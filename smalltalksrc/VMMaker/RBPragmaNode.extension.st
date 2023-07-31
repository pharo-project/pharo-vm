Extension { #name : #RBPragmaNode }

{ #category : #'*VMMaker' }
RBPragmaNode >> isTypeDefinition [

	^ self selector = #var:type:
]
