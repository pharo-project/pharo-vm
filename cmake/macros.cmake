# Include a library in the project, linking it to the main library
macro(addLibraryWithRPATH NAME)

    addIndependentLibraryWithRPATH(${NAME} ${ARGN})

    # Declare the main executable depends on the plugin so it gets built with it
    add_dependencies(${VM_EXECUTABLE_NAME} ${NAME})

    #Declare the plugin depends on the VM core library
    if(NOT "${NAME}" STREQUAL "${VM_LIBRARY_NAME}")
      target_link_libraries(${NAME} PRIVATE ${VM_LIBRARY_NAME})
    endif()
endmacro()

# Include a loose-dependency library in the project, but do not link it to the main library
macro(addIndependentLibraryWithRPATH NAME)
    add_library(${NAME} SHARED ${ARGN})
    set_target_properties(${NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${LIBRARY_OUTPUT_DIRECTORY})
endmacro()

macro(get_platform_name VARNAME)
  # See https://github.com/pharo-project/opensmalltalk-vm/issues/270
  if(${CMAKE_SYSTEM_PROCESSOR} MATCHES "^(AMD64|x64)$")
    set(${VARNAME} ${CMAKE_SYSTEM_NAME}-x86_64)
  else()
    set(${VARNAME} ${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR})
  endif()
endmacro()

macro(get_full_platform_name_with_osx VARNAME)

    if(SIZEOF_VOID_P EQUAL 8)
        set(ARCH 64)
    else()
        set(ARCH 32)
    endif()

    if(WIN)
        set(${VARNAME} "win${ARCH}")
    else()
        if(OSX)
            set(${VARNAME} "osx${ARCH}")
        else()
            set(${VARNAME} "linux${ARCH}")
        endif()
    endif()
endmacro()

macro(convert_cygwin_path_ifNeeded INPUT OUTVARNAME)
  	# transform the path into a windows path with unix backslashes C:/bla/blu
  	# this is the path required to send as argument to libraries outside of the control of cygwin (like pharo itself)
	if(WIN AND NOT MSVC)
		execute_process(
			COMMAND cygpath ${INPUT} --mixed
			OUTPUT_VARIABLE ${OUTVARNAME}
			OUTPUT_STRIP_TRAILING_WHITESPACE)
	else()
		set(${OUTVARNAME} ${INPUT})
	endif()

endmacro()

# Add a third party dependency taken from the given URL
macro(add_third_party_dependency_with_baseurl NAME BASEURL)

    get_platform_name(PLATNAME)
    message("Adding third-party libraries for ${PLATNAME}: ${NAME}")
    
    include(DownloadProject)
    download_project(PROJ ${NAME}
        URL         "${BASEURL}${NAME}.zip"
        ${UPDATE_DISCONNECTED_IF_AVAILABLE}
    )
    file(GLOB DOWNLOADED_THIRD_PARTY_LIBRARIES
        "${${NAME}_SOURCE_DIR}/*"
    )
    add_custom_target(${NAME})
		foreach(LIBRARY_PATH IN LISTS DOWNLOADED_THIRD_PARTY_LIBRARIES)
      message(STATUS ${LIBRARY_PATH})
      add_custom_command(TARGET ${NAME}
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy "${LIBRARY_PATH}" "${LIBRARY_OUTPUT_DIRECTORY}"
      )
		endforeach()
    add_dependencies(${VM_EXECUTABLE_NAME} ${NAME})
endmacro()

# Add a third party dependency taken from the files.pharo.org repository
macro(add_third_party_dependency NAME)
    if(SIZEOF_VOID_P EQUAL 8)
        set(ARCH 64)
    else()
        set(ARCH 32)
    endif()
    get_platform_name(PLATNAME)
    set(BASE_URL "https://files.pharo.org/vm/pharo-spur${ARCH}/${PLATNAME}/third-party/")
    add_third_party_dependency_with_baseurl(${NAME} ${BASE_URL})
endmacro()


#
# Compatibility with old CMAKE versions to remove, as fast as posible
#

if(${CMAKE_VERSION} VERSION_LESS "3.12.0") 
    message(STATUS "Please consider to switch to CMake 3.12.0 or later")
	
	macro(add_compile_definitions)
		foreach(loop_var ${ARGN})
			add_definitions("-D'${loop_var}'")
		endforeach()
	endmacro()
	
endif()
