# MinGW libraries
cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

include(ExternalProject)

if (NOT WIN32)
  return ()
endif ()

set(USR_DIR_MINGW_LIBS ${CMAKE_CURRENT_BINARY_DIR}/usr/mingw-libs)

ExternalProject_Add(
  mingw_libs_ext
  URL ${SITE_URL_MINGW_LIB_PREBUILT}
  BUILD_COMMAND ""
  CONFIGURE_COMMAND ""
  UPDATE_COMMAND ""
  PATCH_COMMAND ""
  INSTALL_COMMAND ""
  SOURCE_DIR "${USR_DIR_MINGW_LIBS}"
)
