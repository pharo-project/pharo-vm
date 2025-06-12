Extension { #name : #NonInteractiveTranscript }

{ #category : #'*VMMakerCompatibilityForPharo8' }
NonInteractiveTranscript >> crtab [
	self critical: [stream crtab]
]

{ #category : #'*VMMakerCompatibilityForPharo8' }
NonInteractiveTranscript >> ensureCr [
	self nextPut: Character cr
]

{ #category : #'*VMMakerCompatibilityForPharo8' }
NonInteractiveTranscript >> next: anInteger put: anObject [
	self critical: [stream next: anInteger put: anObject]
]
