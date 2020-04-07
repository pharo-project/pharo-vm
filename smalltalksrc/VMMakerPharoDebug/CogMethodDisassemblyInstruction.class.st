Class {
	#name : #CogMethodDisassemblyInstruction,
	#superclass : #Object,
	#instVars : [
		'pc',
		'label',
		'assembly',
		'size',
		'bytes'
	],
	#category : #'VMMakerPharoDebug-Disassembly'
}

{ #category : #accessing }
CogMethodDisassemblyInstruction >> assembly [
	^ assembly
]

{ #category : #accessing }
CogMethodDisassemblyInstruction >> assembly: anObject [
	assembly := anObject
]

{ #category : #accessing }
CogMethodDisassemblyInstruction >> bytes [
	^ bytes
]

{ #category : #accessing }
CogMethodDisassemblyInstruction >> bytes: anObject [
	bytes := anObject
]

{ #category : #accessing }
CogMethodDisassemblyInstruction >> label [
	^ label
]

{ #category : #accessing }
CogMethodDisassemblyInstruction >> label: anObject [
	label := anObject
]

{ #category : #accessing }
CogMethodDisassemblyInstruction >> pc [
	^ pc
]

{ #category : #accessing }
CogMethodDisassemblyInstruction >> pc: anObject [
	pc := anObject
]

{ #category : #accessing }
CogMethodDisassemblyInstruction >> size [
	^ size
]

{ #category : #accessing }
CogMethodDisassemblyInstruction >> size: anObject [
	size := anObject
]
