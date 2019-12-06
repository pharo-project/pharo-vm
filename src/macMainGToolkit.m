#include "pharoClient.h"
#include "fileDialog.h"
#include "pathUtilities.h"

#undef null
#include <string.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include <mach-o/dyld.h> // For _NSGetExecutablePath

static char vmExecutableDirectory[FILENAME_MAX+1];
static char vmResourcesDirectory[FILENAME_MAX+1];
static char vmBundleDirectory[FILENAME_MAX+1];
static char foundImageName[FILENAME_MAX+1];
static char defaultOpenFileName[FILENAME_MAX+1];

static bool
findImageFileInVMDirectory(VMParameters *parameters)
{
    vm_path_extract_dirname_into(vmExecutableDirectory, sizeof(vmExecutableDirectory), parameters->processArgv[0]);
    vm_path_join_into(vmResourcesDirectory, sizeof(vmResourcesDirectory), vmExecutableDirectory, "../Resources/");
    vm_path_join_into(vmBundleDirectory, sizeof(vmBundleDirectory), vmExecutableDirectory, "../../../");
    
    int searchDirectoryCount = 3;
    const char *searchDirectories[3] = {
        vmExecutableDirectory,
        vmResourcesDirectory,
        vmBundleDirectory,
    };
    
    size_t foundImageCount = 0;
    for(int i = 0; i < searchDirectoryCount; ++i)
    {
        foundImageCount += vm_path_find_files_with_extension_in_folder(searchDirectories[i], ".image", foundImageName, sizeof(foundImageName));
    }
    
    if(foundImageCount == 1)
    {
        parameters->imageFileName = strdup(foundImageName);
        parameters->defaultImageFound = true;
        return true;
    }
    
    parameters->defaultImageFound = false;
    return false;
}

@interface GToolkitLaunchApplication : NSApplication
@end

@interface GToolkitLaunchAppDelegate : NSObject<NSApplicationDelegate> {
    NSMutableArray *filesToOpen;
    VMParameters *parsedParameters;
}
@property VMParameters *parsedParameters;
@end

static GToolkitLaunchAppDelegate *launchAppDelegate = nil;

@implementation GToolkitLaunchApplication
@end

@implementation GToolkitLaunchAppDelegate
@synthesize parsedParameters;

- (id) init
{
    self = [super init];
    filesToOpen = [NSMutableArray new];
    return self;
}

- (void) applicationDidFinishLaunching: (NSNotification *)notification
{
    // Execute the VM process if We already have a list of files to open.
    if([filesToOpen count] > 0)
        return [self executeVMProcess];
        
    // Do we have a default image to execute?
    if(parsedParameters->defaultImageFound)
    {
        [filesToOpen addObject: [NSString stringWithUTF8String: parsedParameters->imageFileName]];
        return [self executeVMProcess];
    }

    vm_path_join_into(defaultOpenFileName, sizeof(defaultOpenFileName), vmExecutableDirectory, "../../../" DEFAULT_IMAGE_NAME);

    VMFileDialog fileDialog = {};
    fileDialog.title = "Select GToolkit Image to Open";
    fileDialog.message = "Choose an image file to execute";
    fileDialog.filterDescription = "GToolkit Images (*.image)";
    fileDialog.filterExtension = ".image";
    fileDialog.defaultFileNameAndPath = defaultOpenFileName;

    VMErrorCode error = vm_file_dialog_run_modal_open(&fileDialog);
    if(!fileDialog.succeeded)
    {
        vm_file_dialog_destroy(&fileDialog);
        [NSApp terminate: nil];
        return;
    }

    [filesToOpen addObject: [NSString stringWithUTF8String: fileDialog.selectedFileName]];
    vm_file_dialog_destroy(&fileDialog);
    
    [self executeVMProcess];
}

- (BOOL) application: (NSApplication*) theApplication openFile: (NSString *)filename
{
    [filesToOpen addObject: filename];
    return YES;
}

- (void) executeVMProcess
{
    char *path = (char*)calloc(1, FILENAME_MAX + 1);
    if(!path)
    {
        NSLog(@"Out of memory. Aborting.\n");
        abort();
    }

    uint32_t size = FILENAME_MAX;
    if(_NSGetExecutablePath(path, &size))
    {
        NSLog(@"VM executable path name is too long. Aborting.\n");
        abort();
    }

    NSArray *processCommandLineArguments = [[NSProcessInfo processInfo] arguments];
    NSMutableArray *newVMProcessCommandLineArguments = [NSMutableArray new];

    [newVMProcessCommandLineArguments addObjectsFromArray: processCommandLineArguments];
    [newVMProcessCommandLineArguments addObjectsFromArray: filesToOpen];
    [newVMProcessCommandLineArguments addObject: @"--interactive"];

    char **vmArgv = calloc([newVMProcessCommandLineArguments count] + 1, sizeof(char *));
    if(!vmArgv) {
        NSLog(@"Out of memory. Aborting.\n");
        abort();
    }

    for(int i = 0; i < [newVMProcessCommandLineArguments count]; ++i) {
        vmArgv[i] = strdup([newVMProcessCommandLineArguments[i] UTF8String]);
        if(!vmArgv[i]) {
            NSLog(@"Out of memory. Aborting.\n");
            abort();
        }
    }

    execv(path, vmArgv);
}
@end

int
launcher_main(VMParameters *parameters, int argc, const char *argv[])
{
    // Create the application.
    NSApplication *application = [GToolkitLaunchApplication sharedApplication];

    // Create the application delegate.
    launchAppDelegate = [[GToolkitLaunchAppDelegate alloc] init];
    launchAppDelegate.parsedParameters = parameters;
    [application setDelegate: launchAppDelegate];

    // Start the main run loop.
    [application performSelectorOnMainThread: @selector(run)
        withObject: nil waitUntilDone: YES];
    return 0;
}

int
main(int argc, const char *argv[], const char *envp[])
{
    // In OS X, the user may want to drop an image file to the VM application.
    // Dropped image files are treated as events, whose reception is only
    // obtained through the usage of an AppDelegate, which is tied to a
    // NSApplication Singleton that cannot be created and destroyed for just
    // receiving this event. In addition to this, the user may want to
    // have an open image dialog. For this reason, we need to detect on
    // whether this program is being executed as a command line Unix tool, or is
    // being executed as an OS X application. We detect this by looking for a
    // -psn_ command line argument. We also look for the presence of the image in
    // the command line. If no image is specified, we run as if we were a
    // launcher application. Once we receive the image drop event, we launch
    // another process but with the image file name passed as a command line
    // argument.
    VMParameters parameters = {};
	parameters.processArgc = argc;
	parameters.processArgv = argv;
	parameters.environmentVector = (const char**)envp;

	// Did we succeed on parsing the parameters?
	VMErrorCode error = vm_parameters_parse(argc, argv, &parameters);
	if(error)
    {
		if(error == VM_ERROR_EXIT_WITH_SUCCESS) return 0;
		return 1;
	}

    // Look for something that looks like an image file.
    bool isImageFilePassedOnTheCommandLine = !parameters.isDefaultImage;
    bool programExecutedAsCommandLineTool = false;

    // Force our mechanism for finding the image.
    if(!isImageFilePassedOnTheCommandLine)
    {
        if(!findImageFileInVMDirectory(&parameters) && programExecutedAsCommandLineTool)
        {
            fprintf(stderr, "Multiple ambiguous default image have been found. Please specify the image to execute explicitly.\n");
            return 1;
        }
    }

    for(int i = 1; i < parameters.vmParameters.count - /* --headless */1; ++i)
    {
        const char *arg = parameters.vmParameters.parameters[i];
        if(*arg == '-')
        {
            // The process serial number indicates that this program is being
            // executed as an OS X application.
            if(!strncmp(arg, "-psn_", 5) || !strcmp(arg, "-NSDocumentRevisionsDebugMode"))
            {
                programExecutedAsCommandLineTool = 0;
            }
            else
            {
                programExecutedAsCommandLineTool = 1;
            }
        }
    }

    // If this is a program executed as a command line tool, or we found the
    // file passed on the command line, then just hand over the execution to the
    // normal VM execution machinery.
    if(programExecutedAsCommandLineTool || isImageFilePassedOnTheCommandLine)
    {
        int exitCode = vm_main_with_parameters(&parameters);
        vm_parameters_destroy(&parameters);
        return exitCode;
    }

    // This program does not know what VM to run, so run as a separate image
    // launcher program.
    return launcher_main(&parameters, argc, argv);
}
