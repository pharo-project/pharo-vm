Class {
	#name : #SpurByteLayout,
	#superclass : #SpurLayout,
	#category : #'VMMaker-Tools-ImageInspector'
}

{ #category : #accessing }
SpurByteLayout >> asLocalByteArray [
	| localByteArray |
	localByteArray := ByteArray new: self byteSize .
	1 to: localByteArray size do: [ :i |
		localByteArray byteAt: i put: (self at: i).
	].
	^ localByteArray
]

{ #category : #accessing }
SpurByteLayout >> at: anInteger [ 
	
	" ToDo: consider inst vars "
	| slotIndex byteIndex |
	slotIndex := (anInteger - 1) // self wordSize .
	byteIndex := (anInteger - 1) %  self wordSize .
	^ (self slotAt: slotIndex + 1) at: byteIndex + 1
]

{ #category : #accessing }
SpurByteLayout >> objectPrintOn: aStream [
	aStream nextPutAll: self object asLocalByteArray asString
]

{ #category : #accessing }
SpurByteLayout >> slotAt: anInteger [ 
	
	| bodyAddress |
	self assert: anInteger > 0 description: 'Index must be greater than 0'.
	self assert: self numberOfSlots >= anInteger description: 'Index Out of Bounds'.

	bodyAddress := self address + self headerSize + ((anInteger - 1) * self wordSize).
	
	^ self memory copyFrom: bodyAddress to: bodyAddress + self wordSize + (0 - 1) 
	
]
