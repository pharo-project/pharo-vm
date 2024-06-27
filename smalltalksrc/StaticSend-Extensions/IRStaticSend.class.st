Class {
	#name : #IRStaticSend,
	#superclass : #IRInstruction,
	#instVars : [
		'calledMethod'
	],
	#category : #'StaticSend-Extensions'
}

{ #category : #visiting }
IRStaticSend >> accept: aVisitor [
	^ aVisitor visitStaticSend: self
]

{ #category : #accessing }
IRStaticSend >> calledMethod [

	^ calledMethod
]

{ #category : #accessing }
IRStaticSend >> calledMethod: anObject [

	calledMethod := anObject
]
