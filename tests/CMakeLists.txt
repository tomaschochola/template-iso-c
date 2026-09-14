add_executable(template_iso_c_tests)
target_sources(template_iso_c_tests PRIVATE test_todo.c)

target_compile_features(template_iso_c_tests PRIVATE c_std_23)

set_target_properties(template_iso_c_tests PROPERTIES C_EXTENSIONS OFF C_STANDARD_REQUIRED ON)

target_link_libraries(template_iso_c_tests PRIVATE template_iso_c_app template_iso_c_warnings)

add_test(NAME unit.todo COMMAND template_iso_c_tests)
add_test(NAME integration.cli COMMAND template_iso_c)
set_tests_properties(unit.todo integration.cli PROPERTIES TIMEOUT 30)
