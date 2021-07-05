Class {
	#name : #VMSpecialSendArithmethicTest,
	#superclass : #VMStackToRegisterMappingCogitTest,
	#category : #'VMMakerTests-JitTests'
}

{ #category : #'building suites' }
VMSpecialSendArithmethicTest class >> testParameters [ 

	^ super testParameters * { 
		{ #sentSelector -> #+. #sendBytecode -> 176. #value1 -> 42. #value2 -> 54. #expectedResult -> 96. #expectedReflexiveResult -> 84 }.
		{ #sentSelector -> #-.  #sendBytecode -> 177. #value1 -> 42. #value2 -> 54. #expectedResult -> -12. #expectedReflexiveResult -> 0 }.		
	 }
]

{ #category : #running }
VMSpecialSendArithmethicTest >> assertSpecialSendTo: receiverOop withArg: argOop [ 

	self assert: machineSimulator instructionPointerValue equals: sendTrampolineAddress.
	self assert: machineSimulator receiverRegisterValue equals: receiverOop.
	self assert: machineSimulator arg0RegisterValue equals: argOop.
]

{ #category : #'tests - receiver non integer argument' }
VMSpecialSendArithmethicTest >> testNonIntegerArgumentPlusFalseArgumentCallsTrampoline [
		
	self
		arguments: { memory trueObject. memory falseObject};
		receiverOperation: [ cogit genPushTemporaryVariable: 0 ];
		argumentOperation: [ cogit genPushTemporaryVariable: 1 ];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ memory falseObject ]
]

{ #category : #'tests - receiver non integer argument' }
VMSpecialSendArithmethicTest >> testNonIntegerArgumentPlusFalseSelfCallsTrampoline [
		
	self
		methodReceiver: (memory falseObject);
		arguments: { memory trueObject };
		receiverOperation: [ cogit genPushTemporaryVariable: 0 ];
		argumentOperation: [ cogit ssPushDesc: cogit simSelf ];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ memory falseObject ]
]

{ #category : #'tests - receiver non integer argument' }
VMSpecialSendArithmethicTest >> testNonIntegerArgumentPlusSmallIntegerArgumentCallsTrampoline [
		
	self
		arguments: { memory trueObject. memory integerObjectOf: value1 };
		receiverOperation: [ cogit genPushTemporaryVariable: 0 ];
		argumentOperation: [ cogit genPushTemporaryVariable: 1 ];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ memory integerObjectOf: value1 ]
]

{ #category : #'tests - receiver non integer argument' }
VMSpecialSendArithmethicTest >> testNonIntegerArgumentPlusSmallIntegerConstCallsTrampoline [
		
	self
		arguments: { memory trueObject };
		receiverOperation: [ cogit genPushTemporaryVariable: 0 ];
		argumentOperation: [ cogit ssPushConstant: (memory integerObjectOf: value1)];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ memory integerObjectOf: value1 ]
]

{ #category : #'tests - receiver non integer argument' }
VMSpecialSendArithmethicTest >> testNonIntegerArgumentPlusSmallIntegerSelfCallsTrampoline [
		
	self
		methodReceiver: (memory integerObjectOf: value1);
		arguments: { memory trueObject };
		receiverOperation: [ cogit genPushTemporaryVariable: 0 ];
		argumentOperation: [ cogit ssPushDesc: cogit simSelf ];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ (memory integerObjectOf: value1) ]
]

{ #category : #'tests - receiver non integer argument' }
VMSpecialSendArithmethicTest >> testNonIntegerArgumentPlusTrueConstCallsTrampoline [
		
	self
		arguments: { memory trueObject };
		receiverOperation: [ cogit genPushTemporaryVariable: 0 ];
		argumentOperation: [ cogit ssPushConstant: (memory falseObject)];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ memory falseObject ]
]

{ #category : #'tests - receiver integer argument' }
VMSpecialSendArithmethicTest >> testSmallIntegerArgumentPlusIntegerSelfReturnsSmallInteger [
	
	self
		methodReceiver: (memory integerObjectOf: value2);
		arguments: { memory integerObjectOf: value1 };
		receiverOperation: [ cogit genPushTemporaryVariable: 0 ];
		argumentOperation: [ cogit ssPushDesc: cogit simSelf ];
		shouldPerformOperationReturning: expectedResult
]

{ #category : #'tests - receiver integer argument' }
VMSpecialSendArithmethicTest >> testSmallIntegerArgumentPlusSmallIntegerArgumentCallsTrampoline [
	
	self
		arguments: { memory integerObjectOf: value1. memory integerObjectOf: value2. };
		receiverOperation: [ cogit genPushTemporaryVariable: 0 ];
		argumentOperation: [ cogit genPushTemporaryVariable: 1 ];
		shouldCallTrampolineWith: (memory integerObjectOf: value1) and: (memory integerObjectOf: value2)
]

{ #category : #'tests - receiver integer argument' }
VMSpecialSendArithmethicTest >> testSmallIntegerArgumentPlusSmallIntegerConstReturnsSmallInteger [
	
	self
		arguments: { memory integerObjectOf: value1 };
		receiverOperation: [ cogit genPushTemporaryVariable: 0 ];
		argumentOperation: [ cogit ssPushConstant: (memory integerObjectOf: value2) ];
		shouldPerformOperationReturning: expectedResult.
]

{ #category : #'tests - receiver integer argument' }
VMSpecialSendArithmethicTest >> testSmallIntegerArgumentPlusTrueArgumentCallsTrampoline [
	
	self
		arguments: { memory integerObjectOf: value2. memory trueObject };
		receiverOperation: [ cogit genPushTemporaryVariable: 0 ];
		argumentOperation: [ cogit genPushTemporaryVariable: 1 ];
		shouldCallTrampolineWith: (memory integerObjectOf: value2) and: memory trueObject
]

{ #category : #'tests - receiver integer argument' }
VMSpecialSendArithmethicTest >> testSmallIntegerArgumentPlusTrueConstCallsTrampoline [
	
	self
		arguments: { memory integerObjectOf: value1 };
		receiverOperation: [ cogit genPushTemporaryVariable: 0 ];
		argumentOperation: [ cogit ssPushConstant: (memory trueObject) ];
		shouldCallTrampolineWith: (memory integerObjectOf: value1) and: memory trueObject
]

{ #category : #'tests - receiver integer argument' }
VMSpecialSendArithmethicTest >> testSmallIntegerArgumentPlusTrueSelfCallsTrampoline [
	
	self
		methodReceiver: memory trueObject;
		arguments: { memory integerObjectOf: value1 };
		receiverOperation: [ cogit genPushTemporaryVariable: 0 ];
		argumentOperation: [ cogit ssPushDesc: cogit simSelf ];
		shouldCallTrampolineWith: (memory integerObjectOf: value1) and: memory trueObject
]

{ #category : #'tests - receiver constant integer' }
VMSpecialSendArithmethicTest >> testSmallIntegerConstPlusSmallIntegerArgumentReturnsSmallInteger [
	
	self
		arguments: { memory integerObjectOf: value2 };
		receiverOperation: [ cogit ssPushConstant: (memory integerObjectOf: value1) ];
		argumentOperation: [ cogit genPushTemporaryVariable: 0 ];
		shouldPerformOperationReturning: expectedResult.	

]

{ #category : #'tests - receiver constant integer' }
VMSpecialSendArithmethicTest >> testSmallIntegerConstPlusSmallIntegerConstReturnsSmallInteger [
	
	self
		receiverOperation: [ cogit ssPushConstant: (memory integerObjectOf: value1) ];
		argumentOperation: [ cogit ssPushConstant: (memory integerObjectOf: value2) ];
		shouldPerformOperationReturning: expectedResult.	

]

{ #category : #'tests - receiver constant integer' }
VMSpecialSendArithmethicTest >> testSmallIntegerConstPlusSmallIntegerSelfReturnsSmallInteger [
	
	self
		methodReceiver: (memory integerObjectOf: value2);
		receiverOperation: [ cogit ssPushConstant: (memory integerObjectOf: value1) ];
		argumentOperation: [ cogit ssPushDesc: cogit simSelf ];
		shouldPerformOperationReturning: expectedResult.	
	
]

{ #category : #'tests - receiver constant integer' }
VMSpecialSendArithmethicTest >> testSmallIntegerConstPlusTrueArgumentCallsTrampoline [
	
	
	self
		arguments: { memory trueObject };
		receiverOperation: [ cogit ssPushConstant: (memory integerObjectOf: value1) ];
		argumentOperation: [ cogit genPushTemporaryVariable: 0 ];
		shouldCallTrampolineWith: [ memory integerObjectOf: value1 ] and: [ memory trueObject ].	
]

{ #category : #'tests - receiver constant integer' }
VMSpecialSendArithmethicTest >> testSmallIntegerConstPlusTrueConstCallsTrampoline [
	
	self
		receiverOperation: [ cogit ssPushConstant: (memory integerObjectOf: value1) ];
		argumentOperation: [ cogit ssPushConstant: memory trueObject ];
		shouldCallTrampolineWith: [ memory integerObjectOf: value1 ] and: [ memory trueObject ].	

]

{ #category : #'tests - receiver constant integer' }
VMSpecialSendArithmethicTest >> testSmallIntegerConstPlusTrueSelfCallsTrampoline [


	self
		methodReceiver: memory trueObject;
		receiverOperation: [ cogit ssPushConstant: (memory integerObjectOf: value1) ];
		argumentOperation: [ cogit ssPushDesc: cogit ssSelfDescriptor ];
		shouldCallTrampolineWith: [ memory integerObjectOf: value1 ] and: [ memory trueObject ].	
]

{ #category : #'tests - receiver integer self' }
VMSpecialSendArithmethicTest >> testSmallIntegerSelfPlusSmallIntegerArgumentReturnsSmallInteger [
		
	self
		methodReceiver: (memory integerObjectOf: value1);
		arguments: { (memory integerObjectOf: value2) };
		receiverOperation: [ cogit ssPushDesc: cogit ssSelfDescriptor ];
		argumentOperation: [ cogit genPushTemporaryVariable: 0 ];
		shouldPerformOperationReturning: expectedResult
]

{ #category : #'tests - receiver integer self' }
VMSpecialSendArithmethicTest >> testSmallIntegerSelfPlusSmallIntegerConstReturnsSmallInteger [
	
	self
		methodReceiver: (memory integerObjectOf: value1);
		receiverOperation: [ cogit ssPushDesc: cogit simSelf ];
		argumentOperation: [ cogit ssPushConstant: (memory integerObjectOf: value2) ];
		shouldPerformOperationReturning: expectedResult.	

]

{ #category : #'tests - receiver integer self' }
VMSpecialSendArithmethicTest >> testSmallIntegerSelfPlusSmallIntegerSelfReturnsSmallInteger [
		
	self
		methodReceiver: (memory integerObjectOf: value1);
		receiverOperation: [ cogit ssPushDesc: cogit ssSelfDescriptor ];
		argumentOperation: [ cogit ssPushDesc: cogit ssSelfDescriptor ];
		shouldPerformOperationReturning: expectedReflexiveResult
]

{ #category : #'tests - receiver integer self' }
VMSpecialSendArithmethicTest >> testSmallIntegerSelfPlusTrueArgumentCallsTrampoline [
		
	self
		methodReceiver: (memory integerObjectOf: value1);
		arguments: { memory trueObject };
		receiverOperation: [ cogit ssPushDesc: cogit ssSelfDescriptor ];
		argumentOperation: [ cogit genPushTemporaryVariable: 0];
		shouldCallTrampolineWith: [ memory integerObjectOf: value1 ] and: [ memory trueObject ]
]

{ #category : #'tests - receiver integer self' }
VMSpecialSendArithmethicTest >> testSmallIntegerSelfPlusTrueConstCallsTrampoline [
		
	self
		methodReceiver: (memory integerObjectOf: value1);
		receiverOperation: [ cogit ssPushDesc: cogit ssSelfDescriptor ];
		argumentOperation: [ cogit ssPushConstant: (memory trueObject)];
		shouldCallTrampolineWith: [ memory integerObjectOf: value1 ] and: [ memory trueObject ]
]

{ #category : #'tests - receiver constant not integer' }
VMSpecialSendArithmethicTest >> testTrueConstPlusFalseArgumentCallsTrampoline [
	
	self
		arguments: {memory falseObject};
		receiverOperation: [ cogit ssPushConstant: (memory trueObject) ];
		argumentOperation: [ cogit genPushTemporaryVariable: 0 ];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ memory falseObject ]
]

{ #category : #'tests - receiver constant not integer' }
VMSpecialSendArithmethicTest >> testTrueConstPlusFalseConstCallsTrampoline [
	
	self
		receiverOperation: [ cogit ssPushConstant: (memory trueObject) ];
		argumentOperation: [ cogit ssPushConstant: (memory falseObject)];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ memory falseObject ]
]

{ #category : #'tests - receiver constant not integer' }
VMSpecialSendArithmethicTest >> testTrueConstPlusFalseSelfCallsTrampoline [
	
	self
		methodReceiver: (memory falseObject);
		receiverOperation: [ cogit ssPushConstant: (memory trueObject) ];
		argumentOperation: [ cogit ssPushDesc: cogit ssSelfDescriptor ];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ memory falseObject ]
]

{ #category : #'tests - receiver constant not integer' }
VMSpecialSendArithmethicTest >> testTrueConstPlusSmallIntegerArgumentCallsTrampoline [
	
	self
		arguments: {memory integerObjectOf: value1};
		receiverOperation: [ cogit ssPushConstant: (memory trueObject) ];
		argumentOperation: [ cogit genPushTemporaryVariable: 0 ];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ memory integerObjectOf: value1 ]
]

{ #category : #'tests - receiver constant not integer' }
VMSpecialSendArithmethicTest >> testTrueConstPlusSmallIntegerConstCallsTrampoline [
	
	self
		receiverOperation: [ cogit ssPushConstant: (memory trueObject) ];
		argumentOperation: [ cogit ssPushConstant: (memory integerObjectOf: value1) ];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ memory integerObjectOf: value1 ].		
]

{ #category : #'tests - receiver constant not integer' }
VMSpecialSendArithmethicTest >> testTrueConstPlusSmallIntegerSelfCallsTrampoline [
	
	self
		methodReceiver: (memory integerObjectOf: value1);
		receiverOperation: [ cogit ssPushConstant: (memory trueObject) ];
		argumentOperation: [ cogit ssPushDesc: cogit ssSelfDescriptor ];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ (memory integerObjectOf: value1) ]
]

{ #category : #'tests - receiver non integer self' }
VMSpecialSendArithmethicTest >> testTrueSelfPlusFalseArgumentCallsTrampoline [
			
	self
		methodReceiver: memory trueObject;
		arguments: { memory falseObject };
		receiverOperation: [ cogit ssPushDesc: cogit ssSelfDescriptor ];
		argumentOperation: [ cogit genPushTemporaryVariable: 0 ];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ memory falseObject ].		
]

{ #category : #'tests - receiver non integer self' }
VMSpecialSendArithmethicTest >> testTrueSelfPlusFalseConstCallsTrampoline [
			
	self
		methodReceiver: memory trueObject;
		receiverOperation: [ cogit ssPushDesc: cogit ssSelfDescriptor ];
		argumentOperation: [ cogit ssPushConstant: (memory falseObject) ];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ memory falseObject ].		
]

{ #category : #'tests - receiver non integer self' }
VMSpecialSendArithmethicTest >> testTrueSelfPlusSmallIntegerArgumentCallsTrampoline [
			
	self
		methodReceiver: memory trueObject;
		arguments: { memory integerObjectOf: value1 };
		receiverOperation: [ cogit ssPushDesc: cogit ssSelfDescriptor ];
		argumentOperation: [ cogit genPushTemporaryVariable: 0 ];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ memory integerObjectOf: value1 ].		
]

{ #category : #'tests - receiver non integer self' }
VMSpecialSendArithmethicTest >> testTrueSelfPlusSmallIntegerConstCallsTrampoline [
			
	self
		methodReceiver: memory trueObject;
		receiverOperation: [ cogit ssPushDesc: cogit ssSelfDescriptor ];
		argumentOperation: [ cogit ssPushConstant: (memory integerObjectOf: value1) ];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ memory integerObjectOf: value1 ].		
]

{ #category : #'tests - receiver non integer self' }
VMSpecialSendArithmethicTest >> testTrueSelfPlusTrueSelfCallsTrampoline [
			
	self
		methodReceiver: memory trueObject;
		receiverOperation: [ cogit ssPushDesc: cogit ssSelfDescriptor ];
		argumentOperation: [ cogit ssPushDesc: cogit ssSelfDescriptor ];
		shouldCallTrampolineWith: [ memory trueObject ] and: [ memory trueObject ].		
]
