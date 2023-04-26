Class {
	#name : #ManifestVMMaker,
	#superclass : #PackageManifest,
	#category : #VMMaker
}

{ #category : #'code-critics' }
ManifestVMMaker class >> ruleExcessiveArgumentsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGClassDefinition #(#DruidJIT)) #'2023-04-26T00:25:54.122832+02:00') )
]

{ #category : #'code-critics' }
ManifestVMMaker class >> ruleLongMethodsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGClassDefinition #(#DruidJIT)) #'2023-04-26T00:25:44.408297+02:00') )
]

{ #category : #'code-critics' }
ManifestVMMaker class >> ruleTempsReadBeforeWrittenRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGClassDefinition #(#DruidJIT)) #'2023-04-26T00:25:56.65609+02:00') )
]

{ #category : #'code-critics' }
ManifestVMMaker class >> ruleUncommonMessageSendRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGClassDefinition #(#DruidJIT)) #'2023-04-26T00:25:40.525381+02:00') )
]
