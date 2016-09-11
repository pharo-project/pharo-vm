/* Automatically generated by
	VMPluginCodeGenerator VMMaker.oscog-eem.1950 uuid: b4089b49-1494-49d2-8966-57cba5c92194
   from
	Matrix2x3Plugin VMMaker.oscog-eem.1950 uuid: b4089b49-1494-49d2-8966-57cba5c92194
 */
static char __buildInfo[] = "Matrix2x3Plugin VMMaker.oscog-eem.1950 uuid: b4089b49-1494-49d2-8966-57cba5c92194 " __DATE__ ;



#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

/* Default EXPORT macro that does nothing (see comment in sq.h): */
#define EXPORT(returnType) returnType

/* Do not include the entire sq.h file but just those parts needed. */
#include "sqConfig.h"			/* Configuration options */
#include "sqVirtualMachine.h"	/*  The virtual machine proxy definition */
#include "sqPlatformSpecific.h"	/* Platform specific definitions */

#define true 1
#define false 0
#define null 0  /* using 'null' because nil is predefined in Think C */
#ifdef SQUEAK_BUILTIN_PLUGIN
# undef EXPORT
# define EXPORT(returnType) static returnType
#endif

#include "sqMemoryAccess.h"


/*** Function Prototypes ***/
EXPORT(const char*) getModuleName(void);
static float * loadArgumentMatrix(sqInt matrix);
static sqInt loadArgumentPoint(sqInt point);
static sqInt matrix2x3ComposeMatrixwithinto(const float *m1, const float *m2, float *m3);
static sqInt matrix2x3InvertPoint(float *m);
static sqInt matrix2x3TransformPoint(float *m);
static sqInt okayIntValue(sqInt value);
EXPORT(sqInt) primitiveComposeMatrix(void);
EXPORT(sqInt) primitiveInvertPoint(void);
EXPORT(sqInt) primitiveInvertRectInto(void);
EXPORT(sqInt) primitiveIsIdentity(void);
EXPORT(sqInt) primitiveIsPureTranslation(void);
EXPORT(sqInt) primitiveTransformPoint(void);
EXPORT(sqInt) primitiveTransformRectInto(void);
static sqInt roundAndStoreResultPoint(sqInt nItemsToPop);
static sqInt roundAndStoreResultRectx0y0x1y1(sqInt dstOop, double  x0, double  y0, double  x1, double  y1);
EXPORT(sqInt) setInterpreter(struct VirtualMachine*anInterpreter);


/*** Variables ***/

#if !defined(SQUEAK_BUILTIN_PLUGIN)
static sqInt (*classPoint)(void);
static sqInt (*failed)(void);
static sqInt (*fetchClassOf)(sqInt oop);
static sqInt (*fetchPointerofObject)(sqInt index, sqInt oop);
static void * (*firstIndexableField)(sqInt oop);
static double (*floatValueOf)(sqInt oop);
static sqInt (*integerValueOf)(sqInt oop);
static sqInt (*isFloatObject)(sqInt oop);
static sqInt (*isIntegerObject)(sqInt objectPointer);
static sqInt (*isPointers)(sqInt oop);
static sqInt (*isWords)(sqInt oop);
static sqInt (*makePointwithxValueyValue)(sqInt xValue, sqInt yValue);
static sqInt (*pop)(sqInt nItems);
static sqInt (*popthenPush)(sqInt nItems, sqInt oop);
static sqInt (*popRemappableOop)(void);
static sqInt (*primitiveFail)(void);
static sqInt (*pushBool)(sqInt trueOrFalse);
static sqInt (*pushRemappableOop)(sqInt oop);
static sqInt (*slotSizeOf)(sqInt oop);
static sqInt (*stackObjectValue)(sqInt offset);
static sqInt (*storePointerofObjectwithValue)(sqInt index, sqInt oop, sqInt valuePointer);
#else /* !defined(SQUEAK_BUILTIN_PLUGIN) */
extern sqInt classPoint(void);
extern sqInt failed(void);
extern sqInt fetchClassOf(sqInt oop);
extern sqInt fetchPointerofObject(sqInt index, sqInt oop);
extern void * firstIndexableField(sqInt oop);
extern double floatValueOf(sqInt oop);
extern sqInt integerValueOf(sqInt oop);
extern sqInt isFloatObject(sqInt oop);
#if !defined(isIntegerObject)
extern sqInt isIntegerObject(sqInt objectPointer);
#endif
extern sqInt isPointers(sqInt oop);
extern sqInt isWords(sqInt oop);
extern sqInt makePointwithxValueyValue(sqInt xValue, sqInt yValue);
extern sqInt pop(sqInt nItems);
extern sqInt popthenPush(sqInt nItems, sqInt oop);
extern sqInt popRemappableOop(void);
extern sqInt primitiveFail(void);
extern sqInt pushBool(sqInt trueOrFalse);
extern sqInt pushRemappableOop(sqInt oop);
extern sqInt slotSizeOf(sqInt oop);
extern sqInt stackObjectValue(sqInt offset);
extern sqInt storePointerofObjectwithValue(sqInt index, sqInt oop, sqInt valuePointer);
extern
#endif
struct VirtualMachine* interpreterProxy;
static double m23ArgX;
static double m23ArgY;
static double m23ResultX;
static double m23ResultY;
static const char *moduleName =
#ifdef SQUEAK_BUILTIN_PLUGIN
	"Matrix2x3Plugin VMMaker.oscog-eem.1950 (i)"
#else
	"Matrix2x3Plugin VMMaker.oscog-eem.1950 (e)"
#endif
;



/*	Note: This is hardcoded so it can be run from Squeak.
	The module name is used for validating a module *after*
	it is loaded to check if it does really contain the module
	we're thinking it contains. This is important! */

	/* InterpreterPlugin>>#getModuleName */
EXPORT(const char*)
getModuleName(void)
{
	return moduleName;
}


/*	Load the argument matrix */

	/* Matrix2x3Plugin>>#loadArgumentMatrix: */
static float *
loadArgumentMatrix(sqInt matrix)
{
	if (failed()) {
		return null;
	}
	if (!((isWords(matrix))
		 && ((slotSizeOf(matrix)) == 6))) {
		primitiveFail();
		return null;
	}
	return ((float *) (firstIndexableField(matrix)));
}


/*	Load the argument point into m23ArgX and m23ArgY */

	/* Matrix2x3Plugin>>#loadArgumentPoint: */
static sqInt
loadArgumentPoint(sqInt point)
{
    int isInt;
    sqInt oop;

	if (failed()) {
		return null;
	}
	if (!((fetchClassOf(point)) == (classPoint()))) {
		return primitiveFail();
	}
	oop = fetchPointerofObject(0, point);
	isInt = isIntegerObject(oop);
	if (!(isInt
		 || (isFloatObject(oop)))) {
		return primitiveFail();
	}
	if (isInt) {
m23ArgX = integerValueOf(oop);
	}
	else {
m23ArgX = floatValueOf(oop);
	}
	oop = fetchPointerofObject(1, point);
	isInt = isIntegerObject(oop);
	if (!(isInt
		 || (isFloatObject(oop)))) {
		return primitiveFail();
	}
	if (isInt) {
m23ArgY = integerValueOf(oop);
	}
	else {
m23ArgY = floatValueOf(oop);
	}
	return 0;
}


/*	Multiply matrix m1 with m2 and store the result into m3. */

	/* Matrix2x3Plugin>>#matrix2x3ComposeMatrix:with:into: */
static sqInt
matrix2x3ComposeMatrixwithinto(const float *m1, const float *m2, float *m3)
{
    double  a11;
    double  a12;
    double  a13;
    double  a21;
    double  a22;
    double  a23;

	a11 = ((m1[0]) * (m2[0])) + ((m1[1]) * (m2[3]));
	a12 = ((m1[0]) * (m2[1])) + ((m1[1]) * (m2[4]));
	a13 = (((m1[0]) * (m2[2])) + ((m1[1]) * (m2[5]))) + (m1[2]);
	a21 = ((m1[3]) * (m2[0])) + ((m1[4]) * (m2[3]));
	a22 = ((m1[3]) * (m2[1])) + ((m1[4]) * (m2[4]));
	a23 = (((m1[3]) * (m2[2])) + ((m1[4]) * (m2[5]))) + (m1[5]);
	m3[0] = (((float) a11));
	m3[1] = (((float) a12));
	m3[2] = (((float) a13));
	m3[3] = (((float) a21));
	m3[4] = (((float) a22));
	m3[5] = (((float) a23));
	return 0;
}


/*	Invert the pre-loaded argument point by the given matrix */

	/* Matrix2x3Plugin>>#matrix2x3InvertPoint: */
static sqInt
matrix2x3InvertPoint(float *m)
{
    double  det;
    double  detX;
    double  detY;
    double  x;
    double  y;

	x = m23ArgX - (m[2]);
	y = m23ArgY - (m[5]);
	det = ((m[0]) * (m[4])) - ((m[1]) * (m[3]));
	if (det == 0.0) {
return primitiveFail();
	}
	det = 1.0 / det;
	detX = (x * (m[4])) - ((m[1]) * y);
	detY = ((m[0]) * y) - (x * (m[3]));
	m23ResultX = detX * det;
	m23ResultY = detY * det;
	return 0;
}


/*	Transform the pre-loaded argument point by the given matrix */

	/* Matrix2x3Plugin>>#matrix2x3TransformPoint: */
static sqInt
matrix2x3TransformPoint(float *m)
{
	m23ResultX = ((m23ArgX * (m[0])) + (m23ArgY * (m[1]))) + (m[2]);
	m23ResultY = ((m23ArgX * (m[3])) + (m23ArgY * (m[4]))) + (m[5]);
	return 0;
}

	/* Matrix2x3Plugin>>#okayIntValue: */
static sqInt
okayIntValue(sqInt value)
{
	return (value >= (((double) (MinSmallInteger) )))
	 && (value <= (((double) (MaxSmallInteger) )));
}

	/* Matrix2x3Plugin>>#primitiveComposeMatrix */
EXPORT(sqInt)
primitiveComposeMatrix(void)
{
    double  a11;
    double  a12;
    double  a13;
    double  a21;
    double  a22;
    double  a23;
    float *m1;
    float *m2;
    float *m3;
    sqInt matrix;
    sqInt matrix1;
    sqInt matrix2;
    sqInt result;

	/* begin loadArgumentMatrix: */
	matrix = (result = stackObjectValue(0));
	if (failed()) {
		m3 = null;
		goto l1;
	}
	if (!((isWords(matrix))
		 && ((slotSizeOf(matrix)) == 6))) {
		primitiveFail();
		m3 = null;
		goto l1;
	}
	m3 = ((float *) (firstIndexableField(matrix)));
l1:	/* end loadArgumentMatrix: */;
	/* begin loadArgumentMatrix: */
	matrix1 = stackObjectValue(1);
	if (failed()) {
		m2 = null;
		goto l2;
	}
	if (!((isWords(matrix1))
		 && ((slotSizeOf(matrix1)) == 6))) {
		primitiveFail();
		m2 = null;
		goto l2;
	}
	m2 = ((float *) (firstIndexableField(matrix1)));
l2:	/* end loadArgumentMatrix: */;
	/* begin loadArgumentMatrix: */
	matrix2 = stackObjectValue(2);
	if (failed()) {
		m1 = null;
		goto l3;
	}
	if (!((isWords(matrix2))
		 && ((slotSizeOf(matrix2)) == 6))) {
		primitiveFail();
		m1 = null;
		goto l3;
	}
	m1 = ((float *) (firstIndexableField(matrix2)));
l3:	/* end loadArgumentMatrix: */;
	if (failed()) {
		return null;
	}
	/* begin matrix2x3ComposeMatrix:with:into: */
	a11 = ((m1[0]) * (m2[0])) + ((m1[1]) * (m2[3]));
	a12 = ((m1[0]) * (m2[1])) + ((m1[1]) * (m2[4]));
	a13 = (((m1[0]) * (m2[2])) + ((m1[1]) * (m2[5]))) + (m1[2]);
	a21 = ((m1[3]) * (m2[0])) + ((m1[4]) * (m2[3]));
	a22 = ((m1[3]) * (m2[1])) + ((m1[4]) * (m2[4]));
	a23 = (((m1[3]) * (m2[2])) + ((m1[4]) * (m2[5]))) + (m1[5]);
	m3[0] = (((float) a11));
	m3[1] = (((float) a12));
	m3[2] = (((float) a13));
	m3[3] = (((float) a21));
	m3[4] = (((float) a22));
	m3[5] = (((float) a23));
	popthenPush(3, result);
	return 0;
}

	/* Matrix2x3Plugin>>#primitiveInvertPoint */
EXPORT(sqInt)
primitiveInvertPoint(void)
{
    float *matrix;
    sqInt matrix1;

	loadArgumentPoint(stackObjectValue(0));
	/* begin loadArgumentMatrix: */
	matrix1 = stackObjectValue(1);
	if (failed()) {
		matrix = null;
		goto l1;
	}
	if (!((isWords(matrix1))
		 && ((slotSizeOf(matrix1)) == 6))) {
		primitiveFail();
		matrix = null;
		goto l1;
	}
	matrix = ((float *) (firstIndexableField(matrix1)));
l1:	/* end loadArgumentMatrix: */;
	if (failed()) {
		return null;
	}
	matrix2x3InvertPoint(matrix);
	if (!(failed())) {
		/* begin roundAndStoreResultPoint: */
		m23ResultX += 0.5;
		m23ResultY += 0.5;
		if (!((m23ResultX >= (((double) (MinSmallInteger) )))
			 && (m23ResultX <= (((double) (MaxSmallInteger) ))))) {
			primitiveFail();
			goto l2;
		}
		if (!((m23ResultY >= (((double) (MinSmallInteger) )))
			 && (m23ResultY <= (((double) (MaxSmallInteger) ))))) {
			primitiveFail();
			goto l2;
		}
		popthenPush(2, makePointwithxValueyValue(((sqInt)m23ResultX), ((sqInt)m23ResultY)));
	l2:	/* end roundAndStoreResultPoint: */;
	}
	return 0;
}

	/* Matrix2x3Plugin>>#primitiveInvertRectInto */
EXPORT(sqInt)
primitiveInvertRectInto(void)
{
    double  cornerX;
    double  cornerY;
    sqInt dstOop;
    float *matrix;
    sqInt matrix1;
    double  maxX;
    double  maxY;
    double  minX;
    double  minY;
    double  originX;
    double  originY;
    sqInt srcOop;

	dstOop = stackObjectValue(0);
	srcOop = stackObjectValue(1);
	/* begin loadArgumentMatrix: */
	matrix1 = stackObjectValue(2);
	if (failed()) {
		matrix = null;
		goto l1;
	}
	if (!((isWords(matrix1))
		 && ((slotSizeOf(matrix1)) == 6))) {
		primitiveFail();
		matrix = null;
		goto l1;
	}
	matrix = ((float *) (firstIndexableField(matrix1)));
l1:	/* end loadArgumentMatrix: */;
	if (failed()) {
		return null;
	}
	if (!((fetchClassOf(srcOop)) == (fetchClassOf(dstOop)))) {
		return primitiveFail();
	}
	if (!(isPointers(srcOop))) {
		return primitiveFail();
	}
	if (!((slotSizeOf(srcOop)) == 2)) {
		return primitiveFail();
	}
	loadArgumentPoint(fetchPointerofObject(0, srcOop));
	if (failed()) {
		return null;
	}
	originX = m23ArgX;
	originY = m23ArgY;
	matrix2x3InvertPoint(matrix);
	minX = (maxX = m23ResultX);

	/* Load bottom-right point */
minY = (maxY = m23ResultY);
	loadArgumentPoint(fetchPointerofObject(1, srcOop));
	if (failed()) {
		return null;
	}
	cornerX = m23ArgX;
	cornerY = m23ArgY;
	matrix2x3InvertPoint(matrix);
	minX = ((minX < m23ResultX) ? minX : m23ResultX);
	maxX = ((maxX < m23ResultX) ? m23ResultX : maxX);
	minY = ((minY < m23ResultY) ? minY : m23ResultY);

	/* Load top-right point */
maxY = ((maxY < m23ResultY) ? m23ResultY : maxY);
	m23ArgX = cornerX;
	m23ArgY = originY;
	matrix2x3InvertPoint(matrix);
	minX = ((minX < m23ResultX) ? minX : m23ResultX);
	maxX = ((maxX < m23ResultX) ? m23ResultX : maxX);
	minY = ((minY < m23ResultY) ? minY : m23ResultY);

	/* Load bottom-left point */
maxY = ((maxY < m23ResultY) ? m23ResultY : maxY);
	m23ArgX = originX;
	m23ArgY = cornerY;
	matrix2x3InvertPoint(matrix);
	minX = ((minX < m23ResultX) ? minX : m23ResultX);
	maxX = ((maxX < m23ResultX) ? m23ResultX : maxX);
	minY = ((minY < m23ResultY) ? minY : m23ResultY);
	maxY = ((maxY < m23ResultY) ? m23ResultY : maxY);
	if (!(failed())) {
		dstOop = roundAndStoreResultRectx0y0x1y1(dstOop, minX, minY, maxX, maxY);
	}
	if (!(failed())) {
		popthenPush(3, dstOop);
	}
	return 0;
}

	/* Matrix2x3Plugin>>#primitiveIsIdentity */
EXPORT(sqInt)
primitiveIsIdentity(void)
{
    float *matrix;
    sqInt matrix1;

	/* begin loadArgumentMatrix: */
	matrix1 = stackObjectValue(0);
	if (failed()) {
		matrix = null;
		goto l1;
	}
	if (!((isWords(matrix1))
		 && ((slotSizeOf(matrix1)) == 6))) {
		primitiveFail();
		matrix = null;
		goto l1;
	}
	matrix = ((float *) (firstIndexableField(matrix1)));
l1:	/* end loadArgumentMatrix: */;
	if (failed()) {
		return null;
	}
	pop(1);
	pushBool(((((((matrix[0]) == (((float) 1.0))) && ((matrix[1]) == (((float) 0.0)))) && ((matrix[2]) == (((float) 0.0)))) && ((matrix[3]) == (((float) 0.0)))) && ((matrix[4]) == (((float) 1.0)))) && ((matrix[5]) == (((float) 0.0))));
	return 0;
}

	/* Matrix2x3Plugin>>#primitiveIsPureTranslation */
EXPORT(sqInt)
primitiveIsPureTranslation(void)
{
    float *matrix;
    sqInt matrix1;

	/* begin loadArgumentMatrix: */
	matrix1 = stackObjectValue(0);
	if (failed()) {
		matrix = null;
		goto l1;
	}
	if (!((isWords(matrix1))
		 && ((slotSizeOf(matrix1)) == 6))) {
		primitiveFail();
		matrix = null;
		goto l1;
	}
	matrix = ((float *) (firstIndexableField(matrix1)));
l1:	/* end loadArgumentMatrix: */;
	if (failed()) {
		return null;
	}
	pop(1);
	pushBool(((((matrix[0]) == (((float) 1.0))) && ((matrix[1]) == (((float) 0.0)))) && ((matrix[3]) == (((float) 0.0)))) && ((matrix[4]) == (((float) 1.0))));
	return 0;
}

	/* Matrix2x3Plugin>>#primitiveTransformPoint */
EXPORT(sqInt)
primitiveTransformPoint(void)
{
    float *matrix;
    sqInt matrix1;

	loadArgumentPoint(stackObjectValue(0));
	/* begin loadArgumentMatrix: */
	matrix1 = stackObjectValue(1);
	if (failed()) {
		matrix = null;
		goto l1;
	}
	if (!((isWords(matrix1))
		 && ((slotSizeOf(matrix1)) == 6))) {
		primitiveFail();
		matrix = null;
		goto l1;
	}
	matrix = ((float *) (firstIndexableField(matrix1)));
l1:	/* end loadArgumentMatrix: */;
	if (failed()) {
		return null;
	}
	/* begin matrix2x3TransformPoint: */
	m23ResultX = ((m23ArgX * (matrix[0])) + (m23ArgY * (matrix[1]))) + (matrix[2]);
	m23ResultY = ((m23ArgX * (matrix[3])) + (m23ArgY * (matrix[4]))) + (matrix[5]);
	/* begin roundAndStoreResultPoint: */
	m23ResultX += 0.5;
	m23ResultY += 0.5;
	if (!((m23ResultX >= (((double) (MinSmallInteger) )))
		 && (m23ResultX <= (((double) (MaxSmallInteger) ))))) {
		primitiveFail();
		goto l2;
	}
	if (!((m23ResultY >= (((double) (MinSmallInteger) )))
		 && (m23ResultY <= (((double) (MaxSmallInteger) ))))) {
		primitiveFail();
		goto l2;
	}
	popthenPush(2, makePointwithxValueyValue(((sqInt)m23ResultX), ((sqInt)m23ResultY)));
l2:	/* end roundAndStoreResultPoint: */;
	return 0;
}

	/* Matrix2x3Plugin>>#primitiveTransformRectInto */
EXPORT(sqInt)
primitiveTransformRectInto(void)
{
    double  cornerX;
    double  cornerY;
    sqInt dstOop;
    float *matrix;
    sqInt matrix1;
    double  maxX;
    double  maxY;
    double  minX;
    double  minY;
    double  originX;
    double  originY;
    sqInt srcOop;

	dstOop = stackObjectValue(0);
	srcOop = stackObjectValue(1);
	/* begin loadArgumentMatrix: */
	matrix1 = stackObjectValue(2);
	if (failed()) {
		matrix = null;
		goto l1;
	}
	if (!((isWords(matrix1))
		 && ((slotSizeOf(matrix1)) == 6))) {
		primitiveFail();
		matrix = null;
		goto l1;
	}
	matrix = ((float *) (firstIndexableField(matrix1)));
l1:	/* end loadArgumentMatrix: */;
	if (failed()) {
		return null;
	}
	if (!((fetchClassOf(srcOop)) == (fetchClassOf(dstOop)))) {
		return primitiveFail();
	}
	if (!(isPointers(srcOop))) {
		return primitiveFail();
	}
	if (!((slotSizeOf(srcOop)) == 2)) {
		return primitiveFail();
	}
	loadArgumentPoint(fetchPointerofObject(0, srcOop));
	if (failed()) {
		return null;
	}
	originX = m23ArgX;
	originY = m23ArgY;
	/* begin matrix2x3TransformPoint: */
	m23ResultX = ((m23ArgX * (matrix[0])) + (m23ArgY * (matrix[1]))) + (matrix[2]);
	m23ResultY = ((m23ArgX * (matrix[3])) + (m23ArgY * (matrix[4]))) + (matrix[5]);
	minX = (maxX = m23ResultX);

	/* Load bottom-right point */
minY = (maxY = m23ResultY);
	loadArgumentPoint(fetchPointerofObject(1, srcOop));
	if (failed()) {
		return null;
	}
	cornerX = m23ArgX;
	cornerY = m23ArgY;
	/* begin matrix2x3TransformPoint: */
	m23ResultX = ((m23ArgX * (matrix[0])) + (m23ArgY * (matrix[1]))) + (matrix[2]);
	m23ResultY = ((m23ArgX * (matrix[3])) + (m23ArgY * (matrix[4]))) + (matrix[5]);
	minX = ((minX < m23ResultX) ? minX : m23ResultX);
	maxX = ((maxX < m23ResultX) ? m23ResultX : maxX);
	minY = ((minY < m23ResultY) ? minY : m23ResultY);

	/* Load top-right point */
maxY = ((maxY < m23ResultY) ? m23ResultY : maxY);
	m23ArgX = cornerX;
	m23ArgY = originY;
	/* begin matrix2x3TransformPoint: */
	m23ResultX = ((m23ArgX * (matrix[0])) + (m23ArgY * (matrix[1]))) + (matrix[2]);
	m23ResultY = ((m23ArgX * (matrix[3])) + (m23ArgY * (matrix[4]))) + (matrix[5]);
	minX = ((minX < m23ResultX) ? minX : m23ResultX);
	maxX = ((maxX < m23ResultX) ? m23ResultX : maxX);
	minY = ((minY < m23ResultY) ? minY : m23ResultY);

	/* Load bottom-left point */
maxY = ((maxY < m23ResultY) ? m23ResultY : maxY);
	m23ArgX = originX;
	m23ArgY = cornerY;
	/* begin matrix2x3TransformPoint: */
	m23ResultX = ((m23ArgX * (matrix[0])) + (m23ArgY * (matrix[1]))) + (matrix[2]);
	m23ResultY = ((m23ArgX * (matrix[3])) + (m23ArgY * (matrix[4]))) + (matrix[5]);
	minX = ((minX < m23ResultX) ? minX : m23ResultX);
	maxX = ((maxX < m23ResultX) ? m23ResultX : maxX);
	minY = ((minY < m23ResultY) ? minY : m23ResultY);
	maxY = ((maxY < m23ResultY) ? m23ResultY : maxY);
	dstOop = roundAndStoreResultRectx0y0x1y1(dstOop, minX, minY, maxX, maxY);
	if (!(failed())) {
		popthenPush(3, dstOop);
	}
	return 0;
}


/*	Store the result of a previous operation.
	Fail if we cannot represent the result as SmallInteger */

	/* Matrix2x3Plugin>>#roundAndStoreResultPoint: */
static sqInt
roundAndStoreResultPoint(sqInt nItemsToPop)
{
	m23ResultX += 0.5;
	m23ResultY += 0.5;
	if (!((m23ResultX >= (((double) (MinSmallInteger) )))
		 && (m23ResultX <= (((double) (MaxSmallInteger) ))))) {
		return primitiveFail();
	}
	if (!((m23ResultY >= (((double) (MinSmallInteger) )))
		 && (m23ResultY <= (((double) (MaxSmallInteger) ))))) {
		return primitiveFail();
	}
	popthenPush(nItemsToPop, makePointwithxValueyValue(((sqInt)m23ResultX), ((sqInt)m23ResultY)));
	return 0;
}


/*	Check, round and store the result of a rectangle operation */

	/* Matrix2x3Plugin>>#roundAndStoreResultRect:x0:y0:x1:y1: */
static sqInt
roundAndStoreResultRectx0y0x1y1(sqInt dstOop, double  x0, double  y0, double  x1, double  y1)
{
    sqInt cornerOop;
    double  maxX;
    double  maxY;
    double  minX;
    double  minY;
    sqInt originOop;
    sqInt rectOop;

	minX = x0 + 0.5;
	if (!((minX >= (((double) (MinSmallInteger) )))
		 && (minX <= (((double) (MaxSmallInteger) ))))) {
		return primitiveFail();
	}
	maxX = x1 + 0.5;
	if (!((maxX >= (((double) (MinSmallInteger) )))
		 && (maxX <= (((double) (MaxSmallInteger) ))))) {
		return primitiveFail();
	}
	minY = y0 + 0.5;
	if (!((minY >= (((double) (MinSmallInteger) )))
		 && (minY <= (((double) (MaxSmallInteger) ))))) {
		return primitiveFail();
	}
	maxY = y1 + 0.5;
	if (!((maxY >= (((double) (MinSmallInteger) )))
		 && (maxY <= (((double) (MaxSmallInteger) ))))) {
		return primitiveFail();
	}
	pushRemappableOop(dstOop);
	originOop = makePointwithxValueyValue(((sqInt)minX), ((sqInt)minY));
	pushRemappableOop(originOop);
	cornerOop = makePointwithxValueyValue(((sqInt)maxX), ((sqInt)maxY));
	originOop = popRemappableOop();
	rectOop = popRemappableOop();
	storePointerofObjectwithValue(0, rectOop, originOop);
	storePointerofObjectwithValue(1, rectOop, cornerOop);
	return rectOop;
}


/*	Note: This is coded so that it can be run in Squeak. */

	/* InterpreterPlugin>>#setInterpreter: */
EXPORT(sqInt)
setInterpreter(struct VirtualMachine*anInterpreter)
{
    sqInt ok;

	interpreterProxy = anInterpreter;
	ok = ((interpreterProxy->majorVersion()) == (VM_PROXY_MAJOR))
	 && ((interpreterProxy->minorVersion()) >= (VM_PROXY_MINOR));
	if (ok) {

#if !defined(SQUEAK_BUILTIN_PLUGIN)
		classPoint = interpreterProxy->classPoint;
		failed = interpreterProxy->failed;
		fetchClassOf = interpreterProxy->fetchClassOf;
		fetchPointerofObject = interpreterProxy->fetchPointerofObject;
		firstIndexableField = interpreterProxy->firstIndexableField;
		floatValueOf = interpreterProxy->floatValueOf;
		integerValueOf = interpreterProxy->integerValueOf;
		isFloatObject = interpreterProxy->isFloatObject;
		isIntegerObject = interpreterProxy->isIntegerObject;
		isPointers = interpreterProxy->isPointers;
		isWords = interpreterProxy->isWords;
		makePointwithxValueyValue = interpreterProxy->makePointwithxValueyValue;
		pop = interpreterProxy->pop;
		popthenPush = interpreterProxy->popthenPush;
		popRemappableOop = interpreterProxy->popRemappableOop;
		primitiveFail = interpreterProxy->primitiveFail;
		pushBool = interpreterProxy->pushBool;
		pushRemappableOop = interpreterProxy->pushRemappableOop;
		slotSizeOf = interpreterProxy->slotSizeOf;
		stackObjectValue = interpreterProxy->stackObjectValue;
		storePointerofObjectwithValue = interpreterProxy->storePointerofObjectwithValue;
#endif /* !defined(SQUEAK_BUILTIN_PLUGIN) */
	}
	return ok;
}


#ifdef SQUEAK_BUILTIN_PLUGIN

static char _m[] = "Matrix2x3Plugin";
void* Matrix2x3Plugin_exports[][3] = {
	{(void*)_m, "getModuleName", (void*)getModuleName},
	{(void*)_m, "primitiveComposeMatrix\000\000", (void*)primitiveComposeMatrix},
	{(void*)_m, "primitiveInvertPoint\000\001", (void*)primitiveInvertPoint},
	{(void*)_m, "primitiveInvertRectInto\000\002", (void*)primitiveInvertRectInto},
	{(void*)_m, "primitiveIsIdentity\000\001", (void*)primitiveIsIdentity},
	{(void*)_m, "primitiveIsPureTranslation\000\001", (void*)primitiveIsPureTranslation},
	{(void*)_m, "primitiveTransformPoint\000\001", (void*)primitiveTransformPoint},
	{(void*)_m, "primitiveTransformRectInto\000\002", (void*)primitiveTransformRectInto},
	{(void*)_m, "setInterpreter", (void*)setInterpreter},
	{NULL, NULL, NULL}
};

#else /* ifdef SQ_BUILTIN_PLUGIN */

signed char primitiveComposeMatrixAccessorDepth = 0;
signed char primitiveInvertPointAccessorDepth = 1;
signed char primitiveInvertRectIntoAccessorDepth = 2;
signed char primitiveIsIdentityAccessorDepth = 1;
signed char primitiveIsPureTranslationAccessorDepth = 1;
signed char primitiveTransformPointAccessorDepth = 1;
signed char primitiveTransformRectIntoAccessorDepth = 2;

#endif /* ifdef SQ_BUILTIN_PLUGIN */
