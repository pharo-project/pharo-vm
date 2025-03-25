include(cmake/plugins.macros.cmake)

add_vm_plugin(FilePlugin TRUE TRUE)
if(OSX)
    target_link_libraries(FilePlugin PRIVATE "-framework CoreFoundation")
endif()
if(WIN)
    target_compile_definitions(FilePlugin PRIVATE "-DWIN32_FILE_SUPPORT")
endif()


add_vm_plugin(FileAttributesPlugin FALSE TRUE)
target_link_libraries(FileAttributesPlugin PRIVATE FilePlugin)


# UUIDPlugin

if(NOT OPENBSD)
    message(STATUS "Adding plugin: UUIDPlugin")

    file(GLOB UUIDPlugin_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/plugins/UUIDPlugin/common/*.c
    )

    addLibraryWithRPATH(UUIDPlugin ${UUIDPlugin_SOURCES})
    if(WIN)
        target_link_libraries(UUIDPlugin PRIVATE "-lole32")
    elseif(UNIX AND NOT OSX)
       #find_path(LIB_UUID_INCLUDE_DIR uuid.h PATH_SUFFIXES uuid)
        find_library(LIB_UUID_LIBRARY uuid)
        message(STATUS "Using uuid library:" ${LIB_UUID_LIBRARY})
        target_link_libraries(UUIDPlugin PRIVATE ${LIB_UUID_LIBRARY})
    endif()
endif()

# Socket Plugin
if (${FEATURE_NETWORK})
    add_vm_plugin(SocketPlugin FALSE FALSE)
  if(WIN)
    target_link_libraries(SocketPlugin PRIVATE "-lWs2_32")
  endif()
endif()

add_vm_plugin(SurfacePlugin TRUE FALSE)
add_vm_plugin(FloatArrayPlugin TRUE FALSE)
add_vm_plugin(LargeIntegers FALSE FALSE)
add_vm_plugin(JPEGReaderPlugin FALSE FALSE)
add_vm_plugin(JPEGReadWriter2Plugin FALSE FALSE)
add_vm_plugin(MiscPrimitivePlugin FALSE FALSE)
add_vm_plugin(DSAPrims FALSE FALSE)
add_vm_plugin(BitBltPlugin FALSE FALSE)
add_vm_plugin(B2DPlugin FALSE FALSE)

add_vm_plugin(LocalePlugin FALSE TRUE)
if(OSX)
	target_link_libraries(LocalePlugin PRIVATE "-framework CoreFoundation")
endif()

add_vm_plugin(SqueakSSL FALSE FALSE)
if(OSX)
    target_link_libraries(SqueakSSL PRIVATE "-framework CoreFoundation")
    target_link_libraries(SqueakSSL PRIVATE "-framework Security")
elseif(WIN)
    target_link_libraries(SqueakSSL PRIVATE Crypt32 Secur32)
else()
    find_package(OpenSSL REQUIRED)
    target_link_libraries(SqueakSSL PRIVATE OpenSSL::SSL OpenSSL::Crypto)
endif()

# UnixOSProcessPlugin
if(NOT WIN)
    add_vm_plugin(UnixOSProcessPlugin FALSE FALSE)
    target_link_libraries(UnixOSProcessPlugin PRIVATE FilePlugin)
    target_link_libraries(UnixOSProcessPlugin PRIVATE SocketPlugin)
endif()
