#ifndef PHAROVM_PARAMETERS_H
#define PHAROVM_PARAMETERS_H

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include "pharovm/parameters/parameterVector.h"
#include <stdio.h>

/**

 OSX:

  --memory <size>[mk]    use fixed heap size (added to image size)
  --nohandlers           disable sigsegv & sigusr1 handlers
  --timephases           print start load and run times
  --breaksel selector    set breakpoint on send of selector
  --breakmnu selector    set breakpoint on MNU of selector
  --eden <size>[mk]      set eden memory to bytes
  --leakcheck num        check for leaks in the heap
  --stackpages num       use n stack pages
  --numextsems num       make the external semaphore table num in size
  --noheartbeat          disable the heartbeat for VM debugging. disables input
  --pollpip              output . on each poll for input
  --checkpluginwrites    check for writes past end of object in plugins
  --trace[=num]          enable tracing (optionally to a specific value)
  --warnpid              print pid in warnings
  --codesize <size>[mk]  set machine code memory to bytes
  --tracestores          enable store tracing (assert check stores)
  --cogmaxlits <n>       set max number of literals for methods to be compiled to machine code
  --cogminjumps <n>      set min number of backward jumps for interpreted methods to be considered for compilation to machine code
  --reportheadroom       report unused stack headroom on exit
  --maxoldspace <size>[mk]      set max size of old space memory to bytes
  --logscavenge          log scavenging to scavenge.log
  --headless             run in headless (no window) mode (default: false)
  --headfull             run in headful (window) mode (default: true)
  --version              print version information, then exit
  --blockonerror         on error or segv block, not exit.  useful for attaching gdb
  --blockonwarn          on warning block, don't warn.  useful for attaching gdb
  --exitonwarn           treat warnings as errors, exiting on warn


LINUX:

  -encoding <enc>       set the internal character encoding (default: MacRoman)
  -help                 print this help message, then exit
  -memory <size>[mk]    use fixed heap size (added to image size)
  -mmap <size>[mk]      limit dynamic heap size (default: 1024m)
  -timephases           print start load and run times
  -breaksel selector    set breakpoint on send of selector
  -breakmnu selector    set breakpoint on MNU of selector
  -eden <size>[mk]      use given eden size
  -leakcheck num        check for leaks in the heap
  -stackpages <num>     use given number of stack pages
  -noevents             disable event-driven input support
  -nohandlers           disable sigsegv & sigusr1 handlers
  -pollpip              output . on each poll for input
  -checkpluginwrites    check for writes past end of object in plugins
  -pathenc <enc>        set encoding for pathnames (default: UTF-8)
  -plugins <path>       specify alternative plugin location (see manpage)
  -textenc <enc>        set encoding for external text (default: UTF-8)
  -version              print version information, then exit
  -vm-<sys>-<dev>       use the <dev> driver for <sys> (see below)
  -trace[=num]          enable tracing (optionally to a specific value)
  -warnpid              print pid in warnings
  -codesize <size>[mk]  set machine code memory to bytes
  -tracestores          enable store tracing (assert check stores)
  -cogmaxlits <n>       set max number of literals for methods compiled to machine code
  -cogminjumps <n>      set min number of backward jumps for interpreted methods to be considered for compilation to machine code
  -reportheadroom       report unused stack headroom on exit
  -maxoldspace <size>[mk]    set max size of old space memory to bytes
  -logscavenge          log scavenging to scavenge.log
  -blockonerror         on error or segv block, not exit.  useful for attaching gdb
  -blockonwarn          on warning block, don't warn.  useful for attaching gdb
  -exitonwarn           treat warnings as errors, exiting on warn
Deprecated:
  -notimer              disable interval timer for low-res clock
  -display <dpy>        equivalent to '-vm-display-X11 -display <dpy>'
  -headless             equivalent to '-vm-display-X11 -headless'
  -nodisplay            equivalent to '-vm-display-null'
  -nomixer              disable modification of mixer settings
  -nosound              equivalent to '-vm-sound-null'
  -quartz               equivalent to '-vm-display-Quartz'


 */

typedef struct VMParameters_
{
	/**
	 * The image file name.
	 * This string is owned by the \ref VMParameters structure, so it should be assigned by using strdup.
	 */
	char* imageFileName;

	/// Is this image a default image
	bool isDefaultImage;

	/// Has the default image been found?
	bool defaultImageFound;

	/// Is this an interactive session?
	bool isInteractiveSession;

	/// Does the VM run in a worker?
	bool isWorker;

	//The number of smalltalk frames to print in a process dump, (0 to print all).
	int maxStackFramesToPrint;

	//The max size of the old space (as the new space is fixed size, we can take it as a hint of the memory size used by the VM).
	long long maxOldSpaceSize;

	//The max size of the code space (This is the space used to compile JIT methods and trampolines).
	long long maxCodeSize;
  
	//The eden size (This is the space used to allocate new objects).
	long long edenSize;

	//The minimal Permanent Space Size
	long long minPermSpaceSize;

	// FIXME: Why passing this is needed when we have the separated vectors?
	int processArgc;
	const char** processArgv;

	// FIXME: Passing this environment vector seems hackish. getenv should be used instead.
	const char** environmentVector;

	VMParameterVector vmParameters;
	VMParameterVector imageParameters;
} VMParameters;

/**
 * Parse an argument vector into a VM parameter holding structure.
 * \param parsedParameters the resulting parsed parameters.
 */
EXPORT(VMErrorCode) vm_parameters_parse(int argc, const char** argv, VMParameters *parsedParameters);

/**
 * This ensures that the interactive parameter is passed to the image when required.
 */
EXPORT(VMErrorCode) vm_parameters_ensure_interactive_image_parameter(VMParameters* parameters);

/**
 * Destroy an allocated instance \ref VMParameters.
 */
EXPORT(VMErrorCode) vm_parameters_destroy(VMParameters *parameters);

/**
 * Initialize the values of an instance of VMParameters
 */

EXPORT(VMErrorCode) vm_parameters_init(VMParameters *parameters);

/**
 * Prints the command line parameter usage string to a file.
 */
EXPORT(void) vm_printUsageTo(FILE *output);

#ifdef __APPLE__

EXPORT(void) fillParametersFromPList(VMParameters* parameters);

#endif


#ifdef __cplusplus
}
#endif

#endif //PHAROVM_PARAMETERS_H
