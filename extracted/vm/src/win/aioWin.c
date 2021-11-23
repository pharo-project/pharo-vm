#include "winsock2.h"
#include "pharovm/pharo.h"
#include "sqaio.h"

#include "windows.h"

void heartbeat_poll_enter(long microSeconds);

void heartbeat_poll_exit(long microSeconds);

typedef struct _AioFileDescriptor {

	int fd;
	void* clientData;
	int flags;
	int mask;
	aioHandler handlerFn;

	HANDLE readEvent;
	HANDLE writeEvent;

	struct _AioFileDescriptor* next;

} AioFileDescriptor;

AioFileDescriptor* fileDescriptorList = NULL;

HANDLE interruptEvent;
HANDLE interruptMultiWait;

AioFileDescriptor * aioFileDescriptor_new(){

	AioFileDescriptor* last;
	AioFileDescriptor* aNewFD = malloc(sizeof(AioFileDescriptor));

	if(fileDescriptorList == NULL){
		fileDescriptorList = aNewFD;
		return aNewFD;
	}

	last = fileDescriptorList;

	while(last->next != NULL){
		last = last->next;
	}

	last->next = aNewFD;
	return aNewFD;
}

AioFileDescriptor * aioFileDescriptor_find(int fd){

	AioFileDescriptor* found;

	if(fileDescriptorList == NULL){
		return NULL;
	}

	found = fileDescriptorList;

	while(found != NULL && found->fd != fd){
		found = found->next;
	}

	return found;
}

void aioFileDescriptor_remove(int fd){

	AioFileDescriptor* found;
	AioFileDescriptor* previous;

	if(fileDescriptorList == NULL){
		return;
	}

	found = fileDescriptorList;
	previous = NULL;

	while(found != NULL && found->fd != fd){
		previous = found;
		found = found->next;
	}

	if(!found) {
		return;
	}

	if(previous == NULL){
		fileDescriptorList = found->next;
	}else{
		previous->next = found->next;
	}

	if((found->flags & AIO_EXT) == 0){
		WSACloseEvent(found->readEvent);
		WSACloseEvent(found->writeEvent);
	}

	free(found);
}

long aioFileDescriptor_numberOfHandles(){
	AioFileDescriptor* element = fileDescriptorList;
	long count = 0;

	while(element){
		if(element->readEvent != NULL) count++;
		if(element->writeEvent != NULL) count++;

		element = element->next;
	}

	return count;
}

void aioFileDescriptor_fillHandles(HANDLE* handles){
	AioFileDescriptor* element = fileDescriptorList;
	long index = 0;

	while(element){
		if(element->readEvent != NULL){
			handles[index] = element->readEvent;
			index++;
		}

		if(element->writeEvent != NULL){
			handles[index] = element->writeEvent;
			index++;
		}
		element = element->next;
	}

}

void aioFileDescriptor_signal_withHandle(HANDLE event){

	AioFileDescriptor* element = fileDescriptorList;

	while(element){

		if(element->readEvent == event){

			/**
			 * The event should be reset once it has been processed.
			 */
			if((element->flags & AIO_EXT) == 0){
				WSAResetEvent(element->readEvent);

				if(element->mask == 0) {
					return;
				}
				//We set the event to 0 so it is not recalled after
				WSAEventSelect(element->fd, element->readEvent, 0);
			}

			element->handlerFn(element->fd, element->clientData, AIO_R);
			return;
		}

		if(element->writeEvent == event){

			/**
			 * The event should be reset once it has been processed.
			 */
			if((element->flags & AIO_EXT) == 0){
				WSAResetEvent(element->writeEvent);

				if(element->mask == 0) {
					return;
				}
				//We set the event to 0 so it is not recalled after
				WSAEventSelect(element->fd, element->writeEvent, 0);
			}

			element->handlerFn(element->fd, element->clientData, AIO_W);
			return;
		}

		element = element->next;
	}
}

EXPORT(void) aioInit(void){
	interruptEvent = CreateEventW(NULL, TRUE, FALSE, L"InterruptEvent");
	if(!interruptEvent){
		char* msg = formatMessageFromErrorCode(GetLastError());
		logError("Impossible to createEvent: %s", msg);
		free(msg);
		exit(1);
	}

	interruptMultiWait = CreateEventW(NULL, TRUE, FALSE, L"InterruptMultiWaitEvent");
	if(!interruptMultiWait){
		char* msg = formatMessageFromErrorCode(GetLastError());
		logError("Impossible to createEvent: %s", msg);
		free(msg);
		exit(1);
	}

}

EXPORT(void) aioFini(void){
	CloseHandle(interruptEvent);
	CloseHandle(interruptMultiWait);
}

EXPORT(void) aioEnable(int fd, void *clientData, int flags){
	AioFileDescriptor * aioFileDescriptor;

	aioFileDescriptor = aioFileDescriptor_find(fd);
	if(!aioFileDescriptor){
		aioFileDescriptor = aioFileDescriptor_new();
		aioFileDescriptor->next = NULL;
	}

	aioFileDescriptor->fd = fd;
	aioFileDescriptor->clientData = clientData;
	aioFileDescriptor->flags = flags;
	aioFileDescriptor->readEvent = (HANDLE)WSACreateEvent();

	if(aioFileDescriptor->readEvent == WSA_INVALID_EVENT){
		int lastError = WSAGetLastError();
		logError("Error WSACreateEvent READ: %ld", lastError);
	}

	aioFileDescriptor->writeEvent = (HANDLE)WSACreateEvent();

	if(aioFileDescriptor->writeEvent == WSA_INVALID_EVENT){
		int lastError = WSAGetLastError();
		logError("Error WSACreateEvent WRITE: %ld", lastError);
	}

	aioFileDescriptor->mask = 0;

	WSAEventSelect(aioFileDescriptor->fd, aioFileDescriptor->writeEvent, 0);
	WSAEventSelect(aioFileDescriptor->fd, aioFileDescriptor->readEvent, 0);

	u_long iMode = 1;
	int iResult;

	iResult = ioctlsocket(fd, FIONBIO, &iMode);
	if (iResult != NO_ERROR){
		char* msg = formatMessageFromErrorCode(GetLastError());
		logError("ioctlsocket(FIONBIO, 1): %s", msg);
		free(msg);
	}
}

EXPORT(void) aioHandle(int fd, aioHandler handlerFn, int mask){
	AioFileDescriptor * aioFileDescriptor;
	char buf[100];

	aioFileDescriptor = aioFileDescriptor_find(fd);

	if(!aioFileDescriptor){
		return;
	}

	aioFileDescriptor->handlerFn = handlerFn;
	aioFileDescriptor->mask = mask;

	/**
	 * Remember to reset the event once is processed
	 */

	if(mask & AIO_R){
		WSAEventSelect(aioFileDescriptor->fd, aioFileDescriptor->readEvent, FD_READ | FD_ACCEPT | FD_OOB | FD_CLOSE);
		//This recv will always generates a WOULDBLOCK, but this is needed to generate the correct event in Windows.
		recv(aioFileDescriptor->fd, (void*)buf, 100, MSG_PEEK);
		return;
	}

	if(mask & AIO_W){
		WSAEventSelect(aioFileDescriptor->fd, aioFileDescriptor->writeEvent, FD_WRITE);
		return;
	}

}

EXPORT(void) aioSuspend(int fd, int mask){
	/**
	 * TODO: It is not used, so we don't implement it now
	 */
	printf("No implemented");
}

EXPORT(void) aioDisable(int fd){
	aioFileDescriptor_remove(fd);
}

EXPORT(void) aioEnableExternalHandler(int fd, HANDLE handle, void *clientData, aioHandler handlerFn, int mask){

	AioFileDescriptor * aioFileDescriptor;

	aioFileDescriptor = aioFileDescriptor_find(fd);
	if(!aioFileDescriptor){
		aioFileDescriptor = aioFileDescriptor_new();
		aioFileDescriptor->next = NULL;
	}

	aioFileDescriptor->fd = fd;
	aioFileDescriptor->clientData = clientData;
	aioFileDescriptor->flags = AIO_EXT;

	if(mask & AIO_R){
		aioFileDescriptor->readEvent = handle;
		aioFileDescriptor->writeEvent = NULL;
	}else{
		aioFileDescriptor->readEvent = NULL;
		aioFileDescriptor->writeEvent = handle;
	}

	aioFileDescriptor->handlerFn = handlerFn;
	aioFileDescriptor->mask = mask;
}

/*
 * As Pipes may not signal an event when there is data we check if any of the handles is a pipe and check if there
 * are data to read, if there is, we signal the handler.
 */
static int checkHandlesForPipes(HANDLE* handlesToQuery, long size){
	int hasEvent = 0;

	for(int i = 0 ; i < size ; i++){
		  if (GetFileType(handlesToQuery[i]) == FILE_TYPE_PIPE ){
			  DWORD maxDataAvailable;
			  DWORD toRead;

			  PeekNamedPipe(handlesToQuery[i],
					  NULL,
					  0,
					  NULL,
					  &maxDataAvailable,
					  NULL);

			  if(maxDataAvailable > 0){
				  aioFileDescriptor_signal_withHandle(handlesToQuery[i]);
				  hasEvent = 1;
			  }
		  }
	}

	return hasEvent;
}

static int checkEventsInHandles(HANDLE* handlesToQuery, int size){
	int hasEvent = 0;

	for(int i=0; i < size; i++){
		if(WaitForSingleObject(handlesToQuery[i], 0) == WAIT_OBJECT_0) {
			aioFileDescriptor_signal_withHandle(handlesToQuery[i]);
			hasEvent = 1;
		}
	}

	hasEvent |= checkHandlesForPipes(handlesToQuery, size);

	return hasEvent;
}

struct sliceData {
	HANDLE* handles;
	int size;
	long microSeconds;
};

DWORD WINAPI waitHandlesThreadFunction(struct sliceData* sliceData ){

	DWORD returnValue;
	HANDLE* handles;
	int size;
	long microSeconds;

	// I copy the data just in case.

	size = sliceData->size;
	microSeconds = sliceData->microSeconds;

	handles = malloc(sizeof(HANDLE) * size);
	for(int i = 0; i < size; i++){
		handles[i] = sliceData->handles[i];
	}

	free(sliceData);

	returnValue = WaitForMultipleObjectsEx(size, handles, FALSE, microSeconds / 1000, FALSE);

	free(handles);
	return 0;
}

static HANDLE sliceWaitForMultipleObjects(HANDLE* allHandles, int initialIndex, int sizeToProcess, long microSeconds){

	HANDLE r;
	struct sliceData* sliceData = malloc(sizeof(struct sliceData));

	sliceData->handles = &(allHandles[initialIndex]);
	sliceData->size = sizeToProcess;
	sliceData->microSeconds = microSeconds;

//	logTrace("Launching slice from %d size %d", initialIndex, sizeToProcess);

	r = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE) waitHandlesThreadFunction, sliceData, 0, NULL);

	if(r)
		return r;

	int lastError = GetLastError();

	char* msg = formatMessageFromErrorCode(lastError);

	logError("Error CreateThread: %d - %s", lastError,msg);

	return NULL;
}

EXPORT(long) aioPoll(long microSeconds){

	HANDLE* allHandles;
	HANDLE* waitingHandles;
	int numberOfThreads;
	DWORD returnValue;
	AioFileDescriptor* signaled;
	int hasEvents = 0;


	/*
	 * As we only can test for MAXIMUM_WAIT_OBJECTS in a single shot,
	 * we are going to divide them in MAXIMUM_WAIT_OBJECTS - 1 threads.
	 * The remaining slot is used by the interruptEvent.
	 */

	//We need an array with all the handles to process
	long size = aioFileDescriptor_numberOfHandles();
	allHandles = malloc(sizeof(HANDLE) *size);
	aioFileDescriptor_fillHandles(allHandles);

	//Let's calculate the number of threads needed.
	numberOfThreads = size / MAXIMUM_WAIT_OBJECTS;
	if(size % MAXIMUM_WAIT_OBJECTS){
		numberOfThreads++;
	}

	/*
	* If the number of threads is bigger than the ones I can manage I will handle as the timeout has arrive.
	* This is not the best, but it will not break the behaviour.
	*/

	if((numberOfThreads + 1) > MAXIMUM_WAIT_OBJECTS){

		logTrace("More threads than MAXIMUM_WAIT_OBJECTS, just checking one by one");

		checkEventsInHandles(allHandles, size);
		free(allHandles);
		return 1;
	}


	waitingHandles = malloc(sizeof(HANDLE) * (numberOfThreads + 1));

	heartbeat_poll_enter(microSeconds);

	/*
	 * We pass the interrupt event as the first handler
	 */
	waitingHandles[0] = interruptEvent;

	int remainingSize = size;
	int initialIndex = 0;
	int sizeToProcess = 0;

	for(int i=1; i <= numberOfThreads; i++){

		sizeToProcess = remainingSize > MAXIMUM_WAIT_OBJECTS ? MAXIMUM_WAIT_OBJECTS : remainingSize;

		waitingHandles[i] = sliceWaitForMultipleObjects(allHandles, initialIndex, sizeToProcess, microSeconds);

		if(waitingHandles[i] == NULL){

			for(int j=1; j < i; j++){
				CloseHandle(waitingHandles[j]);
			}

			free(waitingHandles);
			free(allHandles);

			return 0;
		}

		remainingSize = remainingSize - MAXIMUM_WAIT_OBJECTS;
		initialIndex = initialIndex + MAXIMUM_WAIT_OBJECTS;
	}

	returnValue = WaitForMultipleObjectsEx(numberOfThreads + 1, waitingHandles, FALSE, microSeconds / 1000, FALSE);

	/*
	 * Closing handles
	 */

	for(int i=1; i <= numberOfThreads; i++){
		CloseHandle(waitingHandles[i]);
	}


	if(returnValue == WAIT_TIMEOUT){
		heartbeat_poll_exit(microSeconds);

		free(waitingHandles);
		free(allHandles);

		return hasEvents;
	}

	if(returnValue == WAIT_FAILED){
		int lastError = GetLastError();

		char* msg = formatMessageFromErrorCode(lastError);

		logError("Error WaitForMultipleObjecsEx: %d - %s", lastError,msg);
		logError("%d - %p - %ld", size+1, waitingHandles, microSeconds);

		free(msg);

		free(waitingHandles);
		free(allHandles);

		return 0;
	}

	heartbeat_poll_exit(microSeconds);

	/*
	 * If it is the first is the interrupt event that we use to break the poll.
	 * If it is interrupted we need to clear the interrupt event
	 */

	if(returnValue == WAIT_OBJECT_0){
		ResetEvent(interruptEvent);
	}else{
		hasEvents = checkEventsInHandles(allHandles, size);
	}

	free(waitingHandles);
	free(allHandles);
	return hasEvents;
}

EXPORT(void) aioInterruptPoll(){
	SetEvent(interruptEvent);
}

