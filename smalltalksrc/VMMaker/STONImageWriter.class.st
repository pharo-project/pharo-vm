Class {
	#name : #STONImageWriter,
	#superclass : #AbstractImageAccess,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #writing }
STONImageWriter >> writeHeader: header toFile: f [

	STON writer
		on: f;
		nextPut: header
]
