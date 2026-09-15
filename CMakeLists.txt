cmake_minimum_required(VERSION 4.4)

if(DEFINED ENV{VERSION})
    set(TEMPLATE_ISO_C_VERSION "$ENV{VERSION}")
else()
    set(TEMPLATE_ISO_C_VERSION "0.0.0")
endif()

if(NOT TEMPLATE_ISO_C_VERSION MATCHES "^[0-9]+(\\.[0-9]+)?(\\.[0-9]+)?(\\.[0-9]+)?$")
    message(FATAL_ERROR "VERSION must be numeric CMake version")
endif()

if(DEFINED ENV{SOURCE_DATE_EPOCH})
    if(NOT "$ENV{SOURCE_DATE_EPOCH}" MATCHES "^[0-9]+$")
        message(FATAL_ERROR "SOURCE_DATE_EPOCH must contain only decimal digits")
    endif()
endif()

project(
    template_iso_c
    VERSION "${TEMPLATE_ISO_C_VERSION}"
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

install(FILES LICENSE DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/doc/template-iso-c")

set(CPACK_PACKAGE_NAME "template-iso-c")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_DESCRIPTION}")
set(CPACK_PACKAGE_VENDOR "Tomáš Chochola")
set(CPACK_GENERATOR "TGZ")
set(CPACK_PACKAGE_CHECKSUM "SHA256")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE")

include(CPack)
