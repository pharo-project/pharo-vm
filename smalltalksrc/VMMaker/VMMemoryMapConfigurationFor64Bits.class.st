Class {
	#name : 'VMMemoryMapConfigurationFor64Bits',
	#superclass : 'VMMemoryMapConfiguration',
	#category : 'VMMaker-Memory',
	#package : 'VMMaker',
	#tag : 'Memory'
}

{ #category : 'initial addresses' }
VMMemoryMapConfigurationFor64Bits >> codeZoneInitialAddress [

	"self cppIf: WIN32 ifTrue: [ ^ 16r440000000 ""17GB"" ]."

	^ 16r320000000 "12.5GB"
]

{ #category : 'accessing' }
VMMemoryMapConfigurationFor64Bits >> confWordSize [

	<inline: true>

	^ 8
]

{ #category : 'initial addresses' }
VMMemoryMapConfigurationFor64Bits >> newSpaceInitialAddress [

"	self cppIf: WIN32 ifTrue: [ ^ 16r480000000 ""18GB"" ]."
	
	^ 16r360000000 "13.5GB"
]

{ #category : 'initial addresses' }
VMMemoryMapConfigurationFor64Bits >> oldSpaceInitialAddress [

	"self cppIf: WIN32 ifTrue: [ ^ 16r4C0000000 ""19GB"" ]."

	^ 16r10000000000 "1024GB"
]

{ #category : 'initial addresses' }
VMMemoryMapConfigurationFor64Bits >> permSpaceInitialAddress [

	^ 16r20000000000 "2048GB"
]

{ #category : 'initial addresses' }
VMMemoryMapConfigurationFor64Bits >> stackPagesInitialAddress [

	"self cppIf: WIN32 ifTrue: [ ^ 16r400000000 ""16GB"" ]."

	^ 16r300000000 "12GB"
]
