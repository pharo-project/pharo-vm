Class {
	#name : #VMTrace,
	#superclass : #Object,
	#instVars : [
		'messageNodes'
	],
	#category : #'VMMaker-Tools'
}

{ #category : #private }
VMTrace class >> loadFrom: fileReference [

	| lines messagesData messageNodes |
	lines := Character lf asString split: fileReference contents.
	1halt.
	messagesData := (lines reject: [ :line| (line beginsWith: '#######:<---->') or: [ line beginsWith: '#######: ' ] ]) select: [ :line | line includesSubstring: '<---->' ].
	messageNodes := messagesData collect: [ :data | (data copyReplaceAll: '#######:' with: '') copyReplaceAll: '<---->' with: ' lookupSelector: #' ] .
	
	^ messageNodes collect: [ :message | Smalltalk compiler evaluate: message ]
	
"	^ self new
		  messages: messageNodes;
		  yourself"
]

{ #category : #'as yet unclassified' }
VMTrace class >> supportedJITCompilationMethods: supportedBytecodes [

	| compiledMethods |
	compiledMethods := OrderedCollection new.

	Smalltalk allClassesDo: [ :c |
		c methodsDo: [ :m |
			m isPrimitive ifFalse: [
				(m bytecodes allSatisfy: [ :bytecode |
					 supportedBytecodes includes: bytecode ]) ifTrue: [
					compiledMethods add: m ] ] ] ].

	^ compiledMethods
]

{ #category : #accessing }
VMTrace >> messages: aCollection [ 

	messageNodes := aCollection 
]

{ #category : #query }
VMTrace >> onlyClasses: clases [

	| newMessageNodes |
	newMessageNodes := messageNodes select: [ :node |
		                   clases includes: node methodNode methodClass ].

	^ self class new
		  messages: newMessageNodes;
		  yourself
]
