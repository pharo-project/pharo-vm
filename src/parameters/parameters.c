#include "pharovm/pharo.h"
#include "pharovm/parameters/parameters.h"
#include "pharovm/debug.h"
#include "pharovm/pathUtilities.h"
#include <assert.h>

typedef VMErrorCode (*vm_parameter_process_function)(const char *argument, VMParameters* params);

typedef struct VMParameterSpec_
{
	const char *name;
	bool hasArgument;
	vm_parameter_process_function function;
} VMParameterSpec;

/*
* Parse a text in the form [anInteger]k|K|m|M|g|G
* Return the number of bytes represented by the text.
* Return VM_ERROR_INVALID_PARAMETER_VALUE in case of error
*  (the text is not prefixed by a number or it is negative number)
*
* E.g., 2M => 2 * 1024 * 1024
*/
long long parseByteSize(const char* text){
	long long intValue = 0;
	int multiplier = 1;
	int argumentLength = 0;
	char* argument = alloca(255);

	strncpy(argument, text, 255);
	argument[254] = 0;

	if(strlen(argument) > 0){
		argumentLength = strlen(argument);
		char lastCharacter = argument[argumentLength - 1];

		switch(lastCharacter){
			case 'k':
			case 'K':
				multiplier = 1024;
				argument[argumentLength - 1] = '\0';
				break;
			case 'm':
			case 'M':
				multiplier = 1024 * 1024;
				argument[argumentLength - 1] = '\0';
				break;
			case 'g':
			case 'G':
				multiplier = 1024 * 1024 * 1024;
				argument[argumentLength - 1] = '\0';
				break;
			default:
				break;
		}
	}

	errno = 0;
	intValue = strtoll(argument, NULL, 10);

	if(errno != 0 || intValue < 0)
	{
		return VM_ERROR_INVALID_PARAMETER_VALUE;
	}

	return intValue * multiplier;
}

void vm_printUsageTo(FILE *out);
static VMErrorCode processHelpOption(const char *argument, VMParameters * params);
static VMErrorCode processPrintVersionOption(const char *argument, VMParameters * params);
static VMErrorCode processLogLevelOption(const char *argument, VMParameters * params);
static VMErrorCode processMaxFramesToPrintOption(const char *argument, VMParameters * params);
static VMErrorCode processMaxOldSpaceSizeOption(const char *argument, VMParameters * params);
static VMErrorCode processMaxCodeSpaceSizeOption(const char *argument, VMParameters * params);
static VMErrorCode processEdenSizeOption(const char *argument, VMParameters * params);
static VMErrorCode processWorkerOption(const char *argument, VMParameters * params);
static VMErrorCode processMinPermSpaceSizeOption(const char *argument, VMParameters * params);

static const VMParameterSpec vm_parameters_spec[] =
{
  {.name = "headless", .hasArgument = false, .function = NULL},
#ifdef PHARO_VM_IN_WORKER_THREAD
  {.name = "worker", .hasArgument = false, .function = processWorkerOption},
#endif
  {.name = "interactive", .hasArgument = false, .function = NULL}, // For pharo-ui scripts.
  {.name = "vm-display-null", .hasArgument = false, .function = NULL}, // For Smalltalk CI.
  {.name = "help", .hasArgument = false, .function = processHelpOption},
  {.name = "h", .hasArgument = false, .function = processHelpOption},
  {.name = "version", .hasArgument = false, .function = processPrintVersionOption},
  {.name = "logLevel", .hasArgument = true, .function = processLogLevelOption},
  {.name = "maxFramesToLog", .hasArgument = true, .function = processMaxFramesToPrintOption},
  {.name = "maxOldSpaceSize", .hasArgument = true, .function = processMaxOldSpaceSizeOption},
  {.name = "codeSize", .hasArgument = true, .function = processMaxCodeSpaceSizeOption},
  {.name = "edenSize", .hasArgument = true, .function = processEdenSizeOption},
  {.name = "minPermSpaceSize", .hasArgument = true, .function = processMinPermSpaceSizeOption},
#ifdef __APPLE__
  // This parameter is passed by the XCode debugger.
  {.name = "NSDocumentRevisionsDebugMode", .hasArgument = false, .function = NULL},
#endif
};

// TODO: Turn this array size computation into a macro.
static const size_t vm_parameters_spec_size = sizeof(vm_parameters_spec) / sizeof(vm_parameters_spec[0]);

/**
 * Folder search suffixes for finding images.
 */
static const char * const vm_image_search_suffixes[] = {
	DEFAULT_IMAGE_NAME,

#ifdef __APPLE__
	"../Resources/" DEFAULT_IMAGE_NAME,
	"../../../" DEFAULT_IMAGE_NAME,
#endif
};

static const size_t vm_image_search_suffixes_count = sizeof(vm_image_search_suffixes) / sizeof(vm_image_search_suffixes[0]);

static const VMParameterSpec*
findParameterWithName(const char *argumentName, size_t argumentNameSize)
{
	for(size_t i = 0; i < vm_parameters_spec_size; ++i) {
		const VMParameterSpec *paramSpec = &vm_parameters_spec[i];
		if(strlen(paramSpec->name) == argumentNameSize &&
		   strncmp(paramSpec->name, argumentName, argumentNameSize) == 0) {
	        return paramSpec;
		}
	}
	return NULL;
}

static int
findParameterArity(const char *parameter)
{
	if(*parameter != '-') return 0;

	// Ignore the preceding hyphens
	++parameter;
	if(*parameter == '-')
	{
		++parameter;
	}

	// Does the parameter have an equal (=)?
	if(strchr(parameter, '=') != NULL) return 0;

	// Find the parameter spec.
	const VMParameterSpec* spec = findParameterWithName(parameter, strlen(parameter));
	if(!spec) return 0;

	return spec->hasArgument ? 1 : 0;
}


// FIXME: This should be provided by the client.
static int
isInConsole()
{
#ifdef _WIN32
	return GetStdHandle(STD_INPUT_HANDLE) != NULL;
#else
	return false;
#endif
}

VMErrorCode
vm_parameters_destroy(VMParameters *parameters)
{
	if(!parameters) return VM_ERROR_NULL_POINTER;

	free(parameters->imageFileName);
	vm_parameter_vector_destroy(&parameters->vmParameters);
	vm_parameter_vector_destroy(&parameters->imageParameters);
	memset(parameters, 0, sizeof(VMParameters));
	return VM_SUCCESS;
}

VMErrorCode
vm_find_startup_image(const char *vmExecutablePath, VMParameters *parameters)
{
    char *imagePathBuffer = (char*)calloc(1, FILENAME_MAX+1);
    char *vmPathBuffer = (char*)calloc(1, FILENAME_MAX+1);
    char *searchPathBuffer = (char*)calloc(1, FILENAME_MAX+1);

	if(!imagePathBuffer || !vmPathBuffer || !searchPathBuffer)
	{
		free(imagePathBuffer);
		free(vmPathBuffer);
		free(searchPathBuffer);
		return VM_ERROR_OUT_OF_MEMORY;
	}

	// Find the VM absolute directory.
	vm_path_make_absolute_into(searchPathBuffer, FILENAME_MAX+1, vmExecutablePath);
    if(sqImageFileExists(searchPathBuffer))
	{
		vm_path_extract_dirname_into(vmPathBuffer, FILENAME_MAX+1, searchPathBuffer);
	}
    else
	{
        strncpy(vmPathBuffer, vmExecutablePath, FILENAME_MAX);
		vmPathBuffer[FILENAME_MAX] = 0;
	}

	// Find the image in the different search directory suffixes.
	for(size_t i = 0; i < vm_image_search_suffixes_count; ++i)
	{
		const char *searchSuffix = vm_image_search_suffixes[i];
		vm_path_join_into(imagePathBuffer, FILENAME_MAX+1, vmPathBuffer, searchSuffix);
	    if(sqImageFileExists(imagePathBuffer))
		{
			parameters->imageFileName = imagePathBuffer;
			parameters->isDefaultImage = true;
			parameters->defaultImageFound = true;
	        free(vmPathBuffer);
	        free(searchPathBuffer);
	        return VM_SUCCESS;
		}
	}

	// Find the image in the current work directory.
	vm_path_get_current_working_dir_into(searchPathBuffer, FILENAME_MAX+1);
	vm_path_join_into(imagePathBuffer, FILENAME_MAX+1, searchPathBuffer, DEFAULT_IMAGE_NAME);
	free(vmPathBuffer);
	free(searchPathBuffer);
	if(sqImageFileExists(imagePathBuffer))
	{
		parameters->imageFileName = imagePathBuffer;
		parameters->isDefaultImage = true;
		parameters->defaultImageFound = true;
		return VM_SUCCESS;
	}

	free(imagePathBuffer);
	parameters->imageFileName = strdup(DEFAULT_IMAGE_NAME);
	parameters->isDefaultImage = true;
	parameters->defaultImageFound = false;
	return VM_SUCCESS;
}

static int
findImageNameIndex(int argc, const char** argv)
{
	//The first parameters is the executable name
	for(int i=1; i < argc; i ++)
	{
		const char *argument = argv[i];

		// Is this a mark for where the image parameters begins?
		if(strcmp(argument, "--") == 0)
		{
			return i;
		}

		// Is this an option?
		if(*argv[i] == '-') {
			i += findParameterArity(argument);
			continue;
		}

		// This must be the first non vmoption argument, so this must be the image.
		return i;
	}

	// I could not find it.
	return argc;
}

static VMErrorCode
fillUpImageName(int argc, const char** argv, VMParameters* parameters){
	
	VMErrorCode error;
		
	int imageNameIndex = findImageNameIndex(argc, argv);

	// We get the image file name
	if(imageNameIndex != argc && strcmp("--", argv[imageNameIndex]) != 0) {
		parameters->imageFileName = strdup(argv[imageNameIndex]);
		parameters->isDefaultImage = false;
		parameters->isInteractiveSession = false;		
	}

	return VM_SUCCESS;
}

static VMErrorCode
splitVMAndImageParameters(int argc, const char** argv, VMParameters* parameters)
{
	VMErrorCode error;
	int imageNameIndex = findImageNameIndex(argc, argv);
	int numberOfVMParameters = imageNameIndex;
	int numberOfImageParameters = argc - imageNameIndex - 1;

	//If we still have an empty image file, we try the default
	if(parameters->imageFileName == NULL){
		error = vm_find_startup_image(argv[0], parameters);
		if(error) return error;
		
		// Is this an interactive environment?
		parameters->isInteractiveSession = !isInConsole() && parameters->isDefaultImage;		
	}

	if(numberOfImageParameters < 0)
		numberOfImageParameters = 0;

	// Copy image parameters.
	error = vm_parameter_vector_insert_from(&parameters->imageParameters, numberOfImageParameters, &argv[imageNameIndex + 1]);
	if(error)
	{
		vm_parameters_destroy(parameters);
		return error;
	}

	// Copy the VM parameters.
	error = vm_parameter_vector_insert_from(&parameters->vmParameters, numberOfVMParameters, argv);
	if(error)
	{
		vm_parameters_destroy(parameters);
		return error;
	}

#if !ALWAYS_INTERACTIVE
	// Add additional VM parameters.
	const char *extraVMParameters = "--headless";
	error = vm_parameter_vector_insert_from(&parameters->vmParameters, 1, &extraVMParameters);
	if(error)
	{
		vm_parameters_destroy(parameters);
		return error;
	}
#endif

	return VM_SUCCESS;
}

static void
logParameterVector(const char* vectorName, const VMParameterVector *vector)
{
	logDebug("%s [count = %u]:", vectorName, vector->count);
	for(size_t i = 0; i < vector->count; ++i)
	{
		logDebug(" %s", vector->parameters[i]);
	}
}

static void
logParameters(const VMParameters* parameters)
{
	logDebug("Image file name: %s", parameters->imageFileName);
	logDebug("Is default Image: %s", parameters->isDefaultImage ? "yes" : "no");
	logDebug("Is interactive session: %s", parameters->isInteractiveSession ? "yes" : "no");

	logParameterVector("vmParameters", &parameters->vmParameters);
	logParameterVector("imageParameters", &parameters->imageParameters);
}

VMErrorCode
vm_parameters_ensure_interactive_image_parameter(VMParameters* parameters)
{
	VMErrorCode error;
	const char* interactiveParameter = "--interactive";

	if (parameters->isInteractiveSession)
	{
		if (!vm_parameter_vector_has_element(&parameters->imageParameters, "--interactive"))
		{
			error = vm_parameter_vector_insert_from(&parameters->imageParameters, 1, &interactiveParameter);
			if (error)
				return error;

		}
	}

#if ALWAYS_INTERACTIVE

	const char* headlessParameter = "--headless";

	/*
	 * If the macro ALWAYS_INTERACTIVE is set, we invert the logic of headless / interactive
	 * This is to mimic the old VM behavior
	 */

	if (!vm_parameter_vector_has_element(&parameters->vmParameters, "--headless") &&
			!vm_parameter_vector_has_element(&parameters->imageParameters, "--interactive")){

		error = vm_parameter_vector_insert_from(&parameters->imageParameters, 1, &interactiveParameter);

		if (error)
			return error;
	}

	/* Ensure we have headless parameter when in interactive mode (the image is expecting it)*/

	if (!vm_parameter_vector_has_element(&parameters->vmParameters, "--headless") &&
			vm_parameter_vector_has_element(&parameters->imageParameters, "--interactive")) {

		error = vm_parameter_vector_insert_from(&parameters->vmParameters, 1, &headlessParameter);

		if (error)
			return error;
	}

#endif

	return VM_SUCCESS;
}

void
vm_printUsageTo(FILE *out)
{
	fprintf(out,
"Usage: " VM_NAME " [<option>...] [<imageName> [<argument>...]]\n"
"       " VM_NAME " [<option>...] -- [<argument>...]\n"
"\n"
"Common <option>s:\n"
"  --help                               Print this help message, then exit\n"
#if ALWAYS_INTERACTIVE
"  --headless                           Run in headless (no window) mode (default: false)\n"
#else
"  --headless                           Run in headless (no window) mode (default: true)\n"
#endif
#ifdef PHARO_VM_IN_WORKER_THREAD
"  --worker                             Run in worker thread (default: false)\n"
#endif
"  --logLevel=<level>                   Sets the log level number (ERROR(1), WARN(2), INFO(3), DEBUG(4), TRACE(5))\n"
"  --version                            Print version information, then exit\n"
"  --maxFramesToLog=<cant>              Sets the max numbers of Smalltalk frames to log\n"
"  --maxOldSpaceSize=<bytes>            Sets the max size of the old space. As the other\n"
"                                       spaces are fixed (or calculated from this) with\n"
"                                       this parameter is possible to set the total size.\n"
"                                       It is possible to use k(kB), M(MB) and G(GB).\n"
"  --codeSize=<size>[mk]                Sets the max size of code zone.\n"
"                                       It is possible to use k(kB), M(MB) and G(GB).\n"
"  --edenSize=<size>[mk]                Sets the size of eden\n"
"                                       It is possible to use k(kB), M(MB) and G(GB).\n"
"  --minPermSpaceSize=<size>[mk]        Sets the size of eden\n"
"                                       It is possible to use k(kB), M(MB) and G(GB).\n"
"\n"
"Notes:\n"
"\n"
"  <imageName> defaults to `Pharo.image'.\n"
"  <argument>s are ignored, but are processed by the Pharo image.\n"
"  Precede <arguments> by `--' to use default image.\n");
}

static VMErrorCode
processLogLevelOption(const char* value, VMParameters * params)
{
	int intValue = 0;

	intValue = strtol(value, NULL, 10);

	if(intValue == 0)
	{
		logError("Invalid option for logLevel: %s\n", value);
		vm_printUsageTo(stderr);
		return VM_ERROR_INVALID_PARAMETER_VALUE;
	}

	logLevel(intValue);
	return VM_SUCCESS;
}

static VMErrorCode
processMaxFramesToPrintOption(const char* value, VMParameters * params)
{
	int intValue = 0;

	intValue = strtol(value, NULL, 10);

	if(intValue < 0)
	{
		logError("Invalid option for maxFramesToLog: %s\n", value);
		vm_printUsageTo(stderr);
		return VM_ERROR_INVALID_PARAMETER_VALUE;
	}

	params->maxStackFramesToPrint = intValue;

	return VM_SUCCESS;
}

static VMErrorCode
processMaxOldSpaceSizeOption(const char* originalArgument, VMParameters * params)
{
	long long intValue = parseByteSize(originalArgument);

	if(intValue < 0)
	{
		logError("Invalid option for maxOldSpaceSize: %s\n", originalArgument);
		vm_printUsageTo(stderr);
		return VM_ERROR_INVALID_PARAMETER_VALUE;
	}
	
	params->maxOldSpaceSize = intValue ;

	return VM_SUCCESS;
}

static VMErrorCode
processMaxCodeSpaceSizeOption(const char* originalArgument, VMParameters * params)
{
	long long intValue = parseByteSize(originalArgument);

	if(intValue < 0)
	{
		logError("Invalid option for codeSize: %s\n", originalArgument);
		vm_printUsageTo(stderr);
		return VM_ERROR_INVALID_PARAMETER_VALUE;
	}

	params->maxCodeSize = intValue;

	return VM_SUCCESS;
}

static VMErrorCode
processMinPermSpaceSizeOption(const char* originalArgument, VMParameters * params)
{
	long long intValue = parseByteSize(originalArgument);

	if(intValue < 0)
	{
		logError("Invalid option for min perm space size: %s\n", originalArgument);
		vm_printUsageTo(stderr);
		return VM_ERROR_INVALID_PARAMETER_VALUE;
	}

	params->minPermSpaceSize = intValue;

	return VM_SUCCESS;
}

static VMErrorCode
processEdenSizeOption(const char* originalArgument, VMParameters * params)
{
	long long intValue = parseByteSize(originalArgument);

	if(intValue < 0)
	{
		logError("Invalid option for eden: %s\n", originalArgument);
		vm_printUsageTo(stderr);
		return VM_ERROR_INVALID_PARAMETER_VALUE;
	}

	params->edenSize = intValue;

	return VM_SUCCESS;
}

static VMErrorCode
processWorkerOption(const char* argument, VMParameters * params)
{
	params->isWorker = true;
	return VM_SUCCESS;
}

static VMErrorCode
processHelpOption(const char* argument, VMParameters * params)
{
	(void)argument;
	vm_printUsageTo(stdout);
	return VM_ERROR_EXIT_WITH_SUCCESS;
}

static VMErrorCode
processPrintVersionOption(const char* argument, VMParameters * params)
{
	(void)argument;
	printf("%s\n", getVMVersion());
	printf("Built from: %s\n", getSourceVersion());
	return VM_ERROR_EXIT_WITH_SUCCESS;
}

static VMErrorCode
processVMOptions(VMParameters* parameters)
{
	VMParameterVector *vector = &parameters->vmParameters;
	for(size_t i = 1; i < vector->count; ++i)
	{
		const char *param = vector->parameters[i];
		if(!param)
		{
			break;
		}

		// We only care about specific parameters here.
		if(*param != '-')
		{
			continue;
		}

#ifdef __APPLE__
		// Ignore the process serial number special argument passed to OS X applications.
		if(strncmp(param, "-psn_", 5) == 0)
		{
			continue;
		}
#endif

		// Ignore the leading dashes (--)
		const char *argumentName = param + 1;
		if(*argumentName == '-')
		{
			++argumentName;
		}

		// Find the argument value.
		const char *argumentValue = strchr(argumentName, '=');
		size_t argumentNameSize = strlen(argumentName);
		if(argumentValue != NULL)
		{
			argumentNameSize = argumentValue - argumentName;
			++argumentValue;
		}

		// Find a matching parameter
		const VMParameterSpec *paramSpec = findParameterWithName(argumentName, argumentNameSize);
		if(!paramSpec)
		{
			logError("Invalid or unknown VM parameter %s\n", param);
			vm_printUsageTo(stderr);
			return VM_ERROR_INVALID_PARAMETER;
		}

		// If the parameter has a required argument, it may be passed as the next parameter in the vector.
		if(paramSpec->hasArgument)
		{
			// Try to fetch the argument from additional means
			if(argumentValue == NULL)
			{
				if(i + 1 < vector->count)
				{
					argumentValue = vector->parameters[++i];
				}
			}

			// Make sure the argument value is present.
			if(argumentValue == NULL)
			{
				logError("VM parameter %s requires a value\n", param);
				vm_printUsageTo(stderr);
				return VM_ERROR_INVALID_PARAMETER_VALUE;
			}
		}

		// Invoke the VM parameter processing function.
		if(paramSpec->function)
		{
			VMErrorCode error = paramSpec->function(argumentValue, parameters);
			if(error) return error;
		}
	}

	return VM_SUCCESS;
}

EXPORT(VMErrorCode)
vm_parameters_parse(int argc, const char** argv, VMParameters* parameters)
{
	char* fullPath;

#ifdef __APPLE__
	//If it is OSX I read parameters from the PList
	fillParametersFromPList(parameters);
#endif

	//We read the arguments from the command line, and override whatever is set before
	VMErrorCode error = fillUpImageName(argc, argv, parameters);
	if(error) return error;	

	// Split the argument vector in two separate vectors (If there is no Image, it gives a default one).
	error = splitVMAndImageParameters(argc, argv, parameters);
	if(error) return error;

	// I get the VM location from the argv[0]
	char *fullPathBuffer = (char*)calloc(1, FILENAME_MAX);
	if(!fullPathBuffer)
	{
		vm_parameters_destroy(parameters);
		return VM_ERROR_OUT_OF_MEMORY;
	}

#if _WIN32
	WCHAR pathString[MAX_PATH];
	char encodedPath[MAX_PATH];
	GetModuleFileNameW(NULL, pathString, MAX_PATH);
	WideCharToMultiByte(CP_UTF8, 0, pathString, -1, encodedPath, FILENAME_MAX, NULL, 0);
	fullPath = getFullPath(encodedPath, fullPathBuffer, FILENAME_MAX);
#else
	fullPath = getFullPath(argv[0], fullPathBuffer, FILENAME_MAX);
#endif
	setVMPath(fullPath);
	free(fullPathBuffer);

	error = processVMOptions(parameters);
	if(error)
	{
		vm_parameters_destroy(parameters);
		return error;
	}

	logParameters(parameters);

	return VM_SUCCESS;
}

EXPORT(VMErrorCode)
vm_parameters_init(VMParameters *parameters){

	parameters->vmParameters.count = 0;
	parameters->vmParameters.parameters = NULL;
	parameters->imageParameters.count = 0;
	parameters->imageParameters.parameters = NULL;

	parameters->maxStackFramesToPrint = 0;
	parameters->maxCodeSize = 0;
	parameters->maxOldSpaceSize = 0;
	parameters->edenSize = 0;
	parameters->minPermSpaceSize = 0;
	parameters->imageFileName = NULL;
	parameters->isDefaultImage = false;
	parameters->defaultImageFound = false;
	parameters->isInteractiveSession = false;

	parameters->isWorker = false;

	return VM_SUCCESS;
}
