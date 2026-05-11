Extension { #name : 'OCLiteralValueNode' }

<<<<<<<< HEAD:smalltalksrc/Slang/OCLiteralValueNode.extension.st
{ #category : '*VMMakerCompatibilityForPharo6-testing' }
OCLiteralValueNode >> isConstantNumber [
	^value isNumber
]

{ #category : '*VMMakerCompatibilityForPharo6-testing' }
OCLiteralValueNode >> isNodeNil [
========
{ #category : '*Slang' }
RBLiteralValueNode >> isConstantNumber [
	^value isNumber
]

{ #category : '*Slang' }
RBLiteralValueNode >> isNodeNil [
>>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba:smalltalksrc/Slang/RBLiteralValueNode.extension.st
	^value == nil
]
