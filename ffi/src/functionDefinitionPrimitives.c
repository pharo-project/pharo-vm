#include "sq.h"
#include "pharovm/macros.h"

#ifdef FEATURE_FFI
#include "pThreadedFFI.h"

void* defineFunctionWithAnd(ffi_type* parameters[], sqInt count, void* returnType, ffi_abi abi){
	ffi_cif* cif;
	int returnCode; 
	
	cif = malloc(sizeof(ffi_cif));
	
	returnCode = ffi_prep_cif(cif, abi, count, returnType, parameters);
	
	if(returnCode != FFI_OK){
		primitiveFailFor(returnCode);
		free(cif);
		free(parameters);
		return NULL;
	}
		
	return cif;
}

void* defineVariadicFunction(ffi_type* parameters[], sqInt fixedArgsCount, sqInt totalArguments, void* returnType, ffi_abi abi){
	ffi_cif* cif;
	int returnCode; 
	
	cif = malloc(sizeof(ffi_cif));
	
	returnCode = ffi_prep_cif_var (cif, abi, fixedArgsCount, totalArguments, returnType, parameters);
	
	
	if(returnCode != FFI_OK){
		primitiveFailFor(returnCode);
		free(cif);
		free(parameters);
		return NULL;
	}
		
	return cif;
}

#endif

PrimitiveWithDepth(primitiveDefineFunction, 2){

#ifndef FEATURE_FFI
	primitiveFail();
#else

    sqInt count;
    void*handler;
    sqInt idx;
    sqInt returnTypePosition;
    ffi_type** parameters;
    sqInt paramsArray;
    sqInt receiver;
    void*returnType;
    ffi_abi abiToUse;

	if(methodArgumentCount() == 3){
		abiToUse = stackIntegerValue(0);
		returnTypePosition = 1;
		checkFailed();
	}else{
		returnTypePosition = 0;
		abiToUse = FFI_DEFAULT_ABI;
	}

	returnType = readAddress(stackValue(returnTypePosition));
	checkFailed();

	count = stSizeOf(stackValue(returnTypePosition + 1));
	checkFailed();

	paramsArray = stackValue(returnTypePosition + 1);
	checkFailed();

	/* The parameters are freed by the primitiveFreeDefinition, if there is an error it is freed by #defineFunction:With:And: */
	receiver = stackValue(returnTypePosition + 2);
	checkFailed();

	parameters = malloc(count*sizeof(void*));
	for (idx = 0; idx < count; idx += 1) {
		parameters[idx] = (readAddress(stObjectat(paramsArray, idx + 1)));
	}
    checkFailed()

	handler = defineFunctionWithAnd(parameters, count, returnType, abiToUse);
    checkFailed();

	setHandler(receiver, handler);
	checkFailed();
#endif
	primitiveEnd();
}

PrimitiveWithDepth(primitiveDefineVariadicFunction, 2){

#ifndef FEATURE_FFI
	primitiveFail();
#else

	sqInt totalCount;
	sqInt fixedArguments;
	void*handler;
	sqInt idx;
	ffi_type** parameters;
	sqInt paramsArray;
	sqInt receiver;
    sqInt fixedArgumentsPosition;
	void*returnType;
    ffi_abi abiToUse;

	if(methodArgumentCount() == 3){
		abiToUse = stackIntegerValue(0);
		fixedArgumentsPosition = 1;
		checkFailed();
	}else{
		fixedArgumentsPosition = 0;
		abiToUse = FFI_DEFAULT_ABI;
	}


	fixedArguments = stackIntegerValue(fixedArgumentsPosition);
	checkFailed();

	returnType = readAddress(stackValue(fixedArgumentsPosition + 1));
	checkFailed();

	totalCount = stSizeOf(stackValue(fixedArgumentsPosition + 2));
	checkFailed();

	paramsArray = stackValue(fixedArgumentsPosition + 2);
	checkFailed();

	/* The parameters are freed by the primitiveFreeDefinition, if there is an error it is freed by #defineFunction:with:and:fixedArgumentsCount: */
	receiver = stackValue(fixedArgumentsPosition + 3);
	checkFailed();

	parameters = malloc(totalCount*sizeof(void*));
	for (idx = 0; idx < totalCount; idx += 1) {
		parameters[idx] = (readAddress(stObjectat(paramsArray, idx + 1)));
	}
    checkFailed()

	handler = defineVariadicFunction(parameters, fixedArguments, totalCount, returnType, abiToUse);

    checkFailed();

	setHandler(receiver, handler);
	checkFailed();
#endif
	primitiveEnd();
}

PrimitiveWithDepth(primitiveFreeDefinition, 1){

#ifndef FEATURE_FFI
	primitiveFail();
#else

	void*handler;
    sqInt receiver;

	receiver = stackValue(0);
	checkFailed();

	handler = getHandler(receiver);
	checkFailed();

	if(!handler){
		primitiveFail();
		return;
	}

	free(((ffi_cif*)handler)->arg_types);
	free(handler);

	setHandler(receiver, 0);

#endif
}
