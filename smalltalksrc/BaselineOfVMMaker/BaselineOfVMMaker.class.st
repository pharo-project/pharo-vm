Class {
	#name : #BaselineOfVMMaker,
	#superclass : #BaselineOf,
	#category : #BaselineOfVMMaker
}

{ #category : #baselines }
BaselineOfVMMaker >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
			
			"Slang, the basics"			
			spec
				package: 'CAST' with: [
					spec requires: #( 'SmaCC-GLR' )
				];
				package: 'Slang' with: [
					spec requires: #( 'CAST' )
				];
				package: 'Slang-Tests' with: [
					spec requires: #('Slang') ].
			
			"Melchor is a VM-oriented Slang"
			spec package: 'Melchor' with: [
				spec requires: #('Slang') ].
			
			"External Dependencies"
			spec baseline: 'SmaCC-GLR' with: [ 
				spec
					loads: #( 'SmaCC-GLR-Runtime' );
					className: 'BaselineOfSmaCC';
					repository: 'github://SmaCCRefactoring/SmaCC' ].
			spec baseline: 'Unicorn' with: [ 
				spec repository: 'github://guillep/pharo-unicorn' ].
			spec baseline: 'LLVMDisassembler' with: [ 
				spec repository: 'github://guillep/pharo-llvmDisassembler' ].

			"Tests"			
			spec
				package: 'VMMakerTests' with: [
					spec requires: #('VMMakerCompatibilityForPharo6' 'Unicorn' 'LLVMDisassembler' 'Slang-Tests') ];
				package: 'VMMaker-MT-Tests' with: [
					spec requires: #('VMMakerTests') ].

			spec
				package: 'VMMaker-OriginalTests' with: [
					spec requires: #('VMMakerCompatibilityForPharo6') ].

			"Tools"			
			spec package: 'VMMaker-Tools' with: [ 
				spec requires: #( 'VMMakerCompatibilityForPharo6' 'VMMakerTests' ) ].
			
			spec
				package: 'VMMakerCompatibilityForPharo6' with: [ spec requires: 'VMMaker' ];
				package: 'VMMakerLoadingDependencies'.
			
			"Dependencies from this repositories"
			spec 
				package: 'Printf'.
				
			"Main VMMaker packages"	
			spec
				package: 'VMMaker-Slang'
				with: [ spec requires: #( 'Melchor' 'VMMaker' ) ];
				package: 'VMMaker'
				with: [ spec requires: #( 'Melchor' 'VMMakerLoadingDependencies' 'Printf') ].
								
			"VM plugins"
			spec package: 'FileAttributesPlugin' with: [ spec requires: #( 'VMMakerCompatibilityForPharo6') ].
			
			spec group: 'plugins' with: #('FileAttributesPlugin').
			spec group: 'core' with: #('VMMaker-Slang').
			spec group: 'tools' with: #('VMMaker-Tools').			
			spec group: 'tests' with: #('VMMakerTests' 'VMMaker-OriginalTests' 'VMMaker-MT-Tests').			
			spec group: 'default' with: #( 'core' 'plugins' 'tools' 'tests') ]
]
