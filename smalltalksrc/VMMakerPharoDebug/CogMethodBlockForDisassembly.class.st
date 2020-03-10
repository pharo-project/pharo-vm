Class {
	#name : #CogMethodBlockForDisassembly,
	#superclass : #Object,
	#instVars : [
		'labelMap',
		'pc',
		'startpc',
		'machineCode'
	],
	#category : #VMMakerPharoDebug
}

{ #category : #accessing }
CogMethodBlockForDisassembly >> labelMap [
	^ labelMap
]

{ #category : #accessing }
CogMethodBlockForDisassembly >> labelMap: anObject [
	labelMap := anObject
]

{ #category : #accessing }
CogMethodBlockForDisassembly >> machineCode [
	^ machineCode
]

{ #category : #accessing }
CogMethodBlockForDisassembly >> machineCode: anObject [
	machineCode := anObject
]

{ #category : #accessing }
CogMethodBlockForDisassembly >> pc [
	^ pc
]

{ #category : #accessing }
CogMethodBlockForDisassembly >> pc: anObject [
	pc := anObject
]

{ #category : #accessing }
CogMethodBlockForDisassembly >> startpc [
	^ startpc
]

{ #category : #accessing }
CogMethodBlockForDisassembly >> startpc: anObject [
	startpc := anObject
]
