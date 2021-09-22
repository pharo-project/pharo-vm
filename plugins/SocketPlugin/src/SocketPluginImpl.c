#include "SocketPluginImpl.h"

/*** Socket types ***/

#define TCPSocketType			0 /* SOCK_STREAM on AF_INET or AF_INET6 */
#define UDPSocketType			1 /* SOCK_DGRAM on AF_INET or AF_INET6 */
#define RAWSocketType			2 /* SOCK_RAW on AF_INET or AF_INET6 */
#define SeqPacketSocketType		3 /* SOCK_SEQPACKET on AF_INET or AF_INET6 */
#define ReliableDGramSocketType	4 /* SOCK_RDM on AF_INET or AF_INET6 */

#define ReuseExistingSocket		65536

#define ProvidedTCPSocketType		(TCPSocketType + ReuseExistingSocket)
#define ProvidedUDPSocketType		(UDPSocketType + ReuseExistingSocket)
#define ProvidedRAWSocketType		(RAWSocketType + ReuseExistingSocket)
#define ProvidedSeqPacketSocketType	(SeqPacketSocketType + ReuseExistingSocket)
#define ProvidedReliableDGramSocketType	(ReliableDGramSocketType + ReuseExistingSocket)

/*** TCP Socket states ***/

#define Invalid					-1
#define Unconnected		 		0
#define WaitingForConnection	1
#define Connected		 		2
#define OtherEndClosed		 	3
#define ThisEndClosed		 	4

#define LINGER_SECS		 		1

volatile static int thisNetSession = 0;
static int one = 1;

/*
 * The ERROR constants are different in Windows and in Unix.
 * We have to use the correct ones if not, the errors are not correctly detected.
 */

#ifdef _WIN32
# define ERROR_IN_PROGRESS	WSAEINPROGRESS
# define ERROR_WOULD_BLOCK	WSAEWOULDBLOCK
#else
# define ERROR_IN_PROGRESS	EINPROGRESS
# define ERROR_WOULD_BLOCK	EWOULDBLOCK
#endif


typedef struct privateSocketStruct
{
  int s;			/* Unix socket */
  int connSema;			/* connection io notification semaphore */
  int readSema;			/* read io notification semaphore */
  int writeSema;		/* write io notification semaphore */
  int sockState;		/* connection + data state */
  int sockError;		/* errno after socket error */
  struct sockaddr_storage peer;	/* default send/recv address for UDP */
  int multiListen;		/* whether to listen for multiple connections */
  int acceptedSock;		/* a connection that has been accepted */
  int socketType;
} privateSocketStruct;

#define CONN_NOTIFY		(1<<0)
#define READ_NOTIFY		(1<<1)
#define WRITE_NOTIFY	(1<<2)

#define PING(S,EVT)						\
{								\
  logTrace("notify %d %s\n", (S)->s, #EVT);		\
  interpreterProxy->signalSemaphoreWithIndex((S)->EVT##Sema);	\
}

#define notify(SOCK,MASK)						\
{									\
  if ((MASK) & CONN_NOTIFY)  PING(SOCK,conn);				\
  if ((MASK) & READ_NOTIFY)  PING(SOCK,read);				\
  if ((MASK) & WRITE_NOTIFY) PING(SOCK,write);				\
}


#define _PSP(S)		(((S)->privateSocketPtr))
#define PSP(S)		((privateSocketStruct *)((S)->privateSocketPtr))

#define SOCKET(S)		(PSP(S)->s)
#define SOCKETSTATE(S)		(PSP(S)->sockState)
#define SOCKETERROR(S)		(PSP(S)->sockError)
#define SOCKETPEER(S)		(PSP(S)->peer)


/*** Variables ***/

#if !defined(SQUEAK_BUILTIN_PLUGIN)
# define success(bool) interpreterProxy->success(bool)
#endif
int setHookFn;


static void acceptHandler(int, void *, int);
static void connectHandler(int, void *, int);
static void dataHandler(int, void *, int);
static void closeHandler(int, void *, int);

/**
 * The Error reporting is different in Windows and in Unix, so we need to provide a function.
 */

int getLastSocketError(){
#ifdef _WIN32
	return WSAGetLastError();
#else
	return errno;
#endif
}


#ifdef AIO_DEBUG
char *socketHandlerName(aioHandler h)
{
  if (h == acceptHandler)     return "acceptHandler";
  if (h == connectHandler)    return "connectHandler";
  if (h == dataHandler)       return "dataHandler";
  if (h == closeHandler)      return "closeHandler";
  return "***unknownHandler***";
}
#endif


/*** module initialisation/shutdown ***/

#ifdef _WIN32
static WSADATA wsaData;
#endif


sqInt socketInit(void)
{

#ifdef _WIN32

	if(WSAStartup( MAKEWORD(2,0), &wsaData ) != 0)
		return -1;

#endif
  return 1;
}

sqInt socketShutdown(void)
{
  /* shutdown the network */
  sqNetworkShutdown();
  return 1;
}


/***      miscellaneous sundries           ***/

/* set linger on a connected stream */

static void setLinger(int fd, int flag)
{
  struct linger linger= { flag, flag * LINGER_SECS };
  setsockopt(fd, SOL_SOCKET, SO_LINGER, (char *)&linger, sizeof(linger));
}

/* answer whether the given socket is valid in this net session */

static int socketValid(SocketPtr s)
{
  if (s && s->privateSocketPtr && getNetSessionID() && (s->sessionID == getNetSessionID()))
    return true;
  success(false);
  return false;
}

/* answer 1 if the given socket is readable,
          0 if read would block, or
         -1 if the socket is no longer connected */

static int socketReadable(int s, int type)
{
  static char buf[100];
  int error;
  sqInt n;

  if(type == UDPSocketType) {
	  n = recvfrom(s, (void*)buf, 100, MSG_PEEK, NULL, NULL);
  }else{
	  n = recv(s, (void *)buf, 100, MSG_PEEK);
  }

  if (n > 0) return 1;
  if ((n < 0) && ((error = getLastSocketError()) == ERROR_WOULD_BLOCK)) return 0;

#ifdef _WIN32
  /*
   * In Windows we can receive an error that the buffer is
   * not big enough. This situation leads to know that there is data to read.
   */

  if ((n < 0) && (error == WSAEMSGSIZE)) return 1;
#endif

  return -1;	/* EOF */
}


/* answer whether the socket can be written without blocking */

static int socketWritable(int s)
{
  struct timeval tv= { 0, 0 };
  fd_set fds;
  
  FD_ZERO(&fds);
  FD_SET(s, &fds);

  return select(s+1, 0, &fds, 0, &tv) > 0;
}

/* answer the error condition on the given socket */

static int socketError(int s)
{
  int error= 0;
  socklen_t errsz= sizeof(error);
  
  if(getsockopt(s, SOL_SOCKET, SO_ERROR, (void *)&error, &errsz) == -1){
	  logWarnFromErrno("getsockopt");
	  return -1;
  };

  return error;
}


/***     asynchronous io handlers       ***/


/* accept() can now be performed for the socket: call accept(),
   and replace the server socket with the new client socket
   leaving the client socket unhandled
*/
static void acceptHandler(int fd, void *data, int flags)
{
  int lastError;
    
  privateSocketStruct *pss= (privateSocketStruct *)data;
  logTrace("acceptHandler(%d, %p ,%d)\n", fd, data, flags);
  if (flags & AIO_X) /* -- exception */
    {
      /* error during listen() */
      aioDisable(fd);
      pss->sockError= socketError(fd);
      pss->sockState= Invalid;
      pss->s= -1;
      closesocket(fd);
      logTrace("acceptHandler: aborting server %d pss=%p\n", fd, pss);
    }
  else /* (flags & AIO_R) -- accept() is ready */
    {
      int newSock= accept(fd, 0, 0);
      if (newSock < 0)
	{
	  if ((lastError = getLastSocketError()) == ECONNABORTED)
	    {
	      /* let's just pretend this never happened */
	      aioHandle(fd, acceptHandler, AIO_RX);
	      return;
	    }
	  /* something really went wrong */
	  pss->sockError= lastError;
	  pss->sockState= Invalid;
	  logWarnFromErrno("acceptHandler");
	  aioDisable(fd);
	  closesocket(fd);
	  logTrace("acceptHandler: aborting server %d pss=%p\n", fd, pss);
	}
      else /* newSock >= 0 -- connection accepted */
	{
	  pss->sockState= Connected;
	  setLinger(newSock, 1);
	  if (pss->multiListen)
	    {
	      pss->acceptedSock= newSock;
	    }
	  else /* traditional listen -- replace server with client in-place */
	    {
	      aioDisable(fd);
	      closesocket(fd);
	      pss->s= newSock;
	      aioEnable(newSock, pss, 0);
	    }
	}
    }
  notify(pss, CONN_NOTIFY);
}


/* connect() has completed: check errors, leaving the socket unhandled */

static void connectHandler(int fd, void *data, int flags)
{

  int error;

  privateSocketStruct *pss= (privateSocketStruct *)data;
  logTrace("connectHandler(%d, %p, %d)\n", fd, data, flags);
  
  // If AIO called us but the socket was already resolved, just return
  // Avoids race condition of the AIO
  if (pss->sockState != WaitingForConnection) {
    // Disable the FD again just in case
    aioDisable(fd);
    return;
  }

  error = socketError(fd);

  if (flags & AIO_X) /* -- exception */
  {
    /* error during asynchronous connect() */
    aioDisable(fd);

    logTrace("AIO_X, SocketError: %d", error);

    pss->sockError= error;
    pss->sockState= Unconnected;
    logWarnFromErrno("connectHandler");
  } else /* (flags & AIO_W) -- connect completed */
  {
    /* connect() has completed */
    logTrace("!AIO_X, SocketError: %d", error);

    if (error) {
      aioDisable(fd);
      logTrace("connectHandler: error %d (%s)\n", error, strerror(error));
	    pss->sockError= error;
	    pss->sockState= Unconnected;
	  } else {
      pss->sockState= Connected;
      setLinger(pss->s, 1);
	  }
  }
  notify(pss, CONN_NOTIFY);
}


/* read or write data transfer is now possible for the socket. */

static void dataHandler(int fd, void *data, int flags)
{
  privateSocketStruct *pss= (privateSocketStruct *)data;
  logTrace("dataHandler(%d=%d, %p, %d)\n", fd, pss->s, data, flags);

  if (pss == NULL)
    {
      logTrace("dataHandler: pss is NULL fd=%d data=%p flags=0x%x\n", fd, data, flags);
      return;
    }

  if (flags & AIO_R)
    {
      int n= socketReadable(fd, pss->socketType);
      if (n == 0)
	{
	  logTrace("dataHandler: selected socket fd=%d flags=0x%x would block (why?)\n", fd, flags);
	}
      if (n != 1)
	{
	  pss->sockError= socketError(fd);
	  pss->sockState= OtherEndClosed;
	}
    }
  if (flags & AIO_X)
    {
      /* assume out-of-band data has arrived */
      /* NOTE: Squeak's socket interface is currently incapable of reading
       *       OOB data.  We have no choice but to discard it.  Ho hum. */
      char buf[1];
      int n= recv(fd, (void *)buf, 1, MSG_OOB);
      if (n == 1) logTrace("socket: received OOB data: %02x\n", buf[0]);
    }
  if (flags & AIO_R) notify(pss, READ_NOTIFY);
  if (flags & AIO_W) notify(pss, WRITE_NOTIFY);
}


/* a non-blocking close() has completed -- finish tidying up */

static void closeHandler(int fd, void *data, int flags)
{
  privateSocketStruct *pss= (privateSocketStruct *)data;
  aioDisable(fd);
  logTrace("closeHandler(%d, %p, %d)\n", fd, data, flags);
  pss->sockState= Unconnected;
  pss->s= -1;
  notify(pss, READ_NOTIFY | CONN_NOTIFY);
}


int getNetSessionID(){
	return thisNetSession;
}

/* start a new network session */

sqInt sqNetworkInit(sqInt resolverSemaIndex)
{
  if (0 != getNetSessionID())
    return 0;  /* already initialised */

  nameResolverInit(resolverSemaIndex);

  thisNetSession = clock() + time(0);

  if (0 == getNetSessionID())
	  thisNetSession = 1;  /* 0 => uninitialised */

  return 0;
}


/* terminate the current network session (invalidates all open sockets) */

void sqNetworkShutdown(void)
{
	thisNetSession= 0;
	nameResolverFini();
	aioFini();
}


void sqSocketCreateNetTypeSocketTypeRecvBytesSendBytesSemaIDReadSemaIDWriteSemaID(SocketPtr s, sqInt domain, sqInt socketType, sqInt recvBufSize, sqInt sendBufSize, sqInt semaIndex, sqInt readSemaIndex, sqInt writeSemaIndex)
{
  int newSocket= -1;
  privateSocketStruct *pss;

  switch (domain)
    {
    case SOCKET_FAMILY_UNSPECIFIED:	domain= AF_INET;	break;
    case SOCKET_FAMILY_LOCAL:		domain= AF_UNIX;	break;
    case SOCKET_FAMILY_INET4:		domain = AF_INET;	break;
    case SOCKET_FAMILY_INET6:		domain = AF_INET6;	break;
    }

  s->sessionID= 0;
  if (TCPSocketType == socketType)
    {
      /* --- TCP --- */
      newSocket= socket(domain, SOCK_STREAM, 0);
    }
  else if (UDPSocketType == socketType)
    {
      /* --- UDP --- */
      newSocket= socket(domain, SOCK_DGRAM, 0);
    }
  else if (ProvidedTCPSocketType == socketType)
    {
      /* --- Existing socket --- */
      if (sd_listen_fds(0) == 0)
        {
          socketType = TCPSocketType;
          newSocket= SD_LISTEN_FDS_START + 0;
        }
      else
        {
          success(false);
          return;
        }
    }
  if (-1 == newSocket)
    {
      /* socket() failed, or incorrect socketType */
      success(false);
      return;
    }
  setsockopt(newSocket, SOL_SOCKET, SO_REUSEADDR, (char *)&one, sizeof(one));
  /* private socket structure */
  pss= (privateSocketStruct *)calloc(1, sizeof(privateSocketStruct));
  if (pss == NULL)
    {
      logTrace("acceptFrom: out of memory\n");
      success(false);
      return;
    }
  pss->s= newSocket;
  pss->connSema= semaIndex;
  pss->readSema= readSemaIndex;
  pss->writeSema= writeSemaIndex;
  pss->socketType = socketType;

  /* UDP sockets are born "connected" */
  if (UDPSocketType == socketType)
    {
      pss->sockState= Connected;
      aioEnable(pss->s, pss, 0);
    }
  else
    {
      pss->sockState= Unconnected;
    }
  pss->sockError= 0;
  /* initial UDP peer := wildcard */
  memset(&pss->peer, 0, sizeof(pss->peer));

  struct sockaddr_in * sin = (struct sockaddr_in *)&pss->peer;

  sin->sin_family= AF_INET;
  sin->sin_port= 0;
  sin->sin_addr.s_addr= INADDR_ANY;

  s->sessionID= getNetSessionID();
  s->socketType= socketType;
  s->privateSocketPtr= pss;
  logTrace("create(%d) -> %lx\n", SOCKET(s), (unsigned long)PSP(s));
  /* Note: socket is in BLOCKING mode until aioEnable is called for it! */
}

void sqSocketCreateRawProtoTypeRecvBytesSendBytesSemaIDReadSemaIDWriteSemaID(SocketPtr s, sqInt domain, sqInt protocol, sqInt recvBufSize, sqInt sendBufSize, sqInt semaIndex, sqInt readSemaIndex, sqInt writeSemaIndex)
{
  int newSocket= -1;
  privateSocketStruct *pss;

  s->sessionID= 0;
  switch(protocol) {
	case 1: newSocket = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP); break;
  }
  if (-1 == newSocket)
    {
      /* socket() failed, or incorrect protocol type */
      logTrace("primSocketCreateRAW: socket() failed; protocol = %ld, errno = %d\n", protocol, errno);
      success(false);
      return;
    }

  /* private socket structure */
  pss= (privateSocketStruct *)calloc(1, sizeof(privateSocketStruct));
  if (pss == NULL)
    {
      logTrace("acceptFrom: out of memory\n");
      success(false);
      return;
    }
  pss->s= newSocket;
  pss->connSema= semaIndex;
  pss->readSema= readSemaIndex;
  pss->writeSema= writeSemaIndex;
  pss->socketType=s->socketType;

  /* RAW sockets are born "connected" */
  pss->sockState= Connected;
  aioEnable(pss->s, pss, 0);
  pss->sockError= 0;
  /* initial UDP peer := wildcard */
  struct sockaddr_in * sin = (struct sockaddr_in *)&pss->peer;

  sin->sin_family= AF_INET;
  sin->sin_port= 0;
  sin->sin_addr.s_addr= INADDR_ANY;

  s->sessionID= getNetSessionID();
  s->socketType= RAWSocketType;
  s->privateSocketPtr= pss;
  logTrace("create(%d) -> %lx\n", SOCKET(s), (unsigned long)PSP(s));
  /* Note: socket is in BLOCKING mode until aioEnable is called for it! */
}


/* return the state of a socket */

sqInt sqSocketConnectionStatus(SocketPtr s)
{
  if (!socketValid(s))
    return Invalid;
  /* we now know that the net session is valid, so if state is Invalid... */
  if (SOCKETSTATE(s) == Invalid)	/* see acceptHandler() */
    {
      logTrace("socketStatus: freeing invalidated pss=%p\n", PSP(s));
      /*free(PSP(s));*/	/* this almost never happens -- safer not to free()?? */
      _PSP(s)= 0;
      success(false);
      return Invalid;
    }
  logTrace("socketStatus(%d) -> %d\n", SOCKET(s), SOCKETSTATE(s));
  return SOCKETSTATE(s);
}

void sqSocketAcceptFromRecvBytesSendBytesSemaIDReadSemaIDWriteSemaID(SocketPtr s, SocketPtr serverSocket, sqInt recvBufSize, sqInt sendBufSize, sqInt semaIndex, sqInt readSemaIndex, sqInt writeSemaIndex)
{
  /* The image has already called waitForConnection, so there is no
     need to signal the server's connection semaphore again. */

  struct privateSocketStruct *pss;

  logTrace("acceptFrom(%p, %d)\n", s, SOCKET(serverSocket));

  /* sanity checks */
  if (!socketValid(serverSocket) || !PSP(serverSocket)->multiListen)
    {
      logTrace("accept failed: (multi->%d)\n", PSP(serverSocket)->multiListen);
      success(false);
      return;
    }

  /* check that a connection is there */
  if (PSP(serverSocket)->acceptedSock < 0)
    {
      logTrace("acceptFrom: no socket available\n");
      success(false);
      return;
    }

  /* got connection -- fill in the structure */
  s->sessionID= 0;
  pss= (privateSocketStruct *)calloc(1, sizeof(privateSocketStruct));
  if (pss == NULL)
    {
      logTrace("acceptFrom: out of memory\n");
      success(false);
      return;
    }

  _PSP(s)= pss;
  pss->s= PSP(serverSocket)->acceptedSock;
  PSP(serverSocket)->acceptedSock= -1;
  SOCKETSTATE(serverSocket)= WaitingForConnection;
  aioHandle(SOCKET(serverSocket), acceptHandler, AIO_RX);
  s->sessionID= getNetSessionID();
  pss->connSema= semaIndex;
  pss->readSema= readSemaIndex;
  pss->writeSema= writeSemaIndex;
  pss->sockState= Connected;
  pss->sockError= 0;

  pss->socketType = s->socketType;

  aioEnable(SOCKET(s), PSP(s), 0);
}


/* close the socket */

void sqSocketCloseConnection(SocketPtr s)
{
  int result= 0;

  if (!socketValid(s))
    return;

  logTrace("closeConnection(%d)\n", SOCKET(s));

  if (SOCKET(s) < 0)
    return;	/* already closed */

  SOCKETSTATE(s)= ThisEndClosed;
  result = closesocket(SOCKET(s));
  int lastError = getLastSocketError();

  if ((result == -1) && (lastError != ERROR_WOULD_BLOCK))
    {
      /* error */
      SOCKETSTATE(s)= Unconnected;
      SOCKETERROR(s)= lastError;
      aioDisable(SOCKET(s));

      notify(PSP(s), CONN_NOTIFY);
      logWarnFromErrno("closeConnection");
    }
  else if (0 == result)
    {
      /* close completed synchronously */
      SOCKETSTATE(s)= Unconnected;
      aioDisable(SOCKET(s));

      logTrace("closeConnection: disconnected\n");
      SOCKET(s)= -1;
    }
  else
    {
      /* asynchronous close in progress */

	  shutdown(SOCKET(s), SD_SEND);

      SOCKETSTATE(s)= ThisEndClosed;
      aioHandle(SOCKET(s), closeHandler, AIO_RWX);  /* => close() done */
      logTrace("closeConnection: deferred [aioHandle is set]\n");
    }
}


/* close the socket without lingering */

void sqSocketAbortConnection(SocketPtr s)
{
  logTrace("abortConnection(%d)\n", SOCKET(s));
  if (!socketValid(s))
    return;
  setLinger(SOCKET(s), 0);
  sqSocketCloseConnection(s);
}


/* Release the resources associated with this socket. 
   If a connection is open, abort it. */

void sqSocketDestroy(SocketPtr s)
{
  if (!socketValid(s))
    return;

  logTrace("destroy(%d)\n", SOCKET(s));

  if (SOCKET(s))
    sqSocketAbortConnection(s);		/* close if necessary */

  if (PSP(s))
    free(PSP(s));			/* release private struct */

  _PSP(s)= 0;
}


/* answer the OS error code for the last socket operation */

sqInt sqSocketError(SocketPtr s)
{
  if (!socketValid(s))
    return -1;
  return SOCKETERROR(s);
}


/* answer whether the socket has data available for reading:
   if the socket is not connected, answer "false";
   if the socket is open and data can be read, answer "true".
   if the socket is open and no data is currently readable, answer "false";
   if the socket is closed by peer, change the state to OtherEndClosed
	and answer "false";
*/
sqInt sqSocketReceiveDataAvailable(SocketPtr s)
{
  if (!socketValid(s)) return false;
  if (SOCKETSTATE(s) == Connected)
    {
      int fd= SOCKET(s);
      int n=  socketReadable(fd, s->socketType);
      if (n > 0)
	{
	  logTrace( "receiveDataAvailable(%d) -> true\n", fd);
	  return true;
	}
      else if (n < 0)
	{
	  logTrace( "receiveDataAvailable(%d): other end closed\n", fd);
	  SOCKETSTATE(s)= OtherEndClosed;
	}
    }
  else /* (SOCKETSTATE(s) != Connected) */
    {
      logTrace( "receiveDataAvailable(%d): socket not connected\n", SOCKET(s));
    }

  aioHandle(SOCKET(s), dataHandler, AIO_RX);
  logTrace( "receiveDataAvailable(%d) -> false [aioHandle is set]\n", SOCKET(s));
  return false;
}


/* answer whether the socket has space to receive more data */

sqInt sqSocketSendDone(SocketPtr s)
{
  if (!socketValid(s))
    return false;
  if (SOCKETSTATE(s) == Connected)
    {
      if (socketWritable(SOCKET(s))) return true;
      aioHandle(SOCKET(s), dataHandler, AIO_WX);
    }
  return false;
}


/* read data from the socket s into buf for at most bufSize bytes.
   answer the number actually read.  For UDP, fill in the peer's address
   with the approriate value.
*/
sqInt sqSocketReceiveDataBufCount(SocketPtr s, char *buf, sqInt bufSize) {
	int nread = 0;
	int lastError;

	if (!socketValid(s))
		return -1;

	if (TCPSocketType != s->socketType) {
		/* --- UDP/RAW --- */
		socklen_t addrSize = sizeof(SOCKETPEER(s));
		if ((nread = recvfrom(SOCKET(s), buf, bufSize, 0,
				(struct sockaddr *) &SOCKETPEER(s), &addrSize)) <= 0) {

			lastError = getLastSocketError();

			if ((nread == -1) && (lastError == ERROR_WOULD_BLOCK)) {
				logTrace("UDP receiveData(%d) < 1 [blocked]\n", SOCKET(s));
				return 0;
			}
			SOCKETERROR(s) = lastError;
			logTrace("UDP receiveData(%d) < 1 [a:%d]\n", SOCKET(s), lastError);
			return 0;
		}
	} else {
		/* --- TCP --- */
		if ((nread = recv(SOCKET(s), buf, bufSize, 0)) <= 0) {
			lastError = getLastSocketError();

			if ((nread == -1) && (lastError == ERROR_WOULD_BLOCK)) {
				logTrace("TCP receiveData(%d) < 1 [blocked]\n", SOCKET(s));
				return 0;
			}
			/* connection reset */
			SOCKETSTATE(s) = OtherEndClosed;
			SOCKETERROR(s) = lastError;
			logTrace("TCP receiveData(%d) < 1 [b:%d] return: %d", SOCKET(s),
					lastError, nread);
			notify(PSP(s), CONN_NOTIFY);
			return 0;
		}
	}
	/* read completed synchronously */
	logTrace("receiveData(%d) done = %d\n", SOCKET(s), nread);
	return nread;
}


/* write data to the socket s from buf for at most bufSize bytes.
   answer the number of bytes actually written.
*/ 
sqInt sqSocketSendDataBufCount(SocketPtr s, char *buf, sqInt bufSize)
{
  int nsent= 0;
  int lastError;

  if (!socketValid(s))
    return -1;

  if (TCPSocketType != s->socketType)
    {
      /* --- UDP/RAW --- */
      logTrace( "UDP sendData(%d, %ld)\n", SOCKET(s), bufSize);
      if ((nsent= sendto(SOCKET(s), buf, bufSize, 0, (struct sockaddr *)&SOCKETPEER(s), sizeof(SOCKETPEER(s)))) <= 0)
	{
      lastError = getLastSocketError();
      int err = lastError;
	  if (err == ERROR_WOULD_BLOCK)	/* asynchronous write in progress */
	    return 0;
	  logTrace( "UDP send failed %d %s\n", err, strerror(err));
	  SOCKETERROR(s)= err;
	  return 0;
	}
    }
  else
    {
      /* --- TCP --- */
      logTrace( "TCP sendData(%d, %ld)\n", SOCKET(s), bufSize);
      if ((nsent= send(SOCKET(s), buf, bufSize, 0)) <= 0)
	{
      lastError = getLastSocketError();
	  if ((nsent == -1) && (lastError == ERROR_WOULD_BLOCK))
	    {
	      logTrace( "TCP sendData(%d, %ld) -> %d [blocked]",
		       SOCKET(s), bufSize, nsent);
	      return 0;
	    }
	  else
	    {
	      /* error: most likely "connection closed by peer" */
	      SOCKETSTATE(s)= OtherEndClosed;
	      SOCKETERROR(s)= lastError;
          logWarn("errno %d\n", lastError);
          logWarnFromErrno("write");

	      return 0;
	    }
	}
    }
  /* write completed synchronously */
  logTrace( "sendData(%d) done = %d\n", SOCKET(s), nsent);
  return nsent;
}


/*** socket options ***/


typedef struct
{
  char *name;		/* name as known to Squeak */
  int   optlevel;	/* protocol level */
  int   optname;	/* name as known to Unix */
} socketOption;

#ifndef SOL_IP
# define SOL_IP IPPROTO_IP
#endif

#ifndef SOL_UDP
# define SOL_UDP IPPROTO_UDP
#endif

#ifndef SOL_TCP
# define SOL_TCP IPPROTO_TCP
#endif

static socketOption socketOptions[]= {
  { "SO_DEBUG",				SOL_SOCKET,	SO_DEBUG },
  { "SO_REUSEADDR",			SOL_SOCKET,	SO_REUSEADDR },
  { "SO_DONTROUTE",			SOL_SOCKET,	SO_DONTROUTE },
  { "SO_BROADCAST",			SOL_SOCKET,	SO_BROADCAST },
  { "SO_SNDBUF",			SOL_SOCKET,	SO_SNDBUF },
  { "SO_RCVBUF",			SOL_SOCKET,	SO_RCVBUF },
  { "SO_KEEPALIVE",			SOL_SOCKET,	SO_KEEPALIVE },
  { "SO_OOBINLINE",			SOL_SOCKET,	SO_OOBINLINE },
  { "SO_LINGER",			SOL_SOCKET,	SO_LINGER },
  { "IP_TTL",				SOL_IP,		IP_TTL },
  { "IP_HDRINCL",			SOL_IP,		IP_HDRINCL },
  { "IP_MULTICAST_IF",			SOL_IP,		IP_MULTICAST_IF },
  { "IP_MULTICAST_TTL",			SOL_IP,		IP_MULTICAST_TTL },
  { "IP_MULTICAST_LOOP",		SOL_IP,		IP_MULTICAST_LOOP },
#ifdef IP_ADD_MEMBERSHIP
  { "IP_ADD_MEMBERSHIP",		SOL_IP,		IP_ADD_MEMBERSHIP },
  { "IP_DROP_MEMBERSHIP",		SOL_IP,		IP_DROP_MEMBERSHIP },
#endif
  { "TCP_MAXSEG",			SOL_TCP,	TCP_MAXSEG },
  { "TCP_NODELAY",			SOL_TCP,	TCP_NODELAY },
#ifdef TCP_CORK
  { "TCP_CORK",		        SOL_TCP,	TCP_CORK },
#endif
#ifdef SO_REUSEPORT
  { "SO_REUSEPORT",			SOL_SOCKET,	SO_REUSEPORT },
#endif
#if 0 /*** deliberately unsupported options -- do NOT enable these! ***/
  { "SO_PRIORITY",			SOL_SOCKET,	SO_PRIORITY },
  { "SO_RCVLOWAT",			SOL_SOCKET,	SO_RCVLOWAT },
  { "SO_SNDLOWAT",			SOL_SOCKET,	SO_SNDLOWAT },
  { "IP_RCVOPTS",			SOL_IP,		IP_RCVOPTS },
  { "IP_RCVDSTADDR",			SOL_IP,		IP_RCVDSTADDR },
  { "UDP_CHECKSUM",			SOL_UDP,	UDP_CHECKSUM },
  { "TCP_ABORT_THRESHOLD",		SOL_TCP,	TCP_ABORT_THRESHOLD },
  { "TCP_CONN_NOTIFY_THRESHOLD",	SOL_TCP,	TCP_CONN_NOTIFY_THRESHOLD },
  { "TCP_CONN_ABORT_THRESHOLD",		SOL_TCP,	TCP_CONN_ABORT_THRESHOLD },
  { "TCP_NOTIFY_THRESHOLD",		SOL_TCP,	TCP_NOTIFY_THRESHOLD },
  { "TCP_URGENT_PTR_TYPE",		SOL_TCP,	TCP_URGENT_PTR_TYPE },
#endif
  { (char *)0,				0,		0 }
};


static socketOption *findOption(char *name, size_t nameSize)
{
  if (nameSize < 32)
    {
      socketOption *opt= 0;
      char buf[32];
      buf[nameSize]= '\0';
      strncpy(buf, name, nameSize);
      for (opt= socketOptions; opt->name != 0; ++opt)
	if (!strcmp(buf, opt->name))
	  return opt;
      logTrace("SocketPlugin: ignoring unknown option '%s'\n", buf);
    }
  return 0;
}


/* set the given option for the socket.  the option comes in as a
 * String.  (why on earth we might think this a good idea eludes me
 * ENTIRELY, so... if the string doesn't smell like an integer then we
 * copy it verbatim, assuming it's really a ByteArray pretending to be
 * a struct.  caveat hackor.)
 */
sqInt sqSocketSetOptionsoptionNameStartoptionNameSizeoptionValueStartoptionValueSizereturnedValue(SocketPtr s, char *optionName, sqInt optionNameSize, char *optionValue, sqInt optionValueSize, sqInt *result)
{
  if (socketValid(s))
    {
      socketOption *opt= findOption(optionName, (size_t)optionNameSize);
      if (opt != 0)
	{
#ifdef _WIN32
	  ULONG   val= 0;
#else
	  int val=0;
#endif
	  char  buf[32];
	  char *endptr;
	  /* this is JUST PLAIN WRONG (I mean the design in the image rather
	     than the implementation here, which is probably correct
	     w.r.t. the broken design) */
	  if (optionValueSize > sizeof(buf) - 1)
	    goto barf;

	  memset((void *)buf, 0, sizeof(buf));
	  memcpy((void *)buf, optionValue, optionValueSize);
	  if (optionValueSize <= sizeof(int)
	   && (strtol(buf, &endptr, 0),
	       endptr - buf == optionValueSize)) /* are all option chars digits? */
	    {
	      val= strtol(buf, &endptr, 0);
		  memcpy((void *)buf, (void *)&val, sizeof(val));
		  optionValueSize= sizeof(val);
	    }
	  if ((setsockopt(PSP(s)->s, opt->optlevel, opt->optname,
			  (const void *)buf, optionValueSize)) < 0)
	    {
		  logWarnFromErrno("setsockopt");
	      goto barf;
	    }
	  /* it isn't clear what we're supposed to return here, since
	     setsockopt isn't supposed to have any value-result parameters
	     (go grok that `const' on the buffer argument if you don't
	     believe me).  the image says "the result of the negotiated
	     value".  what the fuck is there to negotiate?  either
	     setsockopt sets the value or it barfs.  and i'm not about to go
	     calling getsockopt just to see if the value got changed or not
	     (the image should send getOption: to the Socket if it really
	     wants to know).  if the following is wrong then I could
	     probably care (a lot) less...  fix the logic in the image and
	     then maybe i'll care about fixing the logic in here.  (i know
	     that isn't very helpful, but it's 05:47 in the morning and i'm
	     severely grumpy after fixing several very unpleasant bugs that
	     somebody introduced into this file while i wasn't looking.)  */
	  *result= val;
	  return 0;
	}
    }
 barf:
  success(false);
  return false;
}


/* query the socket for the given option.  */
sqInt sqSocketGetOptionsoptionNameStartoptionNameSizereturnedValue(SocketPtr s, char *optionName, sqInt optionNameSize, sqInt *result)
{
  if (socketValid(s)) {
	  socketOption *opt= findOption(optionName, (size_t)optionNameSize);

	  if (opt != 0) {
		  int optval;	/* NOT sqInt */
		  socklen_t optlen= sizeof(optval);

		  if (((getsockopt(PSP(s)->s, opt->optlevel, opt->optname, (void *)&optval, &optlen)) < 0) || optlen != sizeof(optval)){
			  success(false);
			  return getLastSocketError();
		  }

		  *result = optval;

		  return 0;
	  }
  }

  success(false);
  return -1;
}

void sqSocketSetReusable(SocketPtr s)
{
  size_t bufSize;
  unsigned char buf[8];

  if (!socketValid(s)) return;

  *(sqInt *)buf= 1;
  bufSize= 8;
  if (setsockopt(SOCKET(s), SOL_SOCKET, SO_REUSEADDR, buf, bufSize) < 0)
    {
      PSP(s)->sockError= getLastSocketError();
      success(false);
      return;
    }
}

void socketListenOn(SocketPtr s, sqInt socketAddressOop, int backlogSize) {

	struct sockaddr_storage saddr;
	socklen_t saddrSize;
	int lastError;

	if (!socketValid(s))
		return;

	/* only TCP sockets have a backlog */
	if ((backlogSize > 1) && (s->socketType != TCPSocketType)) {
		success(false);
		return;
	}

	updateSockAddressStruct(socketAddressOop, &saddr);
	if(interpreterProxy->failed()){
		return;
	}

	saddrSize = sockAddressStructSize(&saddr);

	PSP(s)->multiListen = (backlogSize > 1);
	logTrace("listenOnPortBacklogSize(%d, %ld)\n", SOCKET(s), backlogSize);

	lastError = bind(SOCKET(s), (struct sockaddr *) &saddr, saddrSize);

	if(lastError == -1){
		logWarnFromErrno("Bind");
	}

	if (TCPSocketType == s->socketType) {
		/* --- TCP --- */
		listen(SOCKET(s), backlogSize);
		SOCKETSTATE(s) = WaitingForConnection;
		aioEnable(SOCKET(s), PSP(s), 0);
		aioHandle(SOCKET(s), acceptHandler, AIO_RX); /* R => accept() */
	} else {
		/* --- UDP/RAW --- */
	}
}

void socketBindTo(SocketPtr s, sqInt socketAddressOop) {

	struct sockaddr_storage saddr;
	socklen_t saddrSize;

	privateSocketStruct *pss = PSP(s);

	if (!socketValid(s)){
		success(false);
		return;
	}

	updateSockAddressStruct(socketAddressOop, &saddr);
	saddrSize = sockAddressStructSize(&saddr);

	if(interpreterProxy->failed()){
		return;
	}

	if (bind(SOCKET(s), (struct sockaddr *)&saddr, saddrSize) == 0)
		return;

	pss->sockError = getLastSocketError();
	success(false);
}


void socketConnectToAddress(SocketPtr s, sqInt socketAddressOop){

	/* TCP => open a connection.
	 * UDP => set remote address.
	 */

	struct sockaddr_storage saddr;
	socklen_t saddrSize;


	if (!socketValid(s)) {
		success(false);
		return;
	}

	logTrace("connectToAddressSize(%d)\n", SOCKET(s));

	updateSockAddressStruct(socketAddressOop, &saddr);
	if(interpreterProxy->failed()){
		return;
	}

	saddrSize = sockAddressStructSize(&saddr);

	if (TCPSocketType != s->socketType) {

		/* --- UDP/RAW --- */

		if (SOCKET(s) >= 0) {

			int result;

			memcpy((void *) &SOCKETPEER(s), (struct sockaddr *)&saddr, saddrSize);

			result = connect(SOCKET(s), (struct sockaddr *)&saddr, saddrSize);

			if (result == 0)
				SOCKETSTATE(s) = Connected;
		}
	} else /* --- TCP --- */
	{
		int result;
		aioEnable(SOCKET(s), PSP(s), 0);
		result = connect(SOCKET(s), (struct sockaddr *)&saddr, saddrSize);

		logTrace("connect() => %d\n", result);

		if (result == 0) {
			/* connection completed synchronously */
			logWarnFromErrno("sqConnectToPort");
			logWarn("LastSocketError: %d", getLastSocketError());

			SOCKETSTATE(s) = Connected;
			notify(PSP(s), CONN_NOTIFY);
			setLinger(SOCKET(s), 1);
		} else {
			int lastError = getLastSocketError();
			if (lastError == ERROR_IN_PROGRESS || lastError == ERROR_WOULD_BLOCK) {
				/* asynchronous connection in progress */
				SOCKETSTATE(s) = WaitingForConnection;
				aioHandle(SOCKET(s), connectHandler, AIO_WX); /* W => connect() */
			} else {
				/* connection error */
				logWarnFromErrno("sqConnectToAddressSize");
				SOCKETSTATE(s) = Unconnected;
				SOCKETERROR(s) = errno;
				notify(PSP(s), CONN_NOTIFY);
			}
		}
	}
}

sqInt socketSendUDPDataToAddress(SocketPtr s, sqInt socketAddressOop, char* buffer, size_t bufferLength) {

	struct sockaddr_storage saddr;
	socklen_t saddrSize;

	if (socketValid(s) && (TCPSocketType != s->socketType)) {

		updateSockAddressStruct(socketAddressOop, &saddr);
		if(interpreterProxy->failed()){
			return 0;
		}

		saddrSize = sockAddressStructSize(&saddr);

		logTrace("sendTo(%d)\n", SOCKET(s));

		int nsent = sendto(SOCKET(s), buffer, bufferLength, 0, (struct sockaddr *)&saddr, saddrSize);

		if (nsent >= 0)
			return nsent;

		int lastError = getLastSocketError();

		if (lastError == ERROR_WOULD_BLOCK) /* asynchronous write in progress */
			return 0;

		logTrace("UDP send failed\n");
		SOCKETERROR(s) = lastError;
	}

	success(false);
	return 0;
}

sqInt socketReceiveUDPData(SocketPtr s, char *buf, sqInt bufSize, sqInt socketAddressOop) {
	int lastError;
	struct sockaddr_storage saddr;
	socklen_t saddrSize = sizeof(struct sockaddr_storage);

	if (socketValid(s) && (TCPSocketType != s->socketType)) /* --- UDP/RAW --- */
	{
		logTrace("recvFrom(%d)\n", SOCKET(s));

		int nread = recvfrom(SOCKET(s), buf, bufSize, 0, (struct sockaddr *)&saddr, &saddrSize);

		if (nread >= 0) {
			updateAddressObject(socketAddressOop, &saddr);
			return nread;
		}

		lastError = getLastSocketError();

		if (lastError == ERROR_WOULD_BLOCK) /* asynchronous read in progress */
			return 0;

		SOCKETERROR(s) = lastError;
		logTrace("receiveData(%d)= %da\n", SOCKET(s), 0);
	}
	success(false);
	return 0;
}

void socketLocalAddress(SocketPtr s, sqInt socketAddressOop){
	struct sockaddr_storage sockaddr;
	socklen_t socklen = sizeof(struct sockaddr_storage);


	if(!socketValid(s)) {
		success(false);
		return;
	}

	memset((void*)&sockaddr, 0, socklen);

	if(getsockname(SOCKET(s), (struct sockaddr*)&sockaddr, &socklen)==-1){
		SOCKETERROR(s) = getLastSocketError();
		logTrace("socketRemoteAddress(%d)= %da\n", SOCKET(s), 0);

		success(false);
		return;
	}

	updateAddressObject(socketAddressOop, &sockaddr);
}

void socketRemoteAddress(SocketPtr s, sqInt socketAddressOop){
	struct sockaddr_storage sockaddr;
	socklen_t socklen = sizeof(struct sockaddr_storage);


	if(!socketValid(s)) {
		success(false);
		return;
	}

	memset((void*)&sockaddr, 0, socklen);

	/* If it is UDP/RAW I will use the peersocket stored before */

	if (s->socketType != TCPSocketType){
		updateAddressObject(socketAddressOop, &SOCKETPEER(s));
		return;
	}


	if(getpeername(SOCKET(s), (struct sockaddr*)&sockaddr, &socklen)==-1){
		SOCKETERROR(s) = getLastSocketError();
		logTrace("socketRemoteAddress(%d)= %da\n", SOCKET(s), 0);

		if(SOCKETERROR(s) == ENOTCONN){
			// If the socket is not connected we return all 0.0.0.0
			return;
		}

		success(false);
		return;
	}

	updateAddressObject(socketAddressOop, &sockaddr);
}

/*
 * Handling different address kinds
 *
 * Addresses are represented by an object with:
 *
 * - A SmallInteger to identify the type of address (check translateSocketType to know the valid values)
 * - A ByteArray with the address information if it is a IPv4 or IPv6, and a byteArray encoded in utf8 if it is a unix socket
 * - A SmallInteger with the port (if non unix address).
 */

static sqInt translateToSocketDomain(sqInt type) {
	switch (type) {
		case SOCKET_FAMILY_UNSPECIFIED:
			return AF_UNSPEC;
		case SOCKET_FAMILY_LOCAL:
			return AF_UNIX;
		case SOCKET_FAMILY_INET4:
			return AF_INET;
		case SOCKET_FAMILY_INET6:
			return AF_INET6;
		default:
			logDebug("Invalid SocketFamily: %d", type);
			success(false);
			return AF_UNSPEC;
	}
}

static sqInt translateSocketType(sa_family_t sa_family){

	switch(sa_family){
		case AF_UNSPEC:
			return SOCKET_FAMILY_UNSPECIFIED;

		case AF_UNIX:
			return SOCKET_FAMILY_LOCAL;

		case AF_INET:
			return SOCKET_FAMILY_INET4;

		case AF_INET6:
			return SOCKET_FAMILY_INET6;

		default: return -1;
	}
}


void updateAddressObject(sqInt socketAddressOop, struct sockaddr_storage * sockaddr){

	sqInt addressInformation;
	sqInt portNumber;
	struct sockaddr_un* unixSocketAddress = (struct sockaddr_un*)sockaddr;
	struct sockaddr_in* ipv4SocketAddress = (struct sockaddr_in*)sockaddr;
	struct sockaddr_in6* ipv6SocketAddress = (struct sockaddr_in6*)sockaddr;

	if(interpreterProxy->slotSizeOf(socketAddressOop) < 3){
		success(false);
		return;
	}

	sqInt addressLength = strlen(unixSocketAddress->sun_path);

	switch(sockaddr->ss_family){
		case AF_UNIX:

			addressInformation = interpreterProxy->instantiateClassindexableSize(interpreterProxy->classByteArray(), addressLength);

			if(interpreterProxy->failed()){
				logDebug("Cannot allocate ByteArray of size %d", addressLength);
				return;
			}

			memcpy(interpreterProxy->firstIndexableField(addressInformation), unixSocketAddress->sun_path, addressLength);
			portNumber = interpreterProxy->integerObjectOf(0);
			break;

		case AF_INET:

			addressInformation = interpreterProxy->instantiateClassindexableSize(interpreterProxy->classByteArray(), sizeof(ipv4SocketAddress->sin_addr.s_addr));

			if(interpreterProxy->failed()){
				logDebug("Cannot allocate ByteArray of size %ld", sizeof(ipv4SocketAddress->sin_addr.s_addr));
				return;
			}

			memcpy(interpreterProxy->firstIndexableField(addressInformation), &(ipv4SocketAddress->sin_addr.s_addr), sizeof(ipv4SocketAddress->sin_addr.s_addr));
			portNumber = interpreterProxy->integerObjectOf(ntohs(ipv4SocketAddress->sin_port));
			break;

		case AF_INET6:

			addressInformation = interpreterProxy->instantiateClassindexableSize(interpreterProxy->classByteArray(), sizeof(ipv6SocketAddress->sin6_addr));

			if(interpreterProxy->failed()){
				logDebug("Cannot allocate ByteArray of size %ld", sizeof(ipv6SocketAddress->sin6_addr));
				return;
			}

			memcpy(interpreterProxy->firstIndexableField(addressInformation), &(ipv6SocketAddress->sin6_addr), sizeof(ipv4SocketAddress->sin_addr.s_addr));
			portNumber = interpreterProxy->integerObjectOf(ntohs(ipv6SocketAddress->sin6_port));
			break;

		default:
			addressInformation = interpreterProxy->nilObject();
			portNumber = interpreterProxy->integerObjectOf(0);
	}

	interpreterProxy->storeIntegerofObjectwithValue(0, socketAddressOop, translateSocketType(sockaddr->ss_family));
	interpreterProxy->storePointerofObjectwithValue(1, socketAddressOop, addressInformation);
	interpreterProxy->storePointerofObjectwithValue(2, socketAddressOop, portNumber);
}

void updateSockAddressStruct(sqInt socketAddressOop, struct sockaddr_storage * sockaddr){

	struct sockaddr_un* unixSocketAddress = (struct sockaddr_un*)sockaddr;
	struct sockaddr_in* ipv4SocketAddress = (struct sockaddr_in*)sockaddr;
	struct sockaddr_in6* ipv6SocketAddress = (struct sockaddr_in6*)sockaddr;

	char buffer[256];

	memset((void*)sockaddr, 0, sizeof(struct sockaddr_storage));

	if(interpreterProxy->slotSizeOf(socketAddressOop) < 3){
		success(false);
		return;
	}

	sqInt domain = translateToSocketDomain(interpreterProxy->fetchIntegerofObject(0, socketAddressOop));
	sqInt addressInformation = interpreterProxy->fetchPointerofObject(1, socketAddressOop);
	sqInt portNumber = interpreterProxy->fetchIntegerofObject(2, socketAddressOop);

	if(interpreterProxy->failed()){
		return;
	}

	if(!interpreterProxy->isBytes(addressInformation)){
		logDebug("Address Information in the SocketAddress is not indexable");
		success(false);
		return;
	}

	sqInt addressInformationSize = interpreterProxy->byteSizeOf(addressInformation);

	switch(domain){
		case AF_UNIX:
			unixSocketAddress->sun_family = AF_UNIX;
			memcpy(unixSocketAddress->sun_path, interpreterProxy->firstIndexableField(addressInformation), addressInformationSize);
			unixSocketAddress->sun_path[addressInformationSize] = '\0';
			break;

		case AF_INET:

			if(addressInformationSize != sizeof(ipv4SocketAddress->sin_addr.s_addr)){
				logDebug("Invalid information in the socketAddress, expecting %ld bytes for IPv4", sizeof(ipv4SocketAddress->sin_addr.s_addr));
				success(false);
				return;
			}

			ipv4SocketAddress->sin_family = AF_INET;
			memcpy(&(ipv4SocketAddress->sin_addr.s_addr), interpreterProxy->firstIndexableField(addressInformation), sizeof(ipv4SocketAddress->sin_addr.s_addr));
			ipv4SocketAddress->sin_port = htons((short)portNumber);

			inet_ntop(AF_INET, &(ipv4SocketAddress->sin_addr), buffer, 256);
			logTrace("Ip4 Address: %s", buffer);
			break;

		case AF_INET6:

			if(addressInformationSize != sizeof(ipv6SocketAddress->sin6_addr)){
				logDebug("Invalid information in the socketAddress, expecting %ld bytes for IPv6", sizeof(ipv6SocketAddress->sin6_addr));
				success(false);
				return;
			}

			ipv6SocketAddress->sin6_family = AF_INET6;
			memcpy(&(ipv6SocketAddress->sin6_addr), interpreterProxy->firstIndexableField(addressInformation), sizeof(ipv6SocketAddress->sin6_addr));
			ipv6SocketAddress->sin6_port = htons((short)portNumber);
			break;

		default:
			logError("Invalid domain type: %d", domain);
			success(false);
			return;
	}
}

socklen_t sockAddressStructSize(struct sockaddr_storage* saddr){
	switch(saddr->ss_family){
		case AF_UNIX: return sizeof(struct sockaddr_un);
		case AF_INET: return sizeof(struct sockaddr_in);
		case AF_INET6: return sizeof(struct sockaddr_in6);
		default:
			return -1;
	}
}
