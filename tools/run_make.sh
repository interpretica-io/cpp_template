#!/bin/bash
# Build script
# Usage: ./tools/run_make.sh
# Script is supposed to be run from the main folder, e.g. ./tools/run_make.sh
is_partial=
plat=
arch=
build_folder="build"
toolchain=""
asan=

. $(cd "$(dirname "$(which "$0")")"/.. ; pwd -P)/tools/lib/core.sh


load_library toolchain

while test -n "$1" ; do
    case $1 in
        --win32)
            plat="win32"
            build_folder="build-win32"
            ;;
        --linux)
            plat="linux"
            build_folder="build-linux"
            ;;
        --mac|--mac-x86_64)
            plat="macos"
            arch="x86_64"
            build_folder="build-mac-x86_64"
            ;;
        --mac-arm64)
            plat="macos"
            arch="arm64"
            build_folder="build-mac-arm64"
            ;;
        --partial)
            is_partial=1
            ;;
        --asan)
            asan="-DENABLE_SANITIZER=ON"
            ;;
    esac
    shift 1
done

mkdir -p "${build_folder}"

# Sort the problem of toolchain
tc="$(get_toolchain $plat $arch)"
echo "Toolchain: ${tc}"

tc_url="$(get_toolchain_url $tc)"
if [ "$?" != "0" ] ; then
    exit 1
fi

tc_extract_path=""
if [ "$tc_url" != "" ] ; then
    pushd "${build_folder}" > /dev/null
    if [ ! -d "toolchain" ] ; then
        mkdir toolchain
    fi
    pushd toolchain
    if [ ! -f "toolchain.tar.xz" ] ; then
        wget --show-progress "${tc_url}" -O "toolchain.tar.xz"
    fi
    if [ ! -d "bin" ] ; then
        tar mxvf toolchain.tar.xz --strip-components 1
    fi
    popd
    tc_extract_path="$(pwd)/toolchain"
    echo "Toolchain is taken from ${tc_extract_path}"
    popd > /dev/null
fi

tc_def="$(get_toolchain_def $tc)"
tc_def_complete=""
tc_path=""
if [ "$tc_def" != "" ] ; then
    export PATH=$(pwd)/${build_folder}/toolchain/bin:${PATH}
    tc_def_complete="-DCMAKE_TOOLCHAIN_FILE=$(pwd)/toolchain/${tc_def}"
fi
tc_osx_archs="$(get_toolchain_osx_archs $tc)"

# Run cmake / make
test -f "${build_folder}/build.ninja" && partial_allowed=1

echo "Build folder: ${build_folder}"
echo "Toolchain: ${toolchain:-default} (Windows: $(lib_core_normalize_bool ${is_win32}))"
echo "Partial build: $(lib_core_normalize_bool ${is_partial})"


cd "${build_folder}"
if [ "$is_partial" == "0" ] || [ "${partial_allowed}" = "" ]; then
    cmake -DBUILD_DEMO=ON \
          -DBUILD_UNITTEST=ON \
          -GNinja \
          $tc_def_complete \
          ${tc_osx_archs:+-DCMAKE_OSX_ARCHITECTURES="$tc_osx_archs"} \
          -DCMAKE_INSTALL_PREFIX:PATH=$(pwd)/fs \
          -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
          -DCMAKE_MACOSX_RPATH=1 \
          $asan \
          ../
fi

time ninja && (ninja install > install.log || cat install.log)
