#include "pharovm/pharo.h"
#include <Windows.h>

#define IDM_OPEN_DEBUGWINDOW 	0xE001

LRESULT CALLBACK Pharo_WindowProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);

EXPORT(int) enableDebugWindowMenu(HWND window){

	LONG_PTR originalHandler;
	char* errorMessage;

	/*
	 * First check if the window userdata is not used.
	 * If it is used return FALSE
	 */
	originalHandler = GetWindowLongPtrW(window, GWLP_USERDATA);

	if(originalHandler != 0){
		return FALSE;
	}

	/**
	 * Store the original WndProc in the user data, so the new WndProc can delegate to it.
	 */
	originalHandler = GetWindowLongPtrW(window, GWLP_WNDPROC);
	SetWindowLongPtrW(window, GWLP_USERDATA, originalHandler);

	/*
	 * Copy the Menu so it can be updated with the new option
	 */
    HMENU windowMenu = GetSystemMenu(window, FALSE);

	if(windowMenu == 0){
		logErrorFromGetLastError("Error copying system menu");
		return FALSE;
	}

    if (windowMenu != NULL){
        if(AppendMenu(windowMenu, MF_SEPARATOR, 0, NULL) == 0){
    		logErrorFromGetLastError("Error creating menu");
    		return FALSE;
        }

        if(AppendMenu(windowMenu, MF_STRING, IDM_OPEN_DEBUGWINDOW, TEXT("Open Debug Window")) == 0){
    		logErrorFromGetLastError("Error creating menu");
    		return FALSE;
        }
    }

	if(SetWindowLongPtrW(window, GWLP_WNDPROC, (LONG_PTR) Pharo_WindowProc) == 0){
		logErrorFromGetLastError("Error enabling debug menu");
		return FALSE;
	}

	return TRUE;
}

LRESULT CALLBACK Pharo_WindowProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam){

	WNDPROC originalHandler = (WNDPROC) GetWindowLongPtrW(hwnd, GWLP_USERDATA);

	if(msg == WM_SYSCOMMAND && wParam == IDM_OPEN_DEBUGWINDOW){
		logDebug("Open DebugWindow Event");
		openDebugWindow(hwnd);
		return 0;
	}

	if(originalHandler){
		return CallWindowProcW(originalHandler, hwnd, msg, wParam, lParam);
	}else{
		return DefWindowProcW(hwnd, msg, wParam, lParam);
	}
}
