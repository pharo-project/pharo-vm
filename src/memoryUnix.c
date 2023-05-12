#include "pharovm/pharo.h"
#include <sys/mman.h>
#include <fcntl.h>
#include <signal.h>


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

#if __OpenBSD__
#define MAP_FLAGS	(MAP_ANON | MAP_PRIVATE | MAP_STACK)
#else
#define MAP_FLAGS	(MAP_ANON | MAP_PRIVATE)
#endif

#define valign(x)	((x) & pageMask)

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

static sqInt   devZero	= -1;

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
//	sqInt firstPage = roundDownToPage(startAddr);
//	if (mprotect((void *)firstPage,
//				 endAddr - firstPage + 1,
//				 PROT_READ | PROT_WRITE | PROT_EXEC) < 0){
//		logError("mprotect(x,y,PROT_READ | PROT_WRITE | PROT_EXEC)");
//		logError("ERRNO: %d\n", errno);
//		exit(1);
//	}
}

void
sqMakeMemoryNotExecutableFromTo(unsigned long startAddr, unsigned long endAddr)
{
//	sqInt firstPage = roundDownToPage(startAddr);
	/* Arguably this is pointless since allocated memory always does include
	 * write permission.  Annoyingly the mprotect call fails on both linux &
	 * mac os x.  So make the whole thing a nop.
	 */
//	if (mprotect((void *)firstPage,
//				 endAddr - firstPage + 1,
//				 PROT_READ | PROT_WRITE) < 0)
//		logErrorFromErrno("mprotect(x,y,PROT_READ | PROT_WRITE)");
}


void* allocateJITMemory(usqInt desiredSize, usqInt desiredPosition){
	
	pageMask = ~(getpagesize() - 1);

	usqInt alignedSize = valign(max(desiredSize, 1));
	usqInt desiredBaseAddressAligned = valign(desiredPosition);
	void* result;

#if __APPLE__	
	int additionalFlags = MAP_JIT;
#else
	int additionalFlags = 0;
#endif
	
	logDebug("Trying to allocate JIT memory in %p\n", (void* )desiredBaseAddressAligned);

	if (MAP_FAILED == (result = mmap((void*) desiredBaseAddressAligned, alignedSize, 
			PROT_READ | PROT_WRITE | PROT_EXEC, 
			MAP_FLAGS | additionalFlags, -1, 0))) {
		logErrorFromErrno("Could not allocate JIT memory");
		exit(1);
	}

	return result;
}


/* answer the address of (minHeapSize <= N <= desiredHeapSize) bytes of memory. */
usqInt
sqAllocateMemory(usqInt minHeapSize, usqInt desiredHeapSize, usqInt desiredBaseAddress) {
    char *heap    =  0;
    sqInt   heapSize    =  0;
    sqInt   heapLimit    =  0;

	pageSize = getpagesize();
	pageMask = ~(pageSize - 1);

	logDebug("Requested Size %"PRIdSQINT, desiredHeapSize);

	heapLimit = valign(max(desiredHeapSize, 1));
	if(heapLimit < desiredHeapSize){
		heapLimit += pageSize;
	}
	
	usqInt desiredBaseAddressAligned = valign(desiredBaseAddress);

	logDebug("Aligned Requested Size %"PRIdSQINT, heapLimit);

	logDebug("Trying to load the image in %p\n",
			(void* )desiredBaseAddressAligned);

	while ((!heap) && (heapLimit >= minHeapSize)) {
		if (MAP_FAILED == (heap = mmap((void*) desiredBaseAddressAligned, heapLimit, MAP_PROT, MAP_FLAGS, devZero, 0))) {
			heap = 0;
			heapLimit = valign(heapLimit / 4 * 3);
		}

/*
 * If we are in linux we have the problem that maybe it gives us a memory location too high in the memory map.
 * To avoid it, we force to use the required base address
 */
#ifndef __APPLE__
		if(heap != 0 && (usqInt)heap != desiredBaseAddressAligned){

			desiredBaseAddressAligned = valign(desiredBaseAddressAligned + pageSize);

			if((usqInt)heap < desiredBaseAddress){
				logError("I cannot find a good memory address starting from: %p", (void*)desiredBaseAddress);
				return 0;
			}

			//If I overflow.
			if(desiredBaseAddress > desiredBaseAddressAligned){
				logError("I cannot find a good memory address starting from: %p", (void*)desiredBaseAddress);
				return 0;
			}

			munmap(heap, heapLimit);
			heap = 0;
		}
#endif
	}

	heapSize = heapLimit;

	if(heap){
		logDebug("Loading the image in %p\n", (void* )heap);
	}

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

