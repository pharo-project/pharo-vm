# Change log

## v12.0.4-beta

* just add third party dependences if BUILD_BUNDLE is enabled by @estebanlm in https://github.com/pharo-project/pharo-vm/pull/1081
* Closed pics to pics by @Ducasse in https://github.com/pharo-project/pharo-vm/pull/1068
* Updating thirdparty libraries for OSX and Windows x86 by @tesonep in https://github.com/pharo-project/pharo-vm/pull/1086
* Build on top of Pharo 13 by @guillep in https://github.com/pharo-project/pharo-vm/pull/1077
* Skip adding handles with empty mask to epoll (fixes #1018) by @daniels220 in https://github.com/pharo-project/pharo-vm/pull/1092
* Minimal changes to type annotations by @takano32 in https://github.com/pharo-project/pharo-vm/pull/1083
* Build hygiene and small portability fixes by @takano32 in https://github.com/pharo-project/pharo-vm/pull/1084
* Minimal Windows x86_64 and aarch64 cross-build support by @takano32 in https://github.com/pharo-project/pharo-vm/pull/1082
* Minimal FreeBSD x86_64 and aarch64 cross-build support by @takano32 in https://github.com/pharo-project/pharo-vm/pull/1080
* Fix issue 1095 by @tesonep in https://github.com/pharo-project/pharo-vm/pull/1097

### New Contributors
* @daniels220 made their first contribution in https://github.com/pharo-project/pharo-vm/pull/1092

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v12.0.3-beta...v12.0.4-beta

## v12.0.3-beta

Fix issue with ssl on linuxes https://github.com/pharo-project/pharo-vm/pull/1073

## v12.0.2-beta

This is a major release featuring:

* Frame unification and stack management improvements, delivering substantial interpreter and execution engine cleanups.
* RISC-V JIT support, expanding platform coverage and future-proofing VM development.
* New memory management capabilities, including direct old-space allocation and numerous GC and allocation improvements.
* Extensive compiler and Slang/C translation work, with many correctness fixes, new tests, and improved inspection tools.
* Platform and build modernization, including SDL updates, improved CI, cross-build support, and updated third-party dependencies.
* Large-scale cleanup and refactoring efforts across the VM, interpreter, Cogit, PICs, and infrastructure.

### VM Runtime, Interpreter & JIT

* Frame unification (#602)
* Improvements in stack management (#710)
* Initialize stack pages during simulation (#853)
* Robust `cannotInterpret:` in the interpreter (#641)
* Simplify stack-to-register mapping API (#627)
* Improve and use unreachable (#630)
* Clean up Interpreter State (#658)
* Void the instructionPointer systematically when creating a base frame (#914)
* Cleanup make base frame when compacting code (#943)
* Fix meta try primitive (#968)
* Feature: `thisProcess` JIT (#1037)
* OpenPIC / Megamorphic IC work (#1067)
* PIC Cleanup (#889)
* Cleanup PIC (#1021)
* Allow `Cogit>>#mnuMethodOrNilFor:` to return non-`CompiledMethod` oops (#936)
* Remove entry alignment (#934)
* Mark debugging overrides in Cogit as `#debuggerCompleteToSender` (#1035)

### Memory Management & Garbage Collection

* Do not unlink all sends on GC (#503)
* Improving perm space P12 (#621)
* Added new primitive for allocating directly in the old space (#701)
* Adding test to test Ephemerons in the Old Space (#702)
* Clean special object array a little (#640)
* Collapse allocation logs (#913)
* Only scan the class table if `become:` was performed to an active class object (#1023)
* Set the size of larger indexable objects allocated in young space (#976)
* Fix LargeIntegers segfault on allocation failure (#1040)

### Compiler, Slang & Code Generation

* Reject reserved words (#613)
* Rename reserved words: selectors, locals and instance variables (#624)
* Rename conflicting identifiers (#646)
* Validate if locals/args exist when adding a type declaration (#603)
* Check structs' instance variable type declarations (#607)
* Redundant type declaration linter rule (#662)
* Fix cast tests (#660)
* Fix and test inlinings with `if`s and right shifts not translated (#667)
* Add tests and fix incorrectly generated inlined C code from CCodeGenerator (#666)
* C AST translation right-side parenthesis in expression (#685)
* Add a palette with the C translation of any inspected C node (#686)
* Add C source code inspection tab for TParseNode (#687)
* Created new package CAST-Tests (#679)
* Better dead code elimination (#915)
* Fix issue #822: remove unused argument for `functionPointerFor:inClass:` (#956)
* Fix CASTParserTests>>#testParseSizeofTypeInt (#965)
* Refactor inlining code and add tests for it (#987)
* Suppress the old inlining implementation (#1000)
* Fix small bug related to method inlining and comments (#957)
* Remove the idea that we might have a different bytecode set (#927)
* Add a dumb `isNotNil` implementation (same as `notNil`) (#890)

### Platform Support & Portability

* RISC-V JIT Support (#932)
* Initial work on W^X for Linux systems (#905)
* Add Windows support for non-ASCII filenames in `basicImageFileExists` (#922)
* Fix the Windows build (#938)
* Windows improvements (#1062)
* Make `next` non-blocking on Linux (#1065)
* Support x86_64 musl cross-build smoke testing with QEMU (#1069)
* Updating versions for OSX (ARM / Intel) (#937)

### Build System, CI & Dependencies

* Update SDL (#615)
* Remove strange SDL2_copy CMake target (#620)
* Forward VM build parameters from CMake (#654)
* Use Pharo 11 on CI (#669)
* Use Pharo file server @ Inria (#868)
* Extract full semantic version from git (#870)
* Remove old versions of libgit in new builds (#902)
* Update CMake minimal version for recent CMake compatibility (#945)
* Updating LibGit2 build to use new OpenSSL and libssh2 (#1033)
* SDL2 2.32.6 update for Windows and macOS (#978)
* Fix OBS build (#981)
* Add FEATURE_JIT_SIMD option (#966)
* Fix Linux compilation error (#1053)

### Plugins, I/O & Networking

* New file plugin (#1024)
* Fix missing socket `accept` on Pharo 12 (#1005)
* Move warnings to debug when loading plugins (#675)

### Testing & Simulation

* Small stack interpreter tests (#690)
* Simulator fixes (#1025)
* Fix VM tests: `specialObjectsArrayAddress` (#1056)
* Fix broken GC tests (#917)
* Fix some Slang tests (#891)
* Redo ML localization test fixes (#1064)

### Bug Fixes

* Resolved UUID primitive bug (#610)
* Make `instantiateClass` more robust when format is missing (#629)
* Revert #629 (#631)
* Revert the revert and restore primitive failure handling (#634)
* Add `getClass` for Pharo 12 compatibility (#651)
* Fix warning absolute value (#782)
* Fix load 32 bits (#920)
* Fix headerAt:put: (#919)
* Fix sign coercion warnings (#950)
* Fix int boxing/loading (#1066)
* VM version primitive (#1050)
* Profile data extraction from PIC cache tags (#969)

### Refactoring, Cleanup & Maintenance

* Added comments and renamed methods during dojo (#623)
* Fixing categorization P12 (#626)
* Updating P12 with changes from P10 branch (#733)
* Forward porting P10 → P12 (#851)
* Forward port 10 → 12 (#893)
* Forward port 10.3.3 → Pharo 12 (#903)
* Realign P12 branch to P10 (#1057)
* Removing duplicated code (#857)
* Cleanups and improvements (#871)
* Lots of cleanups (#874)
* Cleaning (#881)
* Cleanup dead code (#961)
* Cleanup warnings (#906)
* Fix warnings (#1034)
* Remove debugging code (#911)
* Remove unused variables (#930)
* Normalize variable (#897)
* Remove `gcMode` because `getGCMode` is used (#963)
* Remove `ceShortCutTraceStore:` and simulation guard users (#960)
* Simplify signal handler space calculation using POSIX `SIGSTKSZ` (#910)

### Documentation & Developer Experience

* README: Developer documentation is not a link (#637)
* Update README (#878)
* Add default values to `--help` parameters (#872)
* Fix typos in comments (#958)

### New Contributors

* @Mathilde411
* @LucFabresse
* @ivojawer
* @Gabriel-Darbord
* @iglosiggio
* @rolandbernard
* @fouziray
* @kilian-kier
* @NathanMalenge
* @FedeLoch
* @Ducasse
* @takano32

**Full Changelog:** https://github.com/pharo-project/pharo-vm/compare/v10.3.3...v12.0.2-beta

## v10.3.8

* Fixing a race condition introduced in v10.3.7 by @tesonep in https://github.com/pharo-project/pharo-vm/pull/1011

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.3.7...v10.3.8

## v10.3.7

* Improving debugging and types of aioWin.c by @tesonep in https://github.com/pharo-project/pharo-vm/pull/1008
* Reducing the number of handles to test by @tesonep in https://github.com/pharo-project/pharo-vm/pull/1009

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.3.6...v10.3.7

## v10.3.6

* [P10] Fix OBS Build by @tesonep in https://github.com/pharo-project/pharo-vm/pull/980
* Fix Issue 982 - Pharo 10 branch by @guillep in https://github.com/pharo-project/pharo-vm/pull/984
* Fix missing accept on socket by @tesonep in https://github.com/pharo-project/pharo-vm/pull/995
* fixing-build-in-windows by @tesonep in https://github.com/pharo-project/pharo-vm/pull/997

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.3.5...v10.3.6

## v10.3.5

* Removed unused temp in `findNewMethodOrdinaryIfFound:` by @kumom in https://github.com/pharo-project/pharo-vm/pull/951
* Remove set cursor C code #210 by @kumom in https://github.com/pharo-project/pharo-vm/pull/952
* fix PharoWorker value when coming from plist file by @demarey in https://github.com/pharo-project/pharo-vm/pull/972
* log worker mode by @demarey in https://github.com/pharo-project/pharo-vm/pull/971
* Updating SDL2 to 2.32.6 for Windows (x86_64) and MacOS (ARM and Intel) by @tesonep in https://github.com/pharo-project/pharo-vm/pull/977
* Set the size of larger indexable object allocated in the young space by @tesonep in https://github.com/pharo-project/pharo-vm/pull/975


**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.3.4...v10.3.5

## v10.3.4

* Add windows support for non ASCII filenames in basicImageFileExists by @demarey in https://github.com/pharo-project/pharo-vm/pull/926
* Fix signal handler signature by @guillep in https://github.com/pharo-project/pharo-vm/pull/940

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.3.3...v10.3.4

## v10.3.3

* Fixes for 10.3.2 by @guillep in https://github.com/pharo-project/pharo-vm/pull/885
* Enhancement(versionning): Extract full semantic version from git by @guillep in https://github.com/pharo-project/pharo-vm/pull/884
* Fix linking of UnixOSProcessPlugin - Remove dead code by @guillep in https://github.com/pharo-project/pharo-vm/pull/888
* Fix failing tests by @guillep in https://github.com/pharo-project/pharo-vm/pull/887
* fixing-classTag-tests by @tesonep in https://github.com/pharo-project/pharo-vm/pull/886
* fix C warnings related to self assignments by @RenaudFondeur in https://github.com/pharo-project/pharo-vm/pull/894
* Build on old linux server by @guillep in https://github.com/pharo-project/pharo-vm/pull/898
* force non-shallow checkout on CI by @guillep in https://github.com/pharo-project/pharo-vm/pull/899
* Update build and dev VM and image to latest pharo 12 release by @guillep in https://github.com/pharo-project/pharo-vm/pull/900

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.3.2...v10.3.3

## v10.3.2

* Improving Implementation of CompositeImageFormat and PermanentSpace by @tesonep in https://github.com/pharo-project/pharo-vm/pull/855
* Fixing cygpath conversion for newer version of cmake by @tesonep in https://github.com/pharo-project/pharo-vm/pull/860
* use pharo file server @ inria by @demarey in https://github.com/pharo-project/pharo-vm/pull/867
* compatible with FreeBSD mmap() by @Dieken in https://github.com/pharo-project/pharo-vm/pull/863
* Improving Forwarders in the PermSpace by @tesonep in https://github.com/pharo-project/pharo-vm/pull/861
* When patching JITed code after become of a class, the class index can look like a negative number by @tesonep in https://github.com/pharo-project/pharo-vm/pull/873

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.3.1...v10.3.2

## v10.3.1
* Making it loadable in P12 by @guillep in https://github.com/pharo-project/pharo-vm/pull/825
* Added test on extended store and pop by @guillep in https://github.com/pharo-project/pharo-vm/pull/520
* Update build version to P12 by @guillep in https://github.com/pharo-project/pharo-vm/pull/826
* Improving log of old space limit error reporting by @tesonep in https://github.com/pharo-project/pharo-vm/pull/833
* a better comment support for Slang by @RenaudFondeur in https://github.com/pharo-project/pharo-vm/pull/838
* a first version of Slang with no type conflict and an exception if one appear by @RenaudFondeur in https://github.com/pharo-project/pharo-vm/pull/819
* remove unused cast and expression by @RenaudFondeur in https://github.com/pharo-project/pharo-vm/pull/837
* fix warnings related to multiple include of the same header file by @RenaudFondeur in https://github.com/pharo-project/pharo-vm/pull/840
* Fix a lot of unused expression by @RenaudFondeur in https://github.com/pharo-project/pharo-vm/pull/832
* add a comment explaining why declareCVarsIn: is empty in some subclasses by @RenaudFondeur in https://github.com/pharo-project/pharo-vm/pull/842
* small change in dead code elimination to considers a method with only comments empty by @RenaudFondeur in https://github.com/pharo-project/pharo-vm/pull/843
* small change in copyWithoutReturn to handle CCoerce by @RenaudFondeur in https://github.com/pharo-project/pharo-vm/pull/836
* Remove hostname lookup on network initialization by @guillep in https://github.com/pharo-project/pharo-vm/pull/845
* Update SDL2 version in OSX (Intel & Apple) by @tesonep in https://github.com/pharo-project/pharo-vm/pull/849
* Adding option for pin behaviour by @tesonep in https://github.com/pharo-project/pharo-vm/pull/844

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.3.0...v10.3.1

## v10.3.0

* New harmonize rule by @RenaudFondeur in https://github.com/pharo-project/pharo-vm/pull/817
* Ignoring EAGAIN in epoll_wait by @tesonep in https://github.com/pharo-project/pharo-vm/pull/818
* Extend macOS implementation of SqueakSSL plugin to support setting a certificate on the SSL session context by @Rinzwind in https://github.com/pharo-project/pharo-vm/pull/816
* Adding macro for win32.  by @tesonep in https://github.com/pharo-project/pharo-vm/pull/814

## v10.2.1

* Adding the missing tty.c file in the packaging. by @tesonep in https://github.com/pharo-project/pharo-vm/pull/771
* Do not allow comparing objects of different types by @guillep in https://github.com/pharo-project/pharo-vm/pull/772
* Prepare release 10.2.1 by @guillep in https://github.com/pharo-project/pharo-vm/pull/773
* Constant conversion warning by @guillep in https://github.com/pharo-project/pharo-vm/pull/777
* Fix tautological-pointer-compare warnings by @guillep in https://github.com/pharo-project/pharo-vm/pull/775
* Removed Cogit>>#voidNSSendCache:  by @jordanmontt in https://github.com/pharo-project/pharo-vm/pull/776
* Re-enable incompatible-function-pointer-types warning by @guillep in https://github.com/pharo-project/pharo-vm/pull/778
* Removed unused functions from the C written by hand by @jordanmontt in https://github.com/pharo-project/pharo-vm/pull/780
* Fix function pointer comparison warning by @guillep in https://github.com/pharo-project/pharo-vm/pull/783
* Fix -return-type warnings by @doste in https://github.com/pharo-project/pharo-vm/pull/781
* Fix shift-negative-value warning and reenable warning by @guillep in https://github.com/pharo-project/pharo-vm/pull/785
* Remove warnings c compiler by @PalumboN in https://github.com/pharo-project/pharo-vm/pull/789
* Remove StackInterpreter interruptPending instance variable by @jordanmontt in https://github.com/pharo-project/pharo-vm/pull/793
* Do not use asserta: in a statement by @guillep in https://github.com/pharo-project/pharo-vm/pull/788
* Bump to MacOS 11 and above by @guillep in https://github.com/pharo-project/pharo-vm/pull/792
* Moving pharo.signatures files for OSX Bundle to Resources folder by @tesonep in https://github.com/pharo-project/pharo-vm/pull/770
* Do not retain any selectors in CogAbstractInstruction by @RenaudFondeur in https://github.com/pharo-project/pharo-vm/pull/798
* remove warning because of type and unsigned shift issues by @RenaudFondeur in https://github.com/pharo-project/pharo-vm/pull/800
* add tests for type harmonization by @RenaudFondeur in https://github.com/pharo-project/pharo-vm/pull/807
* Primitive format by @doste in https://github.com/pharo-project/pharo-vm/pull/802
* Adding an implementation of the aio.c using EPOLL in Linux. by @tesonep in https://github.com/pharo-project/pharo-vm/pull/805
* Fixing warnings that are errors in newer versions of clang by @tesonep in https://github.com/pharo-project/pharo-vm/pull/813

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.2.0...v10.2.1

## v10.2.0
* Add library with function to spawn a process connected to a pseudo-terminal by @Rinzwind in https://github.com/pharo-project/pharo-vm/pull/742
* Fix VM build in MacOS sonoma by @guillep in https://github.com/pharo-project/pharo-vm/pull/758
* Primitive to compare bytes by @doste in https://github.com/pharo-project/pharo-vm/pull/759
* Translate documentation picture to Englitsh by @Inao0 in https://github.com/pharo-project/pharo-vm/pull/764

**Full Changelog**: https://github.com/pharo-project/pharo-vm/compare/v10.1.1...v10.2.0

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
