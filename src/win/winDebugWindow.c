#include "pharovm/pharo.h"
#include <Windows.h>
#include <shellapi.h>
#include <CommCtrl.h>
#include "pharovm/win/resources.h"

HWND debugWindowHWND;

DWORD logLength;
DWORD logPosition;

#define LOGBUFFER_SIZE 	4195
#define LOG_LINES 		  29
#define APP_REFRESHLOG	(WM_APP + 0)

char* logBuffer;
WCHAR* logBufferWide;
DWORD logBufferUsedSize;

extern int printCallStack();
extern int printAllStacks();

void updateLogText();
void updateFromScrollBar(int request);

void openLogFile(HWND hwnd){
	char logFile[MAX_PATH + 1];
	WCHAR logFileWide[MAX_PATH + 1];

	getErrorLogNameInto(logFile, MAX_PATH + 1);

	if(MultiByteToWideChar(CP_UTF8, 0, logFile, -1, logFileWide, MAX_PATH + 1) <= 0){
		logErrorFromGetLastError("Converting logFile name");
		return;
	}

	ShellExecuteW(hwnd, TEXT("open"), logFileWide, NULL, NULL, SW_SHOW);
}

INT_PTR DebugWindow_WindowProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam){

	switch(msg){
		case APP_REFRESHLOG: {
			updateLogText();
			break;
		}

		case WM_SIZE: {
			UINT width = LOWORD(lParam);
			UINT height = HIWORD(lParam);
			logDebug("Resize %d, %d", width, height);
			break;
		}

		case WM_CLOSE: {
			EndDialog(hwnd,0);
			debugWindowHWND = NULL;
			free(logBuffer);
			free(logBufferWide);
			break;
		}

		case WM_VSCROLL:{
			if((HWND)lParam == GetDlgItem(hwnd, IDC_LOGTEXT_SCROLL)){
				updateFromScrollBar(LOWORD(wParam));
			}
			break;
		}

		case WM_COMMAND:{
			switch(LOWORD(wParam)){
				case IDC_CALLSTACK:
					vm_printf("\nActive Stack trace:\n\n");
					printCallStack();
					updateLogText();
					break;
				case IDC_ALLSTACKS:
					vm_printf("\nAll Stack traces (First is active one):\n\n");
					printAllStacks();
					updateLogText();
					break;
				case IDC_OPENLOG:
					openLogFile(hwnd);
					break;
				case IDC_LOGLEVEL:
					switch(HIWORD(wParam)){
						case CBN_SELCHANGE: {
							int newLevel = SendDlgItemMessageW(debugWindowHWND, IDC_LOGLEVEL, CB_GETCURSEL, (WPARAM)0, (LPARAM)0);
							if(newLevel != CB_ERR && newLevel >= 0 && newLevel <= 5){
								logDebug("Setting new logLevel to: %d", newLevel);
								logLevel(newLevel);
							}
							break;
						}
					}
					break;
			}
			break;
		}
		default:
			return FALSE;
	}

	return TRUE;
}

void updateLogLevelComboBox(){
	SendDlgItemMessageW(debugWindowHWND, IDC_LOGLEVEL, CB_ADDSTRING, (WPARAM)0, (LPARAM)TEXT("None"));
	SendDlgItemMessageW(debugWindowHWND, IDC_LOGLEVEL, CB_ADDSTRING, (WPARAM)0, (LPARAM)TEXT("Error"));
	SendDlgItemMessageW(debugWindowHWND, IDC_LOGLEVEL, CB_ADDSTRING, (WPARAM)0, (LPARAM)TEXT("Warning"));
	SendDlgItemMessageW(debugWindowHWND, IDC_LOGLEVEL, CB_ADDSTRING, (WPARAM)0, (LPARAM)TEXT("Info"));
	SendDlgItemMessageW(debugWindowHWND, IDC_LOGLEVEL, CB_ADDSTRING, (WPARAM)0, (LPARAM)TEXT("Debug"));
	SendDlgItemMessageW(debugWindowHWND, IDC_LOGLEVEL, CB_ADDSTRING, (WPARAM)0, (LPARAM)TEXT("Trace"));

	SendDlgItemMessageW(debugWindowHWND, IDC_LOGLEVEL, CB_SETCURSEL, (WPARAM) getLogLevel(), (LPARAM)0);
}

void scrollToPosition(){

	/*
	 * We move the position of the log to the logPosition variable.
	 * We copy the buffer to a newone transforming the line ending from \n to \r\n
	 */

	FILE *log = getErrorLogFile();

	char logBuffer2[LOGBUFFER_SIZE * 2 + 1];

	fflush(log);
	fseek(log, logPosition, SEEK_SET);
	logBufferUsedSize = fread(logBuffer, sizeof(char), LOGBUFFER_SIZE, log);
	fseek(log, 0, SEEK_END);

	if(logBufferUsedSize != -1){
		logBuffer[logBufferUsedSize] = '\0';

		long logLimit = strlen(logBuffer);
		long logIndex = 0;
		long logIndex2 = 0;
		int linesCount = 0;

		/*
		 * We want only LOG_LINES lines.
		 * We start from the end.
		 *
		 * only if the position is not 0.
		 * If it is 0 we start from the beginning.
		 */

		if(logPosition != 0){
			logIndex = logLimit - 1;

			while(logIndex > 0 && linesCount < LOG_LINES){
				if(logBuffer[logIndex] == '\n'){
					linesCount++;
				}
				logIndex --;
			}

			if(logIndex + 2 <= logLimit){
				logIndex += 2;
			}
		}

		/*
		 * If the position of the log is not the beginning, we look for the first line
		 * so we jump the first semi complete line.
		 * We are in the start of the buffer, and we are not sure if we have a complete line
		 *
		 * We walk until the next newline and add 1 to jump the newline
		 */
		if(logPosition != 0 && logIndex == 0){
			while(logIndex < logLimit && logBuffer[logIndex] != '\n'){
				logIndex++;
			}

			if(logIndex < logLimit){
				logIndex++;
			}
		}

		while(logIndex <= logLimit){

			if(logBuffer[logIndex] == '\n'){
				logBuffer2[logIndex2] = '\r';
				logIndex2++;
			}

			logBuffer2[logIndex2] = logBuffer[logIndex];

			logIndex ++;
			logIndex2 ++;
		}

		MultiByteToWideChar(CP_UTF8, 0, logBuffer2, -1, logBufferWide, LOGBUFFER_SIZE + 1);
		SetDlgItemTextW(debugWindowHWND, IDC_LOGTEXT, logBufferWide);

		/*
		 * Scroll the Edit control to the end, just in case the edit control is showing more lines than expecting.
		 * We have the number of lines fixed by the size of the window.
		 * That is why the window has fixed size
		 */

		SendDlgItemMessageW(debugWindowHWND, IDC_LOGTEXT, EM_SETSEL, 0, -1); //Select all.
		SendDlgItemMessageW(debugWindowHWND, IDC_LOGTEXT, EM_SETSEL, -1, -1);//Unselect and stay at the end pos
		SendDlgItemMessageW(debugWindowHWND, IDC_LOGTEXT, EM_SCROLLCARET, 0, 0); //Set scrollcaret to the current Pos
	}
}

void updateLogText(){
	SCROLLINFO scrollInfo;
	FILE *log = getErrorLogFile();

	logLength = ftell(log);
	logPosition = logLength - LOGBUFFER_SIZE;
	logPosition = logPosition < 0 ? 0 : logPosition;

	scrollInfo.cbSize = sizeof(SCROLLINFO);
	scrollInfo.fMask = SIF_RANGE | SIF_POS;
	scrollInfo.nMin = 0;
	scrollInfo.nMax = logLength;
	scrollInfo.nPos = logPosition;

	SetScrollInfo(GetDlgItem(debugWindowHWND, IDC_LOGTEXT_SCROLL), SB_CTL, &scrollInfo, TRUE);

	scrollToPosition();
}

void updateFromScrollBar(int request){
	SCROLLINFO scrollInfo;
	scrollInfo.cbSize = sizeof(SCROLLINFO);

	if(logLength == 0)
		return;

	switch(request){
		case SB_TOP:
			logPosition = 0;
			break;

		case SB_BOTTOM:
			logPosition = logLength - 1;
			break;

		case SB_PAGEDOWN:
		case SB_LINEDOWN:
			logPosition = logPosition + 10;
			break;

		case SB_PAGEUP:
		case SB_LINEUP:
			logPosition = logPosition - 10  > 0 ? logPosition - 10 : 0;
			break;

		case SB_THUMBPOSITION:
		case SB_THUMBTRACK:{
			scrollInfo.fMask = SIF_TRACKPOS | SIF_POS;

			GetScrollInfo(GetDlgItem(debugWindowHWND, IDC_LOGTEXT_SCROLL), SB_CTL, &scrollInfo);

			if(logPosition != scrollInfo.nPos){
				logPosition = scrollInfo.nPos;
			}else{
				logPosition = scrollInfo.nTrackPos;
			}
			break;
		}

		default:
			return;
	}

	if(logPosition >= logLength)
		logPosition = logLength - 1;

	if(logPosition < 0)
		logPosition = 0;

	scrollInfo.fMask = SIF_POS;
	scrollInfo.nPos = logPosition;
	/*
	 * Accept the new position
	 */
	SetScrollInfo(GetDlgItem(debugWindowHWND, IDC_LOGTEXT_SCROLL), SB_CTL, &scrollInfo, TRUE);

	scrollToPosition();
}

EXPORT(void) openDebugWindow(void* parentHwnd){

	WCHAR windowTitle[255];
	char logFile[MAX_PATH + 1];
	WCHAR logFileWide[MAX_PATH + 1];

	logLength = 0;
	logPosition = 0;

	logBufferUsedSize = 0;
	logBuffer = (char*) malloc(sizeof(char) * (LOGBUFFER_SIZE + 1));
	logBufferWide = (WCHAR*) malloc(sizeof(WCHAR) * (LOGBUFFER_SIZE + 1));

	memset(logBuffer, 0, sizeof(char) * (LOGBUFFER_SIZE + 1));
	memset(logBufferWide, 0, sizeof(WCHAR) * (LOGBUFFER_SIZE + 1));

	if(debugWindowHWND != NULL)
		return;

	debugWindowHWND = CreateDialogParamW(
			GetModuleHandle(NULL),
			MAKEINTRESOURCEW(IDD_DEBUG),
			(HWND)parentHwnd,
			DebugWindow_WindowProc,
			0);

	if(debugWindowHWND == NULL){
		logErrorFromGetLastError("Creating Window");
		return;
	}
	_snwprintf(windowTitle, 255, TEXT("Pharo Debug - PID: %d"), GetCurrentProcessId());
	SendMessageW(debugWindowHWND, WM_SETTEXT, (WPARAM) 0, (LPARAM)windowTitle);

	getErrorLogNameInto(logFile, MAX_PATH + 1);
	MultiByteToWideChar(CP_UTF8, 0, logFile, -1, logFileWide, MAX_PATH + 1);
	SetDlgItemTextW(debugWindowHWND, IDC_LOGFILE, logFileWide);

	updateLogLevelComboBox();
	updateLogText();

	ShowWindow(debugWindowHWND, SW_NORMAL | SW_SHOW);
}

EXPORT(void) notifyDebugWindow(){
	if(debugWindowHWND){
		SendMessageW(debugWindowHWND, APP_REFRESHLOG, (WPARAM)0, (LPARAM)0);
	}
}
