/****************************************************************************
*   PROJECT: Common include
*   FILE:    sq.h
*   CONTENT:
*
*   AUTHOR:
*   ADDRESS:
*   EMAIL:
*   RCSID:   $Id: sq.h 1283 2005-12-31 00:51:12Z rowledge $
*
*/

#ifndef _SQ_H
#define _SQ_H

#include "sqConfig.h"
#include "pharovm/exportDefinition.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <limits.h>

#include "memoryAccess.h"
#include "virtualMachine.h"


#define true	1
#define false	0
#define null	0  /* using "null" because nil is predefined in Think C */

#include "pharovm/semaphores/platformSemaphore.h"


/* Allocate a region of memory of al least sz bytes, at or above minAddr.
 * If the attempt fails, answer null.  If the attempt succeeds, answer the
 * start of the region and assign its size through asp.
 */
extern void sqDeallocateMemorySegmentAtOfSize(void *addr, sqInt sz);

/* Platform-dependent memory size adjustment macro. */

/* Note: This macro can be redefined to allows platforms with a
   fixed application memory partition (notably, the Macintosh)
   to reserve extra C heap memory for special applications that need
   it (e.g., for a 3D graphics library). Since most platforms can
   extend their application memory partition at run time if needed,
   this macro is defined as a noop here and redefined if necessary
   in sqPlatformSpecific.h.
*/

#define reserveExtraCHeapBytes(origHeapSize, bytesToReserve) origHeapSize

/* Platform-dependent millisecond clock macros. */

/* Note: The VM uses two different clock functions for timing, and
   the Cog VMs provide a third.

   The primary one, ioMSecs(), is used to implement Delay and Time
   millisecondClockValue. The resolution of this clock
   determines the resolution of these basic timing functions. For
   doing real-time control of music and MIDI, a clock with resolution
   down to one millisecond is preferred, but a coarser clock (say,
   1/60th second) can be used in a pinch.

   The function ioMicroMSecs() is used only to collect timing statistics
   for the garbage collector and other VM facilities. (The function
   name is meant to suggest that the function is based on a clock
   with microsecond accuracy, even though the times it returns are
   in units of milliseconds.) This clock must have enough precision to
   provide accurate timings, and normally isn't called frequently
   enough to slow down the VM. Thus, it can use a more expensive clock
   than ioMSecs(). This function is listed in the sqVirtualMachine plugin
   support mechanism and thus needs to be a real function, even if a macro is
   use to point to it.

   There was a third form that used to be used for quickly timing primitives in
   order to try to keep millisecond delays up to date. That is no longer used.

   The wall clock is answered by ioSeconds, which answers the number of seconds
   since the start of the 20th century (12pm Dec 31, 1900).

   The Cog VMs depend on a heartbeat to cause the VM to check for interrupts at
   regular intervals (of the order of ever millisecond).  The heartbeat on these
   VMs is responsible for updating a 64-bit microsecond clock with the number
   of microseconds since the start of the 20th century (12pm Dec 31, 1900)
   available via ioUTCMicroseconds and ioLocalMicroseconds.  When exact time is
   required we provide ioUTCMicrosecondsNow & ioLocalMicrosecondsNow that update
   the clock to return the time right now, rather than of the last heartbeat.
*/

long ioMSecs(void);
sqInt ioMicroMSecs(void);

/* duplicate the generated definition in the interpreter.  If they differ the
 * compiler will complain and catch it for us.  We use 0x1FFFFFFF instead of
 * 0x3FFFFFFF so that twice the maximum clock value remains in the positive
 * SmallInteger range.  This assumes 31 bit SmallIntegers; 0x3FFFFFFF is
 * SmallInteger maxVal.
 */
#define MillisecondClockMask 0x1FFFFFFF

#if STACKVM
extern void forceInterruptCheckFromHeartbeat(void);
unsigned volatile long long  ioUTCMicrosecondsNow();
unsigned volatile long long  ioUTCMicroseconds();
unsigned volatile long long  ioLocalMicrosecondsNow();
unsigned volatile long long  ioLocalMicroseconds();
unsigned          long long  ioUTCStartMicroseconds();
sqInt	ioLocalSecondsOffset();
void	ioUpdateVMTimezone();
void	ioSynchronousCheckForEvents();
void	checkHighPriorityTickees(usqLong);
# if ITIMER_HEARTBEAT		/* Hack; allow heartbeat to avoid */
extern int numAsyncTickees; /* prodHighPriorityThread unless necessary */
# endif						/* see platforms/unix/vm/sqUnixHeartbeat.c */
void	ioGetClockLogSizeUsecsIdxMsecsIdx(sqInt*,void**,sqInt*,void**,sqInt*);
void	addIdleUsecs(sqInt);
#endif

/* this function should return the value of the high performance
   counter if there is such a thing on this platform (otherwise return 0) */
sqLong ioHighResClock(void);

/* New filename converting function; used by the interpreterProxy function
  ioFilenamefromStringofLengthresolveAliases. Most platforms can ignore the
  resolveAlias boolean - it seems to only be of use by OSX but is crucial there.
*/
sqInt sqGetFilenameFromString(char * aCharBuffer, char * aFilenameString, sqInt filenameLength, sqInt aBoolean);

/* Macro to provide default null behaviour for ftruncate - a non-ansi call
   used in FilePlugin.
   Override in sqPlatformSpecific.h for each platform that implements a
   file truncate, or consider replacing the
   ../Cross/plugins/FilePlugin/sqFilePluginBasicPrims.c
   file with a platform specific version as Win32 and RISC OS do.
*/
#ifndef sqFTruncate
#define sqFTruncate(filenum, fileoffset) true
#endif

#define insufficientMemoryAvailableError()  error("Failed to allocate memory for the heap")
#define unableToReadImageError()    error("Read failed or premature end of image file")

/* Platform-specific header file may redefine earlier definitions and macros. */

#include "sqPlatformSpecific.h"

/* Interpreter entry points. */

sqInt checkedByteAt(sqInt byteAddress);
sqInt checkedByteAtput(sqInt byteAddress, sqInt byte);
sqInt checkedLongAt(sqInt byteAddress);
sqInt checkedLongAtput(sqInt byteAddress, sqInt a32BitInteger);
sqInt interpret(void);
sqInt primitiveFail(void);
sqInt signalSemaphoreWithIndex(sqInt semaIndex);
sqInt doSignalExternalSemaphores(sqInt);
sqInt success(sqInt);

/* Display, mouse, keyboard, time. */

extern VM_EXPORT void *displayBits;
extern VM_EXPORT int displayWidth, displayHeight, displayDepth;
extern VM_EXPORT sqInt sendWheelEvents;

sqInt ioExit(void);
sqInt ioExitWithErrorCode(int);
sqInt crashInThisOrAnotherThread(sqInt flags);
sqInt ioSeconds(void);
sqInt ioSecondsNow(void);
sqInt ioRelinquishProcessorForMicroseconds(sqInt microSeconds);

#if STACKVM
/* thread subsystem support for e.g. sqExternalSemaphores.c */
void ioInitThreads();

/* Management of the external semaphore table (max size set at startup) */
#if !defined(INITIAL_EXT_SEM_TABLE_SIZE)
# define INITIAL_EXT_SEM_TABLE_SIZE 256
#endif
int   ioGetMaxExtSemTableSize(void);
void  ioSetMaxExtSemTableSize(int);

/* these are used both in the STACKVM & the COGMTVM */
# if !defined(ioCurrentOSThread)
sqOSThread ioCurrentOSThread(void);
# endif
# if !defined(ioOSThreadsEqual)
int  ioOSThreadsEqual(sqOSThread,sqOSThread);
# endif
# if !COGMTVM
extern sqOSThread ioVMThread;
# define getVMOSThread() ioVMThread
# endif
#endif /* STACKVM */

#if STACKVM
/* Event polling via periodic heartbeat thread. */
void  ioInitHeartbeat(void);
int   ioHeartbeatMilliseconds(void);
void  ioSetHeartbeatMilliseconds(int);
unsigned long ioHeartbeatFrequency(int);
#endif /* STACKVM */

#if COGMTVM

extern sqOSThread getVMOSThread();
/* Please read the comment for CogThreadManager in the VMMaker package for
 * documentation of this API.  N.B. code is included from sqPlatformSpecific.h
 * before the code here.  e.g.
 * # include <pthread.h>
 * # define sqOSThread pthread_t
 * # define sqOSSemaphore pthread_cond_t
 * # define ioOSThreadsEqual(a,b) pthread_equal(a,b)
 */
# if !defined(ioGetThreadLocalThreadIndex)
long ioGetThreadLocalThreadIndex(void);
# endif
# if !defined(ioSetThreadLocalThreadIndex)
void ioSetThreadLocalThreadIndex(long);
# endif

# if !defined(ioNewOSThread)
int  ioNewOSThread(void (*func)(void *), void *);
# endif
# if !defined(ioExitOSThread)
void ioExitOSThread(sqOSThread thread);
# endif
# if !defined(ioReleaseOSThreadState)
void ioReleaseOSThreadState(sqOSThread thread);
# endif
# if !defined(ioOSThreadIsAlive)
int  ioOSThreadIsAlive(sqOSThread);
# endif
int  ioNewOSSemaphore(sqOSSemaphore *);
# if !defined(ioDestroyOSSemaphore)
void ioDestroyOSSemaphore(sqOSSemaphore *);
# endif
void ioSignalOSSemaphore(sqOSSemaphore *);
void ioWaitOnOSSemaphore(sqOSSemaphore *);
int  ioNumProcessors(void);
# if !defined(ioTransferTimeslice)
void ioTransferTimeslice(void);
# endif
#endif /* COGMTVM */

/* Image file and VM path names. */
extern char _imageName[];
char *getImageName(void);
sqInt imageNameGetLength(sqInt sqImageNameIndex, sqInt length);
sqInt imageNamePutLength(sqInt sqImageNameIndex, sqInt length);
sqInt imageNameSize(void);
sqInt vmPathSize(void);
sqInt vmPathGetLength(sqInt sqVMPathIndex, sqInt length);

/* The following was not exported by sq.h but we need it
   since if we don't have CURRENT_VERSION around anymore
   and we may want to check for the image version we need it */
sqInt readableFormat(sqInt imageVersion);

/* Image security traps. */
sqInt ioCanRenameImage(void);
sqInt ioCanWriteImage(void);
sqInt ioDisableImageWrite(void);

#include "pharovm/imageAccess.h"

sqInt readImageNamed(char* fileName);

/* Interpreter entry points needed by compiled primitives. */
void *arrayValueOf(sqInt arrayOop);
sqInt checkedIntegerValueOf(sqInt intOop);
void *fetchArrayofObject(sqInt fieldIndex, sqInt objectPointer);
double fetchFloatofObject(sqInt fieldIndex, sqInt objectPointer);
sqInt fetchIntegerofObject(sqInt fieldIndex, sqInt objectPointer);
double floatValueOf(sqInt floatOop);
sqInt pop(sqInt nItems);
sqInt pushInteger(sqInt integerValue);
sqInt sizeOfSTArrayFromCPrimitive(void *cPtr);
sqInt storeIntegerofObjectwithValue(sqInt fieldIndex, sqInt objectPointer, sqInt integerValue);

/* System attributes. */
sqInt attributeSize(sqInt indexNumber);
sqInt getAttributeIntoLength(sqInt indexNumber, sqInt byteArrayIndex, sqInt length);

/*** Pluggable primitive support. ***/

/* NOTE: The following functions are those implemented by sqNamedPrims.c */
void *ioLoadExternalFunctionOfLengthFromModuleOfLength
		(sqInt functionNameIndex, sqInt functionNameLength,
		 sqInt moduleNameIndex, sqInt moduleNameLength);
void *ioLoadExternalFunctionOfLengthFromModuleOfLengthAccessorDepthInto
	(sqInt functionNameIndex, sqInt functionNameLength,
	 sqInt moduleNameIndex,   sqInt moduleNameLength, sqInt *accessorDepthPtr);
sqInt  ioUnloadModuleOfLength(sqInt moduleNameIndex, sqInt moduleNameLength);
void  *ioLoadFunctionFrom(char *functionName, char *pluginName);
sqInt  ioShutdownAllModules(void);
sqInt  ioUnloadModule(char *moduleName);
sqInt  ioUnloadModuleOfLength(sqInt moduleNameIndex, sqInt moduleNameLength);
char  *ioListBuiltinModule(sqInt moduleIndex);
char  *ioListLoadedModule(sqInt moduleIndex);
/* The next two for the FFI, also implemented in sqNamedPrims.c. */
void  *ioLoadModuleOfLength(sqInt moduleNameIndex, sqInt moduleNameLength);
void  *ioLoadSymbolOfLengthFromModule(sqInt functionNameIndex, sqInt functionNameLength, void *moduleHandle);

/* The next three functions must be implemented by sqXYZExternalPrims.c */
/* ioLoadModule:
	Load a module from disk.
	WARNING: this always loads a *new* module. Don't even attempt to find
	a loaded one.
	WARNING: never primitiveFail() within, just return 0
*/
void *ioLoadModule(char *pluginName);

/* ioFindExternalFunctionIn[AccessorDepthInto]:
	Find the function with the given name in the moduleHandle.
	WARNING: never primitiveFail() within, just return 0.
	Note in Spur takes an extra parameter which is defaulted to 0.
*/
void *ioFindExternalFunctionInAccessorDepthInto(char *lookupName, void *moduleHandle, sqInt *accessorDepthPtr);
#define ioFindExternalFunctionIn(ln,mh) ioFindExternalFunctionInAccessorDepthInto(ln,mh,0)

/* ioFreeModule:
	Free the module with the associated handle.
	WARNING: never primitiveFail() within, just return 0.
*/
sqInt ioFreeModule(void *moduleHandle);

/* The version from which this interpreter was generated. */
extern const char *interpreterVersion;

void warning(char* msg);

EXPORT(int) ioGetCurrentWorkingDirectorymaxLength(char * aCString, size_t maxLength);

#endif /* _SQ_H */
