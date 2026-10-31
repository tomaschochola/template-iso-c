cmake_minimum_required(VERSION 4.4)

project(
    template_iso_c
    VERSION 0.0.0
    SPDX_LICENSE "BSD-3-Clause"
    DESCRIPTION "github.com/tomaschochola/template-iso-c"
    HOMEPAGE_URL "https://github.com/tomaschochola/template-iso-c"
    LANGUAGES C
)

set(CMAKE_C23_STANDARD_COMPILE_OPTION "-std=c23")
set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)

add_compile_options(
    -Wall
    -Wextra
    -Wpedantic
    -pedantic-errors
)

add_compile_definitions(_GNU_SOURCE=1)

include(GNUInstallDirs)

include(CheckPIESupported)
check_pie_supported(LANGUAGES C)

set(MEMORYCHECK_COMMAND_OPTIONS "-q --tool=memcheck --leak-check=full --error-exitcode=255")

include(CTest)

add_subdirectory(src)

if(BUILD_TESTING)
    add_subdirectory(tests)
endif()

install(
    FILES LICENSE
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/doc/template-iso-c"
)

set(CPACK_PACKAGE_NAME "template-iso-c")
set(CPACK_PACKAGE_VENDOR "Tomáš Chochola")
set(CPACK_GENERATOR "TGZ")
set(CPACK_PACKAGE_CHECKSUM "SHA256")
set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${PROJECT_VERSION}-${X_CPACK_PACKAGE_VARIANT}")
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE")
set(CPACK_VERBATIM_VARIABLES TRUE)

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CPACK_STRIP_FILES TRUE)
endif()

include(CPack)
