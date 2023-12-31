# Toolchain for Windows (MinGW-based)

set(CMAKE_SYSTEM_NAME Windows)

set(COMPILER_PREFIX "x86_64-w64-mingw32")

find_program(CMAKE_C_COMPILER HINTS ${CMAKE_FIND_ROOT_PATH} NAMES ${COMPILER_PREFIX}-clang REQUIRED)
find_program(CMAKE_CXX_COMPILER HINTS ${CMAKE_FIND_ROOT_PATH} NAMES ${COMPILER_PREFIX}-clang++ REQUIRED)

SET(CMAKE_FIND_ROOT_PATH  /usr/${COMPILER_PREFIX})

add_definitions(-D__USE_MINGW_ANSI_STDIO=1 -D_WIN32_WINNT=0x0600)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
