# Appends a library to the list of interface_link_libraries
function(append_link_library _TARGET _LIB)
    get_target_property(CURRENT_ILL
        ${_TARGET} INTERFACE_LINK_LIBRARIES)
    if (NOT CURRENT_ILL)
        set(CURRENT_ILL )
    endif()
    # Treat framework references different
    if(APPLE AND ${_LIB} MATCHES ".framework$")
        string(REGEX REPLACE ".*/([A-Za-z0-9.]+).framework$" "\\1" FW_NAME ${_LIB})
        #message(STATUS "Matched '${FW_NAME}' to ${_LIB}")
        set(_LIB "-framework ${FW_NAME}")
    endif()
    set_target_properties(${_TARGET} PROPERTIES
        INTERFACE_LINK_LIBRARIES "${CURRENT_ILL};${_LIB}")
endfunction()

# Adds a list of libraries to a configuration specific link libraries property.
function(add_configuration_link_libraries _TARGET _CONFIG _LIBS)

    list(GET _LIBS 0 _FIRST_LIB)
    # Treat apple frameworks separate
    # See http://stackoverflow.com/questions/12547624/cant-link-macos-frameworks-with-cmake

    if(APPLE AND ${_FIRST_LIB} MATCHES ".framework$")
        STRING(REGEX REPLACE ".*/([A-Za-z0-9.]+).framework$" "\\1" FW_NAME ${_FIRST_LIB})
        #message(STATUS "Matched '${FW_NAME}' to ${_FIRST_LIB}")
        SET(_FIRST_LIB "${_FIRST_LIB}/${FW_NAME}")
    endif()

    set_target_properties(${_TARGET} PROPERTIES
            IMPORTED_LOCATION_${_CONFIG} ${_FIRST_LIB}
            IMPORTED_CONFIGURATIONS ${_CONFIG}
            INTERFACE_INCLUDE_DIRECTORIES "${INCS}"
    )

    list(REMOVE_AT _LIBS 0)
    # Add non-matched libraries as link libraries so nothing gets forgotten
    foreach(LIB ${_LIBS})
        append_link_library(${_TARGET} ${_CONFIG} ${LIB})
    endforeach()
endfunction()

# Extract a list of configuration specific libraries from the given list of libraries.
function(extract_config_libs _CONFIG_INDEX _LIBS_LIST _EXTRACTED_LIBS)
    set(_CONFIG_LIBS)
    set(_COUNT 0)
    while(_COUNT LESS _CONFIG_INDEX)
        list(REMOVE_AT _LIBS_LIST 0)
        math(EXPR _COUNT "${_COUNT}+1")
    endwhile()

    # Remove the config specifier keyword itself.
    list(REMOVE_AT _LIBS_LIST 0)
    foreach (_ENTRY ${_LIBS_LIST})
        if (_ENTRY STREQUAL "debug" OR _ENTRY STREQUAL "optimized")
            break()
        endif()
        list(APPEND _CONFIG_LIBS ${_ENTRY})
    endforeach()

    set(${_EXTRACTED_LIBS} ${_CONFIG_LIBS} PARENT_SCOPE)
endfunction()
