Extension { #name : 'OCLiteralValueNode' }

{ #category : '*VMMakerCompatibilityForPharo6-testing' }
OCLiteralValueNode >> isConstantNumber [
	^value isNumber
]

{ #category : '*VMMakerCompatibilityForPharo6-testing' }
OCLiteralValueNode >> isNodeNil [
	^value == nil
]
