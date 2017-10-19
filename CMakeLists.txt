
########################################################
# If your cmake is older than 3.4 - goodbye.
cmake_minimum_required(VERSION 3.4.0 FATAL_ERROR)

########################################################################
# Ready to start the "CMake Modules"
project(OpenCMISS-CMake-Modules VERSION 1.0.0 LANGUAGES CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/Scripts)
include(OCMiscFunctions)
include(OCMultiConfigEnvironment)
tidy_gui_variables()
if (OPENCMISS_HAVE_MULTICONFIG_ENV)
    mark_as_advanced(CMAKE_CONFIGURATION_TYPES)
else ()
    mark_as_advanced(CMAKE_BUILD_TYPE)
endif ()

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE PATH "Choose the type of build, options are: None(CMAKE_CXX_FLAGS or CMAKE_C_FLAGS used) Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif ()

# Standard installation scenario and the module path can be found relative to this directory
get_filename_component(_INSTALL_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../../install/" REALPATH)

set(CMAKE_MODULES_INSTALL_PREFIX "${_INSTALL_PREFIX}" CACHE PATH "Install path prefix, prepended onto install directories.")
if (DEFINED INSTALL_PREFIX)
    set(CMAKE_MODULES_INSTALL_PREFIX "${INSTALL_PREFIX}" CACHE PATH "Install path prefix, prepended onto install directories." FORCE)
endif ()
set(CMAKE_INSTALL_PREFIX "${CMAKE_MODULES_INSTALL_PREFIX}" CACHE INTERNAL "Internalise install path prefix." FORCE)

set(MODULES_FILES_LIST
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FileSyncedOptions.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindBLACS.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindBLAS.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindFTGL.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindGLEW.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindGTKGLext.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindGit.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindHYPRE.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindImageMagick.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindJPEG.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindLAPACK.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindLibGDCM.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindMPI.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindMUMPS.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindNETGEN.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindOpt++.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindPETSC.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindPNG.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindPackageMultipass.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindPerlLibs.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindScoreP.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindSCALAPACK.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindSUNDIALS.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindTAO.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindTIFF.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindVALGRIND.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindwxWidgets.cmake
)
set(FIND_MODULE_WRAPPERS_FILES_LIST
)
set(OPENCMISS_MODULES_FILES_LIST
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCArchitecturePathFunctions.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCMiscFunctions.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCToolchainCompilers.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCToolchainChecks.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCDetermineMPI.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCPythonBindingsVirtualEnv.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCCheckSDKInstallation.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCMultiConfigEnvironment.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCScriptGenerateVirtualEnvCreateAndInstall.cmake
)
set(TEMPLATE_FILES_LIST
    ${CMAKE_CURRENT_SOURCE_DIR}/Templates/librarybindings.in.py
    ${CMAKE_CURRENT_SOURCE_DIR}/Templates/bindingsinfo.in.py
    ${CMAKE_CURRENT_SOURCE_DIR}/Templates/script_gen_bindings_info.in.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Templates/script_virtualenv_create_and_install.in.cmake
)

install(FILES ${MODULES_FILES_LIST}
    DESTINATION share/cmake/Modules
    COMPONENT CMakeFiles
)
install(FILES ${FIND_MODULE_WRAPPERS_FILES_LIST}
    DESTINATION share/cmake/Modules/FindModuleWrappers
    COMPONENT CMakeFiles
)
install(FILES ${TEMPLATE_FILES_LIST}
    DESTINATION share/cmake/Modules/Templates
    COMPONENT CMakeFiles
)
install(FILES ${OPENCMISS_MODULES_FILES_LIST}
    DESTINATION share/cmake/Modules/OpenCMISS
    COMPONENT CMakeFiles
)

set(PRINT_SUMMARY TRUE)
if (PRINT_SUMMARY)
    message(STATUS "@")
    message(STATUS "@@@@@@@@@@@@@@@@@@@@@@ SUMMARY @@@@@@@@@@@@@@@@@@@@@@@")
    message(STATUS "@")
    message(STATUS "@ OPENCMISS_CMAKE_MODULE_PATH: ${CMAKE_INSTALL_PREFIX}/share/cmake/Modules")
    message(STATUS "@")
    message(STATUS "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    message(STATUS "@")
endif ()
