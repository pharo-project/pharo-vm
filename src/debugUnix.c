#include "pharovm/pharo.h"
#include <stdarg.h>

#if __linux__

#define __USE_GNU
#define _GNU_SOURCE

#include <ucontext.h>

#endif

#if __APPLE__

#define _XOPEN_SOURCE
#include <ucontext.h>

#endif


#ifdef HAVE_EXECINFO_H
# include <execinfo.h>
#endif

#include <signal.h>
#include <string.h>


#define BACKTRACE_DEPTH 64

extern void dumpPrimTraceLog(void);

void ifValidWriteBackStackPointersSaveTo(void *theCFP, void *theCSP, char **savedFPP, char **savedSPP);

void printAllStacks();
void printCallStack();
char* GetAttributeString(int idx);
void reportStackState(const char *msg, char *date, int printAll, ucontext_t *uap, FILE* output);

char * getVersionInfo(int verbose);
void getCrashDumpFilenameInto(char *buf);
void dumpPrimTraceLog();

void doReport(char* fault, ucontext_t *uap){
	time_t now = time(NULL);
	char ctimebuf[32];
	char crashdumpFileName[PATH_MAX+1];
	FILE *crashDumpFile;

	ctime_r(&now,ctimebuf);

	//This is awful but replace the stdout to print all the messages in the file.
	crashdumpFileName[0] = 0;
	getCrashDumpFilenameInto(crashdumpFileName);
	crashDumpFile = fopen(crashdumpFileName, "a+");
	vm_setVMOutputStream(crashDumpFile);

	reportStackState(fault, ctimebuf, 1, uap, crashDumpFile);

	vm_setVMOutputStream(stderr);
	fclose(crashDumpFile);

	reportStackState(fault, ctimebuf, 1, uap, stderr);

}

void sigusr1(int sig, siginfo_t *info, ucontext_t *uap)
{
	int saved_errno = errno;

	doReport("SIGUSR1", uap);

	errno = saved_errno;
}


static int inFault = 0;

void sigsegv(int sig, siginfo_t *info, ucontext_t *uap)
{
	char *fault = strsignal(sig);

	doReport(fault, uap);

	exit(-1);
}

void terminateHandler(int sig, siginfo_t *info, ucontext_t *uap)
{
	char *fault = strsignal(sig);

	logWarn("VM terminated with signal %s", fault);

	if(getLogLevel() >= LOG_DEBUG){		
		doReport(fault, uap);
	}

	logWarn("Exiting with error code 1");	
	exit(1);
}


/*
 * Useful if we want to filter which are the threads to monitor
 */
EXPORT(void) registerCurrentThreadToHandleExceptions(){

}

EXPORT(void) installErrorHandlers(){
	struct sigaction sigusr1_handler_action, sigsegv_handler_action, term_handler_action, sigpipe_handler_action;

	sigsegv_handler_action.sa_sigaction = (void (*)(int, siginfo_t *, void *))sigsegv;
	sigsegv_handler_action.sa_flags = SA_NODEFER | SA_SIGINFO;
	sigemptyset(&sigsegv_handler_action.sa_mask);

#ifdef SIGEMT
	sigaction(SIGEMT, &sigsegv_handler_action, 0);
#endif
	sigaction(SIGFPE, &sigsegv_handler_action, 0);

	sigaction(SIGTRAP, &sigsegv_handler_action, 0);
	sigaction(SIGQUIT, &sigsegv_handler_action, 0);

	sigaction(SIGBUS, &sigsegv_handler_action, 0);
	sigaction(SIGILL, &sigsegv_handler_action, 0);
	sigaction(SIGSEGV, &sigsegv_handler_action, 0);
	sigaction(SIGSYS, &sigsegv_handler_action, 0);
	sigaction(SIGALRM, &sigsegv_handler_action, 0);
	sigaction(SIGABRT, &sigsegv_handler_action, 0);

	term_handler_action.sa_sigaction = (void (*)(int, siginfo_t *, void *))terminateHandler;
	term_handler_action.sa_flags = SA_NODEFER | SA_SIGINFO;

	sigaction(SIGHUP, &term_handler_action, 0);
	sigaction(SIGTERM, &term_handler_action, 0);
	
	sigaction(SIGKILL, &term_handler_action, 0);

	//Ignore all broken pipe signals. They will be reported as normal errors by send() and write()
	//Otherwise SIGPIPE kill the process without allowing any recovery or treatment
	sigpipe_handler_action.sa_sigaction = (void (*)(int, siginfo_t *, void *))SIG_IGN;
	sigpipe_handler_action.sa_flags = SA_NODEFER | SA_SIGINFO;
	sigaction(SIGPIPE, &sigpipe_handler_action, 0);
	
	sigusr1_handler_action.sa_sigaction = (void (*)(int, siginfo_t *, void *))sigusr1;
	sigusr1_handler_action.sa_flags = SA_NODEFER | SA_SIGINFO;
	sigemptyset(&sigusr1_handler_action.sa_mask);
	sigaction(SIGUSR1, &sigusr1_handler_action, 0);
}

void * printRegisterState(ucontext_t *uap, FILE* output)
{
#if __linux__ && __i386__
	greg_t *regs = uap->uc_mcontext.gregs;
	fprintf_impl(output,
			"\teax 0x%08x ebx 0x%08x ecx 0x%08x edx 0x%08x\n"
			"\tedi 0x%08x esi 0x%08x ebp 0x%08x esp 0x%08x\n"
			"\teip 0x%08x\n",
			regs[REG_EAX], regs[REG_EBX], regs[REG_ECX], regs[REG_EDX],
			regs[REG_EDI], regs[REG_EDI], regs[REG_EBP], regs[REG_ESP],
			regs[REG_EIP]);
	return (void *)regs[REG_EIP];
#elif __APPLE__ && __DARWIN_UNIX03 && __i386__
	_STRUCT_X86_THREAD_STATE32 *regs = &uap->uc_mcontext->__ss;
	fprintf_impl(output,
			"\teax 0x%08x ebx 0x%08x ecx 0x%08x edx 0x%08x\n"
			"\tedi 0x%08x esi 0x%08x ebp 0x%08x esp 0x%08x\n"
			"\teip 0x%08x\n",
			regs->__eax, regs->__ebx, regs->__ecx, regs->__edx,
			regs->__edi, regs->__edi, regs->__ebp, regs->__esp,
			regs->__eip);
	return (void *)(regs->__eip);
#elif __APPLE__ && __i386__
	_STRUCT_X86_THREAD_STATE32 *regs = &uap->uc_mcontext->ss;
	fprintf_impl(output,
			"\teax 0x%08x ebx 0x%08x ecx 0x%08x edx 0x%08x\n"
			"\tedi 0x%08x esi 0x%08x ebp 0x%08x esp 0x%08x\n"
			"\teip 0x%08x\n",
			regs->eax, regs->ebx, regs->ecx, regs->edx,
			regs->edi, regs->edi, regs->ebp, regs->esp,
			regs->eip);
	return (void *)(regs->eip);
#elif __APPLE__ && __x86_64__
	_STRUCT_X86_THREAD_STATE64 *regs = &uap->uc_mcontext->__ss;
	fprintf_impl(output,
			"\trax 0x%016llx rbx 0x%016llx rcx 0x%016llx rdx 0x%016llx\n"
			"\trdi 0x%016llx rsi 0x%016llx rbp 0x%016llx rsp 0x%016llx\n"
			"\tr8  0x%016llx r9  0x%016llx r10 0x%016llx r11 0x%016llx\n"
			"\tr12 0x%016llx r13 0x%016llx r14 0x%016llx r15 0x%016llx\n"
			"\trip 0x%016llx\n",
			regs->__rax, regs->__rbx, regs->__rcx, regs->__rdx,
			regs->__rdi, regs->__rdi, regs->__rbp, regs->__rsp,
			regs->__r8 , regs->__r9 , regs->__r10, regs->__r11,
			regs->__r12, regs->__r13, regs->__r14, regs->__r15,
			regs->__rip);
	return (void *)(regs->__rip);
# elif __APPLE__ && (defined(__arm__) || defined(__arm32__))
	_STRUCT_ARM_THREAD_STATE *regs = &uap->uc_mcontext->ss;
	fprintf_impl(output,
			"\t r0 0x%08x r1 0x%08x r2 0x%08x r3 0x%08x\n"
	        "\t r4 0x%08x r5 0x%08x r6 0x%08x r7 0x%08x\n"
	        "\t r8 0x%08x r9 0x%08x r10 0x%08x fp 0x%08x\n"
	        "\t ip 0x%08x sp 0x%08x lr 0x%08x pc 0x%08x\n"
			"\tcpsr 0x%08x\n",
	        regs->r[0],regs->r[1],regs->r[2],regs->r[3],
	        regs->r[4],regs->r[5],regs->r[6],regs->r[7],
	        regs->r[8],regs->r[9],regs->r[10],regs->r[11],
	        regs->r[12], regs->sp, regs->lr, regs->pc, regs->cpsr);
	return (void *)(regs->pc);
# elif __APPLE__ && defined(__aarch64__)
	_STRUCT_ARM_THREAD_STATE64 *regs = &uap->uc_mcontext->__ss;

	fprintf_impl(output,
			"\t x00 0x%016llx x01 0x%016llx x02 0x%016llx x03 0x%016llx\n"
			"\t x04 0x%016llx x05 0x%016llx x06 0x%016llx x07 0x%016llx\n"
			"\t x08 0x%016llx x09 0x%016llx x10 0x%016llx x11 0x%016llx\n"
			"\t x12 0x%016llx x13 0x%016llx x14 0x%016llx x15 0x%016llx\n"
			"\t x16 0x%016llx x17 0x%016llx x18 0x%016llx x19 0x%016llx\n"
			"\t x20 0x%016llx x21 0x%016llx x22 0x%016llx x23 0x%016llx\n"
			"\t x24 0x%016llx x25 0x%016llx x26 0x%016llx x27 0x%016llx\n"
			"\t x28 0x%016llx  FP 0x%016llx  LR 0x%016llx  SP 0x%016llx\n"
			"\t  PC 0x%016llx  STATE 0x%016llx\n",

            regs->__x[0],
            regs->__x[1],
            regs->__x[2],
            regs->__x[3],
            regs->__x[4],
            regs->__x[5],
            regs->__x[6],
            regs->__x[7],
            regs->__x[8],
            regs->__x[9],
            regs->__x[10],
            regs->__x[11],
            regs->__x[12],
            regs->__x[13],
            regs->__x[14],
            regs->__x[15],
            regs->__x[16],
            regs->__x[17],
            regs->__x[18],
            regs->__x[19],
            regs->__x[20],
            regs->__x[21],
            regs->__x[22],
            regs->__x[23],
            regs->__x[24],
            regs->__x[25],
            regs->__x[26],
            regs->__x[27],
            regs->__x[28],
            regs->__fp,
            regs->__lr,
            regs->__sp,
            regs->__pc,
            (__uint64_t)regs->__cpsr);
    return (void*)(regs->__pc); 
#elif __FreeBSD__ && __i386__
	struct mcontext *regs = &uap->uc_mcontext;
	fprintf_impl(output,
			"\teax 0x%08x ebx 0x%08x ecx 0x%08x edx 0x%08x\n"
			"\tedi 0x%08x esi 0x%08x ebp 0x%08x esp 0x%08x\n"
			"\teip 0x%08x\n",
			regs->mc_eax, regs->mc_ebx, regs->mc_ecx, regs->mc_edx,
			regs->mc_edi, regs->mc_edi, regs->mc_ebp, regs->mc_esp,
			regs->mc_eip);
	return regs->mc_eip;
#elif __linux__ && __x86_64__
	greg_t *regs = uap->uc_mcontext.gregs;
	fprintf_impl(output,
			"\trax 0x%08llx rbx 0x%08llx rcx 0x%08llx rdx 0x%08llx\n"
			"\trdi 0x%08llx rsi 0x%08llx rbp 0x%08llx rsp 0x%08llx\n"
			"\tr8  0x%08llx r9  0x%08llx r10 0x%08llx r11 0x%08llx\n"
			"\tr12 0x%08llx r13 0x%08llx r14 0x%08llx r15 0x%08llx\n"
			"\trip 0x%08llx\n",
			regs[REG_RAX], regs[REG_RBX], regs[REG_RCX], regs[REG_RDX],
			regs[REG_RDI], regs[REG_RDI], regs[REG_RBP], regs[REG_RSP],
			regs[REG_R8 ], regs[REG_R9 ], regs[REG_R10], regs[REG_R11],
			regs[REG_R12], regs[REG_R13], regs[REG_R14], regs[REG_R15],
			regs[REG_RIP]);
	return (void*)regs[REG_RIP];
# elif __linux__ && (defined(__arm__) || defined(__arm32__) || defined(ARM32))
	struct sigcontext *regs = &uap->uc_mcontext;
	fprintf_impl(output,
			"\t r0 0x%08x r1 0x%08x r2 0x%08x r3 0x%08x\n"
	        "\t r4 0x%08x r5 0x%08x r6 0x%08x r7 0x%08x\n"
	        "\t r8 0x%08x r9 0x%08x r10 0x%08x fp 0x%08x\n"
	        "\t ip 0x%08x sp 0x%08x lr 0x%08x pc 0x%08x\n",
	        regs->arm_r0,regs->arm_r1,regs->arm_r2,regs->arm_r3,
	        regs->arm_r4,regs->arm_r5,regs->arm_r6,regs->arm_r7,
	        regs->arm_r8,regs->arm_r9,regs->arm_r10,regs->arm_fp,
	        regs->arm_ip, regs->arm_sp, regs->arm_lr, regs->arm_pc);
	return regs->arm_pc;
# elif __linux__ && defined(__aarch64__)
	fprintf_impl(output,
			"\t x00 0x%016llx x01 0x%016llx x02 0x%016llx x03 0x%016llx\n"
			"\t x04 0x%016llx x05 0x%016llx x06 0x%016llx x07 0x%016llx\n"
			"\t x08 0x%016llx x09 0x%016llx x10 0x%016llx x11 0x%016llx\n"
			"\t x12 0x%016llx x13 0x%016llx x14 0x%016llx x15 0x%016llx\n"
			"\t x16 0x%016llx x17 0x%016llx x18 0x%016llx x19 0x%016llx\n"
			"\t x20 0x%016llx x21 0x%016llx x22 0x%016llx x23 0x%016llx\n"
			"\t x24 0x%016llx x25 0x%016llx x26 0x%016llx x27 0x%016llx\n"
			"\t x28 0x%016llx  FP 0x%016llx  LR 0x%016llx  SP 0x%016llx\n"
			"\t  PC 0x%016llx  STATE 0x%016llx\n",

            uap->uc_mcontext.regs[0],
            uap->uc_mcontext.regs[1],
            uap->uc_mcontext.regs[2],
            uap->uc_mcontext.regs[3],
            uap->uc_mcontext.regs[4],
            uap->uc_mcontext.regs[5],
            uap->uc_mcontext.regs[6],
            uap->uc_mcontext.regs[7],
            uap->uc_mcontext.regs[8],
            uap->uc_mcontext.regs[9],
            uap->uc_mcontext.regs[10],
            uap->uc_mcontext.regs[11],
            uap->uc_mcontext.regs[12],
            uap->uc_mcontext.regs[13],
            uap->uc_mcontext.regs[14],
            uap->uc_mcontext.regs[15],
            uap->uc_mcontext.regs[16],
            uap->uc_mcontext.regs[17],
            uap->uc_mcontext.regs[18],
            uap->uc_mcontext.regs[19],
            uap->uc_mcontext.regs[20],
            uap->uc_mcontext.regs[21],
            uap->uc_mcontext.regs[22],
            uap->uc_mcontext.regs[23],
            uap->uc_mcontext.regs[24],
            uap->uc_mcontext.regs[25],
            uap->uc_mcontext.regs[26],
            uap->uc_mcontext.regs[27],
            uap->uc_mcontext.regs[28],
            uap->uc_mcontext.regs[29],
            uap->uc_mcontext.regs[30],
            uap->uc_mcontext.sp,
            uap->uc_mcontext.pc,
            uap->uc_mcontext.pstate);
    return (void*)uap->uc_mcontext.pc; 
#else
	fprintf_impl(output,"don't know how to derive register state from a ucontext_t on this platform\n");
	return 0;
#endif
}

static int runningInVMThread(){

/*
	IF THE VM is compiled without support for PTHREAD we assume that we are in the VM thread
*/
	
#ifdef PHARO_VM_IN_WORKER_THREAD
	return ioOSThreadsEqual(ioCurrentOSThread(),getVMOSThread());
#else
	return 1;
#endif
	
}

static sqInt printingStack = false;

void reportStackState(const char *msg, char *date, int printAll, ucontext_t *uap, FILE* output)
{
#if !defined(NOEXECINFO)
	void *addrs[BACKTRACE_DEPTH];
	void *pc;
	int depth;
#endif
	/* flag prevents recursive error when trying to print a broken stack */

#if COGVM
	/* Testing stackLimit tells us whether the VM is initialized. */
	extern usqInt stackLimitAddress(void);
#endif

	fprintf_impl(output,"\n%s%s%s\n\n", msg, date ? " " : "", date ? date : "");
	fprintf_impl(output,"%s\n%s\n\n", GetAttributeString(0), getVersionInfo(1));

#if COGVM
	/* Do not attempt to report the stack until the VM is initialized!! */
	if (!*(char **)stackLimitAddress())
		return;
#endif

#ifdef HAVE_EXECINFO_H
	fprintf_impl(output,"C stack backtrace & registers:\n");
	if (uap) {
		addrs[0] = printRegisterState(uap, output);
		depth = 1 + backtrace(addrs + 1, BACKTRACE_DEPTH);
	}
	else{
		depth = backtrace(addrs, BACKTRACE_DEPTH);
	}

	fputc('*', output); /* indicate where pc is */
	fflush(output); /* backtrace_symbols_fd uses unbuffered i/o */
	backtrace_symbols_fd(addrs, depth + 1, fileno(output));
#endif
	
	if (runningInVMThread()) {
		if (!printingStack) {
#if COGVM
			/* If we're in generated machine code then the only way the stack
			 * dump machinery has of giving us an accurate report is if we set
			 * stackPointer & framePointer to the native stack & frame pointers.
			 */
# if __APPLE__ && __MACH__ && __i386__
#	  if __GNUC__ && !__INTEL_COMPILER /* icc pretends to be gcc */
			void *fp = (void *)(uap ? uap->uc_mcontext->__ss.__ebp: 0);
			void *sp = (void *)(uap ? uap->uc_mcontext->__ss.__esp: 0);
#	  else
			void *fp = (void *)(uap ? uap->uc_mcontext->ss.ebp: 0);
			void *sp = (void *)(uap ? uap->uc_mcontext->ss.esp: 0);
#	  endif
# elif __APPLE__ && __MACH__ && __x86_64__
			void *fp = (void *)(uap ? uap->uc_mcontext->__ss.__rbp: 0);
			void *sp = (void *)(uap ? uap->uc_mcontext->__ss.__rsp: 0);
# elif __linux__ && __i386__
			void *fp = (void *)(uap ? uap->uc_mcontext.gregs[REG_EBP]: 0);
			void *sp = (void *)(uap ? uap->uc_mcontext.gregs[REG_ESP]: 0);
#	elif __linux__ && __x86_64__
			void *fp = (void *)(uap ? uap->uc_mcontext.gregs[REG_RBP]: 0);
			void *sp = (void *)(uap ? uap->uc_mcontext.gregs[REG_RSP]: 0);
# elif __FreeBSD__ && __i386__
			void *fp = (void *)(uap ? uap->uc_mcontext.mc_ebp: 0);
			void *sp = (void *)(uap ? uap->uc_mcontext.mc_esp: 0);
# elif __OpenBSD__
			void *fp = (void *)(uap ? uap->sc_rbp: 0);
			void *sp = (void *)(uap ? uap->sc_rsp: 0);
# elif __sun__ && __i386__
            void *fp = (void *)(uap ? uap->uc_mcontext.gregs[REG_FP]: 0);
            void *sp = (void *)(uap ? uap->uc_mcontext.gregs[REG_SP]: 0);
# elif defined(__arm__) || defined(__arm32__) || defined(ARM32)
			void *fp = (void *)(uap ? uap->uc_mcontext.arm_fp: 0);
			void *sp = (void *)(uap ? uap->uc_mcontext.arm_sp: 0);
# elif defined(__aarch64__) && __APPLE__
			void *fp = (void *)(uap ? uap->uc_mcontext->__ss.__fp: 0); 
			void *sp = (void *)(uap ? uap->uc_mcontext->__ss.__sp: 0);
# elif defined(__aarch64__)
			void *fp = (void *)(uap ? uap->uc_mcontext.regs[29]: 0); // This is the Register that we are using for the FramePointer
			void *sp = (void *)(uap ? uap->uc_mcontext.sp: 0);
# else
#	error need to implement extracting pc from a ucontext_t on this system
# endif
			char *savedSP, *savedFP;

			ifValidWriteBackStackPointersSaveTo(fp,sp,&savedFP,&savedSP);
#endif /* COGVM */

			printingStack = true;
			if (printAll) {
				fprintf_impl(output, "\n\nAll Smalltalk process stacks (active first):\n");
				printAllStacks();
			}
			else {
				fprintf_impl(output,"\n\nSmalltalk stack dump:\n");
				printCallStack();
			}
			printingStack = false;
#if COGVM
			/* Now restore framePointer and stackPointer via same function */
			ifValidWriteBackStackPointersSaveTo(savedFP,savedSP,0,0);
#endif
		}
	}
	else {
		fprintf_impl(output,"\nNot in VM thread.\n");
	}

#if STACKVM
	fprintf_impl(output, "\nMost recent primitives\n");
	dumpPrimTraceLog();
# if COGVM
	fprintf_impl(output,"\n");
	reportMinimumUnusedHeadroom();
# endif
#endif
	fprintf_impl(output,"\n\t(%s)\n", msg);
	fflush(output);
}

EXPORT(void) printStatusAfterError(){
	
	ucontext_t uap;
	
	getcontext(&uap);
	
	int saved_errno = errno;

	doReport("VM Error", &uap);

	errno = saved_errno;
}

EXPORT(int) fprintf_impl(FILE * stream, const char * format, ... ){
	va_list list;
	va_start(list, format);

	int returnValue = vfprintf(stream, format, list);

	va_end(list);

	return returnValue;
}

EXPORT(int) vfprintf_impl(FILE * stream, const char * format, va_list arg){
	return vfprintf(stream, format, arg);
}

