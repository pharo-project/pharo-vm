Class {
	#name : #ComposedSegmentMetadataStruct,
	#superclass : #VMStructType,
	#instVars : [
		'segStart',
		'segSize'
	],
	#category : #'VMMaker-ImageFormat'
}

{ #category : #accessing }
ComposedSegmentMetadataStruct >> segSize [

	^ segSize
]

{ #category : #accessing }
ComposedSegmentMetadataStruct >> segSize: anInt [

	segSize := anInt
]

{ #category : #accessing }
ComposedSegmentMetadataStruct >> segStart [

	^ segStart
]

{ #category : #accessing }
ComposedSegmentMetadataStruct >> segStart: anInt [

	segStart := anInt
]
