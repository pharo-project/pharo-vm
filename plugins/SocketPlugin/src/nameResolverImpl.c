#include "SocketPluginImpl.h"

/*** Resolver states ***/

#define ResolverUninitialised	0
#define ResolverSuccess		1
#define ResolverBusy		2
#define ResolverError		3


/*** Resolver state ***/

static char lastName[MAXHOSTNAMELEN+1];
static int  lastAddr= 0;
static int  lastError= 0;
static int  resolverSema= 0;

static char   localHostName[MAXHOSTNAMELEN];
static u_long localHostAddress;	/* GROSS IPv4 ASSUMPTION! */

static char hostNameInfo[MAXHOSTNAMELEN+1];
static char servNameInfo[MAXHOSTNAMELEN+1];

static int nameInfoValid= 0;


static struct addrinfo *addrList= 0;
static struct addrinfo *addrInfo= 0;
static struct addrinfo *localInfo= 0;

/* flags */

#define SQ_SOCKET_NUMERIC		(1<<0)
#define SQ_SOCKET_PASSIVE		(1<<1)

/* family */

#define SQ_SOCKET_FAMILY_UNSPECIFIED	0
#define SQ_SOCKET_FAMILY_LOCAL		1
#define SQ_SOCKET_FAMILY_INET4		2
#define SQ_SOCKET_FAMILY_INET6		3
#define SQ_SOCKET_FAMILY_MAX		4

/* type */

#define SQ_SOCKET_TYPE_UNSPECIFIED	0
#define SQ_SOCKET_TYPE_STREAM		1
#define SQ_SOCKET_TYPE_DGRAM		2
#define SQ_SOCKET_TYPE_MAX		3

/* protocol */

#define SQ_SOCKET_PROTOCOL_UNSPECIFIED	0
#define SQ_SOCKET_PROTOCOL_TCP		1
#define SQ_SOCKET_PROTOCOL_UDP		2
#define SQ_SOCKET_PROTOCOL_MAX		3

/* answer the hostname for the given IP address */

static const char *addrToName(int netAddress)
{
  u_long nAddr;
  struct hostent *he;

  lastError= 0;			/* for the resolver */
  nAddr= htonl(netAddress);
  if ((he= gethostbyaddr((char *)&nAddr, sizeof(nAddr), AF_INET)))
    return he->h_name;
  lastError= h_errno;		/* ditto */
  return "";
}

/* answer the IP address for the given hostname */

static int nameToAddr(char *hostName)
{
	struct addrinfo* result;
	struct addrinfo* anAddressInfo;
	int error;
	int address = 0;
	struct sockaddr_in* addr;


	/* resolve the domain name into a list of addresses */
   error = getaddrinfo(hostName, NULL, NULL, &result);
   if (error != 0) {
	   lastError = error;
	   return 0;
   }

   anAddressInfo = result;

   while(anAddressInfo && address == 0){

	   if(anAddressInfo->ai_family == AF_INET){
		   addr = (struct sockaddr_in *)anAddressInfo->ai_addr;
#ifdef _WIN32
		   address = ntohl(addr->sin_addr.S_un.S_addr);
#else
		   address = ntohl(addr->sin_addr.s_addr);
#endif
	   }

	   anAddressInfo = anAddressInfo->ai_next;
   }

   freeaddrinfo(result);

   return address;
}

/*** Resolver functions ***/


/* Note: the Mac and Win32 implementations implement asynchronous lookups
 * in the DNS.  I can't think of an easy way to do this in Unix without
 * going totally ott with threads or somesuch.  If anyone knows differently,
 * please tell me about it. - Ian
 */


/*** irrelevancies ***/

void sqResolverAbort(void) {}

void sqResolverStartAddrLookup(sqInt address)
{
  const char *res;
  res= addrToName(address);
  strncpy(lastName, res, MAXHOSTNAMELEN);
  logTrace( "startAddrLookup %s\n", lastName);
}


sqInt sqResolverStatus(void)
{
  if (!getNetSessionID())
    return ResolverUninitialised;
  if (lastError != 0)
    return ResolverError;
  return ResolverSuccess;
}

/*** trivialities ***/

sqInt sqResolverAddrLookupResultSize(void)	{ return strlen(lastName); }
sqInt sqResolverError(void)			{ return lastError; }
sqInt sqResolverLocalAddress(void) {

#ifndef _WIN32

	/*
	 * TODO: Check all this code, because is does not work if you have more than one network interface.
	 */

	struct ifaddrs *ifaddr, *ifa;
    int s;
    char host[NI_MAXHOST];
    sqInt localAddr = 0;

    if (getifaddrs(&ifaddr) == -1) {
        success(false);
        return 0;
    }


    for (ifa = ifaddr; ifa != NULL; ifa = ifa->ifa_next)
    {
        if (ifa->ifa_addr == NULL)
            continue;

        s=getnameinfo(ifa->ifa_addr,sizeof(struct sockaddr_in),host, NI_MAXHOST, NULL, 0, NI_NUMERICHOST);

        if(((strcmp(ifa->ifa_name,"eth0")==0)||(strcmp(ifa->ifa_name,"wlan0")==0))&&(ifa->ifa_addr->sa_family==AF_INET))
        {
            if (s != 0)
            {
                success(false);
                return 0;
            }
            logTrace( "\tInterface : <%s>\n",ifa->ifa_name );
            logTrace( "\t IP       : <%s>\n", inet_ntoa(((struct sockaddr_in *)(ifa->ifa_addr))->sin_addr));
            if(localAddr == 0) { /* take the first plausible answer */
                localAddr = ((struct sockaddr_in *)(ifa->ifa_addr))->sin_addr.s_addr;
            }

        }
    }

    freeifaddrs(ifaddr);
    return ntohl(localAddr);
#else

    static char localHostName[MAXHOSTNAMELEN];
    static u_long localHostAddress;

    sqInt address;

    gethostname(localHostName,MAXHOSTNAMELEN);

    return nameToAddr(localHostName);

#endif
}

sqInt sqResolverNameLookupResult(void)		{
	if(lastError != 0)
		success(false);

	return lastAddr; }

void
sqResolverAddrLookupResult(char *nameForAddress, sqInt nameSize) {
  memcpy(nameForAddress, lastName, nameSize);
}

/*** name resolution ***/

void
sqResolverStartNameLookup(char *hostName, sqInt nameSize) {
  int len= (nameSize < MAXHOSTNAMELEN) ? nameSize : MAXHOSTNAMELEN;
  memcpy(lastName, hostName, len);
  lastName[len]= lastError= 0;
  logTrace( "name lookup %s\n", lastName);
  lastAddr= nameToAddr(lastName);
  /* we're done before we even started */
  interpreterProxy->signalSemaphoreWithIndex(resolverSema);
}

#if 0
static void dumpAddr(struct sockaddr *addr, int addrSize)
{
  int i;
  for (i= 0;  i < addrSize;  ++i)
    logTrace("%02x ", ((unsigned char *)addr)[i]);
  logTrace(" ");
  switch (addr->sa_family)
    {
    case AF_UNIX:	logTrace("local\n"); break;
    case AF_INET:	logTrace("inet\n"); break;
    case AF_INET6:	logTrace("inet6\n"); break;
    default:		logTrace("?\n"); break;
    }
}
#endif

sqInt sqResolverGetAddressInfoSize(void)
{
  if (!addrInfo)
    return -1;
  return AddressHeaderSize + addrInfo->ai_addrlen;
}


void sqResolverGetAddressInfoResultSize(char *addr, sqInt addrSize)
{
  if ((!addrInfo) || (addrSize < (AddressHeaderSize + addrInfo->ai_addrlen)))
    {
      success(false);
      return;
    }

  addressHeader(addr)->sessionID= getNetSessionID();

  addressHeader(addr)->size=      addrInfo->ai_addrlen;
  memcpy(socketAddress(addr), addrInfo->ai_addr, addrInfo->ai_addrlen);
  /*dumpAddr(socketAddress(addr), addrSize - AddressHeaderSize);*/
}

/* ---- address and service lookup ---- */


void sqResolverGetAddressInfoHostSizeServiceSizeFlagsFamilyTypeProtocol(char *hostName, sqInt hostSize, char *servName, sqInt servSize,
									sqInt flags, sqInt family, sqInt type, sqInt protocol)
{
  char host[MAXHOSTNAMELEN+1], serv[MAXHOSTNAMELEN+1];
  struct addrinfo request;
  int gaiError= 0;

  logTrace( "GetAddressInfo %ld %ld %ld %ld %ld %ld\n", hostSize, servSize, flags, family, type, protocol);

  if (addrList)
    {
      freeaddrinfo(addrList);
      addrList= addrInfo= 0;
    }

  if (localInfo)
    {
      free(localInfo->ai_addr);
      free(localInfo);
      localInfo= addrInfo= 0;
    }

  if ((!getNetSessionID())
      || (hostSize < 0) || (hostSize > MAXHOSTNAMELEN)
      || (servSize < 0) || (servSize > MAXHOSTNAMELEN)
      || (family   < 0) || (family   >= SQ_SOCKET_FAMILY_MAX)
      || (type     < 0) || (type     >= SQ_SOCKET_TYPE_MAX)
      || (protocol < 0) || (protocol >= SQ_SOCKET_PROTOCOL_MAX))
    goto fail;

  if (hostSize)
    memcpy(host, hostName, hostSize);
  host[hostSize]= '\0';

  if (servSize)
    memcpy(serv, servName, servSize);
  serv[servSize]= '\0';

  logTrace( "  -> GetAddressInfo %s %s\n", host, serv);

  if (servSize && (family == SQ_SOCKET_FAMILY_LOCAL) && (servSize < sizeof(((struct sockaddr_un *)0)->sun_path)) && !(flags & SQ_SOCKET_NUMERIC))
    {
      struct stat st;
      if ((0 == stat(servName, &st)) && (st.st_mode & S_IFSOCK))
	{
	  struct sockaddr_un *saun= calloc(1, sizeof(struct sockaddr_un));
	  localInfo= (struct addrinfo *)calloc(1, sizeof(struct addrinfo));
	  localInfo->ai_family= AF_UNIX;
	  localInfo->ai_socktype= SOCK_STREAM;
	  localInfo->ai_addrlen= sizeof(struct sockaddr_un);
	  localInfo->ai_addr= (struct sockaddr *)saun;
	  /*saun->sun_len= sizeof(struct sockaddr_un);*/
	  saun->sun_family= AF_UNIX;
	  memcpy(saun->sun_path, servName, servSize);
	  saun->sun_path[servSize]= '\0';
	  addrInfo= localInfo;
	  interpreterProxy->signalSemaphoreWithIndex(resolverSema);
	  return;
	}
    }

  memset(&request, 0, sizeof(request));

  if (flags & SQ_SOCKET_NUMERIC)	request.ai_flags |= AI_NUMERICHOST;
  if (flags & SQ_SOCKET_PASSIVE)	request.ai_flags |= AI_PASSIVE;

  switch (family)
    {
    case SQ_SOCKET_FAMILY_LOCAL:	request.ai_family= AF_UNIX;		break;
    case SQ_SOCKET_FAMILY_INET4:	request.ai_family= AF_INET;		break;
    case SQ_SOCKET_FAMILY_INET6:	request.ai_family= AF_INET6;		break;
    }

  switch (type)
    {
    case SQ_SOCKET_TYPE_STREAM:		request.ai_socktype= SOCK_STREAM;	break;
    case SQ_SOCKET_TYPE_DGRAM:		request.ai_socktype= SOCK_DGRAM;	break;
    }

  switch (protocol)
    {
    case SQ_SOCKET_PROTOCOL_TCP:	request.ai_protocol= IPPROTO_TCP;	break;
    case SQ_SOCKET_PROTOCOL_UDP:	request.ai_protocol= IPPROTO_UDP;	break;
    }

  gaiError= getaddrinfo(hostSize ? host : 0, servSize ? serv : 0, &request, &addrList);

  if (gaiError)
    {
      /* Linux gives you either <netdb.h> with   correct NI_* bit definitions and no  EAI_* definitions at all
	 or                <bind/netdb.h> with incorrect NI_* bit definitions and the EAI_* definitions we need.
	 We cannot distinguish between impossible constraints and genuine lookup failure, so err conservatively. */
#    if defined(EAI_BADHINTS)
      if (EAI_BADHINTS != gaiError)
	{
	  logTrace("getaddrinfo: %s\n", gai_strerror(gaiError));
	  lastError= gaiError;
	  goto fail;
	}
#    else
      logTrace("getaddrinfo: %s\n", gai_strerror(gaiError));
#    endif
      addrList= 0;	/* succeed with zero results for impossible constraints */
    }

  addrInfo= addrList;
  interpreterProxy->signalSemaphoreWithIndex(resolverSema);
  return;

 fail:
  success(false);
  return;
}

sqInt sqResolverGetAddressInfoFamily(void)
{
  if (!addrInfo)
    {
      success(false);
      return 0;
    }

  switch (addrInfo->ai_family)
    {
    case AF_UNIX:	return SQ_SOCKET_FAMILY_LOCAL;
    case AF_INET:	return SQ_SOCKET_FAMILY_INET4;
    case AF_INET6:	return SQ_SOCKET_FAMILY_INET6;
    }

  return SQ_SOCKET_FAMILY_UNSPECIFIED;
}


sqInt sqResolverGetAddressInfoType(void)
{
  if (!addrInfo)
    {
      success(false);
      return 0;
    }

  switch (addrInfo->ai_socktype)
    {
    case SOCK_STREAM:	return SQ_SOCKET_TYPE_STREAM;
    case SOCK_DGRAM:	return SQ_SOCKET_TYPE_DGRAM;
    }

  return SQ_SOCKET_TYPE_UNSPECIFIED;
}


sqInt sqResolverGetAddressInfoProtocol(void)
{
  if (!addrInfo)
    {
      success(false);
      return 0;
    }

  switch (addrInfo->ai_protocol)
    {
    case IPPROTO_TCP:	return SQ_SOCKET_PROTOCOL_TCP;
    case IPPROTO_UDP:	return SQ_SOCKET_PROTOCOL_UDP;
    }

 return SQ_SOCKET_PROTOCOL_UNSPECIFIED;
}


sqInt sqResolverGetAddressInfoNext(void)
{
  return (addrInfo && (addrInfo= addrInfo->ai_next)) ? true : false;
}


void sqResolverGetNameInfoSizeFlags(char *addr, sqInt addrSize, sqInt flags)
{
  int niFlags= 0;
  int gaiError= 0;

  logTrace( "GetNameInfoSizeFlags %p %ld %ld\n", addr, addrSize, flags);

  nameInfoValid= 0;

  if (!addressValid(addr, addrSize))
    goto fail;

  niFlags |= NI_NOFQDN;

  if (flags & SQ_SOCKET_NUMERIC) niFlags |= (NI_NUMERICHOST | NI_NUMERICSERV);

  /*dumpAddr(socketAddress(addr), addrSize - AddressHeaderSize);  logTrace("%02x\n", niFlags);*/

  gaiError= getnameinfo(socketAddress(addr), addrSize - AddressHeaderSize,
			hostNameInfo, sizeof(hostNameInfo),
			servNameInfo, sizeof(servNameInfo),
			niFlags);

  if (gaiError)
    {
      logTrace("getnameinfo: %s\n", gai_strerror(gaiError));
      lastError= gaiError;
      goto fail;
    }

  nameInfoValid= 1;
  interpreterProxy->signalSemaphoreWithIndex(resolverSema);
  return;

 fail:
  success(false);
}


sqInt sqResolverGetNameInfoHostSize(void)
{
  if (!nameInfoValid)
    {
      success(false);
      return 0;
    }
  return strlen(hostNameInfo);
}


void sqResolverGetNameInfoHostResultSize(char *name, sqInt nameSize)
{
  int len;

  if (!nameInfoValid)
    goto fail;

  len= strlen(hostNameInfo);
  if (nameSize < len)
    goto fail;

  memcpy(name, hostNameInfo, len);
  return;

 fail:
  success(false);
}


sqInt sqResolverGetNameInfoServiceSize(void)
{
  if (!nameInfoValid)
    {
      success(false);
      return 0;
    }
  return strlen(servNameInfo);
}


void sqResolverGetNameInfoServiceResultSize(char *name, sqInt nameSize)
{
  int len;

  if (!nameInfoValid)
    goto fail;

  len= strlen(servNameInfo);
  if (nameSize < len)
    goto fail;

  memcpy(name, servNameInfo, len);
  return;

 fail:
  success(false);
}


sqInt sqResolverHostNameSize(void)
{
  char buf[MAXHOSTNAMELEN+1];
  if (gethostname(buf, sizeof(buf)))
    {
      success(false);
      return 0;
    }
  return strlen(buf);
}


void sqResolverHostNameResultSize(char *name, sqInt nameSize)
{
  char buf[MAXHOSTNAMELEN+1];
  int len;
  if (gethostname(buf, sizeof(buf)) || (nameSize < (len= strlen(buf))))
    {
      success(false);
      return;
    }
  memcpy(name, buf, len);
}

void nameResolverInit(sqInt resolverSemaIndex){
  gethostname(localHostName, MAXHOSTNAMELEN);
  localHostAddress = nameToAddr(localHostName);
  resolverSema = resolverSemaIndex;
}

void nameResolverFini(){
  resolverSema = 0;
}
