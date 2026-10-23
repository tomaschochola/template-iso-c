add_library(template_iso_c_core STATIC)

target_sources(
    template_iso_c_core
    PRIVATE
        todo.c
    PUBLIC
        FILE_SET HEADERS
        BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
        FILES todo.h
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
        OUTPUT_NAME "template-iso-c"
)

target_link_libraries(
    template_iso_c
    PRIVATE
        template_iso_c_core
)

install(
    TARGETS template_iso_c
    RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)
