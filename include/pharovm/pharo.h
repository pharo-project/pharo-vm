#pragma once

#include "exportDefinition.h"

#include <stddef.h>
#include <stdio.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

#include "sq.h"
#include "config.h"

#include "sqPlatformSpecific.h"
#include "interpreter.h"

#include "debug.h"
#include "sqAssert.h"

#ifdef _WIN32

#include <windows.h>

#endif

EXPORT(const char*) getSourceVersion();
EXPORT(const char*) getVMVersion();
EXPORT(char*) getVMName();

EXPORT(void) setVMName(const char* name);

EXPORT(void) setVMPath(const char* path);

char* getImageName();
void setImageName(const char* name);

int getVMArgumentCount();
char* getVMArgument(int index);

int getImageArgumentCount();
char* getImageArgument(int index);

char** getSystemSearchPaths();
char** getPluginPaths();

void setPharoCommandLineParameters(const char** newVMParams, int newVMParamsCount, const char** newImageParams, int newImageParamsCount);

void initGlobalStructure(void);
void ioInitExternalSemaphores(void);

void ceCheckForInterrupts(void);

sqInt nilObject(void);

EXPORT(long long) getVMGMTOffset();

EXPORT(long) aioPoll(long microSeconds);
EXPORT(void) aioInit(void);

void ioInitTime(void);

EXPORT(char*) getFullPath(char const *relativePath, char* fullPath, int fullPathSize);
EXPORT(void) getBasePath(char const *path, char* basePath, int basePathSize);

EXPORT(void) setProcessArguments(int count, const char** args);
EXPORT(void) setProcessEnvironmentVector(const char** environment);

// Get information about the process arguments.
// Only available if the process using the VM has given them before.
EXPORT(int) getProcessArgumentCount();
EXPORT(const char**) getProcessArgumentVector();
EXPORT(const char**) getProcessEnvironmentVector();

void * loadModuleHandle(const char *fileName);
sqInt freeModuleHandle(void *module);
void *getModuleSymbol(void *module, const char *symbol);

void *getHandler(sqInt anExternalObject);
void *readAddress(sqInt anExternalAddress);

EXPORT(int) isVMRunOnWorkerThread();
void setMaxStacksToPrint(sqInt anInteger);
