Class {
	#name : 'VMObjectAccessorIdentificationTest',
	#superclass : 'TestCase',
	#category : 'VMMakerTests-Simulation',
	#package : 'VMMakerTests',
	#tag : 'Simulation'
}

{ #category : 'tests' }
VMObjectAccessorIdentificationTest >> testObjectAccessorMessagesAreCorrectlyDetected [

	| knownSelectors nonAccessorSelectors |
	knownSelectors := #(#numSlotsOf: #literal:ofMethod: #fetchFloat:ofObject: #storePointerUnchecked:ofMaybeForwardedObject:withValue: #keyOfMaybeFiredEphemeron: #stObject:at: #fetchClassOfNonImm: #fetchLong64:ofObject: #storeLong64:ofObject:withValue: #storeFloat64:ofObject:withValue: #is:instanceOf: #methodArgumentCount #characterObjectOf: #storeShort16:ofObject:withValue: #lengthOf: #firstIndexableField: #compactClassIndexOf: #fetchLong32:ofObject: #fetchShort16:ofObject: #isOopImmutable: #rawNumSlotsOf:put: #storePointerImmutabilityCheck:ofObject:withValue: #primitiveMethod #storeByte:ofObject:withValue: #fetchByte:ofObject: #keyOfEphemeron: #storePointer:ofObjStack:withValue: #sizeOfSTArrayFromCPrimitive: #formatOf: #classFormatFromInstFormat: #firstBytePointerOfDataObject: #storeInteger:ofObject:withValue: #num64BitUnitsOf: #sizeBitsOfSafe: #instanceSizeOf: #fetchUnsignedShort16:ofObject: #fetchFloat64:ofObject: #numTagBits #numStrongSlotsOf:format:ephemeronInactiveIf: #formatOfHeader: #fetchClassOf: #numStrongSlotsOfWeakling: #num32BitUnitsOf: #rawOverflowSlotsOf:put: #rememberObjInCorrectRememberedSet: #methodPrimitiveIndex #fetchFloat32:ofObject: #rawNumSlotsOf: #num16BitUnitsOf: #isClassOfNonImm:equalTo:compactClassIndex: #oldRawNumSlotsOf: #followedKeyOfMaybeFiredEphemeron: #arrayValueOf: #numBytesOfBytes: #byteSizeOf: #sizeBitsOf: #numStrongSlotsOfInephemeral: #float32At: #slotSizeOf: #obsoleteDontUseThisFetchWord:ofObject: #lengthOf:format: #primitiveIndexOf: #pinObject: #storePointer:ofObject:withValue: #argumentCountOf: #firstFixedField: #fetchPointer:ofObject: #float64At: #storePointerUnchecked:ofObject:withValue: #is:instanceOf:compactClassIndex: #followedKeyOfEphemeron: #numBytesOf: #stSizeOf: #rawOverflowSlotsOf: #fetchInteger:ofObject: #numSlotsOfAny: #characterTag #characterValueOf: #numPointerSlotsOf: #stObject:at:put: #literalCountOf: #unpinObject: #storeLong32:ofObject:withValue: #fetchArray:ofObject: #fetchLong32:ofFloatObject: #storeFloat32:ofObject:withValue:).
	
	nonAccessorSelectors := knownSelectors reject: [ :e | StackInterpreter isObjectAccessor: e ].
	
	self assert: nonAccessorSelectors isEmpty
]
