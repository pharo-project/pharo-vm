function(find_system_SDL2)
    message(STATUS "Looking for SDL2 in the system")
    # Try to use SDL2 provided .cmake files (see NO_MODULE below)
    include(FindPackageHandleStandardArgs)
    # first specifically look for the CMake config version of SDL2 (either system or package manager)
    # provides two TARGETs SDL2::SDL2 and SDL2::SDL2Main
    # SDL2 already provides a -config.cmake file, then use their configuration elements
    find_package(SDL2 QUIET NO_MODULE)
    if(NOT SDL2_FOUND)
      message(STATUS "SDL2 not found.")
    endif()
    set(SDL2_FOUND ${SDL2_FOUND} PARENT_SCOPE)
endfunction()

function(download_SDL2)
  message(STATUS "Downloading SDL2 binary")
  if(WIN)
    if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "ARM64")
      add_third_party_dependency("SDL2-2.0.5")
    else()
      add_third_party_dependency("SDL2-2.24.1")
    endif()
  elseif(OSX)   
    if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm64")
      add_third_party_dependency("SDL2-2.30.6")
    else()
      add_third_party_dependency("SDL2-2.30.6")    
    endif()
  else() #LINUX
    If(${CMAKE_SYSTEM_PROCESSOR} MATCHES "armv7l" OR (${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64"))
      add_third_party_dependency("SDL2-2.0.14")
    else()
      add_third_party_dependency("SDL2-2.24.1")
    endif()
  endif()
endfunction()

function(build_SDL2)
    message(STATUS "Building SDL2")
  	include(cmake/DownloadProject.cmake)
	download_project(PROJ   SDL2
        GIT_REPOSITORY      https://github.com/pharo-project/SDL2.git
        GIT_TAG             "v2.30.6"
        ${UPDATE_DISCONNECTED_IF_AVAILABLE}
	)
    add_subdirectory(${SDL2_SOURCE_DIR} ${SDL2_BINARY_DIR} EXCLUDE_FROM_ALL)

    set_target_properties(SDL2 PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${LIBRARY_OUTPUT_PATH})

    add_custom_target(SDL2_copy
			COMMAND ${CMAKE_COMMAND} -E create_symlink libSDL2-2.0.dylib ${LIBRARY_OUTPUT_PATH}/libSDL2-2.0.0.dylib
    )
    add_dependencies(SDL2_copy SDL2)
    add_dependencies(${VM_LIBRARY_NAME} SDL2_copy)
    set(SDL2_FOUND "From build_SDL2" PARENT_SCOPE)
endfunction()

if (BUILD_BUNDLE)
  if(DEPENDENCIES_FORCE_BUILD)
    build_SDL2()
  elseif(PHARO_DEPENDENCIES_PREFER_DOWNLOAD_BINARIES)
    #Download SDL2 binaries directly
    download_SDL2()
  else()
    #Look for SDL2 in the system, then build or download if possible
    find_system_SDL2()

    if(NOT SDL2_FOUND)
      # Only build SDL if we are in MSVC, otherwise, download
      if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        set(SHOULD_BUILD_SDL FALSE)
      else()
        set(SHOULD_BUILD_SDL TRUE)
      endif()
      if (SHOULD_BUILD_SDL)
        build_SDL2()
      else()
        download_SDL2()
      endif()
    else()
      # SDL2 found, get the library location from the SDL2 CMake exported properties
      get_target_property(SDL2_LIBDIR SDL2::SDL2 IMPORTED_LOCATION)
      # SDL2_LIBDIR now contains the full path to the library including the file (.so/.dll/.dylib)
      message(STATUS "Using system libSDL2 from ${SDL2_LIBDIR}")  
	  endif()
  endif()
endif()
