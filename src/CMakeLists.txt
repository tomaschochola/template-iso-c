include(CheckPIESupported)

check_pie_supported(LANGUAGES C)

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

target_compile_features(
    template_iso_c_core
    PUBLIC
        c_std_23
)

set_target_properties(
    template_iso_c_core
    PROPERTIES
        C_EXTENSIONS OFF
        C_STANDARD_REQUIRED ON
        POSITION_INDEPENDENT_CODE ON
)

target_link_libraries(
    template_iso_c_core
    PRIVATE
        template_iso_c_warnings
)

add_executable(template_iso_c)

target_sources(
    template_iso_c
    PRIVATE
        main.c
)

target_compile_features(
    template_iso_c
    PRIVATE
        c_std_23
)

set_target_properties(
    template_iso_c
    PROPERTIES
        C_EXTENSIONS OFF
        C_STANDARD_REQUIRED ON
        POSITION_INDEPENDENT_CODE ON
        OUTPUT_NAME "template-iso-c"
)

target_link_libraries(
    template_iso_c
    PRIVATE
        template_iso_c_core
        template_iso_c_warnings
)

install(
    TARGETS template_iso_c
    RUNTIME
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)
