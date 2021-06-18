#include "callbacks.h"
#if FEATURE_THREADED_FFI
#ifdef _WIN32
# include <Windows.h>
#else
# include <pthread.h>
#endif
#endif //FEATURE_THREADED_FFI

EXPORT(int) singleCallToCallback(SIMPLE_CALLBACK fun, int base){
	return fun(base + 1);
}

EXPORT(int) callbackInALoop(SIMPLE_CALLBACK fun){
	int i;
	int acc = 0;
	
	for(i=0;i<42;i++){
		acc = fun(acc);
	}
	
	return acc;
}

EXPORT(int) reentringCallback(SIMPLE_CALLBACK fun, int base){
	printf("Value entered: %d\n", base);

	if(base == 0)
		return 1;

	return fun(base);
}

static int value = 0;

#if FEATURE_THREADED_FFI
void* otherThread(void* aFunction){
	SIMPLE_CALLBACK f = (SIMPLE_CALLBACK) aFunction;
	
#ifdef _WIN32
	Sleep(3);
#else
	sleep(3);
#endif

	value = f(42);
}
#endif //FEATURE_THREADED_FFI

EXPORT(int) getValue(){
	return value;
}

EXPORT(void) callbackFromAnotherThread(SIMPLE_CALLBACK fun){
#if FEATURE_THREADED_FFI
	value = 0;

#if defined(_WIN32)
	CreateThread(
		NULL,					// default security attributes
		0,						// use default stack size
		otherThread,	// thread function name
		fun,					// argument to thread function
		0,						// use default creation flags: 0 is run immediately
		NULL);				// returns the thread identifier
#else
	pthread_t t;
	pthread_create(&t, NULL, otherThread, fun);
	pthread_detach(t);
#endif

#endif //FEATURE_THREADED_FFI
}
