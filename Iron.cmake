if (OCM_USE_IRON)
    set(SUBGROUP_PATH .)
    set(GITHUB_ORGANIZATION OpenCMISS)
    
    ADD_COMPONENT(IRON
        -DWITH_CELLML=${IRON_WITH_CELLML})
endif()