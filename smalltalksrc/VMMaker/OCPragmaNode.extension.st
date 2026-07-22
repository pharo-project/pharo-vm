Extension { #name : 'OCPragmaNode' }

{ #category : '*VMMaker' }
OCPragmaNode >> isTypeDefinition [

	^ #( #var:type: #var:declareC: ) includes: self selector
]
