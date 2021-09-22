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
void  sqSocketCreateNetTypeSocketTypeRecvBytesSendBytesSemaIDReadSemaIDWriteSemaID(SocketPtr s, sqInt netType, sqInt socketType, sqInt recvBufSize, sqInt sendBufSize, sqInt semaIndex, sqInt readSemaIndex, sqInt writeSemaIndex);
void  sqSocketCreateRawProtoTypeRecvBytesSendBytesSemaIDReadSemaIDWriteSemaID(SocketPtr s, sqInt domain, sqInt protocol, sqInt recvBufSize, sqInt sendBufSize, sqInt semaIndex, sqInt readSemaIndex, sqInt writeSemaIndex);
void  sqSocketDestroy(SocketPtr s);
sqInt sqSocketError(SocketPtr s);
sqInt sqSocketReceiveDataAvailable(SocketPtr s);
sqInt sqSocketReceiveDataBufCount(SocketPtr s, char *buf, sqInt bufSize);
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

void socketConnectToAddress(SocketPtr s, sqInt socketAddressOop);
void socketListenOn(SocketPtr s, sqInt socketAddressOop, int backlogSize);
void socketBindTo(SocketPtr s, sqInt socketAddressOop);
sqInt socketSendUDPDataToAddress(SocketPtr s, sqInt socketAddressOop, char* buffer, size_t bufferLength);
sqInt socketReceiveUDPData(SocketPtr s, char *buf, sqInt bufSize, sqInt socketAddressOop);

void socketLocalAddress(SocketPtr s, sqInt socketAddressOop);
void socketRemoteAddress(SocketPtr s, sqInt socketAddressOop);

sqInt resolverLocalInterfaces(sqInt anArrayOop);
sqInt resolverLocalName();

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

