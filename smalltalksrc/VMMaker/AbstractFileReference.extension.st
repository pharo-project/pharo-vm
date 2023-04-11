Extension { #name : #AbstractFileReference }

{ #category : #'*VMMaker' }
AbstractFileReference >> hasChildrenMatching: patterns [

	^ (self childrenMatching: patterns) isNotEmpty
]
