# This variable checks if we have a multiconfig environment.
# Needs to be extended for other multiconf like MSVC as we go.
set(OPENCMISS_HAVE_MULTICONFIG_ENV NO)
set(TEST_TARGET_NAME test)
if (MSVC)
    set(OPENCMISS_HAVE_MULTICONFIG_ENV YES)
    set(TEST_TARGET_NAME RUN_TESTS)
endif ()

