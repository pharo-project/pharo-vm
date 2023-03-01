# Pharo VM

This is the main branch of the Pharo VM.

For more details about the whole Pharo VM project refer to our [wiki](../../wiki). 

This implementation started as a fork of [OpenSmalltalk-vm](https://github.com/OpenSmalltalk/opensmalltalk-vm).

The current project could not have been possible with all their previous work.

# Table of Contents

- Building the Virtual Machine
  - [Flavors](Flavors)
  - [Different VM Configurations](PharoVM-Versions)
  - [Build Options](CMake-Configuration-Options)
  - Building in Different Platforms
    - [General Build Information](General-Build-Information)
    - [Detailed Build Guide](Detailed-Build-Guide)
    - [Detailed Development Guide](Detailed-Development-Guide)
    - Windows Build Information
      - [Building on Windows](Building-on-Windows)
    - OSX Build Information
      - [Compiling OSX third party dependencies](Building-OSX-ARM64-Third-Party-Dependencies)
      - [Building in OSX](Building-in-OSX)
    - Linux Build Information
      - [Open Build Service](Pharo-on-Open-Build-Service)
      - [Installing Pharo into Linux Distributions](Installing-Pharo-into-Linux-distributions)
      - [Cross Compiling ARM64 in Ubuntu](Crosscompiling-ARMv8-in-Ubuntu)
      - [Cross Compiling ARM32 in Ubuntu](Crosscompiling-ARMv7-in-Ubuntu-for-Rasbian)
      - [Compiling in Manjaro ARM64](Compiling-in-Manjaro-ARM64)
      - [Compiling in Fedora](Compiling-in-Fedora)
      - [Compiling in Debian](Compiling-in-Debian)
      - [Compiling in Ubuntu/Mint](Compiling-in-Ubuntu)
      - [Compiling i686 third party dependencies](Building-Linux-i686-(32bits)-Third-Party-Dependencies)
      - [Compiling ARM64 third party dependencies](Building-Linux-ARM64-Third-Party-Dependencies)
      - [Compiling ARM32 third party dependencies](Building-Linux-ARM32-Third-Party-Dependencies)
  - [Troubleshooting](Troubleshooting)
- [Continuous Integration](Continuous-Integration)
- [Developer documentation](#developer-documentation)
  - [Source Directory Structure](Source-Directory-Structure)
  - [Simulation Environment](Simulation-Environment)
  - [Slang](Slang)
  - [JIT compiler](JIT-Compiler)
  - [Debugging - GDB](gdb)
  - [Debugging Windows ARM64 builds with Visual Studio](Debugging-ARM64-on-Windows-with-Visual-Studio)
- [How to contribute](How-to-contribute)
- [Glossary](Glossary)