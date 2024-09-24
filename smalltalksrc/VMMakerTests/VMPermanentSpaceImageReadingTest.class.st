Class {
	#name : #VMPermanentSpaceImageReadingTest,
	#superclass : #VMAbstractImageFormatTest,
	#category : #'VMMakerTests-PermSpace'
}

{ #category : #utilities }
VMPermanentSpaceImageReadingTest >> loadImage [

	| memoryClass isa |
	environmentBuilder := VMSimulatedEnvironmentBuilder new.


	memoryClass := self wordSize = 4 
		ifTrue: [ Spur32BitCoMemoryManager simulatorClass ]	
		ifFalse: [ Spur64BitCoMemoryManager simulatorClass ].


	isa := self wordSize = 4 ifTrue: [ #'ARMv5' ] ifFalse: [ #aarch64 ].

	environmentBuilder 
		interpreterClass: CogVMSimulatorLSB;
		objectMemoryClass: memoryClass;
	 	initializationOptions: { 
			#BytesPerWord. self wordSize.
			#ObjectMemory. memoryClass name.
			#ISA. isa };
		wordSize: self wordSize;
		useComposedImageFormatAsDefault: useComposedImageFormat.

	environmentBuilder doBuildSimulator.

	interpreter := environmentBuilder interpreter.
	memory := environmentBuilder objectMemory.
	
	interpreter openOn: self imageFileName extraMemory: 0.

]

{ #category : #initialization }
VMPermanentSpaceImageReadingTest >> setUp [

	super setUp.
	
	memory garbageCollectForSnapshot.

	self assert: interpreter successful.


]

{ #category : #tests }
VMPermanentSpaceImageReadingTest >> testLoadingImageHasEmptyPermSpaceWhenImageDoesNotHave [

	self saveImage.	
	self loadImage.
				
	self assert: memory getMemoryMap permSpaceStart equals: 0.
	self assert: memory permSpaceFreeStart equals: 0.
]
