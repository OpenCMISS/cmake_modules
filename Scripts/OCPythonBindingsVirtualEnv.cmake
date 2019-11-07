
# The binary directories for the python environments are different on windows (for what reason exactly?)
# So we need different subpaths
set(VENV_BINDIR bin)
if (WIN32)
    set(VENV_BINDIR Scripts)
endif()

if (CMAKE_CONFIGURATION_TYPES)
    set(CFG_DIR /$<CONFIG>)
endif ()

set(VIRTUALENV_COMPLETE_INSTALL_PREFIX_WO_CONFIG ${VIRTUALENV_INSTALL_PREFIX}/oclibs_venv_py${Python_VERSION_MAJOR}${Python_VERSION_MINOR}_)
set(VIRTUALENV_COMPLETE_INSTALL_PREFIX ${VIRTUALENV_COMPLETE_INSTALL_PREFIX_WO_CONFIG}$<LOWER_CASE:$<CONFIG>>)

set(ACTIVATE_SCRIPT ${VIRTUALENV_COMPLETE_INSTALL_PREFIX}/${VENV_BINDIR}/activate)
file(TO_CMAKE_PATH "${ACTIVATE_SCRIPT}" ACTIVATE_SCRIPT)
# Have to replace ; with : as they might have changed as TO_NATIVE_PATH sees these as path separators in a list of paths.
string(REPLACE ";" ":" ACTIVATE_SCRIPT "${ACTIVATE_SCRIPT}")

include(OCArchitecturePathFunctions)
include(OCToolchainCompilers)

# Variables used inside configured file
getToolchain(_ACTIVE_TOOLCHAIN)
getCompilerPartArchitecturePath(_ACTIVE_COMPILER)
set(_ACTIVE_MPI ${MPI})

set(BINDINGS_INFO_FILE "${CMAKE_CURRENT_BINARY_DIR}/bindingsinfo_${PYTHON_PACKAGE_CURRENT_NAME}_py${Python_VERSION_MAJOR}${Python_VERSION_MINOR}_$<LOWER_CASE:$<CONFIG>>.py")
set(BINDINGS_INFO_STAGED_FILE "${CMAKE_CURRENT_BINARY_DIR}/Templates/bindingsinfo_${PYTHON_PACKAGE_CURRENT_NAME}_py${Python_VERSION_MAJOR}${Python_VERSION_MINOR}.in.py")
set(GEN_BINDINGS_INFO_FILE "${CMAKE_CURRENT_BINARY_DIR}/Scripts/genbindingsinfo.cmake")
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/../Templates//script_gen_bindings_info.in.cmake"
    "${GEN_BINDINGS_INFO_FILE}"
    @ONLY
)

# Do initial configuration of bindings info file.
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/../Templates//bindingsinfo.in.py"
    "${BINDINGS_INFO_STAGED_FILE}"
    @ONLY
)

# Delay final configuragion of bindings info file until build type is known.
get_filename_component(_DISPLAY_SCRIPT_NAME "${BINDINGS_INFO_FILE}" NAME)
add_custom_command(TARGET collect_python_binding_files POST_BUILD
    COMMAND "${CMAKE_COMMAND}" 
        -DBTYPE=$<LOWER_CASE:$<CONFIG>> 
        -DACTIVATE_SCRIPT=${ACTIVATE_SCRIPT} 
        -DBINDINGS_INFO_STAGED_FILE=${BINDINGS_INFO_STAGED_FILE}
        -DBINDINGS_INFO_FILE=${BINDINGS_INFO_FILE}
        -P ${GEN_BINDINGS_INFO_FILE}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating ${_DISPLAY_SCRIPT_NAME}."
)

set(VIRTUALENV_OPENCMISS_LIBRARIES_FILE ${CMAKE_CURRENT_BINARY_DIR}/opencmisslibraries.py)
message(STATUS "Template file: ${CMAKE_CURRENT_LIST_DIR}/../Templates//librarybindings.in.py")
message(STATUS "VIRTUALENV_OPENCMISS_LIBRARIES_FILE: ${VIRTUALENV_OPENCMISS_LIBRARIES_FILE}")
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/../Templates//librarybindings.in.py"
    "${VIRTUALENV_OPENCMISS_LIBRARIES_FILE}" COPYONLY
)


# We need a native path to pass to the pip program, so we have to use indirection to get a $ symbol into the configured file
set(DOLLAR_SYMBOL $)
# This target takes care to install the python package generated in the build tree to the specified virtual
# environment.
set(GEN_SCRIPT_VIRTUAL_ENV_CREATE_AND_INSTALL ${CMAKE_CURRENT_LIST_DIR}/../OpenCMISS/OCScriptGenerateVirtualEnvCreateAndInstall.cmake)
set(SCRIPT_VIRTUALENV_CREATE_INSTALL "${CMAKE_CURRENT_BINARY_DIR}/script_virtualenv_create_and_install.cmake")
# Delay final configuragion of virtualenv create and install until build type is known.
get_filename_component(_DISPLAY_SCRIPT_NAME "${SCRIPT_VIRTUALENV_CREATE_INSTALL}" NAME)
add_custom_command(TARGET collect_python_binding_files POST_BUILD
    COMMAND "${CMAKE_COMMAND}" 
        -DACTIVATE_SCRIPT=${ACTIVATE_SCRIPT}
        -DPACKAGE_BINARY_DIR="${CMAKE_CURRENT_BINARY_DIR}${CFG_DIR}"
        -DPython_EXECUTABLE=${Python_EXECUTABLE}
        -DVIRTUALENV_EXEC=${VIRTUALENV_EXEC}
        -DVENV_BINDIR=${VENV_BINDIR}
        -DVIRTUALENV_COMPLETE_INSTALL_PREFIX=${VIRTUALENV_COMPLETE_INSTALL_PREFIX}
        -DCREATE_AND_INSTALL_TEMPLATE_SCRIPT=${CMAKE_CURRENT_LIST_DIR}/../Templates//script_virtualenv_create_and_install.in.cmake
        -DCREATE_AND_INSTALL_SCRIPT=${SCRIPT_VIRTUALENV_CREATE_INSTALL}
        -P ${GEN_SCRIPT_VIRTUAL_ENV_CREATE_AND_INSTALL}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating ${_DISPLAY_SCRIPT_NAME}."
)

install(SCRIPT ${SCRIPT_VIRTUALENV_CREATE_INSTALL}
    COMPONENT VirtualEnv
)

# These scripts need to be installed in a sligtly different location.
# They are placed in an architecture path agnostic directory much like
# the OpenCMISS CMake modules files are.
getSystemPartArchitecturePath(SYSTEM_PART)
string(REGEX REPLACE "/${SYSTEM_PART}.*" "" AGNOSTIC_CMAKE_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})

message(STATUS "AGNOSTIC_CMAKE_INSTALL_PREFIX: ${AGNOSTIC_CMAKE_INSTALL_PREFIX}")

set(DESTINATION_PATH ${AGNOSTIC_CMAKE_INSTALL_PREFIX}/share/python)
install(FILES ${BINDINGS_INFO_FILE} ${VIRTUALENV_OPENCMISS_LIBRARIES_FILE}
    DESTINATION "${DESTINATION_PATH}"
    COMPONENT VirtualEnv
)

