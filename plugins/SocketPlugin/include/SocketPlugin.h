#pragma once

/* module initialization/shutdown */
sqInt socketInit(void);
sqInt socketShutdown(void);

typedef struct
{
  int	sessionID;
  int	socketType;  /* 0 = TCP, 1 = UDP */
  void	*privateSocketPtr;
}  SQSocket, *SocketPtr;

/* networking primitives */
sqInt sqNetworkInit(sqInt resolverSemaIndex);
void  sqNetworkShutdown(void);
void  sqResolverAbort(void);
void  sqResolverAddrLookupResult(char *nameForAddress, sqInt nameSize);
sqInt sqResolverAddrLookupResultSize(void);
sqInt sqResolverError(void);
sqInt sqResolverLocalAddress(void);
sqInt sqResolverNameLookupResult(void);
void  sqResolverStartAddrLookup(sqInt address);
void  sqResolverStartNameLookup(char *hostName, sqInt nameSize);
sqInt sqResolverStatus(void);
void  sqSocketAbortConnection(SocketPtr s);
void  sqSocketCloseConnection(SocketPtr s);
sqInt sqSocketConnectionStatus(SocketPtr s);
void  sqSocketConnectToPort(SocketPtr s, sqInt addr, sqInt port);
void  sqSocketCreateNetTypeSocketTypeRecvBytesSendBytesSemaIDReadSemaIDWriteSemaID(SocketPtr s, sqInt netType, sqInt socketType, sqInt recvBufSize, sqInt sendBufSize, sqInt semaIndex, sqInt readSemaIndex, sqInt writeSemaIndex);
void  sqSocketCreateRawProtoTypeRecvBytesSendBytesSemaIDReadSemaIDWriteSemaID(SocketPtr s, sqInt domain, sqInt protocol, sqInt recvBufSize, sqInt sendBufSize, sqInt semaIndex, sqInt readSemaIndex, sqInt writeSemaIndex);
void  sqSocketDestroy(SocketPtr s);
sqInt sqSocketError(SocketPtr s);
sqInt sqSocketLocalAddress(SocketPtr s);
sqInt sqSocketLocalPort(SocketPtr s);
sqInt sqSocketReceiveDataAvailable(SocketPtr s);
sqInt sqSocketReceiveDataBufCount(SocketPtr s, char *buf, sqInt bufSize);
sqInt sqSocketRemoteAddress(SocketPtr s);
sqInt sqSocketRemotePort(SocketPtr s);
sqInt sqSocketSendDataBufCount(SocketPtr s, char *buf, sqInt bufSize);
sqInt sqSocketSendDone(SocketPtr s);
void  sqSocketAcceptFromRecvBytesSendBytesSemaIDReadSemaIDWriteSemaID(SocketPtr s, SocketPtr serverSocket, sqInt recvBufSize, sqInt sendBufSize, sqInt semaIndex, sqInt readSemaIndex, sqInt writeSemaIndex);
sqInt sqSocketSetOptionsoptionNameStartoptionNameSizeoptionValueStartoptionValueSizereturnedValue(SocketPtr s, char *optionName, sqInt optionNameSize, char *optionValue, sqInt optionValueSize, sqInt *result);
sqInt sqSocketGetOptionsoptionNameStartoptionNameSizereturnedValue(SocketPtr s, char *optionName, sqInt optionNameSize, sqInt *result);
void sqSocketSetReusable(SocketPtr s);

void  sqResolverGetAddressInfoHostSizeServiceSizeFlagsFamilyTypeProtocol(char *hostName, sqInt hostSize, char *servName, sqInt servSize,
																		 sqInt flags, sqInt family, sqInt type, sqInt protocol);
sqInt sqResolverGetAddressInfoSize(void);
void  sqResolverGetAddressInfoResultSize(char *addr, sqInt addrSize);
sqInt sqResolverGetAddressInfoFamily(void);
sqInt sqResolverGetAddressInfoType(void);
sqInt sqResolverGetAddressInfoProtocol(void);
sqInt sqResolverGetAddressInfoNext(void);

void  sqResolverGetNameInfoSizeFlags(char *addr, sqInt addrSize, sqInt flags);
sqInt sqResolverGetNameInfoHostSize(void);
void  sqResolverGetNameInfoHostResultSize(char *name, sqInt nameSize);
sqInt sqResolverGetNameInfoServiceSize(void);
void  sqResolverGetNameInfoServiceResultSize(char *name, sqInt nameSize);

sqInt sqResolverHostNameSize(void);
void  sqResolverHostNameResultSize(char *name, sqInt nameSize);

void socketConnectToAddressSize(SocketPtr s, void* addr, size_t addrSize);
void socketListenOn(SocketPtr s, void* address, size_t addressSize, int backlogSize);
void socketBindTo(SocketPtr s, void *address, size_t addrSize);
sqInt socketSendUDPDataToAddress(SocketPtr s, void* address, size_t addrSize, char* buffer, size_t bufferLength);
sqInt socketReceiveUDPData(SocketPtr s, char *buf, sqInt bufSize, void * address, size_t addrSize);

void* newIP4SockAddr(int address, int port);
size_t ip4SockSize();

void setIp4Addressvalue(sqInt addressOop, sqInt address);
void setIp4Portvalue(sqInt addressOop, sqInt port);
void ip4UpdateAddress(sqInt addressOop, void* addr);


/* family */

#define SOCKET_FAMILY_UNSPECIFIED	0
#define SOCKET_FAMILY_LOCAL			1
#define SOCKET_FAMILY_INET4			2
#define SOCKET_FAMILY_INET6			3
#define SOCKET_FAMILY_MAX			4

/* flags */

#define SOCKET_NUMERIC			(1<<0)
#define SOCKET_PASSIVE			(1<<1)

/* type */

#define SOCKET_TYPE_UNSPECIFIED		0
#define SOCKET_TYPE_STREAM			1
#define SOCKET_TYPE_DGRAM			2
#define SOCKET_TYPE_MAX				3

/* protocol */

#define SOCKET_PROTOCOL_UNSPECIFIED	0
#define SOCKET_PROTOCOL_TCP			1
#define SOCKET_PROTOCOL_UDP			2
#define SOCKET_PROTOCOL_MAX			3

