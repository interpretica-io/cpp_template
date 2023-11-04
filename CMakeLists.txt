# Test package build script.
# @author Maxim Menshikov (maxim.menshikov@interpretica.io)
cmake_minimum_required(VERSION 3.0)

project(cpp_template_main)

set(GOOGLETEST_VERSION v1.14.0)
include(${CMAKE_SOURCE_DIR}/site/site-public.cmake)
include(${CMAKE_SOURCE_DIR}/deps/googletest.cmake)

# MinGW libraries
include(${CMAKE_SOURCE_DIR}/deps/mingw_libs.cmake)
if (WIN32)
    install(DIRECTORY ${USR_DIR_MINGW_LIBS}/
            DESTINATION "bin"
            COMPONENT applications
            FILES_MATCHING
            PATTERN "*.dll*"
            PATTERN "*.so*"
            PATTERN "*.dylib*")
endif ()

add_subdirectory(src)
add_subdirectory(unittest)
