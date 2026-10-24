function(add_unit_test test target)
    add_executable(${target} ${ARGN})

    target_compile_options(
        ${target}
        PRIVATE
            -UNDEBUG
    )

    target_link_libraries(
        ${target}
        PRIVATE
            template_iso_c_core
    )

    add_test(
        NAME ${test}
        COMMAND ${target}
    )

    set_tests_properties(
        ${test}
        PROPERTIES
            TIMEOUT 60
            LABELS unit
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
endfunction()

add_unit_test(unit.todo template_iso_c_tests test_todo.c)
