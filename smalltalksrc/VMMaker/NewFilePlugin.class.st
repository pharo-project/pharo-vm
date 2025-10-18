"
I provide file system access via the new file library.
"
Class {
	#name : 'NewFilePlugin',
	#superclass : 'InterpreterPlugin',
	#category : 'VMMaker-Plugins',
	#package : 'VMMaker',
	#tag : 'Plugins'
}

{ #category : 'testing' }
NewFilePlugin class >> hasHeaderFile [
	"If there is a single intrinsic header file to be associated with the plugin, here is where you want to flag"
	^true
]

{ #category : 'testing' }
NewFilePlugin class >> requiresCrossPlatformFiles [
	"this plugin requires cross platform files in order to work"
	^true
]

{ #category : 'testing' }
NewFilePlugin class >> requiresPlatformFiles [
	"this plugin requires platform specific files in order to work"
	^true
]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveFileClose [
	<export: true>
	<var: 'filePointer' type: 'NewFile_t *'>
	
	| fileOop filePointer |
	fileOop := interpreterProxy stackValue: 0.
	interpreterProxy failed ifFalse: [
		filePointer := 	self pointerAtPointer: (interpreterProxy firstIndexableField: fileOop).
		self cCode: 'NewFile_close(filePointer)'
	].
	interpreterProxy failed ifFalse: [ interpreterProxy pop: 1  "pop file; leave rcvr on stack" ].
]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveFileOpen [
	<var: 'pathIndex' type: 'char *'>
	<var: 'filePointer' type: 'void *'>
	<export: true>
"primitiveOpen: path mode: mode creationDisposition: creationDisposition flags: flags
	"
	| pathPointer mode creationDisposition flags pathIndex filePointer fileOop pathSize |
	flags := interpreterProxy positive32BitValueOf: (interpreterProxy stackValue: 0).
	creationDisposition := interpreterProxy positive32BitValueOf: (interpreterProxy stackValue: 1).
	mode := interpreterProxy positive32BitValueOf: (interpreterProxy stackValue: 2).
	
	pathPointer := interpreterProxy stackValue: 3.
	(interpreterProxy isBytes: pathPointer)
		ifFalse: [^ interpreterProxy primitiveFail].
	pathIndex := interpreterProxy firstIndexableField: pathPointer.
	pathSize := interpreterProxy byteSizeOf: pathPointer.

	fileOop := interpreterProxy instantiateClass: interpreterProxy classExternalAddress indexableSize: BytesPerWord.
	
	filePointer := self cCode: 'NewFile_open(pathIndex, pathSize, mode, creationDisposition, flags)'.
	self pointerAtPointer: (interpreterProxy firstIndexableField: fileOop) put: filePointer.

	interpreterProxy failed
		ifFalse: [interpreterProxy methodReturnValue: fileOop]

]
