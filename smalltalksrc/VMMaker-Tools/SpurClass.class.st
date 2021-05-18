Class {
	#name : #SpurClass,
	#superclass : #SpurObject,
	#category : #'VMMaker-Tools'
}

{ #category : #'accessing - instance variables' }
SpurClass >> allInstanceVariableNames [
	^ (1 to: self numberOfSlots) collect: [ :index | self slotAt: index ] .
]

{ #category : #'as yet unclassified' }
SpurClass >> classFormat [
	^ self slotAt: self slotIndexForClassFormat
]

{ #category : #accessing }
SpurClass >> className [ 
"We assume this is a byteSymbol here"
	^ self image printByteSymbol: (self slotAt: self slotIndexForClassName) 
	
	" ] on: Error 
		do: [ (self slotAt: self slotIndexForMetaclassSoleInstance ) asSpurClass className , ' class'] "
	
]

{ #category : #'gt-inspector-extension' }
SpurClass >> gtInspectorLayoutIn: composite [
	^ composite table
		title: 'asd';
		display: [ 
			{ 
			'self' -> self .
			'superclass' -> self spSuperclass  .    
			'format:' -> self classFormat .
			'instSpec' -> self instSpec .
			'instSize' -> self instSize} ];
		column: 'Key' evaluated: [:each |  each key ];
		column: 'Value' evaluated: [ :each | each value ];
		send: #value

]

{ #category : #'accessing-header' }
SpurClass >> instSize [
	"Answer the number of named instance variables
	(as opposed to indexed variables) of the receiver.
	 Above Cog Spur the class format is
		<5 bits inst spec><16 bits inst size>"
	^self classFormat bitAnd: 16rFFFF
]

{ #category : #'accessing-header' }
SpurClass >> instSpec [ 
	^ (self classFormat bitShift: -16) bitAnd: 16r1F
]

{ #category : #accessing }
SpurClass >> methodDictionary [

	^ SpurMethodDictionary on: (self slotAt: self slotIndexForMethodDictionary) address image: self image
]

{ #category : #'accessing - instance variables' }
SpurClass >> printOn: aStream [
	aStream nextPutAll: self className
	"aStream nextPutAll: self className"
	
]

{ #category : #constants }
SpurClass >> slotIndexForClassFormat [
	^ 3
]

{ #category : #constants }
SpurClass >> slotIndexForClassName [
	self flag: '4 for Candle'.
	^ "4" 7
]

{ #category : #constants }
SpurClass >> slotIndexForMetaclassInstanceVariableNames [	
	self flag: '5 for Candle'.
	^ "5" 0
]

{ #category : #constants }
SpurClass >> slotIndexForMetaclassSoleInstance [
	self flag: '4 for Candle'.
	
	^ "4" 6
]

{ #category : #constants }
SpurClass >> slotIndexForMethodDictionary [

	^ 2
]

{ #category : #constants }
SpurClass >> slotIndexForSuperclass [
	^ 1
]

{ #category : #accessing }
SpurClass >> spSuperclass [
	| superclassOrNil |
	superclassOrNil := self slotAt: self slotIndexForSuperclass.
	^ superclassOrNil spIsNil
		ifTrue: [ superclassOrNil ]
		ifFalse: [ superclassOrNil asSpurClass ]
]
