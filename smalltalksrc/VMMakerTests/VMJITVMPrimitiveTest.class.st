Class {
	#name : 'VMJITVMPrimitiveTest',
	#superclass : 'VMSimpleStackBasedCogitAbstractTest',
	#category : 'VMMakerTests-JitTests',
	#package : 'VMMakerTests',
	#tag : 'JitTests'
}

{ #category : 'tests - primitiveMethodXray' }
VMJITVMPrimitiveTest >> setUp [

	super setUp.

	self setUpTrampolines.
	self setUpCogMethodEntry.
	self createBaseFrame
]

{ #category : 'tests - primitiveMethodXray' }
VMJITVMPrimitiveTest >> testPrimitiveMethodXRayPreviouslyCompiledFramelessMethod [

	| methodToXray target |
	
	"This test is only valid as far as the method is the same.
	It should be a method with so many literals that the compiler does not even try to compile it."
	target := (SlangBasicTranslationTestClass>>#first:second:).
	self assert: target bytecodes hash equals: 245997176.
	
	methodToXray := self jitMethod: target.
	interpreter push: methodToXray methodObject.

	interpreter primitiveMethodXray.

	"Are the third lowest bits turned on?"
	self assert: ((memory integerValueOf: interpreter stackTop) anyMask: 2r0111)
]

{ #category : 'tests - primitiveMethodXray' }
VMJITVMPrimitiveTest >> testPrimitiveMethodXRayShouldCompile [

	| methodToXray target |
	
	"This test is only valid as far as the method is the same.
	It should be a method with so many literals that the compiler does not even try to compile it."
	target := (SlangBasicTranslationTestClass>>#methodDefiningSingleExternVariable).
	self assert: target bytecodes hash equals: 222697369.
	
	methodToXray := self createMethodOopFromHostMethod: target.
	interpreter push: methodToXray.
	
	interpreter primitiveMethodXray.

	"Is the lowest bit turned on?"
	self assert: ((memory integerValueOf: interpreter stackTop) anyMask: 2r0001)
]

{ #category : 'tests - primitiveMethodXray' }
VMJITVMPrimitiveTest >> testPrimitiveMethodXRayShouldNotCompile [

	| methodToXray target |
	
	"This test is only valid as far as the method is the same.
	It should be a method with so many literals that the compiler does not even try to compile it."
	target := (CogARMv8Compiler class>>#initialize).
	self assert: target bytecodes hash equals: 46085044.
	
	methodToXray := self createMethodOopFromHostMethod: target.
	interpreter push: methodToXray.
	
	interpreter primitiveMethodXray.

	self assert: interpreter stackTop equals: (memory integerObjectOf: 0)
]

{ #category : 'tests - primitiveMethodXray' }
VMJITVMPrimitiveTest >> testPrimitiveMethodXRayWasCompiled [

	| methodToXray target |
	
	"This test is only valid as far as the method is the same.
	It should be a method with so many literals that the compiler does not even try to compile it."
	target := (SlangBasicTranslationTestClass>>#methodDefiningSingleExternVariable).
	self assert: target bytecodes hash equals: 222697369.
	
	methodToXray := self jitMethod: target.
	interpreter push: methodToXray methodObject.
	
	interpreter primitiveMethodXray.

	"Is the second lowest bit turned off"
	self assert: ((memory integerValueOf: interpreter stackTop) anyMask: 2r0010)
]

{ #category : 'tests - primitiveMethodXray' }
VMJITVMPrimitiveTest >> testPrimitiveMethodXRayWasNotCompiled [

	| methodToXray target |
	
	"This test is only valid as far as the method is the same.
	It should be a method with so many literals that the compiler does not even try to compile it."
	target := (SlangBasicTranslationTestClass>>#methodDefiningSingleExternVariable).
	self assert: target bytecodes hash equals: 222697369.
	
	methodToXray := self createMethodOopFromHostMethod: target.
	interpreter push: methodToXray.

	interpreter primitiveMethodXray.

	"Is the second lowest bit turned off"
	self deny: ((memory integerValueOf: interpreter stackTop) anyMask: 2r0010)
]
