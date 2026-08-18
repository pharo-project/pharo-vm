Extension { #name : 'OCLiteralValueNode' }

{ #category : '*Slang' }
OCLiteralValueNode >> isConstantNumber [
	^value isNumber
]

{ #category : '*Slang' }
OCLiteralValueNode >> isNodeNil [
	^value == nil
]
