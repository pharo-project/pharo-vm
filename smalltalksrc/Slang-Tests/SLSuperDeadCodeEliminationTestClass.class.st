Class {
	#name : 'SLSuperDeadCodeEliminationTestClass',
	#superclass : 'SlangStructType',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'helpers' }
SLSuperDeadCodeEliminationTestClass >> method: arg [

]

{ #category : 'redundant-local-definition' }
SLSuperDeadCodeEliminationTestClass >> methodWithToDo: var [

	var = 1 ifTrue: [ 1 to: 5 do: [ :index | self method: index ] ]
]
