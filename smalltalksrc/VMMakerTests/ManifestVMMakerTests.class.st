"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestVMMakerTests',
	#superclass : 'PackageManifest',
	#category : 'VMMakerTests-Manifest',
	#package : 'VMMakerTests',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestVMMakerTests class >> ruleBadMessageRule2V1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#UnicornARMv8Simulator #smashCallerSavedRegistersWithValuesFrom:by:in: #false)) #'2023-05-12T09:19:16.384586+02:00') #(#(#RGMethodDefinition #(#UnicornARMv8Simulator #postCallArgumentsNumArgs:in: #false)) #'2023-05-12T09:20:41.357283+02:00') #(#(#RGMethodDefinition #(#ProcessorSimulator #smashRegistersWithValuesFrom:by: #false)) #'2023-05-12T09:25:17.137958+02:00') )
]

{ #category : 'code-critics' }
ManifestVMMakerTests class >> rulePrecedenceRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#VMMakerTests)) #'2023-05-12T09:19:42.605517+02:00') )
]

{ #category : 'code-critics' }
ManifestVMMakerTests class >> ruleUncommonMessageSendRuleV1FalsePositive [
	^ #(#(#(#RGPackageDefinition #(#VMMakerTests)) #'2020-07-24T12:05:44.86595+02:00') )
]
