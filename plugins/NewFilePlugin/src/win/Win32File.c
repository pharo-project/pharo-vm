#include "NewFile.h"

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef NOMINMAX
#define NOMINMAX
#endif

#include <Windows.h>

#include <stdlib.h>

struct NewDirectory_s
{
    WCHAR *path;
    HANDLE findHandle;
    WIN32_FIND_DATAW findData;
    bool isFirst;
    char *elementName;
};

struct NewFile_s
{
    HANDLE fileHandle;
    int memoryMapCount;
    HANDLE memoryMapHandle;
    void *memoyMapAddress;
};

static WCHAR *
NewFile_utf8ToWideChar(const char *string, size_t stringLen)
{
    int wstringSize = MultiByteToWideChar(CP_UTF8, 0, string, (int)stringLen, NULL, 0);
    if(wstringSize <= 0)
        return NULL;

    WCHAR *wstring = calloc(wstringSize + 1, sizeof(WCHAR));
    wstringSize = MultiByteToWideChar(CP_UTF8, 0, string, (int)stringLen, wstring, wstringSize + 1);
    if(wstringSize <= 0)
    {
        free(wstring);
        return NULL;
    }

    return wstring;
}

static char *
NewFile_wideCharToUtf8(const WCHAR *wstring)
{
    int characterCount = WideCharToMultiByte(CP_UTF8, 0, wstring, -1, NULL, 0, NULL, NULL);
    char *string = calloc(characterCount + 1, 1);
    WideCharToMultiByte(CP_UTF8, 0, wstring, -1, string, characterCount, NULL, NULL);

    return string;
}

static bool
NewFile_isAbsolutePath(const char *path, size_t pathSize)
{
    return pathSize >= 3 && (path[1] == ':') && (path[2] == '\\');
}

static WCHAR *
NewFile_preparePath(const char *path, size_t pathSize)
{
    // Add the \\?\ prefix to absolute paths
    if(NewFile_isAbsolutePath(path, pathSize))
    {
        size_t pathLength = strlen(path);
        char *stringWithPrefix = calloc(4 + pathLength, 1);
        memcpy(stringWithPrefix, "\\\\?\\", 4);
        memcpy(stringWithPrefix + 4, path, pathLength);
        
        WCHAR *wpath = NewFile_utf8ToWideChar(stringWithPrefix, 4 + pathLength);
        free(stringWithPrefix);
        return wpath;
    }

    return NewFile_utf8ToWideChar(path, pathSize);
}

static WCHAR *
NewFile_prepareWildCardPath(const char *path, size_t pathSize)
{
    const char * suffix = "\\*";
    size_t pathLength = pathSize;
    size_t suffixLength = strlen(suffix);

    char *pathWithWildCard = calloc(pathLength + suffixLength + 1, 1);
    memcpy(pathWithWildCard, path, pathLength);
    memcpy(pathWithWildCard + pathLength, suffix, suffixLength);

    WCHAR *wpath = NewFile_preparePath(pathWithWildCard, pathLength + suffixLength);
    free(pathWithWildCard);
    return wpath;
}

/**
 * Creates a directory.
 */
PHARO_NEWFILE_EXPORT bool
NewDirectory_create(const char *path, size_t pathSize)
{
    WCHAR *wpath = NewFile_preparePath(path, pathSize);
    BOOL result = CreateDirectoryW(wpath, NULL);
    free(wpath);
    return result;
}

/**
 * Removes an empty directory
 */
PHARO_NEWFILE_EXPORT bool
NewDirectory_removeEmpty(const char *path, size_t pathSize)
{
    WCHAR *wpath = NewFile_preparePath(path, pathSize);
    BOOL result = RemoveDirectoryW(wpath);
    free(wpath);
    return result;
}

PHARO_NEWFILE_EXPORT NewDirectory_t*
NewDirectory_open(const char *path, size_t pathSize)
{
    if(!path)
        return NULL;

    WCHAR *wpath = NewFile_prepareWildCardPath(path, pathSize);

    WIN32_FIND_DATAW findData;
    HANDLE findHandle = FindFirstFileW(wpath, &findData);
    if(findHandle == INVALID_HANDLE_VALUE)
    {
        free(wpath);
        return NULL;
    }

    NewDirectory_t *directory = calloc(1, sizeof(NewDirectory_t));
    directory->path = wpath;
    directory->findHandle = findHandle;
    directory->findData = findData;
    directory->isFirst = true;
    directory->elementName = NewFile_wideCharToUtf8(directory->findData.cFileName);
    return directory;
}

PHARO_NEWFILE_EXPORT bool
NewDirectory_rewind(NewDirectory_t *directory)
{
    if(!directory || directory->isFirst)
        return true;

    WIN32_FIND_DATAW newFindData;
    HANDLE newFindHandle = FindFirstFileW(directory->path, &newFindData);
    if(newFindHandle == INVALID_HANDLE_VALUE)
        return false;

    FindClose(directory->findHandle);
    directory->findHandle = newFindHandle;
    directory->findData = newFindData;
    if(directory->elementName)
        free(directory->elementName);

    directory->elementName = NewFile_wideCharToUtf8(directory->findData.cFileName);
    return true;
}

PHARO_NEWFILE_EXPORT const char *
NewDirectory_next(NewDirectory_t *directory)
{
    if(!directory)
        return NULL;

    if(directory->isFirst)
    {
        directory->isFirst = false;
        return directory->elementName;
    }

    free(directory->elementName);
    directory->elementName = NULL;

    if(!FindNextFileW(directory->findHandle, &directory->findData))
        return NULL;

    directory->elementName = NewFile_wideCharToUtf8(directory->findData.cFileName);
    return directory->elementName;
}

PHARO_NEWFILE_EXPORT void
NewDirectory_close(NewDirectory_t *directory)
{
    if(!directory)
        return;

    FindClose(directory->findHandle);
    free(directory->elementName);
    free(directory->path);
    free(directory);
}

PHARO_NEWFILE_EXPORT bool
NewFile_deleteFile(const char *path, size_t pathSize)
{
    WCHAR *wpath = NewFile_preparePath(path, pathSize);
    if(!wpath)
        return false;

    bool result = DeleteFileW(wpath);
    free(wpath);
    return result;
}

PHARO_NEWFILE_EXPORT NewFile_t *
NewFile_open(const char *path, size_t pathSize, NewFileOpenMode_t mode, NewFileCreationDisposition_t creationDisposition, NewFileOpenFlags_t flags)
{
    DWORD desiredAccess = 0;
    DWORD shareMode = FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE;
    switch(mode)
    {
    case NewFileOpenModeReadOnly:
        desiredAccess = GENERIC_READ;
        break;
    case NewFileOpenModeWriteOnly:
        desiredAccess = GENERIC_WRITE;
        break;
    case NewFileOpenModeReadWrite:
        desiredAccess = GENERIC_READ | GENERIC_WRITE;
        break;
    default:
        return NULL;
    }

    DWORD dwCreationDisposition;
    switch(creationDisposition)
    {
    case NewFileCreationDispositionCreateNew:
        dwCreationDisposition = CREATE_NEW;
        break;
    case NewFileCreationDispositionCreateAlways:
        dwCreationDisposition = CREATE_ALWAYS;
        break;
    case NewFileCreationDispositionOpenExisting:
        dwCreationDisposition = OPEN_EXISTING;
        break;
    case NewFileCreationDispositionOpenAlways:
        dwCreationDisposition = OPEN_ALWAYS;
        break;
    case NewFileCreationDispositionTruncateExisting:
        dwCreationDisposition = TRUNCATE_EXISTING;
        break;
    default:
        return NULL;
    }

    WCHAR *wpath = NewFile_preparePath(path, pathSize);
    if(!wpath)
        return NULL;

    HANDLE handle = CreateFileW(wpath, desiredAccess, shareMode, NULL, dwCreationDisposition, FILE_ATTRIBUTE_NORMAL, NULL);
    free(wpath);
    if(handle == INVALID_HANDLE_VALUE)
        return NULL;

    NewFile_t *newFile = calloc(1, sizeof(NewFile_t));
    newFile->fileHandle = handle;
    return newFile;
}

PHARO_NEWFILE_EXPORT void
NewFile_close(NewFile_t *file)
{
    if(!file)
        return;

    if(file->memoryMapCount > 0)
    {
        UnmapViewOfFile(file->memoyMapAddress);
        CloseHandle(file->memoryMapHandle);
    }
    CloseHandle(file->fileHandle);
    free(file);
}

PHARO_NEWFILE_EXPORT int64_t
NewFile_getSize(NewFile_t *file)
{
    if(!file)
        return -1;

    LARGE_INTEGER fileSize = {{0}};
    if(!GetFileSizeEx(file->fileHandle, &fileSize))
        return -1;

    return fileSize.QuadPart;
}

PHARO_NEWFILE_EXPORT void
NewFile_seek(NewFile_t *file, int64_t offset, NewFileSeekMode_t seekMode)
{
    if(!file)
        return;

    LARGE_INTEGER largeIntegerOffset = {{0}};
    largeIntegerOffset.QuadPart = offset;

    DWORD moveMethod;
    switch(seekMode)
    {
    case NewFileSeekModeSet:
        moveMethod = FILE_BEGIN;
        break;
    case NewFileSeekModeCurrent:
        moveMethod = FILE_CURRENT;
        break;
    case NewFileSeekModeEnd:
        moveMethod = FILE_END;
        break;
    default:
        abort();
    }

    SetFilePointerEx(file->fileHandle, largeIntegerOffset, NULL, moveMethod);
}

PHARO_NEWFILE_EXPORT int64_t
NewFile_tell(NewFile_t *file)
{
    if(!file)
        return 0;

    LARGE_INTEGER largeIntegerOffset = {{0}};
    LARGE_INTEGER filePointerPosition = {{0}};

    if(!SetFilePointerEx(file->fileHandle, largeIntegerOffset, &filePointerPosition, FILE_CURRENT))
        return -1;
    return filePointerPosition.QuadPart;
}

PHARO_NEWFILE_EXPORT bool
NewFile_truncate(NewFile_t *file, uint64_t newFileSize)
{
    if(!file)
        return false;

    LARGE_INTEGER largeIntegerOffset = {{0}};
    largeIntegerOffset.QuadPart = newFileSize;
    LARGE_INTEGER oldFileOffset = {{0}};

    // Move the file pointer to the new ending.
    if(!SetFilePointerEx(file->fileHandle, largeIntegerOffset, &oldFileOffset, FILE_BEGIN))
        return -1;

    // Set the new end of file.
    bool result = SetEndOfFile(file->fileHandle);

    // Restore the file pointer.
    if(SetFilePointerEx(file->fileHandle, oldFileOffset, NULL, FILE_BEGIN))
        return -1;

    return result;
}

PHARO_NEWFILE_EXPORT int64_t
NewFile_read(NewFile_t *file, void * buffer, size_t bufferOffset, size_t readSize)
{
    if(!file)
        return -1;

    DWORD readBytes = 0;
    if(!ReadFile(file->fileHandle, (char*)buffer + bufferOffset, (DWORD)readSize, &readBytes, NULL))
        return -1;
    return readBytes;
}

PHARO_NEWFILE_EXPORT int64_t
NewFile_write(NewFile_t *file, const void * buffer, size_t bufferOffset, size_t writeSize)
{
    if(!file)
        return -1;

    DWORD writtenBytes = 0;
    if(!WriteFile(file->fileHandle, (const char*)buffer + bufferOffset, (DWORD)writeSize, &writtenBytes, NULL))
        return -1;

    return writtenBytes;
}

PHARO_NEWFILE_EXPORT int64_t
NewFile_readAtOffset(NewFile_t *file, void * buffer, size_t bufferOffset, size_t readSize, uint64_t offset)
{
    if(!file)
        return -1;

    OVERLAPPED overlapped = {0};
    overlapped.Offset = (DWORD)offset;
    overlapped.OffsetHigh = (DWORD)(offset >> 32);

    DWORD readBytes = 0;
    if(!ReadFile(file->fileHandle, (char*)buffer + bufferOffset, (DWORD)readSize, &readBytes, &overlapped))
        return -1;
    return readBytes;
}

PHARO_NEWFILE_EXPORT int64_t
NewFile_writeAtOffset(NewFile_t *file, const void * buffer, size_t bufferOffset, size_t writeSize, uint64_t offset)
{
    if(!file)
        return -1;

    OVERLAPPED overlapped = {0};
    overlapped.Offset = (DWORD)offset;
    overlapped.OffsetHigh = (DWORD)(offset >> 32);

    DWORD writtenBytes = 0;
    if(!WriteFile(file->fileHandle, (const char*)buffer + bufferOffset, (DWORD)writeSize, &writtenBytes, &overlapped))
        return -1;

    return writtenBytes;
}

PHARO_NEWFILE_EXPORT void * NewFile_memoryMap(NewFile_t *file, NewFileMemMapProtection_t protection)
{
    if(!file)
        return NULL;

    if(file->memoryMapCount)
    {
        // TODO: Support changing the permission
        ++file->memoryMapCount;
        return file->memoyMapAddress;
    }

    // Map the file protection
    DWORD flProtect = 0;
    DWORD desiredAccess = 0;
    switch(protection)
    {
    case NewFileMemMapProtectionReadOnly:
        flProtect = PAGE_READONLY;
        desiredAccess = FILE_MAP_READ;
        break;
    case NewFileMemMapProtectionReadWrite:
        flProtect = PAGE_READWRITE;
        desiredAccess = FILE_MAP_WRITE;
        break;
    }

    file->memoryMapHandle = CreateFileMappingA(file->fileHandle, NULL, flProtect, 0, 0, NULL);
    if(!file->memoryMapHandle)
        return NULL;

    file->memoyMapAddress = MapViewOfFile(file->memoryMapHandle, desiredAccess, 0, 0, 0);
    if(!file->memoyMapAddress)
    {
        CloseHandle(file->memoryMapHandle);
        return NULL;
    }

    file->memoryMapCount = 1;
    return file->memoyMapAddress;
}

PHARO_NEWFILE_EXPORT void
NewFile_memoryUnmap(NewFile_t *file)
{
    if(!file || file->memoryMapCount == 0)
        return;

    --file->memoryMapCount;
    if(file->memoryMapCount > 0)
        return;
    
    UnmapViewOfFile(file->memoyMapAddress);
    CloseHandle(file->memoryMapHandle);
    file->memoryMapHandle = 0;
}
