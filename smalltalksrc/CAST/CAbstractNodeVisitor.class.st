Class {
	#name : #CAbstractNodeVisitor,
	#superclass : #Object,
	#category : #'CAST-Visitor'
}

{ #category : #generated }
CAbstractNodeVisitor >> visitAbstract: anAbstract [
	^ self visitSmaCCParseNode: anAbstract
]

{ #category : #generated }
CAbstractNodeVisitor >> visitAbstractDeclarator: anAbstractDeclarator [
	^ self visitAbstract: anAbstractDeclarator
]

{ #category : #generated }
CAbstractNodeVisitor >> visitArray: anArray [
	^ self visitAbstract: anArray
]

{ #category : #generated }
CAbstractNodeVisitor >> visitArrayDeclarator: anArrayDeclarator [
	^ self visitAbstract: anArrayDeclarator
]

{ #category : #generated }
CAbstractNodeVisitor >> visitArrow: anArrow [
	^ self visitAbstract: anArrow
]

{ #category : #generated }
CAbstractNodeVisitor >> visitAssignment: anAssignment [
	^ self visitAbstract: anAssignment
]

{ #category : #generated }
CAbstractNodeVisitor >> visitBinary: aBinary [
	^ self visitAbstract: aBinary
]

{ #category : #generated }
CAbstractNodeVisitor >> visitBreakStatement: aBreakStatement [
	^ self visitAbstract: aBreakStatement
]

{ #category : #generated }
CAbstractNodeVisitor >> visitCall: aCall [
	^ self visitAbstract: aCall
]

{ #category : #generated }
CAbstractNodeVisitor >> visitCastExpression: aCastExpression [
	^ self visitAbstract: aCastExpression
]

{ #category : #generated }
CAbstractNodeVisitor >> visitCompoundStatement: aCompoundStatement [
	^ self visitAbstract: aCompoundStatement
]

{ #category : #generated }
CAbstractNodeVisitor >> visitConstant: aConstant [
	^ self visitAbstract: aConstant
]

{ #category : #generated }
CAbstractNodeVisitor >> visitContinueStatement: aContinueStatement [
	^ self visitAbstract: aContinueStatement
]

{ #category : #generated }
CAbstractNodeVisitor >> visitDeclaration: aDeclaration [
	^ self visitAbstract: aDeclaration
]

{ #category : #generated }
CAbstractNodeVisitor >> visitDeclarator: aDeclarator [
	^ self visitAbstract: aDeclarator
]

{ #category : #generated }
CAbstractNodeVisitor >> visitDecrement: aDecrement [
	^ self visitAbstract: aDecrement
]

{ #category : #generated }
CAbstractNodeVisitor >> visitDoStatement: aDoStatement [
	^ self visitAbstract: aDoStatement
]

{ #category : #generated }
CAbstractNodeVisitor >> visitEnum: anEnum [
	^ self visitAbstract: anEnum
]

{ #category : #generated }
CAbstractNodeVisitor >> visitEnumerator: anEnumerator [
	^ self visitAbstract: anEnumerator
]

{ #category : #generated }
CAbstractNodeVisitor >> visitExpression: anExpression [
	^ self visitAbstract: anExpression
]

{ #category : #generated }
CAbstractNodeVisitor >> visitExpressionStatement: anExpressionStatement [
	^ self visitAbstract: anExpressionStatement
]

{ #category : #generated }
CAbstractNodeVisitor >> visitForStatement: aForStatement [
	^ self visitAbstract: aForStatement
]

{ #category : #generated }
CAbstractNodeVisitor >> visitFunctionDeclarator: aFunctionDeclarator [
	^ self visitAbstract: aFunctionDeclarator
]

{ #category : #generated }
CAbstractNodeVisitor >> visitFunctionDefinition: aFunctionDefinition [
	^ self visitAbstract: aFunctionDefinition
]

{ #category : #generated }
CAbstractNodeVisitor >> visitFunctionPointerDeclarator: aFunctionPointerDeclarator [
	^ self visitAbstract: aFunctionPointerDeclarator
]

{ #category : #generated }
CAbstractNodeVisitor >> visitGotoStatement: aGotoStatement [
	^ self visitAbstract: aGotoStatement
]

{ #category : #generated }
CAbstractNodeVisitor >> visitIdentifier: anIdentifier [
	^ self visitAbstract: anIdentifier
]

{ #category : #generated }
CAbstractNodeVisitor >> visitIdentifierExpression: anIdentifierExpression [
	^ self visitAbstract: anIdentifierExpression
]

{ #category : #generated }
CAbstractNodeVisitor >> visitIncrement: anIncrement [
	^ self visitAbstract: anIncrement
]

{ #category : #generated }
CAbstractNodeVisitor >> visitInitDeclarator: anInitDeclarator [
	^ self visitAbstract: anInitDeclarator
]

{ #category : #generated }
CAbstractNodeVisitor >> visitInitializer: anInitializer [
	^ self visitAbstract: anInitializer
]

{ #category : #generated }
CAbstractNodeVisitor >> visitLabeledStatement: aLabeledStatement [
	^ self visitAbstract: aLabeledStatement
]

{ #category : #generated }
CAbstractNodeVisitor >> visitParameterDeclaration: aParameterDeclaration [
	^ self visitAbstract: aParameterDeclaration
]

{ #category : #generated }
CAbstractNodeVisitor >> visitParenthesizedExpression: aParenthesizedExpression [
	^ self visitAbstract: aParenthesizedExpression
]

{ #category : #generated }
CAbstractNodeVisitor >> visitPoint: aPoint [
	^ self visitAbstract: aPoint
]

{ #category : #generated }
CAbstractNodeVisitor >> visitReturnStatement: aReturnStatement [
	^ self visitAbstract: aReturnStatement
]

{ #category : #generated }
CAbstractNodeVisitor >> visitSelectionStatement: aSelectionStatement [
	^ self visitAbstract: aSelectionStatement
]

{ #category : #generated }
CAbstractNodeVisitor >> visitStringLiteral: aStringLiteral [
	^ self visitAbstract: aStringLiteral
]

{ #category : #generated }
CAbstractNodeVisitor >> visitStructDeclaration: aStructDeclaration [
	^ self visitAbstract: aStructDeclaration
]

{ #category : #generated }
CAbstractNodeVisitor >> visitStructDeclarator: aStructDeclarator [
	^ self visitAbstract: aStructDeclarator
]

{ #category : #generated }
CAbstractNodeVisitor >> visitStructOrUnionSpecifier: aStructOrUnionSpecifier [
	^ self visitAbstract: aStructOrUnionSpecifier
]

{ #category : #generated }
CAbstractNodeVisitor >> visitSwitchStatement: aSwitchStatement [
	^ self visitAbstract: aSwitchStatement
]

{ #category : #generated }
CAbstractNodeVisitor >> visitTernary: aTernary [
	^ self visitAbstract: aTernary
]

{ #category : #generated }
CAbstractNodeVisitor >> visitTranslationUnit: aTranslationUnit [
	^ self visitAbstract: aTranslationUnit
]

{ #category : #generated }
CAbstractNodeVisitor >> visitTypeName: aTypeName [
	^ self visitAbstract: aTypeName
]

{ #category : #generated }
CAbstractNodeVisitor >> visitTypename: aTypename [
	^ self visitAbstract: aTypename
]

{ #category : #generated }
CAbstractNodeVisitor >> visitUnaryOperator: anUnaryExpression [
	^ self visitAbstract: anUnaryExpression
]

{ #category : #generated }
CAbstractNodeVisitor >> visitWhileStatement: aWhileStatement [
	^ self visitAbstract: aWhileStatement
]
