Class {
	#name : #VMMemoryMapConfigurationFor64Bits,
	#superclass : #VMMemoryMapConfiguration,
	#category : #'VMMaker-Memory'
}

{ #category : #'initial addresses' }
VMMemoryMapConfigurationFor64Bits >> codeZoneInitialAddress [

	^ 16r240000000 "9GB"
]

{ #category : #'initial addresses' }
VMMemoryMapConfigurationFor64Bits >> newSpaceInitialAddress [

	^ 16r280000000 "10GB"
]

{ #category : #'initial addresses' }
VMMemoryMapConfigurationFor64Bits >> oldSpaceInitialAddress [

	^ 16r10000000000 "1024GB"
]

{ #category : #'initial addresses' }
VMMemoryMapConfigurationFor64Bits >> permSpaceInitialAddress [

	^ 16r20000000000 "2048GB"
]

{ #category : #'initial addresses' }
VMMemoryMapConfigurationFor64Bits >> stackPagesInitialAddress [

	^ 16r200000000 "8GB"
]
