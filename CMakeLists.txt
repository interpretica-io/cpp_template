# Test package build script.
# @author Maxim Menshikov (maxim.menshikov@interpretica.io)
cmake_minimum_required(VERSION 3.0)

project(cpp_template_main)

set(GOOGLETEST_VERSION v1.14.0)
include(${CMAKE_SOURCE_DIR}/site/site-public.cmake)
include(${CMAKE_SOURCE_DIR}/deps/googletest.cmake)

add_subdirectory(src)
add_subdirectory(unittest)
