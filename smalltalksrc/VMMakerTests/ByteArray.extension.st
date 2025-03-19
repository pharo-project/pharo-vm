Extension { #name : 'ByteArray' }

{ #category : '*VMMakerTests' }
ByteArray >> forMemory: aMemory inMethod: anObject [

	^ aMemory newByteArrayWith: (self collect: [ :anElement | 
			   anElement forMemory: aMemory inMethod: nil ])
]
