########################################################################
# This script takes care to have the right MPI mnemonic set.
#
# The case of "no MPI" is not implemented yet, but can easily be done by having to specify "MPI=none" and let the script
# handle it.
#
# 1. MPI_HOME specified - Look exclusively at that location for binaries/libraries
#  a. MPI FOUND - ok, detect type and use that
#  b. MPI NOT FOUND - Error and abort
# 2. Nothing specified - Call FindMPI and let it come up with whatever is found on the default path
#  a. MPI_USE_SYSTEM = NO AND/OR No MPI found - Prescribe a reasonable system default choice and go with that
#  b. MPI_USE_SYSTEM = YES AND MPI found - Use the MPI implementation found on PATH/environment 
# 3. MPI mnemonic/variable specified
#  b. MPI_USE_SYSTEM = YES Try to find the specific version on the system
#  a. MPI_USE_SYSTEM = NO Build your own (unix only)

# MPI_HOME specified - use that and fail if there's no MPI
# We also infer the MPI mnemonic from the installation at MPI_HOME
if (DEFINED MPI_HOME AND NOT MPI_HOME STREQUAL "")
    log("Using MPI implementation at MPI_HOME=${MPI_HOME}")
    find_package(MPI QUIET)
    if (NOT MPI_FOUND)
        log("No MPI implementation found at MPI_HOME. Please check." ERROR)
    endif()
    if (NOT DEFINED MPI)
        # MPI_DETECTED is set by FindMPI.cmake to one of the mnemonics or unknown (MPI_TYPE_UNKNOWN in FindMPI.cmake)
        set(MPI ${MPI_DETECTED} CACHE STRING "Detected MPI implementation" FORCE)
    endif()
    if (NOT DEFINED MPI_BUILD_TYPE)
        set(MPI_BUILD_TYPE USER_MPIHOME)
        log("Using MPI via MPI_HOME variable.
If you want to use different build types for the same MPI implementation, please
you have to specify MPI_BUILD_TYPE. Using '${MPI_BUILD_TYPE}'.
https://github.com/OpenCMISS/manage/issues/28        
        " WARNING)
    endif()
else ()

    # Ensure lower-case mpi and upper case mpi build type
    # Whether to allow a system search for MPI implementations
    option(MPI_USE_SYSTEM "Allow to use a system MPI if found" YES)
    if (DEFINED MPI)
        string(TOLOWER ${MPI} MPI)
        set(MPI ${MPI} CACHE STRING "User-specified MPI implementation" FORCE)
    endif()
    if (DEFINED MPI_BUILD_TYPE)
        capitalise(MPI_BUILD_TYPE)
        set(MPI_BUILD_TYPE ${MPI_BUILD_TYPE} CACHE STRING "User-specified MPI build type" FORCE)
    else()
        if (DEFINED OC_DEFAULT_MPI_BUILD_TYPE)
            set(MPI_BUILD_TYPE ${OC_DEFAULT_MPI_BUILD_TYPE} CACHE STRING "MPI build type, initialized to default of ${OC_DEFAULT_MPI_BUILD_TYPE}")
	else()
            set(MPI_BUILD_TYPE Release CACHE STRING "MPI build type, initialized to default of Release")
	endif()
    endif()
    if (MPI_BUILD_TYPE STREQUAL DEBUG AND MPI_USE_SYSTEM)
        log("Cannot have debug MPI builds and MPI_USE_SYSTEM at the same time. Setting MPI_USE_SYSTEM=OFF" WARNING)
        set(MPI_USE_SYSTEM OFF CACHE BOOL "Allow to use a system MPI if found" FORCE)
    endif()
    
    # We did not get any user choice in terms of MPI
    if(NOT DEFINED MPI)
        # No MPI or MPI_HOME - let cmake look and find the default MPI.
        if(MPI_USE_SYSTEM)
            log("Looking for default system MPI...")
            find_package(MPI QUIET)
        endif()
        
        # If there's a system MPI, set MPI to the detected version
        if (MPI_FOUND)
            # MPI_DETECTED is set by FindMPI.cmake to one of the mnemonics or unknown (MPI_TYPE_UNKNOWN in FindMPI.cmake)
            set(MPI ${MPI_DETECTED} CACHE STRING "Detected MPI implementation" FORCE)
            log("Found '${MPI}'")
        else()
            # No MPI found - Prescribe a reasonable system default choice and go with that
            if (UNIX AND NOT APPLE)
                if (NOT DEFINED LINUX_DISTRIBUTION)
                    SET(LINUX_DISTRIBUTION FALSE CACHE STRING "Distribution information")
                    find_program(LSB lsb_release
                        DOC "Distribution information tool")
                    if (LSB)
                        execute_process(COMMAND ${LSB} -i
                            RESULT_VARIABLE RETFLAG
                            OUTPUT_VARIABLE DISTINFO
                            ERROR_VARIABLE ERRDISTINFO
                            OUTPUT_STRIP_TRAILING_WHITESPACE
                        )
                        if (NOT RETFLAG)
                            STRING(SUBSTRING ${DISTINFO} 16 -1 LINUX_DISTRIBUTION)
                        endif()
                    endif()
                endif()
                if (LINUX_DISTRIBUTION STREQUAL "Ubuntu" OR LINUX_DISTRIBUTION STREQUAL "Scientific" OR LINUX_DISTRIBUTION STREQUAL "Arch")
                    SET(SUGGESTED_MPI openmpi)
                elseif(LINUX_DISTRIBUTION STREQUAL "Fedora" OR LINUX_DISTRIBUTION STREQUAL "RedHat")
                    SET(SUGGESTED_MPI mpich)
                endif()
                if (SUGGESTED_MPI)
                    log("No MPI preferences given. We suggest '${SUGGESTED_MPI}' on Linux/${LINUX_DISTRIBUTION}")
                else()
                    log("Unknown distribution '${LINUX_DISTRIBUTION}': No default MPI recommendation implemented. Using '${OC_DEFAULT_MPI}'" WARNING)
                    SET(SUGGESTED_MPI ${OC_DEFAULT_MPI})
                endif()
            elseif(APPLE)
                set(SUGGESTED_MPI openmpi)
            elseif(WIN32)
                set(SUGGESTED_MPI msmpi)
            else()
                log("No default MPI suggestion implemented for your platform. Using '${OC_DEFAULT_MPI}'" WARNING)
                SET(SUGGESTED_MPI ${OC_DEFAULT_MPI})
            endif()
            set(MPI ${SUGGESTED_MPI} CACHE STRING "Auto-suggested MPI implementation" FORCE)
            unset(SUGGESTED_MPI)
        endif()
    endif()
endif()

####################################################################################################
# Find local MPI (own build dir or system-wide)
####################################################################################################
# As of here we always have an MPI mnemonic set, either by manual definition or detection
# of default MPI type. In the latter case we already have MPI_FOUND=TRUE.

# This variable is also used in the main CMakeLists file at path computations!
string(TOLOWER "${MPI_BUILD_TYPE}" MPI_BUILD_TYPE_LOWER)

if (NOT MPI_FOUND AND MPI_USE_SYSTEM) 
    # Educated guesses are used to look for an MPI implementation
    # This bit of logic is covered inside the FindMPI module where MPI is consumed
    log("Looking for '${MPI}' MPI on local system..")
    find_package(MPI QUIET)
endif()

# Last check before building - there might be an own already built MPI implementation
if (NOT MPI_FOUND)
    if (MPI_USE_SYSTEM)
        log("No (matching) system MPI found.")    
    endif()
    log("Checking if own build already exists.")
    
    # Construct installation path
    # For MPI we use a slightly different architecture path - we dont need to re-build MPI for static/shared builds nor do we need the actual
    # MPI mnemonic in the path. Instead, we use "mpi" as common top folder to collect all local MPI builds.
    # Only the debug/release versions of MPI are located in different folders (for own builds only - the behaviour using system mpi
    # in debug mode is unspecified)
    set(SYSTEM_PART_ARCH_PATH .)
    if (OC_USE_ARCHITECTURE_PATH)
        getSystemPartArchitecturePath(SYSTEM_PART_ARCH_PATH)
    endif()

    # This is where our own build of MPI will reside if compilation is needed
    set(OWN_MPI_INSTALL_DIR ${OPENCMISS_OWN_MPI_INSTALL_PREFIX}/${SYSTEM_PART_ARCH_PATH}/${MPI}/${MPI_BUILD_TYPE_LOWER})

    # Set MPI_HOME to the install location - its not set outside anyways (see first if case at top)
    # Important: Do not unset(MPI_HOME) afterwards - this needs to get passed to all external projects the same way
    # it has been after building MPI in the first place.
    set(MPI_HOME "${OWN_MPI_INSTALL_DIR}" CACHE STRING "Installation directory of own/local MPI build" FORCE)
    find_package(MPI QUIET)
    if (MPI_FOUND)
        log("Using own '${MPI}' MPI: ${OWN_MPI_INSTALL_DIR}")
    endif()
endif()

