Extension { #name : 'RBPragmaNode' }

{ #category : '*VMMaker' }
RBPragmaNode >> isTypeDefinition [

	^ #( #var:type: #var:declareC: ) includes: self selector
]
