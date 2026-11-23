#include "pharovm/pharo.h"
#include <sys/mman.h>
#include <fcntl.h>
#include <signal.h>
#include <errno.h>


#define roundDownToPage(v) ((v)&pageMask)
#define roundUpToPage(v) (((v)+pageSize-1)&pageMask)

sqInt uxMemoryExtraBytesLeft(sqInt includingSwap);

#if !defined(MAP_ANON)
# if defined(MAP_ANONYMOUS)
#   define MAP_ANON MAP_ANONYMOUS
# else
#   define MAP_ANON 0
# endif
#endif

#define MAP_PROT	(PROT_READ | PROT_WRITE)

/* MAP_FIXED_NOREPLACE (Linux >= 4.17) places the mapping exactly at the hint
 * but fails instead of clobbering an existing mapping. Where unavailable we
 * fall back to plain hinting (0), which never clobbers either. */
#if !defined(MAP_FIXED_NOREPLACE)
# define MAP_FIXED_NOREPLACE 0
#endif

/* The 64-bit memory map assumes a 48-bit user virtual address space and asks
 * for oldSpace at 2^40 and permSpace at 2^41. Kernels with a smaller VA (e.g.
 * aarch64 built with CONFIG_ARM64_VA_BITS_39, user space < 2^39) cannot map
 * those addresses, so we retry inside the VA39 user space. VMMemoryMap
 * recomputes the space masks from the addresses actually obtained. */
#define VA39_ADDRESS_LIMIT	((usqInt)0x8000000000ULL)
#define VA39_FALLBACK_BASE	((usqInt)0x4000000000ULL)

#if __OpenBSD__
#define MAP_FLAGS	(MAP_ANON | MAP_PRIVATE | MAP_STACK)
#else
#define MAP_FLAGS	(MAP_ANON | MAP_PRIVATE)
#endif

#define valign(x)	((x) & pageMask)

/* When the desired address is taken, look for a free place above it in steps
 * of this size, as the Windows allocator does. */
#define ALLOCATION_SEARCH_STEP		((usqInt)1024 * 1024)
#define ALLOCATION_SEARCH_MAX_STEPS	(64 * 1024)

/* Map size bytes at desiredAddress or at the first free address above it.
 * Never replace an existing mapping: the desired address may be taken, e.g. by
 * a thread stack (issue #1112), and MAP_FIXED would silently replace it.
 * VMMemoryMap checks that each zone keeps the order of the spaces.
 * Answer MAP_FAILED if nothing could be mapped. */
static void*
mapAtOrAbove(usqInt desiredAddress, usqInt size, int prot, int flags)
{
	usqInt address = desiredAddress;
	void* result;
	int steps;

	if (!desiredAddress) {
		return mmap(0, size, prot, flags, -1, 0);
	}

	for (steps = 0; steps < ALLOCATION_SEARCH_MAX_STEPS && address >= desiredAddress; steps++) {
		/* Without MAP_FIXED_NOREPLACE (or on kernels older than 4.17, which
		 * ignore it), the address is only a hint: check where it was mapped. */
		result = mmap((void*) address, size, prot, flags | MAP_FIXED_NOREPLACE, -1, 0);

		if (result == MAP_FAILED) {
			/* EEXIST: the address is taken. Anything else (e.g. ENOMEM when the
			 * address is beyond the user address space) will not get better
			 * by going higher. */
			if (errno != EEXIST) {
				return MAP_FAILED;
			}
		} else {
			if ((usqInt) result == address) {
				return result;
			}
			munmap(result, size);
		}

		address += ALLOCATION_SEARCH_STEP;
	}

	errno = ENOMEM;
	return MAP_FAILED;
}

/*xxx THESE SHOULD BE COMMAND-LINE/ENVIRONMENT OPTIONS */
/* Note:
 *
 *   The code allows memory to be overallocated; i.e., the initial
 *   block is reserved via mmap() and then the unused portion
 *   munmap()ped from the top end.  This is INHERENTLY DANGEROUS since
 *   malloc() may randomly map new memory in the block we "reserved"
 *   and subsequently unmap()ped.  Enabling this causes crashes in
 *   Croquet, which makes heavy use of the FFI and thus calls malloc()
 *   all over the place.
 *
 *   For this reason, overallocateMemory is DISABLED by default.
 *
 *   The upshot of all this is that Squeak will claim (and hold on to)
 *   ALL of the available virtual memory (or at least 75% of it) when
 *   it starts up.  If you can't live with that, use the -memory
 *   option to allocate a fixed size heap.
 */

int overallocateMemory	= 0;

#ifndef max
# define max(a, b)  (((a) > (b)) ? (a) : (b))
#endif
#ifndef min
# define min(a, b)  (((a) < (b)) ? (a) : (b))
#endif

static sqInt pageSize = 0;
static usqInt pageMask = 0;
int mmapErrno = 0;


void
sqMakeMemoryExecutableFromTo(unsigned long startAddr, unsigned long endAddr)
{
	sqInt firstPage = roundDownToPage(startAddr);
	if (mprotect((void *)firstPage,
				 endAddr - firstPage,
				 PROT_READ | PROT_EXEC) < 0){
		logError("mprotect(x,y,PROT_READ | PROT_EXEC)");
		logError("ERRNO: %d\n", errno);
		exit(1);
	}
}

void
sqMakeMemoryNotExecutableFromTo(unsigned long startAddr, unsigned long endAddr)
{
	sqInt firstPage = roundDownToPage(startAddr);
	if (mprotect((void *)firstPage,
				 endAddr - firstPage,
				 PROT_READ | PROT_WRITE) < 0) {
		logErrorFromErrno("mprotect(x,y,PROT_READ | PROT_WRITE)");
		logError("ERRNO: %d\n", errno);
		exit(1);
	}
}


void* allocateJITMemory(usqInt desiredSize, usqInt desiredPosition){
	
	pageMask = ~(getpagesize() - 1);

	usqInt alignedSize = valign(max(desiredSize, 1));
	usqInt desiredBaseAddressAligned = valign(desiredPosition);

#if __APPLE__
	int additionalFlags = MAP_JIT;
	int prot = PROT_READ | PROT_WRITE | PROT_EXEC;
#else
	int additionalFlags = 0;
#	if READ_ONLY_CODE_ZONE
		int prot = PROT_READ | PROT_EXEC;
#	else
		int prot = PROT_READ | PROT_WRITE | PROT_EXEC;
#	endif
#endif

	logDebug("Trying to allocate JIT memory in %p\n", (void* )desiredBaseAddressAligned);

	void* result = mapAtOrAbove(desiredBaseAddressAligned, alignedSize, prot, MAP_FLAGS | additionalFlags);
	if (MAP_FAILED == result) {
		logErrorFromErrno("Could not allocate JIT memory");
		exit(1);
	}

	return result;
}


/* answer the address of (minHeapSize <= N <= desiredHeapSize) bytes of memory. */
usqInt
sqAllocateMemory(usqInt minHeapSize, usqInt desiredHeapSize, usqInt desiredBaseAddress) {
    char *heap    =  0;
    sqInt   heapLimit    =  0;

	pageSize = getpagesize();
	pageMask = ~(pageSize - 1);

	usqInt desiredBaseAddressAligned = valign(desiredBaseAddress);
	heapLimit = valign(max(desiredHeapSize, 1));
	if(heapLimit < desiredHeapSize){
		heapLimit += pageSize;
	}
#ifndef __APPLE__
	sqInt initialHeapLimit = heapLimit;
#endif

	/* Never let the kernel pick the address: it may give a location too high in the memory map
	 * (e.g. above the next space). Take the desired address or the first free one above it. */
	while ((!heap) && (heapLimit >= minHeapSize)) {
		if (MAP_FAILED == (heap = mapAtOrAbove(desiredBaseAddressAligned, heapLimit, MAP_PROT, MAP_FLAGS))) {
			heap = 0;
			heapLimit = valign(heapLimit / 4 * 3);
		}
	}

#ifndef __APPLE__
	/* Fallback for kernels whose user address space cannot reach the
	 * configured base (see VA39_* above). Look for a place from the VA39
	 * fallback base up; as a last resort let the kernel pick. */
	if (!heap && desiredBaseAddress >= VA39_ADDRESS_LIMIT) {
		heapLimit = initialHeapLimit;
		while ((!heap) && (heapLimit >= minHeapSize)) {
			heap = mapAtOrAbove(VA39_FALLBACK_BASE, heapLimit, MAP_PROT, MAP_FLAGS);
			if (MAP_FAILED == heap) {
				heap = mmap(0, heapLimit, MAP_PROT, MAP_FLAGS, -1, 0);
			}
			if (MAP_FAILED == heap) {
				heap = 0;
				heapLimit = valign(heapLimit / 4 * 3);
			}
		}
	}
#endif

	logDebug("Requested memory size: %zu at: %p, aligned size: %zu at: %p, obtained at: %p" , desiredHeapSize, desiredBaseAddress, heapLimit, desiredBaseAddressAligned, heap);
	return (usqInt) heap;
}

/* Deallocate a region of memory previously allocated by
 * sqAllocateMemorySegmentOfSizeAboveAllocatedSizeInto.  Cannot fail.
 */
void
sqDeallocateMemorySegmentAtOfSize(void *addr, sqInt sz)
{
	if (munmap(addr, sz) != 0)
		logErrorFromErrno("sqDeallocateMemorySegment... munmap");
}

