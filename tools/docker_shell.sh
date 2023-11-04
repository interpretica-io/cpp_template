#!/bin/bash
export TOPDIR="$(cd "$(dirname "$(which "$0")")"/.. ; pwd -P)"

image="iio:ubuntu_2204"
pushd "${TOPDIR}" > /dev/null
pushd tools/build-env
docker build -t "${image}" -f Dockerfile_ubuntu_2204 .
if [ "$?" != "0" ] ; then
    echo "Failed to build Docker image"
    exit 1
fi
echo "ok"
popd > /dev/null
popd > /dev/null

docker run -v $(pwd):$(pwd) -w $(pwd) -it "${image}" ${1:+$@}
