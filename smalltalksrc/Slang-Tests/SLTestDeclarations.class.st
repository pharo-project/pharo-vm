Class {
	#name : 'SLTestDeclarations',
	#superclass : 'SlangAbstractTestCase',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'running' }
SLTestDeclarations >> setUp [
	super setUp.
	ccg addClass: SLBasicTestDeclarationClass
]

{ #category : 'tests' }
SLTestDeclarations >> testAllLocalsReturnsBlockLocals [

	self
		assertCollection: (ccg methodNamed: #methodWithBlockLocalDeclaration) allLocals
		hasSameElements: #( var )
]

{ #category : 'tests' }
SLTestDeclarations >> testBlockLocalsAreHoisted [

	self
		assertCollection: (ccg methodNamed: #methodWithBlockLocalDeclaration) locals
		hasSameElements: #(var)
]

{ #category : 'tests' }
SLTestDeclarations >> testDefaultTypeOfVariableNotInScope [

	self assert: (ccg typeOfVariable: #var) isNil
]

{ #category : 'tests' }
SLTestDeclarations >> testDefineGlobalVariable [

	ccg var: 'var' declareC: 'int var'.
	self assert: (ccg typeOfVariable: #var) equals: 'int'
]

{ #category : 'tests' }
SLTestDeclarations >> testLocalVariableWithDeclaration [

	| type method |
	method := ccg methodNamed: #methodWithLocalWithDeclaration.
	method recordDeclarationsIn: ccg.
	ccg
		pushScope: method
		while: [
			type := ccg typeOfVariable: #var ].
	self assert: type equals: 'toto'
]

{ #category : 'tests' }
SLTestDeclarations >> testLocalVariableWithoutDeclaration [

	| type |
	ccg
		pushScope: (ccg methodNamed: #methodWithLocal)
		while: [ type := ccg typeOfVariable: #var ].
	self assert: type isNil
]

{ #category : 'tests' }
SLTestDeclarations >> testLocalsReturnsDirectLocals [

	self
		assertCollection: (ccg methodNamed: #methodWithLocal) locals
		hasSameElements: #( 'var' )
]
