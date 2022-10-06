# Pharo VM

This is the main branch of the Pharo VM.

For more details about the whole Pharo VM project refer to our [wiki](../../wiki). 

This implementation started as a fork of [OpenSmalltalk-vm](https://github.com/OpenSmalltalk/opensmalltalk-vm).
The current project could not have been possible with all their previous work.

## CI

This project is continuously built and test in the CI infrastructure located at:

<https://ci.inria.fr/pharo-ci-jenkins2/job/pharo-vm/job/pharoX/>

## Branches

* `pharoX` the current PharoVM development
* `pharo9` the stable branch (see releases)
* `feat/` specific features branches
* `cog/` legacy things

## Building

### Building dependencies

For building the VM it is required the following set of tools:

- CMake (at least version 3.7.2)
- A C compiler (clang or gcc)
- Binutils (make and friends)
- wget
- unzip
- libtool

Additional libraries are required in the default build but are downloaded and compiled when not found. 


FIXME: which version of Fedora? Is this still true?
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


FIXME: I needed only the following on Debian 11:
```
$ apt install build-essential cmake git python3-minimal pkg-config
  libgit2-dev libssh-dev libsdl2-dev libfreetype-dev libffi-dev
```


### Building in OSX / Linux:

We recommend to use out-of-source building. So, we are building in a different directory than the one containing the sources.
To do so, we give both parameter for saying where the source is (-S) and where to build (-B).

```bash
$ git clone git@github.com:pharo-project/pharo-vm.git
$ cmake -S pharo-vm -B build
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

### Building Internal

Here a bird view of the building process for the development branch PharoX when you run `make install`.
File paths are relative to the building directory of cmake (called `build` above).
Note: this building directory also contains a directory named `build` (they should not be confused).

1. Download a stable Pharo VM to `./build/vmmaker/vm/pharo`
2. Download a recent Pharo image to `./build/vmmaker/image/Pharo*.image`
   Note: this is a development image since new features might be required by PharoX.
3. Import the PharoVM source code (the `.st` files) from the git repository into the downloaded Pharo image and save it as `./build/vmmaker/image/VMMaker.image`.
   Note: this step also downloads the required Pharo dependencies needed by the new image.
4. Generate the C code of the VM in the `./generated/` directory.
5. Compile and link the C code from `./generated/` and produce binaries in `./build/vm/`. This is the step that takes most of the time.
   Note: PharoVM is not a single binary but is made of multiple dynamic libraries.
6. Move files to the `./build/dist/` directory.
   The produced VM is executable with `./build/dist/pharo`.

### In case of Problems

In case of problems with the build, please tell us including the following things: 

- Command executed
- CMakeFiles/CMakeOutput.log
- CMakeFiles/CMakeError.log
- CMakeCache.txt
- If you are using windows, please include the output of ```cygcheck -s ```


## Basic Usage

Once compiled, the VM entry point is at `./build/dist/pharo`.
Since PharoVM is only a VM, an image is required to do useful things.

The image used for the build process is available at `./build/vmmaker/image/Pharo*.image` (glob here because the name is variable since it contains version number and hash).

```bash
$ ./build/dist/pharo ./build/vmmaker/image/Pharo*.image eval '3+4'
7
```

Or run the graphical environment with.

```bash
$ ./build/dist/pharo ./build/vmmaker/image/Pharo*.image --interactive
```

Note: since this image is used by the build process, it is not advised to alter it, but you can still save it as a copy.

## Development -- Quick Guide

### Editing the VM code in your image

You can load the Pharo code of the VM using Pharo's git client Iceberg.
You can do so by cloning directly this repository from Iceberg, or by adding an already existing clone to it.

Alternatively, if you're building the VM using the instructions above, the build process does already generate a Pharo image with the VM code loaded. You'll find such image at `./build/vmmaker/image/VMMaker.image` inside your build directory.

### Compiling a new VM

The build process is described above, so in order to generate a new PharoVM with your changes, there is different approaches.

* Commit your changes (with Iceberg) into the local git repository you cloned then run `make install` from the building directory.
  This will rebuild a new VMMaker image by loading your new code into the basic Pharo image.
  Note: this rebuild starts at the step 3.

* Save your image as XXX (or overwrite the `VMMaker.image` file), then run:

  `cmake ????` TODO

  Note: this rebuild starts at the step 4.

* Generate the C files yourself somewhere (in a Pharo playground for instance):

  `PharoVMMaker generate: #CoInterpreter outputDirectory: '/a/path/'`

  then run the following shell command in the `outputDirectory` given above:

  `cmake -S "$PHAROVM" -B "$PWD" -DGENERATE_SOURCES=OFF -DGENERATED_SOURCE_DIR="$PWD" && make install`

  where `$PHAROVM` is the root of the pharo-vm project (your local git repository for instance).

  Note: this rebuild starts at the step 5.

### Source Directory Structure

TODO: review this. Especially the relevance of headless stuff.

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

### Glossary used by PharoVM

- CoInterpreter: a subclass of the interpreter that knows how to use (and communicate with) Cogit for the JIT service.
- Cog: codename of the Opensmalltalk-vm developed originally by [Eliot Miranda](http://www.mirandabanda.org/cogblog/) and described in [two decades of smalltalk vm development](https://dl.acm.org/doi/10.1145/3281287.3281295).
- Cogit: the just in time compiler used by PharoVM. See `Cogit` in the `VMMaker` package.
- FFI (foreign function interface) allow PharoVM to call dynamically loaded C libraries.
- headless: codename of a previous version of PharoVM where the graphical components where removed from the VM and moved as a image responsibility (with the help of FFI).
- Melchor: part of Slang (or the other way around). See Slang.
- PharoVM: efficient virtual machine for Pharo systems (and the name of the related the project). Is based on Opensmalltalk-vm.
- Slang: transpiler to convert a small subset of Pharo to C (this language is also called slang). Is used to convert the code of the virtual machine in C. See the `Slang` and `Melchor` packages.
- Spur: current memory model (and garbage collectors) implemented as a part of PharoVM.
- VMMaker: main Pharo package of the PharoVM. Is mostly written in a C-compatible subset of Pharo.
