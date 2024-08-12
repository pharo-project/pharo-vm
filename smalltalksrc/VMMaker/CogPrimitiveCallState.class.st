Class {
	#name : 'CogPrimitiveCallState',
	#superclass : 'VMStructType',
	#instVars : [
		'jmpToFallbackCode',
		'jmpSamplePrim',
		'continuePostSamplePrim',
		'jmpSampleNonPrim',
		'continuePostSampleNonPrim'
	],
	#category : 'VMMaker-JIT',
	#package : 'VMMaker',
	#tag : 'JIT'
}

{ #category : 'simulation only' }
CogPrimitiveCallState class >> byteSizeForSimulator: aCogit [

	"Answer an approximation of the byte size of an AbstractInstruction struct.
	 This is for estimating the alloca in allocateOpcodes:bytecodes:ifFail:"
	^self instSize * (aCogit sizeof: #'void *')
]

{ #category : 'translation' }
CogPrimitiveCallState class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	"enumerate aBinaryBlock with the names and C type strings for the inst vars to include in a struct of this type."

	<var: #jmpToFallbackCode type: #'AbstractInstruction *'>
	<var: #jmpSamplePrim type: #'AbstractInstruction *'>
	<var: #jmpSampleNonPrim type: #'AbstractInstruction *'>
	<var: #continuePostSamplePrim type: #'AbstractInstruction *'>
	<var: #continuePostSampleNonPrim type: #'AbstractInstruction *'>

	self filteredInstVarNames do:
		[:ivn|
		aBinaryBlock
			value: ivn
			value: (ivn caseOf: {
						['jmpToFallbackCode']					-> [#'AbstractInstruction *'].
						['jmpSamplePrim']						-> [#'AbstractInstruction *'].
						['jmpSampleNonPrim']					-> [#'AbstractInstruction *'].
						['continuePostSamplePrim']			-> [#'AbstractInstruction *'].
						['continuePostSampleNonPrim']		-> [#'AbstractInstruction *'].
				} otherwise: [ self halt ])]
]

{ #category : 'accessing' }
CogPrimitiveCallState >> continuePostSampleNonPrim [

	^ continuePostSampleNonPrim
]

{ #category : 'accessing' }
CogPrimitiveCallState >> continuePostSampleNonPrim: anObject [

	continuePostSampleNonPrim := anObject
]

{ #category : 'accessing' }
CogPrimitiveCallState >> continuePostSamplePrim [

	^ continuePostSamplePrim
]

{ #category : 'accessing' }
CogPrimitiveCallState >> continuePostSamplePrim: anObject [

	continuePostSamplePrim := anObject
]

{ #category : 'accessing' }
CogPrimitiveCallState >> jmpSampleNonPrim [

	^ jmpSampleNonPrim
]

{ #category : 'accessing' }
CogPrimitiveCallState >> jmpSampleNonPrim: anObject [

	jmpSampleNonPrim := anObject
]

{ #category : 'accessing' }
CogPrimitiveCallState >> jmpSamplePrim [

	^ jmpSamplePrim
]

{ #category : 'accessing' }
CogPrimitiveCallState >> jmpSamplePrim: anObject [

	jmpSamplePrim := anObject
]

{ #category : 'accessing' }
CogPrimitiveCallState >> jmpToFallbackCode [

	^ jmpToFallbackCode
]

{ #category : 'accessing' }
CogPrimitiveCallState >> jmpToFallbackCode: anObject [

	jmpToFallbackCode := anObject
]
