Extension { #name : #ThreadSafeTranscript }

{ #category : #'*VMMaker' }
ThreadSafeTranscript >> closed [
	
	^ false
]

{ #category : #'*VMMaker' }
ThreadSafeTranscript >> fflush [

	<doNotGenerate>
	self flush
]

{ #category : #'*VMMaker' }
ThreadSafeTranscript >> isBinary [
	
	^ false
]

{ #category : #'*VMMaker' }
ThreadSafeTranscript >> newLine [
	
	self cr
]
