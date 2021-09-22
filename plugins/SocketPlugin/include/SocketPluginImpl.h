#pragma once

#ifdef _WIN32

 // Need to include winsock2 before windows.h
 // Windows.h will import otherwise winsock (1) and create conflicts
#include <winsock2.h>
#include <windows.h>
#include <Ws2tcpip.h>
#endif //WIN32

#include "pharovm/pharo.h"
#include "sq.h"
#include "SocketPlugin.h"
#include "sqaio.h"
#include "pharovm/debug.h"

#ifdef _WIN32

# include <sys/stat.h>

# include <stdio.h>

typedef unsigned int sa_family_t;

struct sockaddr_un
{
        sa_family_t sun_family;      /* AF_UNIX */
        char        sun_path[108];   /* pathname */
};

# define TCP_MAXSEG 536
# define S_IFSOCK   0xC000

# define socklen_t int

#else

# include <sys/param.h>
# include <sys/stat.h>
# include <sys/socket.h>
# include <sys/un.h>
# include <netinet/in.h>
# include <netinet/udp.h>
# include <netinet/tcp.h>
# include <arpa/inet.h>
# include <netdb.h>
# include <ifaddrs.h>

# define closesocket(x) close(x)
# define SD_SEND 	SHUT_WR
# define SD_RECEIVE 	SHUT_RD

#endif

# ifdef NEED_GETHOSTNAME_P
    extern int gethostname();
# endif
# ifdef HAVE_SYS_TIME_H
#   include <sys/time.h>
# else
#   include <time.h>
# endif
# include <errno.h>

#if !defined(_WIN32)
# include <unistd.h>
#endif

/* Solaris sometimes fails to define this in netdb.h */
#ifndef  MAXHOSTNAMELEN
# define MAXHOSTNAMELEN	256
#endif

#ifdef HAVE_SD_DAEMON
# include <systemd/sd-daemon.h>
#else
# define SD_LISTEN_FDS_START 3
# define sd_listen_fds(u) 0
#endif

#ifndef true
# define true 1
#endif

#ifndef false
# define false 0
#endif

extern struct VirtualMachine *interpreterProxy;

struct addressHeader
{
  int	sessionID;
  int	size;
};

int getNetSessionID();


#define AddressHeaderSize	sizeof(struct addressHeader)

#define addressHeader(A)	((struct addressHeader *)(A))
#define socketAddress(A)	((struct sockaddr *)((char *)(A) + AddressHeaderSize))

#define addressValid(A, S)	(getNetSessionID() && (getNetSessionID() == addressHeader(A)->sessionID) && (addressHeader(A)->size == ((S) - AddressHeaderSize)))
#define addressSize(A)		(addressHeader(A)->size)

void nameResolverInit(sqInt resolverSemaIndex);
void nameResolverFini();

void updateAddressObject(sqInt socketAddressOop, struct sockaddr_storage * sockaddr);
void updateSockAddressStruct(sqInt socketAddressOop, struct sockaddr_storage * sockaddr);
socklen_t sockAddressStructSize(struct sockaddr_storage* saddr);
