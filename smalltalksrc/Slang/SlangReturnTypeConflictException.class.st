Class {
	#name : #SlangReturnTypeConflictException,
	#superclass : #SlangTyperException,
	#category : #Slang
}

{ #category : #exceptions }
SlangReturnTypeConflictException class >> signalConflictIn: aMethod with: aCollectionOfType [

	| message |
	message := String streamContents: [ :s |
		           s nextPutAll: 'conflicting return types '.
		           aCollectionOfType
			           do: [ :t | s nextPutAll: t ]
			           separatedBy: [ s nextPutAll: ', ' ].
		           s
			           nextPutAll: ' in ';
			           nextPutAll: aMethod definingClass name;
			           nextPutAll: ' >> ';
			           nextPutAll: aMethod selector;
			           cr ].
	self signal: message
]
