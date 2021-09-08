/* squeak socket support header file */

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
sqInt sqSocketReceiveUDPDataBufCountaddressportmoreFlag(SocketPtr s, char *buf, sqInt bufSize,  sqInt *address,  sqInt *port, sqInt *moreFlag);
sqInt sqSockettoHostportSendDataBufCount(SocketPtr s, sqInt address, sqInt port, char *buf, sqInt bufSize);
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

sqInt sqSocketAddressSizeGetPort(char *addr, sqInt addrSize);
void  sqSocketAddressSizeSetPort(char *addr, sqInt addrSize, sqInt port);

void  sqResolverGetNameInfoSizeFlags(char *addr, sqInt addrSize, sqInt flags);
sqInt sqResolverGetNameInfoHostSize(void);
void  sqResolverGetNameInfoHostResultSize(char *name, sqInt nameSize);
sqInt sqResolverGetNameInfoServiceSize(void);
void  sqResolverGetNameInfoServiceResultSize(char *name, sqInt nameSize);

sqInt sqResolverHostNameSize(void);
void  sqResolverHostNameResultSize(char *name, sqInt nameSize);

sqInt sqSocketLocalAddressSize(SocketPtr s);
void  sqSocketLocalAddressResultSize(SocketPtr s, char *addr, int addrSize);
sqInt sqSocketRemoteAddressSize(SocketPtr s);
void  sqSocketRemoteAddressResultSize(SocketPtr s, char *addr, int addrSize);

void socketConnectToAddressSize(SocketPtr s, void* addr, size_t addrSize);
void socketListenOn(SocketPtr s, void* address, size_t addressSize, int backlogSize);
void socketBindTo(SocketPtr s, void *address, size_t addrSize);

void* newIP4SockAddr(int address, int port);
size_t ip4SockSize();

/* family */

#define SQ_SOCKET_FAMILY_UNSPECIFIED	0
#define SQ_SOCKET_FAMILY_LOCAL		1
#define SQ_SOCKET_FAMILY_INET4		2
#define SQ_SOCKET_FAMILY_INET6		3
#define SQ_SOCKET_FAMILY_MAX		4
