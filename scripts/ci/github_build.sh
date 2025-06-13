#!/bin/bash

set -xe

SRC_DIR=$(realpath "$(dirname ${BASH_SOURCE[0]})/../..")

function build_linux_amd64() {
	sudo apt-get -y install \
  		gcc-9 \
  		curl \
  		libssl-dev \
  		libx11-dev \
  		libsdl2-dev

	pushd "$SRC_DIR/build.linux64x64/pharo.cog.spur/build"
		../../../scripts/updateSCCSVersions || true
		yes | ./mvm
	popd

 	pushd "$SRC_DIR/products/release/phcogspur64linuxht"
 		echo "==========="
 		./pharo --version
		echo "==========="
    	zip -r "../pharo64-linux-stable.zip" bin lib pharo
  	popd
}

case "$(uname)-$(uname -m)" in
	Linux-x86_64 )
		build_linux_amd64
		;;
	*)
		echo "ERROR: Unsupported platform [$(uname)-$(uname -m)]"
		echo "NOTE: $(uname -a)"
		exit 1
		;;
esac
