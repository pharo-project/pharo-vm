project(TestLibrary)

include(../macros.cmake)

set(TestLibrary_SOURCES	
	${CMAKE_CURRENT_SOURCE_DIR}/src/basic_types.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/callback_types.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/callbacks.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/callout.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/registerCallback.c
	${CMAKE_CURRENT_SOURCE_DIR}/src/structures.c
)

addIndependentLibraryWithRPATH(TestLibrary ${TestLibrary_SOURCES})

if(${FEATURE_THREADED_FFI})
    target_compile_definitions(TestLibrary PRIVATE FEATURE_THREADED_FFI=1)
endif()


target_include_directories(TestLibrary
PRIVATE
	${CMAKE_CURRENT_SOURCE_DIR}/includes
)

if(${CYGWIN})
	target_link_libraries(TestLibrary pthread)
endif()
