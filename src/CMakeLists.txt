configure_file(
    cli_config.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/cli_config.h
    @ONLY
)

add_library(template_iso_c_core STATIC)

target_link_libraries(template_iso_c_core PRIVATE project_compile_options)

target_sources(
    template_iso_c_core
    PRIVATE
        cli.c
    PUBLIC
        FILE_SET HEADERS
        BASE_DIRS
            ${CMAKE_CURRENT_SOURCE_DIR}
            ${CMAKE_CURRENT_BINARY_DIR}
        FILES
            cli.h
            ${CMAKE_CURRENT_BINARY_DIR}/cli_config.h
)

add_executable(template_iso_c)

target_sources(
    template_iso_c
    PRIVATE
        main.c
)

set_target_properties(
    template_iso_c
    PROPERTIES
        OUTPUT_NAME "${PROJECT_NAME}"
)

target_link_libraries(
    template_iso_c
    PRIVATE
        project_compile_options
        template_iso_c_core
)

install(
    TARGETS
        template_iso_c
    RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)
