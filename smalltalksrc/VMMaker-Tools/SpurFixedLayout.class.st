Class {
	#name : #SpurFixedLayout,
	#superclass : #SpurLayout,
	#category : #'VMMaker-Tools-imageInspector'
}

{ #category : #'gt-inspector-extension' }
SpurFixedLayout >> allSlots [ 
	^ (1 to: self object numberOfSlots) collect: [ :index | self object slotAt: index ]
]

{ #category : #'gt-inspector-extension' }
SpurFixedLayout >> gtInspectorLayoutIn: composite [
	^ composite table
		title: 'Inst Vars';
		display: [ 
			self allSlots collectWithIndex: [ :slot :index | index -> slot  ] ];
		column: 'Index' evaluated: [:each |  each key ];
		column: 'Value' evaluated: [ :each | each value ];
		send: #value
]
