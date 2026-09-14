include(GenerateExportHeader)

add_library(template_iso_c_app)
add_library(template_iso_c::template_iso_c_app ALIAS template_iso_c_app)

generate_export_header(template_iso_c_app
    BASE_NAME TEMPLATE_ISO_C
    EXPORT_FILE_NAME ${PROJECT_BINARY_DIR}/include/template_iso_c/export.h
)

target_sources(template_iso_c_app
    PRIVATE
        todo.c
    PUBLIC
        FILE_SET HEADERS
        BASE_DIRS ${PROJECT_SOURCE_DIR}/include ${PROJECT_BINARY_DIR}/include
        FILES ${PROJECT_SOURCE_DIR}/include/template_iso_c/todo.h ${PROJECT_BINARY_DIR}/include/template_iso_c/export.h
)

target_compile_features(template_iso_c_app PUBLIC c_std_23)

set_target_properties(template_iso_c_app PROPERTIES
    C_EXTENSIONS OFF
    C_STANDARD_REQUIRED ON
    C_VISIBILITY_PRESET hidden
    POSITION_INDEPENDENT_CODE ON
    VERIFY_INTERFACE_HEADER_SETS ON
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)

target_link_libraries(template_iso_c_app PRIVATE $<BUILD_INTERFACE:template_iso_c_warnings>)

add_executable(template_iso_c)
target_sources(template_iso_c PRIVATE main.c)

target_compile_features(template_iso_c PRIVATE c_std_23)

set_target_properties(template_iso_c PROPERTIES
    C_EXTENSIONS OFF
    C_STANDARD_REQUIRED ON
    OUTPUT_NAME "template-iso-c"
)

target_link_libraries(template_iso_c PRIVATE template_iso_c_app $<BUILD_INTERFACE:template_iso_c_warnings>)

install(TARGETS template_iso_c EXPORT template-iso-cTargets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(TARGETS template_iso_c_app EXPORT template-iso-cTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    FILE_SET HEADERS DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
