Class {
	#name : #ManifestVMMaker,
	#superclass : #PackageManifest,
	#category : #VMMaker
}

{ #category : #'code-critics' }
ManifestVMMaker class >> ruleCodeCruftLeftInMethodsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#CogObjectRepresentationForSpur #genGetClassObjectOf:into:scratchReg:instRegIsReceiver: #false)) #'2024-03-20T14:24:39.430485+01:00') )
]

{ #category : #'code-critics' }
ManifestVMMaker class >> ruleExcessiveArgumentsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGClassDefinition #(#DruidJIT)) #'2023-04-26T00:25:54.122832+02:00') )
]

{ #category : #'code-critics' }
ManifestVMMaker class >> ruleLongMethodsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGClassDefinition #(#DruidJIT)) #'2023-04-26T00:25:44.408297+02:00') #(#(#RGMethodDefinition #(#CogObjectRepresentationForSpur #genGetClassObjectOf:into:scratchReg:instRegIsReceiver: #false)) #'2024-03-20T14:24:36.77799+01:00') )
]

{ #category : #'code-critics' }
ManifestVMMaker class >> ruleTempsReadBeforeWrittenRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGClassDefinition #(#DruidJIT)) #'2023-04-26T00:25:56.65609+02:00') )
]

{ #category : #'code-critics' }
ManifestVMMaker class >> ruleUncommonMessageSendRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGClassDefinition #(#DruidJIT)) #'2023-04-26T00:25:40.525381+02:00') #(#(#RGClassDefinition #(#Cogit)) #'2023-11-14T14:51:46.485495+01:00') #(#(#RGMethodDefinition #(#CogObjectRepresentationForSpur #genGetClassObjectOfClassIndex:into:scratchReg: #false)) #'2024-03-20T12:06:14.044383+01:00') #(#(#RGMethodDefinition #(#CogObjectRepresentationForSpur #genGetClassObjectOf:into:scratchReg:instRegIsReceiver: #false)) #'2024-03-20T12:09:37.299869+01:00') #(#(#RGMethodDefinition #(#CogObjectRepresentation #genPrimitiveFormat #false)) #'2024-03-21T10:01:25.937395+01:00') )
]
