function(find_system_SDL2)
    message(STATUS "Looking for SDL2 in the system")
    find_package(SDL2)
    if(NOT SDL2_FOUND)
      message(STATUS "SDL2 not found.")
    endif()
    set(SDL2_FOUND ${SDL2_FOUND} PARENT_SCOPE)
endfunction()

function(download_SDL2)
  message(STATUS "Downloading SDL2 binary")
  if(WIN)
    add_third_party_dependency("SDL2-2.0.5")
  elseif(OSX)   
    if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm64")
      add_third_party_dependency("SDL2-2.0.14")
    else()
      add_third_party_dependency("SDL2-2.0.7")    
    endif()
  else() #LINUX
    If(${CMAKE_SYSTEM_PROCESSOR} MATCHES "armv7l" OR (${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64") OR (${CMAKE_SYSTEM_PROCESSOR} MATCHES "i686"))
      add_third_party_dependency("SDL2-2.0.14")
    else()
      add_third_party_dependency("SDL2-2.0.7")
    endif()
  endif()
endfunction()

function(build_SDL2)
    message(STATUS "Building SDL2")
  	include(cmake/DownloadProject.cmake)
	download_project(PROJ   SDL2
        GIT_REPOSITORY      https://github.com/pharo-project/SDL2.git
        GIT_TAG             "v2.0.12"
        ${UPDATE_DISCONNECTED_IF_AVAILABLE}
	)
    add_subdirectory(${SDL2_SOURCE_DIR} ${SDL2_BINARY_DIR} EXCLUDE_FROM_ALL)

    set_target_properties(SDL2 PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${EXECUTABLE_OUTPUT_PATH})
    add_dependencies(${VM_LIBRARY_NAME} SDL2)
    set(SDL2_FOUND "From build_SDL2" PARENT_SCOPE)
endfunction()

if (BUILD_BUNDLE)
  #Only get SDL2 if required
  if(PHARO_DEPENDENCIES_PREFER_DOWNLOAD_BINARIES)
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
    endif()
  endif()
endif()
