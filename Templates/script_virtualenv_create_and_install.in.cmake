
if (NOT EXISTS "@ACTIVATE_SCRIPT@")
    execute_process(COMMAND @VIRTUALENV_EXEC@ --python=@Python_EXECUTABLE@ --system-site-packages "@VIRTUALENV_COMPLETE_INSTALL_PREFIX@")
endif ()

file(TO_NATIVE_PATH "@PACKAGE_BINARY_DIR@" SETUP_PY_DIR)
execute_process(COMMAND @VIRTUALENV_COMPLETE_INSTALL_PREFIX@/@VENV_BINDIR@/python -m pip install --upgrade "${SETUP_PY_DIR}"
    RESULT_VARIABLE _RESULT OUTPUT_VARIABLE _OUTPUT ERROR_VARIABLE _ERROR)

if (NOT "${_RESULT}" STREQUAL "0")
    message(STATUS "Error installing into virtualenv command returned: ${_RESULT}")
    message(STATUS "with output:")
    message(STATUS "${_OUTPUT}")
    message(STATUS "and errors:")
    message(STATUS "${_ERROR}")
endif ()
