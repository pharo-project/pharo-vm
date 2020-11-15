# VMMaker support file
#
# Manage the pharo-vm to C generation
#
# This support file defines the following variables
#
#     PHARO_VM_SLANG_VM_SOURCE_FILES        - a list of generated VM files
#     PHARO_VM_SLANG_PLUGIN_GENERATED_FILES - a list of generated plugin files
#
# and the following targets
#
#     generate_sources
#     vmmaker
#
# TODOs:
#  - Check at configure time that wget/curl are available? Otherwise this crashes miserably
#  - Make the VMFlavours autodescribed? Slang could output a list of generated files that we could use

#Setting output directories
set(VMMAKER_OUTPUT_PATH "build/vmmaker")
make_directory(${VMMAKER_OUTPUT_PATH})

message("DID WE GET HERE? ${GENERATE_PHARO_VM}")  

if (GENERATE_PHARO_VM) 
    message("DOWNLOAD PHARO VM FOR CODE GENERATION")  
	set(VMMAKER_PHARO_VM ${GENERATE_PHARO_VM})
else()
    message("DOWNLOAD PHARO VM") 
    #Platform specific VM info
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        #Build system configuration management advises explicit components
        #rather than standard zero-config scripts that can drift
        set(VMMAKER_PHARO_VM ${VMMAKER_OUTPUT_PATH}/pharo.exe)
        set(VM_URL_DIR https://files.pharo.org/vm/pharo-spur64/win/)
        set(VM_URL_FILE PharoVM-8.6.1-e829a1da-StockReplacement-win64-bin_signed.zip) #2020/11/15 matches https://files.pharo.org/get-files/90/pharo64-win-stable.zip
        set(VM_ARCHIVE_HASH d24a2fb5d8d744a4c8ce0bc332051960d6f5d8db9f75754317b5aee8eafb7cb1)
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
        message(FATAL_ERROR "TODO - CMAKE_HOST_SYSTEM_NAME ${CMAKE_HOST_SYSTEM_NAME}")
        set(VMMAKER_PHARO_VM TODO)
        set(VM_URL_DIR TODO)
        set(VM_URL_FILE TODO)
        set(VM_ARCHIVE_HASH TODO)
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
        message(FATAL_ERROR "TODO - CMAKE_HOST_SYSTEM_NAME ${CMAKE_HOST_SYSTEM_NAME}")
        set(VMMAKER_PHARO_VM TODO)
        set(VM_URL_DIR TODO)
        set(VM_URL_FILE TODO)
        set(VM_ARCHIVE_HASH TODO)
   else()
        message(FATAL_ERROR "VM DOWNLOAD NOT HANDLED FOR CMAKE HOST SYSTEM: ${CMAKE_HOST_SYSTEM_NAME}")
    endif()
    #Common download method for all platforms
    set(VM_DOWNLOADED_FILE download/${VM_URL_FILE})
    if(NOT EXISTS ${VM_DOWNLOADED_FILE})
        message("DOWNLOADING PHARO VM ${VM_URL_DIR}/${VM_URL_FILE}")
        file(DOWNLOAD ${VM_URL_DIR}/${VM_URL_FILE} ${VM_DOWNLOADED_FILE} SHOW_PROGRESS)
    endif()
    #Check download successful
    file(SHA256 ${VM_DOWNLOADED_FILE} VM_DOWNLOADED_HASH)
    if(NOT VM_ARCHIVE_HASH STREQUAL VM_DOWNLOADED_HASH)
        message(FATAL_ERROR "POSSIBLY INTERUPTED OR CORRUPT DOWNLOAD: ${CMAKE_CURRENT_SOURCE_DIR}/${VM_DOWNLOADED_FILE} HASH_${VM_DOWNLOADED_HASH}")
    endif()
    file(ARCHIVE_EXTRACT 
        INPUT ${VM_DOWNLOADED_FILE}
        DESTINATION ${VMMAKER_OUTPUT_PATH})
    if(NOT EXISTS ${VMMAKER_PHARO_VM})
        message(FATAL_ERROR "NO DOWNLOAD VM AVAILABLE: ${VMMAKER_PHARO_VM}")
    endif()

    #Cross platform image info
    message("DOWNLOAD PHARO IMAGE FOR CODE GENERATION") 
    set(IMAGE_URL_DIR https://files.pharo.org/image/90/)
    set(IMAGE_URL_FILE Pharo9.0-SNAPSHOT.build.839.sha.099690e.arch.64bit.zip) #2020/11/15 matches https://files.pharo.org/get-files/90/pharo64.zip 
    set(IMAGE_ARCHIVE_HASH 00c489f0516005d7ba7be259673eab1225ad9a4d1f90df9ce5082cbce4b47b82)
    #Common download method for all platforms
    set(IMAGE_DOWNLOADED_FILE download/${IMAGE_URL_FILE})
    if(NOT EXISTS ${IMAGE_DOWNLOADED_FILE})
        message("DOWNLOADING PHARO VM ${IMAGE_URL_DIR}/${IMAGE_URL_FILE}")
        file(DOWNLOAD ${IMAGE_URL_DIR}/${IMAGE_URL_FILE} ${IMAGE_DOWNLOADED_FILE} SHOW_PROGRESS)
    endif()
    #Check download successful
    file(SHA256 ${IMAGE_DOWNLOADED_FILE} IMAGE_DOWNLOADED_HASH)
    if(NOT IMAGE_ARCHIVE_HASH STREQUAL IMAGE_DOWNLOADED_HASH)
        message(FATAL_ERROR "POSSIBLY INTERUPTED OR CORRUPT DOWNLOAD: ${CMAKE_CURRENT_SOURCE_DIR}/${IMAGE_DOWNLOADED_FILE} HASH_${IMAGE_DOWNLOADED_HASH}")
    endif()
    file(ARCHIVE_EXTRACT 
        INPUT ${IMAGE_DOWNLOADED_FILE}
        DESTINATION ${VMMAKER_OUTPUT_PATH})

    #message(FATAL_ERROR "USE DOWNLOADED IMAGE") 
endif()


#The list of generated files given the flavour
if(FLAVOUR MATCHES "StackVM")
    if(FEATURE_GNUISATION)
        set(VMSOURCEFILES ${GENERATED_SOURCE_DIR}/generated/vm/src/gcc3x-interp.c)
    else()
        set(VMSOURCEFILES ${GENERATED_SOURCE_DIR}/generated/vm/src/interp.c)
    endif()
else()
  set(PHARO_VM_SLANG_VM_SOURCE_FILES
    ${GENERATED_SOURCE_DIR}/generated/vm/src/cogit.c
    ${GENERATED_SOURCE_DIR}/generated/vm/src/gcc3x-cointerp.c)
endif()

set(PHARO_VM_SLANG_PLUGIN_GENERATED_FILES 
  	${GENERATED_SOURCE_DIR}/generated/plugins/src/FilePlugin/FilePlugin.c)


#Custom command that downloads a Pharo image and VM in ${VMMAKER_OUTPUT_PATH}
if(NOT GENERATE_PHARO_VM) 
  add_custom_command(
    OUTPUT ${VMMAKER_OUTPUT_PATH}/Pharo.image ${VMMAKER_OUTPUT_PATH}/pharo
    COMMAND wget -O - https://get.pharo.org/64/90 | bash
    COMMAND wget -O - https://get.pharo.org/64/vm90 | bash
    WORKING_DIRECTORY ${VMMAKER_OUTPUT_PATH}
    COMMENT "Downloading Pharo 90")
else()
  add_custom_command(
    OUTPUT ${VMMAKER_OUTPUT_PATH}/Pharo.image ${VMMAKER_OUTPUT_PATH}/pharo
    COMMAND wget -O - https://get.pharo.org/64/90 | bash
    WORKING_DIRECTORY ${VMMAKER_OUTPUT_PATH}
    COMMENT "Downloading Pharo 90")
endif()


add_custom_command(
  OUTPUT ${VMMAKER_OUTPUT_PATH}/VMMaker.image
  COMMAND ${VMMAKER_PHARO_VM} Pharo.image --save --quit ${CMAKE_CURRENT_SOURCE_DIR_TO_OUT}/scripts/installVMMaker.st ${CMAKE_CURRENT_SOURCE_DIR_TO_OUT}
  COMMAND ${VMMAKER_PHARO_VM} Pharo.image save VMMaker
  DEPENDS ${VMMAKER_OUTPUT_PATH}/Pharo.image
  WORKING_DIRECTORY ${VMMAKER_OUTPUT_PATH}
  COMMENT "Generating VMMaker image")

#Custom command that generates the vm source code from VMMaker into ${VMMAKER_OUTPUT_PATH} and copies it to ${CMAKE_CURRENT_SOURCE_DIR}
if (NOT GENERATE_PHARO_VM)
  add_custom_command(
    OUTPUT ${VMSOURCEFILES} ${PLUGIN_GENERATED_FILES}
    COMMAND ${VMMAKER_OUTPUT_PATH}/pharo ${VMMAKER_OUTPUT_PATH}/VMMaker.image eval \"PharoVMMaker generate: \#\'${FLAVOUR}\' outputDirectory: \'${CMAKE_CURRENT_BINARY_DIR_TO_OUT}\'\"
    DEPENDS ${VMMAKER_OUTPUT_PATH}/VMMaker.image
    COMMENT "Generating VM files for flavour: ${FLAVOUR}")
else()
  add_custom_command(
    OUTPUT ${VMSOURCEFILES} ${PLUGIN_GENERATED_FILES}
    COMMAND ${VMMAKER_PHARO_VM} ${VMMAKER_OUTPUT_PATH}/VMMaker.image eval \"PharoVMMaker generate: \#\'${FLAVOUR}\' outputDirectory: \'${CMAKE_CURRENT_BINARY_DIR_TO_OUT}\'\"
    DEPENDS ${VMMAKER_OUTPUT_PATH}/VMMaker.image
    COMMENT "Generating VM files for flavour: ${FLAVOUR}")
endif()

#Define generated files as elements in the c-src component for packaging
install(DIRECTORY
  ${CMAKE_CURRENT_BINARY_DIR}/generated/
  DESTINATION pharo-vm/generated/
  COMPONENT c-src)

install(FILES
  ${VMSOURCEFILES}
  DESTINATION vm
  COMPONENT generated-src)
  
install(FILES
  ${PLUGIN_GENERATED_FILES}
  DESTINATION plugins
  COMPONENT generated-src)
  
install(
  DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/generated/vm/include/"
  DESTINATION vm/include
  COMPONENT generated-src
  FILES_MATCHING PATTERN *.h)

install(
  DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/generated/vm/include/"
  DESTINATION include/pharovm
  COMPONENT include
  FILES_MATCHING PATTERN *.h)

add_custom_target(vmmaker DEPENDS ${VMMAKER_OUTPUT_PATH}/VMMaker.image)
add_custom_target(generate-sources DEPENDS ${VMSOURCEFILES} ${PLUGIN_GENERATED_FILES})