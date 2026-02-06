#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

__TARGET="${1:-}"
__VERSION="${2:-}"

echo ${__VERSION}

mkdir -p ${__TARGET}
cp ${__root}/CHANGELOG.md ${__TARGET}/debian.changelog
for f in ${__root}/obs/*
do
    __file="${__TARGET}/$(basename "${f}")"
	cat ${f} | VERSION=${__VERSION} envsubst > ${__file}
done