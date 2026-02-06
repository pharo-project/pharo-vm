Format: 1.0
Source: @OBS_PACKAGE_NAME@
Version: @PharoVM_VERSION_FULL@
Binary: @OBS_PACKAGE_NAME@
Maintainer: Esteban Lorenzano <estebanlm@netc.eu>, Pablo Tesone <tesonep@gmail.com>
Architecture: amd64 aarch64 armv7l
Homepage: https://github.com/pharo-project/pharo-vm
Standards-Version: 3.9.4
Build-Depends: debhelper (>= 11.0.0), cmake, clang, libssl-dev, uuid-dev, libffi7-dev (==3.3-4) | libffi-dev
Depends: libuuid1, libssl, libffi7 (==3.3-4) | libffi8
