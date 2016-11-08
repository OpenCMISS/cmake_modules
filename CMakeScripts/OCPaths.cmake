
# Set paths for the OPENCMISS Build.

# Extra path segment for single configuration case - will give release/debug/...
getBuildTypePathElem(BUILDTYPEEXTRA)

# Install tree locations for components (with/without mpi)
if (DEFINED OPENCMISS_ROOT)
  set(OPENCMISS_FINDMODULEWRAPPERS_INSTALL_PREFIX ${OPENCMISS_ROOT}/install/cmake/FindModuleWrappers)
  set(OPENCMISS_EXPORT_INSTALL_ROOT "${OPENCMISS_ROOT}/install")
  set(OPENCMISS_INSTALL_ROOT_PYTHON "${OPENCMISS_ROOT}/install/python")
else ()
  set(OPENCMISS_FINDMODULEWRAPPERS_INSTALL_PREFIX ${CMAKE_CURRENT_LIST_DIR}/../FindModuleWrappers)
  set(OPENCMISS_EXPORT_INSTALL_ROOT "${OPENCMISS_LIBRARIES_ROOT}/install")
  set(OPENCMISS_INSTALL_ROOT_PYTHON "${OPENCMISS_LIBRARIES_ROOT}/install/python")
endif ()

set(OC_EXTPROJ_STAMP_DIR extproj/stamp)
set(OC_EXTPROJ_TMP_DIR extproj/tmp)
