function(add_platform_headers)
target_include_directories(${VM_LIBRARY_NAME}
PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/extracted/vm/include/unix
    ${CMAKE_CURRENT_SOURCE_DIR}/extracted/vm/include/common
)
endfunction() #add_platform_headers

set(EXTRACTED_SOURCES
#Common sources
    ${CMAKE_CURRENT_SOURCE_DIR}/extracted/vm/src/common/sqHeapMap.c
    ${CMAKE_CURRENT_SOURCE_DIR}/extracted/vm/src/common/sqVirtualMachine.c
    ${CMAKE_CURRENT_SOURCE_DIR}/extracted/vm/src/common/sqNamedPrims.c
    ${CMAKE_CURRENT_SOURCE_DIR}/extracted/vm/src/common/sqExternalSemaphores.c
    ${CMAKE_CURRENT_SOURCE_DIR}/extracted/vm/src/common/sqTicker.c

#Platform sources
    ${CMAKE_CURRENT_SOURCE_DIR}/extracted/vm/src/unix/aio.c
    ${CMAKE_CURRENT_SOURCE_DIR}/src/debugUnix.c

#Virtual Memory functions
    ${CMAKE_CURRENT_SOURCE_DIR}/src/memoryUnix.c

# Support sources
    ${CMAKE_CURRENT_SOURCE_DIR}/src/fileDialogUnix.c
)

set(VM_FRONTEND_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/unixMain.c)

macro(add_third_party_dependencies_per_platform)
	if(${FEATURE_LIB_GIT2})
        include(cmake/importLibGit2.cmake)
    endif()

    if(${FEATURE_LIB_FREETYPE2})
        include(cmake/importFreetype2.cmake)
    endif()

    if(${FEATURE_LIB_CAIRO})
        include(cmake/importCairo.cmake)
    endif()

    if(${FEATURE_LIB_SDL2})
        include(cmake/importSDL2.cmake)
    endif()
endmacro()

macro(configure_installables INSTALL_COMPONENT)
    install(
        TARGETS ${VM_EXECUTABLE_NAME}
        COMPONENT ${INSTALL_COMPONENT})
    install(
        TARGETS ${VM_LIBRARY_NAME}
        COMPONENT ${INSTALL_COMPONENT}
        INCLUDES DESTINATION "include/pharovm")
    install(
        TARGETS ${VM_PLUGIN_TARGETS}
        COMPONENT ${INSTALL_COMPONENT})
endmacro()

macro(add_required_libs_per_platform)
  target_link_libraries(${VM_LIBRARY_NAME} dl)
  target_link_libraries(${VM_LIBRARY_NAME} m)
  target_link_libraries(${VM_LIBRARY_NAME} pthread)
endmacro()
