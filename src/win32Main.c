#include "pharovm/pharoClient.h"

#include <windows.h>
#include <shellapi.h>

int CALLBACK
WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	
	char  **argsInUtf8 = NULL;
	LPWSTR *wideArgs;
	int numberOfArgs;
	int totalSize = 0;
	char *currentString;
	int *sizes;
	int i;

	/*
		Converting the arguments from wide char strings to UTF8 strings.
	*/

	wideArgs = CommandLineToArgvW(GetCommandLineW(), &numberOfArgs);
	if( NULL == wideArgs )
	{
		logErrorFromGetLastError("CommandLineToArgvW failed");
		return 0;
	}

	sizes = (int*)malloc(sizeof(int)*numberOfArgs);
   
	for( i=0; i<numberOfArgs; i++){
		sizes[i] = WideCharToMultiByte(CP_UTF8, 0, wideArgs[i], -1, NULL, 0, NULL, FALSE);
		totalSize += sizes[i];
	}

	totalSize += sizeof(char*) * numberOfArgs;
	argsInUtf8 = malloc(totalSize);
	
	currentString = &argsInUtf8[numberOfArgs];
	
	for( i=0; i<numberOfArgs; i++){
		argsInUtf8[i] = currentString;
		WideCharToMultiByte(CP_UTF8, 0, wideArgs[i], -1, currentString, sizes[i], NULL, FALSE);
		currentString = currentString + sizes[i];
	}

	LocalFree(wideArgs);
	free((void*)sizes);

    return vm_main(numberOfArgs, (const char **)argsInUtf8, (const char**)environ);
}
