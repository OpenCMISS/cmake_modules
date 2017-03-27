
########################################################
# If your cmake is older than 3.4 - goodbye.
cmake_minimum_required(VERSION 3.4.0 FATAL_ERROR)

########################################################################
# Ready to start the "CMake Modules"
project(OpenCMISS-CMake-Modules VERSION 1.0.0 LANGUAGES CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts)
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
get_filename_component(_INSTALL_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../../install/share/cmake" REALPATH)

set(CMAKE_MODULES_INSTALL_PREFIX "${_INSTALL_PREFIX}" CACHE PATH "Install path prefix, prepended onto install directories.")
if (DEFINED INSTALL_PREFIX)
    set(CMAKE_MODULES_INSTALL_PREFIX "${INSTALL_PREFIX}" CACHE PATH "Install path prefix, prepended onto install directories." FORCE)
endif ()
set(CMAKE_INSTALL_PREFIX "${CMAKE_MODULES_INSTALL_PREFIX}" CACHE INTERNAL "Internalise install path prefix." FORCE)

set(MODULES_FILES_LIST
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindBLACS.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindBLAS.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindFTGL.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindGLEW.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindGTKGLext.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindGit.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindHYPRE.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindImageMagick.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindJPEG.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindLAPACK.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindLibGDCM.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindMPI.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindMUMPS.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindNETGEN.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindOpt++.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindPETSC.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindPNG.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindPackageMultipass.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindPerlLibs.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindScoreP.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindSCALAPACK.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindSUNDIALS.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindTAO.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindTIFF.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindVALGRIND.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindwxWidgets.cmake
)
set(OPENCMISS_MODULES_FILES_LIST
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts/OCArchitecturePathFunctions.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts/OCMiscFunctions.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts/OCToolchainCompilers.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts/OCToolchainChecks.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts/OCDetermineMPI.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts/OCPythonBindingsVirtualEnv.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts/OCCheckSDKInstallation.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts/OCMultiConfigEnvironment.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts/OCScriptGenerateVirtualEnvCreateAndInstall.cmake
)
set(TEMPLATE_FILES_LIST
    ${CMAKE_CURRENT_SOURCE_DIR}/Templates/librarybindings.in.py
    ${CMAKE_CURRENT_SOURCE_DIR}/Templates/bindingsinfo.in.py
    ${CMAKE_CURRENT_SOURCE_DIR}/Templates/script_gen_bindings_info.in.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Templates/script_virtualenv_create_and_install.in.cmake
)

install(FILES ${MODULES_FILES_LIST}
    DESTINATION Modules
    COMPONENT CMakeFiles
)
install(FILES ${TEMPLATE_FILES_LIST}
    DESTINATION Templates
    COMPONENT CMakeFiles
)
install(FILES ${OPENCMISS_MODULES_FILES_LIST}
    DESTINATION Modules/OpenCMISS
    COMPONENT CMakeFiles
)

set(PRINT_SUMMARY TRUE)
if (PRINT_SUMMARY)
    message(STATUS "@")
    message(STATUS "@@@@@@@@@@@@@@@@@@@@@@ SUMMARY @@@@@@@@@@@@@@@@@@@@@@@")
    message(STATUS "@")
    message(STATUS "@ OPENCMISS_CMAKE_MODULE_PATH: ${CMAKE_INSTALL_PREFIX}")
    message(STATUS "@")
    message(STATUS "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    message(STATUS "@")
endif ()
