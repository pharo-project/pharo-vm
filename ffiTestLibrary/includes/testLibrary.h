#ifndef TEST_LIBRARY_H
#define TEST_LIBRARY_H

//Define proper exports on Win32
#ifdef _WIN32
# include <windows.h>
# define EXPORT(returnType) __declspec( dllexport ) returnType
#else
# define EXPORT(returnType) returnType
#endif


#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>

#if !defined(_WIN32)
#include <unistd.h>
#endif


#include "structures.h"

typedef enum {
	firstuint = 1
} uintenum;

typedef enum {
	firstsint = -1
} sintenum;

typedef enum {
	firstchar = 'a'
} charenum;

#endif
