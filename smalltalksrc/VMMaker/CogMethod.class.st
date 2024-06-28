"
I am a native Cog method or polymorphic inline cache.  If the former I have been produced by compiling a bytecoded CompiledMethod into machine code by the JIT, and I have a circular reference to that CompiledMethod.  The CompiledMethod's header field is a pointer to me, the CogMethod, and my methodHeader field holds the compiled method's actual header.  My objectHeader field looks like a single word object with a compact header with the mark bit set so as to placate the GC, i.e. make a CogMethod look like an object so that the reference to a CogMethod from a compiled method doesn't break the GC.  The cmType, stackCheckOffset, cmNumArgs & cmNumTemps fields are early in the structure because we place dummy two-word CogMethod headers within a method for each block within it to record this information for each block method (see my superclass CogBlockMethod).  In this case the objectHeader field is overlaid by the homeOffset and startpc fields.  The objectHeader field is also used to hold the relocation distance when compacting methods since when functioning as an obhject header it is a constant value and so can easily be reinitialized.  See Cogit class>>structureOfACogMethod for more information.

In C I look like

	typedef struct {
	    sqInt   objectHeader;
	
	    unsigned        cmNumArgs : 8;
	    unsigned        cmType : 3;
	    unsigned        cmRefersToYoung : 1;
	    unsigned        cmIsUnlinked : 1;
	    unsigned        cmUsageCount : 3;
	    unsigned        stackCheckOffset : 16;
	
	    unsigned short blockSize;
	    unsigned short blockEntryOffset;
	
	    sqInt   methodObject;
	    sqInt   methodHeader;
	    sqInt   selector;
	 } CogMethod;

Note that in a 64-bit system all fields from cmNumArgs through blockEntry fit in a single 64-bit word.

My instances are not actually used.  The methods exist only as input to Slang.  The simulator uses my surrogates (CogMethodSurrogate32 and CogMethodSurrogate64.
"
Class {
	#name : 'CogMethod',
	#superclass : 'VMStructType',
	#instVars : [
		'objectHeader',
		'homeOffset',
		'startpc',
		'padToWord',
		'cmNumArgs',
		'cmType',
		'cmRefersToYoung',
		'cpicHasMNUCaseOrCMIsFullBlock',
		'cmUsageCount',
		'cmUsesPenultimateLit',
		'cbUsesInstVars',
		'cmUnusedFlags',
		'stackCheckOffset',
		'blockSize',
		'picUsage',
		'methodObject',
		'methodHeader',
		'selector'
	],
	#pools : [
		'CogMethodConstants',
		'VMBasicConstants',
		'VMBytecodeConstants'
	],
	#category : 'VMMaker-JIT',
	#package : 'VMMaker',
	#tag : 'JIT'
}

{ #category : 'accessing' }
CogMethod class >> alignedByteSize [
	self shouldNotImplement
]

{ #category : 'accessing' }
CogMethod class >> alignedByteSizeOf: anObject forClient: aVMClass [
	^aVMClass cogit cogMethodSurrogateClass alignedByteSize
]

{ #category : 'translation' }
CogMethod class >> cogMethodHeader [

	^ String streamContents: [ :s | self printTypedefOn: s ]
]

{ #category : 'class initialization' }
CogMethod class >> initialize [
	"CogMethod initialize"
	"see instVarNamesAndTypesForTranslationDo:"
	CMMaxUsageCount		:= (2 raisedTo: 3) - 1.
	MaxStackCheckOffset	:= (2 raisedTo: 12) - 1.
	MaxMethodSize		:= (2 raisedTo: 16) - 1
]

{ #category : 'translation' }
CogMethod class >> instVarNamesAndTypesForTranslationDo: aBinaryBlock [
	"enumerate aBinaryBlock with the names and C type strings for the
	 inst vars to include in a CogMethod or CogBlockMethod struct."

	self allInstVarNames do:
		[:ivn|
		"Notionally objectHeader is in a union with homeOffset and startpc but
		 we don't have any convenient support for unions.  So hack, hack, hack, hack."
		(#('homeOffset' 'startpc' 'padToWord') includes: ivn) ifFalse:
				[aBinaryBlock
					value: ivn
					value: (ivn caseOf: {
								['objectHeader']			-> [VMClass objectMemoryClass baseHeaderSize = 8
																ifTrue: [#sqLong]
																ifFalse: [#sqInt]].
								['cmNumArgs']				-> [#(unsigned ' : 8')].		"SqueakV3 needs only 5 bits"
								['cmType']					-> [#(unsigned ' : 3')].
								['cmRefersToYoung']		-> [#(unsigned #Boolean ' : 1')].
								['cpicHasMNUCaseOrCMIsFullBlock']
															-> [#(unsigned #Boolean ' : 1')].
								['cmUsageCount']			-> [#(unsigned ' : 3')].		"See CMMaxUsageCount in initialize"
								['cmUsesPenultimateLit']	-> [#(unsigned #Boolean ' : 1')].
								['cbUsesInstVars']			-> [#(unsigned #Boolean ' : 1')].
								['cmUnusedFlags']			-> [#(unsigned ' : 2')].
								['stackCheckOffset']		-> [#(unsigned ' : 12')].	"See MaxStackCheckOffset in initialize. a.k.a. cPICNumCases"
								['blockSize']				-> [#'unsigned short'].		"See MaxMethodSize in initialize"
								['picUsage']			-> [#'unsigned short'].
								['homeOffset']				-> [#'unsigned short'].
								['startpc']					-> [#'unsigned short'].
								['padToWord']				-> [#(#BaseHeaderSize 8 'unsigned int')].
								['counters']					-> [#usqInt]}				"See SistaCogMethod"
							otherwise:
								[#sqInt])]]
]

{ #category : 'translation' }
CogMethod class >> isAccessor: aSelector [
	"Answer if aSelector is simply an accessor method for one of our fields."
	^(#(cPICNumCases cPICNumCases: nextOpenPIC nextOpenPIC:) includes: aSelector)
	  or: [super isAccessor: aSelector]
]

{ #category : 'code generation' }
CogMethod class >> offsetForInstVar: instVarName [
	"Hack to offset accesses to variables by certain values.  The inst vars following
	 the objectHeader must be offset by the baseHeaderSize."
	^(#('objectHeader' 'homeOffset' 'startpc' 'padToWord') includes: instVarName) ifFalse:
		['baseHeaderSize']
]

{ #category : 'accessing' }
CogMethod class >> surrogateClass [
	self shouldNotImplement
]

{ #category : 'accessing' }
CogMethod >> blockSize [
	"Answer the value of blockSize"

	^ blockSize
]

{ #category : 'accessing' }
CogMethod >> blockSize: anObject [
	"Set the value of blockSize"

	^blockSize := anObject
]

{ #category : 'accessing' }
CogMethod >> cPICNumCases [
	"Answer the value of cPICNumCases (a.k.a. stackCheckOffset)"
	<cmacro: ' stackCheckOffset'>
	^stackCheckOffset
]

{ #category : 'accessing' }
CogMethod >> cPICNumCases: anObject [
	"Set the value of cPICNumCases (a.k.a. stackCheckOffset)"
	<cmacro: 'Hack hack hack hack i.e. the getter macro does all the work'>
	^stackCheckOffset := anObject
]

{ #category : 'accessing' }
CogMethod >> cbUsesInstVars [

	^cbUsesInstVars
]

{ #category : 'accessing' }
CogMethod >> cbUsesInstVars: anObject [

	^cbUsesInstVars := anObject
]

{ #category : 'accessing' }
CogMethod >> cmIsFullBlock [
	"Answer the value of cpicHasMNUCaseOrCMIsFullBlock"
	<inline: true>
	^SistaV1BytecodeSet
		ifTrue: [self cpicHasMNUCaseOrCMIsFullBlock]
		ifFalse: [false]
]

{ #category : 'accessing' }
CogMethod >> cmNumArgs [
	"Answer the value of cmNumArgs"

	^cmNumArgs
]

{ #category : 'accessing' }
CogMethod >> cmNumArgs: anObject [
	"Set the value of cmNumArgs"

	^cmNumArgs := anObject
]

{ #category : 'accessing' }
CogMethod >> cmRefersToYoung [
	"Answer the value of cmRefersToYoung"

	^cmRefersToYoung
]

{ #category : 'accessing' }
CogMethod >> cmRefersToYoung: anObject [
	"Set the value of cmRefersToYoung"

	^cmRefersToYoung := anObject
]

{ #category : 'accessing' }
CogMethod >> cmType [
	"Answer the value of cmType"

	^cmType
]

{ #category : 'accessing' }
CogMethod >> cmType: anInteger [
	"Set the value of cmType"

	^cmType := anInteger
]

{ #category : 'accessing' }
CogMethod >> cmUsageCount [
	"Answer the value of cmUsageCount"

	^cmUsageCount
]

{ #category : 'accessing' }
CogMethod >> cmUsageCount: anInteger [
	"Set the value of cmUsageCount"

	^cmUsageCount := anInteger
]

{ #category : 'accessing' }
CogMethod >> cmUsesPenultimateLit [
	"Answer the value of cmUsesPenultimateLit"

	^cmUsesPenultimateLit
]

{ #category : 'accessing' }
CogMethod >> cmUsesPenultimateLit: anObject [
	"Set the value of cmUsesPenultimateLit"

	^cmUsesPenultimateLit := anObject
]

{ #category : 'testing' }
CogMethod >> containsAddress: anAddress [
	"is anAddress within my bounds; not a test of addresses referred to within instructions in the method"
	<inline: true>
	^self asUnsignedInteger <= anAddress asUnsignedInteger
	  and: [self asUnsignedInteger + self blockSize >= anAddress asUnsignedInteger]
]

{ #category : 'accessing' }
CogMethod >> counters [
	^ 0
]

{ #category : 'accessing' }
CogMethod >> cpicHasMNUCase [
	"Answer if the receiver has an MNU case."
	<inline: true>

	^SistaV1BytecodeSet
		ifTrue: [self cpicHasMNUCaseOrCMIsFullBlock and: [self cmType = CMPolymorphicIC]]
		ifFalse: [cpicHasMNUCaseOrCMIsFullBlock]
]

{ #category : 'accessing' }
CogMethod >> cpicHasMNUCase: anObject [
	"Set if the receiver has an MNU case."
	<inline: true>
	^cpicHasMNUCaseOrCMIsFullBlock := anObject
]

{ #category : 'accessing' }
CogMethod >> cpicHasMNUCaseOrCMIsFullBlock [
	"Answer the value of cpicHasMNUCaseOrCMIsFullBlock"

	^cpicHasMNUCaseOrCMIsFullBlock
]

{ #category : 'accessing' }
CogMethod >> cpicHasMNUCaseOrCMIsFullBlock: anObject [
	"Set the value of cpicHasMNUCaseOrCMIsFullBlock"

	^cpicHasMNUCaseOrCMIsFullBlock := anObject
]

{ #category : 'accessing' }
CogMethod >> methodHeader [
	"Answer the value of methodHeader"

	^ methodHeader
]

{ #category : 'accessing' }
CogMethod >> methodHeader: anObject [
	"Set the value of methodHeader"

	^methodHeader := anObject
]

{ #category : 'accessing' }
CogMethod >> methodObject [
	"Answer the value of methodObject"

	^methodObject
]

{ #category : 'accessing' }
CogMethod >> methodObject: anObject [
	"Set the value of methodObject"

	^methodObject := anObject
]

{ #category : 'accessing' }
CogMethod >> nextOpenPIC [
	"Answer the value of nextOpenPIC (a.k.a. methodObject)"
	<cmacro: ' methodObject'>
	^methodObject
]

{ #category : 'accessing' }
CogMethod >> nextOpenPIC: anObject [
	"Set the value of nextOpenPIC (a.k.a. methodObject)"
	<cmacro: 'Hack hack hack hack i.e. the getter macro does all the work'>
	^methodObject := anObject
]

{ #category : 'accessing' }
CogMethod >> objectHeader [
	"Answer the value of objectHeader"

	^objectHeader
]

{ #category : 'accessing' }
CogMethod >> objectHeader: anObject [
	"Set the value of objectHeader"

	^objectHeader := anObject
]

{ #category : 'accessing' }
CogMethod >> picUsage [
	"Answer the value of blockEntryOffset"

	^picUsage
]

{ #category : 'accessing' }
CogMethod >> picUsage: anObject [
	"Set the value of blockEntryOffset"

	^picUsage := anObject
]

{ #category : 'accessing' }
CogMethod >> selector [
	"Answer the value of selector"

	^ selector
]

{ #category : 'accessing' }
CogMethod >> selector: anObject [
	"Set the value of selector"

	^selector := anObject
]

{ #category : 'accessing' }
CogMethod >> stackCheckOffset [
	"Answer the value of stackCheckOffset"

	^stackCheckOffset
]

{ #category : 'accessing' }
CogMethod >> stackCheckOffset: anObject [
	"Set the value of stackCheckOffset"

	^stackCheckOffset := anObject
]

{ #category : 'accessing' }
CogMethod >> startpc [
	"Answer the value of startpc"

	^startpc
]

{ #category : 'accessing' }
CogMethod >> startpc: anObject [
	"Set the value of startpc"

	^startpc := anObject
]
