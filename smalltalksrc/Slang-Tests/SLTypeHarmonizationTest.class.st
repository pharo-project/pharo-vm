Class {
	#name : #SLTypeHarmonizationTest,
	#superclass : #SlangAbstractTestCase,
	#instVars : [
		'types'
	],
	#category : #'Slang-Tests'
}

{ #category : #running }
SLTypeHarmonizationTest >> setUp [
	super setUp.
	types := Set new.
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedChar [
	"cast a char to an int"
	| result |
	types add: #char.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedCharAndInt [
	| result |
	types add: #int.
	types add: #char.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedCharAndUnknown [
	| result |
	types add: #unknown.
	types add: #char.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; add: #unknown ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedCharPtr [
	"doesn't change the type"
	| result |
	types add: #'char *'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'char *' ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedEmptyRetrunType [
	"unknowned type doesn't get any transformation"
	| result |
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedInt [
	| result |
	types add: #int.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedIntAndLongNotWorking [
	"the type are not merged"
	| result |
	types add: #int.
	types add: #long.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; add: #long ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedIntAndLonglongNotWorking [
	"the type are not merged"
	| result |
	types add: #int.
	types add: #'long long'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; add: #sqLong ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedIntAndShort [
	| result |
	types add: #int.
	types add: #short.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedIntAndUnsignedIntAndLonglongNotAndUnsignedlonglongWorking [
	"default to signed type"
	| result |
	types add: #int.
	types add: #'unsigned int'.
	types add: #'long long'.
	types add: #'unsigned long long'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; add: #sqLong ; yourself ).
	
	
]

{ #category : #harmonizeThreeType }
SLTypeHarmonizationTest >> testHarmonizedIntAndUnsignedIntAndLonglongNotWorking [
	"default to signed type"
	| result |
	types add: #int.
	types add: #'unsigned int'.
	types add: #'long long'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; add: #sqLong ; add: #usqInt ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedIntAndUnsignedIntNotWorking [
	"default to signed type"
	| result |
	types add: #int.
	types add: #'unsigned int'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedIntPtr [
	"doesn't change the type"
	| result |
	types add: #'int *'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'int *' ; yourself ).
	
	
]

{ #category : #harmonizeThreeType }
SLTypeHarmonizationTest >> testHarmonizedKnownTypeAndNotKnownAndUnsignedIntNotWorking [
	"if at least one of the type isn't in #(char short int #'long long' #'unsigned char' #'unsigned short' #'unsigned int' #'unsigned long long') then it will remain unmerged"
	| result |
	types add: #int.
	types add: #'unsigned int'.
	types add: #unknown.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; add: #unknown ; add: #usqInt ; yourself ).
	
	
]

{ #category : #harmonizeThreeType }
SLTypeHarmonizationTest >> testHarmonizedKnownTypeAndNotKnownNotWorking [
	"if at least one of the type isn't in #(char short int #'long long' #'unsigned char' #'unsigned short' #'unsigned int' #'unsigned long long') then it will remain unmerged"
	| result |
	types add: #int.
	types add: #short.
	types add: #unknown.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; add: #unknown ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedLong [
	"long type doesn't get any transformation, it counts as unknown"
	| result |
	types add: #long.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #long ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedLongAndUnsignedLongNotWorking [
	"doesn't merge the type"
	| result |
	types add: #long.
	types add: #'unsigned long'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #long ; add: #'unsigned long' ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedLongPtr [
	"doesn't change the type"
	| result |
	types add: #'long *'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'long *' ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedLonglong [
	| result |
	types add: #'long long'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqLong ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedLonglongPtr [
	"doesn't change the type"
	| result |
	types add: #'long long*'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'long long*' ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedNumber [
	| result |
	types add: 7.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedNumberAndAnything [
	"doesn't harmonize and produce a notification"
	| result |
	types add: 7.
	types add: #anything.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #anything ; add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeTwoType }
SLTypeHarmonizationTest >> testHarmonizedNumbers [
	| result |
	types add: 7.
	types add: 8.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedShort [
	"cast short to int"
	| result |
	types add: #short.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedShortPtr [
	"doesn't change the type"
	| result |
	types add: #'short *'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'short *' ; yourself ).
	
	
]

{ #category : #harmonizeSignedAndUnsigned }
SLTypeHarmonizationTest >> testHarmonizedSignedUnsignedIntNotWorking [
	| result |
	types add: #int.
	types add: #'unsigned int'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeSignedAndUnsigned }
SLTypeHarmonizationTest >> testHarmonizedSignedUnsignedNotWorking [
	"ignore the unsigned long long in the merge operation"
	| result |
	types add: #int.
	types add: #'unsigned int'.
	types add: #'unsigned long long'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #sqInt ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedUnknown [
	"unknowned type doesn't get any transformation"
	| result |
	types add: #unknown.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #unknown ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedUnknownPtr [
	"doesn't change the type"
	| result |
	types add: #'unknown *'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'unknown *' ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedUnsignedIntPtr [
	"doesn't change the type"
	| result |
	types add: #'unsigned int *'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'unsigned int *' ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedUnsignedchar [
	"cast an unsigned char to an usqInt"
	| result |
	types add: #'unsigned char'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'usqInt' ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedUnsignedcharPtr [
	"doesn't change the type"
	| result |
	types add: #'unsigned char *'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'unsigned char *' ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedUnsignedint [
	| result |
	types add: #'unsigned int'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #usqInt ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedUnsignedlong [
	"unsigned long type doesn't get any transformation, it counts as unknown"
	| result |
	types add: #'unsigned long'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'unsigned long' ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedUnsignedlongPtr [
	"doesn't change the type"
	| result |
	types add: #'unsigned long *'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'unsigned long *' ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedUnsignedlonglong [
	| result |
	types add: #'unsigned long long'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'usqLong' ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedUnsignedlonglongPtr [
	"doesn't change the type"
	| result |
	types add: #'unsigned long long*'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'unsigned long long*' ; yourself ).
	
	
]

{ #category : #harmonizeOneType }
SLTypeHarmonizationTest >> testHarmonizedUnsignedshort [
	| result |
	types add: #'unsigned short'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #usqInt ; yourself ).
	
	
]

{ #category : #harmonizeOnePointer }
SLTypeHarmonizationTest >> testHarmonizedUnsignedshortPtr [
	"doesn't change the type"
	| result |
	types add: #'unsigned short *'.
	result := ccg harmonizeReturnTypesIn: types.
	self assert: result equals: (Set new add: #'unsigned short *' ; yourself ).
	
	
]
