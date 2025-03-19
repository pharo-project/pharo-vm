Class {
	#name : 'UnicornTimeout',
	#superclass : 'Error',
	#instVars : [
		'target'
	],
	#category : 'VMMakerTests-Unicorn',
	#package : 'VMMakerTests',
	#tag : 'Unicorn'
}

{ #category : 'accessing' }
UnicornTimeout >> target [
	^ target
]

{ #category : 'accessing' }
UnicornTimeout >> target: anObject [
	target := anObject
]
