Class {
	#name : #VMSTONImageHeaderWritingTest,
	#superclass : #VMSpurImageHeaderWritingTest,
	#category : #'VMMakerTests-MemoryTests'
}

{ #category : #initialization }
VMSTONImageHeaderWritingTest >> headerFileName [

	^ 'header.ston'
]

{ #category : #initialization }
VMSTONImageHeaderWritingTest >> readHeader [

	| header |
	
	header := self headerFileName asFileReference readStreamDo: [ :f | 
		          imageReader readHeaderFrom: f startingAt: 0 ].
	
	^ header
]

{ #category : #initialization }
VMSTONImageHeaderWritingTest >> saveImage [

	| imageWriter |

	imageWriter := STONImageWriter
		               newWithMemory: memory
		               andInterpreter: interpreter.

	self headerFileName asFileReference writeStreamDo: [ :file | 
		imageWriter writeHeader: interpreter newHeader toFile: file ]
]

{ #category : #initialization }
VMSTONImageHeaderWritingTest >> setUp [

	super setUp.

	imageReader := STONImageReader newWithMemory: memory andInterpreter: interpreter.

]
