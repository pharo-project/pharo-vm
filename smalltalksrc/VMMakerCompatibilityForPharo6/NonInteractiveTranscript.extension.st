Extension { #name : #NonInteractiveTranscript }

{ #category : #'*VMMakerCompatibilityForPharo6' }
NonInteractiveTranscript >> next: anInteger put: anObject [
	"This is supposed to be a fucking WriteStream.  Why am I doing donkey work like this??"
	self critical: [stream next: anInteger put: anObject]
]
