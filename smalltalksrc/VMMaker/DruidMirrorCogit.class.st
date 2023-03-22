Class {
	#name : #DruidMirrorCogit,
	#superclass : #StackToRegisterMappingCogit,
	#category : #'VMMaker-JIT'
}

{ #category : #initialization }
DruidMirrorCogit class >> initializePrimitiveTable [

	<generated>
	MaxCompiledPrimitiveIndex := 10.
	primitiveTable := CArrayAccessor on:
		                  (Array new: MaxCompiledPrimitiveIndex + 1).
	self table: primitiveTable from: self primitiveTableArray
]

{ #category : #'class initialization' }
DruidMirrorCogit class >> primitiveTableArray [

	^ DruidJIT primitiveTableArray collect: [ :tuple |
		  {
			  tuple first.
			  (tuple second copyReplaceAll: '_' with: '') asSymbol.
			  tuple third } ]
]
