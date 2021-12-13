Class {
	#name : #ImageWriter,
	#superclass : #VMClass,
	#instVars : [
		'objectMemory',
		'interpreter'
	],
	#category : #'VMMaker-Support'
}

{ #category : #'instance creation' }
ImageWriter class >> newWithMemory: memory andInterpreter: anInterpreter [


	| imageWriter |
	imageWriter := self new.
	imageWriter objectMemory: memory.
	imageWriter interpreter: anInterpreter.
	^ imageWriter
]

{ #category : #accessing }
ImageWriter >> interpreter: anInterpreter [

	<doNotGenerate>
	interpreter := anInterpreter
]

{ #category : #accessing }
ImageWriter >> objectMemory: memory [

	<doNotGenerate>
	objectMemory := memory
]

{ #category : #writing }
ImageWriter >> putLong: aLong toFile: aFile [
	"Append aLong to aFile in this platform's 'natural' byte order.  aLong is either 32 or 64 bits,
	 depending on ObjectMemory.  (Bytes will be swapped, if necessary, when the image is read
	 on a different platform.) Set successFlag to false if the write fails."

	<var: #aLong type: #sqInt>
	<var: #aFile type: #sqImageFile>
	<inline: false>
	| objectsWritten |
	objectsWritten := self
						cCode: [self sq: (self addressOf: aLong) Image: (self sizeof: #sqInt) File: 1 Write: aFile]
						inSmalltalk:
							[| value |
							 value := aLong.
							 objectMemory wordSize timesRepeat:
								[aFile nextPut: (value bitAnd: 16rFF).
								 value := value >> 8].
							 1].
	interpreter success: objectsWritten = 1
]

{ #category : #writing }
ImageWriter >> putShort: aShort toFile: aFile [
	"Append the 16-bit aShort to aFile in this platform's 'natural' byte order.
	 (Bytes will be swapped, if necessary, when the image is read on a
	 different platform.) Set successFlag to false if the write fails."

	<var: #aShort type: #short>
	<var: #aFile type: #sqImageFile>
	<inline: false>
	| objectsWritten |
	objectsWritten := self
						cCode: [self sq: (self addressOf: aShort) Image: (self sizeof: #short) File: 1 Write: aFile]
						inSmalltalk:
							[aFile
								nextPut: (aShort bitAnd: 16rFF);
								nextPut: (aShort >> 8 bitAnd: 16rFF).
							 1].
	interpreter success: objectsWritten = 1
]

{ #category : #writing }
ImageWriter >> putWord32: aWord32 toFile: aFile [
	"Append aWord32 to aFile in this platform's 'natural' byte order.  aWord32 is 32 bits,
	 depending on ObjectMemory.  (Bytes will be swapped, if necessary, when the image is read
	 on a different platform.) Set successFlag to false if the write fails."

	<var: #aWord32 type: #int>
	<var: #aFile type: #sqImageFile>
	<inline: false>
	| objectsWritten |
	objectsWritten := self
						cCode: [self sq: (self addressOf: aWord32) Image: 4 File: 1 Write: aFile]
						inSmalltalk:
							[| value |
							 value := aWord32.
							 4 timesRepeat:
								[aFile nextPut: (value bitAnd: 16rFF).
								 value := value >> 8].
							 1].
	interpreter success: objectsWritten = 1
]

{ #category : #writing }
ImageWriter >> writeImageFile: header [

	"Write the image header and heap contents to imageFile for snapshot.
	 c.f. writeImageFileIO.  The game below is to maintain 64-bit alignment
	 for all putLong:toFile: occurrences."

	<doNotGenerate>
	| headerSize  |

	headerSize := header headerSize.

	interpreter imageName asFileReference binaryWriteStreamDo: [ :file | 
		self putWord32: header imageFormat toFile: file.
		self putWord32: headerSize toFile: file.

		{ 
			header dataSize.
			header oldBaseAddr.
			header initialSpecialObjectsOop.
			header hdrLastHash.
			header screenSize.
			header headerFlags 
		} do: [ :long | 
			self putLong: long toFile: file 
		].

		self putWord32: header extraVMMemory toFile: file.

		{ 
			header hdrNumStackPages.
			header hdrCogCodeSize 
		} do: [ :short | 
			self putShort: short toFile: file 
		].

		self putWord32: header hdrEdenBytes toFile: file.

		{ 
			header hdrMaxExtSemTabSize.
			0 
		} do: [ :short | 
			self putShort: short toFile: file 
		].

		objectMemory hasSpurMemoryManagerAPI
			ifTrue: [ 
				| bytesWritten |
				self putLong: header firstSegSize toFile: file.
				self putLong: header freeOldSpaceInImage toFile: file.
				
				2 timesRepeat: [ "Pad the rest of the header." 
					self putLong: 0 toFile: file ].
				objectMemory wordSize = 8 ifTrue: [ 
					3 timesRepeat: [ self putLong: 0 toFile: file ] ].

				self assert: file position = headerSize.
				"Position the file after the header."
				file position: headerSize.

				bytesWritten := objectMemory writeImageSegmentsToFile: file.
				self assert: bytesWritten = objectMemory imageSizeToWrite ]
			ifFalse: [ "Pad the rest of the header."
				4 timesRepeat: [ self putLong: 0 toFile: file ].
				objectMemory wordSize = 8 ifTrue: [ 
					3 timesRepeat: [ self putLong: 0 toFile: file ] ].

				self assert: file position = headerSize.
				"Position the file after the header."
				file position: headerSize.

				"Write the object memory."
				objectMemory baseAddressOfImage // 4 + 1 to:
				objectMemory baseAddressOfImage + objectMemory imageSizeToWrite
				// 4 do: [ :index | 
				self putLong: (objectMemory memory at: index) toFile: file ] ].

		interpreter success: true 
	]
]
