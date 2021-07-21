"
This class oversees the translation of a subset of Smalltalk to C, allowing the comforts of Smalltalk during development and the efficiency and portability of C for the resulting interpreter.  
See VMMaker for more useful info

# toto
"
Class {
	#name : #CCodeGenerator,
	#superclass : #Object,
	#instVars : [
		'structClasses',
		'translationDict',
		'asArgumentTranslationDict',
		'inlineList',
		'constants',
		'variables',
		'variableDeclarations',
		'scopeStack',
		'methods',
		'macros',
		'apiMethods',
		'apiVariables',
		'kernelReturnTypes',
		'currentMethod',
		'headerFiles',
		'globalVariableUsage',
		'useSymbolicConstants',
		'generateDeadCode',
		'requiredSelectors',
		'previousCommentMarksInlining',
		'previousCommenter',
		'logger',
		'suppressAsmLabels',
		'asmLabelCounts',
		'pools',
		'selectorTranslations',
		'staticallyResolvedPolymorphicReceivers',
		'optionsDictionary',
		'breakSrcInlineSelectors',
		'breakDestInlineSelectors',
		'breakOnInline',
		'environment',
		'compileTimeOptions',
		'stopOnErrors',
		'castTranslationDict',
		'castAsArgumentTranslationDict',
		'wordSize'
	],
	#classVars : [
		'NoRegParmsInAssertVMs'
	],
	#category : #'Slang-CodeGeneration'
}

{ #category : #'class initialization' }
CCodeGenerator class >> initialize [
	"CCodeGenerator initialize"

	NoRegParmsInAssertVMs := true
		"If NoRegParmsInAssertVMs is true the generator spits out an attribute turning off register parameters for static functions in the Assert and Debug VMs which makes debugging easier, since all functions can be safely called from gdb.  One might hope that -mregparm=0 would work but at least on Mac OS X's gcc 4.2.1 it does not and hence we have to use a per funciton attribute.  Sigh..."
]

{ #category : #testing }
CCodeGenerator class >> isVarargsSelector: aRBSelectorNode [
	^aRBSelectorNode value endsWith: 'printf:'
]

{ #category : #'C code generator' }
CCodeGenerator class >> monticelloDescriptionFor: aClass [
	"Answer a suitable Monticello package stamp to include in the header."
	| pkgInfo pkg uuid |
	pkgInfo := aClass package.
	pkg := MCWorkingCopy allManagers detect: [:ea| ea packageName = pkgInfo packageName].
	pkg ancestry ancestors isEmpty ifFalse:
		[uuid := pkg ancestry ancestors first id].
	^aClass name, (pkg modified ifTrue: [' * '] ifFalse: [' ']), pkg ancestry ancestorString, ' uuid: ', uuid asString
]

{ #category : #'C code generator' }
CCodeGenerator class >> shortMonticelloDescriptionForClass: aClass [
	"Answer a suitable Monticello package stamp to include in a moduleName."
	| mdesc |
	mdesc := [self monticelloDescriptionFor: aClass]
				on: Error
				do: [:ex| ^' ', Date today asString].
	^mdesc copyFrom: 1 to: (mdesc indexOfSubCollection: ' uuid:') - 1
]

{ #category : #accessing }
CCodeGenerator >> abortBlock [
	^ nil
]

{ #category : #public }
CCodeGenerator >> addAllClassVarsFor: aClass [
	"Add the class variables for the given class (and its superclasses) to the code base as constants."

	| allClasses |
	allClasses := aClass withAllSuperclasses.
	allClasses do: [:c | self addClassVarsFor: c].

]

{ #category : #public }
CCodeGenerator >> addClass: aClass [
	"Add the variables and methods of the given class to the code base."

	self addClass: aClass silently: false
]

{ #category : #public }
CCodeGenerator >> addClass: aClass silently: silentlyBoolean [
	"Add the variables and methods of the given class to the code base."

	aClass prepareToBeAddedToCodeGenerator: self.
	self checkClassForNameConflicts: aClass.
	self addClassVarsFor: aClass.
	"ikp..."
	self addPoolVarsFor: aClass.
	(aClass inheritsFrom: SlangStructType) ifFalse:
		[variables addAll: (self instVarNamesForClass: aClass)].
	self retainMethods: (aClass requiredMethodNames: self options).
	
	silentlyBoolean ifTrue: [ 
		aClass selectors do: [:sel | self addMethodFor: aClass selector: sel ].
		aClass declareCVarsIn: self.
		^ self
	].

	"Not silent"
	UIManager default
		displayProgress: 'Adding Class ' , aClass name , '...'
		from: 0
		to: aClass selectors size
		during:
			[:bar |
			 aClass selectors doWithIndex:
				[:sel :i |
				bar value: i.
				self addMethodFor: aClass selector: sel]].
	aClass declareCVarsIn: self
]

{ #category : #public }
CCodeGenerator >> addClassVarsFor: aClass [
	"Add the class variables for the given class to the code base as constants."
	aClass classPool associationsDo:
		[:assoc | self addConstantForBinding: assoc]
]

{ #category : #public }
CCodeGenerator >> addConstantForBinding: variableBinding [
	"Add the pool variable to the code base as a constant."
	| node val |
	val := variableBinding value.
	node := (useSymbolicConstants and: [self isCLiteral: val])
				ifTrue:[TDefineNode new
							setName: variableBinding key
							value: variableBinding value]
				ifFalse:[TConstantNode value: variableBinding value].
	constants at: variableBinding key put: node
]

{ #category : #public }
CCodeGenerator >> addHeaderFile: aString [
	"Add a header file. As a hack we allow C preprocessor defs such as #ifdef"
	self assert: (('"<#' includes: aString first) or: [(aString last: 2) = '_H']).
	(aString first ~= $#
	 and: [headerFiles includes: aString]) ifTrue:
		[logger nextPutAll: 'warning, attempt to include ', aString, ' a second time'; cr; flush.
		 ^self].
	headerFiles addLast: aString
]

{ #category : #public }
CCodeGenerator >> addHeaderFileFirst: aString [
	"Add a header file to the front of the sequence."
	self assert: (('"<' includes: aString first) and: ['">' includes: aString last]).
	self assert: (headerFiles includes: aString) not.
	headerFiles addFirst: aString
]

{ #category : #public }
CCodeGenerator >> addMacro: aString for: selector [
	"Add a macro. aString must be the macro arguments and body without the leading #define or name"
	macros at: selector put: aString
]

{ #category : #utilities }
CCodeGenerator >> addMethod: aTMethod [
	"Add the given method to the code base and answer it.
	 Only allow duplicate definitions for struct accessors, since we don't actually
	 generate code for these methods and hence the conflict doesn't matter.
	 Allow subclasses to redefine methods (Smalltalk has inheritance after all)."

	(methods at: aTMethod selector ifAbsent: []) ifNotNil:
		[:conflict |
		aTMethod compiledMethod isSubclassResponsibility ifTrue:
			[^nil].
		(conflict isStructAccessor
		 and: [aTMethod isStructAccessor
		 and: [conflict compiledMethod decompileString = aTMethod compiledMethod decompileString]]) ifTrue:
			[^nil].
		((aTMethod definingClass inheritsFrom: conflict definingClass)
		 or: [(aTMethod compiledMethod pragmaAt: #option:) notNil]) ifFalse:
			[self error: 'Method name conflict: ', aTMethod selector]].
	^methods at: aTMethod selector put: aTMethod
]

{ #category : #utilities }
CCodeGenerator >> addMethodFor: aClass selector: selector [
	"Add the given method to the code base and answer its translation
	 or nil if it shouldn't be translated."

	| method tmethod |
	method := aClass compiledMethodAt: selector.
	(method pragmaAt: #doNotGenerate) ifNotNil:
		["only remove a previous method if this one overrides it, i.e. this is a subclass method.
		 If the existing method is in a different hierarchy this method must be merely a redeirect."
		 (methods at: selector ifAbsent: []) ifNotNil:
			[:tm|
			(aClass includesBehavior: tm definingClass) ifTrue:
				[self removeMethodForSelector: selector]].
		 ^nil].
	method isSubclassResponsibility ifTrue:
		[^nil].
	(self shouldIncludeMethodFor: aClass selector: selector) ifFalse:
		[^nil].
	tmethod := self compileToTMethodSelector: selector in: aClass.
	"Even though we exclude initialize methods, we must consider their
	 global variable usage, otherwise globals may be incorrectly localized."
	selector == #initialize ifTrue:
		[self checkForGlobalUsage: (tmethod allReferencedVariablesUsing: self) in: tmethod.
		 ^nil].
	self addMethod: tmethod.
	"If the method has a macro then add the macro.  But keep the method
	 for analysis purposes (e.g. its variable accesses)."
	(method pragmaAt: #cmacro:) ifNotNil:
		[:pragma|
		self addMacro: (pragma argumentAt: 1) for: selector.
		(inlineList includes: selector) ifTrue:
			[inlineList := inlineList copyWithout: selector]].
	(method pragmaAt: #cmacro) ifNotNil:
		[:pragma| | literal | "Method should be just foo ^const"
		self assert: (method numArgs = 0 and: [method numLiterals = 3 or: [method isQuick]]).
		literal := method isQuick
					ifTrue: [method decompile quickMethodReturnLiteral]
					ifFalse: [method literalAt: 1].
		self addMacro: '() ', (method isReturnField
								ifTrue: [literal]
								ifFalse: [self cLiteralFor: literal value name: method selector]) for: selector.
		(inlineList includes: selector) ifTrue:
			[inlineList := inlineList copyWithout: selector]].
	^tmethod
]

{ #category : #public }
CCodeGenerator >> addMethodsForTranslatedPrimitives: classAndSelectorList [ 
	| verbose |
	verbose := false.
	classAndSelectorList do:
		[:classAndSelector | | aClass selector meth |
		aClass := Smalltalk at: classAndSelector first.
		selector := classAndSelector last.
		self addAllClassVarsFor: aClass.

		"compile the method source and convert to a suitable translation method.
		 find the method in either the class or the metaclass"
		meth := self
					compileToTMethodSelector: selector
					in: ((aClass includesSelector: selector)
							ifTrue: [aClass]
							ifFalse: [aClass class]).
		meth primitive > 0 ifTrue:
			[meth preparePrimitiveName].
		meth replaceSizeMessages.
		self addMethod: meth].

	self prepareMethods
]

{ #category : #public }
CCodeGenerator >> addPoolVarsFor: aClass [ 
	"Add the pool variables for the given class to the code base as constants."

	(aClass sharedPools reject: [:pool| pools includes: pool]) do:
		[:pool |
		pools add: pool.
		pool bindingsDo:
			[:binding |
			self addConstantForBinding: binding]]
]

{ #category : #public }
CCodeGenerator >> addSelectorTranslation: aSelector to: aString [
	selectorTranslations at: aSelector asSymbol put: aString
]

{ #category : #public }
CCodeGenerator >> addStructClass: aClass [
	"Add the non-accessor methods of the given struct class to the code base."

	^ self addStructClass: aClass silently: false
]

{ #category : #public }
CCodeGenerator >> addStructClass: aClass silently: silentlyBoolean [
	"Add the non-accessor methods of the given struct class to the code base."

	aClass prepareToBeAddedToCodeGenerator: self.
	self addClassVarsFor: aClass.
	self addPoolVarsFor: aClass.
	self retainMethods: (aClass requiredMethodNames: self options).
	
	"Silent version"
	silentlyBoolean ifTrue: [
		aClass selectors do: [:sel | self addStructMethodFor: aClass selector: sel ].
		aClass declareCVarsIn: self.
		^ self
	].
	
	"Non silent version"
	UIManager default
		displayProgress: 'Adding Class ' , aClass name , '...'
		from: 0
		to: aClass selectors size
		during:
			[:bar |
			 aClass selectors doWithIndex:
				[:sel :i |
				bar value: i.
				self addStructMethodFor: aClass selector: sel]].
	aClass declareCVarsIn: self
]

{ #category : #accessing }
CCodeGenerator >> addStructClasses: classes [
	"Add the struct classes and save them for emitCTypesOn: later."
	structClasses := classes.
	structClasses do:
		[:structClass|
		 (structClass withAllSuperclasses copyUpTo: structClass baseStructClass) do:
			[:structClassOrSuperclass|
			 self addStructClass: structClassOrSuperclass]]
]

{ #category : #accessing }
CCodeGenerator >> addStructClasses: classes silently: aSilentlyBoolean [
	"Add the struct classes and save them for emitCTypesOn: later."
	structClasses := classes.
	structClasses do:
		[:structClass|
		 (structClass withAllSuperclasses copyUpTo: SlangStructType) do:
			[:structClassOrSuperclass|
			 self addStructClass: structClassOrSuperclass silently: aSilentlyBoolean ]]
]

{ #category : #utilities }
CCodeGenerator >> addStructMethodFor: aClass selector: selector [ 
	"Add the given struct method to the code base and answer its translation
	 or nil if it shouldn't be translated."
	(self methodNamed: selector) ifNotNil:
		[:tmethod|
		 "If we're repeating an attempt to add the same thing, or
		  if the existing method overrides this one,don't complain."
		 (tmethod definingClass includesBehavior: aClass) ifTrue:
			[^self].
		 "If the methods are both simple accessors, don't complain."
		 ((tmethod definingClass isAccessor: selector)
		 and: [aClass isAccessor: selector]) ifTrue:
			[^self].
		 "If the method is overriding a method in a superclass, don't complain"
		 (aClass inheritsFrom: tmethod definingClass)
			ifTrue: [methods removeKey: selector]
			ifFalse: [self error: 'conflicting implementations for ', selector storeString]].
	^(self addMethodFor: aClass selector: selector) ifNotNil:
		[:tmethod|
		tmethod transformToStructClassMethodFor: self.
		tmethod]
]

{ #category : #utilities }
CCodeGenerator >> addVariablesInVerbatimCIn: aCCodeSendNode to: aCollection [
	"If aCCodeSendNode has a string argument, parse it and extract anything
	 that looks like a variable, and add the resulting vars to aCollection."
	| separators tokens |
	(aCCodeSendNode isSend
	 and: [(aCCodeSendNode selector beginsWith: #cCode:)
	 and: [aCCodeSendNode args first isConstant
	 and: [aCCodeSendNode args first value isString]]]) ifFalse:
		[^self].
	separators := (Character space to: 255 asCharacter) reject:
					[:char|
					char isLetter or: [char isDigit or: [char = $_]]].
	tokens := aCCodeSendNode args first value findTokens: separators.
	aCollection addAll: (tokens select: [:token| token first isLetter]) asSet
]

{ #category : #utilities }
CCodeGenerator >> anyMethodNamed: selector [
	"Answer any method in the code base (including api methods) with the given selector."

	^methods
		at: selector
		ifAbsent:
			[apiMethods ifNotNil:
				[apiMethods
					at: selector
					ifAbsent: []]]
]

{ #category : #accessing }
CCodeGenerator >> apiMethods [

	^ apiMethods
]

{ #category : #utilities }
CCodeGenerator >> arrayInitializerCalled: varName for: array sizeString: sizeStringOrNil type: cType [
	"array is a literal array or a CArray on some array."
	^String streamContents:
		[:s| | sequence lastLine index newLine allIntegers |
		sequence := array isCollection ifTrue: [array] ifFalse: [array object].
		"this is to align -ve and +ve integers nicely in the primitiveAccessorDepthTable"
		allIntegers := sequence allSatisfy: [:element| element isInteger].
		lastLine := index := 0.
		newLine := [sequence size >= 20
						ifTrue: [s cr; nextPutAll: '/*'; print: index; nextPutAll: '*/'; tab]
						ifFalse: [s crtab: 2].
					 lastLine := s position].
		s	nextPutAll: cType;
			space;
			nextPutAll: varName;
			nextPut: $[.
		sizeStringOrNil ifNotNil: [s nextPutAll: sizeStringOrNil].
		s nextPutAll: '] = '.
		sequence isString
			ifTrue: [s nextPutAll: (self cLiteralFor: sequence)]
			ifFalse:
				[s nextPut: ${.
				 newLine value.
				 sequence
					do: [:element|
						(allIntegers
						 and: [element < 0
						 and: [s peekLast = Character space]]) ifTrue:
							[s skip: -1].
						s nextPutAll: (self cLiteralFor: element). index := index + 1]
					separatedBy:
						[s nextPut: $,.
						 ((s position - lastLine) >= 76
						 or: [(index \\ 20) = 0])
							ifTrue: [newLine value]
							ifFalse: [s space]].
				 s crtab; nextPut: $}]]
]

{ #category : #utilities }
CCodeGenerator >> asmLabelNodeFor: selector [
	| count label |
	suppressAsmLabels ifTrue: [^CEmptyStatementNode new].
	asmLabelCounts ifNil:
		[asmLabelCounts := Dictionary new].
	count := asmLabelCounts
				at: selector
				put: 1 + (asmLabelCounts at: selector ifAbsent: [-1]).
				
	label := (self cFunctionNameFor: selector), (count = 0 ifTrue: [''] ifFalse: [count printString]).
	^ CCallNode
			identifier: (CIdentifierNode name: 'VM_LABEL')
			arguments: { CIdentifierNode name: label }
]

{ #category : #utilities }
CCodeGenerator >> baseTypeForPointerType: aCType [
	"Answer the type of the referent of a pointer type."
	self assert: aCType last == $*.
	^self baseTypeForType: aCType allButLast
]

{ #category : #utilities }
CCodeGenerator >> baseTypeForType: aCType [
	"Reduce various declarations to the most basic type we can determine."
	| type fpIndex closeidx openidx |
	type := aCType.
	((openidx := type indexOfSubCollection: 'const ') > 0
	and: [openidx = 1 or: [(type at: openidx) isSeparator]]) ifTrue:
		[type := type copyReplaceFrom: openidx to: openidx + 5 with: ''].
	((type beginsWith: 'unsigned') and: [(type includes: $:) and: [type last isDigit]]) ifTrue:
		[^#usqInt].
	"collapse e.g. void (*foo(int bar))(void) to void (*)(void)"
	(fpIndex := type indexOfSubCollection: '(*') > 0 ifTrue:
		["elide the function arguments after *, if there are any"
		 type := type copyReplaceFrom: (type indexOf: $( startingAt: fpIndex + 1)
					to: (type indexOf: $) startingAt: fpIndex + 1)
					with: ''.
		 "elide the function name after *, if there is one"
		 type := type copyReplaceFrom: fpIndex + 2
					to: (type indexOf: $) startingAt: fpIndex + 1)
					with: ')'].
	"collapse [size] to *"
	openidx := 0.
	[(openidx := type indexOf: $[ startingAt: openidx + 1) > 0
	 and: [(closeidx := type indexOf: $] startingAt: openidx + 1) > 0]] whileTrue:
		[type := type copyReplaceFrom: openidx to: closeidx with: '*'].

	"map foo* to foo *"
	^self conventionalTypeForType: type
]

{ #category : #accessing }
CCodeGenerator >> breakDestInlineSelector: aSelector [
	breakDestInlineSelectors add: aSelector
]

{ #category : #accessing }
CCodeGenerator >> breakOnInline: aBooleanOrNil [
	breakOnInline := aBooleanOrNil
]

{ #category : #accessing }
CCodeGenerator >> breakSrcInlineSelector: aSelector [
	breakSrcInlineSelectors add: aSelector
]

{ #category : #inlining }
CCodeGenerator >> bytesPerOop [
	^ 8
]

{ #category : #inlining }
CCodeGenerator >> bytesPerWord [
	^ 8
]

{ #category : #utilities }
CCodeGenerator >> cCodeForMethod: selector [

	"Answer a string containing the C code for the given method."

	"Example:
		((CCodeGenerator new initialize addClass: TestCClass1; prepareMethods)
			cCodeForMethod: #ifTests)"

	| m s cast |
	m := self methodNamed: selector.
	m = nil ifTrue: [ 
		self error: 'method not found in code base: ' , selector ].

	s := ReadWriteStream on: ''.
	cast := m asCASTIn: self.
	cast prettyPrintOn: s.
	^ s contents
]

{ #category : #'C code generator' }
CCodeGenerator >> cFunctionNameFor: aSelector [
	"Create a C function name from the given selector by finding
	 a specific translation, or if none, simply omitting colons, and
	 any trailing underscores (this supports a varargs convention)."
	^selectorTranslations
		at: aSelector
		ifAbsent:
			[| cSelector |
			 cSelector := aSelector copyWithout: $:.
			 aSelector last = $: ifTrue:
				[[cSelector last = $_] whileTrue:
					[cSelector := cSelector allButLast]].
			 cSelector]
]

{ #category : #'C code generator' }
CCodeGenerator >> cLiteralFor: anObject [
	"Return a string representing the C literal value for the given object."
	anObject isNumber
		ifTrue:
			[anObject isInteger ifTrue:
				[| hex |
				 hex := (anObject > 0
								and: [(anObject >> anObject lowBit + 1) isPowerOfTwo
								and: [(anObject highBit = anObject lowBit and: [anObject > 65536])
									  or: [anObject highBit - anObject lowBit >= 4]]]).
				^self cLiteralForInteger: anObject hex: hex].
			anObject isFloat ifTrue:
				[^anObject printString]]
		ifFalse:
			[anObject isSymbol ifTrue:
				[^self cFunctionNameFor: anObject].
			anObject isString ifTrue:
				[^'"', (anObject copyReplaceAll: (String with: Character cr) with: '\n') , '"'].
			anObject == nil ifTrue: [^ self nilTranslation ].
			anObject == true ifTrue: [^ '1' ].
			anObject == false ifTrue: [^ '0' ].
			anObject isCharacter ifTrue:
				[^anObject == $'
					ifTrue: ['''\'''''] "i.e. '\''"
					ifFalse: [anObject asString printString]]].
	self error: 'Warning: A Smalltalk literal could not be translated into a C constant: ', anObject printString.
	^'"XXX UNTRANSLATABLE CONSTANT XXX"'
]

{ #category : #'C code generator' }
CCodeGenerator >> cLiteralFor: anObject name: smalltalkName [
	"Return a string representing the C literal value for the given object.
	 This version may use hex for integers that are bit masks."

	anObject isInteger
		ifTrue: [ | hex dec useHexa |
			hex := anObject printStringBase: 16.
			dec := anObject printStringBase: 10.
			useHexa := (smalltalkName endsWith: 'Mask')
				or: [ anObject bytesCount > 1
						and: [ hex asSet size * 3 <= (dec asSet size * 2)
								and: [ (smalltalkName endsWith: 'Size') not ] ] ].
			^ self cLiteralForInteger: anObject hex: useHexa ].
	^ self cLiteralFor: anObject
]

{ #category : #'C code generator' }
CCodeGenerator >> cLiteralForInteger: anInteger hex: aBoolean [
	"Answer the string for generating a literal integer.
	Use hexadecimal notation as prescribed by aBoolean.
	Use long long suffix (LL) if the integer does not fit on 32 bits.
	Use unsigned suffix (U) if the integer does not fit on a signed integer (resp. long long).
	Correctly generate INT_MIN and LONG_LONG_MIN.
	Indeed -0x8000000 is parsed as - (0x8000000) by C Compiler.
	0x8000000 does not fit on a signed int, it is interpreted as unsigned.
	That makes INT_MIN unsigned which is badly broken..."
	
	| printString |
	printString := aBoolean
		ifTrue: [anInteger positive
			ifTrue: ['0x' , (anInteger printStringBase: 16)]
			ifFalse: ['-0x' , (anInteger negated printStringBase: 16)]]
		ifFalse: [anInteger printString].
	^anInteger positive
		ifTrue: [anInteger > 16r7FFFFFFF "INT_MAX"
			ifTrue: [anInteger > 16rFFFFFFFF "UINT_MAX"
				ifTrue: [anInteger > 16r7FFFFFFFFFFFFFFF "LONG_LONG_MAX"
					ifTrue: [printString , 'ULL']
					ifFalse: [printString , 'LL']]
				ifFalse: [printString , 'U']]
			ifFalse: [printString]]
		ifFalse: [anInteger < -16r8000000
			ifTrue: [anInteger = -16r800000000000000	"LONG_LONG_MIN"
				ifTrue: ['(-0x7FFFFFFFFFFFFFFFLL-1)']
				ifFalse: [printString , 'LL']]
			ifFalse: [anInteger = -16r8000000	"INT_MIN"
				ifTrue: ['(-0x7FFFFFFF-1)']
				ifFalse: [printString]]]
]

{ #category : #'C code generator' }
CCodeGenerator >> cLiteralForPrintfString: aString [
	^(('"', (PrintfFormatString new setFormat: aString) transformForVMMaker, '"')
		copyReplaceAll: (String with: Character cr) with: '\n')
			copyReplaceAll: (String with: Character tab) with: '\t'
]

{ #category : #'C code generator' }
CCodeGenerator >> cLiteralForUnsignedInteger: anInteger hex: aBoolean longlong: llBoolean [
	"Answer the string for generating an unsigned literal integer.
	Use hexadecimal notation as prescribed by aBoolean.
	Force long long suffix (LL) if the integer does not fit on 32 bits, or if llBoolean is true."
	
	| printString |
	printString := aBoolean
		ifTrue: [anInteger positive
			ifTrue: ['0x' , (anInteger printStringBase: 16)]
			ifFalse: ['-0x' , (anInteger negated printStringBase: 16)]]
		ifFalse: [anInteger printString].
	^anInteger positive
		ifTrue: [(llBoolean or: [anInteger > 16rFFFFFFFF "UINT_MAX"])
			ifTrue: [printString , 'ULL']
			ifFalse: [printString , 'U']]
		ifFalse: [self error: 'please provide positive integer']
]

{ #category : #'C code generator' }
CCodeGenerator >> cLiteralForUnsignedInteger: anInteger longlong: llBoolean [
	"Answer the string for generating an unsigned literal integer.
	Eventually use hexadecimal.
	Force long long suffix (LL) if the integer does not fit on 32 bits, or if llBoolean is true."
	
	| hex |
	hex := (anInteger > 0
				and: [(anInteger >> anInteger lowBit + 1) isPowerOfTwo
				and: [(anInteger highBit = anInteger lowBit and: [anInteger > 65536])
					  or: [anInteger highBit - anInteger lowBit >= 4]]]).
	^self cLiteralForUnsignedInteger: anInteger hex: hex longlong: llBoolean
]

{ #category : #inlining }
CCodeGenerator >> cannotInline: selector [

	self error: 'Failed to inline ', selector,
			' as it contains unrenamable C declarations or C code'
]

{ #category : #'error notification' }
CCodeGenerator >> checkClassForNameConflicts: aClass [
	"Verify that the given class does not have constant, variable, or method names that conflict with
	 those of previously added classes. Raise an error if a conflict is found, otherwise just return."

	"check for constant name collisions in class pools"
	aClass classPool associationsDo:
		[:assoc |
		(constants includesKey: assoc key) ifTrue:
			[self error: 'Constant ', assoc key, ' was defined in a previously added class']].

	"and in shared pools"
	(aClass sharedPools reject: [:pool| pools includes: pool]) do:
		[:pool |
		pool bindingsDo:
			[:assoc |
			(constants includesKey: assoc key) ifTrue:
				[self error: 'Constant ', assoc key, ' was defined in a previously added class']]].

	"check for instance variable name collisions"
	(aClass inheritsFrom: SlangStructType) ifFalse:
		[(self instVarNamesForClass: aClass) do:
			[:varName |
			(variables includes: varName) ifTrue:
				[self error: 'Instance variable ', varName, ' was defined in a previously added class']]].

	"check for method name collisions"
	aClass selectors do:
		[:sel | | tmeth meth |
		((self shouldIncludeMethodFor: aClass selector: sel)
		and: [(tmeth := methods at: sel ifAbsent: nil) notNil
		and: [(aClass isStructClass and: [(aClass isAccessor: sel)
				and: [(methods at: sel) isStructAccessor]]) not
		and: [(meth := aClass >> sel) isSubclassResponsibility not
		and: [(aClass includesBehavior: tmeth definingClass) not]]]]) ifTrue:
			[((aClass >>sel) pragmaAt: #option:)
				ifNil: [self error: 'Method ', sel, ' was defined in a previously added class.']
				ifNotNil:
					[logger
						newLine;
						show: 'warning, method ', aClass name, '>>', sel storeString,
								' overrides ', tmeth definingClass, '>>', sel storeString;
						cr]]]
]

{ #category : #utilities }
CCodeGenerator >> checkDeleteVariable: aName [
	"Hook for debugging variable deletion."
]

{ #category : #utilities }
CCodeGenerator >> checkForGlobalUsage: vars in: aTMethod [ 
	vars do:
		[:var |
		(variables includes: var) ifTrue: "find the set of method names using this global var"
			[(globalVariableUsage at: var ifAbsentPut: [Set new])
				add: aTMethod selector]].
	aTMethod clearReferencesToGlobalStruct.
	(aTMethod locals select: [:l| self reservedWords includes: l]) do:
		[:l| | em |
		em := aTMethod definingClass name, '>>', aTMethod smalltalkSelector, ' has variable that is a C reserved word: ', l.
		self error: em.
		self logger cr; nextPutAll: em; cr; flush]
]

{ #category : #public }
CCodeGenerator >> codeString [
	"Return a string containing all the C code for the code base. Used for testing."

	| stream |
	stream := ReadWriteStream on: (String new: 1000).
	self emitCCodeOn: stream doInlining: true doAssertions: true.
	^stream contents
]

{ #category : #inlining }
CCodeGenerator >> collectInlineList: strategy [
	"Make a list of methods that should be inlined.  If inlineFlagOrSymbol == #asSpecified
	 only inline methods marked with <inline: true>.  If inlineFlagOrSymbol == #asSpecifiedOrQuick
	 only inline methods marked with <inline: true> or methods that are quick (^constant, ^inst var)."
	"Details: The method must not include any inline C, since the
	 translator cannot currently map variable names in inlined C code.
	 Methods to be inlined must be small or called from only one place."
	
	| selectorsOfMethodsNotToInline callsOf inlineStrategy |
	inlineStrategy := strategy asCCodeInlineStrategy.
	inlineStrategy codeGenerator: self.
		
	selectorsOfMethodsNotToInline := Set new: methods size.
	selectorsOfMethodsNotToInline addAll: macros keys.
	apiMethods ifNotNil: [ selectorsOfMethodsNotToInline addAll: apiMethods keys ].
	selectorsOfMethodsNotToInline addAll: self structAccessorSelectors.

	"build dictionary to record the number of calls to each method"
	callsOf := Dictionary new: methods size * 2.
	methods keysAndValuesDo:
		[:s :m|
		(m isRealMethod
		 and: [self shouldGenerateMethod: m]) ifTrue:
			[callsOf at: s put: 0]].

	"For each method, scan its parse tree once or twice to:
		1. determine if the method contains unrenamable C code or declarations or has a C builtin
		2. determine how many nodes it has
		3. increment the sender counts of the methods it calls"
	inlineList := Set new: methods size * 2.
	methods
		reject: [:m|
			(selectorsOfMethodsNotToInline includes: m selector)
				or: [ self isSpecialSelector: m selector ] ]
		thenDo: [:m|
			m parseTree nodesDo: [:node|
				node isSend ifTrue: [
					callsOf
						at: node selector
						ifPresent: [:senderCount| callsOf at: node selector put: senderCount + 1 ] ] ].

		inlineStrategy validateCanInline: m.
		(inlineStrategy canInline: m)
			ifFalse: [ selectorsOfMethodsNotToInline add: m selector ]
			ifTrue: [
				(inlineStrategy shouldInlineMethod: m)
					ifTrue: [ 
						"inline if method has no C code and is either small or contains inline directive"
						inlineList add: m selector]
					ifFalse: [
						inlineStrategy isSelectiveInlineStrategy
							ifTrue: [selectorsOfMethodsNotToInline add: m selector] ] ] ].

	inlineStrategy isSelectiveInlineStrategy
		ifTrue:
			[methods do: [:m| m inline ifNil: [m inline: (inlineList includes: m selector)]]]
		ifFalse:
			[callsOf associationsDo:
				[:assoc|
				(assoc value = 1
				 and: [(selectorsOfMethodsNotToInline includes: assoc key) not]) ifTrue:
					[ inlineList add: assoc key ]]]
]

{ #category : #accessing }
CCodeGenerator >> compileTimeOptions: aCollection [ 
	
	compileTimeOptions := aCollection
]

{ #category : #utilities }
CCodeGenerator >> compileToTMethodSelector: selector in: aClass [
	"Compile a method to a TMethod"
	^(aClass >> selector) asTranslationMethodOfClass: self translationMethodClass forCodeGenerator: self.

	"was:
	| implementingClass |
	implementingClass := aClass.
	^(Compiler new
		parse: ([aClass sourceCodeAt: selector]
					on: KeyNotFound
					do: [:ex| ""Quick hack for simulating Pharo images...""
						(PharoVM and: [aClass == String class and: [selector == #findSubstringViaPrimitive:in:startingAt:matchTable:]]) ifFalse:
							[ex pass].
						(implementingClass := ByteString) sourceCodeAt: #findSubstring:in:startingAt:matchTable:])
		in: implementingClass
		notifying: nil)
			asTranslationMethodOfClass: self translationMethodClass"
]

{ #category : #public }
CCodeGenerator >> const: constName declareC: declarationString [
	"Record the given C declaration for a constant."

	constants
		at: constName
		put: (TDefineNode new
				setName: constName
				value: declarationString)
]

{ #category : #'C code generator' }
CCodeGenerator >> constants [

	^ constants keys
]

{ #category : #utilities }
CCodeGenerator >> conventionalTypeForType: aCTypeString [
	"The pointer type convention in this version of VMMaker is to have a space between the base type and any *'s.
	 C type comparisons are simple string comparisons; therefore the convention matters.
	 Ensure there is a space between the base type and any trailing *'s. Trim whitespace."
	| type index |
	type := aCTypeString withBlanksTrimmed.
	index := type size.
	[(type at: index) == $*] whileTrue:
		[index := index - 1].
	(index < type size
	 and: [(type at: index) ~~ Character space]) ifTrue:
		[type := (type copyFrom: 1 to: index), ' ', (type copyFrom: index + 1 to: type size)].
	^type asSymbol
]

{ #category : #accessing }
CCodeGenerator >> currentMethod [
	^currentMethod
]

{ #category : #accessing }
CCodeGenerator >> currentMethod: aTMethod [
	previousCommenter := nil.
	currentMethod := aTMethod
]

{ #category : #public }
CCodeGenerator >> declareModuleName: nameString [
	"add the declaration of a module name, version and local/external tag"

	self var: #moduleName declareC:'const char *moduleName =
#ifdef SQUEAK_BUILTIN_PLUGIN
	"', nameString,' (i)"
#else
	"', nameString,' (e)"
#endif
'.
	"and for run-time use, answer the string"
	^nameString, ' (i)'
]

{ #category : #public }
CCodeGenerator >> declareVar: varName type: type [
	"This both creates a varable and provides its type"
	self var: (variables add: varName asString) type: type
]

{ #category : #'C code generator' }
CCodeGenerator >> declaredConstants [
	^ constants keys asSet
]

{ #category : #'type inference' }
CCodeGenerator >> defaultType [
	
	^ #int
]

{ #category : #'compile-time-options' }
CCodeGenerator >> defineAtCompileTime: aString [ 
	"Define if the code generator should define the option at compile time or at generation time.
	If true, the decision of the option will be delayed to compilation time.
	Otherwise, do it at transpilation time, 
	 - the code with the option is generated if the value of the option is true
	 - if not true or unset, do not generate"
	compileTimeOptions ifNil: [ ^ false ].
	^ (compileTimeOptions includes: aString)
]

{ #category : #inlining }
CCodeGenerator >> doBasicInlining: inlineFlagOrSymbol [
	"Inline the bodies of all methods that are suitable for inlining.
	This method does only the basic inlining suitable for both the core VM and plugins - no bytecode inlining etc"

	| pass progress |
	self collectInlineList: inlineFlagOrSymbol.
	pass := 0.
	progress := true.
	[progress] whileTrue: [
		"repeatedly attempt to inline methods until no further progress is made"
		progress := false.
		UIManager default
			displayProgress: ('Inlining pass ', (pass := pass + 1) printString, '...')
			from: 0 to: methods size
			during: [:bar |
				(self sortMethods: methods) doWithIndex: [:m :i |
					bar value: i.
					currentMethod := m.
					(m tryToInlineMethodsIn: self)
						ifTrue: [progress := true]]]].


]

{ #category : #inlining }
CCodeGenerator >> doInlining: inlineFlag [
	"do inlining for a plugin; avoid doing it twice and make sure that
	 primitive prolog preparation is done immediately after inlining.
	 Also, since sharing between plugins means that normal pruning
	 can't be done, allow plugins that want to prune specific methods."
	self doBasicInlining: inlineFlag
]

{ #category : #utilities }
CCodeGenerator >> emitBuiltinConstructAsArgumentFor: msgNode on: aStream level: level [
	"If the given selector is in the translation dictionary, translate it into a target code construct and return true. Otherwise, do nothing and return false."

	| action |
	(self shouldGenerateAsInterpreterProxySend: msgNode) ifTrue:
		[^false].
	action := asArgumentTranslationDict
				at: msgNode selector
				ifAbsent: [translationDict at: msgNode selector ifAbsent: [ ^false ]].
	self perform: action with: msgNode with: aStream with: level.
	^true
]

{ #category : #utilities }
CCodeGenerator >> emitBuiltinConstructFor: msgNode on: aStream level: level [
	"If the given selector is in the translation dictionary, translate it into a target code construct and return true. Otherwise, do nothing and return false."

	| action |
	(self shouldGenerateAsInterpreterProxySend: msgNode) ifTrue:
		[^false].
	action := translationDict at: msgNode selector ifAbsent: [ ^false ].
	self perform: action with: msgNode with: aStream with: level.
	^true
]

{ #category : #'C code generator' }
CCodeGenerator >> emitCCodeOn: aStream doInlining: inlineFlag doAssertions: assertionFlag [
	"Emit C code for all methods in the code base onto the given stream. All inlined method calls should already have been expanded."

	| verbose methodList |
	"method preparation"
	verbose := false.
	self prepareMethods.
	verbose ifTrue: [
		self printUnboundCallWarnings.
		self printUnboundVariableReferenceWarnings.
		logger cr.
	].
	assertionFlag ifFalse: [ self removeAssertions ].
	self doInlining: inlineFlag.

	"code generation"
	"If we're outputting the VM put the main interpreter loop first for two reasons.
	 1, so that the dispdbg.h header included at the bytecode dispatch can define
	 macros that affect all C code in the interpreter,  and 2, so that all primitive
	 functions will come after and have relatively high addresses.  This provides safety
	 in the use of primitiveFunctionPointer as a function pointer and an index by trying
	 to ensure that primitives have addresses much higher than any indices."
	methodList := self sortMethods: methods.
	(methods includesKey: #interpret) ifTrue:
		[methodList := { methods at: #interpret }, (methodList copyWithout: (methods at: #interpret))].
	"clean out no longer valid variable names and then
	 handle any global variable usage in each method"
	methodList do: [:m | self checkForGlobalUsage: (m removeUnusedTempsAndNilIfRequiredIn: self) in: m].
	self localizeGlobalVariables.

	self emitCHeaderOn: aStream.
	self emitCConstantsOn: aStream.
	self emitCTypesOn: aStream. "Emitting types after constants allows use of constant names, e.g. in declaring arrays."
	self emitCFunctionPrototypes: methodList on: aStream.
	self emitCVariablesOn: aStream.
	self emitCMacros: methodList on: aStream.
	self emitCMethods: methodList on: aStream

]

{ #category : #'C code generator' }
CCodeGenerator >> emitCConstants: constList on: aStream [
	"Store the global variable declarations on the given stream."

	constList isEmpty ifTrue: [ ^ self ].
	aStream
		cr;
		nextPutAll: '/*** Constants ***/';
		cr.
	(self sortStrings: constList) do: [ :varName | 
		| node default value |
		node := constants at: varName.
		node name isEmpty ifFalse: [ "If the definition includes a C comment, or looks like a conditional, take it as is, otherwise convert
			  the value from Smalltalk to C.
			  Allow the class to provide an alternative definition, either of just the value or the whole shebang."
			default := (node value isString and: [ 
				            (node value includesSubstring: '/*') or: [ 
					            (node value includesSubstring: ' ? ') and: [ 
						            node value includesSubstring: ' : ' ] ] ])
				           ifTrue: [ node value ]
				           ifFalse: [ self cLiteralFor: node value name: varName ].
			default = #undefined
				ifTrue: [ 
					aStream
						nextPutAll: '#undef ';
						nextPutAll: node name;
						cr ]
				ifFalse: [ 
					value := self valueForContant: node ifAbsent: default.
					(self defineAtCompileTime: node name)
						ifTrue: [ 
							self
								putConditionalDefineOf: node name
								as: value
								comment:
								'Allow this to be overridden on the compiler command line'
								on: aStream ]
						ifFalse: [ self putDefineOf: node name as: value on: aStream ] ] ] ].
	aStream cr
]

{ #category : #'C code generator' }
CCodeGenerator >> emitCConstantsOn: aStream [

	"Store the global variable declarations on the given stream."
	self
		emitCConstants: self constants
		on: aStream
]

{ #category : #'C code generator' }
CCodeGenerator >> emitCExpression: aParseNode on: aStream [ 
	"Emit C code for the expression described by the given parse node."

	self emitCExpression: aParseNode on: aStream indent: 0
]

{ #category : #'C code generator' }
CCodeGenerator >> emitCExpression: aParseNode on: aStream indent: level [
	"Emit C code for the expression described by the given parse node."

	(aParseNode isLeaf
	 or: [aParseNode isSend
		 and: [#(bytesPerOop bytesPerWord baseHeaderSize wordSize) includes: aParseNode selector]])
		ifTrue: 
			["omit parens"
			 (aParseNode asCASTExpressionIn: self) prettyPrintOn: aStream ]
		ifFalse: 
			[aStream nextPut: $(.
			 (aParseNode asCASTExpressionIn: self) prettyPrintOn: aStream.
			 aStream nextPut: $)]
]

{ #category : #'C code generator' }
CCodeGenerator >> emitCFunctionPrototypeFor: m on: aStream [
	^ m emitCFunctionPrototype: aStream generator: self
]

{ #category : #'C code generator' }
CCodeGenerator >> emitCFunctionPrototypes: methodList on: aStream [
	"Store prototype declarations for all non-inlined methods on the given stream.
	 Add a define for a NoDbgRegParms attribute for static functions used for debugging.
	 gcc and other compilers will use non-standard calling conventions for static functions
	 when optimizing.  The optimization can render the functions unusable in gdb.  The sqConfig.h
	 file for the platform should define PlatformNoDbgRegParms suitably for the platform's
	 compiler, if the compiler can be persuaded not to generate such functions.
	 Add a define for a NeverInline attribute that tells the compiler never to inline functions
	 with the attribute.  We mark functions we want to observe in a profiler as NeverInline.
	 The sqConfig.h file for the platform should define NeverInline suitably for the platform's
	 compiler, if the compiler can be persuaded not to inline certain functions."

	aStream
		cr;
		nextPutAll: '/*** Function Prototypes ***/';
		cr.
	self emitFunctionPrototypesPreambleOn: aStream.
	methodList
		select: [ :m | m isRealMethod and: [ self shouldGenerateMethod: m ] ]
		thenDo: [ :m | self emitCFunctionPrototypeFor: m on: aStream ].
	aStream cr
]

{ #category : #'C code generator' }
CCodeGenerator >> emitCHeaderOn: aStream [
	"Emit the initial part of a source file on aStream, comprising the version stamp,
	 the global struct usage flags, the header files and preamble code."
	self emitGlobalStructFlagOn: aStream.

	"Additional header files; include C library ones first."
	self emitHeaderFiles: (headerFiles select: [:hdr| hdr includes: $<]) on: aStream.
	"Additional header files; include squeak VM ones last"
	self emitHeaderFiles: (headerFiles reject: [:hdr| hdr includes: $<]) on: aStream.

	aStream cr
]

{ #category : #'C code generator' }
CCodeGenerator >> emitCMacros: methodList on: aStream [ 
	"Store the global variable declarations on the given stream.  Answer any constants used in the macros."
	| usedConstants |
	macros isEmpty ifTrue: [^#()].
	aStream cr; nextPutAll: '/*** Macros ***/'; cr.
	usedConstants := Set new.
	(methodList reject: [:m| m isRealMethod]) do:
		[:m |
		m definedAsMacro ifTrue:
			[aStream
				nextPutAll: '#define ';
				nextPutAll:(self cFunctionNameFor: m selector);
				nextPutAll: (macros at: m selector); cr.
			 m compiledMethod literalsDo:
				[:lit|
				(lit isVariableBinding and: [(macros at: m selector) includesSubstring: lit key]) ifTrue:
					[usedConstants add: lit key]]]].
	aStream cr.
	^usedConstants
]

{ #category : #'C code generator' }
CCodeGenerator >> emitCMethods: methodList on: aStream [

	UIManager default
		displayProgress: 'Writing Translated Code...'
		from: 0
		to: methods size
		during: [ :bar | 
			methodList doWithIndex: [ :m :i | 
				bar value: i.
				(m isRealMethod and: [ self shouldGenerateMethod: m ]) ifTrue: [ | cast |
					cast := m asCASTIn: self.
					cast prettyPrintOn: aStream ] ] ]
]

{ #category : #'C code generator' }
CCodeGenerator >> emitCTypesOn: aStream [ 
	"Store local type declarations on the given stream."
	self structClasses do: [:structClass|
		(self shouldGenerateStruct: structClass) ifTrue: [
			structClass printTypedefOn: aStream.
			aStream cr; cr ] ]
]

{ #category : #'C code generator' }
CCodeGenerator >> emitCVariableDeclarationFor: aDeclaration andVarString: varString on: aStream [
	aStream
		nextPutAll: aDeclaration;
		nextPut: $;;
		cr
]

{ #category : #'C code generator' }
CCodeGenerator >> emitCVariablesOn: aStream [ 
	"Store the global variable declarations on the given stream."

	aStream cr; nextPutAll: '/*** Variables ***/'; cr.
	(self sortStrings: variables) do:
		[:var | | varString decl |
		varString := var asString.
		decl := variableDeclarations at: varString ifAbsent: ['sqInt ' , varString].
		decl first == $# "support cgen var: #bytecodeSetSelector declareC: '#define bytecodeSetSelector 0' hack"
			ifTrue:
				[aStream nextPutAll: decl; cr]
			ifFalse:
				[self emitCVariableDeclarationFor: decl andVarString: varString on: aStream ]].
	aStream cr
]

{ #category : #'C code generator' }
CCodeGenerator >> emitExportNamed: exportsNamePrefix forMethod: method pluginName: pluginName on: aStream [

	| primName |
	primName := self cFunctionNameFor: method selector.
	aStream
		tab;
		nextPutAll: '{(void*)_m, "';
		nextPutAll: primName;
		nextPutAll: '", (void*)';
		nextPutAll: primName;
		nextPutAll: '},';
		cr
]

{ #category : #'C code generator' }
CCodeGenerator >> emitExportsNamed: exportsNamePrefix pluginName: pluginName on: aStream [

	"Store all the exported primitives in the form used by the internal named prim system."
	aStream cr; cr; nextPutAll: 'static char _m[] = "'; nextPutAll: pluginName; nextPutAll: '";'.
	aStream cr; nextPutAll: 'void* '; nextPutAll: exportsNamePrefix; nextPutAll: '_exports[][3] = {'; cr.
	self sortedExportMethods do:
		[:method|
		self withOptionalConditionalDefineFor: method
			on: aStream
			do: [ self emitExportNamed: exportsNamePrefix forMethod: method pluginName: pluginName on: aStream ]].
	aStream tab; nextPutAll: '{NULL, NULL, NULL}'; cr; nextPutAll: '};'; cr.

]

{ #category : #'C code generator' }
CCodeGenerator >> emitFunctionPrototypesPreambleOn: aStream [
	"hook for outputing a preamble before all function prototypes are emitted"
]

{ #category : #'C code generator' }
CCodeGenerator >> emitGlobalStructFlagOn: aStream [
	"Default: do nothing.  Overridden in CCGenGlobalStruct."

]

{ #category : #'C code generator' }
CCodeGenerator >> emitHeaderFiles: headerFilesSubSequence on: aStream [
	headerFilesSubSequence do:
		[:hdr|
		hdr first ~= $# ifTrue:
			[aStream nextPutAll: '#include '].
		aStream nextPutAll: hdr; cr]
]

{ #category : #accessing }
CCodeGenerator >> environment [
	
	^ environment ifNil: [ Smalltalk ]
]

{ #category : #accessing }
CCodeGenerator >> environment: aCollection [ 
	environment := aCollection
]

{ #category : #public }
CCodeGenerator >> exportedPrimitiveNames [
	"Return an array of all exported primitives"
	^methods select:[:m| m export] thenCollect:[:m| self cFunctionNameFor: m selector].

]

{ #category : #utilities }
CCodeGenerator >> extractTypeFor: aVariable fromDeclaration: aVariableDeclaration [
	"Eliminate inessentials from aVariableDeclaration to answer a C type without the variable,
	 or initializations etc"
	| decl |
	((aVariableDeclaration beginsWith: 'static ')
	 or: [aVariableDeclaration beginsWith: 'extern ']) ifTrue:
		[^self extractTypeFor: aVariable fromDeclaration: (aVariableDeclaration allButFirst: 7)].
	decl := (aVariableDeclaration indexOf: $= ifAbsent: [])
				ifNotNil: [:index| aVariableDeclaration copyFrom: 1 to: index - 1]
				ifNil: [aVariableDeclaration].
	decl := decl copyReplaceAll: aVariable with: '' tokenish: [:ch| ch = $_ or: [ch isAlphaNumeric]].
	^self baseTypeForType: decl
]

{ #category : #'C code generator' }
CCodeGenerator >> fileHeaderVersionStampForSourceClass: sourceClass [
	"Answer a suitable version stamp to include in the header."
	| exportBuildInfo slangDescription sourceDescription |
	[exportBuildInfo := sourceClass isInterpreterClass
						ifTrue: ['char *__interpBuildInfo = __buildInfo;']
						ifFalse:
							[sourceClass isCogitClass
								ifTrue: ['char *__cogitBuildInfo = __buildInfo;']
								ifFalse:
									[sourceClass isPluginClass ifTrue:
										[sourceClass exportBuildInfoOrNil]]]]
		on: MessageNotUnderstood
		do: [:ex| ex resume: false].
	[slangDescription := self class monticelloDescriptionFor: self class.
	 sourceClass ifNotNil:
		[sourceDescription := [sourceClass monticelloDescription]
								on: MessageNotUnderstood
								do: [:ex| self class monticelloDescriptionFor: sourceClass]]]
		on: Error
		do: [:ex| | now |
			now := Time dateAndTimeNow printString.
			^String streamContents:
				[:s|
				s nextPutAll: '/* Automatically generated from Squeak on '.
				s nextPutAll: now.
				s nextPutAll: ' */'; cr; cr.
				s nextPutAll: 'static char __buildInfo[] = "Generated on '.
				s nextPutAll: now.
				s nextPutAll: '. Compiled on "'.
				s nextPutAll: '__DATE__ ;'; cr.
				exportBuildInfo ifNotNil:
					[s nextPutAll: exportBuildInfo; cr].
				s cr]].
	^String streamContents:
		[:s|
		s nextPutAll: '/* Automatically generated by\	' withCRs.
		s nextPutAll: slangDescription.
		sourceDescription ifNotNil:
			[s nextPutAll: '\   from\	' withCRs; nextPutAll: (sourceDescription copyReplaceAll: '\' withCRs with: '\	' withCRs)].
		s cr; nextPutAll: ' */'; cr.
		sourceDescription ifNotNil:
			[s nextPutAll: 'static char __buildInfo[] = "'.
			 s nextPutAll: (sourceDescription copyReplaceAll: '\' withCRs with: '\n\', '\' withCRs).
			 s nextPutAll: ' " __DATE__ ;'; cr.
			exportBuildInfo ifNotNil:
				[s nextPutAll: exportBuildInfo; cr].
			s cr]]
]

{ #category : #'C translation support' }
CCodeGenerator >> generateAsConstantExpression: msgNode on: aStream [
	"Attempt to generate the C code for this message onto the given stream.
	 Answer if the attempt succeeded.  This handles integer overflow of int
	 expressions in a 64-bit compiler."

	msgNode constantNumbericValueOrNil ifNotNil:
		[:value|
		 (value between: -1 << 31 and: 1 << 31 - 1) ifFalse:
			[aStream nextPutAll: (self cLiteralFor: value).
			 ^true]].
	^false
]

{ #category : #'C translation' }
CCodeGenerator >> generateAsSymbol: msgNode on: aStream indent: level [
	"Generate the C code for this message onto the given stream.
	 The receiver is expected to be a TConstantNode."

	aStream nextPutAll: (self cFunctionNameFor: msgNode receiver nameOrValue)
]

{ #category : #'C translation' }
CCodeGenerator >> generateBaseHeaderSize: msgNode on: aStream indent: level [
	"Generate the C code for this message onto the given stream."

	aStream nextPutAll: 'BaseHeaderSize'

]

{ #category : #'C translation' }
CCodeGenerator >> generateBytesPerOop: msgNode on: aStream indent: level [
	"Generate the C code for this message onto the given stream.
	 Would prefer to use OopSize than BytesPerOop (shorter)."

	aStream nextPutAll: 'BytesPerOop'
]

{ #category : #'C translation' }
CCodeGenerator >> generateBytesPerWord: msgNode on: aStream indent: level [
	"Generate the C code for this message onto the given stream.
	 Would prefer to use WordSize than BytesPerWord (shorter) but e.g.
	 mpegtype.h has a parameter named WordSize."

	aStream nextPutAll: 'BytesPerWord'
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAbs: tast [

	| type strippedType absFun |
	type := self typeFor: tast receiver in: currentMethod.
	strippedType := (type beginsWith: 'unsigned ')
		ifTrue: [type allButFirst: 'unsigned ' size]
		ifFalse: [(type beginsWith: 'u')
			ifTrue: [type allButFirst: 1]
			ifFalse: [type]].
	absFun :=
		(#(	('long long' llabs) ('__int64' #llabs) ('int64_t' #llabs)
			(sqInt SQABS)
			(sqLong SQLABS)
			(double fabs)
			(float fabsf))
				detect: [:tuple| strippedType beginsWith: tuple first]
				ifNone: [])
			ifNotNil: [:tuple| tuple last]
			ifNil: [#abs].
	^ CCallNode identifier: (CIdentifierNode name: absFun)
					arguments: { tast receiver asCASTExpressionIn: self }
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAddressOf: tast [

	^ CUnaryOperatorNode
		  operator: #&
		  expression: (tast arguments first asCASTExpressionIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAllMask: tast [

	^ CBinaryOperatorNode
		  operator: #==
		  left: (self generateCASTBitAnd: tast)
		  right: (tast arguments first asCASTExpressionIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAnd: tast [

	^ self generateCASTBinary: tast operator: #&&
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAs: tast type: type [

	^ CCastExpressionNode
		  type: (CTypeNameNode symbol: type)
		  expression: (tast receiver asCASTExpressionIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAsFloat: tast [

	^ self generateCASTAs: tast type:  'double'
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAsInteger: tast [

	^ self generateCASTAs: tast type:  'sqInt'
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAsIntegerPtr: tast [

	^ self generateCASTAs: tast type: 'sqIntptr_t'
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAsLong: tast [

	^ self generateCASTAs: tast type:  'long'
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAsSymbol: tast [

	^ CIdentifierNode name:
		  (self cFunctionNameFor: tast receiver nameOrValue)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAsUnsignedInteger: tast [

	^ self generateCASTAs: tast type:  'usqInt'
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAsUnsignedIntegerPtr: tast [

	^ self generateCASTAs: tast type:  'usqIntptr_t'
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAsUnsignedLong: tast [

	^ self generateCASTAs: tast type:  'unsigned long'
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAsUnsignedLongLong: tast [

	^ self generateCASTAs: tast type:  'unsigned long long'
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAsVoidPointer: tast [

	^ self generateCASTAs: tast type: 'void *'
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAt: tast [

	^ CArrayAccessNode
		  array: (tast receiver asCASTExpressionIn: self)
		  index: (tast arguments first asCASTExpressionIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTAtPut: tast [

	^ CAssignmentNode
		  lvalue: (CArrayAccessNode
				   array: (tast receiver asCASTExpressionIn: self)
				   index: (tast arguments first asCASTExpressionIn: self))
		  operator: '='
		  rvalue: (tast arguments last asCASTExpressionIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTBaseHeaderSize: tast [

	^ CIdentifierNode name: 'BaseHeaderSize'
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTBetweenAnd: tast [

	^ CBinaryOperatorNode
		  operator: #&&
		  left: (CBinaryOperatorNode
				   operator: #>=
				   left: (tast receiver asCASTExpressionIn: self)
				   right: (tast arguments first asCASTExpressionIn: self))
		  right: (CBinaryOperatorNode
				   operator: #<=
				   left: (tast receiver asCASTExpressionIn: self)
				   right: (tast arguments second asCASTExpressionIn: self))
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTBinary: tast operator: operator [

	^ CBinaryOperatorNode
		  operator: operator
		  left: (tast receiver asCASTExpressionIn: self)
		  right: (tast arguments first asCASTExpressionIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTBitAnd: tast [

	^ self generateCASTBinary: tast operator: #&
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTBitClear: tast [

	^ CBinaryOperatorNode
		  operator: #-
		  left: (CBinaryOperatorNode
				   operator: #|
				   left: (tast receiver asCASTExpressionIn: self)
				   right: (tast arguments first asCASTExpressionIn: self))
		  right: (tast arguments first asCASTExpressionIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTBitInvert32: tast [

	^ CCastExpressionNode
		  type: (CTypeNameNode symbol: 'unsigned int')
		  expression: ((CUnaryOperatorNode
				    operator: #~
				    expression: (tast receiver asCASTExpressionIn: self))
				   needsParentheses: true;
				   yourself)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTBitInvert64: tast [

	^ CUnaryOperatorNode operator: #~ expression: (CCastExpressionNode
			   type: (self is32Bit not
					    ifTrue: [ CTypeNameNode symbol: 'usqIntptr_t' ]
					    ifFalse: [ CTypeNameNode symbol: 'unsigned long long' ])
			   expression: (tast receiver asCASTExpressionIn: self))
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTBitOr: tast [

	^ self generateCASTBinary: tast operator: #|
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTBitShift: tast [

	^ self generateCASTBitShift: tast cast: 'usqInt'
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTBitShift: tast cast: type [

	| arg receiver shift |
	arg := tast arguments first.
	receiver := tast receiver.
	(self isConstantNode: arg valueInto: [ :value | shift := value ]) 
		ifTrue: [ "bit shift amount is a constant"
			| shiftOperator |
			shift < 0
				ifTrue: [ 
					shiftOperator := '>>'.
					shift := shift negated ]
				ifFalse: [ shiftOperator := '<<' ].
			^ CBinaryOperatorNode
				  operator: shiftOperator
				  left: (CCastExpressionNode
						   type: (CTypeNameNode symbol: type)
						   expression: (receiver asCASTExpressionIn: self))
				  right: (CConstantNode value: shift) ].
	"bit shift amount is an expression"
	^ CTernaryNode
		  condition: (CBinaryOperatorNode
				   operator: #<
				   left: (arg asCASTExpressionIn: self)
				   right: (CConstantNode value: 0))
		  then: ((CBinaryOperatorNode
				    operator: #>>
				    left: (CCastExpressionNode
						     type: (CTypeNameNode symbol: type)
						     expression: (receiver asCASTExpressionIn: self))
				    right: (CUnaryOperatorNode
						     operator: #-
						     expression: (arg asCASTExpressionIn: self)))
				   needsParentheses: true;
				   yourself)
		  else: ((CBinaryOperatorNode
				    operator: #<<
				    left: (CCastExpressionNode
						     type: (CTypeNameNode symbol: type)
						     expression: (receiver asCASTExpressionIn: self))
				    right: (arg asCASTExpressionIn: self))
				   needsParentheses: true;
				   yourself)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTBitXor: tast [

	^ self generateCASTBinary: tast operator: '^'
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTByteSwap32: tast [

	^ CCallNode
		  identifier: (CIdentifierNode name: 'SQ_SWAP_4_BYTES')
		  arguments: { (tast receiver asCASTExpressionIn: self) }
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTByteSwap32IfBigEndian: tast [

	^ CCallNode
		  identifier: (CIdentifierNode name: 'SQ_SWAP_4_BYTES_IF_BIGENDIAN')
		  arguments: { (tast arguments first asCASTExpressionIn: self) }
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTByteSwap64: tast [

	^ CCallNode
		  identifier: (CIdentifierNode name: 'SQ_SWAP_8_BYTES')
		  arguments: { (tast receiver asCASTExpressionIn: self) }
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTByteSwap64IfBigEndian: tast [

	^ CCallNode
		  identifier: (CIdentifierNode name: 'SQ_SWAP_8_BYTES_IF_BIGENDIAN')
		  arguments: { (tast arguments first asCASTExpressionIn: self) }
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTBytesPerOop: tast [

	^ CIdentifierNode name: 'BytesPerOop'
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTBytesPerWord: tast [

	^ CIdentifierNode name: 'BytesPerWord'
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTCCoercion: tast [

	| expr cType literal |
	expr := tast args first.
	cType := tast args last value.
	(cType = #float and: [ 
		 expr isConstant and: [ 
			 expr value isFloat and: [ 
				 (literal := self cLiteralFor: expr value) allSatisfy: [ :c | 
					 c == $. or: [ c isDigit ] ] ] ] ]) ifTrue: [ 
		^ CConstantNode value: literal , 'f' ].
	^ CCastExpressionNode
		  type: (CTypeNameNode symbol: cType)
		  expression: (expr asCASTExpressionIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTDeny: tast [

	^ CCallNode
		  identifier: (CIdentifierNode name: 'assert')
		  arguments: { (CUnaryOperatorNode
				   operator: #!
				   expression: (tast arguments first asCASTExpressionIn: self)) }
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTDivide: tast [

	^ self generateCASTBinary: tast operator: #/
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTDoWhile: boolean loop: tast [

	| block  cond|
	block := (TStmtListNode new setStatements:
		          tast receiver statements allButLast) asCASTIn: self.
	cond := (tast receiver statements last asCASTExpressionIn: self).
	^ CDoStatementNode
		  while: (boolean ifTrue: [ cond ] ifFalse: [ CUnaryOperatorNode operator: #! expression: cond ])
		  statement: block
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTDoWhileFalse: tast [

	^ self generateCASTDoWhile: false loop: tast
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTDoWhileTrue: tast [

	^ self generateCASTDoWhile: true loop: tast
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTEqual: tast [

	^ self generateCASTBinary: tast operator: #==
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTFlag: tast [

	^ CCallNode
		  identifier: (CIdentifierNode name: 'flag')
		  arguments: { ((CStringLiteralNode value:
					    (self cLiteralFor: tast arguments last value asString))
				   needsDoubleQuotes: false;
				   yourself) }
]

{ #category : #utilities }
CCodeGenerator >> generateCASTForBuiltinAsArgumentConstructFor: msgNode [

	"Generate CAST argument form for a message node assuming it is a built-in construct.
	If the message node can not be translated as an argument, try to generate normal CAST form for this built-in.
	Otherwise return nil."

	| action |
	(self shouldGenerateAsInterpreterProxySend: msgNode) ifTrue: [ ^ nil ].
	action := castAsArgumentTranslationDict
		          at: msgNode selector
		          ifAbsent: [ 
		          castTranslationDict
			          at: msgNode selector
			          ifAbsent: [ ^ nil ] ].
	^ self perform: action with: msgNode
]

{ #category : #utilities }
CCodeGenerator >> generateCASTForBuiltinConstructFor: msgNode [

	"Generate CAST for a message node assuming it is a built-in construct.
	If the message node can not be translated as a built-in construct, return nil."

	| action |
	(self shouldGenerateAsInterpreterProxySend: msgNode) ifTrue: [ ^ nil ].
	action := castTranslationDict
		          at: msgNode selector
		          ifAbsent: [ ^ nil ].
	^ self perform: action with: msgNode
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTGreaterThan: tast [

	^ self generateCASTBinary: tast operator: #>
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTGreaterThanOrEqual: tast [

	^ self generateCASTBinary: tast operator: #>=
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfElse: tast reverseArms: reverse [

	| firstStatement secondStatment |
	firstStatement := reverse
		                  ifTrue: [ tast arguments last ]
		                  ifFalse: [ tast arguments first ].
	secondStatment := reverse
		                  ifTrue: [ tast arguments first ]
		                  ifFalse: [ tast arguments last ].

	"If the receiver is a boolean constant, it returns only one of the statements (depending on the constant value)."
	(self nilOrBooleanConstantReceiverOf: tast receiver) ifNotNil: [ 
		:const | 
		^ (const
			   ifTrue: [ firstStatement ]
			   ifFalse: [ secondStatment ]) asCASTIn: self ].

	"If both statements are different, it returs an if nod"
	(firstStatement isSameAs: secondStatment) ifFalse: [ 
		^ CIfStatementNode
			  if: (tast receiver asCASTExpressionIn: self)
			  then: (firstStatement asCASTIn: self)
			  else: (secondStatment asCASTIn: self) ].

	"Here, both statement are equal."
	"If receiver has no side effect, it returns only the one of the statements (they are equal)."
	tast receiver hasSideEffect ifFalse: [ 
		^ firstStatement asCASTIn: self ].

	"If receiver has side effect, receiver has to be executed before the statement."
	^ (CCompoundStatementNode statements: { 
				   (tast receiver asCASTExpressionIn: self).
				   (firstStatement asCASTIn: self) })
		  needsBrackets: false;
		  yourself
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfElseAsArgument: tast reverseArms: reverse [

	| firstStatement secondStatment |
	firstStatement := reverse
		                  ifTrue: [ tast arguments last ]
		                  ifFalse: [ tast arguments first ].
	secondStatment := reverse
		                  ifTrue: [ tast arguments first ]
		                  ifFalse: [ tast arguments last ].

	"If the receiver is a boolean constant, it returns only one of the statements (depending on the constant value)."
	(self nilOrBooleanConstantReceiverOf: tast receiver) ifNotNil: [ 
		:const | 
		^ (const
			   ifTrue: [ firstStatement ]
			   ifFalse: [ secondStatment ]) asCASTExpressionIn: self ].

	"If both statements are different, it returs a ternary"
	(firstStatement isSameAs: secondStatment) ifFalse: [ 
		^ (CTernaryNode
			   condition: (tast receiver asCASTExpressionIn: self)
			   then: (firstStatement asCASTExpressionIn: self)
			   else: (secondStatment asCASTExpressionIn: self))
			  printOnMultipleLines: true;
			  yourself ].

	"Here, both statement are equal."
	"If receiver has no side effect, it returns only the one of the statements (they are equal)."
	tast receiver hasSideEffect ifFalse: [ 
		^ firstStatement asCASTExpressionIn: self ].

	"If receiver has side effect, receiver has to be executed before the statement."
	^ (CExpressionListNode new expressions: { 
				   (tast receiver asCASTExpressionIn: self).
				   (firstStatement asCASTExpressionIn: self) })
		  printOnMultipleLines: true;
		  yourself
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfFalse: tast [

	^ (self nilOrBooleanConstantReceiverOf: tast receiver)
		  ifNil: [ 
			  CIfStatementNode
				  if:
					  ((tast receiver isSend and: [ tast receiver selector == #not ]) "Eliminate double-negatives"
						   ifTrue: [ tast receiver receiver asCASTExpressionIn: self ]
						   ifFalse: [ CUnaryOperatorNode operator: #! expression:  (tast receiver asCASTExpressionIn: self) ])
				  then: (tast arguments first asCASTIn: self)  ]
		  ifNotNil: [ :const | 
			  const
				  ifTrue: [ CEmptyStatementNode new ]
				  ifFalse: [ tast arguments first asCASTIn: self ] ]
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfFalseAsArgument: tast [

	^ (self nilOrBooleanConstantReceiverOf: tast receiver)
		  ifNil: [ 
			  (CTernaryNode
				   condition:
					   ((tast receiver isSend and: [ tast receiver selector == #not ])
						    ifTrue: [ "Eliminate double-negatives" 
							    tast receiver receiver asCASTExpressionIn: self ]
						    ifFalse: [ 
							    CUnaryOperatorNode
								    operator: #!
								    expression: (tast receiver asCASTExpressionIn: self) ])
				   then: (tast arguments first asCASTExpressionIn: self)
				   else: (CConstantNode value: 0))
				  printOnMultipleLines: true;
				  yourself ]
		  ifNotNil: [ :const | 
			  const
				  ifTrue: [ CEmptyStatementNode new ]
				  ifFalse: [ tast arguments first asCASTExpressionIn: self ] ]
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfFalseIfTrue: tast [

	^ self generateCASTIfElse: tast reverseArms: true 
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfFalseIfTrueAsArgument: tast [

	^ self generateCASTIfElseAsArgument: tast reverseArms: true
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfNil: tast [

	(self isNilConstantReceiverOf: tast) ifFalse: [ 
		^ CIfStatementNode
			  if: (CUnaryOperatorNode operator: #! expression: (tast receiver asCASTExpressionIn: self))
			  then: (tast arguments first asCASTIn: self) ].
	"The receiver is a nil constant, known at translation-time. No need to add a conditional node over it."
	^ tast arguments first asCASTIn: self
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfNilAsArgument: tast [

	(self isNilConstantReceiverOf: tast) ifFalse: [ 
		^ (CTernaryNode
			   condition: (CUnaryOperatorNode
					    operator: #!
					    expression: (tast receiver asCASTExpressionIn: self))
			   then: (tast arguments first asCASTExpressionIn: self)
			   else: (tast receiver asCASTExpressionIn: self))
			  printOnMultipleLines: true;
			  yourself ].
	"The receiver is a nil constant, known at translation-time. No need to add a conditional node over it."
	^ tast arguments first asCASTExpressionIn: self
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfNilIfNotNil: tast [

	^ self generateCASTIfNotNilIfNil: tast reverseArms: true
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfNilIfNotNilAsArgument: tast [

	^ self generateCASTIfNotNilIfNilAsArgument: tast reverseArms: true
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfNotNil: tast [

	(self isNilConstantReceiverOf: tast) ifFalse: [ 
		^ CIfStatementNode
			  if: (tast receiver asCASTExpressionIn: self)
			  then: (tast arguments first asCASTIn: self) ].
	"The receiver is a nil constant, nothing to do."
	^ CEmptyStatementNode new
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfNotNilAsArgument: tast [

	(self isNilConstantReceiverOf: tast) ifFalse: [ 
		^ (CTernaryNode
			   condition: (tast receiver asCASTExpressionIn: self)
			   then: (tast arguments first asCASTExpressionIn: self)
			   else: (CConstantNode value: 0))
			  printOnMultipleLines: true;
			  yourself ].
	"The receiver is a nil constant, return C literal for nil."
	^ CConstantNode value: (self cLiteralFor: nil)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfNotNilIfNil: tast [

	^ self generateCASTIfNotNilIfNil: tast reverseArms: false
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfNotNilIfNil: tast reverseArms: reverse [

	| firstBlock lastBlock |
	firstBlock := reverse
		              ifTrue: [ tast arguments last ]
		              ifFalse: [ tast arguments first ].
	lastBlock := reverse
		             ifTrue: [ tast arguments first ]
		             ifFalse: [ tast arguments last ].
	(self isNilConstantReceiverOf: tast) ifFalse: [ 
		^ CIfStatementNode
			  if: (tast receiver asCASTExpressionIn: self)
			  then: ((firstBlock asCASTIn: self)
					   yourself)
			  else: (lastBlock asCASTIn: self) ].
	"The receiver is a nil constant, known at translation-time. We know which block is executed."
	^ lastBlock asCASTIn: self
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfNotNilIfNilAsArgument: tast [

	^ self generateCASTIfNotNilIfNilAsArgument: tast reverseArms: false
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfNotNilIfNilAsArgument: tast reverseArms: reverse [

	| firstBlock lastBlock |
	firstBlock := reverse
		              ifTrue: [ tast arguments last ]
		              ifFalse: [ tast arguments first ].
	lastBlock := reverse
		             ifTrue: [ tast arguments first ]
		             ifFalse: [ tast arguments last ].
	(self isNilConstantReceiverOf: tast) ifFalse: [ 
		^ (CTernaryNode
			   condition: (tast receiver asCASTExpressionIn: self)
			   then: (firstBlock asCASTExpressionIn: self)
			   else: (lastBlock asCASTExpressionIn: self))
			  printOnMultipleLines: true;
			  yourself ].
	"The receiver is a nil constant, known at translation-time. We know which block is executed."
	^ lastBlock asCASTExpressionIn: self
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfTrue: tast [
	
	^ (self nilOrBooleanConstantReceiverOf: tast receiver)
		  ifNil: [ 
			  CIfStatementNode
				  if: (tast receiver asCASTExpressionIn: self)
				  then: (tast arguments first asCASTIn: self) ]
		  ifNotNil: [ :const | 
			  const
				  ifTrue: [ tast arguments first asCASTIn: self ]
				  ifFalse: [ CEmptyStatementNode new ] ]
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfTrueAsArgument: tast [

	(self nilOrBooleanConstantReceiverOf: tast receiver)
		ifNil: [ 
			^ (CTernaryNode
				   condition: ((tast receiver asCASTExpressionIn: self)
						    needsParentheses: false;
						    yourself)
				   then: (tast arguments first asCASTExpressionIn: self)
				   else: (CConstantNode value: 0))
				  printOnMultipleLines: true;
				  yourself ]
		ifNotNil: [ :const | 
			const
				ifTrue: [ ^ tast arguments first asCASTExpressionIn: self ]
				ifFalse: [ ^ CConstantNode value: (self cLiteralFor: nil) ] ]
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfTrueIfFalse: tast [

	^ self generateCASTIfElse: tast reverseArms: false
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIfTrueIfFalseAsArgument: tast [

	^ self generateCASTIfElseAsArgument: tast reverseArms: false
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTInlineCCode: aTSendNode [ 

	aTSendNode args first isConstant ifTrue: [
		"If it is a pre-processor declaration"
		(aTSendNode args first value at: 1 ifAbsent: nil) = $# ifTrue: [
			"This was assuming the argument is a preprocessor directive.
			So it was printing it in a new line"
			self error: 'unsupported' ].
			
			self noteVariableUsageInString: aTSendNode args first value.
			^ CRawCodeNode code: aTSendNode args first value ].

	^ aTSendNode args first asCASTIn: self.
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTInlineCCodeAsArgument: aTSendNode [

	(aTSendNode args first isConstant and: [ 
		 aTSendNode args first value isString ]) ifTrue: [ "If it is a pre-processor declaration"
		(aTSendNode args first value at: 1 ifAbsent: nil) = $# ifTrue: [ "This was assuming the argument is a preprocessor directive.
			So it was printing it in a new line" 
			self error: 'unsupported' ].

		self noteVariableUsageInString: aTSendNode args first value.
		^ CRawCodeNode code: aTSendNode args first value ].

	^ aTSendNode args first asCASTExpressionIn: self
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTInlineCppIfElse: tast [

	^ self generateCASTInlineCppIfElse: tast asArgument: false
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTInlineCppIfElse: tast asArgument: asArgument [
	"Generate the CAST node for the C preprocessor if directive."
	| generateCAST cppIf |
	generateCAST := asArgument
		                ifTrue: [ [ :node | node asCASTExpressionIn: self ] ]
		                ifFalse: [ [ :node | node asCASTIn: self ] ].
	(self nilOrBooleanConditionFor: tast arguments first) ifNotNil: [ 
		:condition | 
		condition ifTrue: [ ^ generateCAST value: tast arguments second ].
		tast arguments size >= 3 ifTrue: [ 
			^ generateCAST value: tast arguments third ].
		^ CEmptyStatementNode new ].
	self haltIf: [ self currentMethod selector = #setInterpreter:].
	cppIf := CPreprocessorIfNode
		         if: (tast arguments first asCASTExpressionIn: self)
		         then: (self
				          with: tast arguments first
				          ifAppropriateSetTo: true
				          do: [ generateCAST value: tast arguments second ])
					asArgument: asArgument.
	tast arguments size >= 3 ifTrue: [ 
		cppIf else: (self
				 with: tast arguments first
				 ifAppropriateSetTo: false
				 do: [ generateCAST value: tast arguments third ]) ].
	^ cppIf
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTInlineCppIfElseAsArgument: tast [

	^ self generateCASTInlineCppIfElse: tast asArgument: true
]

{ #category : #'built-ins' }
CCodeGenerator >> generateCASTIntegerObjectOf: msgNode [ 
	
	| expr mustCastToUnsigned type typeIsUnsigned expressionToShift |
	expr := msgNode args first.
	
	expressionToShift := expr asCASTExpressionIn: self.

	"Note that the default type of an integer constant in C is int.  Hence we /must/
	 cast expression to long if in the 64-bit world, since e.g. in 64-bits
		(int)(16r1FFFFF << 3) = (int)16rFFFFFFF8 = -8
	 whereas
		(long)(16r1FFFFF << 3) = (long) 16rFFFFFFF8 = 4294967288."
	type := self typeFor: expr in: currentMethod.
	typeIsUnsigned := type first = $u.
	mustCastToUnsigned := typeIsUnsigned not
		or: [(self sizeOfIntegralCType: type) < (self sizeOfIntegralCType: #usqInt)].
	mustCastToUnsigned ifTrue: [
		expressionToShift := CCastExpressionNode
			type: (CTypeNameNode symbol: #usqInt)
			expression: expressionToShift ].

	^ (CBinaryOperatorNode
			operator: #|
			left: (CBinaryOperatorNode
			operator: #<<
			left: expressionToShift
			right: (CConstantNode  value: self vmClass objectMemoryClass numSmallIntegerTagBits))
		right: (CConstantNode  value: 1))
		needsParentheses: true;
		yourself
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIntegerValueOf: aTSendNode [ 
	
	^ CBinaryOperatorNode
		operator: #>>
		left: (aTSendNode arguments first asCASTExpressionIn: self)
		right: (CConstantNode value: self vmClass objectMemoryClass numSmallIntegerTagBits)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIsIntegerObject: msgNode [ 

	self vmClass objectMemoryClass numSmallIntegerTagBits = 1
		ifTrue: [
			^ (CBinaryOperatorNode
				operator: '&'
				left: 	(msgNode args first asCASTExpressionIn: self)
				right: (CConstantNode value: 1))
					needsParentheses: true;
					yourself ].
	
	^ (CBinaryOperatorNode
		operator: '=='
		left: (CBinaryOperatorNode
			operator: '&'
			left: 	((msgNode args first asCASTExpressionIn: self) needsParentheses: true; yourself)
			right: (CConstantNode value: 1 << self vmClass objectMemoryClass numSmallIntegerTagBits - 1))
		right: (CConstantNode value: 1))
			needsParentheses: true;
			yourself
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTIsNil: tast [

	^ CBinaryOperatorNode
		  operator: #==
		  left: (tast receiver asCASTIn: self)
		  right: (CIdentifierNode name: self nilTranslation)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTLessThan: tast [

	^ self generateCASTBinary: tast operator: #<
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTLessThanOrEqual: tast [

	^ self generateCASTBinary: tast operator: #<=
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTMax: tast [

	^ CTernaryNode
		  condition: (CBinaryOperatorNode
				   operator: #<
				   left: (tast receiver asCASTExpressionIn: self)
				   right: (tast arguments first asCASTExpressionIn: self))
		  then: (tast arguments first asCASTExpressionIn: self)
		  else: (tast receiver asCASTExpressionIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTMin: tast [

	^ CTernaryNode
		  condition: (CBinaryOperatorNode
				   operator: #<
				   left: (tast receiver asCASTExpressionIn: self)
				   right: (tast arguments first asCASTExpressionIn: self))
		  then: (tast receiver asCASTExpressionIn: self)
		  else: (tast arguments first asCASTExpressionIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTMinus: tast [

	"Constant fold if possible"
	tast constantNumbericValueOrNil ifNotNil: [:value|
	 (value between: -1 << 31 and: 1 << 31 - 1)
		ifFalse: [ ^ CConstantNode value: (self cLiteralFor: value) ] ].
	
	"Simplify if possible"
	tast args first constantNumbericValueOrNil ifNotNil: [:value|
		value = 0 ifTrue: [
			^ tast receiver asCASTExpressionIn: self ]].
	
	"Otherwise, translate normally"
	^ self generateCASTBinary: tast operator: #-
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTModulo: tast [

	^ self generateCASTBinary: tast operator: #%
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTNegated: tast [

	^ self generateCASTUnary: tast operator: #-
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTNoMask: tast [

	^ CBinaryOperatorNode
		  operator: #==
		  left: (self generateCASTBitAnd: tast)
		  right: (CConstantNode value: 0)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTNot: tast [

	^ self generateCASTUnary: tast operator: #!
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTNotEqual: tast [

	^ self generateCASTBinary: tast operator: #!=
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTNotNil: tast [

	^ CBinaryOperatorNode
		  operator: #!=
		  left: (tast receiver asCASTExpressionIn: self)
		  right: (CIdentifierNode name: self nilTranslation)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTOr: tast [
	
	^ self generateCASTBinary: tast operator: #||
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTPerform: tast [

	| arguments identifier |
	arguments := (2 to: tast arguments size) collect: [ :i | 
		(tast arguments at: i) asCASTExpressionIn: self ].
	identifier := tast arguments first asCASTExpressionIn: self.
	identifier isConstant ifTrue: [ 
		identifier := CIdentifierNode name: identifier value ].
	^ CCallNode
        identifier: identifier
        arguments: arguments
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTPlus: tast [
	
	"Constant fold if possible"
	tast constantNumbericValueOrNil ifNotNil: [:value|
	 (value between: -1 << 31 and: 1 << 31 - 1)
		ifFalse: [ ^ CConstantNode value: (self cLiteralFor: value) ] ].
	
	"Simplify if possible"
	tast args first constantNumbericValueOrNil ifNotNil: [:value|
		value = 0 ifTrue: [
			^ tast receiver asCASTExpressionIn: self ]].
	
	"Otherwise, translate normally"
	^ self generateCASTBinary: tast operator: #+
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTPowerTo: tast [

	^ CCastExpressionNode
		  type: (CTypeNameNode symbol: 'sqInt')
		  expression:
			  (CCallNode
				   identifier: (CIdentifierNode name: 'pow')
				   arguments: { 
						   (tast receiver asCASTExpressionIn: self).
						   (tast arguments first asCASTExpressionIn: self) })
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTPreDecrement: tast [

	| varNode |
	varNode := tast receiver.
	varNode isVariable ifFalse: [ 
		self error: 'preDecrement can only be applied to variables' ].
	^ CDecrementNode
		  object:
			  (CIdentifierNode name:
					   (self returnPrefixFromVariable: varNode name))
		  prefix: true
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTPreIncrement: tast [

	| varNode |
	varNode := tast receiver.
	varNode isVariable ifFalse: [ 
		self error: 'preIncrement can only be applied to variables' ].
	^ CIncrementNode
		  object:
			  (CIdentifierNode name:
					   (self returnPrefixFromVariable: varNode name))
		  prefix: true
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTRaisedTo: tast [

	^ CCallNode identifier: (CIdentifierNode name: 'pow') arguments: { 
			  (tast receiver asCASTExpressionIn: self).
			  (tast arguments first asCASTExpressionIn: self) }
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTRepeat: tast [

	^ CWhileStatementNode
		  while: (CConstantNode value: 1)
		  statement: (tast receiver asCASTIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTRounded: tast [

	^ CCallNode
		  identifier: (CIdentifierNode name: 'round')
		  arguments: { (tast receiver asCASTExpressionIn: self) }
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTSequentialAnd: tast [

	(self nilOrBooleanConstantReceiverOf: tast receiver)
		ifNil: [ 
			(self nilOrBooleanConstantReceiverOf: tast arguments first) 
				ifNotNil: [ :const | 
				const == true ifTrue: [ ^ tast receiver asCASTExpressionIn: self ] ].
			^ self generateCASTAnd: tast ]
		ifNotNil: [ :const | 
			const
				ifTrue: [ ^ tast arguments first asCASTExpressionIn: self ]
				ifFalse: [ ^ CConstantNode value: 0 ] ]
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTSequentialOr: tast [

	(self nilOrBooleanConstantReceiverOf: tast receiver)
		ifNil: [ 
			(self nilOrBooleanConstantReceiverOf: tast arguments first) 
				ifNotNil: [ :const | 
				const == false ifTrue: [ ^ tast receiver asCASTExpressionIn: self ] ].
			^ self generateCASTOr: tast ]
		ifNotNil: [ :const | 
			const
				ifTrue: [ ^ CConstantNode value: 1]
				ifFalse: [ ^ tast arguments first asCASTExpressionIn: self ] ]
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTShiftLeft: tast [

	| finalNode leftNode receiverNode rcvr arg castToLong type mustCastBackToSign mustCastToUnsigned canSuffixTheConstant typeIsUnsigned |
	rcvr := tast receiver.
	arg := tast args first.
	castToLong := false.
	(rcvr constantNumbericValueIfAtAllPossibleOrNilIn: self) ifNotNil: [ 
		:rcvrVal | 
		(arg constantNumbericValueIfAtAllPossibleOrNilIn: self)
			ifNil: [ castToLong := self is64Bit ]
			ifNotNil: [ :argVal | 
				| valueBeyondInt |
				valueBeyondInt := 1 bitShift: 32. "The default type of const << N is int."
				castToLong := rcvrVal < valueBeyondInt and: [ 
					              (rcvrVal bitShift: argVal) >= valueBeyondInt ] ] ].
	canSuffixTheConstant := rcvr isConstant and: [ 
		                        rcvr name isEmpty and: [ rcvr value >= 0 ] ].
	canSuffixTheConstant ifTrue: [ 
		^ CBinaryOperatorNode
			  operator: #<<
			  left: (CConstantNode value:
					   (self
						    cLiteralForUnsignedInteger: rcvr value
						    longlong: castToLong))
			  right: (arg asCASTIn: self) ].
	receiverNode := tast receiver asCASTExpressionIn: self.
	leftNode := receiverNode.
	type := self typeFor: rcvr in: currentMethod.
	castToLong := castToLong and: [ 
		              (self sizeOfIntegralCType: type)
		              < (self sizeOfIntegralCType: #usqLong) ].
	typeIsUnsigned := type first = $u.
	mustCastToUnsigned := typeIsUnsigned not or: [ 
		                      castToLong or: [ 
			                      (self sizeOfIntegralCType: type)
			                      < (self sizeOfIntegralCType: #usqInt) ] ].
	mustCastToUnsigned ifTrue: [ 
		| unsigned |
		unsigned := castToLong
			            ifTrue: [ #usqLong ]
			            ifFalse: [ 
				            (self sizeOfIntegralCType: type)
				            < (self sizeOfIntegralCType: #usqLong)
					            ifTrue: [ #usqInt ]
					            ifFalse: [ self unsignedTypeForIntegralType: type ] ].
		leftNode := CCastExpressionNode
			            type: (CTypeNameNode symbol: unsigned)
			            expression: receiverNode ].
	finalNode := CBinaryOperatorNode
		  operator: #<<
		  left: leftNode
		  right: (arg asCASTIn: self).
	mustCastBackToSign := typeIsUnsigned not.
	mustCastBackToSign ifTrue: [ 
		| promotedType |
		promotedType := castToLong
			                ifTrue: [ #sqLong ]
			                ifFalse: [ 
				                (self sizeOfIntegralCType: type)
				                < (self sizeOfIntegralCType: #sqInt)
					                ifTrue: [ #sqInt ]
					                ifFalse: [ type ] ].
		finalNode := CCastExpressionNode
			            type: (CTypeNameNode symbol: promotedType)
			            expression: finalNode ].

	^ finalNode
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTShiftRight: tast [

	| type rcvr |
	rcvr := tast receiver asCASTIn: self.
	(self
		 is64BitIntegralVariable: tast receiver
		 typeInto: [ :t | type := t ])
		ifTrue: [ 
			type first ~= $u ifTrue: [ 
				rcvr := CCastExpressionNode
					          type: (CTypeNameNode symbol: 'unsigned ' , type)
					          expression: rcvr ] ]
		ifFalse: [ 
			rcvr := CCastExpressionNode
				          type: (CTypeNameNode symbol: 'usqInt')
				          expression: rcvr ].

	^ CBinaryOperatorNode
		  operator: #>>
		  left: rcvr
		  right: (tast arguments first asCASTIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTSignedBitShift: tast [

	| cast type |
	"since ``signed'' is a synonym for ``signed int'' do not cast 64-bit values to signed if at all possible."
	cast := (self
		         is64BitIntegralVariable: tast receiver
		         typeInto: [ :t | type := t ])
		        ifTrue: [ 
			        (type first = $u
				         ifTrue: [ 
					         type allButFirst: (type second = $n
							          ifTrue: [ 2 ]
							          ifFalse: [ 1 ]) ]
				         ifFalse: [ type ]) ]
		        ifFalse: [ 'signed' ].
	^ self generateCASTBitShift: tast cast: cast
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTSignedIntFromLong64: tast [

	^ CCastExpressionNode
		  type: (CTypeNameNode symbol: 'sqLong')
		  expression: (tast receiver asCASTExpressionIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTSignedIntFromLong: tast [

	^ CCastExpressionNode
		  type: (CTypeNameNode symbol: 'int')
		  expression: (tast receiver asCASTExpressionIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTSignedIntFromShort: tast [

	^ CCastExpressionNode
		  type: (CTypeNameNode symbol: 'short')
		  expression: (tast receiver asCASTExpressionIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTSignedIntToLong64: tast [

	^ CCastExpressionNode
		  type: (CTypeNameNode symbol: 'usqInt')
		  expression: (tast receiver asCASTExpressionIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTSignedIntToLong: tast [

	| receiver |
	receiver := tast receiver asCASTExpressionIn: self.
	^ CCastExpressionNode
		  type: (CTypeNameNode symbol: 'usqInt')
		  expression: (self is64Bit
				   ifTrue: [ 
					   CCastExpressionNode
						   type: (CTypeNameNode symbol: 'int')
						   expression: receiver ]
				   ifFalse: [ receiver ])
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTSignedIntToShort: tast [

	^ CCastExpressionNode
		  type: (CTypeNameNode symbol: 'usqInt')
		  expression: (CCastExpressionNode
				   type: (CTypeNameNode symbol: 'short')
				   expression: (tast receiver asCASTExpressionIn: self))
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTSignedShiftRight: tast [

	| cast |
	cast := (self is64BitIntegralVariable: tast receiver typeInto: [ :t |  ])
		        ifTrue: [ 'sqLong' ]
		        ifFalse: [ 'sqInt' ].

	^ CBinaryOperatorNode
		  operator: #>>
		  left: (CCastExpressionNode
				   type: (CTypeNameNode symbol: cast)
				   expression: (tast receiver asCASTIn: self))
		  right: (tast arguments first asCASTIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTSmallIntegerConstant: tast [

	tast selector = #minSmallInteger ifTrue:
		[^ CIdentifierNode name: 'MinSmallInteger'].
	tast selector = #maxSmallInteger ifTrue:
		[^ CIdentifierNode name: 'MaxSmallInteger'].
	self error: 'unknown SmallInteger constant'
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTSmalltalkMetaError: tast [

	^ CCallNode
		  identifier: (CIdentifierNode name: 'error')
		  arguments: { (CStringLiteralNode value: tast selector) }
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTTimes: tast [
	
	"Constant fold if possible"
	tast constantNumbericValueOrNil ifNotNil: [:value|
	 (value between: -1 << 31 and: 1 << 31 - 1)
		ifFalse: [ ^ CConstantNode value: (self cLiteralFor: value) ] ].
	
	"Simplify if possible"
	tast args first constantNumbericValueOrNil ifNotNil: [:value|
		value = 0 ifTrue: [
			^ tast args first asCASTExpressionIn: self ].
		value = 1 ifTrue: [
			^ tast receiver asCASTExpressionIn: self ]].
	
	"Otherwise, translate normally"
	^ self generateCASTBinary: tast operator: #*
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTTimesRepeat: tast [

	| repeat |
	repeat := CCompoundStatementNode statements: OrderedCollection new.
	repeat needsBrackets: false.
	repeat needsSeparator: false.

	tast receiver value timesRepeat: [
		repeat add: (tast arguments first asCASTIn: self) ].

	^ repeat
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTToByDo: tast [

	| blockExpr iterationVar until step mayHaveSideEffects inits limitVar limitExpr |
	blockExpr := tast arguments third.
	blockExpr args size = 1 ifFalse: [ 
		self error: 'wrong number of block arguments' ].
	inits := OrderedCollection new.
	iterationVar := blockExpr args first.
	limitExpr := tast args first.
	inits add: (CAssignmentNode
			 lvalue: (CIdentifierNode name: iterationVar)
			 rvalue: (tast receiver asCASTExpressionIn: self)).
	self noteUsedVariableName: iterationVar.
	mayHaveSideEffects := tast arguments size = 4.
	mayHaveSideEffects ifTrue: [ 
		limitVar := tast args last.
		inits add: (CAssignmentNode
				 lvalue: (CIdentifierNode name: limitVar name)
				 rvalue: (limitExpr asCASTExpressionIn: self)).
		limitExpr := limitVar ].
	until := self
		         generateCASTToByDoUntil: limitExpr
		         iterativeVariable: iterationVar
		         negative:
		         (self stepExpressionIsNegative: tast arguments second).
	step := CAssignmentNode
		        lvalue: (CIdentifierNode name: iterationVar)
		        operator: '+='
		        rvalue: (tast arguments second asCASTExpressionIn: self).
	^ CForStatementNode
		  init: inits
		  until: until
		  step: { step }
		  statement: (blockExpr asCASTIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTToByDoUntil: limitExpr iterativeVariable: itVar negative: negative [
	
	"Generate the limit expression for a to:do: or to:by:do:.
	 If the limitExpr is of the form foo - 1 use < foo or > foo, as appropriate, instead of
	 <= (foo - 1) or >= (foo - 1), so as to avoid 'underflowing' an unsigned value to UINT_MAX."
	| operator limit |
	(limitExpr isSend and: [ 
		 limitExpr selector = #- and: [ 
			 limitExpr arguments first isConstant and: [ 
				 limitExpr arguments first value = 1 ] ] ])
		ifTrue: [ 
			operator := negative
				            ifTrue: [ #> ]
				            ifFalse: [ #< ].
			limit := limitExpr receiver ]
		ifFalse: [ 
			operator := negative
				            ifTrue: [ #>= ]
				            ifFalse: [ #<= ].
			limit := limitExpr ].
	^ CBinaryOperatorNode
		  operator: operator
		  left: (CIdentifierNode name: itVar)
		  right: (limit asCASTExpressionIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTToDo: tast [

	| iterationVar init until step |
	(tast args last args size = 1) ifFalse: [
		self error: 'wrong number of block arguments'.
	].
	iterationVar := tast arguments last args first.
	init := CAssignmentNode
		        lvalue: (CIdentifierNode name: iterationVar)
		        rvalue: (tast receiver asCASTExpressionIn: self).
	self noteUsedVariableName: iterationVar.
	until := self generateCASTToByDoUntil: tast arguments first iterativeVariable: iterationVar negative: false.
	step := CIncrementNode object: (CIdentifierNode name: iterationVar).
	^ CForStatementNode
		  init: { init }
		  until: until
		  step: { step }
		  statement: (tast arguments last asCASTIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTTouch: tast [

	^ CEmptyStatementNode new
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTTruncateTo: tast [

	| arg |
	(self isConstantNode: tast args first valueInto: [ :a | arg := a ]) 
		ifFalse: [ 
		self error: 'can''t find method for inlining truncateTo:' ].
	self assert: (arg isInteger and: [ arg isPowerOfTwo ]).
	^ (CBinaryOperatorNode
		   operator: #&
		   left: (tast receiver asCASTExpressionIn: self)
		   right: (CUnaryOperatorNode
				    operator: #~
				    expression: (CConstantNode value: arg - 1)))
		  needsParentheses: true;
		  yourself
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTUnary: tast operator: operator [

	^ CUnaryOperatorNode
		  operator: operator
		  expression: (tast receiver asCASTExpressionIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTValue: tast [

	"Reduce [:formal ... :formalN| body ] value: actual ... value: actualN
	 to body with formals substituted for by actuals."

	| substitution substitutionDict newLabels castStatements |
	self assert: tast receiver isStmtList.
	self assert: tast receiver args size = tast args size.
	castStatements := CCompoundStatementNode statements:
		                  OrderedCollection new.
	castStatements needsBrackets: false.
	substitution := tast receiver copy.
	substitution renameLabelsForInliningInto: currentMethod.
	substitutionDict := Dictionary new: tast args size * 2.
	tast receiver args with: tast args do: [ :argName :exprNode | 
		exprNode isLeaf
			ifTrue: [ substitutionDict at: argName put: exprNode ]
			ifFalse: [ 
				castStatements add: (CAssignmentNode
						 lvalue: (CIdentifierNode name: argName)
						 rvalue: (exprNode asCASTExpressionIn: self)).
				self noteUsedVariableName: argName ] ].
	substitution bindVariablesIn: substitutionDict.
	castStatements add: (substitution asCASTIn: self).
	newLabels := Set withAll: currentMethod labels.
	substitution nodesDo: [ :node | 
		node isLabel ifTrue: [ 
			node label ifNotNil: [ :label | newLabels add: label ] ] ].
	"now add the new labels so that a subsequent inline of
	 the same block will be renamed with different labels."
	currentMethod labels: newLabels.
	^ castStatements
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTValueAsArgument: tast [

	"Reduce [:formal ... :formalN| body ] value: actual ... value: actualN
	 to body with formals substituted for by actuals."
	| substitution substitutionDict newLabels |
	self assert: tast receiver isStmtList.
	self assert: tast receiver args size = tast args size.
	substitution := tast receiver copy.
	substitution renameLabelsForInliningInto: currentMethod.
	substitutionDict := Dictionary new: tast args size * 2.
	tast receiver args
		with: tast args
		do: [ :argName :exprNode | 
		substitutionDict at: argName put: exprNode ].
	newLabels := Set withAll: currentMethod labels.
	substitution nodesDo: [ :node | 
		node isLabel ifTrue: [ 
			node label ifNotNil: [ :label | newLabels add: label ] ] ].
	"now add the new labels so that a subsequent inline of
	 the same block will be renamed with different labels."
	currentMethod labels: newLabels.
	^ substitution
		  bindVariablesIn: substitutionDict;
		  asCASTExpressionIn: self
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTWhile: boolean loop: tast [

	| condition |
	condition := tast receiver asCASTExpressionIn: self.
	^ CWhileStatementNode
		  while: (boolean
				   ifTrue: [ condition ]
				   ifFalse: [ 
				   CUnaryOperatorNode operator: #! expression: condition ])
		  statement: (tast arguments first asCASTIn: self)
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTWhileFalse: tast [

	tast receiver statements size <= 1
		ifTrue: [^self generateCASTWhile: false loop: tast].
	tast args first isNilStmtListNode
		ifTrue: [^self generateCASTDoWhileFalse: tast].
	^self generateCASTWhileForeverBreakIf: true loop: tast
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTWhileForeverBreakIf: boolean loop: tast [

	| block if cond |
	cond := (tast receiver statements last asCASTExpressionIn: self).
	if := CIfStatementNode if: (boolean ifTrue: [ cond ] ifFalse: [ CUnaryOperatorNode operator: #! expression: cond ]) then: (CBreakStatementNode new).
	block := (TStmtListNode new setStatements: tast receiver statements allButLast) asCASTIn: self.
	block add: if.
	block addAll: (tast arguments first asCASTIn: self).

	^ CWhileStatementNode 
		  while: (CConstantNode value: 1)
		  statement: block
]

{ #category : #'CAST translation' }
CCodeGenerator >> generateCASTWhileTrue: tast [

	tast receiver statements size <= 1
		ifTrue: [^self generateCASTWhile: true loop: tast].
	tast args first isNilStmtListNode
		ifTrue: [^self generateCASTDoWhileTrue: tast].
	^self generateCASTWhileForeverBreakIf: false loop: tast
]

{ #category : #accessing }
CCodeGenerator >> generateDeadCode [
	"Answer whether we should generate 'dead code' branches. This can be useful for hacking the VM when used in conjunction with #useSymbolicConstants, e.g., for code like:
		DoAssertionChecks ifTrue:[
			...
		].

	we will generate

		#define DoAssertionChecks 0
		...
		if(DoAssertionChecks) {
			...
		}.

	allowing us to change the #define (or redefine it as a variable) for later use."
	^generateDeadCode
]

{ #category : #accessing }
CCodeGenerator >> generateDeadCode: aBool [
	"Indicate whether we should generate 'dead code' branches."
	generateDeadCode := aBool
]

{ #category : #'C translation' }
CCodeGenerator >> generateFlag: msgNode on: aStream indent: level [
	"Compoensate for the use of self flag: #aSymbol.  We used to translate  symbols
	 as strings unless they were quoted via #aSymbol asSymbol. But this is too tedious,
	 so we now translate symbols directly.  The only use that this affected was in
		 self flag: #aSymbol,
	 so hard-code it to produce a string value.  Note that this isn't strictly necessary
	 because there's a
		#define flag(foo) 0
	 in C land, but it makes the generated C less dissonant."

	aStream
		nextPutAll: 'flag(';
		nextPutAll: (self cLiteralFor: msgNode args last value asString);
		nextPut: $)
]

{ #category : #'C translation' }
CCodeGenerator >> generateIsNil: msgNode on: aStream indent: level [
	"Generate the C code for this message onto the given stream."

	self emitCExpression: msgNode receiver on: aStream.
	aStream nextPutAll: ' == '.
	aStream nextPutAll: (self cLiteralFor: nil).
]

{ #category : #'C translation' }
CCodeGenerator >> generatePreDecrement: msgNode on: aStream indent: level [
	"Generate the C code for this message onto the given stream."

	| varNode |
	varNode := msgNode receiver.
	varNode isVariable
		ifFalse: [ self error: 'preDecrement can only be applied to variables' ].
	aStream nextPutAll: '--'.
	aStream nextPutAll: (self returnPrefixFromVariable: varNode name).

]

{ #category : #'C translation' }
CCodeGenerator >> generatePreIncrement: msgNode on: aStream indent: level [
	"Generate the C code for this message onto the given stream."

	| varNode |
	varNode := msgNode receiver.
	varNode isVariable
		ifFalse: [ self error: 'preIncrement can only be applied to variables' ].
	aStream nextPutAll: '++'.
	aStream nextPutAll: (self returnPrefixFromVariable: varNode name).

]

{ #category : #'C translation' }
CCodeGenerator >> generateSharedCodeDirective: msgNode on: aStream indent: level [
	"Generate the C code for this message onto the given stream."

	aStream nextPutAll: '/* common code: '.
	aStream nextPutAll: msgNode args first value.
	aStream nextPutAll: ' */'.

]

{ #category : #'C translation' }
CCodeGenerator >> generateSmallIntegerConstant: aSendNode on: aStream indent: indent [
	aSendNode selector = #minSmallInteger ifTrue:
		[^aStream nextPutAll: 'MinSmallInteger'].
	aSendNode selector = #maxSmallInteger ifTrue:
		[^aStream nextPutAll: 'MaxSmallInteger'].
	self error: 'unknown SmallInteger constant'
]

{ #category : #'C translation' }
CCodeGenerator >> generateSmalltalkMetaError: msgNode on: aStream indent: level [
	"Generate the C code for this message onto the given stream."

	aStream nextPutAll: 'error("'; nextPutAll: msgNode selector; nextPutAll: '")'
]

{ #category : #'C translation' }
CCodeGenerator >> generateTouch: msgNode on: aStream indent: level [
	"Generate the C code for this message onto the given stream - which is to say absolutely nothing"

]

{ #category : #public }
CCodeGenerator >> globalsAsSet [
	"Used by the inliner to avoid name clashes with global variables."

	^variables
]

{ #category : #'type inference' }
CCodeGenerator >> harmonizeReturnTypesIn: aSetOfTypes [
	"Eliminate signed/unsigned conflicts in aSetOfTypes. Non-negative integers can be either
	 signed or unsigned. Ignore them unless there are no types, in which case use the default type."
	| constantIntegers |
	constantIntegers := aSetOfTypes select: [:element| element isInteger].
	aSetOfTypes removeAll: constantIntegers.
	^(aSetOfTypes isEmpty and: [constantIntegers notEmpty])
		ifTrue: [Set with: self defaultType]
		ifFalse: [aSetOfTypes]
]

{ #category : #public }
CCodeGenerator >> ifStaticallyResolvedPolymorphicReceiverThenUpdateSelectorIn: aSendNode [
	"We allow a limited amount of polymorphism; if a class chooses, its selectoers can be
	 prefixed with a given string to disambiguate. This hack allows us to use two different
	 compaction algorithms with the same API at the same time; the selection being done
	 by a class which holds the flag stating which algorithm is in effect at the current time."
	| class |
	staticallyResolvedPolymorphicReceivers ifNil: [^self].
	aSendNode receiver isVariable ifFalse:
		[^self].
	class := staticallyResolvedPolymorphicReceivers
				at: aSendNode receiver name
				ifAbsent: [^self].
	aSendNode selector: (class staticallyResolvePolymorphicSelector: aSendNode selector)
]

{ #category : #'type inference' }
CCodeGenerator >> implicitReturnTypeFor: aSelector [
	"Answer the default return type for mthods of the defining class of
	 aSelector. Default to #sqInt if there is no method, or if the method's
	 defining class doesn't understand implicitReturnTypeFor:."
	| m |
	m := methods at: aSelector ifAbsent: [ ^ self defaultType ].
	^[m definingClass implicitReturnTypeFor: aSelector]
		on: MessageNotUnderstood
		do: [:ex|
			ex message selector ~~ #implicitReturnTypeFor: ifTrue:
				[ex pass].
			^ self defaultType]
]

{ #category : #accessing }
CCodeGenerator >> includeAPIFrom: aCCodeGenerator [
	apiMethods := aCCodeGenerator selectAPIMethods.
	apiVariables := aCCodeGenerator selectAPIVariables
]

{ #category : #'type inference' }
CCodeGenerator >> inferTypes [
	
	(SlangTyper on: self)
		stopOnErrors: stopOnErrors;
		inferTypes
]

{ #category : #'initialize-release' }
CCodeGenerator >> initialize [
	translationDict := Dictionary new.
	inlineList := Array new.
	constants := Dictionary new: 100.
	variables := Set new: 100.
	variableDeclarations := Dictionary new: 100.
	methods := Dictionary new: 500.
	macros := Dictionary new.
	self initializeCTranslationDictionary.
	self initializeCASTTranslationDictionary.
	headerFiles := OrderedCollection new.
	globalVariableUsage := Dictionary new.
	useSymbolicConstants := true.
	generateDeadCode := true.
	scopeStack := OrderedCollection new.
	logger := (ProvideAnswerNotification new tag: #logger; signal) ifNil: [Transcript].
	pools := IdentitySet new.
	selectorTranslations := IdentityDictionary new.
	suppressAsmLabels := false.
	previousCommentMarksInlining := false.
	previousCommenter := nil.
	breakSrcInlineSelectors := IdentitySet new.
	breakDestInlineSelectors := IdentitySet new.
	
	stopOnErrors := false.
	wordSize := 4
]

{ #category : #'C translation support' }
CCodeGenerator >> initializeCASTTranslationDictionary [
	"Initialize the dictionary mapping message names to actions for C code generation."

	| pairs |
	
	castTranslationDict := Dictionary new: 200.
	pairs := #(
	#&				#generateCASTAnd:
	#|				#generateCASTOr:
	#abs			#generateCASTAbs:
	#and:			#generateCASTSequentialAnd:
	#or:			#generateCASTSequentialOr:
	#not			#generateCASTNot:

	#+				#generateCASTPlus:
	#-				#generateCASTMinus:
	#negated		#generateCASTNegated:
	#*				#generateCASTTimes:
	#**				#generateCASTPowerTo:
	#/				#generateCASTDivide:
	#//				#generateCASTDivide:
	#\\				#generateCASTModulo:
	#<<				#generateCASTShiftLeft:
	#>>				#generateCASTShiftRight:
	#>>>			#generateCASTSignedShiftRight:
	#min:			#generateCASTMin:
	#max:			#generateCASTMax:
	#between:and:	#generateCASTBetweenAnd:

	#bitAnd:			#generateCASTBitAnd:
	#bitOr:				#generateCASTBitOr:
	#bitXor:			#generateCASTBitXor:
	#bitShift:			#generateCASTBitShift:
	#signedBitShift:	#generateCASTSignedBitShift:
	#bitInvert32		#generateCASTBitInvert32:
	#bitInvert64		#generateCASTBitInvert64:
	#bitClear:			#generateCASTBitClear:
	#truncateTo:		#generateCASTTruncateTo:
	#rounded			#generateCASTRounded:

	#byteSwap32		#generateCASTByteSwap32:
	#byteSwap64		#generateCASTByteSwap64:
	#byteSwapped32IfBigEndian:	generateCASTByteSwap32IfBigEndian:
	#byteSwapped64IfBigEndian:	generateCASTByteSwap64IfBigEndian:
	
	#<				#generateCASTLessThan:
	#<=			#generateCASTLessThanOrEqual:
	#=				#generateCASTEqual:
	#>				#generateCASTGreaterThan:
	#>=			#generateCASTGreaterThanOrEqual:
	#~=			#generateCASTNotEqual:
	#==			#generateCASTEqual:
	#~~			#generateCASTNotEqual:
	#isNil			#generateCASTIsNil:
	#notNil			#generateCASTNotNil:

	#whileTrue: 	#generateCASTWhileTrue:
	#whileFalse:	#generateCASTWhileFalse:
	#whileTrue 	#generateCASTDoWhileTrue:
	#whileFalse		#generateCASTDoWhileFalse:
	#to:do:			#generateCASTToDo:
	#to:by:do:		#generateCASTToByDo:
	#repeat 		#generateCASTRepeat:
	#timesRepeat:	#generateCASTTimesRepeat:

	#ifTrue:			#generateCASTIfTrue:
	#ifFalse:		#generateCASTIfFalse:
	#ifTrue:ifFalse:	#generateCASTIfTrueIfFalse:
	#ifFalse:ifTrue:	#generateCASTIfFalseIfTrue:

	#ifNotNil:		#generateCASTIfNotNil:
	#ifNil:			#generateCASTIfNil:
	#ifNotNil:ifNil:	#generateCASTIfNotNilIfNil:
	#ifNil:ifNotNil:	#generateCASTIfNilIfNotNil:

	#at:				#generateCASTAt:
	#at:put:			#generateCASTAtPut:
	#basicAt:		#generateCASTAt:
	#basicAt:put:	#generateCASTAtPut:

	#integerValueOf:			#generateCASTIntegerValueOf:
	#integerObjectOf:			#generateCASTIntegerObjectOf:
	#isIntegerObject: 			#generateCASTIsIntegerObject:
	#cCode:					#generateCASTInlineCCode:
	#cCode:inSmalltalk:			#generateCASTInlineCCode:
	#cppIf:ifTrue:ifFalse:		#generateCASTInlineCppIfElse:
	#cppIf:ifTrue:				#generateCASTInlineCppIfElse:
	#cCoerce:to:				#generateCASTCCoercion:
	#cCoerceSimple:to:			#generateCASTCCoercion:
	#addressOf:				#generateCASTAddressOf:
	#addressOf:put:			#generateCASTAddressOf:
	#asAddress:put:			#generateCASTAsAddress:
	#signedIntFromLong64		#generateCASTSignedIntFromLong64:
	#signedIntFromLong		#generateCASTSignedIntFromLong:
	#signedIntFromShort		#generateCASTSignedIntFromShort:
	#signedIntToLong64		#generateCASTSignedIntToLong64:
	#signedIntToLong			#generateCASTSignedIntToLong:
	#signedIntToShort			#generateCASTSignedIntToShort:
	#preIncrement				#generateCASTPreIncrement:
	#preDecrement			#generateCASTPreDecrement:
	#asFloat					#generateCASTAsFloat:
	#asInteger					#generateCASTAsInteger:
	#asIntegerPtr				#generateCASTAsIntegerPtr:
	#asUnsignedInteger		#generateCASTAsUnsignedInteger:
	#asUnsignedIntegerPtr		#generateCASTAsUnsignedIntegerPtr:
	#asLong					#generateCASTAsLong:
	#asUnsignedLong			#generateCASTAsUnsignedLong:
	#asUnsignedLongLong		#generateCASTAsUnsignedLongLong:
	#asVoidPointer				#generateCASTAsVoidPointer:
	#asSymbol					#generateCASTAsSymbol:
	#flag:						#generateCASTFlag:
	#anyMask:					#generateCASTBitAnd:
	#allMask:					#generateCASTAllMask:
	#noMask:					#generateCASTNoMask:
	#raisedTo:					#generateCASTRaisedTo:
	#touch:						#generateCASTTouch:

	#bytesPerOop 				#generateCASTBytesPerOop:
	#bytesPerWord 			#generateCASTBytesPerWord:
	#wordSize		 			#generateCASTBytesPerWord:
	#baseHeaderSize			#generateCASTBaseHeaderSize:
	#minSmallInteger			#generateCASTSmallIntegerConstant:
	#maxSmallInteger			#generateCASTSmallIntegerConstant:
	
	#sharedCodeNamed:inCase:		#generateCASTSharedCodeDirective:

	#perform:							#generateCASTPerform:
	#perform:with:						#generateCASTPerform:
	#perform:with:with:					#generateCASTPerform:
	#perform:with:with:with:				#generateCASTPerform:
	#perform:with:with:with:with:		#generateCASTPerform:
	#perform:with:with:with:with:with:	#generateCASTPerform:
	#perform:with:with:with:with:with:with:	#generateCASTPerform:

	#value								#generateCASTValue:
	#value:								#generateCASTValue:
	#value:value:						#generateCASTValue:
	#value:value:value:					#generateCASTValue:
	#value:value:value:value:			#generateCASTValue:
	#value:value:value:value:value:			#generateCASTValue:
	#value:value:value:value:value:value:	#generateCASTValue:

	#deny:								#generateCASTDeny:

	#shouldNotImplement				#generateCASTSmalltalkMetaError:
	#shouldBeImplemented			#generateCASTSmalltalkMetaError:
	#subclassResponsibility			#generateCASTSmalltalkMetaError:
	).

	1 to: pairs size by: 2 do: [:i |
		castTranslationDict at: (pairs at: i) put: (pairs at: i + 1)].

	pairs := #(
	#ifTrue:					#generateCASTIfTrueAsArgument:	
	#ifFalse:				#generateCASTIfFalseAsArgument:
	#ifTrue:ifFalse:			#generateCASTIfTrueIfFalseAsArgument:
	#ifFalse:ifTrue:			#generateCASTIfFalseIfTrueAsArgument:
	#ifNotNil:				#generateCASTIfNotNilAsArgument:	
	#ifNil:					#generateCASTIfNilAsArgument:
	#ifNotNil:ifNil:			#generateCASTIfNotNilIfNilAsArgument:
	#ifNil:ifNotNil:			#generateCASTIfNilIfNotNilAsArgument:
	#cCode:				#generateCASTInlineCCodeAsArgument:
	#cCode:inSmalltalk:		#generateCASTInlineCCodeAsArgument:
	#cppIf:ifTrue:ifFalse:	#generateCASTInlineCppIfElseAsArgument:
	#cppIf:ifTrue:			#generateCASTInlineCppIfElseAsArgument:
				
	#value					#generateCASTValueAsArgument:
	#value:					#generateCASTValueAsArgument:
	#value:value:			#generateCASTValueAsArgument:
	).

	castAsArgumentTranslationDict := Dictionary new: 15.
	1 to: pairs size by: 2 do: [:i |
		castAsArgumentTranslationDict at: (pairs at: i) put: (pairs at: i + 1)].

]

{ #category : #inlining }
CCodeGenerator >> initializerForInstVar: varName in: aClass [
	| instVarIndex |
	instVarIndex := aClass instVarIndexFor: varName ifAbsent: [^nil].
	aClass selectorsAndMethodsDo:
		[:s :m| | tmeth |
		((s beginsWith: 'initialize')
		 and: [m writesField: instVarIndex]) ifTrue:
			[tmeth := m asTranslationMethodOfClass: TMethod.
			 tmeth parseTree nodesDo:
				[:node| | exprOrAssignment |
				(node isAssignment
				 and: [node variable name = varName]) ifTrue:
					[exprOrAssignment := node.
					 [exprOrAssignment isAssignment] whileTrue:
						[exprOrAssignment := exprOrAssignment expression].
					 ^exprOrAssignment]]]].
	^nil
]

{ #category : #inlining }
CCodeGenerator >> initializerForInstVar: varName inStartClass: aClass [
	| allClasses sizeBefore |
	(aClass inheritsFrom: SlangClass) ifFalse:
		[^false].
	allClasses := (aClass withAllSuperclasses copyUpTo: SlangClass) asSet.
	[sizeBefore := allClasses size.
	 allClasses copy do:
		[:class|
		class ancilliaryClasses do:
			[:ancilliary|
			allClasses addAll: (ancilliary withAllSuperclasses copyUpTo: SlangClass)]].
	 sizeBefore ~= allClasses size] whileTrue.
	allClasses do:
		[:class|
		(self initializerForInstVar: varName in: class) ifNotNil:
			[:initializer| ^initializer]].
	^nil
]

{ #category : #inlining }
CCodeGenerator >> inlineDispatchesInMethodNamed: selector localizingVars: varsList [
	"Inline dispatches (case statements) in the method with the given name."

	| m |
	m := self methodNamed: selector.
	m = nil ifFalse: [
		m inlineCaseStatementBranchesIn: self localizingVars: varsList.
		m parseTree nodesDo: [ :n |
			n isCaseStmt ifTrue: [
				n customizeShortCasesForDispatchVar: 'currentBytecode' in: self method: m.
			].
		].
	].
	varsList do: [ :v | | varString |
		varString := v asString.
		self checkDeleteVariable: varString.
		variables remove: varString ifAbsent: [].
		(variableDeclarations includesKey: varString) ifTrue: [
			m declarationAt: v asString put: (variableDeclarations at: varString).
			variableDeclarations removeKey: varString.
		].
	]
]

{ #category : #utilities }
CCodeGenerator >> instVarNamesForClass: aClass [
	^ aClass instVarNames

]

{ #category : #'C translation' }
CCodeGenerator >> is32Bit [
	^ self wordSize = 4
]

{ #category : #'C translation' }
CCodeGenerator >> is64Bit [
	^ self is32Bit not
]

{ #category : #'C translation support' }
CCodeGenerator >> is64BitIntegralVariable: node typeInto: aBlock [
	| decl |
	^node isVariable
	  and: [(decl := self typeOfVariable: node name) notNil
	  and: [(#('usqLong' 'sqLong' 'unsigned long long' 'long long' 'unsigned __int64' '__int64')
			anySatisfy: [:type| decl beginsWith: type])
	  and: [aBlock value: ((decl endsWith: node name)
							ifTrue: [decl allButLast: node name size + 1]
							ifFalse: [decl]).
			true]]]
]

{ #category : #utilities }
CCodeGenerator >> isAcceptableAncilliaryClass: class [
	^ true
]

{ #category : #inlining }
CCodeGenerator >> isActualType: actualTypeOrNil compatibleWithFormalType: formalTypeOrNil [ 
	| actualType formalType |
	actualType := actualTypeOrNil ifNil: [#sqInt].
	formalType := formalTypeOrNil ifNil: [#sqInt].
	((self isIntegralCType: actualType)
	 and: [self isIntegralCType: formalType]) ifFalse:
		[^actualType = formalType
		 or: [formalType = #double and: [actualType = #float]]].
	"For now, insist that the signedness agrees.  If the actual's type is unknown allow inlining.
	 A formal defaults to #sqInt. Allowing inlining an unsigned type within a sqInt formal is wrong;
	 snd for testing, it breaks e.g. the BitBltPlugin."
	^(actualType first = $u) = (formalType first = $u)
	  or: [actualTypeOrNil isNil] 
]

{ #category : #inlining }
CCodeGenerator >> isAssertSelector: selector [
	^#(assert: asserta: assert:l: asserta:l: deny: eassert:) includes: selector
]

{ #category : #utilities }
CCodeGenerator >> isBuiltinSelector: sel [
	"Answer true if the given selector is one of the builtin selectors."

	^(self isKernelSelector: sel) or: [translationDict includesKey: sel]
]

{ #category : #'C code generator' }
CCodeGenerator >> isCLiteral: anObject [
	anObject isInteger ifTrue: [^true].
	anObject isString ifTrue: [^true].
	anObject isFloat ifTrue: [^true].
	anObject == nil ifTrue: [^true].
	anObject == true ifTrue: [^true].			"ikp"
	anObject == false ifTrue: [^true].			"ikp"
	anObject isCharacter ifTrue:[^true]. "ar"
	^false
]

{ #category : #utilities }
CCodeGenerator >> isConstantNode: aNode valueInto: aBlock [
	"Answer if aNode evaluates to a constant, and if so, evaluate aBlock with the value of that constant."

	aNode isConstant ifTrue: [ 
		(aNode isDefine and: [ self defineAtCompileTime: aNode name ]) 
			ifTrue: [ ^ false ].
		aBlock value: aNode value.
		^ true ].
	(aNode isVariable and: [ aNode name = #nil ]) ifTrue: [ 
		aBlock value: nil.
		^ true ].
	aNode isSend ifTrue: [ 
		(self anyMethodNamed: aNode selector)
			ifNil: [ 
				| hasValue |
				hasValue := self valueOfConstantNode: aNode doing: aBlock.
				hasValue ifTrue: [ ^ true ] ]
			ifNotNil: [ :m | 
				(m statements size = 1 and: [ m statements last isReturn ]) 
					ifTrue: [ 
						^ self
							  isConstantNode: m statements last expression
							  valueInto: aBlock ] ] ].
	^ false
]

{ #category : #inlining }
CCodeGenerator >> isFloatingPointCType: aCType [ "<String>"
	^#('float' 'double' 'long double') includes: aCType asString
]

{ #category : #'type inference' }
CCodeGenerator >> isFunctionalCType: aType [
	"Answer if aType is either a function or a pointer to a function."
	^aType last == $) and: [(aType indexOf: $() > 0]
]

{ #category : #utilities }
CCodeGenerator >> isGeneratingPluginCode [
	^false
]

{ #category : #public }
CCodeGenerator >> isGlobalStructureBuild [
	^false
]

{ #category : #inlining }
CCodeGenerator >> isIntegralCType: aCType [ "<String>"
	^(#('sqLong' 'usqLong' 'sqInt' 'usqInt' 'sqIntptr_t' 'usqIntptr_t'
		'long' 'long long' 'int' 'short' 'short int' 'char' 'signed char'
		'size_t' 'pid_t') includes: aCType asString)
	or: [(aCType beginsWith: 'unsigned') "Accept e.g. 'unsigned long' and also 'unsigned  : 8'"
		and: [(aCType includesAnyOf: '[*]') not]]
]

{ #category : #utilities }
CCodeGenerator >> isKernelSelector: sel [
	"Answer true if the given selector is one of the kernel selectors that are implemented as macros."

	^(#(error:
		 oopAt: oopAt:put: oopAtPointer: oopAtPointer:put:
		 byteAt: byteAt:put: byteAtPointer: byteAtPointer:put:
		 shortAt: shortAt:put: shortAtPointer: shortAtPointer:put:
		 intAt: intAt:put: intAtPointer: intAtPointer:put:
		 longAt: longAt:put: longAtPointer: longAtPointer:put:
		 long32At: long32At:put: long64At: long64At:put:
		 fetchFloatAt:into: storeFloatAt:from: fetchFloatAtPointer:into: storeFloatAtPointer:from:
		 fetchSingleFloatAt:into: storeSingleFloatAt:from: fetchSingleFloatAtPointer:into: storeSingleFloatAtPointer:from:
		 pointerForOop: oopForPointer:
		 cCoerce:to: cCoerceSimple:to:)
			includes: sel)
]

{ #category : #utilities }
CCodeGenerator >> isNilConstantReceiverOf: sendNode [
	"Answer true if the receiver of the given message send is the constant nil. Used to suppress conditional code when the condition is a translation-time constant."

	| val |
	generateDeadCode ifTrue: [^false].
	^(self isConstantNode: sendNode receiver valueInto: [:v| val := v])
	  and: [val isNil]
]

{ #category : #'type inference' }
CCodeGenerator >> isNode: aNode constantValueWithinRangeOfType: aType [
	"Answer if aNode is a constant value within the range of an integral type.
	 If aNode isn't an integral constant or aType isn't an integral type then answer false."

	| value |
	^ aNode expression isConstant
		and: [ (self isIntegralCType: aType)
				and: [ (value := aNode expression value) isInteger
						and: [ value positive
								and: [ (aType first = $u
										ifTrue: [ value bytesCount ]
										ifFalse: [ (value highBit + 7) // 8 ])
										<= (self sizeOfIntegralCType: aType) ] ] ] ]
]

{ #category : #'C code generator' }
CCodeGenerator >> isNonArgumentImplicitReceiverVariableName: aString [

	^ (self typeOfVariable: aString) == #implicit
]

{ #category : #'type inference' }
CCodeGenerator >> isPointerCType: aType [
	^aType last == $*
]

{ #category : #inlining }
CCodeGenerator >> isQuickCompiledMethod: aCompiledMethod [
	^aCompiledMethod isQuick
	 or: [(#(pushConstant: pushLiteralVariable:) includes: (aCompiledMethod abstractBytecodeMessageAt: aCompiledMethod initialPC) selector)
		and: [(aCompiledMethod abstractBytecodeMessageAt: (InstructionStream on: aCompiledMethod) followingPc) selector == #methodReturnTop]]
]

{ #category : #'type inference' }
CCodeGenerator >> isSimpleType: aType [
	"For the purposes of the read-before-written initializer, answer if
	 aType is simple, e.g. not a structure, and array or an opaque type."
	^(self isPointerCType: aType)
	  or: [ (self isIntegralCType: aType)
		or: [ 
			"The type affected to literal floating point numbers"
			aType = #double ]]
]

{ #category : #inlining }
CCodeGenerator >> isSpecialSelector: aSelector [
		
	^ translationDict includesKey: aSelector
]

{ #category : #utilities }
CCodeGenerator >> isStructSend: aTSendNode [
	"Answer if the argument aTSendNode is a send of a structure accessor.
	 This is tricky.  We want
		foo bar => foo->bar
		foo bar => foo.bar
		foo bar: expr => foo->bar = expr
		foo bar: expr => foo.bar = expr
	 depending on whether foo is a struct or a pointer to a struct,
	 but only if both foo is a struct type and bar is a field accessor.
	 The tricky cases are self-sends within struct class methods.  Here we need to
	 distinguish between self-sends of ordinary methods from self sends of accessors."
	^aTSendNode numArgs <= 1
	   and: [(aTSendNode receiver structTargetKindIn: self) notNil
	   and: [(self methodNamed: aTSendNode selector)
				ifNil: [false]
				ifNotNil: [:method| method isStructAccessor]]]
]

{ #category : #inlining }
CCodeGenerator >> isVoidPointer: aCType [ "<String>"
	"sigh..."
	^#('void *' 'void*') includes: aCType asString
]

{ #category : #utilities }
CCodeGenerator >> localizeGlobalVariables [
	| candidates elected localized |

	"find all globals used in only one method"
	candidates := globalVariableUsage select: [:e | e size = 1].
	"Don't localize globals; nor those that are only assigned to; they're for debugging..."
	(candidates keys select: [:k| (self mustBeGlobal: k)
								or: [(self methodNamed: (globalVariableUsage at: k) anyOne)
										ifNil: [false]
										ifNotNil: [:m| (m readsVariable: k) not]]]) do:
		[:k| candidates removeKey: k].
	
	elected := Set new.
	localized := Dictionary new. "for an ordered report"
	"move any suitable global to be local to the single method using it"
	candidates keysAndValuesDo:
		[:key :targets |
		targets do:
			[:name |
			(methods at: name ifAbsent: []) ifNotNil:
				[:procedure | | newDeclaration |
				(procedure isRealMethod
				 and: [self shouldGenerateMethod: procedure]) ifTrue:
					[(localized at: name ifAbsentPut: [SortedCollection new]) add: key.
					elected add: (procedure locals add: key).
					newDeclaration := variableDeclarations at: key ifAbsent: ['sqInt ', key].
					(self initializerForInstVar: key inStartClass: procedure definingClass) ifNotNil:
						[:initializerNode|
						newDeclaration := String streamContents:
												[:s|
												 s nextPutAll: newDeclaration; nextPutAll: ' = '.
												(initializerNode asCASTIn: self) prettyPrintOn: s ]].
					procedure declarationAt: key put: newDeclaration.
					variableDeclarations removeKey: key ifAbsent: []]]]].
	logger ifNotNil:
		[localized keys asSortedCollection do:
			[:name|
			(localized at: name) do:
				[:var|
				logger newLine; show: var, ' localised to ', name; cr]]].
	elected do: [:ea| (variables includes: ea) ifTrue: [self checkDeleteVariable: ea]].
	variables removeAllFoundIn: elected
]

{ #category : #utilities }
CCodeGenerator >> logger [
	^logger
]

{ #category : #utilities }
CCodeGenerator >> logger: aTranscriptStream [
	logger := aTranscriptStream
]

{ #category : #inlining }
CCodeGenerator >> mayInline: sel [
	"Answer if the method with the given selector may be inlined."

	^(self isAssertSelector: sel) not and: [inlineList includes: sel]
]

{ #category : #inlining }
CCodeGenerator >> maybeBreakForInlineOf: aNode in: aTMethod [
	"convenient for debugging..."
	(aNode isSend
	and: [breakSrcInlineSelectors size + breakDestInlineSelectors size > 0
	and: [(breakSrcInlineSelectors isEmpty or: [breakSrcInlineSelectors includes: aNode selector])
	and: [(breakDestInlineSelectors isEmpty or: [(breakDestInlineSelectors includes: aTMethod selector)])
	and: [breakOnInline ~~ false]]]]) ifTrue:
		[aTMethod halt: aTMethod selector, ' ', aNode selector]
]

{ #category : #inlining }
CCodeGenerator >> maybeBreakForTestOfInliningOf: aNodeOrSelector [
	"convenient for debugging..."
	| selector |
	selector := aNodeOrSelector isSymbol
					ifTrue: [aNodeOrSelector]
					ifFalse:
						[aNodeOrSelector isSend
							ifTrue: [aNodeOrSelector selector]
							ifFalse: [^self]].
	((breakSrcInlineSelectors includes: selector)
	 and: [breakDestInlineSelectors isEmpty
	 and: [breakOnInline == true]]) ifTrue:
		[self halt: selector]
]

{ #category : #inlining }
CCodeGenerator >> maybeBreakForTestToInline: aNodeOrSelector in: aTMethod [
	"convenient for debugging..."
	| selector |
	selector := aNodeOrSelector isSymbol
					ifTrue: [aNodeOrSelector]
					ifFalse:
						[aNodeOrSelector isSend
							ifTrue: [aNodeOrSelector selector]
							ifFalse: [^self]].
	(breakSrcInlineSelectors size + breakDestInlineSelectors size > 0
	and: [(breakSrcInlineSelectors isEmpty or: [breakSrcInlineSelectors includes: selector])
	and: [(breakDestInlineSelectors isEmpty or: [(breakDestInlineSelectors includes: aTMethod selector)])
	and: [breakOnInline ~~ true]]]) ifTrue:
		[aTMethod halt: aTMethod selector, ' ', selector]
]

{ #category : #'C code generator' }
CCodeGenerator >> maybePutPreambleFor: aClass on: aStream [
	aClass preambleCCode ifNotNil:
		[:preamble| | actualClass |
		 actualClass := aClass class whichClassIncludesSelector: #preambleCCode.
		 aStream
			newLine; newLine;
			nextPutAll: '/* '; print: actualClass; nextPutAll: '>>preambleCCode */'; cr;
			nextPutAll: preamble; cr;
			nextPutAll: '/* end '; print: actualClass; nextPutAll: '>>preambleCCode */'; cr]
]

{ #category : #utilities }
CCodeGenerator >> messageReceiverIsInterpreterProxy: sendNode [
	^self isGeneratingPluginCode
	  and: [sendNode receiver isVariable
	  and: ['interpreterProxy' = sendNode receiver name
	  and: [(self isKernelSelector: sendNode selector) not]]]
]

{ #category : #utilities }
CCodeGenerator >> methodNamed: selector [
	"Answer the method in the code base with the given selector."
	^ methods at: selector ifAbsent: [ nil ]
]

{ #category : #inlining }
CCodeGenerator >> methodStatsString [
	"Return a string describing the size, # of locals, and # of senders of
	 each method. Note methods that have inline C code or C declarations."

	| methodsWithCCode sizesOf callsOf s |
	methodsWithCCode := Set new: methods size.
	sizesOf := Dictionary new: methods size * 2.  "selector -> nodeCount"
	callsOf := Dictionary new: methods size * 2.  "selector -> senderCount"

	"For each method, scan its parse tree once to:
		1. determine if the method contains C code or declarations
		2. determine how many nodes it has
		3. increment the sender counts of the methods it calls
		4. determine if it includes any C declarations or code"

	methods do: [ :m | | hasCCode nodeCount |
		(translationDict includesKey: m selector) ifTrue: [
			hasCCode := true.
		] ifFalse: [
			hasCCode := m declarations size > 0.
			nodeCount := 0.
			m parseTree nodesDo: [ :node | | selr senderCount |
				node isSend ifTrue: [
					selr := node selector.
					node isNonNullCCode ifTrue: [ hasCCode := true ].
					senderCount := callsOf at: selr ifAbsent: [ 0 ].
					callsOf at: selr put: senderCount + 1.
				].
				nodeCount := nodeCount + 1.
			].
		].
		hasCCode ifTrue: [ methodsWithCCode add: m selector ].
		sizesOf at: m selector put: nodeCount.
	].

	s := WriteStream on: (String new: 5000).
	(self sortStrings: methods keys) do: [ :sel | | m calls registers |
		m := methods at: sel.
		registers := m locals size + m args size.
		calls := callsOf at: sel ifAbsent: [0].
		registers > 11 ifTrue: [
			s nextPutAll: sel; tab.
			s nextPutAll: (sizesOf at: sel) printString; tab.
			s nextPutAll: calls printString; tab.
			s nextPutAll: registers printString; tab.
			(methodsWithCCode includes: sel) ifTrue: [ s nextPutAll: 'CCode' ].
		s cr.
		].
	].
	^ s contents
]

{ #category : #accessing }
CCodeGenerator >> methods [

	^ methods
]

{ #category : #utilities }
CCodeGenerator >> methodsForDefiningClass: dc [
	"Answer a collection of methods that refer to the given global variable."

	^methods select: [:tMethod| tMethod definingClass == dc]
]

{ #category : #utilities }
CCodeGenerator >> methodsReferringToGlobal: v [
	"Return a collection of methods that refer to the given global variable."

	| out |
	out := OrderedCollection new.
	methods associationsDo: [ :assoc |
		(assoc value freeVariableReferences includes: v) ifTrue: [
			out add: assoc key.
		].
	].
	^ out
]

{ #category : #utilities }
CCodeGenerator >> methodsThatCanInvoke: aSelectorList [
	"Return a set of methods that can invoke one of the given selectors, either directly or via a sequence of intermediate methods."

	| out todo sel |
	out := Set new.
	todo := aSelectorList copy asOrderedCollection.
	[todo isEmpty] whileFalse: [
		sel := todo removeFirst.
		out add: sel.
		methods do: [ :m | | mSelector |
			(m allCalls includes: sel) ifTrue: [
				mSelector := m selector.
				((out includes: mSelector) or:
				 [todo includes: mSelector]) ifFalse: [
					todo add: mSelector.
				].
			].
		].
	].
	^ out
	
]

{ #category : #translating }
CCodeGenerator >> mostBasicConstantSelectors [
	"Returns a list of selectors that should be translated as macros"
	^ #()
]

{ #category : #utilities }
CCodeGenerator >> mustBeGlobal: aName [
	^ false
]

{ #category : #'C code generator' }
CCodeGenerator >> needToGenerateHeader: headerName file: interpHdrPath contents: newContentsArg [
	"Check if we need to regenerate a header file.  We always need to if the contents have changed.
	 But if not we can avoid needless recompilations by not regenerating.  So only regenerate if the
	 package stamp is dirty and the monticello stamp is clean."

	| newContents oldContents dirtyStamp |
	interpHdrPath asFileReference exists ifFalse: [ ^ true ].
	newContents := newContentsArg.
	oldContents := interpHdrPath asFileReference contents.
	oldContents := oldContents
		               copyReplaceAll: { 
				               Character cr.
				               Character lf }
		               with: { Character cr }.
	oldContents replaceAll: Character lf with: Character cr.
	dirtyStamp := (oldContents indexOfSubCollection: '* VMMaker') ~= 0.
	(newContents beginsWith: '/*') = (oldContents beginsWith: '/*') 
		ifFalse: [ 
			(newContents beginsWith: '/*') ifTrue: [ 
				newContents := newContents readStream
					               upToAll: '*/';
					               skipSeparators;
					               upToEnd ].
			(oldContents beginsWith: '/*') ifTrue: [ 
				oldContents := oldContents readStream
					               upToAll: '*/';
					               skipSeparators;
					               upToEnd ] ].
	^ oldContents ~= newContents or: [ 
		  (dirtyStamp and: [ self shouldGenerateHeader ]) or: [ 
			  self confirm: headerName
				  ,
					  ' contents are unchanged.\Writing the file may cause recompilation of support files.\Do you want to write the header file?'
						  withCRs ] "If no stamp don't worry" ]
]

{ #category : #utilities }
CCodeGenerator >> nilOrBooleanConditionFor: nodeOrNil [
	"If nodeOrNil is one of the conditional sends for which we do translation-time dead code elimination
	 (i.e. cppIf:ifTrue: et al or ifTrue: et al) and the conditional does evaluate to a translation-time
	 boolean constant, answer that constant, otherwise answer nil.  Used to prune dead code,
	 either for code generaton or dead variable elimination."

	generateDeadCode ifTrue: [ ^ nil ].
	nodeOrNil ifNil: [ ^ nil ].
	nodeOrNil isSend ifFalse: [ ^ nil ].
	(#( ifTrue: ifFalse: #ifTrue:ifFalse: #ifFalse:ifTrue: ) includes:
		 nodeOrNil selector) ifTrue: [ 
		^ self nilOrBooleanConstantReceiverOf: nodeOrNil receiver ].
	(#( and: or: ) includes: nodeOrNil selector) ifTrue: [ 
		^ self nilOrBooleanConstantReceiverOf: nodeOrNil ].
	(#( #cppIf:ifTrue: #cppIf:ifTrue:ifFalse: ) includes: nodeOrNil selector) 
		ifTrue: [ 
		| maybeName value |
		value := nodeOrNil args first value.
		self validateCppIf: nodeOrNil withValue: value.
		maybeName := nodeOrNil args first isConstant ifTrue: [ 
			             nodeOrNil args first nameOrValue ].
		^ (optionsDictionary notNil and: [ 
			   nodeOrNil args first isConstant and: [ 
				   (#( true false ) includes:
					    (optionsDictionary at: maybeName ifAbsent: [ nil ])) and: [ 
					   (self defineAtCompileTime: maybeName) not ] ] ]) 
			  ifTrue: [ optionsDictionary at: nodeOrNil args first name ] ].
	^ nil
]

{ #category : #utilities }
CCodeGenerator >> nilOrBooleanConstantReceiverOf: aNode [
	"Answer nil or the boolean constant that is the receiver of the given message send.
	 Used to suppress conditional code when the condition is a translation-time constant."

	| val receiver argument arms |
	generateDeadCode ifTrue:[^nil].
	((self isConstantNode: aNode valueInto: [:v| val := v])
	 and: [#(true false) includes: val]) ifTrue:
		[^val].
	aNode isSend ifTrue:
		[aNode selector == #not ifTrue:
			[(self nilOrBooleanConstantReceiverOf: aNode receiver) ifNotNil:
				[:bool| ^bool not]].
		 ((#(isNil notNil) includes: aNode selector)
		  and: [self isNilConstantReceiverOf: aNode]) ifTrue:
			[^aNode selector == #isNil].
		 ((#(or: and:) includes: aNode selector)
		 and: [aNode args last isStmtList
		 and: [aNode args last statements size = 1]]) ifTrue:
			[(self nilOrBooleanConstantReceiverOf: aNode receiver) ifNotNil:
				[:rcvr|
				((rcvr == false and: [aNode selector == #and:])
				 or: [rcvr == true and: [aNode selector == #or:]]) ifTrue:
					[^rcvr].
				(self nilOrBooleanConstantReceiverOf: aNode args last statements first) ifNotNil:
					[:arg|
					^rcvr perform: aNode selector with: [arg]]].
			 "We can also eliminate expr and: [false], expr or: [true], but only if expr is side-effect free.
			  This is a weak test; we don't traverse calls.  Caveat emptor!"
			 ((aNode receiver noneSatisfy: [:node| node isAssignment]) "No side-effects in the elided expression"
			  and: [aNode args last statements size = 1]) ifTrue:
				[(self nilOrBooleanConstantReceiverOf: aNode args last statements first) ifNotNil:
					[:arg|
					((arg == false and: [aNode selector == #and:])
					 or: [arg == true and: [aNode selector == #or:]]) ifTrue:
						[^arg]]]].
		"Look for Const ifTrue: [self foo] ifFalse: [false] => false"
		 ((#(ifTrue:ifFalse: ifFalse:ifTrue:) includes: aNode selector)
		  and: [(self isConstantNode: aNode receiver valueInto: [:v| val := v])
		  and: [(#(true false) includes: val)
		  and: [arms := aNode args collect:
							[:altBlock| | bval |
							 (altBlock statements size = 1
							 and: [(self isConstantNode: altBlock statements last valueInto: [:v| bval := v])
							 and: [#(true false) includes: bval]]) ifTrue:
								[bval]].
				arms asArray ~= #(nil nil)]]]) ifTrue:
			[| arm |
			 arm := aNode selector == #ifTrue:ifFalse: == val
						ifTrue: [arms first]
						ifFalse: [arms last].
			 (#(true false) includes: arm) ifTrue:
				[^arm]].
		 ((#(= ~= < > <= >=) includes: aNode selector)
		  and: [(self isConstantNode: aNode receiver valueInto: [:v| receiver := v])
		  and: [receiver isInteger
		  and: [(self isConstantNode: aNode args first valueInto: [:v| argument := v])
		  and: [argument isInteger]]]]) ifTrue:
			[^receiver perform: aNode selector with: argument].
		 "Inlining for e.g. CharacterTable ifNil: [...] ifNotNil: [...]], which compiles to CharacterTable == nil ifTrue: [...] ifFalse: [...]"
		(aNode selector == #==
		 and: [aNode args first isVariable
		 and: [aNode args first name = 'nil'
		 and: [aNode receiver isConstant
		 and: [aNode receiver value == nil]]]]) ifTrue:
			[^true]].
	^nil
]

{ #category : #'translation support' }
CCodeGenerator >> nilTranslation [
	"Defined in some header file as a macro?"
	^ 'NULL'
]

{ #category : #inlining }
CCodeGenerator >> node: exprNode typeCompatibleWith: argName inliningInto: targetMethod in: aTMethod [
	"Answer either exprNode or, if required, a cast of exprNode to the type of argName.
	 The cast is required if
		- argName is typed and exprNode is untyped
		- argName is untyped and exprNode is an arithmetic type of size > #sqInt
		- both argName and exprNode are typed but they are incompatible"
	| formalType actualType |
	formalType := targetMethod typeFor: argName in: self.
	actualType := self typeFor: exprNode in: aTMethod.
	^((exprNode isSend or: [exprNode isVariable])
	   and: [(formalType notNil and: [actualType isNil])
			or: [(formalType isNil and: [actualType notNil and: [(self isIntegralCType: actualType) and: [(self sizeOfIntegralCType: actualType) > (self sizeOfIntegralCType: #sqInt)]]])
			or: [(self variableOfType: formalType acceptsValue: exprNode ofType: actualType) not]]])
		ifTrue: [self nodeToCast: exprNode to: (formalType ifNil: [#sqInt])]
		ifFalse:
			[((exprNode isSend or: [exprNode isVariable])
			  and: [(self
					variableOfType: (targetMethod typeFor: argName in: self)
					acceptsValue: exprNode
					ofType: (self typeFor: exprNode in: aTMethod)) not]) ifTrue:
				[logger
					nextPutAll:
						'type mismatch for formal ', argName, ' and actual "', exprNode asString,
						'" when inlining ', targetMethod selector, ' in ', aTMethod selector, '. Use a cast.';
					cr; flush]. 
			exprNode]
]

{ #category : #utilities }
CCodeGenerator >> nodeIsDeadCode: aNode withParent: parentNode [
	"Answer if aNode would not be generated due to dead code elimination."
	^(self nilOrBooleanConditionFor: parentNode)
		ifNil: [false]
		ifNotNil:
			[:cond| | filter |
			filter := parentNode selector caseOf:
							{   "First element is accessor for filtered (eliminated) node if expression is true.
								Second element is accessor for filtered (eliminated) node if expression is false."
								[#ifFalse:]				-> [#(first nil)].
								[#ifFalse:ifTrue:] 		-> [#(first last)].
								[#ifTrue:]				-> [#(nil first)].
								[#ifTrue:ifFalse:]			-> [#(last first)].
								[#and:]					-> [#(nil first)].
								[#or:]					-> [#(last nil)].
								[#cppIf:ifTrue:]			-> [#(nil #second)].
								[#cppIf:ifTrue:ifFalse:]	-> [#(third #second)] }.
			(cond ifTrue: [filter first] ifFalse: [filter last])
				ifNil: [false]
				ifNotNil: [:accessor| aNode == (parentNode args perform: accessor)]]
]

{ #category : #inlining }
CCodeGenerator >> nodeToCast: exprNode to: cType [
	^TSendNode new
		setSelector: #cCoerceSimple:to:
		receiver: (TVariableNode new setName: 'self')
		arguments: { exprNode. TConstantNode value: cType }
		isBuiltInOp: true
]

{ #category : #utilities }
CCodeGenerator >> nonStructClassesForTranslationClasses: classes [
	"Answer in superclass order (any superclass precedes any subclass)
	 the ancilliaryClasses that are not struct classes for all the given classes."

	| nonStructClasses |
	nonStructClasses := OrderedCollection new.
	classes do: [ :aTranslationClass | 
		aTranslationClass ancilliaryClasses do: [ :class | 
			(self isAcceptableAncilliaryClass: class) ifTrue: [ 
				(class isStructClass or: [ 
					 (nonStructClasses includes: class) or: [ 
						 classes includes: class ] ]) ifFalse: [ 
					nonStructClasses addLast: class ] ] ] ].
	^ self superclassOrder: nonStructClasses
]

{ #category : #utilities }
CCodeGenerator >> noteUsedVariableName: variableName [
	currentMethod ifNotNil:
		[:m| m noteUsedVariableName: variableName]
]

{ #category : #utilities }
CCodeGenerator >> noteVariableUsageInString: aString [
	currentMethod ifNotNil:
		[:m|
		 (Scanner new typedScanTokens: aString) do:
			[:token|
			 (token isString and: [token first isLetter or: [token first == $_]]) ifTrue:
				[m noteUsedVariableName: token]]]
]

{ #category : #utilities }
CCodeGenerator >> optionIsTrue: pragma in: aClass [
	"Answer whether an option: or notOption: pragma is true in the context of aClass.
	 The argument to the option: pragma is interpreted as either a Cogit class name
	 or a class variable name or a variable name in VMBasicConstants."
	| key |
	key := pragma argumentAt: 1.
	(self defineAtCompileTime: key)
		ifTrue: [ ^ true ].
	
	^ false
]

{ #category : #accessing }
CCodeGenerator >> options [
	^optionsDictionary
]

{ #category : #accessing }
CCodeGenerator >> options: aDictionary [
	"Set optionsDictionary to the argument and scan it for accessors on the receiver,
	 performing the accessor with the value, allowing one to specify things like
	 generateDeadCode: false in the options."
	optionsDictionary := aDictionary.
	optionsDictionary keysAndValuesDo:
		[:k :v| | accessor |
		((self class instVarNames includes: k)
		and: [(Symbol hasInterned: k, ':' ifTrue: [:s| accessor := s])
		and: [self class canUnderstand: accessor]]) ifTrue:
			[self perform: accessor with: v]]
]

{ #category : #utilities }
CCodeGenerator >> outputAsmLabel: selector on: aStream [
	| count |
	suppressAsmLabels ifTrue: [^self].
	asmLabelCounts ifNil:
		[asmLabelCounts := Dictionary new].
	count := asmLabelCounts
				at: selector
				put: 1 + (asmLabelCounts at: selector ifAbsent: [-1]).
	 aStream
		nextPutAll: 'VM_LABEL(';
		nextPutAll: (self cFunctionNameFor: selector);
		nextPutAll: (count = 0 ifTrue: [''] ifFalse: [count printString]);
		nextPut: $);
		nextPut: $;
]

{ #category : #'C code generator' }
CCodeGenerator >> preDeclareInterpreterProxyOn: aStream [
	"Put the necessary #defines needed before interpreterProxy.  Basically
	 internal plugins use the VM's interpreterProxy variable and external plugins use
	 their own.  In addition the VMPluginCodeGenerator can choose to keep local copies
	 all functions."
	aStream cr; nextPutAll: '#ifdef SQUEAK_BUILTIN_PLUGIN'.
	aStream cr; nextPutAll: 'extern'.
	aStream cr; nextPutAll: '#endif'; cr
]

{ #category : #utilities }
CCodeGenerator >> prepareMethods [
	| globals |
	globals := Set new: 200.
	globals addAll: variables.
	methods do:
		[:m |
		m locals, m args do:
			[:var |
			(globals includes: var) ifTrue:
				[self error: 'Local variable ''', var, ''' may mask global when inlining ', m selector].
			((methods at: var ifAbsent: [nil]) ifNil: [false] ifNotNil: [:m1| m1 isStructAccessor not]) ifTrue:
				[logger
					newLine;
					nextPutAll: 'Local variable name ''', var, ''' in ';
					nextPutAll: m selector;
					nextPutAll: ' may mask method when inlining';
					cr]].
		m bindClassVariablesIn: constants.
		m prepareMethodIn: self]
]

{ #category : #accessing }
CCodeGenerator >> previousCommentMarksInlining [
	^previousCommentMarksInlining
]

{ #category : #accessing }
CCodeGenerator >> previousCommentMarksInlining: aBoolean [
	| previousValue |
	previousValue := previousCommentMarksInlining.
	previousCommentMarksInlining := aBoolean.
	^previousValue
]

{ #category : #accessing }
CCodeGenerator >> previousCommenter [
	^previousCommenter
]

{ #category : #accessing }
CCodeGenerator >> previousCommenter: aTParseNodeOrNil [
	| previousValue |
	previousValue := previousCommenter.
	previousCommenter := aTParseNodeOrNil.
	^previousValue
]

{ #category : #'error notification' }
CCodeGenerator >> printUnboundCallWarnings [
	"Print a warning message for every unbound method call in the code base."

	| knownSelectors undefinedCalls |
	undefinedCalls := Dictionary new.
	knownSelectors := translationDict keys asSet.
	knownSelectors add: #error:.
	methods do: [ :m | knownSelectors add: m selector ].
	methods do: [ :m |
		m allCalls do: [ :sel |
			(knownSelectors includes: sel) ifFalse: [
				(undefinedCalls includesKey: sel)
					ifTrue: [ (undefinedCalls at: sel) add: m selector ]
					ifFalse: [ undefinedCalls at: sel put: (OrderedCollection with: m selector) ].
			].
		].
	].

	logger cr.
	(self sortStrings: undefinedCalls keys) do: [ :undefined |
		logger show: undefined, ' -- undefined method sent by:'; cr.
		(undefinedCalls at: undefined) do: [ :caller |
			logger tab; show: caller; cr.
		].
	].
]

{ #category : #'error notification' }
CCodeGenerator >> printUnboundVariableReferenceWarnings [
	"Print a warning message for every unbound variable reference in the code base."

	| undefinedRefs globalVars |
	undefinedRefs := Dictionary new.
	globalVars := Set new: 100.
	globalVars addAll: variables.
	methods do: [ :m | | knownVars |
		knownVars := globalVars copy.
		m args do: [ :var | knownVars add: var ].
		m locals do: [ :var | knownVars add: var ].
		m freeVariableReferences do: [ :varName |
			(knownVars includes: varName) ifFalse: [
				(undefinedRefs includesKey: varName)
					ifTrue: [ (undefinedRefs at: varName) add: m selector ]
					ifFalse: [ undefinedRefs at: varName put: (OrderedCollection with: m selector) ].
			].
		].
	].

	logger cr.
	(self sortStrings: undefinedRefs keys) do: [ :var |
		logger show: var, ' -- undefined variable used in:'; cr.
		(undefinedRefs at: var) do: [ :sel |
			logger tab; show: sel; cr.
		].
	].
]

{ #category : #'type inference' }
CCodeGenerator >> promoteArithmeticTypes: firstType and: secondType [
	
	"If either type is unknown, answer nil."
	(firstType isNil or: [secondType isNil]) ifTrue:
		[^nil].

	"Answer the return type for an arithmetic send.  This is so that the inliner can still inline
	 simple expressions.  Deal with pointer arithmetic, floating point arithmetic and promotion.
	 It is important to choose deterministically to get stable source generation.
	 Also, the behaviour of inlined and non inlined code should be unchanged."
	((#(#double float) includes: firstType)
	 or: [#(#double float) includes: secondType]) ifTrue:
		[^(firstType = #double or: [secondType = #double])
			ifTrue: [#double]
			ifFalse: [#float] "in C99 6.3.1.8, float+int, int is converted as a float"].

	"Deal with integer promotion and arithmetic conversion"
	^self promoteIntegerArithmeticTypes: firstType and: secondType
]

{ #category : #'type inference' }
CCodeGenerator >> promoteIntegerArithmeticTypes: firstType and: secondType [
	"Answer the return type for an arithmetic send.
	Deal with integer promotion rules of C99.
	See section 6.3 Conversions of the standard.
	
	6.3.1.1 ...snip...
		If an int can represent all values of the original type, the value is converted to an int;
		otherwise, it is converted to an unsigned int. These are called the integer promotions.
		All other types are unchanged by the integer promotions

	6.3.1.8 ...snip...
		Otherwise, the integer promotions are performed on both operands
		Then the following rules are applied to the promoted operands:

			If both operands have the same type, then no further conversion is needed.

			Otherwise, if both operands have signed integer types or both have unsigned integer
			types, the operand with the type of lesser integer conversion rank is converted to the
			type of the operand with greater rank.

			Otherwise, if the operand that has unsigned integer type has rank greater or equal to
			the rank of the type of the other operand, then the operand with signed integer type
			is converted to the type of the operand with unsigned integer type.

			Otherwise, if the type of the operand with signed integer type can represent all of the
			values of the type of the operand with unsigned integer type, then the operand with
			unsigned integer type is converted to the type of the operand with signed integer type.

			Otherwise, both operands are converted to the unsigned integer type corresponding to
			the type of the operand with signed integer type.

	This is so that the generated code behaviour is insensitive to inlining."
	| length1 length2 intSize |
	length1 := self sizeOfIntegralCType: firstType.
	length2 := self sizeOfIntegralCType: secondType.
	intSize := self sizeOfIntegralCType: #int.
	(length1 < intSize and: [length2 < intSize]) ifTrue: [^#int].	"Integer promotion"
	length1 > length2 ifTrue: [^firstType].
	length2 > length1 ifTrue: [^secondType].
	firstType first = $u ifTrue: [^firstType].
	secondType first = $u ifTrue: [^secondType].
	^firstType
]

{ #category : #inlining }
CCodeGenerator >> pruneMethods: selectorList [
	"Explicitly prune some methods"
	selectorList do: [:sel| self removeMethodForSelector: sel]
]

{ #category : #inlining }
CCodeGenerator >> pruneUnreachableMethods [
	"Remove any methods that are not reachable. Retain methods needed by the translated classes - see implementors of requiredMethodNames"
 	
	| neededSelectors newMethods previousSize visited |
	"add all the exported methods and all the called methods to the requiredSelectors"
	"keep all the fake methods (macros and struct accessors; these are needed
	 to ensure correct code generation."

	neededSelectors := Set withAll: requiredSelectors.
	methods do: [ :m |
		m export ifTrue:
			[neededSelectors add: m selector].
		m isAPIMethod ifTrue:
			[neededSelectors add: m selector].
		m isRealMethod ifFalse:
			[neededSelectors add: m selector]].

	"Now compute the transitive closure..."
	previousSize := neededSelectors size.
	visited := IdentitySet new: methods size.
	[neededSelectors do:
		[:s|
		(methods at: s ifAbsent: []) ifNotNil:
			[:m|
			(visited includes: m) ifFalse:
				[visited add: m.
				 (m isRealMethod
				  and: [self shouldGenerateMethod: m]) ifTrue:
					[neededSelectors addAll: m allCalls]]]].
	 neededSelectors size > previousSize]
		whileTrue:
			[previousSize := neededSelectors size].

	"build a new dictionary of methods from the collection of all the ones to keep"			
	newMethods := Dictionary new: neededSelectors size.
	neededSelectors do:
		[:sel|
		methods at: sel ifPresent: [:meth| newMethods at: sel put: meth]].
	methods := newMethods
]

{ #category : #'C code generator' }
CCodeGenerator >> pushScope: variableToType "<Dictionary>" while: aBlock [
	scopeStack addLast: variableToType.
	^aBlock ensure: [scopeStack removeLast]
]

{ #category : #'C code generator' }
CCodeGenerator >> putConditionalDefineOf: aConstantNameString as: valueOrValueString comment: commentOrNil on: aStream [
	self withConditionalDefineOf: aConstantNameString
		comment: commentOrNil
		on: aStream
		do: [| valueAsString |
			 valueAsString := valueOrValueString asString.
			 valueAsString first ~= $# ifTrue:
				[aStream nextPutAll: '# define '; nextPutAll: aConstantNameString; space].
			 aStream nextPutAll: valueAsString; cr]
]

{ #category : #'C code generator' }
CCodeGenerator >> putDefineOf: aConstantNameString as: valueOrValueString on: aStream [
	aStream
		nextPutAll: '#define ';
		nextPutAll: aConstantNameString;
		space;
		nextPutAll: valueOrValueString asString;
		cr
]

{ #category : #inlining }
CCodeGenerator >> removeAssertions [
	"Remove all assertions in method bodies.  This is for the benefit of inlining, which
	fails to recognise and disregard empty method bodies when checking the inlinability
	of sends."

	| newMethods |
	newMethods := Dictionary new.
	'Removing assertions...'
		displayProgressAt: Sensor cursorPoint
		from: 0 to: methods size
		during: [ :bar |
			methods doWithIndex: [ :m :i |
				bar value: i.
				m isAssertion ifFalse: [
					newMethods at: m selector put: m.
					m removeAssertions]]].
	methods := newMethods.
]

{ #category : #utilities }
CCodeGenerator >> removeConstant: aName [
	"Remove the given (class) variable from the code base."

	constants removeKey:  aName ifAbsent: []
]

{ #category : #utilities }
CCodeGenerator >> removeMethodForSelector: aSelector [
	"Remove the given method from the code base"
	((breakSrcInlineSelectors includes: aSelector)
	 or: [(breakDestInlineSelectors includes: aSelector)]) ifTrue:
		[self halt].
	methods removeKey:  aSelector ifAbsent: []
]

{ #category : #inlining }
CCodeGenerator >> removeMethodsReferingToGlobals: varList except: methodName [
	"Remove any methods (presumably inlined) that still contain references to the given
	 global variables. Answer a Dictionary of the removed methods for later reporting."

	| varListAsStrings removed |
	varListAsStrings := varList collect: [ :sym | sym asString ].
	removed := Dictionary new: methods size / 2.
	methods copy keysAndValuesDo:
		[ :sel :meth| | mVars |
		sel ~= methodName ifTrue:
			[mVars := meth freeVariableReferences asSet.
			 (varListAsStrings anySatisfy: [ :v | mVars includes: v]) ifTrue:
				[removed at: sel put: meth.
				self removeMethodForSelector: sel]]].

	^removed
]

{ #category : #utilities }
CCodeGenerator >> removeVariable: aName [
	"Remove the given (instance) variable from the code base."

	self
		removeVariable: aName
		ifAbsent: [ self error: 'variable missing: ' , aName ]
]

{ #category : #utilities }
CCodeGenerator >> removeVariable: aName ifAbsent: ifAbsentBlock [
	"Remove the given (instance) variable from the code base."
	self checkDeleteVariable: aName.
	variableDeclarations removeKey: aName ifAbsent: [].
	^variables remove: aName ifAbsent: ifAbsentBlock
]

{ #category : #utilities }
CCodeGenerator >> reportRecursiveMethods [
	"Report in transcript all methods that can call themselves directly or indirectly or via a chain of N intermediate methods."

	methods do: [: m | | visited calls newCalls sel called |
		visited := translationDict keys asSet.
		calls := m allCalls asOrderedCollection.
		5 timesRepeat: [
			newCalls := Set new: 50.
			[calls isEmpty] whileFalse: [
				sel := calls removeFirst.
				sel = m selector ifTrue: [
					logger newLine; show: m selector, ' is recursive'; cr.
				] ifFalse: [
					(visited includes: sel) ifFalse: [
						called := self methodNamed: sel.
						called = nil ifFalse: [ newCalls addAll: called allCalls ].
					].
					visited add: sel.
				].
			].
			calls := newCalls asOrderedCollection.
		].
	].
]

{ #category : #inlining }
CCodeGenerator >> reportShouldNotBeRemoved: removed varList: varList [
	"Report whether any of the removed methods are still used."
]

{ #category : #'C translation support' }
CCodeGenerator >> reservedWords [
	^#(	'auto'
		'break'
		'case' 'char' 'const' 'continue'
		'default' 'do' 'double'
		'else' "'entry' obsolete" 'enum' 'extern'
		'float' 'for'
		'goto'
		'if' 'int'
		'long'
		'register' 'return'
		'short' 'signed' 'sizeof' 'static' 'struct' 'switch'
		'typedef'
		'union' 'unsigned'
		'void' 'volatile'
		'while')
]

{ #category : #inlining }
CCodeGenerator >> retainMethods: aListOfSelectorsToKeep [
	"add aListOfSelectorsToKeep to requiredSelectors so that they will not be pruned"
	requiredSelectors ifNil:[requiredSelectors := Set new:100].
	requiredSelectors addAll: aListOfSelectorsToKeep.
	^aListOfSelectorsToKeep
]

{ #category : #utilities }
CCodeGenerator >> returnPrefixFromVariable: aName [
	^aName
]

{ #category : #'type inference' }
CCodeGenerator >> returnTypeForSend: sendNode in: aTMethod boundTo: aCalledMethod typeIfNil: typeIfNil [
	"Answer the return type for a send.  Unbound sends default to typeIfNil.
	 Methods with types as yet unknown have a type determined either by the
	 kernelReturnTypes or the table below, or, if they are in neither set, then nil.
	 The inferred type should match as closely as possible the C type of
	 generated expessions so that inlining would not change the expression.
	 If there is a method for sel but its return type is as yet unknown it mustn't
	 be defaulted, since on a subsequent pass its type may be computable."

	^sendNode selector
				caseOf: {
				[#integerValueOf:]		->	[#sqInt].
				[#isIntegerObject:]		->	[#int].
				[#negated]				->	[self promoteArithmeticTypes: (sendNode receiver typeFrom: self in: aTMethod) and: #int].
				[#+]					->	[self typeForArithmetic: sendNode in: aTMethod].
				[#-]						->	[self typeForArithmetic: sendNode in: aTMethod].
				[#*]					->	[self typeForArithmetic: sendNode in: aTMethod].
				[#/]						->	[self typeForArithmetic: sendNode in: aTMethod].
				[#//]					->	[self typeForArithmetic: sendNode in: aTMethod].
				[#\\]					->	[self typeForArithmetic: sendNode in: aTMethod].
				[#rem:]					->	[self typeForArithmetic: sendNode in: aTMethod].
				[#quo:]					->	[self typeForArithmetic: sendNode in: aTMethod].
				"C99 Sec Bitwise shift operators ... 3 Sematics ...
				 The integer promotions are performed on each of the operands. The type of the result is that of the promoted left operand..."
				[#>>]					->	[sendNode receiver typeFrom: self in: aTMethod].
				[#<<]					->	[sendNode receiver typeFrom: self in: aTMethod].
				[#addressOf:]			->	[(sendNode receiver typeFrom: self in: aTMethod)
												ifNil: [#sqInt]
												ifNotNil: [:type| type, (type last isLetter ifTrue: [' *'] ifFalse: ['*'])]].
				[#at:]					->	[self typeForDereference: sendNode in: aTMethod].
				[#bitAnd:]				->	[self typeForArithmetic: sendNode in: aTMethod].
				[#bitOr:]				->	[self typeForArithmetic: sendNode in: aTMethod].
				[#bitXor:]				->	[self typeForArithmetic: sendNode in: aTMethod].
				[#bitClear:]				->	[self typeForArithmetic: sendNode in: aTMethod].
				[#bitInvert32]			->	[#'unsigned int'].
				[#bitInvert64]			->	[self promoteArithmeticTypes: (sendNode receiver typeFrom: self in: aTMethod) and: #int].
				[#byteSwap32]			->	[#'unsigned int'].
				[#byteSwap64]			->	[#'unsigned long long'].
				[#byteSwapped32IfBigEndian:]	->	[#'unsigned int'].
				[#byteSwapped64IfBigEndian:]	->	[#'unsigned long long'].
				[#=]					->	[#int].
				[#~=]					->	[#int].
				[#==]					->	[#int].
				[#~~]					->	[#int].
				[#<]					->	[#int].
				[#<=]					->	[#int].
				[#>]					->	[#int].
				[#>=]					->	[#int].
				[#between:and:]		->	[#int].
				[#anyMask:]				->	[#int].
				[#allMask:]				->	[#int].
				[#noMask:]				->	[#int].
				[#isNil]					->	[#int].
				[#notNil]				->	[#int].
				[#&]					->	[#int].
				[#|]						->	[#int].
				[#not]					->	[#int].
				[#asFloat]				->	[#double].
				[#atan]					->	[#double].
				[#exp]					->	[#double].
				[#log]					->	[#double].
				[#sin]					->	[#double].
				[#sqrt]					->	[#double].
				[#asLong]				->	[#long].
				[#asInteger]			->	[#sqInt].
				[#asIntegerPtr]			->	[#'sqIntptr_t'].
				[#asUnsignedInteger]	->	[#usqInt].
				[#asUnsignedIntegerPtr]->	[#'usqIntptr_t'].
				[#asUnsignedLong]		->	[#'unsigned long'].
				[#asUnsignedLongLong]		->	[#'unsigned long long'].
				[#asVoidPointer]		->	[#'void *'].
				[#signedIntToLong]		->	[#usqInt]. "c.f. generateSignedIntToLong:on:indent:"
				[#signedIntToShort]	->	[#usqInt]. "c.f. generateSignedIntToShort:on:indent:"
				[#cCoerce:to:]			->	[self conventionalTypeForType: sendNode args last value].
				[#cCoerceSimple:to:]	->	[self conventionalTypeForType: sendNode args last value].
				[#sizeof:]				->	[#'usqIntptr_t']. "Technically it's a size_t but it matches on target architectures so far..."
				[#ifTrue:ifFalse:]		->	[self typeForConditional: sendNode in: aTMethod].
				[#ifFalse:ifTrue:]		->	[self typeForConditional: sendNode in: aTMethod].
				[#ifTrue:]				->	[self typeForConditional: sendNode in: aTMethod].
				[#ifFalse:]				->	[self typeForConditional: sendNode in: aTMethod].
				[#and:]					->	[#sqInt].
				[#or:]					->	[#sqInt].
				[#caseOf:]				->	[self typeFor: sendNode args first in: aTMethod] }
				otherwise: "If there /is/ a method for sel but its return type is as yet unknown it /mustn't/ be defaulted,
							since on a subsequent pass its type may be computable.  Only default unbound selectors."
					[aCalledMethod ifNotNil: [nil] ifNil: [typeIfNil]]
]

{ #category : #'type inference' }
CCodeGenerator >> returnTypeForSend: sendNode in: aTMethod ifNil: typeIfNil [
	"Answer the return type for a send.  Unbound sends default to typeIfNil.
	 Methods with types as yet unknown have a type determined either by the
	 kernelReturnTypes or the table below, or, if they are in neither set, then nil.
	 The inferred type should match as closely as possible the C type of
	 generated expessions so that inlining would not change the expression.
	 If there is a method for sel but its return type is as yet unknown it mustn't
	 be defaulted, since on a subsequent pass its type may be computable."
	| sel methodOrNil |

	methodOrNil := self anyMethodNamed: (sel := sendNode selector).

	(methodOrNil notNil and: [methodOrNil returnType notNil]) ifTrue:
		[^self baseTypeForType: methodOrNil returnType].

	^ self
		returnTypeForSend: sendNode
		in: aTMethod
		boundTo: methodOrNil
		typeIfNil: typeIfNil
]

{ #category : #accessing }
CCodeGenerator >> selectAPIMethods [
	^methods select: [:m| m isAPIMethod]
]

{ #category : #accessing }
CCodeGenerator >> selectAPIVariables [
	^variableDeclarations reject: [:decl| decl includesSubstring: 'static ']
]

{ #category : #'C code generator' }
CCodeGenerator >> selectorReturnsPointerToStruct: selector [ "<Symbol>"
	| tMethod |
	^(tMethod := methods
					at: selector
					ifAbsent:
						[apiMethods ifNotNil:
							[apiMethods at: selector ifAbsent: []]]) notNil
	  and: [SlangStructType isTypePointerToStruct: tMethod returnType]
]

{ #category : #'C code generator' }
CCodeGenerator >> selectorReturnsStruct: selector [ "<Symbol>"
	| tMethod |
	^(tMethod := methods
					at: selector
					ifAbsent:
						[apiMethods ifNotNil:
							[apiMethods at: selector ifAbsent: []]]) notNil
	  and: [SlangStructType isTypeStruct: tMethod returnType]
]

{ #category : #utilities }
CCodeGenerator >> selectorsAndMethodsDo: aBinaryBlock [
	methods keysAndValuesDo: aBinaryBlock
]

{ #category : #'C code generator' }
CCodeGenerator >> shortMonticelloDescriptionForClass: aClass [
	"Answer a suitable Monticello package stamp to include in a moduleName."
	^self class shortMonticelloDescriptionForClass: aClass
]

{ #category : #utilities }
CCodeGenerator >> shouldGenerateAsInterpreterProxySend: aSendNode [
	^ false
]

{ #category : #'C code generator' }
CCodeGenerator >> shouldGenerateHeader [
	^ false
]

{ #category : #utilities }
CCodeGenerator >> shouldGenerateMethod: aTMethod [
	^(self isBuiltinSelector: aTMethod selector)
		ifTrue: [requiredSelectors includes: aTMethod selector]
		ifFalse: [aTMethod inline ~~ #always]
]

{ #category : #'C code generator' }
CCodeGenerator >> shouldGenerateStruct: structClass [

	^ structClass isAbstract not
]

{ #category : #utilities }
CCodeGenerator >> shouldIncludeMethodFor: aClass selector: selector [
	"Answer whether a method shoud be translated.  Process optional methods by
	 interpreting the argument to the option: pragma as either a Cogit class name
	 or a class variable name or a variable name in VMBasicConstants.  Exclude
	 methods with the doNotGenerate pragma."

	| optionPragmas notOptionPragmas |
	(aClass >> selector pragmaAt: #doNotGenerate) ifNotNil: [ ^ false ].

	"where is pragmasAt: ??"
	optionPragmas := (aClass >> selector) pragmas select: [ :p | 
		                 p selector == #option: ].
	notOptionPragmas := (aClass >> selector) pragmas select: [ :p | 
		                    p selector == #notOption: ].
	(optionPragmas notEmpty or: [ notOptionPragmas notEmpty ]) ifTrue: [ 
		^ (optionPragmas allSatisfy: [ :pragma | 
			   self optionIsTrue: pragma in: aClass ]) and: [ 
			  notOptionPragmas noneSatisfy: [ :pragma | 
				  self optionIsTrue: pragma in: aClass ] ] ].
	^ true
]

{ #category : #'type inference' }
CCodeGenerator >> signedTypeForIntegralType: aCTypeString [
	(aCTypeString beginsWith: 'unsigned ') ifTrue:
		[^aCTypeString allButFirst: 8].
	
	(aCTypeString beginsWith: 'usq') ifTrue:
		[^aCTypeString allButFirst].

	aCTypeString = 'size_t' ifTrue: [^#usqIntptr_t].
	
	self error: 'unknown type'.
	^#long
]

{ #category : #inlining }
CCodeGenerator >> sizeOfIntegralCType: anIntegralCType [ "<String>"
	"N.B. Only works for values for which isIntegralCType: answers true."
	| prunedCType index |
	(anIntegralCType beginsWith: 'register ') ifTrue:
		[^self sizeOfIntegralCType: (anIntegralCType allButFirst: 9)].
	prunedCType := (anIntegralCType beginsWith: 'unsigned ')
						ifTrue: [(anIntegralCType allButFirst: 9) withBlanksTrimmed]
						ifFalse: [(anIntegralCType beginsWith: 'signed ')
									ifTrue: [(anIntegralCType allButFirst: 7) withBlanksTrimmed]
									ifFalse: [anIntegralCType]].
	
	^prunedCType asString caseOf: {
		['sqLong']	->	[8].
		['usqLong']	->	[8].
		['long long']	->	[8].
		['sqInt']		->	[self bytesPerOop].
		['usqInt']	->	[self bytesPerOop].
		['sqIntptr_t']	->	[self bytesPerWord].
		['usqIntptr_t']	->	[self bytesPerWord].
		['int']		->	[4].
		['short']		->	[2].
		['short int']	->	[2].
		['char']		->	[1].
		['long']		->	[self bytesPerWord]. "It's ambiguous on LLP64 and we'll later remove it"
		['size_t']	->	[self bytesPerWord].
		['pid_t']		->	[self bytesPerWord].
		
		"Standard C types"
		['uint64_t']		->	[8].
		['uint32_t']		->	[4].
	}
	otherwise:
		[((anIntegralCType beginsWith: 'unsigned') "e.g. 'unsigned  : 8'"
		  and: [(anIntegralCType includesAnyOf: '[*]') not
		  and: [(index := anIntegralCType indexOf: $:) > 0]])
			ifTrue: [(Integer readFrom: (anIntegralCType copyFrom: index + 1 to: anIntegralCType size) withBlanksTrimmed readStream) + 7 // 8]
			ifFalse: [self error: 'unrecognized integral type']]
]

{ #category : #utilities }
CCodeGenerator >> sortMethods: aTMethodCollection [
	"We need to define this since different Squeak versions answer different results
	 for asSortedCollection and if sort order changes, generated code changes too.
	 When generating VM code, use class name as major sort index as this groups
	 some methods by functionality (e.g. SpurGenerationScavenger) and that makes
	 the VMProfiler more useful."
	^aTMethodCollection asSortedCollection:
		(self isGeneratingPluginCode
			ifTrue:
				[[:a :b| a selector caseSensitiveLessOrEqual: b selector]]
			ifFalse:
				[[:a :b|
				  a definingClass = b definingClass
					ifTrue: [a selector caseSensitiveLessOrEqual: b selector]
					ifFalse: [a definingClass name caseSensitiveLessOrEqual: b definingClass name]]])
]

{ #category : #utilities }
CCodeGenerator >> sortStrings: aStringOrSymbolCollection [
	"We need to define this since different Squeak versions answer different results
	 for asSortedCollection and if sort order changes, generated code changes too."
	^aStringOrSymbolCollection asSortedCollection: [:a :b| a caseSensitiveLessOrEqual: b]
]

{ #category : #public }
CCodeGenerator >> sortedExportMethods [
	"Answer a suitably-sorted array of all exported TMethods"
	^(methods select: [:m| m export]) asSortedCollection: [:a :b| a selector caseSensitiveLessOrEqual: b selector]
]

{ #category : #public }
CCodeGenerator >> staticallyResolveMethodNamed: selector forClass: aClass to: staticallyResolvedSelector [
	"We allow a limited amount of polymorphism; if a class chooses, its selectoers can be
	 prefixed with a given string to disambiguate. This hack allows us to use two different
	 compaction algorithms with the same API at the same time; the selection being done
	 by a class which holds the flag stating which algorithm is in effect at the current time."
	| method |
	method := methods
					removeKey: selector
					ifAbsent:
						[self logger cr; nextPutAll: 'warning: did not find ', selector, ' to be able to map to ', staticallyResolvedSelector.
						^self].
	method selector: staticallyResolvedSelector.
	methods at: staticallyResolvedSelector put: method
]

{ #category : #public }
CCodeGenerator >> staticallyResolvedPolymorphicReceiver: variableName to: aClass [
	"We allow a limited amount of polymorphism; if a class chooses, its selectoers can be
	 prefixed with a given string to disambiguate. This hack allows us to use two different
	 compaction algorithms with the same API at the same time; the selection being done
	 by a class which holds the flag stating which algorithm is in effect at the current time."
	(staticallyResolvedPolymorphicReceivers ifNil: [staticallyResolvedPolymorphicReceivers := Dictionary new])
		at: variableName
		put: aClass
]

{ #category : #'C translation support' }
CCodeGenerator >> stepExpressionIsNegative: aNode [
	"Answer if the step expression (the by: argument in a to:by:do:) is negative."
	self isConstantNode: aNode valueInto: [:stepValue| ^stepValue < 0].
	(aNode isSend and: [aNode selector == #negated]) ifTrue:
		[self isConstantNode: aNode receiver valueInto: [:stepValue| ^stepValue > 0]].
	^false
]

{ #category : #utilities }
CCodeGenerator >> stopOnErrors: aBoolean [
	stopOnErrors := aBoolean
]

{ #category : #public }
CCodeGenerator >> storeCodeOnFile: fileName doInlining: inlineFlag [
	"Store C code for this code base on the given file."

	self storeCodeOnFile: fileName doInlining: inlineFlag doAssertions: true
]

{ #category : #public }
CCodeGenerator >> storeCodeOnFile: fileName doInlining: inlineFlag doAssertions: assertionFlag [
	"Store C code for this code base on the given file."

	| stream |
	stream := VMMaker forceNewFileNamed: fileName.
	stream ifNil: [Error signal: 'Could not open C code file: ', fileName].
	self emitCCodeOn: stream doInlining: inlineFlag doAssertions: assertionFlag.
	stream close
]

{ #category : #public }
CCodeGenerator >> storeHeaderOnFile: fileName contents: contents [
	"Store C header code on the given file. Evaluate
	 aBlock with the stream to generate its contents."

	| aStream fileNameGuard |
	aStream := VMMaker forceNewFileNamed: fileName.
	
	fileNameGuard := (fileName asFileReference basename asUppercase replaceAll: $. with: $_)  , '__'.
	
	aStream ifNil: [ self error: 'Could not open C header file: ', fileName].
	
	[(contents beginsWith: '/* Automatic') ifFalse:
		[
		aStream nextPutAll: (self fileHeaderVersionStampForSourceClass: nil); cr].
		aStream nextPutAll: ('#ifndef {1}
#define {1}
' format: {fileNameGuard}).
	 	aStream nextPutAll: contents.
		aStream nextPutAll: '#endif']
		ensure: [aStream close]
]

{ #category : #inlining }
CCodeGenerator >> structAccessorSelectors [
		
	^ methods
		select: [ :m | m isStructAccessor ]
		thenCollect: [ :m | m selector]
]

{ #category : #'C code generator' }
CCodeGenerator >> structClasses [

	^ structClasses ifNil: [ #() ]
]

{ #category : #utilities }
CCodeGenerator >> structClassesForTranslationClasses: classes [
	"Answer in superclass order (any superclass precedes any subclass)
	 the ancilliaryClasses that are struct classes for all the given classes."

	| theStructClasses |
	theStructClasses := OrderedCollection new.
	classes do: [ :aTranslationClass | 
		aTranslationClass ancilliaryClasses do: [ :class | 
			(class isStructClass and: [ 
				 (self isAcceptableAncilliaryClass: class) and: [ 
					 (theStructClasses includes: class) not ] ]) ifTrue: [ 
				theStructClasses addLast: class ] ] ].
	^ self superclassOrder: theStructClasses
]

{ #category : #'C code generator' }
CCodeGenerator >> structTargetKindForDeclaration: typeName [ "<String>"
	^SlangStructType structTargetKindForDeclaration: typeName
]

{ #category : #'C code generator' }
CCodeGenerator >> structTargetKindForVariableName: varName [ "<String>"
	^(self typeOfVariable: varName) ifNotNil:
		[:declaration|
		 self structTargetKindForDeclaration: declaration]
]

{ #category : #utilities }
CCodeGenerator >> superclassOrder: classes [
	^[ChangeSet superclassOrder: classes] "Squeak"
		on: MessageNotUnderstood
		do: [ :ex|
			ex message selector == #superclassOrder: ifFalse:
				[ex pass].
			Class superclassOrder: classes] "Pharo"
]

{ #category : #accessing }
CCodeGenerator >> suppressAsmLabels [
	^suppressAsmLabels
]

{ #category : #accessing }
CCodeGenerator >> suppressAsmLabels: aBoolean [
	suppressAsmLabels := aBoolean
]

{ #category : #utilities }
CCodeGenerator >> suppressAsmLabelsWhile: aBlock [
	| oldSuppressAsmLabels |
	oldSuppressAsmLabels := suppressAsmLabels.
	suppressAsmLabels := true.
	^aBlock ensure: [suppressAsmLabels := oldSuppressAsmLabels]
]

{ #category : #utilities }
CCodeGenerator >> testInliningFor: selector as: inlineFlagOrSymbol [
	"Test inlining for the method with the given selector.
	 Do all inlining first (cuz that's how the algorithm works).
	 Then try and inline into a copy of the method.  This isn't
	 exactly what happens in the real deal but is close enough."
	| meth |
	((breakDestInlineSelectors includes:  selector)
	 or: [(breakSrcInlineSelectors includes:  selector)]) ifTrue:
		[self halt].
	meth := (self methodNamed: selector) copy.
	self doBasicInlining: inlineFlagOrSymbol.
	self halt.
	meth tryToInlineMethodsIn: self
]

{ #category : #utilities }
CCodeGenerator >> translationMethodClass [
	"return the class used to produce C translation methods from MethodNodes"
	^TMethod
]

{ #category : #'type inference' }
CCodeGenerator >> typeFor: aNode in: aTMethod [
	^aNode typeFrom: self in: aTMethod
]

{ #category : #'type inference' }
CCodeGenerator >> typeForArithmetic: sendNode in: aTMethod [
	"Answer the return type for an arithmetic sendThis is so that the inliner can still
	 inline simple expressions.  Deal with pointer arithmetic, floating point arithmetic
	 and promotion."
	| rcvrType argType arg |
	rcvrType := sendNode receiver typeOrNilFrom: self in: aTMethod.
	argType := (arg := sendNode args first) typeOrNilFrom: self in: aTMethod.
	"deal with pointer arithmetic"
	((rcvrType notNil and: [rcvrType last == $*]) or: [argType notNil and: [argType last == $*]]) ifTrue:
		[(rcvrType isNil or: [argType isNil]) ifTrue:
			[^nil].
		 (rcvrType last == $* and: [argType last == $*]) ifTrue:
			[sendNode selector == #- ifTrue:
				[^#int].
			 self error: 'invalid pointer arithmetic'].
		 ^rcvrType last == $*
			ifTrue: [rcvrType]
			ifFalse: [argType]].
	^(self promoteArithmeticTypes: rcvrType and: argType) ifNotNil:
		[:promotedType|
		 "We have to be very careful with subtraction.  The difference between two unsigned types is signed.
		  But we don't want unsigned - constant to be signed.  We almost always want this to stay unsigned."
		 (sendNode selector == #- and: [promotedType first == $u and: [(arg isConstant and: [arg value isInteger]) not]])
			ifTrue: [promotedType allButFirst: ((promotedType beginsWith: 'unsigned') ifTrue: [9] ifFalse: [1])]
			ifFalse: [promotedType]]
]

{ #category : #'type inference' }
CCodeGenerator >> typeForConditional: sendNode in: aTMethod [
	"Answer the return type for a conditional, ifTrue:ifFalse: et al"
	| firstType secondType |
	firstType := self typeFor: sendNode args first statements last in: aTMethod.
	sendNode selector numArgs = 1 ifTrue:
		[^firstType].
	secondType := self typeFor: sendNode args second statements last in: aTMethod.
	((firstType notNil and: [(self isIntegralCType: firstType) or: [self isFloatingPointCType: firstType]])
	 and: [secondType notNil and: [(self isIntegralCType: secondType) or: [self isFloatingPointCType: secondType]]]) ifTrue:
		[^self promoteArithmeticTypes: firstType and: secondType].
	^firstType ifNil: [secondType]
]

{ #category : #'type inference' }
CCodeGenerator >> typeForDereference: sendNode in: aTMethod [
	(self typeFor: sendNode receiver in: aTMethod) ifNotNil:
		[:type|
		 type last = $* ifTrue:
			[^type allButLast withBlanksTrimmed]].
	"It would be nice to warn here, but there are contexts when the type is unknown, for example determining
	 the return types of apiMethods.  inferTypesForImplicitlyTypedVariablesAndMethods could provide a signal
	 handler to suppress the warnings in that case but that's too fancy.  Instead we live with the default."
	"logger
		nextPutAll: 'warning, cannot determine type of at: for ', sendNode receiver asString, ' in ', aTMethod selector;
		cr."
	^#sqInt
]

{ #category : #'C code generator' }
CCodeGenerator >> typeOfVariable: varName [ "<String>"
	self assert: varName isString.
	scopeStack reverseDo:
		[:dict|
		(dict includesKey: varName) ifTrue:
			[^self
				extractTypeFor: varName
				fromDeclaration: (dict at: varName)]].
	(variableDeclarations
		at: varName
		ifAbsent:
			[apiVariables
				ifNotNil: [apiVariables at: varName ifAbsent: []]
				ifNil: []]) ifNotNil:
		[:decl| ^self extractTypeFor: varName fromDeclaration: decl].
	^(constants at: varName ifAbsent: []) ifNotNil:
		[:const|
		const value isInteger
			ifTrue: [self defaultType]
			ifFalse:
				[const value isFloat ifTrue:
					[#double]]]
]

{ #category : #utilities }
CCodeGenerator >> unreachableMethods [
	"Return a collection of methods that are never invoked."

	| neededSelectors previousSize visited |
	neededSelectors := Set new.
	"collect the exports"
	methods do:
		[:m|
		 m export ifTrue:
			[neededSelectors add: m selector]].

	"Now compute the transitive closure..."
	previousSize := neededSelectors size.
	visited := IdentitySet new: methods size.
	[neededSelectors do:
		[:s|
		(methods at: s ifAbsent: []) ifNotNil:
			[:m|
			(visited includes: m) ifFalse:
				[visited add: m.
				 neededSelectors
					add: m selector;
					addAll: m allCalls]]].
	 neededSelectors size > previousSize]
		whileTrue:
			[previousSize := neededSelectors size].

	^methods reject: [:m| neededSelectors includes: m selector]
]

{ #category : #'type inference' }
CCodeGenerator >> unsignedTypeForIntegralType: aCTypeString [
	^aCTypeString first = $u
		ifTrue: [aCTypeString]
		ifFalse:
			[(aCTypeString beginsWith: 'sq')
				ifTrue: ['u' , aCTypeString]
				ifFalse: ['unsigned ' , aCTypeString]]
]

{ #category : #'C code generator' }
CCodeGenerator >> unusedConstants [
	| unused |
	unused := self declaredConstants.
	methods do: [ :meth | 
		meth declarations keysDo: [ :v | 
			(meth typeFor: v in: self) ifNotNil: [ :type | 
				unused remove: type ifAbsent: [  ] ] ].
		unused remove: meth returnType ifAbsent: [  ].
		meth parseTree nodesDo: [ :n | 
			n isConstant ifTrue: [ unused remove: n name ifAbsent: [  ] ] ] ].
	unused copy do: [ :const | 
		(variableDeclarations anySatisfy: [ :value | 
			 value includesSubstring: const ]) ifTrue: [ 
			unused remove: const ifAbsent: [  ] ] ].
	^ unused
]

{ #category : #accessing }
CCodeGenerator >> useSymbolicConstants [
	"Answer whether we should generate symbolic constants instead of their actual values"
	^useSymbolicConstants
]

{ #category : #accessing }
CCodeGenerator >> useSymbolicConstants: aBool [
	"Indicate whether we should generate symbolic constants instead of their actual values"
	useSymbolicConstants := aBool
]

{ #category : #utilities }
CCodeGenerator >> validateCppIf: nodeOrNil withValue: value [
	
]

{ #category : #'C code generator' }
CCodeGenerator >> valueForContant: node ifAbsent: default [
	^ default
]

{ #category : #utilities }
CCodeGenerator >> valueOfConstantNode: aNode doing: aBlock [
	aNode constantNumbericValueOrNil 
		ifNotNil: [ :value | 
			aBlock value: value.
			^ true ].
	^ false
]

{ #category : #public }
CCodeGenerator >> var: varName declareC: declarationString [
	"Record the given C declaration for a global variable."

	(declarationString includesSubstring: varName) ifFalse:
		[self error: 'declaration omits variable name.  probably an error.  use e.g. var:type:'].
	variableDeclarations at: varName asString put: declarationString.
]

{ #category : #public }
CCodeGenerator >> var: varName type: type [
	"Use this in preference to #var:declareC: when ever possible since it avoids typing
	 the varname twice and thus avoids the potential for a typo. See also #var:type:array:"
	self var: varName declareC: type , ' ' , varName
]

{ #category : #public }
CCodeGenerator >> var: varName type: cType array: array [
	"Use this in preference to #var:declareC: when possible. This produces a C
	 statment of the form
		int * fooArray[]={1,2,3}
	 See also #var:type: for simple var decls" 
	self
		var: varName
		declareC: (self arrayInitializerCalled: varName for: array sizeString: nil type: cType)
]

{ #category : #public }
CCodeGenerator >> var: varName type: cType sizeString: sizeString array: array [
	"Use this in preference to #var:declareC: when possible. This produces a C
	 statment of the form
		int * fooArray[3 /* Foo */]={1,2,3}
	 See also #var:type: for simple var decls" 
	self
		var: varName
		declareC: (self arrayInitializerCalled: varName for: array sizeString: sizeString type: cType)
]

{ #category : #inlining }
CCodeGenerator >> variableOfType: variableType acceptsValue: exprNode ofType: expressionType [
	"Simple type checking for assignment/return values"

	^variableType isNil "means as yet untyped, hence can adapt"
	  or: [expressionType isNil "means we don't know.  Potentially dangerous to say yes, but Slang is traditionally lax :("
	  or: [variableType = expressionType
	  or: [variableType notNil
		 and: [(variableType includes: $*)
				ifTrue:
					[(exprNode isVariable and: [exprNode name = 'nil'])
					  or: [expressionType last = $*
						   and: [(self isVoidPointer: variableType)
								or: [self isVoidPointer: expressionType]]]]
				ifFalse: "Require a cast if assigning integral with floating-point but not the other way around"
					[((self isIntegralCType: variableType)
					   and: [(self isIntegralCType: expressionType)
					   and: [(self sizeOfIntegralCType: variableType) >= (self sizeOfIntegralCType: expressionType)]])
					or: [(self isFloatingPointCType: variableType)
						and: [(self isFloatingPointCType: expressionType)
							or: [self isIntegralCType: expressionType]]]]]]]]
]

{ #category : #public }
CCodeGenerator >> vmHeaderContentsWithBytesPerWord: bytesPerWord [
	"Store C header code on the given stream."

	^ ''
]

{ #category : #utilities }
CCodeGenerator >> with: aNode ifAppropriateSetTo: aBoolean do: aBlock [
	"If aNode is a TDefineNode for a variable, set it to the supplied boolean for the duration
	 of aBlock.  This avoids duplicating both arms of nested cppIf:ifTrue:[ifFalse:]'s."
	| savedOptions |
	(aNode isConstant and: [aNode name notEmpty and: [aNode name first isLetter]]) ifFalse:
		[^aBlock value].
	savedOptions := optionsDictionary.
	optionsDictionary := savedOptions
							ifNil: [Dictionary new]
							ifNotNil: [savedOptions copy].
	optionsDictionary at: aNode name put: aBoolean.
	^aBlock ensure: [optionsDictionary := savedOptions]
]

{ #category : #'C code generator' }
CCodeGenerator >> withCASTConditionalDefineOf: aConstantNameString comment: commentOrNil thenStatement: statement [

	| thenNode |
	thenNode := CLabeledStatementNode new.
	thenNode statement: statement.
	commentOrNil ifNotNil: [ thenNode comment: commentOrNil ].
	^ CPreprocessorIfNode
		if: (CUnaryOperatorNode
			operator: #!
			expression: (CCallNode
				identifier: (CIdentifierNode name: 'defined')
				arguments: { CConstantNode value: aConstantNameString }))
		then: (CCompoundStatementNode statements: { thenNode })
]

{ #category : #'C code generator' }
CCodeGenerator >> withConditionalDefineOf: aConstantNameString comment: commentOrNil on: aStream do: aBlock [
	aStream nextPutAll: '#if !defined('; nextPutAll: aConstantNameString; nextPut: $).
	commentOrNil ifNotNil: [aStream nextPutAll: ' /* '; nextPutAll: commentOrNil; nextPutAll: ' */'].
	aStream newLine.
	aBlock value.
	aStream nextPutAll: '#endif'.
	aStream nextPutAll: ' /* !defined('; nextPutAll: aConstantNameString; nextPutAll: ') */'.
	aStream newLine
]

{ #category : #'C code generator' }
CCodeGenerator >> withOptionalConditionalDefineFor: aTMethod on: aStream do: aBlock [
	"Evaluate aBlock, surrounded by an appropriate conditional define added to the stream if required."
	| compileTimeOptionPragmas |
	compileTimeOptionPragmas := aTMethod compileTimeOptionPragmas: self.
	
	compileTimeOptionPragmas notEmpty ifTrue:
		[aTMethod outputConditionalDefineFor: compileTimeOptionPragmas on: aStream].

	aBlock value.
	aTMethod terminateConditionalDefineFor: compileTimeOptionPragmas on: aStream
]

{ #category : #accessing }
CCodeGenerator >> wordSize [
	^ wordSize
]

{ #category : #accessing }
CCodeGenerator >> wordSize: aValue [

	wordSize := aValue
]
