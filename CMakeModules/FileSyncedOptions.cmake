#.rst
# FileSyncedOptions
# =================
# 
# ::
# 
#   read_options(filename [option file location])
# 
# Read options from a text file; Options are added as a line in the file
# each line contains a semicolon list of options e.g.
# VARIABLE_NAME;DEFAULT_VALUE;VARIABLE_TYPE;VARIABLE_HELPSTRING
# Don't use the suffix '.cmake' for the option definitions file.
# You can also optionally add a location for the file to be stored as
# a second argument when calling the function.
function(read_options OPTIONS_FILE)
	_update_cache(${OPTIONS_FILE})
	_get_options(_OPTIONS ${OPTIONS_FILE})
	_get_build_options_file(OPTION_FILE ${OPTIONS_FILE} ${ARGV1})
	
	include(${OPTION_FILE} OPTIONAL RESULT_VARIABLE _RES)
	if (_RES)
		message(STATUS "Read options from: ${_RES}")
	endif ()

	if ("${OPTION_FILE}" IS_NEWER_THAN "${CMAKE_BINARY_DIR}/CMakeCache.txt")
		foreach(_VAR ${_OPTIONS})
			set_property(CACHE ${_VAR} PROPERTY VALUE ${${_VAR}})
		endforeach()
	else ()
		foreach(_VAR ${_OPTIONS})
			get_property(_stored_value CACHE ${_VAR} PROPERTY VALUE)
			set(${_VAR} ${_stored_value})
		endforeach()
	endif ()

	set(OPTION_FILE_TMP "${OPTION_FILE}.tmp")
	file(WRITE "${OPTION_FILE_TMP}" "# This is a generated file. You may only change the values of the variables, nothing else.\n")
	foreach(_VAR ${_OPTIONS})
		string(REGEX MATCH " " _SPACE_MATCH "${${_VAR}}" )
		if (_SPACE_MATCH)
			set(_c_line "set(${_VAR} \"${${_VAR}}\")")
		else ()
			set(_c_line "set(${_VAR} ${${_VAR}})")
		endif ()
		get_property(_bdocs_value CACHE ${_VAR} PROPERTY HELPSTRING)
		file(APPEND "${OPTION_FILE_TMP}" "\n# ${_VAR}: ${_bdocs_value}\n")
		file(APPEND "${OPTION_FILE_TMP}" "${_c_line}\n")
	endforeach()
	configure_file("${OPTION_FILE_TMP}" "${OPTION_FILE}" COPYONLY)
	file(REMOVE "${OPTION_FILE_TMP}")
endfunction()

# Unset the options from the options file from the cache and delete the options file.
function(unset_options OPTIONS_FILE)
	_get_options(_OPTIONS ${OPTIONS_FILE})
	foreach(_VAR ${_OPTIONS})
		unset(${_VAR} CACHE)
	endforeach()
	_get_build_options_file(OPTION_FILE ${OPTIONS_FILE})
	file(REMOVE "${OPTION_FILE}")
endfunction()

# Finalise the options from the options file from the cache, by making them
# internal vairables, and delete the options file.
function(finalise_options OPTIONS_FILE)
	_get_options(_OPTIONS ${OPTIONS_FILE})
	foreach(_VAR ${_OPTIONS})
		set_property(CACHE ${_VAR} PROPERTY TYPE INTERNAL)
	endforeach()
	_get_build_options_file(OPTION_FILE ${OPTIONS_FILE})
	file(REMOVE "${OPTION_FILE}")
endfunction()

# Return the location of the build options file.
#
# Internal module function do not call directly
function(_get_build_options_file _RETURN_VAR OPTIONS_FILE)
	get_filename_component(_BASE_NAME ${OPTIONS_FILE} NAME_WE)
	if (ARGC EQUAL 3)
		get_filename_component(OPTION_FILE_LOCATION ${ARGV2} ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
		set(OPTION_FILE "${OPTION_FILE_LOCATION}/${_BASE_NAME}.cmake")
	else ()
		set(OPTION_FILE "${CMAKE_CURRENT_BINARY_DIR}/${_BASE_NAME}.cmake")
	endif ()
	set(${_RETURN_VAR} ${OPTION_FILE} PARENT_SCOPE)
endfunction()

# Return a list of the option names read from the database.
#
# Internal module function do not call directly
function(_get_options _RETURN_VAR OPTIONS_FILE)
	file(STRINGS "${OPTIONS_FILE}" ENTRIES)
	foreach(_ENTRY ${ENTRIES})
		list(LENGTH _ENTRY _SIZE)
		if (_SIZE STREQUAL "4")
			list(GET _ENTRY 0 _NAME)
			list(APPEND _OPTIONS ${_NAME})
		endif ()
	endforeach()
	set(${_RETURN_VAR} ${_OPTIONS} PARENT_SCOPE)
endfunction()

# Update the CMake cache with the values from the file.  If the variable already
# exists leave it as is unless it is marked as internal.  If the variable is
# marked as internal reset its type to the type specified in the options database.
# If the variable is not set then initialise it with the information read from the database.
#
# Internal module function do not call directly
function(_update_cache OPTIONS_FILE)
	file(STRINGS "${OPTIONS_FILE}" ENTRIES)
	foreach(_ENTRY ${ENTRIES})
		list(LENGTH _ENTRY _SIZE)
		if (_SIZE STREQUAL "4")
			list(INSERT _ENTRY 2 CACHE)
			list(GET _ENTRY 0 _NAME)
			get_property(propIsSet CACHE ${_NAME} PROPERTY TYPE SET)
			if (propIsSet)
				get_property(propValue CACHE ${_NAME} PROPERTY TYPE)
				if (propValue STREQUAL "INTERNAL")
					list(GET _ENTRY 3 _TYPE)
					set_property(CACHE ${_NAME} PROPERTY TYPE ${_TYPE})
				endif ()
			else ()
				set(${_ENTRY})
			endif ()
		endif ()
	endforeach()
endfunction()
