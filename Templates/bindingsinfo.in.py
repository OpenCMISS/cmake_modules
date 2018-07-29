#!/usr/bin/env python
# This file contains information about installed virtual environments 

info = { "dir": "@VIRTUALENV_COMPLETE_INSTALL_PREFIX_WO_CONFIG@${BTYPE}",
         "toolchain": "@_ACTIVE_TOOLCHAIN@", "compiler": "@_ACTIVE_COMPILER@", "buildtype": "${BTYPE}",
         "mpi": "@_ACTIVE_MPI@", "mpi_home": "@OPENCMISS_MPI_HOME@", "mpi_buildtype": "@OPENCMISS_MPI_BUILD_TYPE@",
         "library_path": "@LIBRARY_PATH@", "library": "@PYTHON_PACKAGE_CURRENT_NAME@", "python_ver": "@Python_VERSION@", "activate": "${ACTIVATE_SCRIPT}", }

