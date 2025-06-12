Class {
	#name : #PrintfStringFormatDescriptor,
	#superclass : #PrintfFormatDescriptor,
	#instVars : [
		'widthDescriptor'
	],
	#category : #Printf
}

{ #category : #rendering }
PrintfStringFormatDescriptor >> applyOperator: object [
	^ object
]

{ #category : #printing }
PrintfStringFormatDescriptor >> printOn: aStream [
	super printOn: aStream.
	self printWidthOn: aStream.
	aStream nextPut: $s
]

{ #category : #printing }
PrintfStringFormatDescriptor >> printWidthOn: aStream [
	widthDescriptor
		ifNil: [super printWidthOn: aStream]
		ifNotNil: [aStream nextPutAll: '.*'.
				lengthModifier isCharacter ifTrue: [aStream nextPut: lengthModifier].
				lengthModifier isString ifTrue: [aStream nextPutAll: lengthModifier]]
]

{ #category : #accessing }
PrintfStringFormatDescriptor >> stringLength [
	^widthDescriptor
		ifNotNil: [:wd| wd value ifNil: [0]]
		ifNil: [super stringLength]
]

{ #category : #accessing }
PrintfStringFormatDescriptor >> widthDescriptor: aPrintfNumberFormatDescriptor [

	widthDescriptor := aPrintfNumberFormatDescriptor
]
