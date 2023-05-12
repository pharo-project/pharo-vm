Class {
	#name : #CASTEqualityTests,
	#superclass : #TestCase,
	#category : #'CAST-Tests'
}

{ #category : #tests }
CASTEqualityTests >> testArrayDeclaratorNodeEquality [

	self
		assert: (CArrayDeclaratorNode identifier: 'aLiteralArray')
		equals: (CArrayDeclaratorNode identifier: 'aLiteralArray')
]

{ #category : #tests }
CASTEqualityTests >> testArrayDeclaratorNodeInEquality [

	self
		deny: (CArrayDeclaratorNode identifier: 'aLiteralArray')
		equals: (CArrayDeclaratorNode identifier: 'toto')
]

{ #category : #tests }
CASTEqualityTests >> testAssignmentNodeDefaultOperatorInEquality [

	self
		deny: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto')
			rvalue: (CConstantNode value: 2))
		equals: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto2')
			operator: '+='
			rvalue: (CConstantNode value: 2))
]

{ #category : #tests }
CASTEqualityTests >> testAssignmentNodeEquality [

	self
		assert: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto')
			rvalue: (CConstantNode value: 2))
		equals: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto')
			rvalue: (CConstantNode value: 2))
]

{ #category : #tests }
CASTEqualityTests >> testAssignmentNodeLvalueInEquality [

	self
		deny: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto')
			rvalue: (CConstantNode value: 2))
		equals: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto2')
			rvalue: (CConstantNode value: 2))
]

{ #category : #tests }
CASTEqualityTests >> testAssignmentNodeRvalueInEquality [

	self
		deny: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto')
			rvalue: (CConstantNode value: 2))
		equals: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto')
			rvalue: (CConstantNode value: 3))
]

{ #category : #tests }
CASTEqualityTests >> testAssignmentNodeWithSpecialAndDefaultOperatorEquality [

	self
		assert: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto')
			rvalue: (CConstantNode value: 2))
		equals: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto')
			operator: '='
			rvalue: (CConstantNode value: 2))
]

{ #category : #tests }
CASTEqualityTests >> testAssignmentNodeWithSpecialOperatorEquality [

	self
		assert: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto')
			operator: '+='
			rvalue: (CConstantNode value: 2))
		equals: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto')
			operator: '+='
			rvalue: (CConstantNode value: 2))
]

{ #category : #tests }
CASTEqualityTests >> testAssignmentNodeWithSpecialOperatorLvalueInEquality [

	self
		deny: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto')
			operator: '+='
			rvalue: (CConstantNode value: 2))
		equals: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto2')
			operator: '+='
			rvalue: (CConstantNode value: 2))
]

{ #category : #tests }
CASTEqualityTests >> testAssignmentNodeWithSpecialOperatorOperatorInEquality [

	self
		deny: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto')
			operator: '+='
			rvalue: (CConstantNode value: 2))
		equals: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto')
			operator: '='
			rvalue: (CConstantNode value: 3))
]

{ #category : #tests }
CASTEqualityTests >> testAssignmentNodeWithSpecialOperatorRvalueInEquality [

	self
		deny: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto')
			operator: '+='
			rvalue: (CConstantNode value: 2))
		equals: (CAssignmentNode
			lvalue: (CIdentifierNode name: 'toto')
			operator: '+='
			rvalue: (CConstantNode value: 3))
]

{ #category : #tests }
CASTEqualityTests >> testConstantNodeEquality [

	self
		assert: (CConstantNode value: 1)
		equals: (CConstantNode value: 1)
]

{ #category : #tests }
CASTEqualityTests >> testConstantNodeInEquality [

	self
		deny: (CConstantNode value: 1)
		equals: (CConstantNode value: 2)
]

{ #category : #tests }
CASTEqualityTests >> testGoToEquality [

	self
		assert: (CGotoStatementNode identifier: 'toto')
		equals: (CGotoStatementNode identifier: 'toto')
]

{ #category : #tests }
CASTEqualityTests >> testGoToInequality [

	self
		deny: (CGotoStatementNode identifier: 'tata')
		equals: (CGotoStatementNode identifier: 'toto')
]

{ #category : #tests }
CASTEqualityTests >> testIdentifierNodeEquality [

	self
		assert: (CIdentifierNode name: 'toto')
		equals: (CIdentifierNode name: 'toto')
]

{ #category : #tests }
CASTEqualityTests >> testIdentifierNodeInEquality [

	self
		deny: (CIdentifierNode name: 'toto')
		equals: (CIdentifierNode name: 'toto2')
]

{ #category : #tests }
CASTEqualityTests >> testInitDeclaratorNodeEquality [

	self
		assert: (CInitDeclaratorNode
			declarator: (CIdentifierNode name: 'toto')
			initializer: (CConstantNode value: '1'))
		equals: (CInitDeclaratorNode
			declarator: (CIdentifierNode name: 'toto')
			initializer: (CConstantNode value: '1'))
]

{ #category : #tests }
CASTEqualityTests >> testInitDeclaratorNodeWithDeclaratorInEquality [

	self
		deny: (CInitDeclaratorNode
			declarator: (CIdentifierNode name: 'toto')
			initializer: (CConstantNode value: '1'))
		equals: (CInitDeclaratorNode
			declarator: (CIdentifierNode name: 'toto2')
			initializer: (CConstantNode value: '1'))
]

{ #category : #tests }
CASTEqualityTests >> testInitDeclaratorNodeWithInitializerInEquality [

	self
		deny: (CInitDeclaratorNode
			declarator: (CIdentifierNode name: 'toto')
			initializer: (CConstantNode value: '1'))
		equals: (CInitDeclaratorNode
			declarator: (CIdentifierNode name: 'toto')
			initializer: (CConstantNode value: '2'))
]

{ #category : #tests }
CASTEqualityTests >> testInitializerNodeEquality [

	self
		assert: (CGLRInitializerNode initializers: { CConstantNode value: 1 })
		equals: (CGLRInitializerNode initializers: { CConstantNode value: 1 })
]

{ #category : #tests }
CASTEqualityTests >> testInitializerNodeInEquality [

	self
		deny: (CGLRInitializerNode initializers: { CConstantNode value: 1 })
		equals: (CGLRInitializerNode initializers: { CConstantNode value: 2 })
]
