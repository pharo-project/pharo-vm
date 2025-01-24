Name:           pharo-vm-@PharoVM_VERSION_MAJOR@.@PharoVM_VERSION_MINOR@
Version:        @PharoVM_VERSION_FULL@
Release:        0
License:        MIT
Summary:        Pharo is a pure object-oriented programming language and a powerful environment
Url:            https://github.com/pharo-project/pharo-vm
Group:          Development/Languages/Pharo
Source:         https://github.com/pharo-project/pharo-vm/release/%{name}-%{version}.tar.gz
BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  cmake wget
%if 0%{?suse_version} || 0%{?sle_version} >= 150100
BuildRequires:  clang 
BuildRequires:	libopenssl-1_0_0-devel libuuid-devel libffi7-devel
BuildRequires:	-post-build-checks
Requires:       glibc libopenssl1_0_0 libuuid1 libffi7
%endif
%if 0%{?fedora}
BuildRequires:  clang
%if 0%{?fedora} >= 36
BuildRequires:	openssl-devel libuuid-devel libffi-devel
Requires:       glibc openssl libuuid libffi
%else 
BuildRequires:	openssl-devel libuuid-devel libffi7-devel
Requires:       glibc openssl libuuid libffi7
%endif
%endif

BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%define destdir %{_libdir}/%{name}-%{version}

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
# Workaround for fedora >= 35
%if 0%{?fedora} >= 35
export QA_RPATHS=\$[0x0007]
%endif
mkdir -p %{buildroot}%{destdir}/bin
mkdir -p %{buildroot}%{destdir}/lib
install -Dm755 build/dist/pharo %{buildroot}%{destdir}
install -D build/dist/bin/* %{buildroot}%{destdir}/bin
install -D build/dist/lib/* %{buildroot}%{destdir}/lib
mkdir -p %{buildroot}/%{_bindir}
ln -s %{destdir}/pharo %{buildroot}/%{_bindir}/pharo
# Workaround to bypass test phase on OSL versions (rpath is no valid there, but 
# we do not care as it will be ignored)
#%if 0%{?suse_version} > 1500 || 0%{?sle_version} >= 150100
export NO_BRP_CHECK_RPATH=true
#%endif

%files
%defattr(-,root,root,-)
#%doc README.md
%{_bindir}/pharo
%{destdir}
%{destdir}/bin
%{destdir}/lib
%{destdir}/pharo
%{destdir}/bin/pharo
%{destdir}/lib/libB2DPlugin.so
%{destdir}/lib/libBitBltPlugin.so
%{destdir}/lib/libDSAPrims.so
%{destdir}/lib/libFileAttributesPlugin.so
%{destdir}/lib/libFilePlugin.so
#destdir/lib/libIA32ABI.so
%{destdir}/lib/libJPEGReadWriter2Plugin.so
%{destdir}/lib/libJPEGReaderPlugin.so
%{destdir}/lib/libLargeIntegers.so
%{destdir}/lib/libLocalePlugin.so
%{destdir}/lib/libMiscPrimitivePlugin.so
%{destdir}/lib/libPharoVMCore.so
#destdir/lib/libSecurityPlugin.so
%{destdir}/lib/libSocketPlugin.so
#destdir/lib/libSqueakFFIPrims.so
%{destdir}/lib/libSqueakSSL.so
%{destdir}/lib/libSurfacePlugin.so
%{destdir}/lib/libFloatArrayPlugin.so
%{destdir}/lib/libUUIDPlugin.so
%{destdir}/lib/libUnixOSProcessPlugin.so
%{destdir}/lib/pharo

%changelog

