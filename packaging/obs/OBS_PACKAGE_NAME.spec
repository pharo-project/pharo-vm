Name:           @OBS_PACKAGE_NAME@
Version:        @PharoVM_VERSION_FULL@
Release:        0
License:        MIT
Summary:        Pharo is a pure object-oriented programming language and a powerful environment
Url:            https://github.com/pharo-project/pharo-vm
Group:          Development/Languages/Pharo

# Source tarball URL
Source:         https://github.com/pharo-project/pharo-vm/release/src.tar.gz

# Common build dependencies
BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  cmake
BuildRequires:  clang

# Fedora 43 has conflicting wget packages
%if 0%{?fedora} == 43
BuildRequires: wget1-wget
%else
BuildRequires: wget
%endif

# OpenSUSE / SLE dependencies
%if 0%{?suse_version} || 0%{?sle_version} >= 150100
BuildRequires: libopenssl-devel libuuid-devel libffi-devel
Requires:       glibc libopenssl1_1 libuuid1 libffi
%endif

# Fedora / RHEL dependencies
%if 0%{?fedora}
BuildRequires: openssl-devel libuuid-devel libffi-devel
Requires:       glibc openssl libuuid libffi
%endif

BuildRoot:      %{_tmppath}/%{name}-build

%define destdir %{_libdir}/%{name}

%description
Pharo is a pure object-oriented programming language and a powerful environment,
focused on simplicity and immediate feedback (think IDE and OS rolled into one).

%prep
%setup -q -n pharo-vm

%build
cmake . \
    -DGENERATE_SOURCES=FALSE \
    -DPHARO_DEPENDENCIES_PREFER_DOWNLOAD_BINARIES=FALSE \
    -DPHARO_LIBRARY_PATH=%{destdir}/lib \
    -DPHARO_BIN_LOCATION=%{destdir}/lib \
    -DBUILD_BUNDLE=FALSE
make install

%install
# Fedora >= 35 workaround for rpaths
%if 0%{?fedora} >= 35
export QA_RPATHS=\$[0x0007]
%endif

mkdir -p %{buildroot}%{destdir}/bin
mkdir -p %{buildroot}%{destdir}/lib
mkdir -p %{buildroot}%{_bindir}

install -Dm755 build/dist/pharo %{buildroot}%{destdir}/pharo
install -D build/dist/bin/* %{buildroot}%{destdir}/bin
install -D build/dist/lib/* %{buildroot}%{destdir}/lib

# Symlink in buildroot so RPM tracks /usr/bin/pharo
ln -s %{destdir}/pharo %{buildroot}%{_bindir}/pharo

%post
# Register Pharo VM in update-alternatives
/usr/sbin/update-alternatives --install /usr/bin pharo %{destdir}/pharo 1

%preun
# Remove the alternative when uninstalling
if [ $1 -eq 0 ]; then
    /usr/sbin/update-alternatives --remove pharo %{destdir}/pharo
fi
# Disable RPATH checks for SLE / OpenSUSE
export NO_BRP_CHECK_RPATH=true

%files
%defattr(-,root,root,-)
%{_bindir}/pharo
%{destdir}
%{destdir}/bin
%{destdir}/lib
%{destdir}/lib/libB2DPlugin.so
%{destdir}/lib/libBitBltPlugin.so
%{destdir}/lib/libDSAPrims.so
%{destdir}/lib/libFileAttributesPlugin.so
%{destdir}/lib/libFilePlugin.so
%{destdir}/lib/libJPEGReadWriter2Plugin.so
%{destdir}/lib/libJPEGReaderPlugin.so
%{destdir}/lib/libLargeIntegers.so
%{destdir}/lib/libLocalePlugin.so
%{destdir}/lib/libMiscPrimitivePlugin.so
%{destdir}/lib/libPharoVMCore.so
%{destdir}/lib/libSocketPlugin.so
%{destdir}/lib/libSqueakSSL.so
%{destdir}/lib/libSurfacePlugin.so
%{destdir}/lib/libFloatArrayPlugin.so
%{destdir}/lib/libUUIDPlugin.so
%{destdir}/lib/libUnixOSProcessPlugin.so
%{destdir}/lib/pharo

%changelog