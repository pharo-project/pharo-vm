Class {
	#name : 'CCodeGeneratorInlineAlwaysStrategy',
	#superclass : 'CCodeGeneratorAbsoluteInlineStrategy',
	#category : 'Slang-CodeGeneration',
	#package : 'Slang',
	#tag : 'CodeGeneration'
}

{ #category : 'testing' }
CCodeGeneratorInlineAlwaysStrategy >> isSelectiveInlineStrategy [

	^ false
]

{ #category : 'accessing' }
CCodeGeneratorInlineAlwaysStrategy >> nodeCountOfMethod: aTMethod [

	| nodeCount |
	nodeCount := 0.
	aTMethod parseTree nodesDo: [ :node | nodeCount := nodeCount + 1 ].
	^ nodeCount
]

{ #category : 'asserting' }
CCodeGeneratorInlineAlwaysStrategy >> shouldInlineMethod: aTMethod [ 

	^ (super shouldInlineMethod: aTMethod) and: [
			(self wantsInline: aTMethod)
				or: [ (self nodeCountOfMethod: aTMethod) < 40 ]]
]
