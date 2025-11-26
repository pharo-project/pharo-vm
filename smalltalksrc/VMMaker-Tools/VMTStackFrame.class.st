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
