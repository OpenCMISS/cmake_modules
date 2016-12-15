
# The binary directories for the python environments are different on windows (for what reason exactly?)
# So we need different subpaths
set(VENV_BINDIR bin)
if (WIN32)
    set(VENV_BINDIR Scripts)
endif()

set(VIRTUALENV_COMPLETE_INSTALL_PREFIX_WO_CONFIG ${VIRTUALENV_INSTALL_PREFIX}/oclibs_venv_py${PYTHONLIBS_MAJOR_VERSION}${PYTHONLIBS_MINOR_VERSION}_)
set(VIRTUALENV_COMPLETE_INSTALL_PREFIX ${VIRTUALENV_COMPLETE_INSTALL_PREFIX_WO_CONFIG}$<LOWER_CASE:$<CONFIG>>)

set(ACTIVATE_SCRIPT ${VIRTUALENV_COMPLETE_INSTALL_PREFIX}/${VENV_BINDIR}/activate)
file(TO_NATIVE_PATH "${ACTIVATE_SCRIPT}" ACTIVATE_SCRIPT)
# Have to replace ; with : as they might have changed as TO_NATIVE_PATH sees these as path separators in a list of paths.
string(REPLACE ";" ":" ACTIVATE_SCRIPT "${ACTIVATE_SCRIPT}")

include(OCArchitecturePathFunctions)
include(OCToolchainCompilers)

# Variables used inside configured file
getToolchain(TOOLCHAIN)
getCompilerPartArchitecturePath(COMPILER)

set(BINDINGS_INFO_FILE "${CMAKE_CURRENT_BINARY_DIR}/bindingsinfo_${PYTHON_PACKAGE_CURRENT_NAME}_py${PYTHONLIBS_MAJOR_VERSION}${PYTHONLIBS_MINOR_VERSION}_$<LOWER_CASE:$<CONFIG>>.py")
set(BINDINGS_INFO_STAGED_FILE "${CMAKE_CURRENT_BINARY_DIR}/Templates/bindingsinfo_${PYTHON_PACKAGE_CURRENT_NAME}_py${PYTHONLIBS_MAJOR_VERSION}${PYTHONLIBS_MINOR_VERSION}.in.py")
set(GEN_BINDINGS_INFO_FILE "${CMAKE_CURRENT_BINARY_DIR}/Scripts/genbindingsinfo.cmake")
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/../../Templates/script_gen_bindings_info.in.cmake"
    "${GEN_BINDINGS_INFO_FILE}"
    @ONLY
)

# Do initial configuration of bindings info file.
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/../../Templates/bindingsinfo.in.py"
    "${BINDINGS_INFO_STAGED_FILE}"
    @ONLY
)

# Delay final configuragion of bindings info file until build type is known.
add_custom_command(TARGET collect_python_binding_files POST_BUILD
	COMMAND "${CMAKE_COMMAND}" 
	    -DBTYPE=$<LOWER_CASE:$<CONFIG>> 
	    -DACTIVATE_SCRIPT=${ACTIVATE_SCRIPT} 
	    -DBINDINGS_INFO_STAGED_FILE=${BINDINGS_INFO_STAGED_FILE}
	    -DBINDINGS_INFO_FILE=${BINDINGS_INFO_FILE}
	    -P ${GEN_BINDINGS_INFO_FILE}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

set(VIRTUALENV_OPENCMISS_LIBRARIES_FILE ${CMAKE_CURRENT_BINARY_DIR}/opencmisslibraries.py)
message(STATUS "Template file: ${CMAKE_CURRENT_LIST_DIR}/../../Templates/librarybindings.in.py")
message(STATUS "VIRTUALENV_OPENCMISS_LIBRARIES_FILE: ${VIRTUALENV_OPENCMISS_LIBRARIES_FILE}")
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/../../Templates/librarybindings.in.py"
    "${VIRTUALENV_OPENCMISS_LIBRARIES_FILE}" COPYONLY
)

# Cannot use generator expressions in custom command OUTPUTs so we will say it outputs 
# all possible options.
message(STATUS "OPENCMISS_HAVE_MULTICONFIG_ENV: ${OPENCMISS_HAVE_MULTICONFIG_ENV}")
set(OUTPUT_ACTIVATE_SCRIPTS)
if (OPENCMISS_HAVE_MULTICONFIG_ENV)
    foreach( _config ${CMAKE_CONFIGURATION_BUILD_TYPES)
        list(APPEND OUTPUT_ACTIVATE_SCRIPTS "${VIRTUALENV_COMPLETE_INSTALL_PREFIX_WO_CONFIG}${_config}/${VENV_BINDIR}/activate")
    endforeach()
else ()
    string(TOLOWER ${CMAKE_BUILD_TYPE} build_type)
    list(APPEND OUTPUT_ACTIVATE_SCRIPTS "${VIRTUALENV_COMPLETE_INSTALL_PREFIX_WO_CONFIG}${build_type}/${VENV_BINDIR}/activate")
endif ()

message(STATUS "OUTPUT_ACTIVATE_SCRIPTS: ${OUTPUT_ACTIVATE_SCRIPTS}")
add_custom_command(OUTPUT ${OUTPUT_ACTIVATE_SCRIPTS}
    COMMAND ${VIRTUALENV_EXEC} --system-site-packages "${VIRTUALENV_COMPLETE_INSTALL_PREFIX}"
)
add_custom_target(virtualenv_create
    DEPENDS ${ACTIVATE_SCRIPT}
)

# We need a native path to pass to the pip program
file(TO_NATIVE_PATH "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>" NATIVE_CMAKE_CURRENT_BINARY_DIR)
# This target takes care to install the python package generated in the build tree to the specified virtual
# environment.
add_custom_target(install_venv
    DEPENDS collect_python_binding_files virtualenv_create
    COMMAND ${VIRTUALENV_COMPLETE_INSTALL_PREFIX}/${VENV_BINDIR}/pip install --upgrade "${NATIVE_CMAKE_CURRENT_BINARY_DIR}"
#    WORKING_DIRECTORY "${VIRTUALENV_COMPLETE_INSTALL_PREFIX}" # Cannot use this if we want to use generator expressions, which we/I do.
    COMMENT "Installing: opencmiss.${PYTHON_PACKAGE_CURRENT_NAME} package for Python virtual environment ..."
)
install(CODE "execute_process(COMMAND \"${CMAKE_COMMAND}\" --build . --target install_venv --config \${CMAKE_INSTALL_CONFIG_NAME} WORKING_DIRECTORY \"${PROJECT_BINARY_DIR}\")"
    COMPONENT VirtualEnv
)
install(FILES ${BINDINGS_INFO_FILE} ${VIRTUALENV_OPENCMISS_LIBRARIES_FILE}
    DESTINATION python
    COMPONENT VirtualEnv
)

