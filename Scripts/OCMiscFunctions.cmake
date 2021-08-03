##
# The function :command:`log()` can be used to produce screen output as well as write messages to the build log::
#
#     log(MESSAGE [LOGLEVEL])
#
# See also: :ref:`loglevels`
function(log msg)
    #message(STATUS "@@@@@ log(\"${msg}\")")
    if (OC_CONFIG_LOG_LEVELS)
        set(CONFIG_LOG_LEVELS ${OC_CONFIG_LOG_LEVELS})
    else ()
        set(CONFIG_LOG_LEVELS SCREEN WARNING ERROR)
    endif ()
    if (ARGC GREATER 1)
        set(level ${ARGV1})
        set(level_prefix "${level} - ")
    else()
        set(level "SCREEN")
        set(level_prefix "")
    endif()
    # Write to config log file
    if (level IN_LIST CONFIG_LOG_LEVELS AND OC_BUILD_LOG)
        #message(STATUS "@@@@@ writing to file")    
        if (NOT EXISTS "${OC_BUILD_LOG}")
            file(WRITE "${OC_BUILD_LOG}" "${level_prefix}${msg}\r\n")
        else()
            file(APPEND "${OC_BUILD_LOG}" "${level_prefix}${msg}\r\n")
        endif()
    endif()
    # Also write to console output
    if (level STREQUAL "WARNING")
        message(WARNING "${msg}")
    elseif(level STREQUAL "ERROR")
        message(FATAL_ERROR "${msg}")
    elseif (level STREQUAL "SCREEN" OR OC_CONFIG_LOG_TO_SCREEN)
        message(STATUS "${level_prefix}${msg}")
    endif()
endfunction()

function(TIDY_GUI_VARIABLES)
    mark_as_advanced(QT_QMAKE_EXECUTABLE)
    if (APPLE)
        mark_as_advanced(CMAKE_OSX_ARCHITECTURES)
        mark_as_advanced(CMAKE_CODEBLOCKS_EXECUTABLE)
        mark_as_advanced(CMAKE_OSX_DEPLOYMENT_TARGET)
        mark_as_advanced(CMAKE_OSX_SYSROOT)
    endif ()
endfunction()

function(capitalise VARNAME)
    set(TEXT ${VARNAME})
    string(SUBSTRING ${TEXT} 0 1 FIRST_LETTER)
    string(TOUPPER ${FIRST_LETTER} FIRST_LETTER)
    string(REGEX REPLACE "^.(.*)" "${FIRST_LETTER}\\1" TEXT_CAP "${TEXT}")

    set(${VARNAME} ${TEXT_CAP} PARENT_SCOPE)
    #unset(TEXT_CAP)
    #unset(TEXT)
    #unset(FIRST_LETTER)
endfunction()

# This is a slow function don't call it if you don't have to.
function(check_ssh_github_access VAR_NAME)
    find_program(SSH_EXE ssh)
    mark_as_advanced(SSH_EXE)
    if (SSH_EXE)
        # This command always fail as github doesn't allow ssh access
        execute_process(
            COMMAND ${SSH_EXE} git@github.com
            RESULT_VARIABLE _RESULT
            OUTPUT_VARIABLE _OUT
            ERROR_VARIABLE _ERR
            )
        # So check the contents of the error message for a success message
        if ("${_ERR}" MATCHES "successfully authenticated")
            set(HAVE_SSH_ACCESS TRUE)
        else ()
            set(HAVE_SSH_ACCESS FALSE)
        endif ()
    else ()
        set(HAVE_SSH_ACCESS FALSE)
    endif ()
    set(${VAR_NAME} ${HAVE_SSH_ACCESS} PARENT_SCOPE)
endfunction()

#################################################################################
# Extra functions to use within CMake-enabled OpenCMISS applications and examples

# Composes a native PATH-compatible variable to use for DLL/SO finding.
# Each extra argument is assumed a path to add. Added in the order specified.
function(get_library_path OUTPUT_VARIABLE)
    if (WIN32)
        set(PSEP "\\;")
        #set(HAVE_MULTICONFIG_ENV YES)
        set(LD_VARNAME "PATH")
    elseif(APPLE)
        set(LD_VARNAME "DYLD_LIBRARY_PATH")
        set(PSEP ":")
    elseif(UNIX)
        set(LD_VARNAME "LD_LIBRARY_PATH")
        set(PSEP ":")
    else()
        message(WARNING "get_library_path not implemented for '${CMAKE_HOST_SYSTEM}'")
    endif()
    # Load system environment - on windows its separated by semicolon, so we need to protect those
    string(REPLACE ";" "\\;" LD_PATH "$ENV{${LD_VARNAME}}")
    foreach(_PATH ${ARGN})
        # For now: We dont have /Release or /Debug subfolders in any installed/packaged structure.
        #if (HAVE_MULTICONFIG_ENV)
        #    file(TO_NATIVE_PATH "${_PATH}/$<CONFIG>" _PATH)
        #else()
            file(TO_NATIVE_PATH "${_PATH}" _PATH)
        #endif()
        set(LD_PATH "${_PATH}${PSEP}${LD_PATH}")
    endforeach()
    set(${OUTPUT_VARIABLE} "${LD_VARNAME}=${LD_PATH}" PARENT_SCOPE)
endfunction()

# Convenience function to add the currently found OpenCMISS runtime environment to any
# test using OpenCMISS libraries
# Intended use is the OpenCMISS User SDK.
function(add_opencmiss_environment TESTNAME)
    get_library_path(PATH_DEFINITION "${OPENCMISS_BINARIES_PATH}")
    messaged("Setting environment for test ${TESTNAME}: ${LD_PATH}")
    # Set up the correct environment for the test
    # See https://cmake.org/pipermail/cmake/2009-May/029464.html
    get_test_property(${TESTNAME} ENVIRONMENT EXISTING_TEST_ENV)
    if (EXISTING_TEST_ENV)
        set_tests_properties(${TESTNAME} PROPERTIES
            ENVIRONMENT "${EXISTING_TEST_ENV};${PATH_DEFINITION}")
    else()
        set_tests_properties(${TESTNAME} PROPERTIES
            ENVIRONMENT "${PATH_DEFINITION}")
    endif()
endfunction()


# Breaks up a string in the form n1.n2.n3 into three parts and stores
# them in major, minor, and patch.  version should be a value, not a
# variable, while major, minor and patch should be variables.
function(THREE_PART_VERSION_TO_VARS VERSION MAJOR_VAR MINOR_VAR PATCH_VAR)
    set(_THREE_PART_VERSION_REGEX "[0-9]+\\.[0-9]+\\.[0-9]+")
    if (${VERSION} MATCHES ${_THREE_PART_VERSION_REGEX})
        string(REGEX REPLACE "^([0-9]+)\\.[0-9]+\\.[0-9]+" "\\1" major "${VERSION}")
        string(REGEX REPLACE "^[0-9]+\\.([0-9])+\\.[0-9]+" "\\1" minor "${VERSION}")
        string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+)" "\\1" patch "${VERSION}")
    else ()
        message(STATUS "MACRO(THREE_PART_VERSION_TO_VARS ${VERSION}")
        message(STATUS "Problem parsing version string, I can't parse it properly.")
    endif ()
    set(${MAJOR_VAR} ${major} PARENT_SCOPE)
    set(${MINOR_VAR} ${minor} PARENT_SCOPE)
    set(${PATCH_VAR} ${patch} PARENT_SCOPE)
endfunction()

function(GET_GIT_BRANCH GIT_SRC_DIR BRANCH_VAR)
    find_package(Git)
    if (GIT_FOUND)
        # Get the current working branch
        execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
            WORKING_DIRECTORY ${GIT_SRC_DIR}
            OUTPUT_VARIABLE GIT_BRANCH
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        if (GIT_BRANCH MATCHES "fatal.*")
            set(GIT_BRANCH -----)
        endif ()
    else ()
        set(GIT_BRANCH -----)
    endif ()
    set(${BRANCH_VAR} ${GIT_BRANCH} PARENT_SCOPE)
endfunction()

function(get_configuration_subdir_suffix suffix_var)
    set(suffix "")
    if(CMAKE_CONFIGURATION_TYPES)
        set(suffix "/${CMAKE_CFG_INTDIR}")
    endif()
    set(${suffix_var} "${suffix}" PARENT_SCOPE)
endfunction()

function(FIND_PROGRAM_ALL _var)
    if (NOT DEFINED ${_var})
        while(1)
            unset(_found CACHE)
            find_program(_found ${ARGN})
            if (_found AND NOT _found IN_LIST ${_var})
                set(${_var} "${${_var}};${_found}" CACHE FILEPATH "Path to a program." FORCE)
                mark_as_advanced(${_var})
                # ignore with the next try
                get_filename_component(_dir "${_found}" DIRECTORY)
                list(APPEND CMAKE_IGNORE_PATH "${_dir}")
            else()
                unset(_found CACHE)
                break()
            endif()
        endwhile()
        unset(CMAKE_IGNORE_PATH)
    endif()
endfunction()

function(messaged TEXT)
    if (DEBUG_MESSAGE)
        message(STATUS "DEBUG: ${TEXT}")
    endif ()
endfunction()

function(get_module_case_sensitive_name _MODULE _OUT)
    string(TOLOWER "${_MODULE}" LOWER_NAME)

    if (LOWER_NAME STREQUAL "libxml2")
        set(CASE_NAME LibXml2)
    elseif (LOWER_NAME STREQUAL "bzip2")
        set(CASE_NAME BZip2)
    elseif (LOWER_NAME STREQUAL "freetype")
        set(CASE_NAME Freetype)
    elseif (LOWER_NAME STREQUAL "imagemagick")
        set(CASE_NAME ImageMagick)
    elseif (LOWER_NAME STREQUAL "gtest")
        set(CASE_NAME GTest)
    elseif (LOWER_NAME STREQUAL "clang")
        set(CASE_NAME Clang)
    elseif (LOWER_NAME STREQUAL "csim")
        set(CASE_NAME CSim)
    else()
        set(CASE_NAME ${_MODULE})
    endif()

    set(${_OUT} ${CASE_NAME} PARENT_SCOPE)
endfunction()

function(get_module_targets _MODULE _OUT)
    string(TOLOWER "${_MODULE}" LOWER_NAME)

    if (LOWER_NAME STREQUAL "libxml2")
        set(TARGET_NAME xml2)
    elseif (LOWER_NAME STREQUAL "bzip2")
        set(TARGET_NAME bz2)
    elseif (LOWER_NAME STREQUAL "netgen")
        set(TARGET_NAME nglib)
    elseif (LOWER_NAME STREQUAL "imagemagick")
        set(TARGET_NAME MagickCore)
    elseif (LOWER_NAME STREQUAL "gtest")
        set(TARGET_NAME gtest_main)
    else()
        set(TARGET_NAME ${LOWER_NAME})
    endif()

    set(${_OUT} ${TARGET_NAME} PARENT_SCOPE)
endfunction()

