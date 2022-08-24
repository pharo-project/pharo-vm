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

set(CMAKE_VERBOSE_MAKEFILE TRUE)

#Setting vmmaker directory and image 
set( VMMAKER_DIR    "${CMAKE_CURRENT_BINARY_DIR_TO_OUT}/build/vmmaker")
set( VMMAKER_IMAGE  "${VMMAKER_DIR}/image/VMMaker.image")

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

    #Setting platform specific vmmaker virtual machine, with cached download or override
    if (GENERATE_PHARO_VM) 
        message("Overriding VM used for code generation")  
        set(VMMAKER_VM ${GENERATE_PHARO_VM})
        # add empty target because is required later when installing vmmaker
        add_custom_target(build_vmmaker_get_vm-build)
    else()
        #Pick platform specific VM to download
        if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
            message("Defining Windows VM to download for code generation")
            set(VMMAKER_VM ${VMMAKER_DIR}/vm/PharoConsole.exe)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Windows-x86_64/PharoVM-9.0.17-9e4879f5-Windows-x86_64-bin.zip)
            set(VM_URL_HASH SHA256=fb5aa8c7adcc12830500933bf8fd1ab6ffb1ccfc534b4e0b0c9d23eecbe639e9)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND (${CMAKE_SYSTEM_PROCESSOR} MATCHES "aarch64"))
            message("Defining Linux AARCH64 VM to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Linux-aarch64/PharoVM-9.0.17-9e4879f-Linux-aarch64-bin.zip)
            set(VM_URL_HASH      SHA256=2fe44aab3715f26378796bef835fc1bd51da0baa02aad3fee03610926e80a59f)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND (${CMAKE_SYSTEM_PROCESSOR} MATCHES "armv7l"))
            message("Defining Linux ARM 32 VM to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur32-headless/Linux-armv7l/PharoVM-9.0.17-9e4879f-Linux-armv7l-bin.zip)
            set(VM_URL_HASH      SHA256=b08fdf80c21fa81d61cf8ee71abd741fc192e4a7210f20185a48ed108dfa402f)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
            message("Defining Linux VM x86_64 to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Linux-x86_64/PharoVM-9.0.17-9e4879f-Linux-x86_64-bin.zip)
            set(VM_URL_HASH      SHA256=be97eff9525a70aca457f2bc77ddd775756c17b7a799adb3b12db7810763403c)
        elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
            message("Defining OSX VM to download for code generation")
            set(VMMAKER_VM       ${VMMAKER_DIR}/vm/Contents/MacOS/Pharo)
            set(VM_URL https://files.pharo.org/vm/pharo-spur64-headless/Darwin-x86_64/PharoVM-9.0.17-9e4879f5-Darwin-x86_64-bin.zip)
            set(VM_URL_HASH      SHA256=920c2dd54a99f54a08d1c02980668188725572cdae6e736588559f23a0523ae3)
        else()
            message(FATAL_ERROR "VM DOWNLOAD NOT HANDLED FOR CMAKE SYSTEM: ${CMAKE_SYSTEM_NAME}")
        endif()

        #Download VM
        ExternalProject_Add(
            build_vmmaker_get_vm

            URL ${VM_URL}
            URL_HASH ${VM_URL_HASH}
            BUILD_COMMAND       echo 
            UPDATE_COMMAND      echo 
            CONFIGURE_COMMAND   echo 
            INSTALL_COMMAND     echo 

            PREFIX "${VMMAKER_DIR}"
            SOURCE_DIR "${VMMAKER_DIR}/vm"
            BUILD_IN_SOURCE True

            STEP_TARGETS   build
            )
    endif()

    #Bootstrap VMMaker.image from downloaded image
    ExternalProject_Add(
            build_vmmaker_get_image

            URL https://files.pharo.org/image/100/Pharo10.0.1-0.build.527.sha.0542643.arch.64bit.zip
            URL_HASH SHA256=f6d87c8aa4d5fa6ac6848cacd6a29d87d5a013df4074aa70083a211f0943b762
            BUILD_COMMAND ${VMMAKER_VM} --headless ${VMMAKER_DIR}/image/Pharo10.0.1-0-64bit-0542643.image --no-default-preferences save VMMaker
            COMMAND ${VMMAKER_VM} --headless ${VMMAKER_IMAGE} --no-default-preferences --save --quit "${CMAKE_CURRENT_SOURCE_DIR_TO_OUT}/scripts/installVMMaker.st" "${CMAKE_CURRENT_SOURCE_DIR_TO_OUT}" "${ICEBERG_DEFAULT_REMOTE}"
            UPDATE_COMMAND      echo 
            CONFIGURE_COMMAND   echo
            INSTALL_COMMAND     echo

            PREFIX "${VMMAKER_DIR}"
            SOURCE_DIR "${VMMAKER_DIR}/image"
            BUILD_IN_SOURCE True
            WORKING_DIRECTORY "${VMMAKER_DIR}"

            DEPENDS build_vmmaker_get_vm-build
            )

    #Custom command that generates the vm source code from VMMaker into "out/build/XXXX/generated" folder
    add_custom_command(
        OUTPUT ${VMSOURCEFILES} ${PLUGIN_GENERATED_FILES}
        COMMAND ${VMMAKER_VM} --headless ${VMMAKER_IMAGE} --no-default-preferences eval \"PharoVMMaker generate: \#\'${FLAVOUR}\' outputDirectory: \'${CMAKE_CURRENT_BINARY_DIR_TO_OUT}\'\"
        DEPENDS build_vmmaker_get_image
        COMMENT "Generating VM files for flavour: ${FLAVOUR}")
    
    add_custom_target(vmmaker DEPENDS build_vmmaker_get_image)
    add_custom_target(generate-sources DEPENDS ${VMSOURCEFILES} ${PLUGIN_GENERATED_FILES})

endif()
