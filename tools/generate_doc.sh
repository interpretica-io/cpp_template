#!/bin/bash
# Generate project documents
# Usage: generate_doc.sh
# Script is supposed to be run from main folder.

. $(cd "$(dirname "$(which "$0")")"/.. ; pwd -P)/tools/lib/core.sh

load_library docgen
load_library target
load_library site

# Local variables
build_folder=$(target_linux_def_build_folder)
include_doxyrest=y
include_html=y
include_pdf=y
site=public

while test -n "$1" ; do
    case $1 in
        --win32)
            build_folder=$(target_win32_def_build_folder)
            ;;
        --public)
            include_doxyrest=
            ;;
        --without-pdf)
            include_pdf=
            ;;
        --without-html)
            include_html=
            ;;
        --site)
            site="$2"
            shift 1
            ;;
    esac
    shift 1
done

lib_load_site "${site}"

build_folder="$(make_absolute "${TOP_DIR}" "${build_folder}")"
cleanup_docgen "${build_folder}"

pushd "${build_folder}" > /dev/null
    export DOXYREST_PATH=${build_folder}/doxyrest
    export REAL_THEME_PATH="${build_folder}/sphinx_theme"
    export THEME_PATH="${REAL_THEME_PATH}/themes"

    # Download Doxyrest
    doxyrest_download "${DOXYREST_PATH}" "${build_folder}"

    # Download theme
    theme_download "${REAL_THEME_PATH}"

    if [ -n "${include_doxyrest}" ] ; then
        # Build the documentation using Doxygen
        doxygen_build "${build_folder}"
    fi
popd > /dev/null

# Invoke Doxygen
if [ -n "${include_doxyrest}" ] ; then
    doxyrest_invoke "${DOXYREST_PATH}" "${TOP_DIR}/docs"
else
    mkdir -p "${build_folder}/rst"
fi

# Copy static materials
static_material_copy "${TOP_DIR}" "${build_folder}/rst"

# Build documentation using Sphinx
if [ -n "${include_html}" ] ; then
    sphinx_build "${build_folder}" html "${include_doxyrest:+dev}"
fi

if [ -n "${include_pdf}" ] ; then
    sphinx_build "${build_folder}" pdf "${include_doxyrest:+dev}"
fi

rm -rf "${build_folder}/html/.doctrees" \
       "${build_folder}/html/_sources" \
       "${build_folder}/html/.buildinfo"
