
function(genBindingInfoFile BTYPE)
    string(TOLOWER ${BTYPE} BTYPE)
    if (OPENCMISS_USE_ARCHITECTURE_PATH)
        string(REPLACE "/" "_" _APATH "${ARCHITECTURE_MPI_PATH}")
        string(REPLACE "." "_" _APATH "${_APATH}")
        string(REPLACE "-" "_" _APATH "${_APATH}")
        set(VIRTUALENV_INFO_FILE_STEM "${_OC_PYTHON_INSTALL_PREFIX}/bindings_${_APATH}_")
        set(VIRTUALENV_INFO_FILE ${_OC_PYTHON_INSTALL_PREFIX}/bindings_${_APATH}_${BTYPE}.py)
    else ()
        set(VIRTUALENV_INFO_FILE ${_OC_PYTHON_INSTALL_PREFIX}/bindings_${BTYPE}.py)
    endif ()
    string(TOLOWER ${OPENCMISS_MPI_BUILD_TYPE} OPENCMISS_MPI_BUILD_TYPE)
    set(LIBRARY_PATH )
    foreach(_PATH ${OPENCMISS_LIBRARY_PATH})
        file(TO_NATIVE_PATH "${_PATH}" _NATIVE)
        list(APPEND LIBRARY_PATH "${_NATIVE}")
    endforeach()
    set(IS_VIRTUALENV False)
    if (OC_PYTHON_BINDINGS_USE_VIRTUALENV)
        set(IS_VIRTUALENV True)
        set(_SCRIPT_DIR bin)
        if (WIN32)
            set(_SCRIPT_DIR Scripts)
        endif ()
        set(ACTIVATE_SCRIPT ${OPENCMISS_LIBRARIES_INSTALL_MPI_PREFIX}/${OC_VIRTUALENV_SUBPATH}/${_SCRIPT_DIR}/activate)
        if (WIN32)
            file(TO_NATIVE_PATH "${ACTIVATE_SCRIPT}" ACTIVATE_SCRIPT)
        endif ()
    endif()
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/Templates/python_virtualenv.in.py"
        "${VIRTUALENV_INFO_FILE}" 
        @ONLY
    )
endfunction()

set(VENV_CREATION_COMMANDS )
set(VIRTUALENV_OPENCMISS_LIBRARIES_FILE ${_OC_PYTHON_INSTALL_PREFIX}/opencmisslibraries.py)
# Technically this should be configured into the build directory and installed
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/Templates/opencmiss.bindings.in.py"
    "${VIRTUALENV_OPENCMISS_LIBRARIES_FILE}" COPYONLY
)

# Compiler variable used inside configured file
getCompilerPartArchitecturePath(COMPILER)

if (OPENCMISS_HAVE_MULTICONFIG_ENV)
    foreach(BTYPE ${CMAKE_CONFIGURATION_TYPES})
        string(TOLOWER ${BTYPE} BTYPE)
        set(OC_TARGET_VIRTUALENV ${OPENCMISS_LIBRARIES_INSTALL_MPI_PREFIX}/${OC_VIRTUALENV_SUBPATH}/${BTYPE})
        genBindingInfoFile(${BTYPE})
    
        # For multiconfig builds, we need to create all the possible virtual environments
        # at once, as CMake currently does not allow generator expressions in add_custom_command's OUTPUT part,
        # see https://cmake.org/Bug/view.php?id=13840
        if (OC_PYTHON_BINDINGS_USE_VIRTUALENV)
            list(APPEND VENV_CREATION_COMMANDS
                COMMAND ${VIRTUALENV_EXECUTABLE} --system-site-packages "${OC_TARGET_VIRTUALENV}"
            )
        endif()
    endforeach()
    # Set to the directory without build type - zinc/iron will know if they're in a multiconf-environment
    # and create the correct path for installation within their own cmake logic
    set(OC_TARGET_VIRTUALENV ${OPENCMISS_LIBRARIES_INSTALL_MPI_PREFIX}/${OC_VIRTUALENV_SUBPATH})
else()
    set(OC_TARGET_VIRTUALENV ${OPENCMISS_LIBRARIES_INSTALL_MPI_PREFIX}/${OC_VIRTUALENV_SUBPATH})
    genBindingInfoFile(${CMAKE_BUILD_TYPE})
    
    if (OC_PYTHON_BINDINGS_USE_VIRTUALENV)
        set(VENV_CREATION_COMMANDS COMMAND ${VIRTUALENV_EXECUTABLE} --system-site-packages "${OC_TARGET_VIRTUALENV}")
        set(VENV_BINDING_INFO_COMMAND COMMAND "${CMAKE_COMMAND}" -E copy_if_different ""
    endif()
endif()

set(OC_VENV_STAMPFILE ${OPENCMISS_LIBRARIES_VIRTUALENV_INSTALL_PREFIX}/virtualenv.created)
add_custom_command(OUTPUT ${OC_VENV_STAMPFILE}
    ${VENV_CREATION_COMMANDS}
    COMMAND ${CMAKE_COMMAND} -E touch "${OC_VENV_STAMPFILE}"
)
add_custom_target(virtualenv_create ALL
    DEPENDS ${OC_VENV_STAMPFILE}
)
