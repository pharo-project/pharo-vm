macro(get_commit_hash VARNAME)
    execute_process(
        COMMAND git log -1 --format=%h
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE ${VARNAME}
        OUTPUT_STRIP_TRAILING_WHITESPACE)
endmacro()

macro(get_git_describe VARNAME)
    execute_process(
        COMMAND git describe --always
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE ${VARNAME}
        OUTPUT_STRIP_TRAILING_WHITESPACE)
endmacro()

macro(get_git_date VARNAME)
    execute_process(
        COMMAND git log -1 --format=%ai
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE ${VARNAME}
        OUTPUT_STRIP_TRAILING_WHITESPACE)
endmacro()

macro(extractVCSInformation COMMIT_VARNAME DESCRIBE_VARNAME COMMIT_DATE_VARNAME)
	get_commit_hash(${COMMIT_VARNAME})
	get_git_describe(${DESCRIBE_VARNAME})
	get_git_date(${COMMIT_DATE_VARNAME})

	if("${${COMMIT_VARNAME}}" STREQUAL "")
		#If I don't have information I try to get it from the version.info file next to the sources (if one)
		message(STATUS "I couldn't get version information from git, using the version.info next to the sources")
		file(STRINGS ${CMAKE_CURRENT_SOURCE_DIR}/version.info FILECONTENT LIMIT_COUNT 3)
		list(GET FILECONTENT 0 ${COMMIT_VARNAME})
		list(GET FILECONTENT 1 ${DESCRIBE_VARNAME})
		list(GET FILECONTENT 2 ${COMMIT_DATE_VARNAME})
	else()
		#If I have information for the Commit ID, I store it in the version.info file
		file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/version.info ${${COMMIT_VARNAME}}\n)
		file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/version.info ${${DESCRIBE_VARNAME}}\n)
		file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/version.info ${${COMMIT_DATE_VARNAME}})
	endif()
endmacro()
