# - Try to find pthread (win32) define the variables for the binaries/headers and include 
#
# Once done this will define
#  PTHREADW32_FOUND - System has pthread-win32
#  PTHREADW32::lib - Imported target for the pthread-win32

message(STATUS "PTHREADW32_DIR: ${PTHREADW32_DIR}")
find_library(PTHREADW32_LIBRARY NAMES pthreads
    PATHS $ENV{PTHREADW32_DIR} ${PTHREADW32_DIR}
    PATH_SUFFIXES lib
    HINTS ${PC_PTHREADW32_LIBDIR} ${PC_PTHREADW32_LIBRARY_DIRS}
)

find_path(PTHREADW32_INCLUDE_DIR pthread.h
     PATHS $ENV{PTHREADW32_DIR} ${PTHREADW32_DIR}
     PATH_SUFFIXES include
     HINTS ${PC_PTHREADW32_INCLUDEDIR} ${PC_PTHREADW32_INCLUDE_DIRS}
)

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set PTHREADW32_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(PTHREADW32 DEFAULT_MSG
                                  PTHREADW32_LIBRARY PTHREADW32_INCLUDE_DIR)
mark_as_advanced(PTHREADW32_INCLUDE_DIR PTHREADW32_LIBRARY)

set(PTHREADW32_LIBRARIES ${PTHREADW32_LIBRARY})
set(PTHREADW32_INCLUDE_DIRS ${PTHREADW32_INCLUDE_DIR})

if(PTHREADW32_FOUND AND NOT TARGET PTHREADW32::lib)
    add_library(PTHREADW32::lib STATIC IMPORTED)
    set_target_properties(PTHREADW32::lib PROPERTIES
            IMPORTED_LOCATION "${PTHREADW32_LIBRARY}"
            INTERFACE_INCLUDE_DIRECTORIES "${PTHREADW32_INCLUDE_DIR}"
    )
endif()