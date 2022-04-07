Class {
	#name : #VMSpurImageToComposedImageMigrationProcess,
	#superclass : #Object,
	#instVars : [
		'interpreter',
		'memory'
	],
	#category : #'VMMaker-PermSpace'
}

{ #category : #'as yet unclassified' }
VMSpurImageToComposedImageMigrationProcess >> createSimulator [

	| environmentBuilder memoryClass |
	environmentBuilder := VMSimulatedEnvironmentBuilder new.
	memoryClass := Spur64BitMemoryManager simulatorClass.

	environmentBuilder 
		interpreterClass: StackInterpreterSimulatorLSB;
		objectMemoryClass: memoryClass;
	 	initializationOptions: { 
			#BytesPerWord. 8.
			#ObjectMemory. memoryClass name.
		  	#ImageReader. SpurImageReader name.
		  	#ImageWriter. ComposedImageWriter name};
		wordSize: 8;
		initialCodeSize: 4*1024; 
		primitiveTraceLogSize: 0.

	environmentBuilder build.

	interpreter := environmentBuilder interpreter.
	memory := environmentBuilder objectMemory.
]

{ #category : #'as yet unclassified' }
VMSpurImageToComposedImageMigrationProcess >> loadImage: originalImage [

	interpreter openOn: originalImage extraMemory: 0.


]

{ #category : #'as yet unclassified' }
VMSpurImageToComposedImageMigrationProcess >> migrate: originalImage to: newImage [

	self createSimulator.
	self loadImage: originalImage.
	self saveImage: newImage.


]

{ #category : #'as yet unclassified' }
VMSpurImageToComposedImageMigrationProcess >> saveImage: newImage [

	interpreter imageName: newImage.
	interpreter writeImageFileIO.


]
