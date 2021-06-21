Class {
	#name : #SlangTyper,
	#superclass : #Object,
	#instVars : [
		'codeGenerator',
		'stopOnErrors'
	],
	#category : #'Slang-TypeInference'
}

{ #category : #'instance creation' }
SlangTyper class >> on: aCCodeGenerator [ 
	
	^ self new
		codeGenerator: aCCodeGenerator;
		yourself
]

{ #category : #'type inference' }
SlangTyper >> addTypesFor: node inMethod: method to: typeSet [
	"Add the value types for the node to typeSet.
	 Answer if any type was derived from an as-yet-untyped method or variable, which allows us to abort
	 inferReturnTypeFromReturnsIn: if the return type depends on a yet-to-be-typed method or variable."
	| expr |
	expr := node.
	[expr isAssignment or: [expr isStmtList]] whileTrue:
		[expr isAssignment ifTrue:
			[expr := expr variable].
		 expr isStmtList ifTrue:
			[expr := expr statements last]].
	expr isSend ifTrue: [
		(#(ifTrue: ifFalse: ifTrue:ifFalse: ifFalse:ifTrue:) includes: expr selector) ifTrue: [
			^expr args
				inject: false
				into: [:asYetUntyped :block|
					asYetUntyped | (self addTypesFor: block inMethod: method to: typeSet) ] ].
		(codeGenerator returnTypeForSend: expr in: method ifNil: nil)
			ifNil: [^(codeGenerator methodNamed: expr selector) notNil and: [expr selector ~~ method selector]]
			ifNotNil:
				[:type |
				typeSet add: type.
				^false]].
	expr isVariable ifTrue:
		[(codeGenerator typeOfVariable: expr name)
			ifNotNil: [:type| typeSet add: type]
			ifNil: [(typeSet add: (expr name = 'self'
										ifTrue: [#void]
										ifFalse: [ expr typeFrom: codeGenerator in: method ])) == #sqInt ifTrue:
					[^true]]].
	expr isConstant ifTrue:
		[(expr value isInteger and: [expr value >= 0]) "cannot determine if signed or unsigned yet..."
			ifTrue: [typeSet add: expr value]
			ifFalse:
				[(expr typeOrNilFrom: codeGenerator in: method) ifNotNil:
					[:type | typeSet add: type]]].
	^false
]

{ #category : #accessing }
SlangTyper >> codeGenerator [
	^ codeGenerator
]

{ #category : #accessing }
SlangTyper >> codeGenerator: aCCodeGenerator [ 
	codeGenerator := aCCodeGenerator
]

{ #category : #'type inference' }
SlangTyper >> inferReturnTypeFromReturnsOf: aMethod [
	"Attempt to infer the return type of the receiver from returns in the parse tree."

	"this for determining which returns have which return types:"
	"aCodeGen
		pushScope: declarations
		while: [parseTree
				nodesSelect: [:n| n isReturn]
				thenCollect: [:n| | s |
					s := Set new.
					self addTypesFor: n expression to: s in: aCodeGen.
					{n. s}]]"

	codeGenerator maybeBreakForTestToInline: aMethod selector in: aMethod.
	aMethod returnType ifNotNil: [ ^ self ].
	codeGenerator
		pushScope: aMethod declarations
		while:
			[| hasReturn returnTypes |
			 hasReturn := false.
			 returnTypes := Set new.
			 "Debug:
			 (| rettypes |
			  rettypes := Dictionary new.
			  parseTree nodesDo:
				[:node|
				node isReturn ifTrue:
					[| types |
					 self addTypesFor: node expression to: (types := Set new) in: aCodeGen.
					 rettypes at: node expression put: types]].
			  rettypes)"
			 aMethod parseTree nodesDo:
				[:node|
				node isReturn ifTrue:
					[hasReturn := true.
					 "If we encounter a send of an as-yet-untyped method then abort,
					  retrying and computing the type when that method is fully typed."
					(self addTypesFor: node expression inMethod: aMethod to: returnTypes) ifTrue:
						[^self]]].
			returnTypes remove: #implicit ifAbsent: [].
			returnTypes := codeGenerator harmonizeReturnTypesIn: returnTypes.
			hasReturn
				ifTrue:
					[returnTypes size > 1 ifTrue:
						[| message |
						 message := String streamContents:
										[:s|
										 s nextPutAll: 'conflicting return types '.
										 returnTypes
											do: [:t| s nextPutAll: t]
											separatedBy: [s nextPutAll: ', '].
										 s nextPutAll: ' in '; nextPutAll: aMethod selector; cr].
						 Notification signal: message.
						 codeGenerator logger newLine; show: message].
					 returnTypes size = 1 ifTrue:
						[aMethod returnType: returnTypes anyOne]]
				ifFalse:
					[aMethod returnType: (codeGenerator implicitReturnTypeFor: aMethod selector)]]
]

{ #category : #'type inference' }
SlangTyper >> inferReturnTypeOf: aMethod [
	"Attempt to infer the return type of the receiver and answer if it changed."

	| existingReturnType |
	existingReturnType := aMethod returnType.
	self inferReturnTypeFromReturnsOf: aMethod.
	^existingReturnType ~= aMethod returnType
]

{ #category : #'type inference' }
SlangTyper >> inferTypes [
	| typeConflicts |
	typeConflicts := OrderedCollection new.
	[ self inferTypesForImplicitlyTypedVariablesAndMethods ]
		on: Notification
		do: [ :n | 
			typeConflicts add: n copy freeze.
			n resume ].
	(stopOnErrors and: [ typeConflicts isNotEmpty ]) ifTrue: [ Error signal: 'there were type errors' ]
]

{ #category : #'type inference' }
SlangTyper >> inferTypesForImplicitlyTypedVariablesAndMethods [
	"Infer the return tupe and the types of untyped variables.
	 As far as variables go, for now we try only to infer variables
	 assigned the result of #longLongAt:, but much more could be
	 done here."

	"Iterate over all methods, inferring #void return types, until we reach a fixed point."
	| allMethods |
	allMethods := codeGenerator apiMethods
					ifNil: [codeGenerator methods]
					ifNotNil: [(Set withAll: codeGenerator methods)
								addAll: codeGenerator apiMethods;
								yourself].
	"Make an initial pass to assign the return types of all simple methods that return constants,
	 or those that have explicit return types."						
	allMethods do:
		[:m|
		m removeFinalSelfReturnIn: codeGenerator. "must precede recordDeclarationsIn: because it may set returnType"
		m recordDeclarationsIn: codeGenerator.
		(m returnType isNil
		 and: [m isReturnConstant]) ifTrue:
			[self inferReturnTypeOf: m]].

	"now iterate until we reach a fixed point"
	[| changedReturnType |
	 changedReturnType := false.
	 allMethods do:
		[:m|
		self inferTypesForImplicitlyTypedVariablesIn: m.
		 (self inferReturnTypeOf: m) ifTrue:
			[changedReturnType := true]].
	 changedReturnType] whileTrue.

	"Type all as-yet-untyped methods as the default"
	codeGenerator methods do:
		[:m|
		m returnType ifNil:
			[m returnType: (m returnsExpression
								ifTrue: [codeGenerator defaultType]
								ifFalse: [codeGenerator implicitReturnTypeFor: m])].
		m transformReturns].

	"Make a final pass to type anything assigned from the default type"
	allMethods do: [ :m |
		self inferTypesForImplicitlyTypedVariablesIn: m ]
]

{ #category : #'type inference' }
SlangTyper >> inferTypesForImplicitlyTypedVariablesIn: aMethod [

	" Infer types for untyped variables from assignments and arithmetic uses "

	| alreadyExplicitlyTypedOrNotToBeTyped asYetUntyped mustBeSigned newDeclarations |
	codeGenerator maybeBreakForTestToInline: aMethod selector in: aMethod.

	alreadyExplicitlyTypedOrNotToBeTyped := aMethod declarations keys
		                                        asSet.
	asYetUntyped := aMethod locals copyWithoutAll:
		                alreadyExplicitlyTypedOrNotToBeTyped.
	mustBeSigned := Set new.
	newDeclarations := Dictionary new.

	aMethod parseTree nodesDo: [ :node | 
		| type var |
		"If there is something of the form i >= 0, then i should be signed, not unsigned."
		(node isSend and: [ 
			 (aMethod locals includes: (var := node receiver variableNameOrNil)) 
				 and: [ 
					 (#( <= < >= > ) includes: node selector) and: [ 
						 node args first isConstant and: [ node args first value = 0 ] ] ] ]) 
			ifTrue: [ mustBeSigned add: var ].

		"if an assignment to an untyped local of a known type, set the local's type to that type.
		 Only observe known sends (methods in the current set) and typed local variables."
		(node isAssignment and: [ 
			 (aMethod locals includes: (var := node variable name)) and: [ 
				 (alreadyExplicitlyTypedOrNotToBeTyped includes: var) not ] ]) 
			ifTrue: [ "don't be fooled by previously inferred types"
				type := self tryExtractTypeFromAssignmentNode: node inMethod: aMethod.
				type
					ifNil: [ "Further, if the type derives from an as-yet-untyped method, we must defer."
						alreadyExplicitlyTypedOrNotToBeTyped add: var.
						(node expression isSend and: [ 
							 (codeGenerator methodNamed: node expression selector) notNil ]) 
							ifTrue: [ newDeclarations removeKey: var ifAbsent: nil ] ]
					ifNotNil: [ "Merge simple types (but *don't* merge untyped vars); complex types must be defined by the programmer."
						(codeGenerator isSimpleType: type) ifTrue: [ 
							(asYetUntyped includes: var)
								ifTrue: [ 
									newDeclarations at: var put: type , ' ' , var.
									asYetUntyped remove: var ]
								ifFalse: [ 
									self
										mergeTypeOf: var
										in: newDeclarations
										with: type
										method: aMethod ] ] ] "If untyped, then cannot type the variable yet. A subsequent assignment may assign a subtype of what this type ends up being" ] ].


	mustBeSigned do: [ :var | 
		(newDeclarations at: var ifAbsent: nil) ifNotNil: [ :decl | 
			| type |
			type := codeGenerator extractTypeFor: var fromDeclaration: decl.
			type first == $u ifTrue: [ 
				newDeclarations
					at: var
					put: (self signedTypeForIntegralType: type) , ' ' , var ] ] ].
	newDeclarations keysAndValuesDo: [ :var :decl | 
		aMethod declarations at: var put: decl ]
]

{ #category : #'type inference' }
SlangTyper >> mergeTypeOf: var in: aDictionary with: newType method: tMethod [
	"var is a variable that has been assigned an expression of type  newType.
	 Either assign its type, if it is as yet untyped, or merge newType with its existing type.
	 N.B. We refuse to promote a variable that already has integral type to a floating point
	 type.  The existing plugins depend on this; one can always use an explicit type in future."
	| existingType mergedType |
	existingType := codeGenerator
						extractTypeFor: var
						fromDeclaration: (aDictionary at: var ifAbsentPut: [newType, ' ', var]).
	existingType ~= newType ifTrue:
		[((codeGenerator isPointerCType: existingType)
		  or: [codeGenerator isPointerCType: newType])
			ifTrue:
				[existingType = #'void *' ifTrue: [^newType].
				 newType = #'void *' ifTrue: [^existingType].
				 codeGenerator logger show: 'conflicting types ', existingType, ' ', newType, ' for ', var, ' in ', tMethod selector.
				 ^existingType]
			ifFalse:
				[((codeGenerator isIntegralCType: existingType)
				  and: [codeGenerator isFloatingPointCType: newType]) ifFalse:
					[mergedType := codeGenerator promoteArithmeticTypes: existingType and: newType.
					 aDictionary at: var put: mergedType, ' ', var]]]
]

{ #category : #'type inference' }
SlangTyper >> signedTypeForIntegralType: aCTypeString [
	(aCTypeString beginsWith: 'unsigned ') ifTrue:
		[^aCTypeString allButFirst: 8].
	
	(aCTypeString beginsWith: 'usq') ifTrue:
		[^aCTypeString allButFirst].

	aCTypeString = 'size_t' ifTrue: [^#usqIntptr_t].
	
	self error: 'unknown type'.
	^#long
]

{ #category : #accessing }
SlangTyper >> stopOnErrors [
	^ stopOnErrors
]

{ #category : #accessing }
SlangTyper >> stopOnErrors: anObject [
	stopOnErrors := anObject
]

{ #category : #'type inference' }
SlangTyper >> tryExtractTypeFromAssignmentNode: node inMethod: aMethod [

	^ node expression isSend
		  ifTrue: [ 
			  codeGenerator
				  returnTypeForSend: node expression
				  in: aMethod
				  ifNil: nil ]
		  ifFalse: [ 
			  (node expression isAssignment
				   ifTrue: [ node expression variable ]
				   ifFalse: [ node expression ])
				  typeFrom: codeGenerator
				  in: aMethod ]
]
