Class {
	#name : #VMImageReadingTest,
	#superclass : #VMAbstractImageFormatTest,
	#instVars : [
		'originalNilObjectIdentityHash'
	],
	#category : #'VMMakerTests-ImageFormat'
}

{ #category : #utilities }
VMImageReadingTest >> loadImage [

	environmentBuilder := VMSimulatedEnvironmentBuilder new.
	environmentBuilder 
		interpreterClass: self interpreterClass;
		objectMemoryClass: self memoryClass;
	 	initializationOptions: self initializationOptions;
		wordSize: self wordSize;
		initialCodeSize: self initialCodeSize; 
		primitiveTraceLogSize: self primitiveTraceLogSize.

	environmentBuilder build.

	interpreter := environmentBuilder interpreter.
	memory := environmentBuilder objectMemory.
	
	interpreter openOn: self imageFileName extraMemory: 0.

]

{ #category : #initialization }
VMImageReadingTest >> setUp [

	super setUp.

	memory garbageCollectForSnapshot.

	self assert: interpreter successful.

	originalNilObjectIdentityHash := memory hashBitsOf: memory nilObject.
	
]

{ #category : #tests }
VMImageReadingTest >> testReadingSTONHeader [

	| headerStruct headerFile |

	imageReaderClass ~= ComposedImageReader ifTrue: [ ^ self skip ].

	self saveImage.	
	headerStruct := SpurImageHeaderStruct new.
	headerFile := (self imageFileName asFileReference  / 'header.ston') readStream.
	
	imageReader readSTONFrom: headerFile into: headerStruct .

	headerFile position: 0.

	self assert: (self stonPretty: headerStruct) equals: headerFile contents.
]

{ #category : #tests }
VMImageReadingTest >> testSavedImageSavesObject [
	
	self saveImage.	
	self loadImage.
		
	self assert: originalNilObjectIdentityHash equals: (memory hashBitsOf: memory nilObject).
]

{ #category : #tests }
VMImageReadingTest >> testSavingImageWithThreeSegmentsIsCorrectlySqueezed [
	
	| firstNewSegmentSize secondNewSegmentSize obj newObj originalObjHash |
	firstNewSegmentSize := memory growOldSpaceByAtLeast: 12 * 1024.
	secondNewSegmentSize := memory growOldSpaceByAtLeast: 12 * 1024.
	
	self assert: memory segmentManager numSegments equals: 3.

	self assert: (memory segmentManager segments at: 1) segSize equals: firstNewSegmentSize.
	self assert: (memory segmentManager segments at: 2) segSize equals: secondNewSegmentSize.

	obj := self newOldSpaceObjectWithSlots: (firstNewSegmentSize / 2) // memory wordSize.
	memory splObj: 4 put: obj. "Store object in SpecialObjects Array to keep it" 
	originalObjHash := memory hashBitsOf: obj.


	"Ensure the object is created in the last segment".
	self assert: obj > (memory segmentManager segments at: 2) segStart.
	self assert: obj < (memory segmentManager segments at: 2) segLimit.

	self saveImage.	

	self loadImage.

	self assert: memory segmentManager numSegments equals: 1.
	
	newObj := memory splObj: 4. 
	
	self assert: originalObjHash equals: (memory hashBitsOf: newObj).
]
