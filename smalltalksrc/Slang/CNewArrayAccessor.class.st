Class {
	#name : #CNewArrayAccessor,
	#superclass : #Object,
	#instVars : [
		'address',
		'manager'
	],
	#category : #'Slang-Types'
}

{ #category : #'instance creation' }
CNewArrayAccessor class >> on: anInteger manager: aVMMemoryManager [ 
	
	^ self new
		address: anInteger;
		manager: aVMMemoryManager;
		yourself
]

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
CNewArrayAccessor >> manager [

	^ manager
]

{ #category : #accessing }
CNewArrayAccessor >> manager: anObject [

	manager := anObject
]
