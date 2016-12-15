
set(_LIBRARY_PATH )
foreach(_PATH @LIBRARY_PATH@)
    file(TO_NATIVE_PATH "${_PATH}" _NATIVE)
    list(APPEND _LIBRARY_PATH "${_NATIVE}")
endforeach()

#string(REPLACE ".in.py" ".py" BINDINGS_INFO_FILE ${BINDINGS_INFO_STAGED_FILE})
configure_file(
    "${BINDINGS_INFO_STAGED_FILE}"
    "${BINDINGS_INFO_FILE}"
)

