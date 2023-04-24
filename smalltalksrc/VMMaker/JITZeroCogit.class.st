Class {
	#name : #JITZeroCogit,
	#superclass : #DruidMirrorCogit,
	#category : #'VMMaker-JIT'
}

{ #category : #constants }
JITZeroCogit class >> bytecodeTable [

	^ {
		  #( 1 0 223 unknownBytecode ).
		  #( 2 224 247 unknownBytecode ).
		  #( 3 248 255 unknownBytecode ) }
]

{ #category : #'class initialization' }
JITZeroCogit class >> primitiveTableArray [
	"Only keeps mandatory entries. All marked as non implemented."

	^ super primitiveTableArray
		  select: [ :entry | entry size > 3 and: [ entry fourth = #maycallback ] ]
		  thenCollect: [ :entry |
		  entry copyReplaceFrom: 2 to: 2 with: { #genNonImplementedPrimitive } ]
]
