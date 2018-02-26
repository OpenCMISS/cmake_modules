# This variable checks if we have a multiconfig environment.
# Needs to be extended for other multiconf like MSVC as we go.
set(OPENCMISS_HAVE_MULTICONFIG_ENV NO)
if (MSVC OR XCODE)
    set(OPENCMISS_HAVE_MULTICONFIG_ENV YES)
endif ()

