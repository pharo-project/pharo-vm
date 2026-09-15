#ifndef __SQ_WIN32_ALLOC_H
#define __SQ_WIN32_ALLOC_H

#include "memoryAccess.h"

/*
   Limit the default size for virtual memory to 512MB to avoid nasty
   spurious problems when large dynamic libraries are loaded later.
   Applications needing more virtual memory can increase the size by
   defining it appropriately - here we try to cater for the common
   case by using a "reasonable" size that will leave enough space for
   other libraries. 
*/
#ifndef MAX_VIRTUAL_MEMORY
#define MAX_VIRTUAL_MEMORY 512*1024*1024
#endif

/* Memory initialize-release */
#undef sqAllocateMemory
#undef sqMemoryExtraBytesLeft

extern usqInt sqAllocateMemory(usqInt minHeapSize, usqInt desiredHeapSize, usqInt baseAddress, usqInt limit);
extern void* allocateJITMemory_limit(usqInt desiredSize, usqInt desiredPosition, usqInt limit);

int sqMemoryExtraBytesLeft(int includingSwap);

#endif /* __SQ_WIN32_ALLOC_H */
