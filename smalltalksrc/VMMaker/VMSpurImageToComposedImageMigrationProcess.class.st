Class {
	#name : #VMSpurImageToComposedImageMigrationProcess,
	#superclass : #Object,
	#instVars : [
		'interpreter',
		'memory'
	],
	#category : #'VMMaker-PermSpace'
}

{ #category : #migrate }
VMSpurImageToComposedImageMigrationProcess >> copyChangesFileFromImage: originalImageString to: newImageString [ 

	| originalImageFileReference originalChangesFileReference newImageFileReference newChangesFileReference |

	originalImageFileReference := originalImageString asFileReference.
	originalChangesFileReference := originalImageFileReference withExtension: 'changes'.
	
	originalChangesFileReference ifExists: [ 
		newImageFileReference := newImageString asFileReference.
		newChangesFileReference :=  newImageFileReference withExtension: 'changes'.
		newChangesFileReference ensureDelete.
		originalChangesFileReference copyTo: newChangesFileReference ].
]

{ #category : #migrate }
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

	environmentBuilder doBuildSimulator.

	interpreter := environmentBuilder interpreter.
	memory := environmentBuilder objectMemory.
]

{ #category : #migrate }
VMSpurImageToComposedImageMigrationProcess >> loadImage: originalImage [

	interpreter openOn: originalImage extraMemory: 0.


]

{ #category : #migrate }
VMSpurImageToComposedImageMigrationProcess >> migrate: originalImage to: newImage [

	self createSimulator.
	self loadImage: originalImage.
	self saveImage: newImage.

	self copyChangesFileFromImage: originalImage to: newImage 
]

{ #category : #migrate }
VMSpurImageToComposedImageMigrationProcess >> saveImage: newImage [

	interpreter imageName: newImage.
	interpreter writeImageFileIO
]
