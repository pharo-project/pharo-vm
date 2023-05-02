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

{ #category : #private }
VMTrace class >> loadGCLogFrom: fileReference [

	| lines messagesData messageNodes |
	lines := '---' split: fileReference contents.
	^ lines allButLast collect: [ :ston | STON fromString: ston ]
]

{ #category : #'as yet unclassified' }
VMTrace class >> plotScavenge: scavengesAndFullGCs [

	| chart plot y scavenges fullGCs tenures |
	scavenges := scavengesAndFullGCs select: [ :e |
		             e className includesSubstring: 'Scavenge' ].
	fullGCs := scavengesAndFullGCs select: [ :e |
		           e className includesSubstring: 'FullGC' ].
	tenures := scavenges collect: [ :e | e tTenureThreshold ].

	y := scavenges collect: [ :e | e eSurvivorBytes ].


	chart := RSChart new.

	plot := RSLinePlot new
		        color: Color black;
		        x: (1 to: scavenges size) y: y.

	chart addPlot: plot.

	tenures doWithIndex: [ :bytes :i |
		bytes > 0 ifTrue: [
			chart addPlot: (RSScatterPlot new x: { i } y: { bytes }) ] ].


	chart addDecoration: (RSHorizontalTick new
			 numberOfTicks: 10;
			 labelConversion: [ :e | e asInteger printString ];
			 yourself).
	chart addDecoration: (RSVerticalTick new
			 numberOfTicks: 10;
			 labelConversion: [ :e | e asInteger humanReadableByteSizeString ];
			 yourself).

	fullGCs doWithIndex: [ :e :i |
		| x |
		x := (scavengesAndFullGCs indexOf: e) - i + 1.
		chart addDecoration:
			((RSXMarkerDecoration new atValue: x) color: Color red) ].


	^ chart build
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
