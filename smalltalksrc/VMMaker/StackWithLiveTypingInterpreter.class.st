Class {
	#name : #StackWithLiveTypingInterpreter,
	#superclass : #StackInterpreterPrimitives,
	#category : #'VMMaker-Interpreter'
}

{ #category : #'live-typing' }
StackWithLiveTypingInterpreter >> additionalMethodStateOf: methodPointer [

	<inline: true>
	
	| additionalMethodState |

	additionalMethodState := self followLiteral: (objectMemory literalCountOf: methodPointer) - 2 ofMethod: methodPointer.
	^ (additionalMethodState ~= objectMemory nilObject and: [objectMemory isPointers: additionalMethodState]) "filters out fullBlock last literal"
			ifTrue: [ additionalMethodState ]
			ifFalse: [objectMemory nilObject]
]

{ #category : #'stack bytecodes' }
StackWithLiveTypingInterpreter >> extendedStoreBytecodePop: popBoolean [
	| descriptor variableType variableIndex value rcvr |
	<inline: true>
	descriptor := self fetchByte.
	variableType := descriptor >> 6 bitAnd: 3.
	variableIndex := descriptor bitAnd: 63.
	value := self internalStackTop.
	popBoolean ifTrue: [ self internalPop: 1 ].
	variableType = 0 ifTrue:
		[rcvr := self receiver.
		objectMemory storePointerImmutabilityCheck: variableIndex ofObject: rcvr withValue: value.
		self keepInstanceVariableTypeInformationFor: value in: rcvr at: variableIndex.
		^ self fetchNextBytecode].
	variableType = 1 ifTrue:
		[ self fetchNextBytecode.
		^self keepTypeAndSetTemporary: variableIndex in: localFP put: value].
	variableType = 3 ifTrue:
		[self storeLiteralVariable: variableIndex withValue: value.
		^ self fetchNextBytecode].
	self error: 'illegal store'
]

{ #category : #'message sending' }
StackWithLiveTypingInterpreter >> internalActivateNewMethod [ 
	| methodHeader numTemps rcvr |
	<inline: true>

	methodHeader := objectMemory methodHeaderOf: newMethod.
	numTemps := self temporaryCountOfMethodHeader: methodHeader.
	self assert: argumentCount = (self argumentCountOfMethodHeader: methodHeader).
	rcvr := self internalStackValue: argumentCount. "could new rcvr be set at point of send?"
	self assert: (objectMemory isOopForwarded: rcvr) not.

	self keepArgumentTypes.

	self internalPush: localIP.
	self internalPush: localFP.
	localFP := localSP.
	self internalPush: newMethod.
	self setMethod: newMethod methodHeader: methodHeader.
	self internalPush: (self
						encodeFrameFieldHasContext: false
						isBlock: false
						numArgs: (self argumentCountOfMethodHeader: methodHeader)).
	self internalPush: objectMemory nilObject. "FxThisContext field"
	self internalPush: rcvr.

	"Initialize temps..."
	argumentCount + 1 to: numTemps do:
		[:i | self internalPush: objectMemory nilObject].

	"-1 to account for pre-increment in fetchNextBytecode"
	localIP := self pointerForOop: (self initialIPForHeader: methodHeader method: newMethod) - 1.

	(self methodHeaderHasPrimitive: methodHeader) ifTrue:
		["Skip the CallPrimitive bytecode, if it's there, and store the error code if the method starts
		  with a long store temp.  Strictly no need to skip the store because it's effectively a noop."
		 localIP := localIP + (self sizeOfCallPrimitiveBytecode: methodHeader).
		 primFailCode ~= 0 ifTrue:
			[self reapAndResetErrorCodeTo: localSP header: methodHeader]].

	self assert: (self frameNumArgs: localFP) = argumentCount.
	self assert: (self frameIsBlockActivation: localFP) not.
	self assert: (self frameHasContext: localFP) not.

	"Now check for stack overflow or an event (interrupt, must scavenge, etc)."
	localSP < stackLimit ifTrue:
		[self externalizeIPandSP.
		 self handleStackOverflowOrEventAllowContextSwitch: (self canContextSwitchIfActivating: newMethod header: methodHeader).
		 self internalizeIPandSP]
]

{ #category : #'live-typing' }
StackWithLiveTypingInterpreter >> keepArgumentTypes [
	| additionalMethodState tempVarsTypes maxNumberOfArguments types |
	<inline: true>
			
	argumentCount > 0 ifTrue: [ 
		additionalMethodState := self additionalMethodStateOf: newMethod.
		additionalMethodState = objectMemory nilObject ifFalse: [ 
			tempVarsTypes := objectMemory followObjField: 2 ofObject: additionalMethodState.
			tempVarsTypes = objectMemory nilObject ifFalse: [ 
				(self isInstanceOfClassArray: tempVarsTypes) ifTrue: [ 
					maxNumberOfArguments := (objectMemory lengthOf: tempVarsTypes) min: (argumentCount-1).
					0 to: maxNumberOfArguments do: [ :argIndex | 
						types := objectMemory followObjField: argIndex ofObject: tempVarsTypes.
						self keepTypeInformationIn: types for: (self internalStackValue: argIndex)]]]]].

	
]

{ #category : #'live-typing' }
StackWithLiveTypingInterpreter >> keepInstanceVariableTypeInformationFor: anAssignedObject in: rcvr at: instVarIndex [

	<inline: true>

	| instVarsTypes rcvrClass rcvrClassTag |
	
	rcvrClassTag := objectMemory fetchClassTagOf: rcvr.
	self deny: (objectMemory isForwardedClassTag: rcvrClassTag).
	rcvrClass := objectMemory classForClassTag: rcvrClassTag.
	self deny: rcvrClass isNil.

	instVarsTypes := objectMemory followObjField: 5 ofObject: rcvrClass.
	self keepTypeInformationIn: instVarsTypes at: instVarIndex for: anAssignedObject.

]

{ #category : #'live-typing' }
StackWithLiveTypingInterpreter >> keepReturnObjectType [

	<inline: true>

	| frameMethod additionalMethodState returnTypes |
	
	frameMethod := self frameMethod: localFP.
	additionalMethodState := self additionalMethodStateOf: frameMethod.
	additionalMethodState = objectMemory nilObject ifFalse: [ 
		returnTypes := objectMemory followObjField: 3 ofObject: additionalMethodState.
		self keepTypeInformationIn: returnTypes for: localReturnValue ]
	
]

{ #category : #'live-typing' }
StackWithLiveTypingInterpreter >> keepTypeAndSetTemporary: tempIndex in: theFP put: anAssignedObject [

	<inline: true>

	| frameMethod additionalMethodState tempVarsTypes |
	
	self temporary: tempIndex in: theFP put: anAssignedObject.

	frameMethod := self frameMethod: theFP.
	additionalMethodState := self additionalMethodStateOf: frameMethod.
	additionalMethodState = objectMemory nilObject ifFalse: [ 
		tempVarsTypes := objectMemory followObjField: 2 ofObject: additionalMethodState.
		self keepTypeInformationIn: tempVarsTypes at: tempIndex for: anAssignedObject ]
]

{ #category : #'live-typing' }
StackWithLiveTypingInterpreter >> keepTypeInformationIn: allVarsTypes at: anIndex for: anAssignedObject [

	<inline: true>

	| types |
	
	allVarsTypes = objectMemory nilObject ifFalse: [
		(self isInstanceOfClassArray: allVarsTypes) ifTrue: [
			anIndex < (objectMemory lengthOf: allVarsTypes) ifTrue:  [ 
				types := objectMemory followObjField: anIndex ofObject: allVarsTypes.
				self keepTypeInformationIn: types for: anAssignedObject ]]]

]

{ #category : #'live-typing' }
StackWithLiveTypingInterpreter >> keepTypeInformationIn: types for: anAssignedObject [

	<inline: true>
	
	| assignedObjectClass assignedObjectClassTag typesSize index typeNotStored typeAtIndex |
	
	types = objectMemory nilObject ifFalse: [ 
		(self isInstanceOfClassArray: types) ifTrue: [ 
			assignedObjectClassTag := objectMemory fetchClassTagOf: anAssignedObject.
			self deny: (objectMemory isForwardedClassTag: assignedObjectClassTag).
			assignedObjectClass := objectMemory classForClassTag: assignedObjectClassTag.
			self deny: assignedObjectClass isNil.

			"To avoid label redefinition compile error! - Hernan"
			typesSize := (objectMemory lengthOf: types)-0.
			index := 0.
			typeNotStored := true.
			[ typeNotStored and: [ index < typesSize ] ] whileTrue: [ 
				typeAtIndex := objectMemory followObjField: index ofObject: types.
				typeAtIndex == assignedObjectClass 
					ifTrue: [ typeNotStored := false ]
					ifFalse: [ typeAtIndex == objectMemory nilObject 
						ifTrue: [ 
							objectMemory storePointer: index ofObject: types withValue: assignedObjectClass. 
							typeNotStored := false ]
						ifFalse: [ index := index + 1 ]]]]]

	
]

{ #category : #printing }
StackWithLiveTypingInterpreter >> printHello [
	<inline: false>
	
	self cCode: 'printf("hello!!");'.

]

{ #category : #'return bytecodes' }
StackWithLiveTypingInterpreter >> returnFalse [
	localReturnValue := objectMemory falseObject.
	self keepReturnObjectType.
	self commonReturn
]

{ #category : #'return bytecodes' }
StackWithLiveTypingInterpreter >> returnNil [
	localReturnValue := objectMemory nilObject.
	self keepReturnObjectType.
	self commonReturn
]

{ #category : #'return bytecodes' }
StackWithLiveTypingInterpreter >> returnNilFromBlock [

	"Return nil to the caller of the current block activation."
	localReturnValue := objectMemory nilObject.
	self keepReturnObjectType.
	self commonCallerReturn
]

{ #category : #'return bytecodes' }
StackWithLiveTypingInterpreter >> returnReceiver [

	localReturnValue := self receiver.
	self keepReturnObjectType.
	self commonReturn
]

{ #category : #'return bytecodes' }
StackWithLiveTypingInterpreter >> returnTopFromBlock [

	"Return top-of-stack to the caller of the current block activation."
	localReturnValue := self internalStackTop.
	" I don't have to keep the return of a block because it will be added
	as method return - Hernan
	self keepReturnObjectType."
	self commonCallerReturn
]

{ #category : #'return bytecodes' }
StackWithLiveTypingInterpreter >> returnTopFromMethod [

	localReturnValue := self internalStackTop.
	self keepReturnObjectType.
	self commonReturn
]

{ #category : #'return bytecodes' }
StackWithLiveTypingInterpreter >> returnTrue [

	localReturnValue := objectMemory trueObject.
	self keepReturnObjectType.
	self commonReturn
]

{ #category : #'stack bytecodes' }
StackWithLiveTypingInterpreter >> storeAndPopReceiverVariableBytecode [
	| rcvr top instVarIndex |
	
	rcvr := self receiver.
	top := self internalStackTop.
	instVarIndex := currentBytecode bitAnd: 7.
	self internalPop: 1.
	objectMemory
		storePointerImmutabilityCheck: instVarIndex
		ofObject: rcvr
		withValue: top.
	self fetchNextBytecode.

	self keepInstanceVariableTypeInformationFor: top in: rcvr at: instVarIndex.
]

{ #category : #'stack bytecodes' }
StackWithLiveTypingInterpreter >> storeAndPopTemporaryVariableBytecode [
	<expandCases>
	
	self
		cCode: "this bytecode will be expanded so that refs to currentBytecode below will be constant"
			[self fetchNextBytecode.
			 self keepTypeAndSetTemporary: (currentBytecode bitAnd: 7) in: localFP put: self internalStackTop.
			 self internalPop: 1]
		inSmalltalk: "Interpreter version has fetchNextBytecode out of order"
			[self keepTypeAndSetTemporary: (currentBytecode bitAnd: 7) in: localFP put: self internalStackTop.
			 self fetchNextBytecode.
			 self internalPop: 1]
]

{ #category : #'stack bytecodes' }
StackWithLiveTypingInterpreter >> storeRemoteTemp: index inVectorAt: tempVectorIndex [
	| tempVector value frameMethod additionalMethodState remoteVectorTypes |
	
	tempVector := self temporary: tempVectorIndex in: localFP.
	TempVectReadBarrier
		ifTrue: 
			[(objectMemory isForwarded: tempVector) ifTrue:
				[tempVector := self unfollowTempVector: tempVector atIndex: tempVectorIndex in: localFP]].
	value := self internalStackTop.
	objectMemory storePointer: index ofObject: tempVector withValue: value.

	frameMethod := self frameMethod: localFP.
	additionalMethodState := self additionalMethodStateOf: frameMethod.
	additionalMethodState = objectMemory nilObject ifFalse: [ 
		remoteVectorTypes := objectMemory followObjField: 4 ofObject: additionalMethodState.
		self keepTypeInformationIn: remoteVectorTypes at: index for: value ]
]
