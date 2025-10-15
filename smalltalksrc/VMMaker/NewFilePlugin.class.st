Class {
	#name : 'NewFilePlugin',
	#superclass : 'InterpreterPlugin',
	#category : 'VMMaker-Plugins',
	#package : 'VMMaker',
	#tag : 'Plugins'
}

{ #category : 'testing' }
NewFilePlugin >> hasHeaderFile [
	"If there is a single intrinsic header file to be associated with the plugin, here is where you want to flag"
	^true
]

{ #category : 'testing' }
NewFilePlugin >> requiresCrossPlatformFiles [
	"this plugin requires cross platform files in order to work"
	^true
]

{ #category : 'testing' }
NewFilePlugin >> requiresPlatformFiles [
	"this plugin requires platform specific files in order to work"
	^true
]
