MACRO(GET_COMPILER_NAME VARNAME)
	# Get the compiler name
	IF( MINGW )
		SET(${VARNAME} "mingw" )
	ELSEIF( MSYS )
		SET(${VARNAME} "msys" )
	ELSEIF( BORLAND )
		SET(${VARNAME} "borland" )
	ELSEIF( WATCOM )
		SET(${VARNAME} "watcom" )
	ELSEIF( MSVC OR MSVC_IDE OR MSVC60 OR MSVC70 OR MSVC71 OR MSVC80 OR CMAKE_COMPILER_2005 OR MSVC90 )
		SET(${VARNAME} "msvc" )
	ELSEIF( CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
	    execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpversion
	        RESULT_VARIABLE RES
	        OUTPUT_VARIABLE VERSION
	        OUTPUT_STRIP_TRAILING_WHITESPACE)
	    if (NOT RES EQUAL 0)
	        SET(VERSION "0.0")
	    endif()
	    SET(${VARNAME} gnu-${VERSION})
	ELSEIF(${CMAKE_C_COMPILER} MATCHES icc 
	    OR ${CMAKE_CXX_COMPILER} MATCHES icpc
	    OR ${CMAKE_Fortran_COMPILER} MATCHES ifort)
	    SET(${VARNAME} "intel")
	ELSEIF( CYGWIN )
		SET(${VARNAME} "cygwin")
	ENDIF()
ENDMACRO()

# This function assembles the architecture path
# We have [ARCH][COMPILER][MPI][MT][STATIC|SHARED]
function(get_architecture_path VARNAME)
    SET(ARCHPATH )
    
    if(OCM_USE_ARCHITECTURE_PATH)
        # Architecture/System
        STRING(TOLOWER ${CMAKE_SYSTEM_NAME} CMAKE_SYSTEM_NAME_LOWER)
        SET(ARCHPATH ${CMAKE_SYSTEM_PROCESSOR}_${CMAKE_SYSTEM_NAME_LOWER})
        
        # Bit/Adressing bandwidth
        #if (ABI)
        #    SET(ARCHPATH ${ARCHPATH}/${ABI}bit)
        #endif()
        
        # Compiler
        GET_COMPILER_NAME(COMPILER)
        SET(ARCHPATH ${ARCHPATH}/${COMPILER})
        
        # MPI version information
        if (OCM_USE_MPI)
            SET(MPI_PART ${MPI})
        else()
            SET(MPI_PART "sequential")
        endif()
        SET(ARCHPATH ${ARCHPATH}/${MPI_PART})
        
        # Multithreading
        if (OCM_USE_MT)
            SET(ARCHPATH ${ARCHPATH}/mt)
        endif()
        
        # Library type (static/shared)
        if (BUILD_SHARED_LIBS)
            SET(ARCHPATH ${ARCHPATH}/shared)    
        else()
            SET(ARCHPATH ${ARCHPATH}/static)
        endif()
        
    else()
        SET(ARCHPATH .)
    endif()
    
    #if (ARGC EQUAL 2 AND ARGV1 STREQUAL FULL)
    #    get_build_type_extra(BUILDTYPEEXTRA)
    #    SET(ARCHPATH ${ARCHPATH}/${BUILDTYPEEXTRA})
    #endif()
    
    # Append to desired variable
    SET(${VARNAME} ${ARCHPATH} PARENT_SCOPE)
endfunction()

function(get_build_type_extra VARNAME)
    # Build type
    if (CMAKE_BUILD_TYPE)
        STRING(TOLOWER ${CMAKE_BUILD_TYPE} buildtype)
        SET(BUILDTYPEEXTRA ${buildtype})
    elseif (NOT CMAKE_CFG_INTDIR STREQUAL .)
        SET(BUILDTYPEEXTRA ) #${CMAKE_CFG_INTDIR}
    else()
        SET(BUILDTYPEEXTRA noconfig)
    endif()
    SET(${VARNAME} ${BUILDTYPEEXTRA} PARENT_SCOPE)
endfunction()