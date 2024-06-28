Extension { #name : 'SlangBasicTranslationTest' }

{ #category : '*VMMaker' }
SlangBasicTranslationTest >> setUp [

	super setUp.
	generator := MLVMCCodeGenerator new.
	generator vmMaker: VMMaker new.
	generator vmMaker vmmakerConfiguration: VMMakerConfiguration.
	generator currentMethod: (TMethod new
		labels: Set new;
		definingClass: self class;
		selector: #setUp;
		yourself).
	generator pushScope: TStatementListNode new.
	
	"The translator accesses it directly using class variables..."
	SpurMemoryManager initBytesPerWord: 8.
	
	"Tell the generator this is the class we are generating.
	That will make the generation dispatch to us to ask for configurations such as the number of small integer bits"
	generator vmClass: self.
	numSmallIntegerTagBits := 42.
]

{ #category : '*VMMaker' }
SlangBasicTranslationTest >> testSendMemberAccess [

	| translation send |
	generator var: 'toto' declareC: 'VMCallbackContext toto'.
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TVariableNode new setName: 'toto')
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation equals: '(toto.stackp)'
]

{ #category : '*VMMaker' }
SlangBasicTranslationTest >> testSendMemberAccessFromPointer [

	| translation send |
	generator var: 'toto' declareC: 'VMCallbackContext *toto'.
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TVariableNode new setName: 'toto')
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation equals: '(toto->stackp)'
]

{ #category : '*VMMaker' }
SlangBasicTranslationTest >> testSendMemberAccessWithAdressOfVariableStructureReceiver [

	"Tests member access on an adress of a structure variable."

	| translation send |
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TSendNode new
				         setSelector: #addressOf:
				         receiver: (TVariableNode new setName: 'aVM')
				         arguments: { (TVariableNode new setName: 'x') })
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation equals: '((&x)->stackp)'
]

{ #category : '*VMMaker' }
SlangBasicTranslationTest >> testSendMemberAccessWithArgumentAssignment [

	"When there is an argument in the send node, it adds an assignement."
	| translation send |
	generator var: 'toto' declareC: 'VMCallbackContext toto'.
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TVariableNode new setName: 'toto')
		        arguments: { (TConstantNode value: 1) }.
	translation := self translate: send.

	self assert: translation equals: '(toto.stackp = 1)'
]

{ #category : '*VMMaker' }
SlangBasicTranslationTest >> testSendMemberAccessWithArrayAccessReceiver [

	"Tests member access on a structure contained in an array."

	| translation send |
	generator var: 'tab' declareC: 'VMCallbackContext tab[10]'.
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TSendNode new
				         setSelector: #at:
				         receiver: (TVariableNode new setName: 'tab')
				         arguments: { (TConstantNode value: 7) })
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation equals: '((tab[7]).stackp)'
]

{ #category : '*VMMaker' }
SlangBasicTranslationTest >> testSendMemberAccessWithArrayOfPointersToStructAccessReceiver [

	"Tests member access on an adress contained in an array of pointers to structures."

	| translation send |
	generator var: 'tab' declareC: 'VMCallbackContext *tab[10]'.
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TSendNode new
				         setSelector: #at:
				         receiver: (TVariableNode new setName: 'tab')
				         arguments: { (TConstantNode value: 7) })
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation equals: '((tab[7])->stackp)'
]

{ #category : '*VMMaker' }
SlangBasicTranslationTest >> testSendMemberAccessWithCCoercionReceiver [

	"Tests member access of a structure pointer cast."

	| translation send |
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TSendNode new
			                setSelector: #cCoerceSimple:to:
			                receiver: (TVariableNode new setName: 'self')
			                arguments: { 
					                (TVariableNode new setName: 'var').
					                (TConstantNode value: 'VMCallbackContext *') })
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation equals: '((((VMCallbackContext *) var ))->stackp)'
]

{ #category : '*VMMaker' }
SlangBasicTranslationTest >> testSendMemberAccessWithFunctionCallReceiver [

	"Tests member access on a call function that returns a structure"

	| translation send |
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	generator addMethod: (TMethod new
			 selector: 'foo';
			 returnType: 'VMCallbackContext';
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TSendNode new
				         setSelector: #foo
				         receiver: (TVariableNode named: 'self')
				         arguments: {  })
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation equals: '((foo()).stackp)'
]

{ #category : '*VMMaker' }
SlangBasicTranslationTest >> testSendMemberAccessWithFunctionCallReceiverWithPointerToStructReturn [

	"Tests member access on a call function that returns a pointer to a structure."

	| translation send |
	generator addMethod: (TMethod new
			 selector: 'stackp';
			 definingClass: VMCallbackContext;
			 yourself).
	generator addMethod: (TMethod new
			 selector: 'foo';
			 returnType: 'VMCallbackContext *';
			 yourself).
	send := TSendNode new
		        setSelector: #stackp
		        receiver: (TSendNode new
				         setSelector: #foo
				         receiver: (TVariableNode named: 'self')
				         arguments: {  })
		        arguments: {  }.
	translation := self translate: send.

	self assert: translation equals: '((foo())->stackp)'
]
