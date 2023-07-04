Class {
	#name : #VMSessionIdTest,
	#superclass : #VMInterpreterTests,
	#category : #'VMMakerTests-InterpreterTests'
}

{ #category : #tests }
VMSessionIdTest >> testGlobalSessionID [
	"The globalSessionID is stored as a 64 bit number, but for compatibility with older plugins, is restricted to postive signed 32 bit values"
	| vm predicted diff |

	"The globalSessionID is the Unix time at startup + startMicroseconds.
	The simulator allows startMicroseconds to be set, so we can force the value to have the top bit set in a 32 bit signed integer"
	vm := StackInterpreterSimulator newBasicWithOptions: { 
		#ObjectMemory -> #Spur64BitMemoryManager.
		#startMicroseconds -> 16r80000000. } asDictionary.
	vm initializeGlobalSessionID.

	"Check that startMicroseconds is the expected value"
	self assert: vm ioUTCStartMicroseconds equals: 16r80000000.
	"Check that the globalSessionID is close to what we expect (allowing for a generous execution time"
	predicted := DateAndTime now asUnixTime + (vm ioUTCMicroseconds // 1000).
	diff := (predicted - vm getThisSessionID) abs.
	self assert: diff < 180.

	"Ensure that bit 32 isn't set"
	self assert: vm getThisSessionID < 16r80000000.
]
