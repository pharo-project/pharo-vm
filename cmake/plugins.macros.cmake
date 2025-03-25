macro(add_vm_plugin NAME GENERATED MACOS_AS_UNIX)
    message(STATUS "Adding plugin ${NAME} including generated code ${GENERATED}")

    if(OSX)
        file(GLOB ${NAME}_SOURCES
            ${CMAKE_CURRENT_SOURCE_DIR}/plugins/${NAME}/src/common/*.c   
            ${CMAKE_CURRENT_SOURCE_DIR}/plugins/${NAME}/src/osx/*.c   
        )
        if(${MACOS_AS_UNIX})
            file(GLOB ${NAME}_SOURCES_UNIX ${CMAKE_CURRENT_SOURCE_DIR}/plugins/${NAME}/src/unix/*.c)
            list (APPEND ${NAME}_SOURCES ${${NAME}_SOURCES_UNIX})
        endif()
    elseif(UNIX)
        file(GLOB ${NAME}_SOURCES
            ${CMAKE_CURRENT_SOURCE_DIR}/plugins/${NAME}/src/common/*.c   
            ${CMAKE_CURRENT_SOURCE_DIR}/plugins/${NAME}/src/unix/*.c 
        )         
    else()
        file(GLOB ${NAME}_SOURCES
            ${CMAKE_CURRENT_SOURCE_DIR}/plugins/${NAME}/src/common/*.c   
            ${CMAKE_CURRENT_SOURCE_DIR}/plugins/${NAME}/src/win/*.c 
        )                 
    endif()

    if(${GENERATED})
        list(APPEND ${NAME}_SOURCES "${PHARO_CURRENT_GENERATED}/plugins/src/${NAME}/${NAME}.c")
    endif()

    addLibraryWithRPATH(${NAME} ${${NAME}_SOURCES})

    target_include_directories(${NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/plugins/${NAME}/include/common)
    if(OSX)
        target_include_directories(${NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/plugins/${NAME}/include/osx)
        if(${MACOS_AS_UNIX})
            target_include_directories(${NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/plugins/${NAME}/include/unix)
            message(STATUS "HEREEE ${CMAKE_CURRENT_SOURCE_DIR}/plugins/${NAME}/include/unix")
        endif()
    elseif(UNIX)
        target_include_directories(${NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/plugins/${NAME}/include/unix)
    else() #Windows
        target_include_directories(${NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/plugins/${NAME}/include/win)
    endif()
endmacro()