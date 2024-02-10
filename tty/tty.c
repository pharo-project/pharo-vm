#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>
#include <sys/ioctl.h>

#define CHECK_ERROR(exp) if ((exp) == -1) { printf("Error in %s at %s: %s\n", __func__, #exp, strerror(errno)); exit(1); }

pid_t tty_spawn(int fdm, const char *path, char *const argv[], char *const envp[])
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
