#include "pharoClient.h"
#include "fileDialog.h"
#include "pathUtilities.h"

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

static char vmDirectory[FILENAME_MAX+1];
static char foundImageName[FILENAME_MAX+1];

static bool
findImageFileInVMDirectory(VMParameters *parameters)
{
    vm_path_extract_dirname_into(vmDirectory, sizeof(vmDirectory), parameters->processArgv[0]);

    size_t foundImageCount = vm_path_find_files_with_extension_in_folder(vmDirectory, ".image", foundImageName, sizeof(foundImageName));
    if(foundImageCount == 1)
    {
        parameters->imageFileName = _strdup(foundImageName);
        parameters->defaultImageFound = true;
        return true;
    }

    return false;
}

static int
gtoolkit_main(int argc, const char **argv, const char **envp)
{
    VMParameters parameters = {};
	parameters.processArgc = argc;
	parameters.processArgv = argv;
	parameters.environmentVector = envp;

	// Did we succeed on parsing the parameters?
	VMErrorCode error = vm_parameters_parse(argc, argv, &parameters);
	if(error)
	{
		if(error == VM_ERROR_EXIT_WITH_SUCCESS) return 0;
		return 1;
	}

    // Do we need to select an image file interactively?
	if(parameters.isInteractiveSession && parameters.isDefaultImage)
	{
        if(!findImageFileInVMDirectory(&parameters))
        {
            VMFileDialog fileDialog = {};
    		fileDialog.title = "Select GToolkit Image to Open";
    		fileDialog.message = "Choose an image file to execute";
    		fileDialog.filterDescription = "GToolkit Images (*.image)";
    		fileDialog.filterExtension = ".image";
    		fileDialog.defaultFileNameAndPath = DEFAULT_IMAGE_NAME;

    		error = vm_file_dialog_run_modal_open(&fileDialog);
    		if(!fileDialog.succeeded)
    		{
    			vm_file_dialog_destroy(&fileDialog);
    			return 0;
    		}

    		parameters.imageFileName = _strdup(fileDialog.selectedFileName);
    		parameters.isDefaultImage = false;
    		vm_file_dialog_destroy(&fileDialog);
        }
	}

	int exitCode = vm_main_with_parameters(&parameters);
	vm_parameters_destroy(&parameters);
	return exitCode;
}

int CALLBACK
WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    return gtoolkit_main(__argc, (const char **)__argv, (const char**)environ);
}
