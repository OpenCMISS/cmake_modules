
########################################################
# If your cmake is older than 3.4 - goodbye.
cmake_minimum_required(VERSION 3.4.0 FATAL_ERROR)

########################################################################
# Ready to start the "CMake Modules"
project(OpenCMISS-CMake-Modules VERSION 1.0.0 LANGUAGES CXX)

set(OPENCMISS_CMAKE_MODULES_PATH ${OPENCMISS_CMAKE_MODULES_PATH} CACHE PATH "Location of OpenCMISS CMake files.")

set(MODULES_FILES_LIST
    ${CMAKE_CURRENT_SOURCE_DIR}/CMakeModules/FindMPI.cmake
    )

install(FILES ${MODULES_FILES_LIST}
    DESTINATION ${OPENCMISS_CMAKE_MODULES_PATH}/Modules
    )
