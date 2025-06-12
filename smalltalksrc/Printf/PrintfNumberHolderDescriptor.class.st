Class {
	#name : #PrintfNumberHolderDescriptor,
	#superclass : #PrintfFormatDescriptor,
	#instVars : [
		'value'
	],
	#category : #Printf
}

{ #category : #rendering }
PrintfNumberHolderDescriptor >> applyOperator: ignored [
]

{ #category : #rendering }
PrintfNumberHolderDescriptor >> render: object for: printfFormatString [
	^printfFormatString nextFormat
		render: (printfFormatString nextArgument copyFrom: 1 to: object)
		for: printfFormatString
]

{ #category : #accessing }
PrintfNumberHolderDescriptor >> value [
	^value
]
