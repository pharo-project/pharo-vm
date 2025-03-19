Class {
	#name : 'TDefineNode',
	#superclass : 'TConstantNode',
	#instVars : [
		'name'
	],
	#category : 'Slang-AST',
	#package : 'Slang',
	#tag : 'AST'
}

{ #category : 'instance creation' }
TDefineNode class >> named: aName [

	^ self new
		name: aName;
		yourself
]

{ #category : 'C code generation' }
TDefineNode >> asCASTIn: aBuilder [
	
	^ CConstantNode value: name
]

{ #category : 'accessing' }
TDefineNode >> constantNumbericValueOrNil [
	"Override so that named constants don't get elided."
	^nil
]

{ #category : 'testing' }
TDefineNode >> isDefine [

	^true
]

{ #category : 'comparing' }
TDefineNode >> isSameAs: aTParseNode [
	^self class == aTParseNode class
	  and: [name = aTParseNode nameOrValue]
]

{ #category : 'accessing' }
TDefineNode >> name [
	^name
]

{ #category : 'accessing' }
TDefineNode >> name: aName [
	name := aName
]

{ #category : 'accessing' }
TDefineNode >> nameOrValue [
	^name
]

{ #category : 'C code generation' }
TDefineNode >> printOn: aStream level: level [

	aStream nextPutAll: name
]

{ #category : 'accessing' }
TDefineNode >> setName: aName value: aValue [
	self name: aName.
	self setValue: aValue.
]
