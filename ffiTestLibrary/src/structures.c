#include "testLibrary.h"

EXPORT(int) sizeOfPoint(){
	return sizeof(OUR_POINT);
}


EXPORT(OUR_POINT) newPoint(int x, int y){
	OUR_POINT p;
	p.x = x;
	p.y = y;

	return p;
}

EXPORT(int) assertCorrectPoint(OUR_POINT aPoint, int x, int y){
	return aPoint.x == x && aPoint.y == y;
}

EXPORT(int) sizeOfLongStruct(){
	return sizeof(LONG_STRUCT);
}

EXPORT(int) passingLongStruct(LONG_STRUCT st, float b, double c, long d){
	return st.b == b && st.c == c && st.d == d;
}

EXPORT(int) passingLongStructByRef(LONG_STRUCT* st, float b, double c, long d){
	return st && st->b == b && st->c == c && st->d == d;
}

EXPORT(int) sizeOfNestedStruct(){
	return sizeof(NESTED_STRUCTS);
}

EXPORT(int) passingNestedStruct(NESTED_STRUCTS st, char a, double y){
	return st.inner.a == a && st.y == y;
}
