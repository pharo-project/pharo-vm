Extension { #name : 'ThreadSafeTranscript' }

{ #category : '*VMMaker' }
ThreadSafeTranscript >> closed [
	
	^ false
]

{ #category : '*VMMaker' }
ThreadSafeTranscript >> isBinary [
	
	^ false
]

{ #category : '*VMMaker' }
ThreadSafeTranscript >> newLine [
	
	self cr
]

{ #category : '*VMMaker-Simulation-accessing' }
ThreadSafeTranscript >> next: anInteger put: anObject [

	self critical: [stream next: anInteger put: anObject]
]
