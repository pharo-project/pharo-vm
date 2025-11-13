#include "NewFile.h"

#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>

struct NewDirectory_s
{
    DIR *handle;
};

static char *
makeCStringWithFixedString(const char *string, size_t stringSize)
{
    char *cstring = malloc(stringSize + 1);
    memcpy(cstring, string, stringSize);
    cstring[stringSize] = 0;
    return cstring;
}

bool
NewDirectory_create(const char *path, size_t pathSize)
{
    char *cpath = makeCStringWithFixedString(path, pathSize);
    bool result = mkdir(cpath, 0755) == 0;
    free(cpath);
    return result;
}

bool NewDirectory_removeEmpty(const char *path, size_t pathSize)
{
    char *cpath = makeCStringWithFixedString(path, pathSize);
    bool result = rmdir(cpath) == 0;
    free(cpath);
    return result;
}

NewDirectory_t *
NewDirectory_open(const char *path, size_t pathSize)
{
    char *cpath = makeCStringWithFixedString(path, pathSize);
    DIR *handle = opendir(path);
    free(cpath);
    if(!handle)
        return NULL;
    
    NewDirectory_t *directory = calloc(1, sizeof(NewDirectory_t));
    directory->handle = handle;
    return directory;
}

bool
NewDirectory_rewind(NewDirectory_t *directory)
{
    if(!directory)
        return false;

    rewinddir(directory->handle);
    return true;
}

const char *
NewDirectory_next(NewDirectory_t *directory)
{
    if(!directory)
        return NULL;

    struct dirent *entry = readdir(directory->handle);
    if(!entry)
        return NULL;

    return entry->d_name;
}

void
NewDirectory_close(NewDirectory_t *directory)
{
    if(!directory)
        return;
    
    closedir(directory->handle);
    free(directory);
}

struct NewFile_s
{
    int fileDescriptor;
    int memoryMapCount;
    size_t memoryMapLength;
    void *memoryMapAddress;
};

PHARO_NEWFILE_EXPORT bool
NewFile_deleteFile(const char *path, size_t pathSize)
{
    char *cpath = makeCStringWithFixedString(path, pathSize);
    bool result = unlink(cpath) == 0;
    free(cpath);
    return result;
}

NewFile_t *
NewFile_open(const char *path, size_t pathSize, NewFileOpenMode_t mode, NewFileCreationDisposition_t creationDisposition, NewFileOpenFlags_t flags)
{
    int openFlags = 0;
    int openMode = 0644;
    switch(mode)
    {
    case NewFileOpenModeReadOnly:
        openFlags = O_RDONLY;
        break;
    case NewFileOpenModeWriteOnly:
        openFlags = O_WRONLY;
        break;
    case NewFileOpenModeReadWrite:
        openFlags = O_RDWR;
        break;
    default:
        return NULL;
    }

    if(flags & NewFileOpenFlagsAppend)
        openFlags |= O_APPEND;

    switch(creationDisposition)
    {
    case NewFileCreationDispositionCreateNew:
        openFlags |= O_CREAT | O_EXCL;
        break;
    case NewFileCreationDispositionCreateAlways:
        openFlags |= O_CREAT | O_TRUNC;
        break;
    case NewFileCreationDispositionOpenExisting:
        break;
    case NewFileCreationDispositionOpenAlways:
        openFlags |= O_CREAT;
        break;
    case NewFileCreationDispositionTruncateExisting:
        openFlags |= O_TRUNC;
        break;
    default:
        break;
    }
    
    char *cpath = makeCStringWithFixedString(path, pathSize);
    int fd = open(cpath, openFlags, openMode);
    free(cpath);
    if(fd < 0)
        return NULL;

    NewFile_t *newFile = calloc(1, sizeof(NewFile_t));
    newFile->fileDescriptor = fd;
    return newFile;
}

void
NewFile_close(NewFile_t *file)
{
    if(!file)
        return;

    close(file->fileDescriptor);
    free(file);
}

int64_t
NewFile_getSize(NewFile_t *file)
{
    if(!file)
        return -1;

    struct stat s;
    if(fstat(file->fileDescriptor, &s))
        return -1;

    return s.st_size;
}

void NewFile_seek(NewFile_t *file, int64_t offset, NewFileSeekMode_t seekMode)
{
    int whence = 0;
    switch(seekMode)
    {
    case NewFileSeekModeSet:
        whence = SEEK_SET;
        break;
    case NewFileSeekModeCurrent:
        whence = SEEK_CUR;
        break;
    case NewFileSeekModeEnd:
        whence = SEEK_END;
        break;
    default:
        return;
    }

    lseek(file->fileDescriptor, offset, whence);
}

int64_t
NewFile_tell(NewFile_t *file)
{
    if(!file)
        return 0;
    return lseek(file->fileDescriptor, 0, SEEK_CUR);
}

bool
NewFile_truncate(NewFile_t *file, uint64_t newFileSize)
{
    if(!file)
        return false;
    
    return ftruncate(file->fileDescriptor, newFileSize) == 0;
}

int64_t
NewFile_read(NewFile_t *file, void * buffer, size_t bufferOffset, size_t readSize)
{
    if(!file)
        return -1;

    return read(file->fileDescriptor, (char*)buffer + bufferOffset, readSize);
}

int64_t
NewFile_write(NewFile_t *file, const void * buffer, size_t bufferOffset, size_t writeSize)
{
    if(!file)
        return -1;

    return write(file->fileDescriptor, (const char*)buffer + bufferOffset, writeSize);
}

int64_t
NewFile_readAtOffset(NewFile_t *file, void * buffer, size_t bufferOffset, size_t readSize, uint64_t offset)
{
    if(!file)
        return -1;

    return pread(file->fileDescriptor, (char*)buffer + bufferOffset, readSize, offset);
}

int64_t
NewFile_writeAtOffset(NewFile_t *file, const void * buffer, size_t bufferOffset, size_t writeSize, uint64_t offset)
{
    if(!file)
        return -1;

    return pwrite(file->fileDescriptor, (const char*)buffer + bufferOffset, writeSize, offset);
}

PHARO_NEWFILE_EXPORT void *
NewFile_memoryMap(NewFile_t *file, NewFileMemMapProtection_t protection)
{
    if(!file)
        return NULL;

    if(file->memoryMapCount > 0)
    {
        ++file->memoryMapCount;
        return file->memoryMapAddress;
    }

    file->memoryMapLength = NewFile_getSize(file);
    if(file->memoryMapLength == 0)
        return 0;

    int mmapProtection = PROT_NONE;
    switch(protection)
    {
    case NewFileMemMapProtectionReadOnly:
        mmapProtection = PROT_READ;
        break;
    case NewFileMemMapProtectionReadWrite:
        mmapProtection = PROT_READ | PROT_WRITE;
        break;
    default:
        break;
    }

    file->memoryMapAddress = mmap(NULL, file->memoryMapLength, mmapProtection, MAP_SHARED, file->fileDescriptor, 0);
    if(file->memoryMapAddress == MAP_FAILED)
        return NULL;

    ++file->memoryMapCount;
    return file->memoryMapAddress;
}

PHARO_NEWFILE_EXPORT void
NewFile_memoryUnmap(NewFile_t *file)
{
    if(!file || file->memoryMapCount <= 0)
        return;

    --file->memoryMapCount;
    if(!file->memoryMapCount)
        return;

    munmap(file->memoryMapAddress, file->memoryMapLength);
}
