"
Implement the socket and resolver primitives.  Since it requires platform support it will only be built when supported on your platform
"
Class {
	#name : #SocketPlugin,
	#superclass : #SmartSyntaxInterpreterPlugin,
	#category : #'VMMaker-Plugins'
}

{ #category : #translation }
SocketPlugin class >> declareCVarsIn: aCCodeGenerator [

	"Hmmm, we could use 
		self declareC:  (self instVarNames select: [:ivn| ivn first = $s and: [ivn second isUppercase]])
			as: #'void *'
			in: aCCodeGenerator."
	aCCodeGenerator addHeaderFile: '"SocketPlugin.h"'
]

{ #category : #translation }
SocketPlugin class >> hasHeaderFile [
	"If there is a single intrinsic header file to be associated with the plugin, here is where you want to flag"
	^true
]

{ #category : #translation }
SocketPlugin class >> requiresPlatformFiles [
	"this plugin requires platform specific files in order to work"
	^true
]

{ #category : #translation }
SocketPlugin class >> shouldGenerateDeadCode [

	^ false
]

{ #category : #'accessing - ip4' }
SocketPlugin >> addressStructFor: aSocketAddress [

	<returnTypeC: #'struct sockaddr*'>

	| addressType |

	addressType := self getAddressType: aSocketAddress.
	addressType = 0 ifTrue: [ ^ interpreterProxy primitiveFail. ].
	
	addressType = self ip4AddressType 
		ifTrue: [ 
			(self isValidIp4Address: aSocketAddress) 
				ifFalse: [ ^ nil  ].
			^ self newIP4SockAddr: (self getIp4Address: aSocketAddress) _: (self getIp4Port: aSocketAddress) ].
		
	^ interpreterProxy primitiveFail.
]

{ #category : #'accessing - ip4' }
SocketPlugin >> addressStructSizeFor: aSocketAddress [

	<returnTypeC: #'void*'>

	| addressType |

	addressType := self getAddressType: aSocketAddress.
	addressType = 0 ifTrue: [ ^ interpreterProxy primitiveFail. ].
	
	addressType = self ip4AddressType 
		ifTrue: [ ^ self ip4SockSize ].
		
	^ interpreterProxy primitiveFail.
]

{ #category : #'accessing - ip4' }
SocketPlugin >> getAddressType: anAddressOop [

	<returnTypeC: #int>

	| type |
	
	(interpreterProxy isPointers: anAddressOop)
		ifFalse: [ interpreterProxy primitiveFail. ^ nil  ].

	(interpreterProxy slotSizeOf: anAddressOop) >= 1
		ifFalse:  [ interpreterProxy primitiveFail. ^ nil  ].

	type := interpreterProxy fetchInteger: 0 ofObject: anAddressOop.
	interpreterProxy failed ifTrue: [ ^ nil ].
	
	^ type
]

{ #category : #'accessing - ip4' }
SocketPlugin >> getIp4Address: anAddressOop [

	"IPv4 Addresses are represented by an object with a smallinteger saying the address type (2 for IPv4), a 4 bytes bytearray as second instance variable, and a smallInteger as port number as third instance variable. If it does not have port the value is -1.
	It returns the int32 representing the address in host order"

	<returnTypeC: #int>
	<var: #ptrToByteArray type: 'unsigned char * '>

	| ptrToByteArray |
	ptrToByteArray := interpreterProxy firstIndexableField: (interpreterProxy fetchPointer: 1 ofObject: anAddressOop).

	^ (ptrToByteArray at: 3	) +
		((ptrToByteArray at: 2) <<8) +
		((ptrToByteArray at: 1) <<16) +
		((ptrToByteArray at: 0) <<24)


]

{ #category : #'accessing - ip4' }
SocketPlugin >> getIp4Port: anAddressOop [

	<returnTypeC: #int>

	"IPv4 Addresses are represented by an object with a smallinteger saying the address type (2 for IPv4), a 4 bytes bytearray as second instance variable, and a smallInteger as port number as third instance variable. If it does not have port the value is -1.
	It returns the int32 representing the port in host order"

	^ interpreterProxy fetchInteger: 2 ofObject: anAddressOop
]

{ #category : #'initialize-release' }
SocketPlugin >> initialiseModule [

	<export: true>

	^self socketInit
]

{ #category : #primitives }
SocketPlugin >> intToNetAddress: addr [
	"Convert the given 32-bit integer into an internet network address represented as a four-byte ByteArray."

	| netAddressOop naPtr |
	<var: #naPtr type: 'char * '>

	netAddressOop :=
		interpreterProxy instantiateClass: interpreterProxy classByteArray
			indexableSize: 4.
	naPtr := netAddressOop asCharPtr.
	naPtr at: 0 put: (self cCoerce: ((addr >> 24) bitAnd: 16rFF) to: 'char').
	naPtr at: 1 put: (self cCoerce: ((addr >> 16) bitAnd: 16rFF) to: 'char').
	naPtr at: 2 put: (self cCoerce: ((addr >> 8) bitAnd: 16rFF) to: 'char').
	naPtr at: 3 put: (self cCoerce: (addr bitAnd: 16rFF) to: 'char').
	^ netAddressOop
]

{ #category : #'accessing - ip4' }
SocketPlugin >> ip4AddressType [

	<cmacro: '() SOCKET_FAMILY_INET4'>

	^ 2
]

{ #category : #'accessing - ip4' }
SocketPlugin >> isValidIp4Address: anAddressOop [

	<returnTypeC: #int>

	"IPv4 Addresses are represented by an object with a smallinteger saying the address type (2 for IPv4), a 4 bytes bytearray as second instance variable, and a smallInteger as port number as third instance variable. If it does not have port the value is -1."

	| maybeByteArray maybeInteger type |

	type := self getAddressType: anAddressOop.
	interpreterProxy failed ifTrue: [ ^ false ].
	
	type = self ip4AddressType ifFalse: [ interpreterProxy primitiveFail. ^ false ].

	maybeByteArray := interpreterProxy fetchPointer: 1 ofObject: anAddressOop.
	
	(interpreterProxy isBytes: maybeByteArray)
		ifFalse:  [ interpreterProxy primitiveFail. ^ false  ].

	(interpreterProxy stSizeOf: maybeByteArray) = 4
		ifFalse:  [ interpreterProxy primitiveFail. ^ false  ].

	maybeInteger := interpreterProxy fetchPointer: 2 ofObject: anAddressOop.

	(interpreterProxy isIntegerObject: maybeInteger)
		ifFalse:  [ interpreterProxy primitiveFail. ^ false  ].
		
	^ true
]

{ #category : #primitives }
SocketPlugin >> netAddressToInt: ptrToByteArray [
	"Convert the given internet network address (represented as a four-byte ByteArray) into a 32-bit integer. Fail if the given ptrToByteArray does not appear to point to a four-byte ByteArray."

	| sz |
	<var: #ptrToByteArray type: 'unsigned char * '>
	sz := interpreterProxy byteSizeOf: ptrToByteArray cPtrAsOop.
	sz = 4 ifFalse: [^ interpreterProxy primitiveFail].
	^ (ptrToByteArray at: 3	) +
		((ptrToByteArray at: 2) <<8) +
		((ptrToByteArray at: 1) <<16) +
		((ptrToByteArray at: 0) <<24)
]

{ #category : #primitives }
SocketPlugin >> primitiveInitializeNetwork: resolverSemaIndex [

	| err |
	self primitive: 'primitiveInitializeNetwork'
		parameters: #(SmallInteger).
	err := self sqNetworkInit: resolverSemaIndex.
	interpreterProxy success: err = 0
]

{ #category : #'primitives - resolver - old' }
SocketPlugin >> primitiveResolverAbortLookup [

	self primitive: 'primitiveResolverAbortLookup'.

	self sqResolverAbort
]

{ #category : #'primitives - resolver - old' }
SocketPlugin >> primitiveResolverAddressLookupResult [
	| sz s |
	self primitive: 'primitiveResolverAddressLookupResult'.
	sz := self sqResolverAddrLookupResultSize.

	interpreterProxy failed
		ifFalse: [s := interpreterProxy instantiateClass: interpreterProxy classString indexableSize: sz.
			self sqResolverAddrLookup: s asCharPtr Result: sz].
	^ s
]

{ #category : #'primitives - resolver - old' }
SocketPlugin >> primitiveResolverError [

	self primitive: 'primitiveResolverError'.
	^ self sqResolverError asSmallIntegerObj
]

{ #category : #'primitives - resolver' }
SocketPlugin >> primitiveResolverGetAddressInfoFamily [

	| family |
	self primitive: 'primitiveResolverGetAddressInfoFamily'
		parameters: #().
	interpreterProxy failed
		ifFalse:
			[family := self sqResolverGetAddressInfoFamily.
			 ^family asSmallIntegerObj]
]

{ #category : #'primitives - resolver' }
SocketPlugin >> primitiveResolverGetAddressInfoHost: hostName service: servName flags: flags family: family type: type protocol: protocol [

	| hostSize servSize |
	self primitive: 'primitiveResolverGetAddressInfo'
		parameters: #(String String SmallInteger SmallInteger SmallInteger SmallInteger).
	interpreterProxy failed
		ifFalse:
			[hostSize := interpreterProxy byteSizeOf: hostName cPtrAsOop.
			 servSize := interpreterProxy byteSizeOf: servName cPtrAsOop.
			 self
			 	sqResolverGetAddressInfoHost: hostName Size: hostSize Service: servName Size: servSize
					Flags: flags Family: family Type: type Protocol: protocol]
]

{ #category : #'primitives - resolver' }
SocketPlugin >> primitiveResolverGetAddressInfoNext [

	| more |
	self primitive: 'primitiveResolverGetAddressInfoNext'
		parameters: #().
	more := self sqResolverGetAddressInfoNext.
	interpreterProxy failed ifTrue: [^nil].
	^more asBooleanObj
]

{ #category : #'primitives - resolver' }
SocketPlugin >> primitiveResolverGetAddressInfoProtocol [

	| protocol |
	self primitive: 'primitiveResolverGetAddressInfoProtocol'
		parameters: #().
	interpreterProxy failed
		ifFalse:
			[protocol := self sqResolverGetAddressInfoProtocol.
			 ^protocol asSmallIntegerObj]
]

{ #category : #'primitives - resolver' }
SocketPlugin >> primitiveResolverGetAddressInfoResult: socketAddress [

	| addrSize |
	self primitive: 'primitiveResolverGetAddressInfoResult'
		parameters: #(ByteArray).
	interpreterProxy failed
		ifFalse:
			[addrSize := interpreterProxy byteSizeOf: socketAddress cPtrAsOop.
			 self sqResolverGetAddressInfoResult: socketAddress Size: addrSize]
]

{ #category : #'primitives - resolver' }
SocketPlugin >> primitiveResolverGetAddressInfoSize [

	| size |
	self primitive: 'primitiveResolverGetAddressInfoSize'
		parameters: #().
	interpreterProxy failed
		ifFalse:
			[size := self sqResolverGetAddressInfoSize.
			 ^size asSmallIntegerObj]
]

{ #category : #'primitives - resolver' }
SocketPlugin >> primitiveResolverGetAddressInfoType [

	| type |
	self primitive: 'primitiveResolverGetAddressInfoType'
		parameters: #().
	interpreterProxy failed
		ifFalse:
			[type := self sqResolverGetAddressInfoType.
			 ^type asSmallIntegerObj]
]

{ #category : #'primitives - resolver' }
SocketPlugin >> primitiveResolverGetNameInfo: socketAddress flags: flags [

	| addrSize addrBase |
	<var: #addrBase type: 'char *'>
	self primitive: 'primitiveResolverGetNameInfo'
		parameters: #(Oop SmallInteger).
	interpreterProxy failed
		ifFalse:
			[addrSize := interpreterProxy byteSizeOf: socketAddress.
			 addrBase := self cCoerce: (interpreterProxy firstIndexableField: socketAddress) to: 'char *'.
			 self sqResolverGetNameInfo: addrBase Size: addrSize Flags: flags]
]

{ #category : #'primitives - resolver' }
SocketPlugin >> primitiveResolverGetNameInfoHostResult: socketName [

	| addrSize |
	self primitive: 'primitiveResolverGetNameInfoHostResult'
		parameters: #(String).
	interpreterProxy failed
		ifFalse:
			[addrSize := interpreterProxy byteSizeOf: socketName cPtrAsOop.
			 self sqResolverGetNameInfoHostResult: socketName Size: addrSize]
]

{ #category : #'primitives - resolver' }
SocketPlugin >> primitiveResolverGetNameInfoHostSize [

	| size |
	self primitive: 'primitiveResolverGetNameInfoHostSize'
		parameters: #().
	interpreterProxy failed
		ifFalse:
			[size := self sqResolverGetNameInfoHostSize.
			 ^size asSmallIntegerObj]
]

{ #category : #'primitives - resolver' }
SocketPlugin >> primitiveResolverGetNameInfoServiceResult: socketName [

	| addrSize |
	self primitive: 'primitiveResolverGetNameInfoServiceResult'
		parameters: #(String).
	interpreterProxy failed
		ifFalse:
			[addrSize := interpreterProxy byteSizeOf: socketName cPtrAsOop.
			 self sqResolverGetNameInfoServiceResult: socketName Size: addrSize]
]

{ #category : #'primitives - resolver' }
SocketPlugin >> primitiveResolverGetNameInfoServiceSize [

	| size |
	self primitive: 'primitiveResolverGetNameInfoServiceSize'
		parameters: #().
	interpreterProxy failed
		ifFalse:
			[size := self sqResolverGetNameInfoServiceSize.
			 ^size asSmallIntegerObj]
]

{ #category : #'primitives - resolver' }
SocketPlugin >> primitiveResolverHostNameResult: nameString [

	| nameSize |
	self primitive: 'primitiveResolverHostNameResult'
		parameters: #(String).
	interpreterProxy failed
		ifFalse:
			[nameSize := interpreterProxy byteSizeOf: nameString cPtrAsOop.
			 self sqResolverHostNameResult: nameString Size: nameSize]
]

{ #category : #'primitives - resolver' }
SocketPlugin >> primitiveResolverHostNameSize [

	| size |
	self primitive: 'primitiveResolverHostNameSize'
		parameters: #().
	interpreterProxy failed
		ifFalse:
			[size := self sqResolverHostNameSize.
			 interpreterProxy failed ifFalse: [^size asSmallIntegerObj]]
]

{ #category : #'primitives - resolver - old' }
SocketPlugin >> primitiveResolverLocalAddress [

	| addr |
	self primitive: 'primitiveResolverLocalAddress'.
	addr := self sqResolverLocalAddress.
	^self intToNetAddress: addr
]

{ #category : #'primitives - resolver - old' }
SocketPlugin >> primitiveResolverNameLookupResult [

	| addr |
	self primitive: 'primitiveResolverNameLookupResult'.
	addr := self sqResolverNameLookupResult.
	^self intToNetAddress: addr
]

{ #category : #'primitives - resolver - old' }
SocketPlugin >> primitiveResolverStartAddressLookup: address [

	| addr |
	self primitive: 'primitiveResolverStartAddressLookup'
		parameters: #(ByteArray).
	addr := self netAddressToInt: (self cCoerce: address to: 'unsigned char *').
	interpreterProxy failed ifFalse: [
		self sqResolverStartAddrLookup: addr]
]

{ #category : #'primitives - resolver - old' }
SocketPlugin >> primitiveResolverStartNameLookup: name [

	| sz |
	self primitive: 'primitiveResolverStartNameLookup'
		parameters: #(String).
	interpreterProxy failed ifFalse:  [
		sz := interpreterProxy byteSizeOf: name cPtrAsOop.
		self sqResolverStartName: name Lookup: sz]
]

{ #category : #'primitives - resolver - old' }
SocketPlugin >> primitiveResolverStatus [

	| status |
	self primitive: 'primitiveResolverStatus'.
	status := self sqResolverStatus.
	^status asSmallIntegerObj
]

{ #category : #'primitives - status' }
SocketPlugin >> primitiveSocket: socket LocalAddress: socketAddressOop [

	<var: #s type: #SocketPtr>
	<var: #addr type: #'void *'>
	<var: #addrSize type: #'size_t'>

	| s addr addrSize |
	self primitive: 'primitiveSocketLocalAddress' parameters: #(Oop Oop).

	s := self socketValueOf: socket.

	addr := self addressStructFor: socketAddressOop.
	addrSize := self addressStructSizeFor: socketAddressOop.
			
	interpreterProxy failed
		ifFalse: [
			self socketLocalAddress: s _: addr _: addrSize.
			self updateAddress: socketAddressOop from: addr.
			self free: addr ].

]

{ #category : #'primitives - status' }
SocketPlugin >> primitiveSocket: socket RemoteAddress: socketAddressOop [

	<var: #s type: #SocketPtr>
	<var: #addr type: #'void *'>
	<var: #addrSize type: #'size_t'>

	| s addr addrSize |
	self primitive: 'primitiveSocketRemoteAddress' parameters: #(Oop Oop).

	s := self socketValueOf: socket.

	addr := self addressStructFor: socketAddressOop.
	addrSize := self addressStructSizeFor: socketAddressOop.
			
	interpreterProxy failed
		ifFalse: [
			self socketRemoteAddress: s _: addr _: addrSize.
			self updateAddress: socketAddressOop from: addr.
			self free: addr ].

]

{ #category : #'primitives - connection' }
SocketPlugin >> primitiveSocket: socket bindTo: socketAddressOop [

	<var: #addr type: 'void*'>
	<var: #addrSize type: 'size_t'>

	<var: #s type: 'SocketPtr'>

	| s addr addrSize |
	self primitive: 'primitiveSocketBindTo' parameters: #(#Oop #Oop).

	s := self socketValueOf: socket.

	addr := self addressStructFor: socketAddressOop.
	addrSize := self addressStructSizeFor: socketAddressOop.

	interpreterProxy failed ifFalse: [
		self socketBindTo: s _: addr _: addrSize.
		self free: addr].
]

{ #category : #'primitives - connection' }
SocketPlugin >> primitiveSocket: socket connectTo: socketAddressOop [

	| addrSize addr s  |

	<var: #addr type: 'void*'>
	<var: #addrSize type: 'size_t'>

	<var: #s type: 'SocketPtr'>

	self primitive: 'primitiveSocketConnectTo' parameters: #(#Oop #Oop).

	s := self socketValueOf: socket.

	addr := self addressStructFor: socketAddressOop.
	addrSize := self addressStructSizeFor: socketAddressOop.

	interpreterProxy failed ifFalse: [
		self socket: s ConnectToAddress: addr Size: addrSize.
		self free: addr].
	
	
]

{ #category : #'primitives - status' }
SocketPlugin >> primitiveSocket: socket getOptions: optionName [

	| s optionNameStart optionNameSize returnedValue errorCode results |
	<var: #s type: #SocketPtr>
	<var: #optionNameStart type: #'char *'>
	self primitive: 'primitiveSocketGetOptions'
		parameters: #(Oop Oop).

	s := self socketValueOf: socket.
	interpreterProxy success: (interpreterProxy isBytes: optionName).
	optionNameStart := self cCoerce: (interpreterProxy firstIndexableField: optionName) to: #'char *'.
	optionNameSize := interpreterProxy slotSizeOf: optionName.

	interpreterProxy failed ifTrue: [^nil].
	returnedValue := 0.

	errorCode := self sqSocketGetOptions: s 
					optionNameStart: optionNameStart 
					optionNameSize: optionNameSize
					returnedValue: (self addressOf: returnedValue).

	results := interpreterProxy instantiateClass: interpreterProxy classArray indexableSize: 2.
	interpreterProxy storePointer: 0 ofObject: results withValue: errorCode asSmallIntegerObj.
	interpreterProxy storePointer: 1 ofObject: results withValue: returnedValue asSmallIntegerObj.
	^ results
]

{ #category : #'primitives - connection' }
SocketPlugin >> primitiveSocket: socket listenOn: socketAddressOop backLog: backlogSize [

	| addrSize addr s  |

	<var: #addr type: 'void*'>
	<var: #addrSize type: 'size_t'>

	<var: #s type: 'SocketPtr'>

	self primitive: 'primitiveSocketListenOn' parameters: #(#Oop #Oop #SmallInteger).

	s := self socketValueOf: socket.

	addr := self addressStructFor: socketAddressOop.
	addrSize := self addressStructSizeFor: socketAddressOop.

	interpreterProxy failed ifFalse: [
		self socketListenOn: s _: addr _: addrSize _: backlogSize.
		self free: addr].
	
	
]

{ #category : #'primitives - sending/receiving' }
SocketPlugin >> primitiveSocket: socket receiveDataBuf: array start: startIndex count: count [ 
	| s byteSize arrayBase bufStart bytesReceived |
	<var: #s type: 'SocketPtr'>
	<var: #arrayBase type: 'char *'>
	<var: #bufStart type: 'char *'>
	self primitive: 'primitiveSocketReceiveDataBufCount'
		parameters: #(Oop Oop SmallInteger SmallInteger ).
	s := self socketValueOf: socket.

	"buffer can be any indexable words or bytes object"
	interpreterProxy success: (interpreterProxy isWordsOrBytes: array).
	(interpreterProxy isWords: array)
		ifTrue: [byteSize := 4]
		ifFalse: [byteSize := 1].
	interpreterProxy success: (startIndex >= 1
			and: [count >= 0 and: [startIndex + count - 1 <= (interpreterProxy slotSizeOf: array)]]).
	interpreterProxy failed
		ifFalse: ["Note: adjust bufStart for zero-origin indexing"
			arrayBase := self cCoerce: (interpreterProxy firstIndexableField: array) to: 'char *'.
			bufStart := arrayBase + (startIndex - 1 * byteSize).
			bytesReceived := self
						sqSocket: s
						ReceiveDataBuf: bufStart
						Count: count * byteSize].
	^ (bytesReceived // byteSize) asSmallIntegerObj
]

{ #category : #'primitives - sending/receiving' }
SocketPlugin >> primitiveSocket: socket receiveUDPDataBuf: array start: startIndex count: count fromAddress: socketAddressOop [
	| s elementSize arrayBase bufStart bytesReceived addr addrSize |
	<var: #s type: #SocketPtr>
	<var: #arrayBase type: #'char *'>
	<var: #bufStart type: #'char *'>
	<var: #addr type: #'void *'>
	<var: #addrSize type: #'size_t'>

	self primitive: 'primitiveSocketReceiveUDPData'
		parameters: #(Oop Oop SmallInteger SmallInteger Oop).

	s := self socketValueOf: socket.

	"buffer can be any indexable words or bytes object"
	interpreterProxy success: (interpreterProxy isWordsOrBytes: array).
	(interpreterProxy isWords: array)
		ifTrue: [elementSize := 4]
		ifFalse: [elementSize := 1].
	interpreterProxy success: (startIndex >= 1
			and: [count >= 0 and: [startIndex + count - 1 <= (interpreterProxy slotSizeOf: array)]]).

	addr := self addressStructFor: socketAddressOop.
	addrSize := self addressStructSizeFor: socketAddressOop.
			
	interpreterProxy failed
		ifFalse: ["Note: adjust bufStart for zero-origin indexing"
			arrayBase		:= self cCoerce: (interpreterProxy firstIndexableField: array) to: #'char *'.
			bufStart		:= arrayBase + (startIndex - 1 * elementSize).
			bytesReceived := self socketReceiveUDPData: s
									_: bufStart
									_: count * elementSize
									_: addr
									_: addrSize.

			self updateAddress: socketAddressOop from: addr.
			self free: addr ].
		
	^ (bytesReceived // elementSize) asSmallIntegerObj
]

{ #category : #'primitives - sending/receiving' }
SocketPlugin >> primitiveSocket: socket sendData: array start: startIndex count: count [ 
	| s byteSize arrayBase bufStart bytesSent |
	<var: #s type: 'SocketPtr'>
	<var: #arrayBase type: 'char *'>
	<var: #bufStart type: 'char *'>
	self primitive: 'primitiveSocketSendDataBufCount'
		parameters: #(Oop Oop SmallInteger SmallInteger ).
	s := self socketValueOf: socket.

	"buffer can be any indexable words or bytes object except CompiledMethod "
	interpreterProxy success: (interpreterProxy isWordsOrBytes: array).
	(interpreterProxy isWords: array)
		ifTrue: [byteSize := 4]
		ifFalse: [byteSize := 1].
	interpreterProxy success: (startIndex >= 1
			and: [count >= 0 and: [startIndex + count - 1 <= (interpreterProxy slotSizeOf: array)]]).
	interpreterProxy failed
		ifFalse: ["Note: adjust bufStart for zero-origin indexing"
			arrayBase := self cCoerce: (interpreterProxy firstIndexableField: array) to: 'char *'.
			bufStart := arrayBase + (startIndex - 1 * byteSize).
			bytesSent := self
						sqSocket: s
						SendDataBuf: bufStart
						Count: count * byteSize].
	^ (bytesSent // byteSize) asSmallIntegerObj
]

{ #category : #'primitives - sending/receiving' }
SocketPlugin >> primitiveSocket: socket sendUDPData: array toAddress: socketAddressOop start: startIndex count: count [ 
	| s byteSize arrayBase bufStart bytesSent addr addrSize |
	<var: #s type: 'SocketPtr'>
	<var: #bufStart type: 'char *'>

	self primitive: 'primitiveSocketSendUDPData' parameters: #(Oop Oop Oop SmallInteger SmallInteger ).

	s := self socketValueOf: socket.

	"buffer can be any indexable words or bytes object except CompiledMethod "
	interpreterProxy success: (interpreterProxy isWordsOrBytes: array).
	(interpreterProxy isWords: array)
		ifTrue: [byteSize := 4]
		ifFalse: [byteSize := 1].

	interpreterProxy success: (startIndex >= 1
			and: [count >= 0 and: [startIndex + count - 1 <= (interpreterProxy slotSizeOf: array)]]).

	interpreterProxy failed
		ifFalse: ["Note: adjust bufStart for zero-origin indexing"
			arrayBase := self cCoerce: (interpreterProxy firstIndexableField: array) to: 'char *'.
			bufStart := arrayBase + (startIndex - 1 * byteSize).
			addr := self addressStructFor: socketAddressOop.
			addrSize := self addressStructSizeFor: socketAddressOop.

			bytesSent := self socketSendUDPDataToAddress: s _: addr _: addrSize _: bufStart _: count * byteSize.
			self free: addr].


	^ (bytesSent // byteSize) asSmallIntegerObj
]

{ #category : #'primitives - status' }
SocketPlugin >> primitiveSocket: socket setOptions: optionName value: optionValue [
	"THIS BADLY NEEDS TO BE REWRITTEN TO TAKE Booleans AND Integers AS WELL AS (OR INSTEAD OF) Strings.
	 It is only used with booleans and integers and parsing these back out of strings in
	 sqSocketSetOptions:optionNameStart:optionNameSize:optionValueStart:optionValueSize:returnedValue:
	 is STUPID."
	| s optionNameStart optionNameSize optionValueStart optionValueSize returnedValue errorCode results |
	<var: #s type: #SocketPtr>
	<var: #optionNameStart type: #'char *'>
	<var: #optionValueStart type: #'char *'>
	self primitive: 'primitiveSocketSetOptions'
		parameters: #(Oop Oop Oop).

	s := self socketValueOf: socket.
	interpreterProxy success: (interpreterProxy isBytes: optionName).
	optionNameStart := self cCoerce: (interpreterProxy firstIndexableField: optionName) to: #'char *'.
	optionNameSize := interpreterProxy slotSizeOf: optionName.
	interpreterProxy success: (interpreterProxy isBytes: optionValue).
	optionValueStart:= self cCoerce: (interpreterProxy firstIndexableField: optionValue) to: #'char *'.
	optionValueSize := interpreterProxy slotSizeOf: optionValue.

	interpreterProxy failed ifTrue: [^nil].
	returnedValue := 0.

	errorCode := self sqSocketSetOptions: s 
					optionNameStart: optionNameStart 
					optionNameSize: optionNameSize
					optionValueStart: optionValueStart
					optionValueSize: optionValueSize
					returnedValue: (self addressOf: returnedValue).

	results := interpreterProxy instantiateClass: interpreterProxy classArray indexableSize: 2.
	interpreterProxy storePointer: 0 ofObject: results withValue: errorCode asSmallIntegerObj.
	interpreterProxy storePointer: 1 ofObject: results withValue: returnedValue asSmallIntegerObj.
	^ results
]

{ #category : #'primitives - connection' }
SocketPlugin >> primitiveSocketAbortConnection: socket [

	| s |
	<var: #s type: 'SocketPtr '>
	self primitive: 'primitiveSocketAbortConnection'
		parameters: #(Oop).
	s := self socketValueOf: socket.
	interpreterProxy failed ifFalse: [
		self sqSocketAbortConnection: s]
]

{ #category : #'primitives - creation' }
SocketPlugin >> primitiveSocketAcceptFrom: sockHandle rcvBufferSize: recvBufSize sndBufSize: sendBufSize semaIndex: semaIndex readSemaIndex: aReadSema writeSemaIndex: aWriteSema [
	| socketOop s serverSocket |
	<var: #s type: 'SocketPtr '>
	<var: #serverSocket type: 'SocketPtr '>
	self primitive: 'primitiveSocketAccept3Semaphores'
		parameters: #(Oop SmallInteger SmallInteger SmallInteger SmallInteger SmallInteger).
	serverSocket := self socketValueOf: sockHandle.

	interpreterProxy failed
		ifFalse: [socketOop := interpreterProxy instantiateClass: interpreterProxy classByteArray indexableSize: self socketRecordSize.
			s := self socketValueOf: socketOop.
			self
				sqSocket: s
				AcceptFrom: serverSocket
				RecvBytes: recvBufSize
				SendBytes: sendBufSize
				SemaID: semaIndex
				ReadSemaID: aReadSema
				WriteSemaID: aWriteSema].
	^ socketOop
]

{ #category : #'primitives - connection' }
SocketPlugin >> primitiveSocketCloseConnection: socket [

	| s |
	<var: #s type: 'SocketPtr '>
	self primitive: 'primitiveSocketCloseConnection'
		parameters: #(Oop).
	s := self socketValueOf: socket.
	interpreterProxy failed ifFalse: [
		self sqSocketCloseConnection: s]
]

{ #category : #'primitives - status' }
SocketPlugin >> primitiveSocketConnectionStatus: socket [

	| s status |
	<var: #s type: 'SocketPtr '>
	self primitive: 'primitiveSocketConnectionStatus'
		parameters: #(Oop).
	s := self socketValueOf: socket.
	interpreterProxy failed ifFalse: [
		status := self sqSocketConnectionStatus: s].
	^ status asSmallIntegerObj
]

{ #category : #'primitives - creation' }
SocketPlugin >> primitiveSocketCreateNetwork: netType type: socketType receiveBufferSize: recvBufSize sendBufSize: sendBufSize semaIndex: semaIndex readSemaIndex: aReadSema writeSemaIndex: aWriteSema [ 
	| socketOop s okToCreate |
	<var: #s type: 'SocketPtr '>
	self primitive: 'primitiveSocketCreate3Semaphores' parameters: #(#SmallInteger #SmallInteger #SmallInteger #SmallInteger #SmallInteger #SmallInteger #SmallInteger ).

	socketOop := interpreterProxy instantiateClass: interpreterProxy classByteArray indexableSize: self socketRecordSize.
	s := self socketValueOf: socketOop.
	interpreterProxy failed ifFalse:
		[self
			sqSocket: s
			CreateNetType: netType
			SocketType: socketType
			RecvBytes: recvBufSize
			SendBytes: sendBufSize
			SemaID: semaIndex
			ReadSemaID: aReadSema
			WriteSemaID: aWriteSema].
	^socketOop
]

{ #category : #'primitives - creation' }
SocketPlugin >> primitiveSocketCreateRaw: netType type: protoType receiveBufferSize: recvBufSize sendBufSize: sendBufSize semaIndex: semaIndex readSemaIndex: aReadSema writeSemaIndex: aWriteSema [ 
	| socketOop s |
	<var: #s type: 'SocketPtr '>
	self primitive: 'primitiveSocketCreateRAW' parameters: #(#SmallInteger #SmallInteger #SmallInteger #SmallInteger #SmallInteger #SmallInteger #SmallInteger ).

	socketOop := interpreterProxy instantiateClass: interpreterProxy classByteArray indexableSize: self socketRecordSize.
	s := self socketValueOf: socketOop.
	interpreterProxy failed ifFalse:
		[self
			sqSocket: s
			CreateRaw: netType
			ProtoType: protoType
			RecvBytes: recvBufSize
			SendBytes: sendBufSize
			SemaID: semaIndex
			ReadSemaID: aReadSema
			WriteSemaID: aWriteSema].
	^ socketOop
]

{ #category : #primitives }
SocketPlugin >> primitiveSocketDestroy: socket [

	| s |
	<var: #s type: 'SocketPtr'>
	self primitive: 'primitiveSocketDestroy'
		parameters: #(Oop).
	s := self socketValueOf: socket.
	interpreterProxy failed ifFalse: [
		self sqSocketDestroy: s]
]

{ #category : #'primitives - status' }
SocketPlugin >> primitiveSocketError: socket [

	| s err |
	<var: #s type: 'SocketPtr '>
	self primitive: 'primitiveSocketError'
		parameters: #(Oop).
	s := self socketValueOf: socket.
	interpreterProxy failed ifFalse: [
		err := self sqSocketError: s].
	^err asSmallIntegerObj
]

{ #category : #'primitives - status' }
SocketPlugin >> primitiveSocketLocalAddressType: socket [

	<var: #s type: 'SocketPtr'>

	| s |
	self primitive: 'primitiveSocketLocalAddressType' parameters: #(#Oop).

	s := self socketValueOf: socket.

	interpreterProxy failed ifFalse: [
		^ (self socketLocalAddressType: s) asSmallIntegerObj ].
	
	^ 0 asSmallIntegerObj
]

{ #category : #'primitives - sending/receiving' }
SocketPlugin >> primitiveSocketReceiveDataAvailable: socket [

	| s dataIsAvailable |
	<var: #s type: 'SocketPtr'>
	self primitive: 'primitiveSocketReceiveDataAvailable'
		parameters: #(Oop).
	s := self socketValueOf: socket.
	dataIsAvailable := self sqSocketReceiveDataAvailable: s.
	^dataIsAvailable asBooleanObj
]

{ #category : #'primitives - status' }
SocketPlugin >> primitiveSocketRemoteAddressType: socket [

	<var: #s type: 'SocketPtr'>

	| s |
	self primitive: 'primitiveSocketRemoteAddressType' parameters: #(#Oop).

	s := self socketValueOf: socket.

	interpreterProxy failed ifFalse: [
		^ (self socketRemoteAddressType: s) asSmallIntegerObj ].
	
	^ 0 asSmallIntegerObj
]

{ #category : #'primitives - status' }
SocketPlugin >> primitiveSocketSendDone: socket [

	| s done |
	<var: #s type: 'SocketPtr'>
	self primitive: 'primitiveSocketSendDone'
		parameters: #(Oop).
	s := self socketValueOf: socket.
	done := self sqSocketSendDone: s.
	^done asBooleanObj
]

{ #category : #'accessing - ip4' }
SocketPlugin >> setIp4Address: anAddressOop value: addr [

	<api>
	<returnTypeC: #void>
	<var: #naPtr type: 'unsigned char * '>

	| naPtr |
	naPtr := interpreterProxy firstIndexableField: (interpreterProxy fetchPointer: 1 ofObject: anAddressOop).
	naPtr at: 0 put: (self cCoerce: ((addr >> 24) bitAnd: 16rFF) to: 'char').
	naPtr at: 1 put: (self cCoerce: ((addr >> 16) bitAnd: 16rFF) to: 'char').
	naPtr at: 2 put: (self cCoerce: ((addr >> 8) bitAnd: 16rFF) to: 'char').
	naPtr at: 3 put: (self cCoerce: (addr bitAnd: 16rFF) to: 'char').

]

{ #category : #'accessing - ip4' }
SocketPlugin >> setIp4Port: anAddressOop value: aPort [

	<api>
	<returnTypeC: #void>

	"IPv4 Addresses are represented by an object with a smallinteger saying the address type (2 for IPv4), a 4 bytes bytearray as second instance variable, and a smallInteger as port number as third instance variable. If it does not have port the value is -1."

	^ interpreterProxy storeInteger: 2 ofObject: anAddressOop withValue: aPort

]

{ #category : #'initialize-release' }
SocketPlugin >> shutdownModule [
	<export: true>
	^self cCode: 'socketShutdown()' inSmalltalk:[true]
]

{ #category : #'for - simulation' }
SocketPlugin >> socket: s ConnectToAddress: addr Size: addrSize [

	<doNotGenerate>
	self subclassResponsibility
]

{ #category : #'for - simulation' }
SocketPlugin >> socketBindTo: s _: addr _: addrSize [

	<doNotGenerate>
	self subclassResponsibility
]

{ #category : #'for - simulation' }
SocketPlugin >> socketListenOn: s _: addr _: addrSize _: backlogSize [

	<doNotGenerate>
	self subclassResponsibility
]

{ #category : #primitives }
SocketPlugin >> socketRecordSize [
	"Return the size of a Smalltalk socket record in bytes."
	<inline: true>
	^ self sizeof: #SQSocket
]

{ #category : #primitives }
SocketPlugin >> socketValueOf: socketOop [ 
	"Answer a pointer to the first byte of of the socket record within the  
	 given Smalltalk object, or nil if socketOop is not a socket record."
	<returnTypeC: #SocketPtr>
	^((interpreterProxy isBytes: socketOop)
	   and: [(interpreterProxy byteSizeOf: socketOop) = self socketRecordSize])
		ifTrue: [self cCoerce: (interpreterProxy firstIndexableField: socketOop) to: #SocketPtr]
		ifFalse: [interpreterProxy primitiveFailFor: PrimErrBadArgument. nil]
]

{ #category : #'for - simulation' }
SocketPlugin >> sqNetworkInit: resolverSemaIndex [

	<doNotGenerate>

	self subclassResponsibility
]

{ #category : #'for - simulation' }
SocketPlugin >> sqSocketAbortConnection: s [

	<doNotGenerate>
	self subclassResponsibility
]

{ #category : #'for - simulation' }
SocketPlugin >> sqSocketCloseConnection: s [

	<doNotGenerate>
	self subclassResponsibility
]

{ #category : #'for - simulation' }
SocketPlugin >> sqSocketDestroy: socketPtr [

	<doNotGenerate>
	self subclassResponsibility
]

{ #category : #'accessing - ip4' }
SocketPlugin >> updateAddress: socketAddressOop from: addr [

	<returnTypeC: #'void'>
	<var: #addr type: #'void*'>

	| addressType |

	addressType := self getAddressType: socketAddressOop.
	addressType = 0 ifTrue: [ ^ self ].
	
	addressType = self ip4AddressType 
		ifTrue: [ ^ self ip4UpdateAddress: socketAddressOop _: addr ].
]
