Class {
	#name : #AbstractSTONImageAccess,
	#superclass : #AbstractImageAccess,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #'file operations' }
AbstractSTONImageAccess >> headerFileName: imageFileName [

	self flag: #TODO.
	^ imageFileName", '/header.ston'"
]
