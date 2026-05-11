Class {
	#name : 'VMTStackFrame',
	#superclass : 'Object',
	#instVars : [
		'memory',
		'framePointer'
	],
	#category : 'VMMaker-Tools',
	#package : 'VMMaker-Tools'
}

{ #category : 'accessing' }
VMTStackFrame >> callerFP [
	^ self interpreter frameCallerFP: framePointer
]

{ #category : 'accessing' }
VMTStackFrame >> callerIP [
	^ self interpreter frameCallerSavedIP: framePointer
]

{ #category : 'accessing' }
VMTStackFrame >> descriptors [
	^ OrderedCollection new 
		add: #callerIP ->  self callerIP ;
		add: #callerFP -> self callerFP;
		add: #method -> self method;
		yourself
]

{ #category : 'accessing' }
VMTStackFrame >> framePointer [
	^ framePointer
]

{ #category : 'accessing' }
VMTStackFrame >> framePointer: anObject [
	framePointer := anObject
]

<<<<<<< HEAD
{ #category : 'debugging' }
VMTStackFrame >> gtStackFrameInspector: composite [
	<gtInspectorPresentationOrder: 0>
	^ composite fastTable
		title: 'StackFrame';
		display: [ :anObject | self descriptors ];
		column: 'Name' evaluated: [ :descriptor | descriptor name ];
		column: 'Value' evaluated: [ :descriptor | descriptor value ]
]

=======
>>>>>>> 0c6de9df559c3ee3416255822f6bc2cbe9d3cfba
{ #category : 'accessing' }
VMTStackFrame >> interpreter [
	^ memory coInterpreter
]

{ #category : 'accessing' }
VMTStackFrame >> memory [
	^ memory
]

{ #category : 'accessing' }
VMTStackFrame >> memory: anObject [
	memory := anObject
]

{ #category : 'accessing' }
VMTStackFrame >> method [
	^ self interpreter iframeMethod: framePointer
]
