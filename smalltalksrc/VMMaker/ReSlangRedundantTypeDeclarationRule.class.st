Class {
	#name : 'ReSlangRedundantTypeDeclarationRule',
	#superclass : 'ReAbstractRule',
	#category : 'VMMaker-Slang',
	#package : 'VMMaker',
	#tag : 'Slang'
}

{ #category : 'testing - interest' }
ReSlangRedundantTypeDeclarationRule class >> checksNode [

	^ true
]

{ #category : 'running' }
ReSlangRedundantTypeDeclarationRule >> basicCheck: aNode [

	^ aNode isPragma and: [
		  aNode isTypeDefinition and: [
			  (aNode methodNode allDefinedVariables includes:
				  (aNode argumentAt: #var:) value) not ] ]
]

{ #category : 'accessing' }
ReSlangRedundantTypeDeclarationRule >> name [

	^ 'Type declaration for missing local'
]
