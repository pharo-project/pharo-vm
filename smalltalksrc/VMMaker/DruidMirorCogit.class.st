Class {
	#name : #DruidMirorCogit,
	#superclass : #StackToRegisterMappingCogit,
	#category : #'VMMaker-JIT'
}

{ #category : #initialization }
DruidMirorCogit class >> initializePrimitiveTable [

	<generated>
	MaxCompiledPrimitiveIndex := 10.
	primitiveTable := CArrayAccessor on:
		                  (Array new: MaxCompiledPrimitiveIndex + 1).
	self table: primitiveTable from: self primitiveTableArray
]

{ #category : #'class initialization' }
DruidMirorCogit class >> primitiveTableArray [

	^ DruidJIT primitiveTableArray collect: [ :tuple |
		  {
			  tuple first.
			  (tuple second copyReplaceAll: '_' with: '').
			  tuple third } ]
]
