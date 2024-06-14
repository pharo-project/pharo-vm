/* aio.c -- asynchronous file i/o
 * 
 *   Copyright (C) 1996-2006 by Ian Piumarta and other authors/contributors
 *                              listed elsewhere in this file.
 *   All rights reserved.
 *   
 *   This file is part of Unix Squeak.
 * 
 *   Permission is hereby granted, free of charge, to any person obtaining a
 *   copy of this software and associated documentation files (the "Software"),
 *   to deal in the Software without restriction, including without limitation
 *   the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *   and/or sell copies of the Software, and to permit persons to whom the
 *   Software is furnished to do so, subject to the following conditions:
 * 
 *   The above copyright notice and this permission notice shall be included in
 *   all copies or substantial portions of the Software.
 * 
 *   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *   DEALINGS IN THE SOFTWARE.
 */

/* Authors: Ian.Piumarta@squeakland.org, eliot.miranda@gmail.com
 * 
 * Last edited: Tue Mar 29 13:06:00 PDT 2016
 */

/* Multiple changes and authors performed, use the git versioning tool to correctly address them
 */

#include "pharovm/debug.h"
#include "pharovm/semaphores/platformSemaphore.h"
#include "sqMemoryFence.h"
#include "sqaio.h"

#include <sys/types.h>
#include <sys/socket.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/epoll.h>
#include <sys/ioctl.h>
#include <fcntl.h>

#define INCOMING_EVENTS_SIZE	50

/*
 * This is the struct that I am keeping for the registered FD
 */
typedef struct _AioUnixDescriptor {

	int fd;
	void* clientData;
	aioHandler readHandlerFn;
	aioHandler writeHandlerFn;
	struct _AioUnixDescriptor* next;
	int mask;

} AioUnixDescriptor;

/*
 * I have to keep a list of the registered FDs as the operations are divided in two functions
 */
AioUnixDescriptor* descriptorList = NULL;

/*
 * I can access the elements in the list
 */
AioUnixDescriptor* AioUnixDescriptor_find(int fd);
void AioUnixDescriptor_remove(int fd);
void AioUnixDescriptor_removeAll();

/*
 * This is important, the AIO poll should only do a long pause if there is no pending signals for semaphores.
 * Check ExternalSemaphores to understand this function.
 */
int isPendingSemaphores();

void heartbeat_poll_enter(long microSeconds);
void heartbeat_poll_exit(long microSeconds);
static int aio_handle_events(long microSeconds);

Semaphore* interruptFIFOMutex;
int pendingInterruption;
int aio_in_sleep = 0;
int aio_request_interrupt = 0;

volatile int isPooling = 0;

/* initialise asynchronous i/o */

int signal_pipe_fd[2];

void sigIOHandler(int signum){
	forceInterruptCheck();
}

void 
aioInit(void)
{
	int arg;
	
	interruptFIFOMutex = platform_semaphore_new(1);

	if (pipe(signal_pipe_fd) != 0) {
		logErrorFromErrno("pipe");
		exit(-1);
	}

	if ((arg = fcntl(signal_pipe_fd[0], F_GETFL, 0)) < 0)
		logErrorFromErrno("fcntl(F_GETFL)");
	if (fcntl(signal_pipe_fd[0], F_SETFL, arg | O_NONBLOCK | O_ASYNC ) < 0)
		logErrorFromErrno("fcntl(F_SETFL, O_ASYNC)");

	if ((arg = fcntl(signal_pipe_fd[1], F_GETFL, 0)) < 0)
		logErrorFromErrno("fcntl(F_GETFL)");
	if (fcntl(signal_pipe_fd[1], F_SETFL, arg | O_NONBLOCK | O_ASYNC | O_APPEND) < 0)
		logErrorFromErrno("fcntl(F_SETFL, O_ASYNC)");

	signal(SIGIO, sigIOHandler);
}

/* disable handlers and close all handled non-exteral descriptors */

void 
aioFini(void)
{	
	AioUnixDescriptor_removeAll();
	signal(SIGIO, SIG_DFL);
}


/*
 * answer whether i/o becomes possible within the given number of
 * microSeconds
 */
#ifndef max
# define max(a, b)  (((a) > (b)) ? (a) : (b))
#endif


volatile int aio_requests = 0;
volatile int aio_responses = 0;

/*
 * I Try to clear all the data available in the pipe, so it does not passes the limit of data.
 * Do not call me outside the mutex area of interruptFIFOMutex.
 */
void
aio_flush_pipe(int fd){

	int bytesRead;
	char buf[1024];

	interruptFIFOMutex->wait(interruptFIFOMutex);
	if(pendingInterruption){
		pendingInterruption = false;
	}

	do {
		bytesRead = read(fd, &buf, 1024);

		if(bytesRead == -1){

			if(errno == EAGAIN || errno == EWOULDBLOCK){
				interruptFIFOMutex->signal(interruptFIFOMutex);
				return;
			}

			logErrorFromErrno("pipe - read");

			interruptFIFOMutex->signal(interruptFIFOMutex);
			return;
		}

	} while(bytesRead > 0);

	interruptFIFOMutex->signal(interruptFIFOMutex);
}

long
aioPoll(long microSeconds){
	long timeout;

	interruptFIFOMutex->wait(interruptFIFOMutex);

	if(pendingInterruption || isPendingSemaphores()){
		timeout = 0;
	}else{
		timeout = microSeconds;
	}

	if(pendingInterruption){
		pendingInterruption = false;
	}

	interruptFIFOMutex->signal(interruptFIFOMutex);

	return aio_handle_events(timeout);
}

static int addFDToEPoll(int epollDescriptor, int fd, int events, void* userData){
	struct epoll_event ev;
	ev.events = events;
	ev.data.ptr = userData;
	
	if (epoll_ctl(epollDescriptor, EPOLL_CTL_ADD, fd, &ev) == -1) {
		logError("Error adding FD %d to Epoll", fd);
		logErrorFromErrno("epoll_ctl");
		return -1;
	}

	return 0;
}

static int fillEPollDescriptor(){

	int epollDescriptor = epoll_create1(0);

	if (epollDescriptor == -1) {
		logErrorFromErrno("epoll_create1");
		return -1;
	}

	if(addFDToEPoll(epollDescriptor, signal_pipe_fd[0], EPOLLIN, NULL) == -1){
		logError("Error adding Pipe FD");

		if(epollDescriptor != -1){
			close(epollDescriptor);
			epollDescriptor = -1;
		}
		return -1;
	}

	AioUnixDescriptor* descriptor = descriptorList;

	while(descriptor){
		int hasRead = (descriptor->mask & AIO_R) == AIO_R;
		int hasWrite = (descriptor->mask & AIO_W) == AIO_W;
		int hasExceptions = (descriptor->mask & AIO_X) == AIO_X;

		int events = 0;
		events |= hasRead ? (EPOLLIN | EPOLLRDHUP) : 0;
		events |= hasWrite ? (EPOLLOUT | EPOLLRDHUP) : 0;
		events |= hasExceptions ? (EPOLLERR | EPOLLRDHUP) : 0;

		if(addFDToEPoll(epollDescriptor, descriptor->fd, events, descriptor) == -1){
			if(epollDescriptor != -1){
				close(epollDescriptor);
				epollDescriptor = -1;
			}

			return -1;
		}

		descriptor = descriptor->next;
	}

	return epollDescriptor;
}

static int
aio_handle_events(long microSecondsTimeout){

	struct epoll_event incomingEvents[INCOMING_EVENTS_SIZE];
	int epollReturn;
	int withError = 0;
	AioUnixDescriptor* triggeredDescriptor;

	int epollDescriptor = -1;

	long milliSecondsTimeout = microSecondsTimeout / 1000;

	//I notify the heartbeat of a pause
	heartbeat_poll_enter(microSecondsTimeout);

	sqLowLevelMFence();
	isPooling = 1;

	epollDescriptor = fillEPollDescriptor();
		
	epollReturn = epoll_wait(epollDescriptor, incomingEvents, INCOMING_EVENTS_SIZE, milliSecondsTimeout);

	if(epollDescriptor != -1){
		close(epollDescriptor);
		epollDescriptor = -1;
	}

	sqLowLevelMFence();
	isPooling = 0;

	interruptFIFOMutex->wait(interruptFIFOMutex);
	pendingInterruption = false;
	interruptFIFOMutex->signal(interruptFIFOMutex);

	//I notify the heartbeat of the end of the pause
	heartbeat_poll_exit(microSecondsTimeout);
	aio_flush_pipe(signal_pipe_fd[0]);

	if(epollReturn == -1){
		if(errno != EINTR){
			logErrorFromErrno("epoll_wait");
		}
		return 0;
	}

	if(epollReturn == 0){
		return 0;
	}

	for(int index = 0; index < epollReturn; index++){
		//Only process the signals that are not from the interrupt pipe
		if(incomingEvents[index].data.ptr != NULL){
			triggeredDescriptor = (AioUnixDescriptor*) incomingEvents[index].data.ptr;

			// Clearing the mask aioHandle will re add it
			triggeredDescriptor->mask = 0;
			
			if((incomingEvents[index].events & EPOLLERR) == EPOLLERR){
				withError = AIO_X;
			}else{
				withError = 0;
			}

			if((incomingEvents[index].events & EPOLLIN) == EPOLLIN){
				if(triggeredDescriptor->readHandlerFn){
					triggeredDescriptor->readHandlerFn(triggeredDescriptor->fd, triggeredDescriptor->clientData, AIO_R | withError);
				}
			}
			if((incomingEvents[index].events & EPOLLOUT) == EPOLLOUT){
				if(triggeredDescriptor->writeHandlerFn){
					triggeredDescriptor->writeHandlerFn(triggeredDescriptor->fd, triggeredDescriptor->clientData, AIO_W | withError);
				}
			}
		}
	}

	return 1;
}

/*
 * This function is used to interrupt a aioPoll.
 * Used when signalling a Pharo semaphore to re-wake the VM and execute code of the image.
 */

void
aioInterruptPoll(){
	int n;

	sqLowLevelMFence();

	if(isPooling){
		n = write(signal_pipe_fd[1], "1", 1);
		if(n != 1){
			logErrorFromErrno("write to pipe");
		}
		fsync(signal_pipe_fd[1]);
	}

	interruptFIFOMutex->wait(interruptFIFOMutex);
	pendingInterruption = true;
	interruptFIFOMutex->signal(interruptFIFOMutex);
}

void 
aioEnable(int fd, void *clientData, int flags)
{
	AioUnixDescriptor * descriptor;

	if (fd < 0) {
		logWarn("AioEnable(%d): IGNORED - Negative Number", fd);
		return;
	}

	descriptor = AioUnixDescriptor_find(fd);

	if(descriptor == NULL){
		descriptor = malloc(sizeof(AioUnixDescriptor));
		descriptor->readHandlerFn = NULL;
		descriptor->writeHandlerFn = NULL;
		descriptor->next = descriptorList;
		descriptorList = descriptor;
		descriptor->mask = 0;
	}

	descriptor->fd = fd;
	descriptor->clientData = clientData;

	logTrace("Enabling FD: %d", (int) descriptor->fd);

	/* we should not set NBIO ourselves on external descriptors! */
	if ((flags & AIO_EXT) != AIO_EXT) {
		/*
		 * enable non-blocking asynchronous i/o and delivery of SIGIO
		 * to the active process
		 */
		int	arg;

#if defined(O_ASYNC)
		if (fcntl(fd, F_SETOWN, getpid()) < 0)
			logErrorFromErrno("fcntl(F_SETOWN, getpid())");
		if ((arg = fcntl(fd, F_GETFL, 0)) < 0)
			logErrorFromErrno("fcntl(F_GETFL)");
		if (fcntl(fd, F_SETFL, arg | O_NONBLOCK | O_ASYNC) < 0)
			logErrorFromErrno("fcntl(F_SETFL, O_ASYNC)");

#elif defined(FASYNC)
		if (fcntl(fd, F_SETOWN, getpid()) < 0)
			logErrorFromErrno("fcntl(F_SETOWN, getpid())");
		if ((arg = fcntl(fd, F_GETFL, 0)) < 0)
			logErrorFromErrno("fcntl(F_GETFL)");
		if (fcntl(fd, F_SETFL, arg | O_NONBLOCK | FASYNC) < 0)
			logErrorFromErrno("fcntl(F_SETFL, FASYNC)");

#elif defined(FIOASYNC)
		arg = getpid();
		if (ioctl(fd, SIOCSPGRP, &arg) < 0)
			logErrorFromErrno("ioctl(SIOCSPGRP, getpid())");
		arg = 1;
		if (ioctl(fd, FIOASYNC, &arg) < 0)
			logErrorFromErrno("ioctl(FIOASYNC, 1)");
#endif
	}
}


/* install/change the handler for a descriptor */

void 
aioHandle(int fd, aioHandler handlerFn, int mask)
{
	AioUnixDescriptor *descriptor = AioUnixDescriptor_find(fd);

	if(descriptor == NULL){
		logWarn("Enabling a FD that is not present: %d - IGNORING", fd);
		return;
	}

	int hasRead = (mask & AIO_R) == AIO_R;
	int hasWrite = (mask & AIO_W) == AIO_W;

	descriptor->readHandlerFn = hasRead ? handlerFn : NULL;
	descriptor->writeHandlerFn = hasWrite ? handlerFn : NULL;
	descriptor->mask = mask;
}


/* temporarily suspend asynchronous notification for a descriptor */

void 
aioSuspend(int fd, int maskToSuspend)
{
	AioUnixDescriptor *descriptor = AioUnixDescriptor_find(fd);

	if(descriptor == NULL){
		logWarn("Enabling a FD that is not present: %d - IGNORING", fd);
		return;
	}
	
	// If original MASK is 0, we don't register it before. Nothing to suspend
	if(descriptor->mask == 0){
		return;
	}
	
	int hasRead = (maskToSuspend & AIO_R) == AIO_R;
	int hasWrite = (maskToSuspend & AIO_W) == AIO_W;
	int hasExceptions = (maskToSuspend & AIO_X) == AIO_X;

	if(hasRead){
		descriptor->readHandlerFn = NULL;
		descriptor->mask &= ~AIO_R;
	}

	if(hasWrite){
		descriptor->writeHandlerFn = NULL;		
		descriptor->mask &= ~AIO_W;
	}

	if(hasExceptions){
		descriptor->mask &= ~AIO_X;
	}
}


/* definitively disable asynchronous notification for a descriptor */

void 
aioDisable(int fd)
{
	AioUnixDescriptor_remove(fd);
}

AioUnixDescriptor* AioUnixDescriptor_find(int fd){
	AioUnixDescriptor* found;

	found = descriptorList;
	while(found != NULL){
		if(found->fd == fd)
			return found;
		found = found->next;
	}

	return NULL;
}

void AioUnixDescriptor_remove(int fd){
	AioUnixDescriptor* found;
	AioUnixDescriptor* prev = NULL;

	found = descriptorList;

	while(found != NULL){

		if(found->fd == fd){
			if(descriptorList == found){
				descriptorList = found->next;
			}else{
				prev->next = found->next;
			}
			free(found);
			return;
		}
		prev = found;
		found = found->next;
	}

}

void AioUnixDescriptor_removeAll(){
	AioUnixDescriptor* current;

	while(descriptorList != NULL){
		current = descriptorList;
		descriptorList = current->next;
		free(current);
	}
}