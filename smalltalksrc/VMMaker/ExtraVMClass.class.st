Class {
	#name : 'ExtraVMClass',
	#superclass : 'VMClass',
	#category : 'VMMaker-Core',
	#package : 'VMMaker',
	#tag : 'Core'
}

{ #category : 'translation' }
ExtraVMClass class >> sourceFileName [

	^ #'extra.c'
]

{ #category : 'accessing - structure variables' }
ExtraVMClass >> f [

	<api>
	^ 42
]
