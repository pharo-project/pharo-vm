"
I am a simulated memory manager that records the address of every integer write.
Tests use me to check which memory the VM writes, for example the perm space while loading an image.
"
Class {
	#name : 'VMWriteRecordingMemoryManager',
	#superclass : 'MachineSimulatorMemoryManager',
	#instVars : [
		'writtenAddresses'
	],
	#category : 'VMMakerTests-ImageFormat',
	#package : 'VMMakerTests',
	#tag : 'ImageFormat'
}

{ #category : 'memory-access' }
VMWriteRecordingMemoryManager >> writeInteger: aValue at: address size: size signed: aBoolean [

	writtenAddresses add: address.
	^ super writeInteger: aValue at: address size: size signed: aBoolean
]

{ #category : 'accessing' }
VMWriteRecordingMemoryManager >> writtenAddresses [

	^ writtenAddresses
]

{ #category : 'accessing' }
VMWriteRecordingMemoryManager >> writtenAddressesFrom: start to: end [

	^ writtenAddresses select: [ :each | each >= start and: [ each < end ] ]
]

{ #category : 'initialization' }
VMWriteRecordingMemoryManager >> initialize [

	super initialize.
	writtenAddresses := Set new
]
