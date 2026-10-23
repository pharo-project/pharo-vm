#include "pharovm/semaphores/platformSemaphore.h"

/*
 * This Functions are private to the implementation
 */
PlatformSemaphore semaphore_new(long initialValue);
int semaphore_wait(PlatformSemaphore sem);
int semaphore_signal(PlatformSemaphore sem);
int semaphore_release(PlatformSemaphore sem);

#if defined(_WIN32)

#include <windows.h>

/*
 * Win32 semaphore implementation based on WaitOnAddress.
 *
 * The count is changed atomically. Waiting threads sleep only while the count
 * is zero, and a signal wakes one waiter after publishing one token. As
 * WaitOnAddress permits spurious wake-ups, semaphore_wait always rechecks the
 * count and claims a token with compare-and-exchange.
 *
 * https://learn.microsoft.com/windows/win32/api/synchapi/nf-synchapi-waitonaddress
 */

#define PLATFORM_SEMAPHORE_MAX_COUNT 255

struct PharoPlatformSemaphore {
	volatile LONG count;
};

PlatformSemaphore
semaphore_new(long initialValue) {
	PlatformSemaphore semaphore;

	if (initialValue < 0 || initialValue > PLATFORM_SEMAPHORE_MAX_COUNT) {
		return NULL;
	}

	semaphore = malloc(sizeof(*semaphore));
	if (semaphore == NULL) {
		return NULL;
	}

	semaphore->count = (LONG) initialValue;
	return semaphore;
}

int
semaphore_wait(PlatformSemaphore sem) {
	LONG count;
	LONG unavailable = 0;

	if (sem == NULL) {
		return 1;
	}

	for (;;) {
		/* InterlockedCompareExchange with identical exchange and comparand
		 * values provides an atomic load with the required memory ordering. */
		count = InterlockedCompareExchange(&sem->count, 0, 0);

		if (count == 0) {
			if (!WaitOnAddress(
					&sem->count,
					&unavailable,
					sizeof(unavailable),
					INFINITE)) {
				return 1;
			}
			continue;
		}

		if (InterlockedCompareExchange(&sem->count, count - 1, count) == count) {
			return 0;
		}
	}
}

int
semaphore_signal(PlatformSemaphore sem) {
	LONG count;

	if (sem == NULL) {
		return 1;
	}

	for (;;) {
		count = InterlockedCompareExchange(&sem->count, 0, 0);
		if (count >= PLATFORM_SEMAPHORE_MAX_COUNT) {
			return 1;
		}

		if (InterlockedCompareExchange(&sem->count, count + 1, count) == count) {
			/* Wake after every published token. Restricting this to the zero-to-one
			 * transition can strand waiters when several signals arrive together. */
			WakeByAddressSingle((PVOID) &sem->count);
			return 0;
		}
	}
}

int
semaphore_release(PlatformSemaphore sem) {
	if (sem == NULL) {
		return 1;
	}

	free(sem);
	return 0;
}

#elif !defined(__APPLE__)

PlatformSemaphore
semaphore_new(long initialValue){
	PlatformSemaphore wrapper = malloc(sizeof(sem_t));
    int returnCode;

	if (wrapper == NULL) {
		return NULL;
	}

    returnCode = sem_init(wrapper, 0, initialValue);

    if(returnCode != 0){
		free(wrapper);
        return NULL;
    }

    return wrapper;
}

int
semaphore_wait(PlatformSemaphore sem){
    int returnCode;
    while((returnCode = sem_wait(sem)) == -1  && errno == EINTR);
    return returnCode;
}

int
semaphore_signal(PlatformSemaphore sem){
    return sem_post(sem);
}

int
semaphore_release(PlatformSemaphore sem){
    sem_destroy(sem);
    free(sem);
    return 0;
}

#else

PlatformSemaphore
semaphore_new(long initialValue){
    return dispatch_semaphore_create(initialValue);
}

int
semaphore_wait(PlatformSemaphore sem){
	dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER );
    return 0;
}

int
semaphore_signal(PlatformSemaphore sem){
    dispatch_semaphore_signal(sem);
    return 0;
}

int
semaphore_release(PlatformSemaphore sem){
    /* https://developer.apple.com/documentation/dispatch/1496328-dispatch_release
      If your app is built with a deployment target of macOS 10.8 and later or iOS v6.0 and
      later, dispatch queues are typically managed by ARC, so you do not need to retain or release
      the dispatch queues.
      TODO: No idea if this applies (need to check later), but this is crashing the system.
    dispatch_release(sem);
     */
    return 0;
}

#endif

int
platform_semaphore_wait(Semaphore *semaphore){
	return semaphore_wait((PlatformSemaphore)semaphore->handle);
}

int
platform_semaphore_signal(Semaphore *semaphore){
	return semaphore_signal((PlatformSemaphore)semaphore->handle);
}

void
platform_semaphore_free(Semaphore *semaphore){
	semaphore_release((PlatformSemaphore)semaphore->handle);
	free(semaphore);
}

Semaphore*
platform_semaphore_new(int initialValue) {
	Semaphore *semaphore = (Semaphore *) malloc(sizeof(Semaphore));
	PlatformSemaphore handle;

	if (semaphore == NULL) {
		return NULL;
	}

	handle = semaphore_new(initialValue);
	if (!isValidSemaphore(handle)) {
		free(semaphore);
		return NULL;
	}

	semaphore->handle = (void *) handle;
	semaphore->wait = platform_semaphore_wait;
	semaphore->signal = platform_semaphore_signal;
	semaphore->free = platform_semaphore_free;
	return semaphore;
}
