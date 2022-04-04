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
		  	#ImageReader. imageReaderClass name.
		  	#ImageWriter. imageWriterClass name.
			#ISA. isa };
		wordSize: self wordSize;
		initialCodeSize: 4*1024; 
		primitiveTraceLogSize: self primitiveTraceLogSize.

	environmentBuilder build.

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
VMPermanentSpaceImageReadingTest >> testLoadingImageCreatesPermSpace [

	self saveImage.	
	self loadImage.
		
	self halt.
]
