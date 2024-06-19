Class {
	#name : #MLVMCCodeGenerator,
	#superclass : #CCodeGenerator,
	#instVars : [
		'vmClass',
		'vmMaker'
	],
	#category : #Melchor
}

{ #category : #'C code generator' }
MLVMCCodeGenerator >> abortBlock [
	^self vmMaker ifNotNil: [:vmm| vmm abortBlock]
]

{ #category : #'spur primitive compilation' }
MLVMCCodeGenerator >> accessorDepthCalculator [

	^ MLAccessorDepthCalculator forCodeGenerator: self 
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> bytesPerOop [
	^ self vmmakerConfiguration bytesPerOop
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> bytesPerWord [
	^ self vmmakerConfiguration bytesPerWord
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> computeKernelReturnTypes [
	| dictionary |
	dictionary := Dictionary newFromPairs:
		#(oopAt: #sqInt oopAt:put: #sqInt
			oopAtPointer: #sqInt oopAtPointer:put: #sqInt
		 byteAt: #sqInt byteAt:put: #sqInt
			byteAtPointer: #sqInt byteAtPointer:put: #sqInt
		 shortAt: #sqInt shortAt:put: #sqInt
			shortAtPointer: #sqInt shortAtPointer:put: #sqInt
		 intAt: #sqInt intAt:put: #sqInt
			intAtPointer: #sqInt intAtPointer:put: #sqInt
		 longAt: #sqInt longAt:put: #sqInt
			longAtPointer: #sqInt longAtPointer:put: #sqInt
				long32At: #int long32At:put: #int
					unalignedLongAt: #sqInt unalignedLongAt:put: #sqInt
						unalignedLong32At: #int unalignedLong32At:put: #int

		 long64At: #sqLong long64At:put: #sqLong
		 long64AtPointer: #sqLong long64AtPointer:put: #sqLong
	
		singleFloatAtPointer: #float singleFloatAtPointerPut: #float		
		floatAtPointer: #double floatAtPointerPut: #double
				
		 fetchFloatAt:into: #void storeFloatAt:from: #void
			fetchFloatAtPointer:into: #void storeFloatAtPointer:from: #void
		 fetchSingleFloatAt:into: #void storeSingleFloatAt:from: #void
			 storeSingleFloatAtPointer:from: #void

		 pointerForOop: #'char *' oopForPointer: #sqInt
		 baseHeaderSize #sqInt wordSize #sqInt bytesPerOop #sqInt).
	self vmmakerConfiguration bytesPerWord = 8 ifTrue:
		[#(long32At: long32At:put: unalignedLong32At: unalignedLong32At:put:) do:
			[:accessor|
			dictionary at: accessor put: #int]].
	^dictionary
]

{ #category : #accessing }
MLVMCCodeGenerator >> constantClass [
	
	^ (self vmClass ifNil: [ self vmmakerConfiguration ]) constantClass.
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> constants [

	| unused |
	"and VMBasicConstants mostBasicConstantNames *must* be taken from interp.h"
	unused := self unusedConstants.
	^ constants keys reject: [ :any | unused includes: any ]
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> declaredConstants [
	| unused |
	unused := super declaredConstants.
	unused addAll: self vmmakerConfiguration unusedConstantNames.
	^ unused
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> defaultType [
	
	^ #sqInt
]

{ #category : #'compile-time-options' }
MLVMCCodeGenerator >> defineAtCompileTime: aString [ 
	"Define if the code generator should define the option at compile time or at generation time.
	If true, the decision of the option will be delayed to compilation time.
	Otherwise, do it at transpilation time, 
	 - the code with the option is generated if the value of the option is true
	 - if not true or unset, do not generate"
	(super defineAtCompileTime: aString)
		ifTrue: [ ^ true ].
		
	^ (self vmClass ifNil: [self constantClass]) defineAtCompileTime: aString
]

{ #category : #inlining }
MLVMCCodeGenerator >> doInlining: inlineFlagOrSymbol [
	"Inline the bodies of all methods that are suitable for inlining."
	"Modified slightly for the core VM translator, since the first level of inlining for the interpret loop must be performed in order that the instruction implementations can easily discover their addresses. Remember to inline the bytecode routines as well"

	| interpretMethod |
	inlineFlagOrSymbol isSymbol ifTrue:
		[self inlineDispatchesInMethodNamed: #interpret.
		 self doBasicInlining: inlineFlagOrSymbol.
		 self pruneUnreachableMethods.
		 ^self].

	inlineFlagOrSymbol ifFalse:
		[self inlineDispatchesInMethodNamed: #interpret.
		self pruneUnreachableMethods.
		^self].

	self doBasicInlining: inlineFlagOrSymbol.

	self vmClass ifNil: [^self].

	UIManager default
		displayProgress: 'Inlining bytecodes'
		from: 1 to: 2
		during: [:bar |
			self inlineDispatchesInMethodNamed: #interpret.
			bar value: 1 ].

	self pruneUnreachableMethods.
	interpretMethod := self methodNamed: #interpret.
	self
		localizeVariables: self vmClass namesOfVariablesToLocalize
		inMethod: interpretMethod
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> emitCAPIExportHeaderOn: aStream [ 
	"Store prototype declarations for all API methods on the given stream."
	| exportedAPIMethods usedConstants |
	exportedAPIMethods := self sortMethods: (methods select: [:m| m isAPIMethod]).
	exportedAPIMethods do:
		[:m|
		m static ifTrue:
			[logger newLine; show: m selector, ' excluded from export API because it is static'; newLine]].
	self emitCFunctionPrototypes: exportedAPIMethods on: aStream.
	self emitGlobalCVariablesOn: aStream.
	usedConstants := self emitCMacros: exportedAPIMethods on: aStream.
	self emitCConstants: usedConstants on: aStream
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> emitCCodeOn: aStream doInlining: inlineFlag doAssertions: assertionFlag [
	"Emit C code for all methods in the code base onto the given stream. All inlined method calls should already have been expanded."

	super emitCCodeOn: aStream doInlining: inlineFlag doAssertions: assertionFlag.
	self emitExportsOn: aStream
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> emitCFunctionPrototypeFor: m on: aStream [
	self vmClass ifNotNil: [ 
		(NoRegParmsInAssertVMs and: [ 
			 m export not and: [ m isStatic and: [ m args notEmpty ] ] ]) 
			ifTrue: [ m addFunctionAttribute: 'NoDbgRegParms' ].
		m inline == #never ifTrue: [ m addFunctionAttribute: 'NeverInline' ] ].
	^ super emitCFunctionPrototypeFor: m on: aStream
]

{ #category : #'compile-time-options' }
MLVMCCodeGenerator >> emitCHeaderOn: aStream [
	"Emit the initial part of a source file on aStream, comprising the version stamp,
	 the global struct usage flags, the header files and preamble code."

	| headerClass |
	headerClass := [self vmClass coreInterpreterClass]
						on: MessageNotUnderstood
						do: [:ex| self vmClass].
	aStream nextPutAll: (self fileHeaderVersionStampForSourceClass: headerClass); newLine; newLine.
	self addHeaderFileFirst: '"sq.h"'.

	super emitCHeaderOn: aStream.
	
	vmClass isInterpreterClass ifTrue:
		[self maybePutPreambleFor: vmClass on: aStream].
	aStream newLine
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> emitCVariableDeclarationFor: aDeclaration andVarString: varString on: aStream [
	| declaration |
	declaration := aDeclaration.
	self isGeneratingPluginCode
		ifTrue: [ 
			varString = 'interpreterProxy'
				ifTrue: [ "quite special..." 
				self preDeclareInterpreterProxyOn: aStream ]
				ifFalse: [ 
					(declaration beginsWith: 'static') ifFalse: [ 
						aStream nextPutAll: 'static ' ] ] ]
		ifFalse: [ 
			(self vmClass mustBeGlobal: varString)
				ifTrue: [ 
					(declaration beginsWith: 'static ') ifTrue: [ 
						declaration := declaration allButFirst: 7 ] ]
				ifFalse: [ 
					(declaration beginsWith: 'static') ifFalse: [ 
						aStream nextPutAll: 'static ' ] ] ].
	aStream
		nextPutAll: declaration;
		nextPut: $;;
		newLine
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> emitExportNamed: exportsNamePrefix forMethod: method pluginName: pluginName on: aStream [

	| primName |
	"Don't include the depth in the vm's named primitives if the vm is non-Spur."
	primName := self cFunctionNameFor: method selector.
	aStream
		tab;
		nextPutAll: '{(void*)_m, "';
		nextPutAll: primName.
	(self accessorDepthCalculator accessorDepthForSelector:
		 primName asSymbol) ifNotNil: [ :depth | "store the accessor depth in a hidden byte immediately after the primName"
		self assert: depth < 128.
		aStream
			nextPutAll: '\000\';
			nextPutAll: ((depth bitAnd: 255) printStringBase: 8 nDigits: 3) ].
	aStream
		nextPutAll: '", (void*)';
		nextPutAll: primName;
		nextPutAll: '},';
		newLine
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> emitExportsOn: aStream [
	"Store all the exported primitives in the form used by the internal named prim system."
	(self vmClass isNil or: [self vmClass isInterpreterClass]) ifTrue:
		[self emitExportsNamed: 'vm' pluginName: '' on: aStream]
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> emitFunctionPrototypesPreambleOn: aStream [
	self vmClass ifNotNil: [ 
		NoRegParmsInAssertVMs ifTrue: [ 
			aStream nextPutAll:
				'\\#if !PRODUCTION && defined(PlatformNoDbgRegParms)\# define NoDbgRegParms PlatformNoDbgRegParms\#endif'
					withCRs.
			aStream nextPutAll:
				'\\#if !defined(NoDbgRegParms)\# define NoDbgRegParms /*empty*/\#endif\\'
					withCRs ].
		aStream nextPutAll:
			'\\#if !defined(NeverInline)\# define NeverInline /*empty*/\#endif\\'
				withCRs ]
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> emitGlobalCVariablesOn: aStream [
	"Store the global variable declarations on the given stream."

	aStream newLine; nextPutAll: '/*** Global Variables ***/'; newLine.
	
	(self sortStrings: (variables select: [:v| self vmClass mustBeGlobal: v])) do:
		[:var | | varString decl |
		varString := var asString.
		decl := variableDeclarations at: varString ifAbsent: ['sqInt ' , varString].
		decl first == $# "support cgen var: #bytecodeSetSelector declareC: '#define bytecodeSetSelector 0' hack"
			ifTrue:
				[aStream nextPutAll: decl; newLine]
			ifFalse:
				[(decl includesSubstring: ' private ') ifFalse: "work-around hack to prevent localization of variables only referenced once."
					[(decl beginsWith: 'static') ifFalse: [aStream nextPutAll: 'VM_EXPORT extern '].
					(decl includes: $=) ifTrue:
						[decl := decl copyFrom: 1 to: (decl indexOf: $=) - 1].
					aStream
						nextPutAll: decl;
						nextPut: $;;
						newLine]]].
	aStream newLine
]

{ #category : #'type inference' }
MLVMCCodeGenerator >> harmonizeIntegerIn: aSetOfTypes [
	"help to decide if the element in a SetOfTypes will be treated as signed or unsigned.
	only add sqInt to the types if an usqInt isn't here to prevent signing method returning usqInt."
	| constantIntegers |
	constantIntegers := aSetOfTypes select: [ :element |
		                    element isInteger ].
	constantIntegers notEmpty ifFalse: [ ^ self ].
	aSetOfTypes removeAll: constantIntegers.
	(aSetOfTypes includes: #usqInt) ifTrue: [ ^ self ].
	aSetOfTypes add: #sqInt
]

{ #category : #'type inference' }
MLVMCCodeGenerator >> harmonizeReturnTypesIn: aSetOfTypes [
	"Eliminate signed/unsigned conflicts in aSetOfTypes. Non-negative integers can be either
	 signed or unsigned. if possible the type will default to the signed part"

	| sqs usqs |
	"N.B. Because of LP64 vs LLP64 issues do *not* rename #long to #sqInt or #'unsigned long' to #usqInt"
	#( char short int #'long long' #'unsigned char' #'unsigned short'
	   #'unsigned int' #'unsigned long long' )
		with: #( sqInt sqInt sqInt sqLong usqInt usqInt usqInt usqLong )
		do: [ :type :replacement |
			(aSetOfTypes includes: type) ifTrue: [
				aSetOfTypes
					remove: type;
					add: replacement ] ].
	self harmonizeIntegerIn: aSetOfTypes.
	sqs := aSetOfTypes select: [ :t | t beginsWith: 'sq' ].
	usqs := aSetOfTypes select: [ :t | t beginsWith: 'usq' ].
	^ (sqs size + usqs size = aSetOfTypes size and: [
		   sqs notEmpty and: [
			   sqs allSatisfy: [ :t | usqs includes: 'u' , t ] ] ])
		  ifTrue: [ sqs ]
		  ifFalse: [ aSetOfTypes ]
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> instVarNamesForClass: aClass [
	^self vmClass
		ifNil: [ super instVarNamesForClass: aClass ]
		ifNotNil: [aClass instVarNames reject:
					[:ivn| self vmClass isNonArgumentImplicitReceiverVariableName: ivn]]
]

{ #category : #accessing }
MLVMCCodeGenerator >> interpreterVersion [
	^self vmClass interpreterVersion, '[', self vmClass objectMemoryClass memoryManagerVersion, ']'
]

{ #category : #'C translation' }
MLVMCCodeGenerator >> is32Bit [
	^ self vmClass isNil or: [ 
		  self vmClass objectMemoryClass wordSize = 4 ]
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> isAcceptableAncilliaryClass: class [
	^ self vmClass isNil or: [ 
		  self vmClass isAcceptableAncilliaryClass: class ]
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> isNonArgumentImplicitReceiverVariableName: aString [

	^ (super isNonArgumentImplicitReceiverVariableName: aString)
	    or: [self vmClass
			ifNil: [#('interpreterProxy' 'self') includes: aString]
	 		ifNotNil: [self vmClass isNonArgumentImplicitReceiverVariableName: aString]]
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> kernelReturnTypes [
	
	^ kernelReturnTypes ifNil: [ kernelReturnTypes := self computeKernelReturnTypes ]
]

{ #category : #'C translation support' }
MLVMCCodeGenerator >> maybeEmitPrimitiveFailureDefineFor: selector on: aStream [
	 (self vmClass notNil
	 and: [(self vmClass inheritsFrom: self vmmakerConfiguration baseInterpreterClass)
	 and: [(self vmClass primitiveTable includes: selector)]]) ifTrue:
		[aStream nextPutAll: '#else\# define ' withCRs; nextPutAll: selector; nextPutAll: ' (void (*)(void))0\' withCRs]
]

{ #category : #'C translation support' }
MLVMCCodeGenerator >> maybeGenerateCASTPrimitiveFailureDefineFor: selector [
	 (self vmClass notNil
	 and: [(self vmClass inheritsFrom: self vmmakerConfiguration baseInterpreterClass)
	 and: [(self vmClass primitiveTable includes: selector)]]) ifTrue:
		[^ CPreprocessorDefineNode token: (CIdentifierNode name: selector) rawMacro: '(void (*)(void))0' ].
	^ nil
]

{ #category : #translating }
MLVMCCodeGenerator >> mostBasicConstantSelectors [

	^ self constantClass mostBasicConstantSelectors
]

{ #category : #inlining }
MLVMCCodeGenerator >> mustBeGlobal: aName [
	^ self vmClass mustBeGlobal: aName
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> nilTranslation [
	"Defined in some header file as a macro?"
	^ 'null'
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> optionIsTrue: pragma in: aClass [
	"Answer whether an option: or notOption: pragma is true in the context of aClass.
	 The argument to the option: pragma is interpreted as either a Cogit class name
	 or a class variable name or a variable name in VMBasicConstants."
	| key |
	key := pragma argumentAt: 1.
	
	(super optionIsTrue: pragma in: aClass) ifTrue:
		[^true].

	"If the option is the name of a subclass of Cogit or the memory manager,
	include it if it inherits from the one of the configured classes
	otherwise, do not include it and cut here"
	(self environment classNamed: key) ifNotNil:
		[:optionClass|
		 aClass cogitClass ifNotNil:
			[:cogitClass|
			  (optionClass isCogitClass) ifTrue:
				[^cogitClass includesBehavior: optionClass]].
		 aClass objectMemoryClass ifNotNil:
			[:objectMemoryClass|
			 (optionClass isSpurMemoryManagerClass) ifTrue:
				[^objectMemoryClass includesBehavior: optionClass]]].
	
	"Lookup options in options, class variables of the defining class, VMBasicConstants, the interpreterClass and the objectMemoryClass"
	{aClass initializationOptions.
	  aClass.
	  self constantClass.
	  aClass interpreterClass.
	  aClass objectMemoryClass} do:
		[:scopeOrNil|
		 scopeOrNil ifNotNil:
			[:scope|
			 (scope bindingOf: key) ifNotNil:
				[:binding|
				binding value ~~ false ifTrue: [ ^true ]]]].
	^false
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> removeVariable: aName [

	"Remove the given (instance) variable from the code base."

	self removeVariable: aName ifAbsent: [ 
		(self vmClass notNil and: [ 
			 self vmClass isNonArgumentImplicitReceiverVariableName: aName ]) 
			ifFalse: [ 
				self error: 'warning, variable ' , aName
					, ' doesn''t exist or has already been removed' ] ]
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> returnTypeForSend: sendNode in: aTMethod boundTo: aCalledMethod typeIfNil: typeIfNil [
	"Answer the return type for a send.  Unbound sends default to typeIfNil.
	 Methods with types as yet unknown have a type determined either by the
	 kernelReturnTypes or by the common definitions in the superclass.

	 The inferred type should match as closely as possible the C type of
	 generated expessions so that inlining would not change the expression"

	^ self kernelReturnTypes
		at: sendNode selector
		ifAbsent: [
			super
				returnTypeForSend: sendNode
				in: aTMethod
				boundTo: aCalledMethod
				typeIfNil: typeIfNil ]
]

{ #category : #'C translation support' }
MLVMCCodeGenerator >> shouldGenerateAsInterpreterProxySend: aSendNode [
	^(self messageReceiverIsInterpreterProxy: aSendNode)
	  and: [(self constantClass mostBasicConstantSelectors includes: aSendNode selector) not]
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> shouldGenerateHeader [
	^ [ 
	  ((self class monticelloDescriptionFor: self vmClass) includes: $*)
		  not ]
		  on: Error
		  do: [ :ex | false ]
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> shouldGenerateStruct: structClass [

	^ (super shouldGenerateStruct: structClass)
		and: [self vmClass shouldGenerateTypedefFor: structClass]
]

{ #category : #public }
MLVMCCodeGenerator >> storeAPIExportHeader: headerName OnFile: fullHeaderPath [
	"Store C header code on the given file. Evaluate
	 aBlock with the stream to generate its contents."

	| header |
	header := String streamContents:
				[:s|
				 s nextPutAll: (self fileHeaderVersionStampForSourceClass: nil); newLine.
				 self emitCAPIExportHeaderOn: s].
	(self needToGenerateHeader: headerName file: fullHeaderPath contents: header) ifTrue:
		[self storeHeaderOnFile: fullHeaderPath contents: header]
]

{ #category : #'C translation support' }
MLVMCCodeGenerator >> unusedConstants [

	| unused |
	unused := super unusedConstants.
	"and VMBasicConstants mostBasicConstantNames *must* be taken from interp.h"
	unused addAll: self constantClass mostBasicConstantNames.
	^ unused
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> validateCppIf: nodeOrNil withValue: value [

	(self vmClass notNil and: [ 
		 nodeOrNil arguments first isConstant and: [ 
			 value isSymbol and: [ 
				 (self vmClass defineAtCompileTime: value) not and: [ 
					 (self vmClass bindingOf: value) notNil ] ] ] ]) ifTrue: [ 
		self logger
			nextPutAll: 'Warning: cppIf: reference to ';
			store: value;
			nextPutAll: ' when variable of same name exists.';
			newLine ]
]

{ #category : #'compile-time-options' }
MLVMCCodeGenerator >> valueForContant: node ifAbsent: default [
	^ self vmClass
		  ifNotNil: [ 
			  (self vmClass specialValueForConstant: node name default: default)
				  ifNotNil: [ :specialDef | specialDef ]
				  ifNil: [ default ] ]
		  ifNil: [ default ]
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> valueOfConstantNode: aNode doing: aBlock [
	(self constantClass valueOfBasicSelector: aNode selector) ifNotNil: [ 
		:value | 
		aBlock value: value.
		^ true ].
	^ super valueOfConstantNode: aNode doing: aBlock
]

{ #category : #accessing }
MLVMCCodeGenerator >> vmClass [
	"Answer the interpreter class if any.  This is nil other than for the core VM."
	^vmClass
]

{ #category : #accessing }
MLVMCCodeGenerator >> vmClass: aClass [
	"Set the main translation class if any.  This is nil other than for the core VM.
	 It may be an interpreter or a cogit"
	vmClass := aClass.
	vmClass ifNotNil:
		[generateDeadCode := vmClass shouldGenerateDeadCode]
]

{ #category : #'C code generator' }
MLVMCCodeGenerator >> vmHeaderContentsWithBytesPerWord: bytesPerWord [
	"Store C header code on the given stream."

	^ ByteString
		streamContents: [ :tempStream | self vmClass writeVMHeaderTo: tempStream bytesPerWord: bytesPerWord generator: self ]
]

{ #category : #accessing }
MLVMCCodeGenerator >> vmMaker [
	^vmMaker
]

{ #category : #accessing }
MLVMCCodeGenerator >> vmMaker: aVMMaker [
	vmMaker := aVMMaker
]

{ #category : #accessing }
MLVMCCodeGenerator >> vmmakerConfiguration [
	
	^ self vmMaker vmmakerConfiguration
]
