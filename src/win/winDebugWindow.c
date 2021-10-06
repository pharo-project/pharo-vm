#include "pharovm/pharo.h"
#include <Windows.h>
#include "pharovm/win/resources.h"

HWND debugWindowHWND;

INT_PTR DebugWindow_WindowProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam){

	switch(msg){
		case WM_SIZE: {
			UINT width = LOWORD(lParam);
			UINT height = HIWORD(lParam);
			logDebug("Resize %d, %d", width, height);
			break;
		}
		case WM_CLOSE: {
			EndDialog(hwnd,0);
			debugWindowHWND = NULL;
			break;
		}
		case WM_COMMAND:{
			switch(LOWORD(wParam)){
				case IDC_CALLSTACK:
					printCallStack();
					break;
				case IDC_ALLSTACKS:
					printAllStacks();
					break;
			}
			break;
		}
		default:
			return FALSE;
	}

	return TRUE;
}

EXPORT(void) openDebugWindow(void* parentHwnd){

	WCHAR windowTitle[255];
	char* logFile[MAX_PATH + 1];
	WCHAR logFileWide[MAX_PATH + 1];

	if(debugWindowHWND != NULL)
		return;

	_snwprintf(windowTitle, 255, TEXT("Pharo Debug %d"), GetCurrentProcessId());

	debugWindowHWND = CreateDialogParamW(
			GetModuleHandle(NULL),
			MAKEINTRESOURCEW(IDD_DEBUG),
			(HWND)parentHwnd,
			DebugWindow_WindowProc,
			0);

	SendMessageW(debugWindowHWND, WM_SETTEXT, (WPARAM) 0, (LPARAM)windowTitle);

	getErrorLogNameInto(logFile, MAX_PATH + 1);
	MultiByteToWideChar(CP_UTF8, 0, logFile, -1, logFileWide, MAX_PATH + 1);
	SetDlgItemTextW(debugWindowHWND, IDC_LOGFILE, logFileWide);

	if(debugWindowHWND == NULL){
		logErrorFromGetLastError("Creating Window");
		return;
	}

	ShowWindow(debugWindowHWND, SW_NORMAL | SW_SHOW);
}


