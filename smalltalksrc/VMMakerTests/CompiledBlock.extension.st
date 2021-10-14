Extension { #name : #CompiledBlock }

{ #category : #'*VMMakerTests' }
CompiledBlock >> forMethodBuilder: aBuilder [

	^ aBuilder newCompiledBlockBuilder
		fillFromPharoMethod: self;
		build
]
