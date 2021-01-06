#ifndef __WORKERTASK__
#define __WORKERTASK__

#include <ffi.h>

#include "callbacks.h"

typedef enum {
    CALLOUT,
    CALLBACK_RETURN,
	WORKER_RELEASE
} WorkerTaskType;

typedef struct {
    WorkerTaskType type;
    void *anExternalFunction;
    ffi_cif *cif;
    void *parametersAddress;
    void *returnHolderAddress;
    int semaphoreIndex;
    void *queueHandle; //NULL unless useQueue == QUEUE_REGISTERED

    //This semaphore is only used if the callback invocation is coming from a thread different than the worker thread
    void *callbackSemaphore;
} WorkerTask;

WorkerTask *worker_task_new(void *externalFunction, ffi_cif *cif, void *parameters, void *returnHolder, int semaphoreIndex);
WorkerTask *worker_task_new_callback(CallbackInvocation* invocation);

/*
 * I create a new task that is used when the worker should be released.
 */
WorkerTask *worker_task_new_release();

void worker_task_release(WorkerTask *task);
void worker_task_set_main_queue(WorkerTask *task);
void worker_task_set_queue(WorkerTask *task, void *queueHandle);

#endif
