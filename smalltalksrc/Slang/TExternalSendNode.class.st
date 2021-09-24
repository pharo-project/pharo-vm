Class {
	#name : #TExternalSendNode,
	#superclass : #TParseNode,
	#instVars : [
		'sendNode',
		'variableBindings'
	],
	#category : #'Slang-AST'
}

{ #category : #accessing }
TExternalSendNode >> variableBindings: aCollection [
	
	variableBindings := aCollection 
]
