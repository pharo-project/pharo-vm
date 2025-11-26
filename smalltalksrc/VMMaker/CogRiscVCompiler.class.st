Class {
	#name : 'CogRiscVCompiler',
	#superclass : 'CogAbstractInstruction',
	#category : 'VMMaker-JIT',
	#package : 'VMMaker',
	#tag : 'JIT'
}

{ #category : 'testing' }
CogRiscVCompiler class >> isAbstract [
	^ self == CogRiscVCompiler 
]
