
########################################################
# If your cmake is older than 3.4 - goodbye.
cmake_minimum_required(VERSION 3.4.0 FATAL_ERROR)

########################################################################
# Ready to start the "CMake Modules"
project(OpenCMISS-CMake-Modules VERSION 1.0.0 LANGUAGES CXX)

if (NOT DEFINED OPENCMISS_CMAKE_MODULE_PATH)
    # Standard installation scenario and the module path can be found relative to this directory
    get_filename_component(OPENCMISS_CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../install/share/cmake" REALPATH)
endif ()

set(OPENCMISS_CMAKE_MODULE_PATH ${OPENCMISS_CMAKE_MODULE_PATH} CACHE PATH "Location of OpenCMISS CMake files.")

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
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindSCALAPACK.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindSUNDIALS.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindTAO.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindTIFF.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindVALGRIND.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindwxWidgets.cmake
    )
set(PACKAGES_FILES_LIST
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts/OCArchitecturePathFunctions.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts/OCMiscFunctionsMacros.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts/OCToolchainCompilers.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts/OCToolchainChecks.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts/OCDetermineMPI.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts/OCCheckSDKInstallation.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeScripts/OCMultiConfigEnvironment.cmake
    )

install(FILES ${MODULES_FILES_LIST}
    DESTINATION ${OPENCMISS_CMAKE_MODULE_PATH}/Modules
    )
install(FILES ${PACKAGES_FILES_LIST}
    DESTINATION ${OPENCMISS_CMAKE_MODULE_PATH}/Modules/Packages
    )

set(PRINT_SUMMARY TRUE)
if (PRINT_SUMMARY)
    message(STATUS "")
    message(STATUS "====================== SUMMARY ==========================")
    message(STATUS "")
    message(STATUS "OPENCMISS_CMAKE_MODULE_PATH: ${OPENCMISS_CMAKE_MODULE_PATH}")
    message(STATUS "")
    message(STATUS "=========================================================")
    message(STATUS "")
endif ()
