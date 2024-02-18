#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>
#include <sys/ioctl.h>

#define CHECK_ERROR(exp) if ((exp) == -1) { printf("Error in %s at %s: %s\n", __func__, #exp, strerror(errno)); exit(1); }

pid_t tty_spawn(int fdm, const char *path, char *const argv[], char *const envp[])
    /*
        Spawns a process as a session leader with a pseudo-terminal as
        its controlling terminal, its standard file descriptors
        referring to the terminal, and executing a file with the given
        arguments and environment. The first argument is expected to
        be a file descriptor referring to a master pseudo-terminal
        device as returned by 'posix_openpt'. The next three arguments
        should be given as expected by 'execve'. The process ID of the
        new process is returned, or -1 if one could not be created. If
        the process is created but fails to create the session, set
        the controlling terminal or execute the file, it exits with
        status 1 after printing an error message on the terminal that
        indicates the call that failed.
        
        Provided through a library included with the VM to support
        Pharo terminal emulators: it can only be partially replicated
        through the FFI by using 'posix_spawn', as that seems to lack
        a way to set the controlling terminal of the new process.
    */
{
    pid_t pid = fork();
    if (pid == 0)
    {
        int fds = open(ptsname(fdm), O_RDWR);
        close(fdm);
        close(0);
        close(1);
        close(2);
        dup(fds);
        dup(fds);
        dup(fds);
        close(fds);
        CHECK_ERROR(setsid());
        CHECK_ERROR(ioctl(0, TIOCSCTTY, 0));
        CHECK_ERROR(execve(path, argv, envp));
    }
    return pid;
}
