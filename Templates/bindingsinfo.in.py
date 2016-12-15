#!/usr/bin/env python
# This file contains information about installed virtual environments 

info = { "dir": "@VIRTUALENV_COMPLETE_INSTALL_PREFIX_WO_CONFIG@${BTYPE}",
         "toolchain": "@TOOLCHAIN@", "compiler": "@COMPILER@", "buildtype": "${BTYPE}",
         "mpi": "@OPENCMISS_MPI@", "mpi_home": "@OPENCMISS_MPI_HOME@", "mpi_buildtype": "@OPENCMISS_MPI_BUILD_TYPE@",
         "library_path": "@LIBRARY_PATH@", "library": "@PYTHON_PACKAGE_CURRENT_NAME@", "python_ver": "@PYTHONLIBS_VERSION_STRING@", "activate": "${ACTIVATE_SCRIPT}", }

