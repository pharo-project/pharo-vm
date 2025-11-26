Extension { #name : 'NonInteractiveTranscript' }

{ #category : '*VMMaker-Simulation' }
NonInteractiveTranscript >> next: anInteger put: anObject [

	self critical: [stream next: anInteger put: anObject]
]
