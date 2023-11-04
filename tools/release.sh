#!/bin/bash
# Release generation script
# Usage: ./tools/release.sh
# Script is supposed to be run from main folder, e.g. ./tools/release.sh
postfix="linux-x86_64"
build_folder="build"
build_folder_gen="build"
toolchain=""
is_linux=1
is_win32=
is_mac=
tar_flags="-cJvf"
tar_ext="xz"
exclude_files="--exclude=bin/cpp_template_test.exe --exclude=bin/cpp_template_test"

. $(cd "$(dirname "$(which "$0")")"/.. ; pwd -P)/tools/lib/core.sh

fail()
{
    echo $@
    exit 1
}

normalize_bool()
{
    if [ "$1" == "1" ] ; then
        echo "yes"
    else
        echo "no"
    fi
}

normalize_filepath()
{
    dir="$(dirname $1)"
    if [ -z "${dir}" ] ; then
        dir=$(pwd)
    else
        cd "$(dirname $1)"
        dir=$(pwd)
    fi
    echo "${dir}/$(basename $1)"
}

while test -n "$1" ; do
    case $1 in
        --win32)
            build_folder="build-win32"
            postfix="win32-x86_64"
            is_win32=1
            is_linux=
            is_mac=
            ;;
        --linux)
            build_folder="build-linux"
            postfix="linux-x86_64"
            is_mac=
            is_win32=
            is_linux=1
            ;;
        --mac|--mac-x86_64)
            build_folder="build-mac-x86_64"
            postfix="macos-x86_64"
            is_mac=1
            is_win32=
            is_linux=
            ;;
        --mac-arm64)
            build_folder="build-mac-arm64"
            postfix="macos-arm64"
            is_mac=1
            is_win32=
            is_linux=
            ;;
        --out)
            output="$2"
            ;;
        --doc)
            output_doc="$2"
            ;;
        --fast-packaging)
            tar_flags="-czvf"
            tar_ext="gz"
            ;;
    esac
    shift 1
done

function get_hash()
{
    pushd ${TOP_DIR} > /dev/null
    git rev-parse --short HEAD
    popd > /dev/null
}

build_folder="$(cd ${build_folder} && pwd)"
build_folder_gen="$(cd ${build_folder_gen} && pwd)"
test -z "${output}" && output="${build_folder}/cpp_template-${postfix}.${tar_ext}"
output="$(normalize_filepath ${output})"
if [ -n "${output_doc}" ] ; then
    output_doc="$(normalize_filepath ${output_doc})"
    test -f "${build_folder}/build.ninja" || fail "Release is not built"
    test -d "${build_folder_gen}/html" || fail "Documentation is not built"
    find "${build_folder_gen}/html" -type f -exec chmod 664 {} \;
    find "${build_folder_gen}/html" -type d -exec chmod 775 {} \;
    find "${build_folder_gen}/html" -type d -exec chmod +s {} \;
    find "${build_folder_gen}/latex" -type f -exec chmod 664 {} \;
    find "${build_folder_gen}/latex" -type d -exec chmod 775 {} \;
    find "${build_folder_gen}/latex" -type d -exec chmod +s {} \;
    tar ${tar_flags} "${output_doc}" -C "${build_folder_gen}" html -C latex/latex documentation.pdf
fi
echo $(get_hash) > "${build_folder}/fs/hash"
tar ${exclude_files} ${tar_flags} "${output}" -C "${build_folder}/fs" hash bin
