Class {
	#name : 'MachineSimulatorMemoryManager',
	#superclass : 'SlangMemoryManager',
	#instVars : [
		'machineSimulator'
	],
	#category : 'VMMaker-JITSimulation',
	#package : 'VMMaker',
	#tag : 'JITSimulation'
}

{ #category : 'accessing' }
MachineSimulatorMemoryManager >> machineSimulator: anUnicornARMv8Simulator [ 
	machineSimulator := anUnicornARMv8Simulator
]

{ #category : 'allocating' }
MachineSimulatorMemoryManager >> registerNewRegion: newMemoryRegion size: desiredSize address: allocatedAddress [

	super registerNewRegion: newMemoryRegion size: desiredSize address: allocatedAddress.
	
	machineSimulator ifNotNil: [ 
		machineSimulator mapMemory: newMemoryRegion memory at: allocatedAddress ].
]
