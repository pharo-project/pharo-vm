# Change log

## v10.1.1
* Change custom command in ‘vmmaker.cmake’ to take into account that the ‘CMAKE_CURRENT_BINARY_DIR_TO_OUT’ can contain other characters besides spaces that require escaping by @Rinzwind in https://github.com/pharo-project/pharo-vm/pull/741
* Backporting PR for allocating in the old space by @jordanmontt in https://github.com/pharo-project/pharo-vm/pull/709
* Fixing memory map in OSX by @tesonep in https://github.com/pharo-project/pharo-vm/pull/751
* Adding generation of signature files by @tesonep in https://github.com/pharo-project/pharo-vm/pull/749

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.1.0...v10.1.1

## v10.1.0
* Fixing undefined behaviors that Clang 15 removes by @tesonep in https://github.com/pharo-project/pharo-vm/pull/731
* Fix ‘doReport’ to take into account that ‘fopen’ can return NULL by @Rinzwind in https://github.com/pharo-project/pharo-vm/pull/739
* Change custom command in ‘vmmaker.cmake’ to take into account that the ‘CMAKE_CURRENT_BINARY_DIR_TO_OUT’ can contain spaces by @Rinzwind in https://github.com/pharo-project/pharo-vm/pull/738
* Integrating new format by @tesonep in https://github.com/pharo-project/pharo-vm/pull/734

 New Contributors
* @Rinzwind made their first contribution in https://github.com/pharo-project/pharo-vm/pull/739

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.0.9...v10.1.0

## v10.0.9

* Improves in PermSpace by @tesonep in https://github.com/pharo-project/pharo-vm/pull/684

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.0.8...v10.0.9

## v10.0.8

* Fixes #14768: File class>>primFileAttributes😷 answers corrupted result by @akgrant43 in https://github.com/pharo-project/pharo-vm/pull/697
* Fix/speed regression by @tesonep in https://github.com/pharo-project/pharo-vm/pull/705

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.0.7...v10.0.8

## v10.0.7

* Update README.md by @guillep in https://github.com/pharo-project/pharo-vm/pull/688
* Fix ephemeron scanning perf by @guillep in https://github.com/pharo-project/pharo-vm/pull/691

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.0.6...v10.0.7

## v10.0.6

Improvements in build environment
* Update build environment for Pharo 10 vm branch by @guillep in https://github.com/pharo-project/pharo-vm/pull/594
* Make tests run in parallel by @guillep in https://github.com/pharo-project/pharo-vm/pull/596
* Update Jenkins to use Pharo 110 for building by @PalumboN in https://github.com/pharo-project/pharo-vm/pull/661

Cleanups
* Cleanups/externalize internalize by @guillep in https://github.com/pharo-project/pharo-vm/pull/583
* Fix/warnings by @guillep in https://github.com/pharo-project/pharo-vm/pull/584
* fixing-categorization in P10 by @tesonep in https://github.com/pharo-project/pharo-vm/pull/625

Fixes
* Fix mnuMethodOrNilFor: for method wrappers by @guillep in https://github.com/pharo-project/pharo-vm/pull/578
* fix function signatures by @pavel-krivanek in https://github.com/pharo-project/pharo-vm/pull/582

Debugging improvements
* Gdbinit file and helpers v2 by @guillep in https://github.com/pharo-project/pharo-vm/pull/486
* VM Debugger improvement with IR by @QDucasse in https://github.com/pharo-project/pharo-vm/pull/342

VM Improvements
* improving-permSpace by @tesonep in https://github.com/pharo-project/pharo-vm/pull/614
* Changing the order of command-line processing and PList in OSX by @tesonep in https://github.com/pharo-project/pharo-vm/pull/609
* Adding parsing of image parameters from PList by @tesonep in https://github.com/pharo-project/pharo-vm/pull/636
* Change terminate handler to exit with 128+signal by @jvalteren in https://github.com/pharo-project/pharo-vm/pull/644
* Improvements in parameters handling in OSX by @tesonep in https://github.com/pharo-project/pharo-vm/pull/639
* Adding check to fix when the image is open with an older VM by @tesonep in https://github.com/pharo-project/pharo-vm/pull/642
* Fix/ephemeron list by @guillep in https://github.com/pharo-project/pharo-vm/pull/668

New Contributors
* @jvalteren made their first contribution in https://github.com/pharo-project/pharo-vm/pull/644

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.0.5...v10.0.6

## v10.0.5

* Testing scavenger tenuring by @PalumboN in https://github.com/pharo-project/pharo-vm/pull/588
* Deleting Pharo image from the vm repo by @jordanmontt in https://github.com/pharo-project/pharo-vm/pull/591
* Cleaning Up Third Party Libraries by @tesonep in https://github.com/pharo-project/pharo-vm/pull/581

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.0.4...v10.0.5

## v10.0.4

- Composed image format by @PalumboN in https://github.com/pharo-project/pharo-vm/pull/377
- Composed image format: C translation by @PalumboN in https://github.com/pharo-project/pharo-vm/pull/388
- Perm space on image by @PalumboN in https://github.com/pharo-project/pharo-vm/pull/416
- New & old remembered sets by @PalumboN in https://github.com/pharo-project/pharo-vm/pull/418
- Reduce segment files size on move objects to PermSpace by @PalumboN in https://github.com/pharo-project/pharo-vm/pull/508
- Adding Support for PermSpace by @tesonep in https://github.com/pharo-project/pharo-vm/pull/488

- Adding option to not use contant block optimization for test by @StevenCostiou in https://github.com/pharo-project/pharo-vm/pull/573
- Do not use newer CMAKE features by @estebanlm in https://github.com/pharo-project/pharo-vm/pull/572
- Split a method in two to reuse part in espell by @jecisc in https://github.com/pharo-project/pharo-vm/pull/569


## New Contributors
* @StevenCostiou made their first contribution in https://github.com/pharo-project/pharo-vm/pull/573
* @estebanlm made their first contribution in https://github.com/pharo-project/pharo-vm/pull/572
* @jecisc made their first contribution in https://github.com/pharo-project/pharo-vm/pull/569

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.0.3...v10.0.4

## v10.0.3

 - Fix ARM32 by @tesonep in #562
 - Verify ephemeron key is not immediate when marking by @guillep in #565

## v10.0.2

- Generate Pharo VM dependency graph by @hernanmd in #554
- Link against a shared SDL2 if already installed in target by @hernanmd in #555
- Slang: Integer>>#bitOr: and Integer>>#| are translated to C code differently by @hernanmd in #523
- Fix ephemeron compaction by @guillep in #561

## v10.0.1

- Adding image version field to the image header
- Fixes in String comparison primitive when JIT
- Improvements in dependency of the VMMaker code.

## v10.0.0

- Slang (Smalltalk to C Translator)
	- Introducing a C AST to ease the generation of C Code
	- Having a Pretty Printer for C AST
	- Translation Tests
	- Fixing Translation Issues
	- Clear separation between Slang and VM code
	- Improving Cast generation

- Clean Up:	
	- Remove Old Bytecode Set
	- Remove Old Block Implementation
	- Simplification of the Primitives
	- Removing Unused / Old Code / Dead Code
	- Cleanup / Removal of Old Unused primitives
	- Removing Old FFI Implementation
	- Removing MT Experiment from the code base (Kept in own branch)
	- Fixing Compilation Warnings
	- Improving Type annotations to fix bugs in the translation / compilation
	- Removing Conditional Code on Old Configurations / Features
	- Renaming Concepts to be inline with Common terminology
	- Remove Newspeak, Multiple Bytecode and Old Memory Managers
	- Removing Unused Plugins

- Tests
	- GNUification Tests
	- Tests for Math primitives including overflow and conversion testing.
	- Tests for comparison primitives (Equals / Not Equals / Less than / Less or Equals / Greater Than / Greater or Equals)
	- Testing Primitives for objects Pinned in Memory
	- Testing Math Primitives for Immediate Classes (SmallFloats / SmallIntegers)	
	- Improving Simulation Infrastructure
	- Using Sista Bytecode in all Tests
	- Updating Unicorn version
	- Improving Machine Code emulation
	- Testing Image Read / Image Write
	- Using the same memory map in Tests and Execution
	- Testing Ephemerons
	- Become Primitives

- Ephemeron
	- Fix for large ammounts
	- Make it available
	- Testing Signal Finalizations
	
- Fixing Become Errors.

- Fixing XRay Primitive

- Single-Instruction Multiple-Data (SIMD) initial Support:
	- Initialization of new objects using SIMD (ARM64)
	- Adding Bytecode Extensions to support SIMD instructions
	- Adding Vector Registers
	- Vector Register bytecodes

- Auto Localization of Interpreter loop variables and edge detection simplifying development and minimizing code

- ImageReader / ImageWriter reification needed for Permanent Space.

- Improving Memory Map of the VM (Using constant positions)

- Dependencies Improvements

## v9.0.21

- Implementing High resolution clock for ARM64 (Used during profiling)
- Updating third party libraries for all the graphic layer

## v9.0.20
- Fixing a performance regression on the allocation of opcodes and fix-ups. 
	Cleaning only the ones that are going to be used.
	Like this, this version has the same speed than before when allocating in the stack.

## v9.0.19
- Correctly handling the encoding of the command line arguments of the VM (Windows)
- Allocating the opcodes and fixup structs only once and reusing them (Reducing risk of C Stack Overflow)

## v9.0.18
- Update library downloads in Windows to
	- libgit2 => 1.4.4

## v9.0.17
- Supporting old images in OSX ARM64 with Libgit older than v1.4.4

## v9.0.16
- Fixes in users of declarationAt:
- Updating Readme
- Improving the generation of plugins
- Upgrade library dependencies
- Update library downloads to
	- libgit2 => 1.4.4
	- libssh2 => 1.9.0
	- openssl => 1.1.1k
- Update build instructions to build libgit v1.4.4

## v9.0.15

- Fixing FFI Variadic functions in OSX ARM64
- Fixing store of Int64 in FFI OSX ARM64 when using LongLong
- Fixing Error code in Primitive when more than one temporary is used.

## v9.0.14

- Adding support to read command line parameters from the PList (In OSX)

## v9.0.13

- Correct handling OOB (Out of Band Data) in Window
- Blocking signals while signaling semaphores to avoid deadlocks caused by signal handlers

## v9.0.12
- Make MAXHOSTNAMELEN at least 256: improving resolution of names in linux
- Improving VM Simulator Machine debugger
- Integrating Processor Simulator for RISCV
- Using a new SDL2 version built for OSX Mojave compatibility 

## v9.0.11

- Include FloatArrayPlugin in the build
- Updating SDL2 to 2.0.18 for OSX X86_64
- Using Pharo 10 image as VMMaker image
- Fixing issue in message counting on non JIT VM

## v9.0.10

- Improving error messages when looking for a symbol in Windows, and exporting symbol used when using worker thread.
- Adding message counting primitives in the interpreter
- Adding a compile time option to generate or not the counting of messages
- Adding generation of StackVM
- Fixing memory issue with spawned threads in AIO.

## v9.0.9
- Fixing dependencies of functions with Variadic Arguments
- Debug window and menu for Windows.
- Fixing Version Numbers when is not a Release in the Resources File (Windows).

## v9.0.8
- Improving AIO Support in windows to handle the maximum quantity of waiting on objects 
- SIGEMT is not defined in all Linux as it depends on the architecture
- Improving reporting of exception and version number

## v9.0.7

- Ignore SIGPIPE and let send fail with an error instead of killing the process
- Exposing the ABI selection to the image

## v9.0.6

- Fixing the marshalling of LargeIntegers in 32bits platforms

## v9.0.5

- Updating Linux ARM64/32 SDL versions

## v9.0.4

- Improving the logging when there is a signal to terminate the VM

## v9.0.3

- Logging the snapshot and quit primitives
- Adding testing function to see if we are in debug
- Improving the logging of unimplemented primitive to log it only once
- Fixing the hint handling when allocating memory in MINGW
- Fixing Upload of artifacts

## v9.0.2

- Releasing on Tag
- Fixing sqSetupSSL when not using LibGit
- Introduce SlangMemoryManager and MachineMemoryManager
- Builds for ARM using Docker
- Extracting the read of Image Header
- Refactoring of readImage to use the same implementation in the Simulator and real.
- Improving VMDebugger
- Fixes in Slang
- Fixing RumpCStack in simulation
- Building ARM32
- Fixing ARM32 issue when using mcprimHashMultiply

## v9.0.1

- Correct handling of Out-of-band data
- Improve error handling of network events in OSX

## v9.0.0

- Build for ARM32 Linux
- Fixing ARM64 in Windows
- Fixing asFloat primitives
- Fixing Platform name
- Fixing ARM32 to use Sista Bytecode and Full blocks
- Testing globalSession ID
- Support for OpenBSD
- Tests for the JIT, Memory management and Intrepreter
- Apple M1 Support
- Improve Allocation of JIT memory
- Improving FFI calls and Marshalling primitives
- Improving SurfacePlugin
- Fix Directed super sends for SISTA in ARMv5 
- Change register mapping in ARMv5
- Added accessors in Cogit for testing purposes
- Extracted directed super send trampoline creation
- Fixed disassembler 
- Enhance simulator and tests with calling convention accessors
- Fix fopen issue in Windows with encoding
- Configurations for desired eden size, old space size, new space size
- Adding configurable Features to the build from CMake
- Dead code removal and storage in specific branches for history
- Improving Stack report on errors
- Correct handling of time queries in Windows
- ARM64 JIT implementation
- Tons and Tons of tests
