# Change log

I am a changelog... do not wait too much from me :D

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