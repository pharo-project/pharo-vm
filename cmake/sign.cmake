if(OSX)
    set(EXECUTABLE_DIR_TO_SIGN "${EXECUTABLE_OUTPUT_PATH}/${VM_EXECUTABLE_NAME}.app/Contents/Resources")
else()
    set(EXECUTABLE_DIR_TO_SIGN "${EXECUTABLE_OUTPUT_PATH}")
endif()

set(SIGNATURE_FILE "${EXECUTABLE_DIR_TO_SIGN}/pharo.signatures")
set(SIGN_CERT "$ENV{SIGN_CERT}")

set(FIND_ARGS . -type f -maxdepth 1 ! -name 'pharo.signatures' -exec)
set(OPENSSL_COMMAND openssl dgst -sha256 -sign ${SIGN_CERT} -passin env:SIGN_CERT_PASSWORD -r -hex)

set(EXECUTABLES_SIGNATURE_FILE ${CMAKE_CURRENT_BINARY_DIR}/signatures/executables.signatures)
set(LIBRARY_SIGNATURE_FILE ${CMAKE_CURRENT_BINARY_DIR}/signatures/libraries.signatures)
set(LIBRARY_DIR_TO_SIGN "${LIBRARY_OUTPUT_DIRECTORY}")

make_directory(${CMAKE_CURRENT_BINARY_DIR}/signatures)

add_custom_target(sign_libraries
                  COMMAND echo "Signing Libraries in ${LIBRARY_DIR_TO_SIGN} with in file ${LIBRARY_SIGNATURE_FILE}"
                  COMMAND rm -f ${LIBRARY_SIGNATURE_FILE}
                  COMMAND find ${FIND_ARGS} ${OPENSSL_COMMAND} {} "\\;" >> ${LIBRARY_SIGNATURE_FILE}
                  DEPENDS ${VM_EXECUTABLE_NAME} TestLibrary
                  BYPRODUCTS ${LIBRARY_SIGNATURE_FILE}
                  WORKING_DIRECTORY ${LIBRARY_DIR_TO_SIGN})

add_custom_target(sign_executables
                  COMMAND echo "Signing Executables in ${EXECUTABLE_DIR_TO_SIGN} with in file ${EXECUTABLES_SIGNATURE_FILE}"
                  COMMAND rm -f ${EXECUTABLES_SIGNATURE_FILE}
                  COMMAND find ${FIND_ARGS} ${OPENSSL_COMMAND} {} "\\;" >> ${EXECUTABLES_SIGNATURE_FILE}
                  DEPENDS ${VM_EXECUTABLE_NAME}
                  BYPRODUCTS ${EXECUTABLES_SIGNATURE_FILE}
                  WORKING_DIRECTORY ${EXECUTABLE_DIR_TO_SIGN})

add_custom_target(sign
                  COMMAND echo "Combining Signatures in ${SIGNATURE_FILE}"
                  COMMAND cat ${EXECUTABLES_SIGNATURE_FILE} ${LIBRARY_SIGNATURE_FILE} > ${SIGNATURE_FILE}
                  DEPENDS sign_libraries sign_executables
                  BYPRODUCTS ${SIGNATURE_FILE}
                  WORKING_DIRECTORY ${EXECUTABLE_DIR_TO_SIGN})	  
