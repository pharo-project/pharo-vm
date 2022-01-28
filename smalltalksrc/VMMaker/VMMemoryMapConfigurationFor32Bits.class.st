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
