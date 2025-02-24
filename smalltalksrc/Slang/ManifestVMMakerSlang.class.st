"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestVMMakerSlang',
	#superclass : 'PackageManifest',
	#category : 'Slang-Manifest',
	#package : 'Slang',
	#tag : 'Manifest'
}

{ #category : 'meta-data - dependency analyser' }
ManifestVMMakerSlang class >> manuallyResolvedDependencies [
	^ #(#'FileSystem-Core' #'Collections-Abstract')
]

{ #category : 'code-critics' }
ManifestVMMakerSlang class >> ruleStringConcatenationRuleV1FalsePositive [
	^ #(#(#(#RGPackageDefinition #(#Slang)) #'2022-01-03T12:05:51.106983+01:00') )
]
