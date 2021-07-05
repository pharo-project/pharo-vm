Class {
	#name : #SLInterpreterThreadingTest,
	#superclass : #TestCase,
	#category : #'Slang-Tests'
}

{ #category : #helpers }
SLInterpreterThreadingTest >> gnuify: aString [

	| fileSystem |
	fileSystem := FileSystem memory.
	fileSystem / 'testInterpreter' writeStreamDo: [ :stream | 
		stream nextPutAll: aString ].

	(Gnuifier on: fileSystem root)
		interpreterFilename: 'testInterpreter';
		gnuify.
	^ (fileSystem / 'gcc3x-testInterpreter') contents
]

{ #category : #tests }
SLInterpreterThreadingTest >> testAddJumpTableVariableAtEndOfInterpreterVariables [

	| gnuified |
	gnuified := self gnuify: 'sqInt
interpret(void){
 localIP;

}'.
	
	self assert: (gnuified lineNumber: 7) equals: '    JUMP_TABLE;'
]

{ #category : #tests }
SLInterpreterThreadingTest >> testGnuisationGeneratesNewFile [

	| fileSystem |
	fileSystem := FileSystem memory.
	(fileSystem / 'testInterpreter') writeStreamDo: [ :stream | "Empty file" ].
	
	(Gnuifier on: fileSystem root)
		interpreterFilename: 'testInterpreter';
		gnuify.
	

	self assert: (fileSystem / 'gcc3x-testInterpreter') exists
]

{ #category : #tests }
SLInterpreterThreadingTest >> testReplaceBreakStatementByBREAKMacro [

	| gnuified |
	gnuified := self gnuify: 'sqInt 
interpret(void){
 localSP;

				break;
}'.
	
	self assert: (gnuified lineNumber: 14) equals: '				BREAK;'
]

{ #category : #tests }
SLInterpreterThreadingTest >> testReplaceCaseStatementByCASEMacroWithArgument [

	| gnuified |
	gnuified := self gnuify: 'sqInt 
interpret(void){
 localSP;

				case 1 :
}'.
	
	self assert: (gnuified lineNumber: 14) equals: '				CASE(1)'
]

{ #category : #tests }
SLInterpreterThreadingTest >> testReplaceCurrentBytecodeInterpreterVariablesByItsGnuDefinition [

	| gnuified |
	gnuified := self gnuify: 'sqInt
interpret(void){
 currentBytecode;
}'.
	
	self assert: (gnuified lineNumber: 6) equals: '	register sqInt currentBytecode CB_REG;'
]

{ #category : #tests }
SLInterpreterThreadingTest >> testReplaceFooInterpreterVariablesByItsGnuDefinition [

	| gnuified |
	gnuified := self gnuify: 'sqInt
interpret(void){
register struct foo * foo = &fum;
}'.
	
	self assert: (gnuified lineNumber: 6) equals: 'register struct foo * foo FOO_REG = &fum;'
]

{ #category : #tests }
SLInterpreterThreadingTest >> testReplaceGenericHeaderByGnuHeader [

	| gnuified |
	gnuified := self gnuify: '#include "sq.h"'.
	"At line 4, because gnuifier adds a comment."
	self assert: (gnuified lineNumber: 4) equals: '#include "sqGnu.h"'
]

{ #category : #tests }
SLInterpreterThreadingTest >> testReplaceLocalFPInterpreterVariablesByItsGnuDefinition [

	| gnuified |
	gnuified := self gnuify: 'sqInt
interpret(void){
 localFP;
}'.
	
	self assert: (gnuified lineNumber: 6) equals: '	register char* localFP FP_REG;'
]

{ #category : #tests }
SLInterpreterThreadingTest >> testReplaceLocalIPInterpreterVariablesByItsGnuDefinition [

	| gnuified |
	gnuified := self gnuify: 'sqInt
interpret(void){
 localIP;
}'.
	
	self assert: (gnuified lineNumber: 6) equals: '	register char* localIP IP_REG;'
]

{ #category : #tests }
SLInterpreterThreadingTest >> testReplaceLocalSPInterpreterVariablesByItsGnuDefinition [

	| gnuified |
	gnuified := self gnuify: 'sqInt 
interpret(void){
 localSP;
}'.
	
	self assert: (gnuified lineNumber: 6) equals: '	register char* localSP SP_REG;'
]
