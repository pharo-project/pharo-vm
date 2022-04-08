Class {
	#name : #VMMemoryMapConfigurationFor64Bits,
	#superclass : #VMMemoryMapConfiguration,
	#category : #'VMMaker-Memory'
}

{ #category : #'initial addresses' }
VMMemoryMapConfigurationFor64Bits >> codeZoneInitialAddress [

	self cppIf: WIN32 ifTrue: [ ^ 16r440000000 "17GB" ].

	^ 16r240000000 "9GB"
]

{ #category : #'initial addresses' }
VMMemoryMapConfigurationFor64Bits >> newSpaceInitialAddress [

	self cppIf: WIN32 ifTrue: [ ^ 16r480000000 "18GB" ].

	^ 16r280000000 "10GB"
]

{ #category : #'initial addresses' }
VMMemoryMapConfigurationFor64Bits >> oldSpaceInitialAddress [

	self cppIf: WIN32 ifTrue: [ ^ 16r4C0000000 "19GB" ].

	^ 16r10000000000 "1024GB"
]

{ #category : #'initial addresses' }
VMMemoryMapConfigurationFor64Bits >> permSpaceInitialAddress [

	^ 16r20000000000 "2048GB"
]

{ #category : #'initial addresses' }
VMMemoryMapConfigurationFor64Bits >> stackPagesInitialAddress [

	self cppIf: WIN32 ifTrue: [ ^ 16r400000000 "16GB" ].

	^ 16r200000000 "8GB"
]

{ #category : #accessing }
VMMemoryMapConfigurationFor64Bits >> wordSize [
	<doNotGenerate>
	^ 8
]
