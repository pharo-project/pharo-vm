# Pharo VM

This is main branch of the Pharo VM.

For more details about the whole Pharo VM project refer to our [wiki](../../wiki). 

This implementation started as a fork of [OpenSmalltalk-vm](https://github.com/OpenSmalltalk/opensmalltalk-vm).
The current project could not have been possible with all their previous work.

## CI

This project is continuously built and test in the CI infrastructure located at:

[https://ci.inria.fr/pharo-ci-jenkins2/job/pharo-vm/job/headless/](https://ci.inria.fr/pharo-ci-jenkins2/job/pharo-vm/job/headless/)


## Building

For building the VM it is required the following set of tools:

- A working Pharo
- CMake (at least version 3.7.2)
- CLang 
- Binutils (make and friends) 
- wget
- unzip
- automake
- libtool

In Linux Fedora, it is needed to install libcurl and to create a symbolic link to alias such library with the name used by libGit.
For doing so, it is required to do:

```
sudo ln -s /usr/lib64/libcurl.so.4 /usr/lib64/libcurl-gnutls.so.4
```

In Ubuntu 20.04 and in Mint 20, the VM is built with the following packages:

- build-essential
- gcc 
- g++
- binutils
- cmake
- git
- wget 
- unzip
- uuid-dev
- libssl-dev

### Building in OSX / Linux:

We recommend to use out-of-source building. So, we are building in a different directory than the one containing the sources.
To do so, we give both parameter for saying where the source is (-S) and where to build (-B).

```bash
$ git clone git@github.com:pharo-project/opensmalltalk-vm.git
$ cmake -S opensmalltalk-vm -B build
$ cd build
$ make install
```

### Building in Windows:

The build in Windows, uses Cygwin. This tool should be installed, and the following Cygwin packages are needed:

- cmake
- mingw64-x86_64-clang
- zip
- unzip
- wget
- curl 
- make
- git
- libtool

To automate the Cygwin installation process there is `scripts\installCygwin.ps1` which downloads and installs a chosen version of cygwin and mingw for a given architecture. For example the following installs the latest `Cygwin (64 bit)` and `mingw64-x86_64-clang` compiler:
```
.\scripts\installCygwin.ps1 setup-x86_64.exe x86_64
```
Do not forget to set the execution policy to `Unrestricted` (from the Admin PowerShell) in order to being able run the `ps1` script:
```
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
````

Bulding the VM:
```bash
$ cmake .
$ make install
```

The VM is built from generated code and code written by hand.
The generated code is the result of converting Smalltalk code into C.
This conversion is performed during the *cmake* process. 

This will generate the VM in *build/dist/*

###  VM flavours

By default the cmake build will build a CogVM, that is, a VM configuration with JIT compilation. Our cmake configuration accepts a `FLAVOUR` argument to specify different vm flavours to build, which you can use as follows:

$ cmake -DFLAVOUR=[your flavour] .

The accepted flavours for the moment are as follows:
- *CoInterpreterWithQueueFFI*: VM including JIT
- *StackVM*: VM with context to native stack mapping, without JI

### In case of Problems

In case of problems with the build, please tell us including the following things: 

- Command executed
- CMakeFiles/CMakeOutput.log
- CMakeFiles/CMakeError.log
- CMakeCache.txt
- If you are using windows, please include the output of ```cygcheck -s ```

## Source Directory Structure

The headless mode is developed on top of code of the Cog branch of Opensmalltalk-vm.
The code that is used without changes is stored in the *extracted* directory. 
This allows us to easy integrate changes from and to the Cog branch.

The code that has been specially created or modified for this branch is stored in *src* / *include* and *plugins*.


- smalltalksrc: includes the tonel repository with the code in Slang.
- generated: here VMMaker will generate the VM code.
- includes: All non generated includes required by headless mode
- src: All non generated code required by headless mode.
- extracted: This code is literally the same code base used in the normal OpenSmalltalk-VM build.
- plugins: The code of the different plugins developed for headless mode.

## Editing the VM code in your image

You can load the Pharo code of the VM using Pharo's git client Iceberg.
You can do so by cloning directly this repository from Iceberg, or by adding an already existing clone to it.

Alternatively, if you're building the VM using the instructions above, the build process does already generate a Pharo image with the VM code loaded. You'll find such Image in the `build/vmmaker` directory inside your build directory.
