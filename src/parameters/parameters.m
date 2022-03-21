#import <Foundation/Foundation.h>
#include "pharovm/pharo.h"
#include "pharovm/parameters/parameters.h"
#include "pharovm/debug.h"
#include "pharovm/pathUtilities.h"

EXPORT(void) fillParametersFromPList(VMParameters* parameters){

	char			fileNameBuffer[FILENAME_MAX + 1];
	CFBundleRef  	mainBundle;

	CFNumberRef 	logLevelRef;
	int32_t			logLevelValue;
	CFStringRef		imageFileName;
	

	mainBundle = CFBundleGetMainBundle();

	logLevelRef = CFBundleGetValueForInfoDictionaryKey(mainBundle, CFSTR("PharoLogLevel"));
	imageFileName = CFBundleGetValueForInfoDictionaryKey(mainBundle, CFSTR("PharoImageFile"));

	if(logLevelRef != NULL){
		CFNumberGetValue(logLevelRef, kCFNumberSInt32Type, &logLevelValue);
		logLevel(logLevelValue);
	}

	if(imageFileName != NULL){
		CFStringGetCString(imageFileName, fileNameBuffer, FILENAME_MAX + 1, kCFStringEncodingUTF8);
		parameters->imageFileName = strdup(fileNameBuffer);
		parameters->isDefaultImage = false;
		parameters->defaultImageFound = false;
		parameters->isInteractiveSession = true;
		
		logDebug("Using Image File from PList: %s", fileNameBuffer); 
	}
	
}