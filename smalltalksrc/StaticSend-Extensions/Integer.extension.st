Extension { #name : #Integer }

{ #category : #'*StaticSend-Extensions' }
Integer >> lateBoundRecursiveFactorial [

	<opalBytecodeMethod>
	^ IRBuilder buildIR: [ :builder |
		  builder
			  pushReceiver;
			  pushLiteral: 1;
			  send: #'<=';
			  jumpAheadTo: #gogogo if: false;

			  "Base case"
			  pushLiteral: 1;
			  returnTop;
			  
			  "Recursive case"
			  jumpAheadTarget: #gogogo;
			  pushReceiver;
			  pushReceiver;
			  pushLiteral: 1;
			  send: #-;
			  send: #lateBoundRecursiveFactorial;
			  send: #*;
			  returnTop ]
]

{ #category : #'*StaticSend-Extensions' }
Integer >> staticBoundRecursiveFactorial [

	<opalBytecodeMethod>
	1halt.
	^ IRBuilder buildIR: [ :builder |
		  builder
			  pushReceiver;
			  pushLiteral: 1;
			  send: #'<=';
			  jumpAheadTo: #gogogo if: false;

			  "Base case"
			  pushLiteral: 1;
			  returnTop;
			  
			  "Recursive case"
			  jumpAheadTarget: #gogogo;
			  pushReceiver;
			  pushReceiver;
			  pushLiteral: 1;
			  send: #-;
			  sendStatic: (StaticRecursiveMethodPlaceHolder new selector: #staticBoundRecursiveFactorial);
			  send: #*;
			  returnTop ]
]

{ #category : #'*StaticSend-Extensions' }
Integer >> staticBoundRecursiveFactorialHardcore [

	<opalBytecodeMethod>
	^ IRBuilder buildIR: [ :builder |
		  builder
			  pushReceiver;
			  pushLiteral: 1;
			  sendStatic: (SmallInteger >> #'<=');
			  jumpAheadTo: #gogogo if: false;

			  "Base case"
			  pushLiteral: 1;
			  returnTop;
			  
			  "Recursive case"
			  jumpAheadTarget: #gogogo;
			  pushReceiver;
			  pushReceiver;
			  pushLiteral: 1;
			  sendStatic: (SmallInteger >> #'-');
			  sendStatic: (StaticRecursiveMethodPlaceHolder new selector: #staticBoundRecursiveFactorial);
			  sendStatic: (SmallInteger >> #'*');
			  returnTop ]
]
