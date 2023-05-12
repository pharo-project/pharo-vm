function(find_system_Freetype)
  message(STATUS "Looking for Freetype in the system")
  find_package(Freetype)
  if(Freetype_FOUND)
    add_dependencies(${VM_LIBRARY_NAME} Freetype::Freetype)
  else()
    message(STATUS "Freetype not found.")
  endif()
  set(Freetype_FOUND ${Freetype_FOUND} PARENT_SCOPE)
endfunction()

function(download_Freetype)
  if (WIN)
    if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "ARM64")
      add_third_party_dependency("freetype-2.9.1")
    else()
      add_third_party_dependency("freetype-2.12.1")
      add_third_party_dependency("fontconfig-2.13.1")
      add_third_party_dependency("harfbuzz-5.3.1")
    endif()
  elseif(OSX)
    If(${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm64")
      add_third_party_dependency("freetype-2.12.1")
      add_third_party_dependency("fontconfig-2.13.1")
      add_third_party_dependency("harfbuzz-5.3.1")
    else()
      add_third_party_dependency("freetype-2.12.1")
      add_third_party_dependency("fontconfig-2.13.1")
      add_third_party_dependency("harfbuzz-5.3.1")
    endif()
  else() # linuxes, only for ARM
    If(${CMAKE_SYSTEM_PROCESSOR} MATCHES "armv7l" OR (${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64")  OR (${CMAKE_SYSTEM_PROCESSOR} MATCHES "i686"))
      add_third_party_dependency("freetype-2.10.0")
    else()
      add_third_party_dependency("freetype-2.12.1")
      add_third_party_dependency("fontconfig-2.13.1")
      add_third_party_dependency("harfbuzz-5.3.1")
    endif()
  endif()
endfunction()

function(build_Freetype)
  message(STATUS "Building Freetype")

  include(cmake/DownloadProject.cmake)

  download_project(PROJ                freetype
               URL      https://download.savannah.gnu.org/releases/freetype/freetype-2.10.0.tar.gz
               ${UPDATE_DISCONNECTED_IF_AVAILABLE}
  )

  set(DISABLE_FORCE_DEBUG_POSTFIX ON)

  # Store the old value of the 'BUILD_SHARED_LIBS'
  set(BUILD_SHARED_LIBS_OLD ${BUILD_SHARED_LIBS})
  # Make subproject to use 'BUILD_SHARED_LIBS=ON' setting.
  set(BUILD_SHARED_LIBS ON CACHE INTERNAL "Build SHARED libraries")

  add_subdirectory(${freetype_SOURCE_DIR} ${freetype_BINARY_DIR} EXCLUDE_FROM_ALL)

  # Restore the old value of the parameter
  set(BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS_OLD} CACHE BOOL "Type of libraries to build" FORCE)
  
  #set_target_properties(${NAME} PROPERTIES MACOSX_RPATH ON)
  set_target_properties(freetype PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${EXECUTABLE_OUTPUT_PATH})
  #set_target_properties(${NAME} PROPERTIES INSTALL_NAME_DIR "@executable_path/Plugins")

  add_dependencies(${VM_LIBRARY_NAME} freetype)
endfunction()

if (BUILD_BUNDLE)
  #Only get Freetype if required
  if(PHARO_DEPENDENCIES_PREFER_DOWNLOAD_BINARIES)
    #Download Freetype binaries directly
    download_Freetype()
  else()
    #Look for Freetype in the system, then build or download if possible
    find_system_Freetype()
    if(NOT Freetype_FOUND)
        build_Freetype()
    endif()
  endif()
endif()
