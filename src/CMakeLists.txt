include(CheckPIESupported)
check_pie_supported(LANGUAGES C)

add_executable(template_iso_c)
target_sources(template_iso_c PRIVATE main.c todo.c)

target_compile_features(template_iso_c PRIVATE c_std_23)

set_target_properties(template_iso_c PROPERTIES
    C_EXTENSIONS OFF
    C_STANDARD_REQUIRED ON
    POSITION_INDEPENDENT_CODE ON
    OUTPUT_NAME "template-iso-c"
)

target_link_libraries(template_iso_c PRIVATE template_iso_c_warnings)

install(TARGETS template_iso_c RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
