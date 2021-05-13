#include "testLibrary.h"

//Deprecated
EXPORT(int) returnAnswer(){
	return 42;
}

//Deprecated
EXPORT(int) sumTwoNumbers(int a, int b){
  return a+b; 
}

//Deprecated
EXPORT(float) sumAFloatAndADouble(float a, double b){
  return a+b; 
}

EXPORT(int) shortCallout(){
  return 42;
}

EXPORT(int) longCallout(int seconds){

	// will sleep for number of seconds
#if defined(_WIN32)
	Sleep(seconds * 1000);
#else
	sleep(seconds);
#endif
	return 1;
}

EXPORT(int) multipleArgumentCallout(
  int arg1,
  int arg2,
  int arg3,
  int arg4,
  int arg5,
  int arg6,
  int arg7,
  int arg8,
  int arg9,
  int arg10){
  return arg1 + arg2 + arg3 + arg4 + arg5 + arg6 + arg7 + arg8 + arg9 + arg10;
}
