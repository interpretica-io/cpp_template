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

find_package(Doxygen)

if (DOXYGEN_FOUND)
    # set input and output files
    set(DOXYGEN_IN ${CMAKE_CURRENT_SOURCE_DIR}/docs/doxygen.config.in)
    set(DOXYGEN_OUT ${CMAKE_CURRENT_BINARY_DIR}/docs/Doxyfile)

    # request to configure the file
    configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)
    message("Doxygen build started")

    # note the option ALL which allows to build the docs together with the application
    add_custom_target( doc
        COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generating API documentation with Doxygen"
        VERBATIM )
else (DOXYGEN_FOUND)
  message("Doxygen need to be installed to generate the doxygen documentation")
endif (DOXYGEN_FOUND)
