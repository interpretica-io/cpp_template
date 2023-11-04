# Test package build script.
# @author Maxim Menshikov (maxim.menshikov@interpretica.io)
cmake_minimum_required(VERSION 3.0)

project(cpp_template_test)

# Create a shared library
add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME} PRIVATE gtest_main)

install(TARGETS ${PROJECT_NAME}
        RUNTIME
        DESTINATION ${DISTR_BINARY_PATH}
        COMPONENT applications)
