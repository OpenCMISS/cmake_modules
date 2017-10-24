# Appends a library to the list of interface_link_libraries
function(append_link_library TARGET LIB)
    get_target_property(CURRENT_ILL
        ${TARGET} INTERFACE_LINK_LIBRARIES)
    if (NOT CURRENT_ILL)
        set(CURRENT_ILL )
    endif()
    # Treat framework references different
    if(APPLE AND ${LIB} MATCHES ".framework$")
        string(REGEX REPLACE ".*/([A-Za-z0-9.]+).framework$" "\\1" FW_NAME ${LIB})
        #message(STATUS "Matched '${FW_NAME}' to ${LIB}")
        set(LIB "-framework ${FW_NAME}")
    endif()
    set_target_properties(${TARGET} PROPERTIES
        INTERFACE_LINK_LIBRARIES "${CURRENT_ILL};${LIB}")
endfunction()

# Need to have function name templates to have the correct package info at call time!
# Took some time to figure this quiet function re-definition stuff out..
function(my_stupid_package_dependent_message_function_scalapack MSG)
    message(STATUS "FindSCALAPACK wrapper: ${MSG}")
endfunction()
function(my_stupid_package_dependent_message_function_debug_scalapack MSG)
    #message(STATUS "DEBUG FindSCALAPACK wrapper: ${MSG}")
endfunction()

my_stupid_package_dependent_message_function_debug_scalapack("Entering script. CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}, _IMPORT_PREFIX=${_IMPORT_PREFIX}")

# Default: Not found
set(SCALAPACK_FOUND NO)
    
# The default way is to look for components in the current PREFIX_PATH, e.g. own build components.
# If the OC_SYSTEM_SCALAPACK flag is set for a package, the MODULE and CONFIG modes are tried outside the PREFIX PATH first.
if (SCALAPACK_FIND_SYSTEM)
    # If local lookup is enabled, try to look for packages in old-fashioned module mode and then config modes 
    my_stupid_package_dependent_message_function_scalapack("System search enabled")
    
    # Remove all paths resolving to this one here so that recursive calls wont search here again
    set(_ORIGINAL_CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH})
    get_filename_component(_THIS_DIRECTORY ${CMAKE_CURRENT_LIST_FILE} DIRECTORY)
    foreach(_ENTRY ${_ORIGINAL_CMAKE_MODULE_PATH})
        get_filename_component(_ENTRY_ABSOLUTE ${_ENTRY} ABSOLUTE)
        if (_ENTRY_ABSOLUTE STREQUAL _THIS_DIRECTORY)
            list(REMOVE_ITEM CMAKE_MODULE_PATH ${_ENTRY})
        endif ()
    endforeach()
    unset(_THIS_DIRECTORY)
    unset(_ENTRY_ABSOLUTE)
    
    # Make "native" call to find_package in MODULE mode first
    my_stupid_package_dependent_message_function_scalapack("Trying to find version ${SCALAPACK_FIND_VERSION} on system in MODULE mode")
    my_stupid_package_dependent_message_function_debug_scalapack("CMAKE_MODULE_PATH: ${CMAKE_MODULE_PATH}\nCMAKE_SYSTEM_PREFIX_PATH=${CMAKE_SYSTEM_PREFIX_PATH}\nPATH=$ENV{PATH}\nLD_LIBRARY_PATH=$ENV{LD_LIBRARY_PATH}")
    
    # Temporarily disable the required flag (if set from outside)
    SET(_PKG_REQ_OLD ${SCALAPACK_FIND_REQUIRED})
    UNSET(SCALAPACK_FIND_REQUIRED)
    
    # Remove CMAKE_INSTALL_PREFIX from CMAKE_SYSTEM_PREFIX_PATH - we dont want the module search to "accidentally"
    # discover the packages in our install directory, collect libraries and then re-turn them into targets (redundant round-trip)
    set(DEFAULT_INSTALL_PREFIX FALSE)
    if (CMAKE_INSTALL_PREFIX STREQUAL "/usr/local" OR CMAKE_INSTALL_PREFIX STREQUAL "c:/Program Files")
        set(DEFAULT_INSTALL_PREFIX TRUE)
    endif ()
    if (NOT DEFAULT_INSTALL_PREFIX AND CMAKE_INSTALL_PREFIX AND CMAKE_SYSTEM_PREFIX_PATH)
        list(REMOVE_ITEM CMAKE_SYSTEM_PREFIX_PATH ${CMAKE_INSTALL_PREFIX})
        set(_readd YES)
    endif ()
    
    # Actual MODULE mode find call
    #message(STATUS "find_package(SCALAPACK ${SCALAPACK_FIND_VERSION} MODULE QUIET)")
    find_package(SCALAPACK ${SCALAPACK_FIND_VERSION} MODULE QUIET)
    
    # Restore stuff
    SET(SCALAPACK_FIND_REQUIRED ${_PKG_REQ_OLD})
    if (_readd)
        list(APPEND CMAKE_SYSTEM_PREFIX_PATH ${CMAKE_INSTALL_PREFIX})
    endif ()
    unset(_readd)
    
    # Restore the current module path
    # This needs to be done BEFORE any calls in CONFIG find mode - if the found config has our
    # xxx-config-dependencies, which in turn might be allowed as system lookup, the FindModuleWrapper dir
    # is missing and stuff breaks. Took a while to figure out the problem as you might guess ;-)
    # Scenario discovered on Michael Sprenger's Ubuntu 10 system with 
    # OC_SYSTEM_ZLIB=YES and found, OC_SYSTEM_LIBXML2=ON but not found. This broke the CELLML-build as
    # the wrapper call for LIBXML removed the wrapper dir from the module path, then found libxml2 in config mode,
    # which in turn called find_dependency(ZLIB), which used the native FindZLIB instead of the wrapper first.
    # This problem only was detected because the native zlib library is called "(lib)z", but we link against the 
    # "zlib" target, which is either provided by our own build or by the wrapper that creates it. 
    set(CMAKE_MODULE_PATH ${_ORIGINAL_CMAKE_MODULE_PATH})
    unset(_ORIGINAL_CMAKE_MODULE_PATH)
        
    if (SCALAPACK_FOUND)
        # Also set the casename variant as this is checked upon at the end ("newer" version; config mode returns
        # a xXx_FOUND variable that has the same case as used for the call find_package(xXx ..)
        set(SCALAPACK_FOUND YES)
        if (NOT TARGET scalapack)
            set(LIBS ${SCALAPACK_LIBRARIES})
            my_stupid_package_dependent_message_function_scalapack("Found: ${LIBS}")
            
            SET(INCS )
            foreach(DIRSUFF _INCLUDE_DIRS _INCLUDES _INCLUDE_PATH _INCLUDE_DIR)
                if (DEFINED SCALAPACK${DIRSUFF})
                    LIST(APPEND INCS ${SCALAPACK${DIRSUFF}})
                endif()
            endforeach()
            my_stupid_package_dependent_message_function_debug_scalapack("Include directories: ${INCS}")
            
            my_stupid_package_dependent_message_function_debug_scalapack("Converting found module to imported targets")
            if (NOT CMAKE_CFG_INTDIR STREQUAL .)
                STRING(TOUPPER ${CMAKE_CFG_INTDIR} CURRENT_BUILD_TYPE)
            elseif(CMAKE_BUILD_TYPE)
                STRING(TOUPPER ${CMAKE_BUILD_TYPE} CURRENT_BUILD_TYPE)
            else()
                SET(CURRENT_BUILD_TYPE NOCONFIG)
            endif()
            my_stupid_package_dependent_message_function_debug_scalapack("Current build type: CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -- CURRENT_BUILD_TYPE=${CURRENT_BUILD_TYPE}")
            
            list(GET LIBS 0 _FIRST_LIB)
            add_library(scalapack UNKNOWN IMPORTED)
            # Treat apple frameworks separate
            # See http://stackoverflow.com/questions/12547624/cant-link-macos-frameworks-with-cmake
            if(APPLE AND ${_FIRST_LIB} MATCHES ".framework$")
                STRING(REGEX REPLACE ".*/([A-Za-z0-9.]+).framework$" "\\1" FW_NAME ${_FIRST_LIB})
                #message(STATUS "Matched '${FW_NAME}' to ${LIB}")
                SET(_FIRST_LIB "${_FIRST_LIB}/${FW_NAME}")
            endif()
            set_target_properties(scalapack PROPERTIES 
                    IMPORTED_LOCATION_${CURRENT_BUILD_TYPE} ${_FIRST_LIB}
                    IMPORTED_CONFIGURATIONS ${CURRENT_BUILD_TYPE}
                    INTERFACE_INCLUDE_DIRECTORIES "${INCS}"
            )
            
            list(REMOVE_AT LIBS 0)
            # Add non-matched libraries as link libraries so nothing gets forgotten
            foreach(LIB ${LIBS})
                my_stupid_package_dependent_message_function_debug_scalapack("Adding extra library ${LIB} to link interface")
                append_link_library(scalapack ${LIB})
            endforeach()
        else()
            my_stupid_package_dependent_message_function_scalapack("Avoiding double import of target 'scalapack'")
        endif()
    else ()
        # Look outside the prefix path
        my_stupid_package_dependent_message_function_debug_scalapack("Calling find_package(SCALAPACK ${SCALAPACK_FIND_VERSION} CONFIG QUIET NO_CMAKE_PATH)")
        find_package(SCALAPACK ${SCALAPACK_FIND_VERSION} CONFIG QUIET NO_CMAKE_PATH)

        # If not found, look also at the prefix path
        if (SCALAPACK_FOUND)
            set(SCALAPACK_FOUND ${SCALAPACK_FOUND})
            my_stupid_package_dependent_message_function_scalapack("Found at ${SCALAPACK_DIR} in CONFIG mode")
        endif ()
    endif ()
endif ()

# If not found, look also at the prefix path
if (NOT SCALAPACK_FOUND)
    #my_stupid_package_dependent_message_function_scalapack("No system package found/available.")
    find_package(SCALAPACK ${SCALAPACK_FIND_VERSION} CONFIG
        QUIET
        PATHS ${CMAKE_PREFIX_PATH}
        NO_CMAKE_ENVIRONMENT_PATH
        NO_SYSTEM_ENVIRONMENT_PATH
        NO_CMAKE_BUILDS_PATH
        NO_CMAKE_PACKAGE_REGISTRY
        NO_CMAKE_SYSTEM_PATH
        NO_CMAKE_SYSTEM_PACKAGE_REGISTRY
    )
    if (SCALAPACK_FOUND)
        set(SCALAPACK_FOUND ${SCALAPACK_FOUND})
        my_stupid_package_dependent_message_function_scalapack("Found at ${SCALAPACK_DIR} in CONFIG mode")
    endif ()
endif ()

if (SCALAPACK_FIND_REQUIRED AND NOT SCALAPACK_FOUND)
    message(FATAL_ERROR "FindModuleWrapper error!\n"
        "Could not find SCALAPACK ${SCALAPACK_FIND_VERSION} with either MODULE or CONFIG mode.\n"
        "CMAKE_MODULE_PATH: ${CMAKE_MODULE_PATH}\n"
        "CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}\n"
        "Allow system search for SCALAPACK: ${SCALAPACK_FIND_SYSTEM}\n"
        "Alternatively, refer to CMake(Output|Error).log in ${PROJECT_BINARY_DIR}/CMakeFiles\n"
    )
endif()
