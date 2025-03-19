#import <Foundation/Foundation.h>
#include "pharovm/pharo.h"
#include "pharovm/parameters/parameters.h"
#include "pharovm/parameters/parameterVector.h"
#include "pharovm/debug.h"
#include "pharovm/pathUtilities.h"

#include <sys/stat.h>

static bool
fileExists(char *filename) {

  struct stat  buffer;  
  return (stat (filename, &buffer) == 0);
}

EXPORT(void) fillParametersFromPList(VMParameters* parameters){

	char			fileNameBuffer[FILENAME_MAX + 1];
	char			mainBundlePath[FILENAME_MAX + 1];
	CFBundleRef  	mainBundle;

	CFNumberRef 	logLevelRef;
	int32_t			logLevelValue;
	CFStringRef		imageFileName;
	CFBooleanRef	headlessRef;
	CFBooleanRef	workerRef;	
	CFNumberRef		maxFramesToLogRef;
	CFNumberRef		maxOldSpaceSizeRef;
	CFNumberRef		edenSizeRef;
	CFNumberRef		codeSizeRef;
	CFArrayRef		argumentsRef;


	mainBundle = CFBundleGetMainBundle();

	CFStringGetCString((CFStringRef)[[NSBundle mainBundle] bundlePath], mainBundlePath, FILENAME_MAX + 1, kCFStringEncodingUTF8);

	logLevelRef = CFBundleGetValueForInfoDictionaryKey(mainBundle, CFSTR("PharoLogLevel"));

	if(logLevelRef != NULL){
		CFNumberGetValue(logLevelRef, kCFNumberSInt32Type, &logLevelValue);
		logLevel(logLevelValue);
	}

	imageFileName = CFBundleGetValueForInfoDictionaryKey(mainBundle, CFSTR("PharoImageFile"));

	if(imageFileName != NULL){
		CFStringGetCString(imageFileName, fileNameBuffer, FILENAME_MAX + 1, kCFStringEncodingUTF8);
		parameters->imageFileName = strdup(fileNameBuffer);
		parameters->isDefaultImage = false;
		parameters->isInteractiveSession = true;
		parameters->defaultImageFound = true;

		//Check if the path passed exists, if not exists try with a location inside the main bundle.

		if(fileExists(parameters->imageFileName)){
			parameters->defaultImageFound = true;
		}else{
			snprintf(fileNameBuffer, FILENAME_MAX + 1, "%s/Contents/Resources/%s", mainBundlePath, parameters->imageFileName);
			if(fileExists(fileNameBuffer)){
				free(parameters->imageFileName);
				parameters->imageFileName = strdup(fileNameBuffer);
				parameters->defaultImageFound = true;				
			}else{
				snprintf(fileNameBuffer, FILENAME_MAX + 1, "%s/Contents/MacOS/Resources/%s", mainBundlePath, parameters->imageFileName);
				if(fileExists(fileNameBuffer)){
					free(parameters->imageFileName);
					parameters->imageFileName = strdup(fileNameBuffer);
					parameters->defaultImageFound = true;				
				}
			}
		}
		
		logDebug("Using Image File from PList: %s", parameters->imageFileName); 
	}

	headlessRef = CFBundleGetValueForInfoDictionaryKey(mainBundle, CFSTR("PharoHeadless"));	
	if(headlessRef != NULL){
		parameters->isInteractiveSession = !CFBooleanGetValue(headlessRef);
	}
	
	workerRef = CFBundleGetValueForInfoDictionaryKey(mainBundle, CFSTR("PharoWorker"));	
	if(workerRef != NULL){
		parameters->isWorker = !CFBooleanGetValue(workerRef);
	}

	maxFramesToLogRef = CFBundleGetValueForInfoDictionaryKey(mainBundle, CFSTR("PharoMaxFramesToLog"));

	if(maxFramesToLogRef != NULL){
		CFNumberGetValue(maxFramesToLogRef, kCFNumberSInt32Type, &parameters->maxStackFramesToPrint);
	}

	maxOldSpaceSizeRef = CFBundleGetValueForInfoDictionaryKey(mainBundle, CFSTR("PharoMaxOldSpaceSize"));

	if(maxOldSpaceSizeRef != NULL){
		CFNumberGetValue(maxOldSpaceSizeRef, kCFNumberSInt64Type, &parameters->maxOldSpaceSize);
	}

	edenSizeRef = CFBundleGetValueForInfoDictionaryKey(mainBundle, CFSTR("PharoEdenSize"));

	if(edenSizeRef != NULL){
		CFNumberGetValue(edenSizeRef, kCFNumberSInt64Type, &parameters->edenSize);
	}

	codeSizeRef = CFBundleGetValueForInfoDictionaryKey(mainBundle, CFSTR("PharoCodeSize"));

	if(codeSizeRef != NULL){
		CFNumberGetValue(codeSizeRef, kCFNumberSInt64Type, &parameters->maxCodeSize);
	}


	argumentsRef = CFBundleGetValueForInfoDictionaryKey(mainBundle, CFSTR("PharoImageParameters"));

	if(argumentsRef != NULL){
		CFIndex count = CFArrayGetCount(argumentsRef);

		for(CFIndex i=0; i < count; i++){
			CFStringRef value = CFArrayGetValueAtIndex(argumentsRef, i);

			if(value != NULL){
				char* valueString = calloc(1, 255+1);
				
				CFStringGetCString(value, valueString, 255 + 1, kCFStringEncodingUTF8);
				vm_parameter_vector_insert_from(&parameters->imageParameters, 1, (const char**) &valueString);
			}
			
		}
	}

}
