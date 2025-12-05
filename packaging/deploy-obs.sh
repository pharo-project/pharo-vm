#Deploy the build files in ${1} into the obs ocs repository found in ${2} using ${3} message

# Bash3 Boilerplate. Copyright (c) 2014, kvz.io
set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace

BUILD=${1}
TARGET=${2}

rm -rf ${TARGET}/*

SOURCESPATH=`find ${BUILD}/build/packages/ -name "PharoVM*-Darwin-arm64-c-src.tar.gz" | head -n 1`
SOURCESBASENAME=$(basename "$SOURCESPATH")
cp "${SOURCESPATH}" "${TARGET}/src.tar.gz"

OBS_PACKAGE=`find ${BUILD}/build/packages/ -name "PharoVM-v*-obs.zip" | head -n 1`
unzip ${OBS_PACKAGE} -d ${TARGET}/
mv ${TARGET}/obs/* ${TARGET}
rm -rf ${TARGET}/obs

cd ${TARGET}
osc add *
osc commit -m "${3}"