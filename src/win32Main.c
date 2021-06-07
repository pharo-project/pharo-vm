#include "pharovm/pharoClient.h"

#include <windows.h>

int CALLBACK
WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    return vm_main(__argc, (const char **)__argv, (const char**)environ);
}
