add_library(template_iso_c_test STATIC)

target_sources(
    template_iso_c_test
    PRIVATE
        test.c
    PUBLIC
        FILE_SET HEADERS
        BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
        FILES test.h
)

target_compile_features(
    template_iso_c_test
    PUBLIC
        c_std_23
)

set_target_properties(
    template_iso_c_test
    PROPERTIES
        C_EXTENSIONS OFF
        C_STANDARD_REQUIRED ON
        POSITION_INDEPENDENT_CODE ON
)

target_link_libraries(
    template_iso_c_test
    PRIVATE
        template_iso_c_warnings
)

function(template_iso_c_add_unit_test test target)
    add_executable(${target} ${ARGN})

    target_compile_features(
        ${target}
        PRIVATE
            c_std_23
    )

    set_target_properties(
        ${target}
        PROPERTIES
            C_EXTENSIONS OFF
            C_STANDARD_REQUIRED ON
            POSITION_INDEPENDENT_CODE ON
    )

    target_link_libraries(
        ${target}
        PRIVATE
            template_iso_c_core
            template_iso_c_test
            template_iso_c_warnings
    )

    add_test(
        NAME ${test}
        COMMAND ${target}
    )

    set_tests_properties(
        ${test}
        PROPERTIES
            TIMEOUT 5
            LABELS unit
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
endfunction()

template_iso_c_add_unit_test(unit.todo template_iso_c_tests test_todo.c)
