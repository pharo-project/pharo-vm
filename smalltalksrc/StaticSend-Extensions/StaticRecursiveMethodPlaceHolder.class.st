Class {
	#name : #StaticRecursiveMethodPlaceHolder,
	#superclass : #Object,
	#instVars : [
		'selector'
	],
	#category : #'StaticSend-Extensions'
}

{ #category : #accessing }
StaticRecursiveMethodPlaceHolder >> numArgs [
	
	^ selector numArgs
]

{ #category : #accessing }
StaticRecursiveMethodPlaceHolder >> selector: aString [ 
	selector := aString
]
