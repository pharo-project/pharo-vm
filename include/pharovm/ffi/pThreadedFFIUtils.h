#ifndef __UTILS__
#define __UTILS__

#include "pharovm/pharo.h"

void setHandler(sqInt anExternalObject, void* value);
void writeAddress(sqInt anExternalAddress, void* value);
char *readString(sqInt aString);
void *getAddressFromExternalAddressOrByteArray(sqInt anExternalAddressOrByteArray);

// meta
sqInt getAttributeOf(sqInt receiver, int index);
void *getHandlerOf(sqInt receiver, int index);
// arrays
sqInt arrayObjectAt(sqInt array, sqInt index);
sqInt arrayObjectAtPut(sqInt array, sqInt index, sqInt object);
sqInt arrayObjectSize(sqInt array);
// clean ending for a primitive

// Inline  functions need to be defined in the file that uses them. Thus define them at the header level
static inline sqInt getReceiver() {
    return stackValue(methodArgumentCount());
}
// these must be made static else they cause trouble with no-opt -O0 builds
// because the compiler doesn't inline them with -O0
static inline void primitiveEnd() {
    //pop all execept receiver, which will be answered (^self)
    pop(methodArgumentCount());
}

static inline void primitiveEndReturn(sqInt ret) {
    //pop all including receiver, we are answering our own result
    pop(methodArgumentCount() + 1);
    push(ret);
}

static inline void primitiveEndReturnInteger(sqInt ret) {
    pop(methodArgumentCount() + 1);
    pushInteger(ret);
}
// others
sqInt newExternalAddress(void *address);

#endif
