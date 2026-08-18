Extension { #name : 'StThreadSafeTranscript' }

{ #category : '*VMMaker' }
StThreadSafeTranscript >> next: anInteger put: anObject [ 

	anInteger timesRepeat: [ self nextPut: anObject ].
	^ anObject
]

{ #category : '*VMMaker' }
StThreadSafeTranscript >> print: anObject [

	self nextPutAll: anObject 
]
