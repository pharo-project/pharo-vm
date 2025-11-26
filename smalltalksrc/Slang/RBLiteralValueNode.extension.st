Extension { #name : 'RBLiteralValueNode' }

{ #category : '*Slang' }
RBLiteralValueNode >> isConstantNumber [
	^value isNumber
]

{ #category : '*Slang' }
RBLiteralValueNode >> isNodeNil [
	^value == nil
]
