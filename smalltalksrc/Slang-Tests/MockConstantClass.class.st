Class {
	#name : 'MockConstantClass',
	#superclass : 'Object',
	#category : 'Slang-Tests',
	#package : 'Slang-Tests'
}

{ #category : 'accessing' }
MockConstantClass >> bindingOf: aString [ 
	
	"For compatibility, used by the code generator to lookup for constants"
	
	^ nil
]

{ #category : 'testing' }
MockConstantClass >> defineAtCompileTime: aString [ 
	
	^ false
]

{ #category : 'accessing' }
MockConstantClass >> innerBindingOf: aString [ 
	
	"For compatibility, used by the code generator to lookup for constants"
	
	^ nil
]
