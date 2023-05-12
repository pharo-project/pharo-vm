"Patch the Pharo image removing the tests that crash the VM"

"For https://github.com/pharo-project/pharo/issues/11745"
ReflectivityControlTest removeSelector: #testAfterSequence.


Smalltalk snapshot: true andQuit: true.
