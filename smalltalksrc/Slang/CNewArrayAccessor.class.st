Class {
	#name : #CNewArrayAccessor,
	#superclass : #CArrayAccessor,
	#instVars : [
		'address'
	],
	#category : #'Slang-Types'
}

{ #category : #accessing }
CNewArrayAccessor >> address [

	^ address
]

{ #category : #accessing }
CNewArrayAccessor >> address: anObject [

	address := anObject
]

{ #category : #accessing }
CNewArrayAccessor >> asInteger [
	
	^ address
]

{ #category : #accessing }
CNewArrayAccessor >> at: index [

	^ object byteAt: index + 1
]
