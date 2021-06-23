message(STATUS "Building executable named ${VM_EXECUTABLE_NAME}")

add_executable(${VM_EXECUTABLE_NAME} ${VM_FRONTEND_APPLICATION_TYPE} ${VM_FRONTEND_SOURCES})

#If in OSX, configure creation of Bundle
if(OSX)
  set_target_properties(
    ${VM_EXECUTABLE_NAME}
    PROPERTIES
    MACOSX_BUNDLE YES
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/resources/mac/Info.plist.in"
  )
endif()

target_link_libraries(${VM_EXECUTABLE_NAME} ${VM_LIBRARY_NAME})


# Packaging Setup

include(cmake/packaging.cmake)