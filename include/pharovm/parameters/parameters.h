#ifndef PHAROVM_PARAMETERS_H
#define PHAROVM_PARAMETERS_H

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include "pharovm/parameters/parameterVector.h"
#include <stdio.h>


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

    // The amount of bytes used for a stack page
    int stackPageSize;

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

	// When pinning young objects, the objects are clonned into the old space.
	// Trying to allocate it in a segment with already pinned objects
	// Does the clonning process avoid this search and allocate the clonned object anywhere?
	// DEFAULT: false
	bool avoidSearchingSegmentsWithPinnedObjects;

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
