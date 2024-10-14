# Pharo VM

This repository holds the code of the Pharo Virtual Machine.
This implementation started as a fork of [OpenSmalltalk-vm](https://github.com/OpenSmalltalk/opensmalltalk-vm).
The current project could not have been possible with all their previous work.

The current implementation presents the following core features:
- an indirect threaded bytecode compiler using GNU extensions
- a generational scavenger garbage collector: semi-space + nursery for the young generation, a mark-compact collecting for the old generation
- a space for permanent objects that need not to be scanned by the GC
- a baseline JIT compiler that
  - translates primitive operations using IR templates
  - translates bytecode methods using a simple abstract interpretation approach to reduce memory pressure (less loads/stores)
- FFI through the well-known [libFFI](https://github.com/libffi/libffi), and support for non-blocking FFI using worker threads

For more details about the whole Pharo VM project refer to our [wiki](../../wiki). 

# Table of Contents

- Building the Virtual Machine
  - [Flavors](https://github.com/pharo-project/pharo-vm/wiki/Flavors)
  - [Different VM Configurations](https://github.com/pharo-project/pharo-vm/wiki/PharoVM-Versions)
  - [Build Options](https://github.com/pharo-project/pharo-vm/wiki/CMake-Configuration-Options)
  - Building in Different Platforms
    - [General Build Information](https://github.com/pharo-project/pharo-vm/wiki/General-Build-Information)
    - [Detailed Build Guide](https://github.com/pharo-project/pharo-vm/wiki/Detailed-Build-Guide)
    - [Detailed Development Guide](https://github.com/pharo-project/pharo-vm/wiki/Detailed-Development-Guide)
    - Windows Build Information
      - [Building on Windows](https://github.com/pharo-project/pharo-vm/wiki/Building-on-Windows)
    - OSX Build Information
      - [Compiling OSX third party dependencies](https://github.com/pharo-project/pharo-vm/wiki/Building-OSX-ARM64-Third-Party-Dependencies)
      - [Building in OSX](https://github.com/pharo-project/pharo-vm/wiki/Building-in-OSX)
    - Linux Build Information
      - [Open Build Service](https://github.com/pharo-project/pharo-vm/wiki/Pharo-on-Open-Build-Service)
      - [Installing Pharo into Linux Distributions](https://github.com/pharo-project/pharo-vm/wiki/Installing-Pharo-into-Linux-distributions)
      - [Cross Compiling ARM64 in Ubuntu](https://github.com/pharo-project/pharo-vm/wiki/Crosscompiling-ARMv8-in-Ubuntu)
      - [Cross Compiling ARM32 in Ubuntu](https://github.com/pharo-project/pharo-vm/wiki/Crosscompiling-ARMv7-in-Ubuntu-for-Rasbian)
      - [Compiling in Manjaro ARM64](https://github.com/pharo-project/pharo-vm/wiki/Compiling-in-Manjaro-ARM64)
      - [Compiling in Fedora](https://github.com/pharo-project/pharo-vm/wiki/Compiling-in-Fedora)
      - [Compiling in Debian](https://github.com/pharo-project/pharo-vm/wiki/Compiling-in-Debian)
      - [Compiling in Ubuntu/Mint](https://github.com/pharo-project/pharo-vm/wiki/Compiling-in-Ubuntu)
      - [Compiling i686 third party dependencies](https://github.com/pharo-project/pharo-vm/wiki/Building-Linux-i686-(32bits)-Third-Party-Dependencies)
      - [Compiling ARM64 third party dependencies](https://github.com/pharo-project/pharo-vm/wiki/Building-Linux-ARM64-Third-Party-Dependencies)
      - [Compiling ARM32 third party dependencies](https://github.com/pharo-project/pharo-vm/wiki/Building-Linux-ARM32-Third-Party-Dependencies)
  - [Troubleshooting](https://github.com/pharo-project/pharo-vm/wiki/Troubleshooting)
- [Continuous Integration](https://github.com/pharo-project/pharo-vm/wiki/Continuous-Integration)
- Developer documentation
  - [Source Directory Structure](https://github.com/pharo-project/pharo-vm/wiki/Source-Directory-Structure)
  - [Simulation Environment](https://github.com/pharo-project/pharo-vm/wiki/Simulation-Environment)
  - [Slang](https://github.com/pharo-project/pharo-vm/wiki/Slang)
  - [JIT compiler](https://github.com/pharo-project/pharo-vm/wiki/JIT-Compiler)
  - [Debugging - GDB](https://github.com/pharo-project/pharo-vm/wiki/gdb)
  - [Debugging Windows ARM64 builds with Visual Studio](https://github.com/pharo-project/pharo-vm/wiki/Debugging-ARM64-on-Windows-with-Visual-Studio)
- [How to contribute](https://github.com/pharo-project/pharo-vm/wiki/How-to-contribute)
- [Glossary](https://github.com/pharo-project/pharo-vm/wiki/Glossary)
