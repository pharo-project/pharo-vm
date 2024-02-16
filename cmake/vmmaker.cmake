# VMMaker support file
#
# Manage the pharo-vm to C generation
#
# This support file defines the following variables
#
#     VMSOURCEFILES        - a list of generated VM files
#     PLUGIN_GENERATED_FILES - a list of generated plugin files
#
# and the following targets
#
#     generate-sources
#     vmmaker
#
# TODOs:
#  - Make the VMFlavours autodescribed? Slang could output a list of generated files that we could use


if(${SIZEOF_VOID_P} STREQUAL "8")
    set(PHARO_CURRENT_GENERATED ${GENERATED_SOURCE_DIR}/generated/64)
else()
    set(PHARO_CURRENT_GENERATED ${GENERATED_SOURCE_DIR}/generated/32)
endif()

#If not StackVM, include also JIT related files
if(FLAVOUR MATCHES "StackVM")
  if(${FEATURE_COMPILE_GNUISATION})
      set(VMSOURCEFILES ${PHARO_CURRENT_GENERATED}/vm/src/gcc3x-interp.c)
  else()
      set(VMSOURCEFILES ${PHARO_CURRENT_GENERATED}/vm/src/interp.c)
  endif()
else()
  list(APPEND VMSOURCEFILES ${PHARO_CURRENT_GENERATED}/vm/src/cogit.c)
  if(${FEATURE_COMPILE_GNUISATION})
      list(APPEND VMSOURCEFILES ${PHARO_CURRENT_GENERATED}/vm/src/gcc3x-cointerp.c)
  else()
      list(APPEND VMSOURCEFILES ${PHARO_CURRENT_GENERATED}/vm/src/cointerp.c)
  endif()
endif()

set(PLUGIN_GENERATED_FILES 
    ${PHARO_CURRENT_GENERATED}/plugins/src/FilePlugin/FilePlugin.c
    ${PHARO_CURRENT_GENERATED}/plugins/src/SurfacePlugin/SurfacePlugin.c
    ${PHARO_CURRENT_GENERATED}/plugins/src/FloatArrayPlugin/FloatArrayPlugin.c)

if(GENERATE_SOURCES)

    #Setting vmmaker directory and image
    set( VMMAKER_DIR    "${CMAKE_CURRENT_BINARY_DIR_TO_OUT}/build/vmmaker")

    # If we are generating the vmmaker image, set a the image path
    # Otherwise set it with a default, but parametrizable
    if(${GENERATE_VMMAKER})
        set(VMMAKER_IMAGE "${VMMAKER_DIR}/image/VMMaker.image")
    else()
        set(VMMAKER_IMAGE "${VMMAKER_DIR}/image/VMMaker.image" CACHE STRING "Path to the VMMaker image used to generate the C files. Default to ${VMMAKER_DIR}/image/VMMaker.image")
    endif()

    #Setting platform specific vmmaker virtual machine, with cached download or override
    if (GENERATE_PHARO_VM) 
        message("Overriding VM used for code generation")  
        set(VMMAKER_VM ${GENERATE_PHARO_VM})
        # add empty target because is required later when installing vmmaker
	add_custom_target(vmmaker_vm)
    else()
        #Pick platform specific VM to download
        if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
            message("Defining Windows VM to download for code generation")
            set(VMMAKER_VM ${VMMAKER_DIR}/vm/PharoConsole.exe)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Windows-x86_64/PharoVM-10.0.5-2757766f-Windows-x86_64-bin.zip)
            set(VM_URL_HASH SHA256=917dbbef15b870ecf5ecf449bd6be39437985c6e3f056620e9acda60ea58e09e)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND (${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64"))
            message("Defining Linux AARCH64 VM to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Linux-aarch64/PharoVM-10.0.5-2757766-Linux-aarch64-bin.zip)
            set(VM_URL_HASH      SHA256=2fe44aab3715f26378796bef835fc1bd51da0baa02aad3fee03610926e80a59f)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND (${CMAKE_SYSTEM_PROCESSOR} MATCHES "armv7l"))
            message("Defining Linux ARM 32 VM to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur32-headless/Linux-armv7l/PharoVM-10.0.5-2757766-Linux-armv7l-bin.zip)
            set(VM_URL_HASH      SHA256=b08fdf80c21fa81d61cf8ee71abd741fc192e4a7210f20185a48ed108dfa402f)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
            message("Defining Linux VM x86_64 to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Linux-x86_64/PharoVM-10.0.5-2757766-Linux-x86_64-bin.zip)
            set(VM_URL_HASH      SHA256=dde65589966e4f547eb0b1b08053504f9663bdb94d520109d053dfcce7921eab)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin" AND (${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm64"))
            message("Defining arm64 OSX VM to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/Contents/MacOS/Pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Darwin-arm64/PharoVM-10.0.5-2757766f-Darwin-arm64-bin.zip)
            set(VM_URL_HASH      SHA256=414ecf82b71a4ed94a95af0fb6e04c0ab09cc7ab3011fcc207af6c1322d0b47b)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
            message("Defining OSX VM to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/Contents/MacOS/Pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Darwin-x86_64/PharoVM-10.0.5-2757766f-Darwin-x86_64-bin.zip)
            set(VM_URL_HASH      SHA256=f0f34c9411e899005749095dbdffdbeaa405ae8864aea81e4bff56331c3959e0)
        else()
            message(FATAL_ERROR "VM DOWNLOAD NOT HANDLED FOR CMAKE SYSTEM: ${CMAKE_SYSTEM_NAME}")
        endif()

        #Download VM
        ExternalProject_Add(
            vmmaker_vm

            URL ${VM_URL}
            URL_HASH ${VM_URL_HASH}
	    BUILD_COMMAND       ""
	    UPDATE_COMMAND      ""
	    CONFIGURE_COMMAND   ""
	    INSTALL_COMMAND     ""

            PREFIX "${VMMAKER_DIR}"
            SOURCE_DIR "${VMMAKER_DIR}/vm"
            BUILD_IN_SOURCE True
            )
    endif()

    if(GENERATE_VMMAKER)
        #Bootstrap VMMaker.image from downloaded plain Pharo image
        ExternalProject_Add(
            vmmaker

            URL https://files.pharo.org/image/110/Pharo11-SNAPSHOT.build.688.sha.cf3d3fd.arch.64bit.zip
            URL_HASH SHA256=c050ddcedce70ec92c22a3244aa5ebbc655dcaffcb42ac80fbf1f6e795c7010d
            BUILD_COMMAND ${VMMAKER_VM} --headless ${VMMAKER_DIR}/image/Pharo11-SNAPSHOT-64bit-cf3d3fd.image --no-default-preferences save VMMaker
	    COMMAND ${VMMAKER_VM} --headless ${VMMAKER_IMAGE} --no-default-preferences --save --quit "${CMAKE_CURRENT_SOURCE_DIR_TO_OUT}/scripts/installVMMaker.st" "${CMAKE_CURRENT_SOURCE_DIR_TO_OUT}" "${ICEBERG_DEFAULT_REMOTE}"
            UPDATE_COMMAND      ""
            CONFIGURE_COMMAND   ""
            INSTALL_COMMAND     ""

            PREFIX "${VMMAKER_DIR}"
            SOURCE_DIR "${VMMAKER_DIR}/image"
            BUILD_IN_SOURCE True
            WORKING_DIRECTORY "${VMMAKER_DIR}"

            DEPENDS vmmaker_vm
            )

    else()
        #Use the given vmimage
	add_custom_target(vmmaker DEPENDS ${VMMAKER_IMAGE})
    endif()

    #Custom command that generates the vm source code from VMMaker into the generated folder
    add_custom_command(
        OUTPUT ${VMSOURCEFILES} ${PLUGIN_GENERATED_FILES}
        COMMAND ${VMMAKER_VM} --headless ${VMMAKER_IMAGE} --no-default-preferences perform PharoVMMaker generate:outputDirectory: ${FLAVOUR} ${CMAKE_CURRENT_BINARY_DIR_TO_OUT}
        VERBATIM
        DEPENDS vmmaker ${VMMAKER_IMAGE} ${VMMAKER_VM}
        COMMENT "Generating VM files for flavour: ${FLAVOUR}")

    add_custom_target(generate-sources DEPENDS ${VMSOURCEFILES} ${PLUGIN_GENERATED_FILES})

endif()
