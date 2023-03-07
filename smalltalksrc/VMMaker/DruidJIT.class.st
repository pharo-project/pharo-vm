Class {
	#name : #DruidJIT,
	#superclass : #StackToRegisterMappingCogit,
	#instVars : [
		'ceDereferenceSelectorIndex',
		'ceStoreTrampolines',
		'ceNewHashTrampoline',
		'ceInlineNewHashTrampoline',
		'ceStoreCheckTrampoline',
		'ceStoreCheckContextReceiverTrampoline',
		'ceScheduleScavengeTrampoline',
		'ceSmallActiveContextInMethodTrampoline',
		'ceSmallActiveContextInFullBlockTrampoline',
		'ceLargeActiveContextInMethodTrampoline',
		'ceLargeActiveContextInFullBlockTrampoline'
	],
	#classVars : [
		'NumStoreTrampolines'
	],
	#category : #'VMMaker-JIT'
}

{ #category : #translation }
DruidJIT class >> declareCVarsIn: aCodeGen [
	"Deal wuth the fact that the number of trampolines depends on IMMUTABILITY
	 and that IMMUTABILITY can be defined at compile time.  Yes, this is a mess."
	| current values |
	current := InitializationOptions at: #IMMUTABILITY ifAbsent: nil.
	values := #(true false) collect:
				[:bool|
				 InitializationOptions at: #IMMUTABILITY put: bool.
				 self initializeNumTrampolines.
				 (Cogit classPool at: #NumTrampolines) printString].
	current
		ifNil: [InitializationOptions removeKey: #IMMUTABILITY]
		ifNotNil: [InitializationOptions at: #IMMUTABILITY put: current].
	values first ~= values last ifTrue:
		[aCodeGen addConstantForBinding: #NumTrampolines -> ('(IMMUTABILITY ? ' , values first , ' : ' , values last , ')')].

	aCodeGen
		var: #ceStoreTrampolines
		declareC: ('#if IMMUTABILITY\sqInt ceStoreTrampolines[', NumStoreTrampolines printString, '];\#endif') withCRs
]

{ #category : #initialization }
DruidJIT class >> initialize [
	
	NumStoreTrampolines := 5
]

{ #category : #'class initialization' }
DruidJIT class >> initializePrimitiveTable [

	<generated>
	MaxCompiledPrimitiveIndex := 10.
	primitiveTable := CArrayAccessor on:
		                  (Array new: MaxCompiledPrimitiveIndex + 1).
	self table: primitiveTable from: self primitiveTableArray
]

{ #category : #translation }
DruidJIT class >> objectRepresentationAncilliaryClasses [

	^ Array empty
]

{ #category : #'accessing class hierarchy' }
DruidJIT class >> objectRepresentationClass [

]

{ #category : #'class initialization' }
DruidJIT class >> primitiveTableArray [

	<generated>
	^ {
		  { 1. #gen_PrimitiveAdd. 1 }.
		  { 2. #gen_PrimitiveSubtract. 1 }.
		  { 3. #gen_PrimitiveLessThan. 1 }.
		  { 4. #gen_PrimitiveGreaterThan. 1 }.
		  { 5. #gen_PrimitiveLessOrEqual. 1 }.
		  { 6. #gen_PrimitiveGreaterOrEqual. 1 }.
		  { 7. #gen_PrimitiveEqual. 1 }.
		  { 8. #gen_PrimitiveNotEqual. 1 }.
		  { 9. #gen_PrimitiveMultiply. 1 }.
		  { 10. #gen_PrimitiveDivide. 1 } }
]

{ #category : #'trait candidates' }
DruidJIT >> allYoungObjectsAgeInFullGC [
	^false
]

{ #category : #'trait candidates' }
DruidJIT >> cacheTagIsMarked: cacheTag [
	"Answer if the cacheTag is not unmarked, i.e. answer true for compact class
	 indices and immediates; only answer false for unmarked objects.  In Spur
	 linked send cache tags are class indices so effectively they're always marked."
	^true
]

{ #category : #'trait candidates' }
DruidJIT >> checkValidObjectReference: anOop [
	^(objectMemory isImmediate: anOop) not
	   and: [(objectMemory heapMapAtWord: (self pointerForOop: anOop)) ~= 0]
]

{ #category : #'trait candidates' }
DruidJIT >> checkValidOopReference: anOop [
	^(objectMemory isImmediate: anOop)
	   or: [(objectMemory heapMapAtWord: (self pointerForOop: anOop)) ~= 0]
]

{ #category : #'trait candidates' }
DruidJIT >> classForInlineCacheTag: classIndex [
	^objectMemory classOrNilAtIndex: classIndex
]

{ #category : #'trait candidates' }
DruidJIT >> couldBeObject: literal [
	^(objectMemory isNonImmediate: literal)
	  and: [self oop: literal isGreaterThanOrEqualTo: objectMemory startOfMemory]
]

{ #category : #'trait candidates' }
DruidJIT >> genGetInlineCacheClassTagFrom: sourceReg into: destReg forEntry: forEntry [
	"Extract the inline cache tag for the object in sourceReg into destReg. The inline
	 cache tag for a given object is the value loaded in inline caches to distinguish
	 objects of different classes.  In Spur this is either the tags for immediates, or
	 the receiver's classIndex.  Answer the label for the start of the sequence."
	| jumpImm entryLabel |
	<var: #jumpImm type: #'AbstractInstruction *'>
	<var: #entryLabel type: #'AbstractInstruction *'>
	forEntry ifTrue:
		[ self AlignmentNops: objectMemory wordSize].
	entryLabel := self Label.
	self AndCq: objectMemory tagMask R: sourceReg R: destReg.
	jumpImm := self JumpNonZero: 0.
	"Get least significant half of header word in destReg"
	self flag: #endianness.
	self MoveMw: 0 r: sourceReg R: destReg.
	self AndCq: objectMemory classIndexMask R: destReg.

	"The entry and the noCheckEntry (that will generated after) need to be aligned differently.
	We do that by forcing some odd number of extra Nop operations here.
	One Nop is not enough because that causes x86-64 entries to have the same allignment.
	
	In ARM64 all instructions are 4 byte long, thus 3 Nops make 
	   - the entry to be aligned to 8 bytes and
	   - the no check entry aligned to 4 bytes.
	
	In x86-64 instruction size is variable, and 3 Nops take 3 bytes."
	forEntry ifTrue: [ 
		self Nop.
		self Nop.
		self Nop.
	].

	jumpImm jmpTarget: self Label.
	^entryLabel
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveAdd [
	"AutoGenerated by Druid"

	| jump1 jump2 currentBlock |
	self mclassIsSmallInteger ifFalse: [ ^ UnimplementedPrimitive ].
	self TstCq: 1 R: Arg0Reg.
	jump1 := self JumpZero: 0.
	self MoveR: Arg0Reg R: TempReg.
	self SubCq: 1 R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AddR: ClassReg R: TempReg.
	jump2 := self JumpOverflow: 0.
	self MoveR: TempReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveDivide [
	"AutoGenerated by Druid"

	| jump5 jump3 jump1 currentBlock jump4 jump2 |
	self TstCq: 1 R: ReceiverResultReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: TempReg.
	self ArithmeticShiftRightCq: 3 R: TempReg.
	self TstCq: 1 R: Arg0Reg.
	jump2 := self JumpZero: 0.
	self MoveR: Arg0Reg R: ClassReg.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jump3 := self JumpZero: 0.
	self
		DivR: ClassReg
		R: TempReg
		Quo: Extra0Reg
		Rem: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump4 := self JumpNonZero: 0.
	self
		DivR: ClassReg
		R: TempReg
		Quo: Extra0Reg
		Rem: SendNumArgsReg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self ArithmeticShiftRightCq: 60 R: SendNumArgsReg.
	self AddCq: 1 R: SendNumArgsReg.
	self AndCq: 15 R: SendNumArgsReg.
	self CmpCq: 1 R: SendNumArgsReg.
	jump5 := self JumpGreater: 0.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 1 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveEqual [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpZero: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveGreaterOrEqual [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpGreaterOrEqual: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveGreaterThan [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpGreater: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveLessOrEqual [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpLessOrEqual: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveLessThan [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpLess: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveMultiply [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self TstCq: 1 R: ReceiverResultReg.
	jump1 := self JumpZero: 0.
	self TstCq: 1 R: Arg0Reg.
	jump2 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: TempReg.
	self ArithmeticShiftRightCq: 3 R: TempReg.
	self MoveR: Arg0Reg R: ClassReg.
	self SubCq: 1 R: ClassReg.
	self MulR: ClassReg R: TempReg.
	jump3 := self JumpMultiplyOverflow: 0.
	self AddCq: 1 R: TempReg.
	self MoveR: TempReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveNotEqual [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpNonZero: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveSubtract [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self TstCq: 1 R: ReceiverResultReg.
	jump1 := self JumpZero: 0.
	self TstCq: 1 R: Arg0Reg.
	jump2 := self JumpZero: 0.
	self MoveR: Arg0Reg R: TempReg.
	self SubCq: 1 R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self SubR: TempReg R: ClassReg.
	jump3 := self JumpOverflow: 0.
	self MoveR: ClassReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #'trait candidates' }
DruidJIT >> generateObjectRepresentationTrampolines [
	"Do the store check.  Answer the argument for the benefit of the code generator;
	 ReceiverResultReg may be caller-saved and hence smashed by this call.  Answering
	 it allows the code generator to reload ReceiverResultReg cheaply.
	 In Spur the only thing we leave to the run-time is adding the receiver to the
	 remembered set and setting its isRemembered bit."
	self 
		cppIf: IMMUTABILITY
		ifTrue: 
			[self cCode: [] inSmalltalk:
				[ceStoreTrampolines := CArrayAccessor on: (Array new: NumStoreTrampolines)].
			 0 to: NumStoreTrampolines - 1 do:
				[:instVarIndex |
				 ceStoreTrampolines
					at: instVarIndex
					put: (self 
							genStoreTrampolineCalled: (self 
															trampolineName: 'ceStoreTrampoline' 
															numArgs: instVarIndex 
															limit: NumStoreTrampolines - 2) 
							instVarIndex: instVarIndex)]].
	ceNewHashTrampoline := self genNewHashTrampoline: false called: 'ceNewHash'.
	SistaVM ifTrue: [ceInlineNewHashTrampoline := self genNewHashTrampoline: true  called: 'ceInlineNewHash'].
	ceStoreCheckTrampoline := self genStoreCheckTrampoline.
	ceStoreCheckContextReceiverTrampoline := self genStoreCheckContextReceiverTrampoline.
	ceScheduleScavengeTrampoline := self
											genTrampolineFor: #ceScheduleScavenge
											called: 'ceScheduleScavengeTrampoline'
											regsToSave: CallerSavedRegisterMask.
	ceSmallActiveContextInMethodTrampoline := self genActiveContextTrampolineLarge: false inBlock: 0 called: 'ceSmallMethodContext'.
	SistaV1BytecodeSet ifTrue:
		[ceSmallActiveContextInFullBlockTrampoline := self genActiveContextTrampolineLarge: false inBlock: InFullBlock called: 'ceSmallFullBlockContext'].
	ceLargeActiveContextInMethodTrampoline := self genActiveContextTrampolineLarge: true inBlock: 0 called: 'ceLargeMethodContext'.
	SistaV1BytecodeSet ifTrue:
		[ceLargeActiveContextInFullBlockTrampoline := self genActiveContextTrampolineLarge: true inBlock: InFullBlock called: 'ceLargeFullBlockContext'].
]

{ #category : #'trait candidates' }
DruidJIT >> hasValidHeaderPostGC: cogMethod [
	<var: #cogMethod type: #'CogMethod *'>
	<inline: true>
	^cogMethod objectHeader = objectMemory nullHeaderForMachineCodeMethod
]

{ #category : #'trait candidates' }
DruidJIT >> initialize [

	<doNotGenerate>
	super initialize.
	
	ceStoreTrampolines := (CArrayAccessor on: (Array new: NumStoreTrampolines))
]

{ #category : #'trait candidates' }
DruidJIT >> inlineCacheTagForInstance: oop [
	"Answer the relevant inline cache tag for an instance.
	 c.f. getInlineCacheClassTagFrom:into: & inlineCacheTagForClass:"
	^(objectMemory isImmediate: oop)
		ifTrue: [oop bitAnd: objectMemory tagMask]
		ifFalse: [objectMemory classIndexOf: oop]
]

{ #category : #'trait candidates' }
DruidJIT >> inlineCacheTagIsYoung: cacheTag [
	"Since all cache tags in Spur are class indices none of
	 them are young or have to be updated in a scavenge."
	^false
]

{ #category : #'trait candidates' }
DruidJIT >> markAndTraceCacheTagLiteral: literal in: cogMethodOrNil atpc: address [
	"Mark and trace a literal in an inline cache preceding address in cogMethodOrNil.
	 Answer if code was modified.  In 64-bit Spur, cache tags are either selector
	 indices or class indices and so this is a noop."
	<var: #cogMethodOrNil type: #'CogMethod *'>
	<var: #address type: #usqInt>
	<inline: true>
	^false
]

{ #category : #'trait candidates' }
DruidJIT >> markAndTraceLiteral: literal in: cogMethod at: address [
	"Mark and trace a literal in a sqInt variable of cogMethod."
	<var: #cogMethod type: #'CogMethod *'>
	<var: #address type: #'sqInt *'>
	| objOop |
	(self couldBeObject: literal) ifFalse:
		[^self].
	self assert: (objectMemory addressCouldBeObj: literal).
	(objectMemory isForwarded: literal) ifFalse:
		[objectMemory markAndTrace: literal.
		 ^self].
	objOop := objectMemory followForwarded: literal.
	address at: 0 put: objOop.
	self markAndTraceUpdatedLiteral: objOop in: cogMethod
]

{ #category : #'trait candidates' }
DruidJIT >> markAndTraceLiteral: literal in: cogMethodOrNil atpc: address [
	"Mark and trace a literal in a machine code instruction preceding address in cogMethodOrNil.
	 Answer if code was modified."
	<var: #cogMethodOrNil type: #'CogMethod *'>
	<var: #address type: #usqInt>
	| objOop |
	(self couldBeObject: literal) ifFalse:
		[^false].
	self assert: (objectMemory addressCouldBeObj: literal).
	(objectMemory isForwarded: literal) ifFalse:
		[objectMemory markAndTrace: literal.
		 ^false].
	objOop := objectMemory followForwarded: literal.
	self backEnd storeLiteral: objOop beforeFollowingAddress: address.
	self markAndTraceUpdatedLiteral: objOop in: cogMethodOrNil.
	^true
]

{ #category : #'trait candidates' }
DruidJIT >> markAndTraceUpdatedLiteral: objOop in: cogMethodOrNil [
	"Common code to mark a literal in cogMethod and add
	 the cogMethod to youngReferrers if the literal is young."
	<var: #cogMethodOrNil type: #'CogMethod *'>
	(objectMemory isNonImmediate: objOop) ifTrue:
		[(cogMethodOrNil notNil
		  and: [objectMemory isYoungObject: objOop]) ifTrue:
			[methodZone ensureInYoungReferrers: cogMethodOrNil].
		 objectMemory markAndTrace: objOop]
]

{ #category : #'trait candidates' }
DruidJIT >> maybeGenerateSelectorIndexDereferenceRoutine [
	"Generate the routine that converts selector indices into selector objects.
	 It is called from the send trampolines.
	 If the selector index is negative, convert it into a positive index into the
	 special selectors array and index that.  Otherwise, index the current method.
	 The routine uses Extra0Reg & Extra1Reg, which are available, since they
	 are not live at point of send."
	| jumpNegative jumpNotBlock jumpFullBlock |
	<var: 'jumpNegative' type: #'AbstractInstruction *'>
	<var: 'jumpNotBlock' type: #'AbstractInstruction *'>
	<var: 'jumpFullBlock' type: #'AbstractInstruction *'>
	self zeroOpcodeIndex.
	self CmpCq: 0 R: ClassReg.
	jumpNegative := self JumpLess: 0.
	self
		MoveMw: FoxMethod r: FPReg R: Extra0Reg;
		AddCq: 2 R: ClassReg; "Change selector index to 1-relative, skipping the method header"
		TstCq: MFMethodFlagIsBlockFlag R: Extra0Reg.
	jumpNotBlock := self JumpZero: 0.
	"If in a block, need to find the home method...  If using full blocks, need to test the cpicHasMNUCaseOrCMIsFullBlock bit"
	self AndCq: methodZone zoneAlignment negated R: Extra0Reg.
	SistaV1BytecodeSet ifTrue:
		[self bitAndByteOffsetOfIsFullBlockBitInto:
			[:bitmask :byteOffset|
			jumpFullBlock := self
				MoveMb: byteOffset r: Extra0Reg R: Extra1Reg;
				TstCq: bitmask R: Extra1Reg;
				JumpNonZero: 0]].
	self 
		MoveM16: 0 r: Extra0Reg R: Extra1Reg;
		SubR: Extra1Reg R: Extra0Reg.
	jumpNotBlock jmpTarget: self Label.
	SistaV1BytecodeSet ifTrue:
		[jumpFullBlock jmpTarget: jumpNotBlock getJmpTarget].
	self "Now fetch the method object and index with the literal index to retrieve the selector"
		AndCq: methodZone zoneAlignment negated R: Extra0Reg;
		MoveMw: (self offset: CogMethod of: #methodObject) r: Extra0Reg R: Extra1Reg;
		MoveXwr: ClassReg R: Extra1Reg R: ClassReg;
		RetN: 0.
	jumpNegative jmpTarget: self Label.
	self
		NegateR: ClassReg;
		LogicalShiftLeftCq: 1 R: ClassReg;
		MoveAw: objectMemory specialObjectsArrayAddress R: Extra0Reg;
		SubCq: 1 R: ClassReg;
		MoveMw: SpecialSelectors + 1 * objectMemory wordSize r: Extra0Reg R: Extra1Reg; "Index, including header size"
		MoveXwr: ClassReg R: Extra1Reg R: ClassReg;
		RetN: 0.
	ceDereferenceSelectorIndex := self methodZoneBase.
	self
		outputInstructionsForGeneratedRuntimeAt: ceDereferenceSelectorIndex;
		recordGeneratedRunTime: 'ceDereferenceSelectorIndex' address: ceDereferenceSelectorIndex;
		recordRunTimeObjectReferences
]

{ #category : #'trait candidates' }
DruidJIT >> numRegArgs [
	"Define how many register arguments a StackToRegisterMappingCogit can
	 and should use with the receiver.  The value must be 0, 1 or 2.  Note that a
	 SimpleStackBasedCogit always has 0 register args (although the receiver is
	 passed in a register).  The Spur object representation is simple enough that
	 implementing at:put: is straight-forward and hence 2 register args are worth
	 while.  The method must be inlined in CoInterpreter, and dead code eliminated
	 so that the register-popping enilopmarts such as enterRegisterArgCogMethod:-
	 at:receiver: do not have to be implemented in SimpleStackBasedCogit."
	<api>
	<option: #StackToRegisterMappingCogit>
	^2
]

{ #category : #'trait candidates' }
DruidJIT >> remapObject: objOop [
	self assert: (objectMemory addressCouldBeObj: objOop).
	^(objectMemory shouldRemapObj: objOop)
		ifTrue: [objectMemory remapObj: objOop]
		ifFalse: [objOop]
]

{ #category : #'trait candidates' }
DruidJIT >> remapOop: objOop [
	^(objectMemory shouldRemapOop: objOop)
		ifTrue: [objectMemory remapObj: objOop]
		ifFalse: [objOop]
]

{ #category : #'trait candidates' }
DruidJIT >> shouldAnnotateObjectReference: anOop [
	"Objects in newSpace or oldSpace except nil, true, false & classTableRootObj need to be annotated."
	^(objectMemory isNonImmediate: anOop)
	  and: [(self oop: anOop isGreaterThan: objectMemory classTableRootObj)
		or: [self oop: anOop isLessThan: objectMemory nilObject]]
]

{ #category : #'trait candidates' }
DruidJIT >> validInlineCacheTag: classIndexOrTagPattern [
	"The three valid tag patterns are 1 (SmallInteger), 2 (Character) and 3 (SmallFloat64)."
	^(classIndexOrTagPattern >= 1
	  and: [classIndexOrTagPattern <= 3])
	  or: [(objectMemory classAtIndex: classIndexOrTagPattern) notNil]
]
