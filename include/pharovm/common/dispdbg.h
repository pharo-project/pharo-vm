/*
 * Break-pointer debugging facilities for the StackInterpreter VM.
 * Edit this to install various debugging traps.  In a production
 * VM this header should define only the assert macros and empty
 * sendBreakpointreceiver and bytecodeDispatchDebugHook macros.
 */

#include "sqAssert.h"

#include "pharovm/debug.h"

#if !defined(VMBIGENDIAN)
# error "sqConfig.h does not define VMBIGENDIAN"
#elif !((VMBIGENDIAN == 1) || (VMBIGENDIAN == 0))
# error "sqConfig.h does not define VMBIGENDIAN as either 1 or 0"
#endif

/*
 * various definitions of the sendBreakpointreceiver macro for break-pointing at
 * specific sends.
 */
#if STACKVM
# define warnSendBreak() do { \
		suppressHeartbeatFlag = 1; \
		warning("send breakpoint (heartbeat suppressed)"); \
	} while (0)
# define warnMNUBreak() do { \
		suppressHeartbeatFlag = 1; \
		warning("MNU breakpoint (heartbeat suppressed)"); \
	} while (0)
#else
# define warnSendBreak() warning("send breakpoint")
# define warnMNUBreak() warning("MNU breakpoint")
#endif

#if PRODUCTION && !SENDTRACE /* default for no send breakpoint. */
# define sendBreakpointreceiver(sel, len, rcvr) 0
# define mnuBreakpointreceiver(sel, len, rcvr) 0

#elif SENDTRACE /* send tracing.  */
# define sendBreakpointreceiver(sel, len, rcvr) do { \
	if (sendTrace) \
		logTrace("%.*s\n", (int)(len), (char *)(sel)); \
} while (0)
# define mnuBreakpointreceiver(sel, len, rcvr) 0

#elif 0 /* send trace/byte count.  */
# define sendBreakpointreceiver(sel, len, rcvr) do { \
	if (sendTrace) \
		logTrace("%u %.*s\n", GIV(byteCount), (int)(len), (char *)(sel)); \
} while (0)
# define mnuBreakpointreceiver(sel, len, rcvr) 0

#else /* breakpoint for assert and debug configurations. */
# define sendBreakpointreceiver(sel, len, rcvr) do { \
	if ((len) == breakSelectorLength \
	 && !strncmp((char *)(sel), breakSelector, breakSelectorLength)) { \
		warnSendBreak(); \
		if (0) sendTrace = 1; \
	} \
	if (sendTrace) \
		logTrace("%.*s\n", (int)(len), (char *)(sel)); \
} while (0)
# define mnuBreakpointreceiver(sel, len, rcvr) do { \
	if ((len) == -breakSelectorLength \
	 && !strncmp((char *)(sel), breakSelector, -breakSelectorLength)) { \
		warnMNUBreak(); \
		if (0) sendTrace = 1; \
	} \
} while (0)

#endif

#define bytecodeDispatchDebugHook() 0
