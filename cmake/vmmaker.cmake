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
    set( VMMAKER_DIR    "${CMAKE_CURRENT_BINARY_DIR}/build/vmmaker")

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
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Windows-x86_64/PharoVM-10.3.2-b8793dd2-Windows-x86_64-bin.zip)
            set(VM_URL_HASH SHA256=f9ae01d7d3fcd2fae2d4d5ffdfa7a5ff6780f390e2a534bcfdc6c10bc1819ef5)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND (${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64"))
            message("Defining Linux AARCH64 VM to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Linux-aarch64/PharoVM-10.3.2-b8793dd2-Linux-aarch64-bin.zip)
            set(VM_URL_HASH      SHA256=2fe44aab3715f26378796bef835fc1bd51da0baa02aad3fee03610926e80a59f)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND (${CMAKE_SYSTEM_PROCESSOR} MATCHES "armv7l"))
            message("Defining Linux ARM 32 VM to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur32-headless/Linux-armv7l/PharoVM-10.3.2-b8793dd2-Linux-armv7l-bin.zip)
            set(VM_URL_HASH      SHA256=b08fdf80c21fa81d61cf8ee71abd741fc192e4a7210f20185a48ed108dfa402f)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
            message("Defining Linux VM x86_64 to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Linux-x86_64/PharoVM-10.3.1-6cdb1e5-Linux-x86_64-bin.zip)
            set(VM_URL_HASH      SHA256=a12f955f553ffed4d669b4dba6f4c16e8c094346253d8f3ebd1fe377e529fa55)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin" AND (${CMAKE_SYSTEM_PROCESSOR} MATCHES "arm64"))
            message("Defining arm64 OSX VM to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/Contents/MacOS/Pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Darwin-arm64/PharoVM-10.3.2-b8793dd2-Darwin-arm64-bin.zip)
            set(VM_URL_HASH      SHA256=157837d765435597bdf05f1054aabe5287e59ca6360b7827c8750a5f7fcef7e3)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
            message("Defining OSX VM to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/Contents/MacOS/Pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Darwin-x86_64/PharoVM-10.3.2-b8793dd2-Darwin-x86_64-bin.zip)
            set(VM_URL_HASH      SHA256=38794ac10d758123ef618c84a0a37e98cb700a175d23eadccabf56a1ff9c688a)
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

	set(IMAGE_PATH ${VMMAKER_DIR}/image/Pharo12.0-SNAPSHOT-64bit-92f3bb989f.image)

	convert_cygwin_path_ifNeeded(${IMAGE_PATH} IMAGE_PATH_TO_USE)
	convert_cygwin_path_ifNeeded(${VMMAKER_IMAGE} VMMAKER_IMAGE_TO_USE)
	convert_cygwin_path_ifNeeded(${CMAKE_CURRENT_SOURCE_DIR} CMAKE_CURRENT_SOURCE_DIR_OUT)
	convert_cygwin_path_ifNeeded(${CMAKE_CURRENT_BINARY_DIR} CMAKE_CURRENT_BINARY_DIR_OUT)

    if(GENERATE_VMMAKER)
        #Bootstrap VMMaker.image from downloaded plain Pharo image
		
        ExternalProject_Add(
            vmmaker

            URL https://files.pharo.org/image/120/Pharo12.0-SNAPSHOT.build.1551.sha.92f3bb989f.arch.64bit.zip
            URL_HASH SHA256=fd84c9f345d806389ecdad52f63eeb8bad7f983c99c5e010d83cf2d12ca97766
            BUILD_COMMAND ${VMMAKER_VM} --headless ${IMAGE_PATH_TO_USE} --no-default-preferences save VMMaker
	    COMMAND ${VMMAKER_VM} --headless ${VMMAKER_IMAGE_TO_USE} --no-default-preferences --save --quit "${CMAKE_CURRENT_SOURCE_DIR_OUT}/scripts/installVMMaker.st" "${CMAKE_CURRENT_SOURCE_DIR_OUT}" "${ICEBERG_DEFAULT_REMOTE}"
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
        COMMAND ${VMMAKER_VM} --headless ${VMMAKER_IMAGE_TO_USE} --no-default-preferences perform PharoVMMaker generate:outputDirectory: ${FLAVOUR} ${CMAKE_CURRENT_BINARY_DIR_OUT}
        VERBATIM
        DEPENDS vmmaker ${VMMAKER_IMAGE} ${VMMAKER_VM}
        COMMENT "Generating VM files for flavour: ${FLAVOUR}")

    add_custom_target(generate-sources DEPENDS ${VMSOURCEFILES} ${PLUGIN_GENERATED_FILES})

endif()
