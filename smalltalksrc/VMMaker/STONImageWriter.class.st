Class {
	#name : #STONImageWriter,
	#superclass : #AbstractSTONImageAccess,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #writing }
STONImageWriter >> writeHeader: header toFile: f [

	STON writer
		on: f;
		nextPut: header
]

{ #category : #api }
STONImageWriter >> writeImageFile: imageFileName fromHeader: header [

	(self headerFileName: imageFileName) asFileReference writeStreamDo: [ :file | 
		self writeHeader: header toFile: file ].

	self flag: #TODO "Save segments"
]
