Class {
	#name : #SpurVariableLayout,
	#superclass : #SpurLayout,
	#category : #'VMMaker-Tools-ImageInspector'
}

{ #category : #'gt-inspector-extension' }
SpurVariableLayout >> allSlots [ 
	^ self object instanceVariables 
]

{ #category : #'gt-inspector-extension' }
SpurVariableLayout >> gtInspectorLayoutIn: composite [
	^ composite table
		title: 'Items';
		display: [ 
			self allSlots collectWithIndex: [ :slot :index | index -> slot  ] ];
		column: 'Index' evaluated: [:each |  each key ];
		column: 'Value' evaluated: [ :each | each value ];
		send: #value
]
