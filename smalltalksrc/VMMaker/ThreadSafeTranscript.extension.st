Extension { #name : #ThreadSafeTranscript }

{ #category : #'*VMMaker' }
ThreadSafeTranscript >> closed [
	
	^ false
]

{ #category : #'*VMMaker' }
ThreadSafeTranscript >> isBinary [
	
	^ false
]

{ #category : #'*VMMaker' }
ThreadSafeTranscript >> newLine [
	
	self cr
]
