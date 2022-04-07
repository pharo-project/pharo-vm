Class {
	#name : #VMMemoryMapConfigurationFor32Bits,
	#superclass : #VMMemoryMapConfiguration,
	#category : #'VMMaker-Memory'
}

{ #category : #'initial addresses' }
VMMemoryMapConfigurationFor32Bits >> codeZoneInitialAddress [

	^ 16r10000000 "(256 MB)"
]

{ #category : #'initial addresses' }
VMMemoryMapConfigurationFor32Bits >> newSpaceInitialAddress [

	^ 16r20000000 "(512 MB)"
]

{ #category : #'initial addresses' }
VMMemoryMapConfigurationFor32Bits >> oldSpaceInitialAddress [

	^ 16r40000000 "(1024 MB)"
]

{ #category : #'initial addresses' }
VMMemoryMapConfigurationFor32Bits >> permSpaceInitialAddress [

	^ 16r80000000 "(2048 MB)"
]

{ #category : #'initial addresses' }
VMMemoryMapConfigurationFor32Bits >> stackPagesInitialAddress [

	^ 16r0F000000 "(240 MB)"
]

{ #category : #accessing }
VMMemoryMapConfigurationFor32Bits >> wordSize [
	<doNotGenerate>
	^ 4
]
