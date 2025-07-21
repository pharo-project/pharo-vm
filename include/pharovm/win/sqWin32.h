/* Generic OS identifying and sub-system selecting include for _WIN32, _WIN64
 * and _WINCE
 */
#ifndef SQ_WIN_32_H
#define SQ_WIN_32_H


/*************************************************************/
/* NOTE: For a list of possible definitions see file README. */
/*************************************************************/

#ifdef _MSC_VER
/* disable "function XXXX: no return value" */
#pragma warning(disable:4035)
/* optional C SEH macros */
# define TRY __try
# define EXCEPT(filter) __except(filter)
# define FINALLY __finally
#else
/* optional C SEH macros */
# define TRY
# define EXCEPT(filter) if (0)
# define FINALLY
#endif

#ifdef _WIN32_WCE
/*************************************************************/
/*                          Windows CE                       */
/*************************************************************/

#ifndef SEEK_SET
#	define SEEK_SET	0
#endif
#ifndef SEEK_CUR
#	define SEEK_CUR	1
#endif
#ifndef SEEK_END
#	define SEEK_END	2
#endif

#define LPEXCEPTION_POINTERS EXCEPTION_POINTERS*

#endif /* (_WIN32_WCE) */

#endif /* SQ_WIN_32_H */
