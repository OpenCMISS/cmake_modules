
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

if (GENERATE_COMPONENTS)
    string(REPLACE ";" "-semi-colon-" GENERATE_COMPONENTS_LIST "${GENERATE_COMPONENTS}")
    set(GENERATE_COMPONENTS_OPTION -DGENERATE_COMPONENTS=${GENERATE_COMPONENTS_LIST})
    unset(GENERATE_COMPONENTS CACHE)
endif ()
add_custom_target(generate_find_module_wrappers
    COMMAND ${CMAKE_COMMAND} ${GENERATE_COMPONENTS_OPTION} -DFINDXXX_TEMPLATE=${CMAKE_CURRENT_SOURCE_DIR}/Templates/FindXXX.template.cmake -P ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCGenerateFindModuleWrappers.cmake
)

set(CMAKE_MODULES_INSTALL_PREFIX "${_INSTALL_PREFIX}" CACHE PATH "Install path prefix, prepended onto install directories.")
if (DEFINED INSTALL_PREFIX)
    set(CMAKE_MODULES_INSTALL_PREFIX "${INSTALL_PREFIX}" CACHE PATH "Install path prefix, prepended onto install directories." FORCE)
endif ()
set(CMAKE_INSTALL_PREFIX "${CMAKE_MODULES_INSTALL_PREFIX}" CACHE INTERNAL "Internalise install path prefix." FORCE)

set(FIND_MPI_MODULE_FILE
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindMPI.cmake
)
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
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindLibraryUtilityFunctions.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindMKL.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindMUMPS.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindNETGEN.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindOpt++.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindOSMesa.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindPETSC.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindPNG.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindPackageMultipass.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindPerlLibs.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindPython.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindPython2.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindPython3.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindScoreP.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindSCALAPACK.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindSUNDIALS.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindTAO.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindTIFF.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindVALGRIND.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindwxWidgets.cmake
)
set(FINDPYTHON_MODULES_FILES_LIST
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindPython/Support.cmake
)
set(FINDMPI_MODULES_FILES_LIST
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindMPI/fortranparam_mpi.f90.in
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindMPI/libver_mpi.c
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindMPI/libver_mpi.f90.in
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindMPI/mpiver.f90.in
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindMPI/test_mpi.c
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindMPI/test_mpi.f90.in
)
set(FIND_MODULE_WRAPPERS_FILES_LIST
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindBLAS.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindBZip2.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindCSim.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindClang.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindFTGL.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindFreetype.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindGDCM-ABI.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindGLEW.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindGTest.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindHDF5.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindHYPRE.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindITK.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindImageMagick.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindJPEG.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindLAPACK.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindLLVM.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindLibXml2.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindMUMPS.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindNETGEN.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindOPTPP.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindPARMETIS.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindPASTIX.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindPETSC.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindPLAPACK.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindPNG.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindSCALAPACK.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindSCOTCH.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindSLEPC.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindSOWING.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindSUITESPARSE.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindSUNDIALS.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindSUPERLU.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindSUPERLU_DIST.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindSZIP.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindTIFF.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Modules/FindModuleWrappers/FindZLIB.cmake
)
set(OPENCMISS_MODULES_FILES_LIST
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCArchitecturePathFunctions.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCMiscFunctions.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCToolchainCompilers.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCToolchainFlags.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCInstrumentation.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCToolchainChecks.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCPythonBindingsVirtualEnv.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCCheckSDKInstallation.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCMultiConfigEnvironment.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCScriptGenerateVirtualEnvCreateAndInstall.cmake
)
set(OPENCMISS_MPI_MODULES_FILES_LIST
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCDetermineMPIFunctions.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCPostSelectMPI.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCPreSelectMPI.cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/Scripts/OCSelectMPI.cmake
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
install(FILES ${FIND_MPI_MODULE_FILE}
    DESTINATION share/cmake/Modules
    COMPONENT SDK
)
install(FILES ${FINDPYTHON_MODULES_FILES_LIST}
    DESTINATION share/cmake/Modules/FindPython
    COMPONENT SDK
)
install(FILES ${FINDMPI_MODULES_FILES_LIST}
    DESTINATION share/cmake/Modules/FindMPI
    COMPONENT SDK
)
install(FILES ${OPENCMISS_MPI_MODULES_FILES_LIST}
    DESTINATION share/cmake/Modules/OpenCMISS
    COMPONENT SDK
)

set(PRINT_SUMMARY TRUE)
if (PRINT_SUMMARY)
    message(STATUS "@")
    message(STATUS "@@@@@@@@@@@@@@@@@@@@@@ SUMMARY @@@@@@@@@@@@@@@@@@@@@@@")
    message(STATUS "@")
    message(STATUS "@ OPENCMISS_CMAKE_MODULE_PATH: ${CMAKE_INSTALL_PREFIX}/share/cmake/Modules")
    message(STATUS "@ OPENCMISS_INSTRUMENTATION: ${OPEMCMISS_INSTRUMENTATION}")
    message(STATUS "@")
    message(STATUS "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
    message(STATUS "@")
endif ()
