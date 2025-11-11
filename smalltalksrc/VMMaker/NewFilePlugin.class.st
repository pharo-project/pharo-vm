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
NewFilePlugin >> primitiveDeleteFile [
	<var: 'pathIndex' type: 'char *'>
	<var: 'result' type: 'bool'>
	<export: true>
	| pathPointer pathIndex result pathSize |
	pathPointer := interpreterProxy stackValue: 0.
	(interpreterProxy isBytes: pathPointer)
		ifFalse: [^ interpreterProxy primitiveFail].
	pathIndex := interpreterProxy firstIndexableField: pathPointer.
	pathSize := interpreterProxy byteSizeOf: pathPointer.

	result := self cCode: 'NewFile_deleteFile(pathIndex, pathSize)'.

	interpreterProxy failed
		ifFalse: [interpreterProxy methodReturnBool: result]

]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveDirectoryClose [
	<export: true>
	<var: 'directoryPointer' type: 'NewDirectory_t *'>
	
	| directoryOop directoryPointer |
	directoryOop := interpreterProxy stackValue: 0.
	interpreterProxy failed ifFalse: [
		directoryPointer := self pointerAtPointer: (interpreterProxy firstIndexableField: directoryOop).
		self cCode: 'NewDirectory_close(directoryPointer)'
	].
	interpreterProxy failed ifFalse: [ interpreterProxy pop: 1  "pop directory; leave rcvr on stack" ].
]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveDirectoryCreate [
	<var: 'pathIndex' type: 'char *'>
	<var: 'result' type: 'bool'>
	<export: true>
	| pathPointer pathIndex result pathSize |
	pathPointer := interpreterProxy stackValue: 0.
	(interpreterProxy isBytes: pathPointer)
		ifFalse: [^ interpreterProxy primitiveFail].
	pathIndex := interpreterProxy firstIndexableField: pathPointer.
	pathSize := interpreterProxy byteSizeOf: pathPointer.

	result := self cCode: 'NewDirectory_create(pathIndex, pathSize)'.

	interpreterProxy failed
		ifFalse: [interpreterProxy methodReturnBool: result]

]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveDirectoryNext [
	<export: true>
	<var: 'directoryPointer' type: 'NewDirectory_t *'>
	<var: 'stringPointer' type: 'char *'>
	
	| directoryOop directoryPointer stringOop stringPointer|
	directoryOop := interpreterProxy stackValue: 0.
	stringOop := interpreterProxy instantiateClass: interpreterProxy classExternalAddress indexableSize: BytesPerWord.
	interpreterProxy failed ifFalse: [
		directoryPointer := self pointerAtPointer: (interpreterProxy firstIndexableField: directoryOop).
		stringPointer := self cCode: 'NewDirectory_next(directoryPointer)'.
		self pointerAtPointer: (interpreterProxy firstIndexableField: stringOop) put: stringPointer.
	].
	interpreterProxy failed ifFalse: [ interpreterProxy methodReturnValue: stringOop ].
]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveDirectoryOpen [
	<var: 'pathIndex' type: 'char *'>
	<var: 'directoryPointer' type: 'void *'>
	<export: true>
"primitiveOpen: path mode: mode creationDisposition: creationDisposition flags: flags
	"
	| pathPointer pathIndex directoryPointer directoryOop pathSize |
	pathPointer := interpreterProxy stackValue: 0.
	(interpreterProxy isBytes: pathPointer)
		ifFalse: [^ interpreterProxy primitiveFail].
	pathIndex := interpreterProxy firstIndexableField: pathPointer.
	pathSize := interpreterProxy byteSizeOf: pathPointer.

	directoryOop := interpreterProxy instantiateClass: interpreterProxy classExternalAddress indexableSize: BytesPerWord.
	
	directoryPointer := self cCode: 'NewDirectory_open(pathIndex, pathSize)'.
	self pointerAtPointer: (interpreterProxy firstIndexableField: directoryOop) put: directoryPointer.

	interpreterProxy failed
		ifFalse: [interpreterProxy methodReturnValue: directoryOop]

]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveDirectoryRemoveEmpty [
	<var: 'pathIndex' type: 'char *'>
	<var: 'result' type: 'bool'>
	<export: true>
	| pathPointer pathIndex result pathSize |
	pathPointer := interpreterProxy stackValue: 0.
	(interpreterProxy isBytes: pathPointer)
		ifFalse: [^ interpreterProxy primitiveFail].
	pathIndex := interpreterProxy firstIndexableField: pathPointer.
	pathSize := interpreterProxy byteSizeOf: pathPointer.

	result := self cCode: 'NewDirectory_removeEmpty(pathIndex, pathSize)'.

	interpreterProxy failed
		ifFalse: [interpreterProxy methodReturnBool: result]

]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveDirectoryRewind [
	<export: true>
	<var: 'directoryPointer' type: 'NewDirectory_t *'>
	
	| directoryOop directoryPointer |
	directoryOop := interpreterProxy stackValue: 0.
	interpreterProxy failed ifFalse: [
		directoryPointer := self pointerAtPointer: (interpreterProxy firstIndexableField: directoryOop).
		self cCode: 'NewDirectory_rewind(directoryPointer)'
	].
	interpreterProxy failed ifFalse: [ interpreterProxy pop: 1  "pop directory; leave rcvr on stack" ].
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
NewFilePlugin >> primitiveFileGetSize [
	<export: true>
	<var: 'filePointer' type: 'NewFile_t *'>
	<var: 'fileSize' type: 'sqLong'>
	
	| fileOop filePointer fileSize |
	fileOop := interpreterProxy stackValue: 0.
	interpreterProxy failed ifFalse: [
		filePointer := 	self pointerAtPointer: (interpreterProxy firstIndexableField: fileOop).
		fileSize := self cCode: 'NewFile_getSize(filePointer)'
	].
	interpreterProxy failed ifFalse: [ interpreterProxy methodReturnValue: (interpreterProxy signed64BitIntegerFor: fileSize)].
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

{ #category : 'file primitives' }
NewFilePlugin >> primitiveFileReadInto [
	<export: true>
	<var: 'filePointer' type: 'NewFile_t *'>
	<var: 'bufferPointer' type: 'void*'>
	<var: 'readResult' type: 'sqLong'>
	
	| fileOop filePointer readSize bufferOffset bufferOop bufferPointer readResult |
	readSize := interpreterProxy positiveMachineIntegerValueOf: (interpreterProxy stackValue: 0).
	bufferOffset := interpreterProxy positiveMachineIntegerValueOf: (interpreterProxy stackValue: 1).
	bufferOop := interpreterProxy stackValue: 2.
	fileOop := interpreterProxy stackValue: 3.

	interpreterProxy failed ifFalse: [
		bufferPointer := interpreterProxy firstIndexableField: bufferOop.
		filePointer := 	self pointerAtPointer: (interpreterProxy firstIndexableField: fileOop).
		readResult := self cCode: 'NewFile_read(filePointer, bufferPointer, bufferOffset, readSize)'
	].
	interpreterProxy failed ifFalse: [ interpreterProxy methodReturnValue: (interpreterProxy signed64BitIntegerFor: readResult)].
]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveFileReadIntoAtFileOffset [
	<export: true>
	<var: 'filePointer' type: 'NewFile_t *'>
	<var: 'bufferPointer' type: 'void*'>
	<var: 'readResult' type: 'sqLong'>
	
	| fileOop filePointer fileOffset readSize bufferOffset bufferOop bufferPointer readResult |
	fileOffset := interpreterProxy positive64BitValueOf: (interpreterProxy stackValue: 0).
	readSize := interpreterProxy positiveMachineIntegerValueOf: (interpreterProxy stackValue: 1).
	bufferOffset := interpreterProxy positiveMachineIntegerValueOf: (interpreterProxy stackValue: 2).
	bufferOop := interpreterProxy stackValue: 3.
	fileOop := interpreterProxy stackValue: 4.

	interpreterProxy failed ifFalse: [
		bufferPointer := interpreterProxy firstIndexableField: bufferOop.
		filePointer := 	self pointerAtPointer: (interpreterProxy firstIndexableField: fileOop).
		readResult := self cCode: 'NewFile_readAtOffset(filePointer, bufferPointer, bufferOffset, readSize, fileOffset)'
	].
	interpreterProxy failed ifFalse: [ interpreterProxy methodReturnValue: (interpreterProxy signed64BitIntegerFor: readResult)].
]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveFileSeek [
	<export: true>
	<var: 'filePointer' type: 'NewFile_t *'>
	
	| fileOop filePointer seekMode seekOffset |
	seekMode := interpreterProxy positive32BitValueOf: (interpreterProxy stackValue: 0).
	seekOffset := interpreterProxy signed64BitValueOf: (interpreterProxy stackValue: 1).
	fileOop := interpreterProxy stackValue: 2.
	interpreterProxy failed ifFalse: [
		filePointer := 	self pointerAtPointer: (interpreterProxy firstIndexableField: fileOop).
		self cCode: 'NewFile_seek(filePointer, seekOffset, seekMode)'
	].
	interpreterProxy failed ifFalse: [ interpreterProxy pop: 3  "pop seek mode, offset and file; leave rcvr on stack"].
]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveFileTell [
	<export: true>
	<var: 'filePointer' type: 'NewFile_t *'>
	<var: 'fileSize' type: 'sqLong'>
	
	| fileOop filePointer fileSize |
	fileOop := interpreterProxy stackValue: 0.
	interpreterProxy failed ifFalse: [
		filePointer := 	self pointerAtPointer: (interpreterProxy firstIndexableField: fileOop).
		fileSize := self cCode: 'NewFile_tell(filePointer)'
	].
	interpreterProxy failed ifFalse: [ interpreterProxy methodReturnValue: (interpreterProxy signed64BitIntegerFor: fileSize)].
]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveFileTruncate [
	<export: true>
	<var: 'filePointer' type: 'NewFile_t *'>
	<var: 'result' type: 'bool'>
	
	| fileOop filePointer newFileSize result |
	newFileSize := interpreterProxy positive64BitValueOf: (interpreterProxy stackValue: 0).
	fileOop := interpreterProxy stackValue: 1.
	interpreterProxy failed ifFalse: [
		filePointer := 	self pointerAtPointer: (interpreterProxy firstIndexableField: fileOop).
		result := self cCode: 'NewFile_truncate(filePointer, newFileSize)'
	].
	interpreterProxy failed ifFalse: [ interpreterProxy methodReturnBool: result ].
]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveFileWriteFrom [
	<export: true>
	<var: 'filePointer' type: 'NewFile_t *'>
	<var: 'bufferPointer' type: 'void*'>
	<var: 'writeResult' type: 'sqLong'>
	
	| fileOop filePointer writeSize bufferOffset bufferOop bufferPointer writeResult |
	writeSize := interpreterProxy positiveMachineIntegerValueOf: (interpreterProxy stackValue: 0).
	bufferOffset := interpreterProxy positiveMachineIntegerValueOf: (interpreterProxy stackValue: 1).
	bufferOop := interpreterProxy stackValue: 2.
	fileOop := interpreterProxy stackValue: 3.

	interpreterProxy failed ifFalse: [
		bufferPointer := interpreterProxy firstIndexableField: bufferOop.
		filePointer := 	self pointerAtPointer: (interpreterProxy firstIndexableField: fileOop).
		writeResult := self cCode: 'NewFile_write(filePointer, bufferPointer, bufferOffset, writeSize)'
	].
	interpreterProxy failed ifFalse: [ interpreterProxy methodReturnValue: (interpreterProxy signed64BitIntegerFor: writeResult)].
]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveFileWriteFromAtFileOffset [
	<export: true>
	<var: 'filePointer' type: 'NewFile_t *'>
	<var: 'bufferPointer' type: 'void*'>
	<var: 'writeResult' type: 'sqLong'>
	
	| fileOop filePointer fileOffset writeSize bufferOffset bufferOop bufferPointer writeResult |
	fileOffset := interpreterProxy positive64BitValueOf: (interpreterProxy stackValue: 0).
	writeSize := interpreterProxy positiveMachineIntegerValueOf: (interpreterProxy stackValue: 1).
	bufferOffset := interpreterProxy positiveMachineIntegerValueOf: (interpreterProxy stackValue: 2).
	bufferOop := interpreterProxy stackValue: 3.
	fileOop := interpreterProxy stackValue: 4.

	interpreterProxy failed ifFalse: [
		bufferPointer := interpreterProxy firstIndexableField: bufferOop.
		filePointer := 	self pointerAtPointer: (interpreterProxy firstIndexableField: fileOop).
		writeResult := self cCode: 'NewFile_writeAtOffset(filePointer, bufferPointer, bufferOffset, writeSize, fileOffset)'
	].
	interpreterProxy failed ifFalse: [ interpreterProxy methodReturnValue: (interpreterProxy signed64BitIntegerFor: writeResult)].
]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveIsAvailable [
	<export: true>
	interpreterProxy failed ifFalse: [ interpreterProxy methodReturnValue: (interpreterProxy trueObject)].
]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveMemoryMapWithProtection [
	<export: true>
	<var: 'filePointer' type: 'NewFile_t *'>
	<var: 'memoryMappedPointer' type: 'void *'>
	
	| fileOop filePointer protectionFlags memoryMappedPointer memoryMappedPointerOop |
	protectionFlags := interpreterProxy positive32BitValueOf:(interpreterProxy stackValue: 0).
	fileOop := interpreterProxy stackValue: 1.
	memoryMappedPointerOop := interpreterProxy instantiateClass: interpreterProxy classExternalAddress indexableSize: BytesPerWord.
	interpreterProxy failed ifFalse: [
		filePointer := 	self pointerAtPointer: (interpreterProxy firstIndexableField: fileOop).
		memoryMappedPointer := self cCode: 'NewFile_memoryMap(filePointer, protectionFlags)'.
		self pointerAtPointer: (interpreterProxy firstIndexableField: memoryMappedPointerOop) put: memoryMappedPointer.
	].
	interpreterProxy failed ifFalse: [ interpreterProxy methodReturnValue: memoryMappedPointerOop ].
]

{ #category : 'file primitives' }
NewFilePlugin >> primitiveMemoryUnmap [
	<export: true>
	<var: 'filePointer' type: 'NewFile_t *'>
	
	| fileOop filePointer |
	fileOop := interpreterProxy stackValue: 0.
	interpreterProxy failed ifFalse: [
		filePointer := 	self pointerAtPointer: (interpreterProxy firstIndexableField: fileOop).
		self cCode: 'NewFile_memoryUnmap(filePointer)'
	].
	interpreterProxy failed ifFalse: [ interpreterProxy pop: 1  "pop file; leave rcvr on stack" ].
]
