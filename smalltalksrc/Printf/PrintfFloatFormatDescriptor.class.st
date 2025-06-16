Class {
	#name : #PrintfFloatFormatDescriptor,
	#superclass : #PrintfNumberFormatDescriptor,
	#category : #Printf
}

{ #category : #rendering }
PrintfFloatFormatDescriptor >> applyOperator: aNumber [ 
	"Number is the only valid object class.
	Emulate C behavior as much as we understand it"

	| printer |
	"FloatPrinter might be Undeclared. Let's be helpful."
	FloatPrinter ifNil:
		[self error: 'FloatPrinter appears to be Undeclared. It is a class in the NumberPrinter package by Nicolas Cellier. See https://www.squeaksource.com/NumberPrinter - proceed to install'.
		Installer ss project: 'NumberPrinter'; install: 'NumberPrinter'].
	printer := operator asLowercase caseOf: {
				[$g] -> [FloatPrinter freeFormat].
				[$e] -> [FloatPrinter scientific].
				[$f]  -> [FloatPrinter fixed].
				[$a] -> [FloatPrinter hex] }.
	printer actAsPrintf.
	precision ifNotNil: [printer digitCount: precision].
	printer positiveSignChar: plusSign.
	^flush == #leftFlush
		ifTrue:
			["leftFlush is not handled by versatile printer yet, do it ourself"
			| print |
			print := String new: 32 streamContents: [:str | printer print: aNumber on: str].
			"Note that zero padding is ignored in leftFlush mode. Always use space padding"
			width ifNotNil: [width > print size ifTrue: [print := print , (String new: width - print size withAll: Character space)]].
			print]
		ifFalse:
			[width ifNotNil: [printer totalWidth: width].
			padding = $0 ifTrue: [printer padWithZeros: true].
			String new: 32 streamContents: [:str | printer print: aNumber on: str]]
]

{ #category : #rendering }
PrintfFloatFormatDescriptor >> render: object for: printfFormatString [
	"Bypass super, because we don't want it to truncate to prescribed width"
	^self applyOperator: object.
]

{ #category : #private }
PrintfFloatFormatDescriptor >> stringLength [
	"answer zero because width and padding are handled locally"
	^0
]
