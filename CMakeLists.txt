cmake_minimum_required(VERSION 4.4)

project(
    template_iso_c
    VERSION 0.0.0
    DESCRIPTION "Native GNU/Linux GCC ISO C23 project template"
    LANGUAGES C
)

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(FATAL_ERROR "template-iso-c supports GNU/Linux only")
endif()

if(CMAKE_CROSSCOMPILING)
    message(FATAL_ERROR "template-iso-c supports native builds only")
endif()

if(NOT CMAKE_C_COMPILER_ID STREQUAL "GNU")
    message(FATAL_ERROR "template-iso-c requires GCC")
endif()

include(GNUInstallDirs)
set(MEMORYCHECK_COMMAND_OPTIONS "--leak-check=full --track-origins=yes")
include(CTest)
include(CMakePackageConfigHelpers)

if(BUILD_SHARED_LIBS)
    set(CMAKE_INSTALL_RPATH "$ORIGIN;$ORIGIN/../lib")
endif()
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)

add_library(template_iso_c_warnings INTERFACE)
target_compile_options(
    template_iso_c_warnings
    INTERFACE
        -Wall
        -Wextra
        -Wpedantic
        -pedantic-errors
)
target_compile_definitions(template_iso_c_warnings INTERFACE _GNU_SOURCE)

add_subdirectory(src)

if(BUILD_TESTING)
    add_subdirectory(tests)
endif()

install(EXPORT template-iso-cTargets
    NAMESPACE template_iso_c::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/template-iso-c
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/template-iso-cConfigVersion.cmake
    COMPATIBILITY SameMajorVersion
)

install(FILES
    cmake/template-iso-cConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/template-iso-cConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/template-iso-c
)

install(FILES LICENSE DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/doc/template-iso-c")

set(CPACK_PACKAGE_NAME "template-iso-c")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_DESCRIPTION}")
set(CPACK_PACKAGE_VENDOR "Tomáš Chochola")
set(CPACK_GENERATOR "TGZ")
set(CPACK_PACKAGE_CHECKSUM "SHA256")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE")

include(CPack)
