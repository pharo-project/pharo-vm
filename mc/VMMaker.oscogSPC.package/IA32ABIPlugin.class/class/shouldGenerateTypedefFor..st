translation
shouldGenerateTypedefFor: aStructClass
	"Hack to work-around mutliple definitions.  Sometimes a type has been defined in an include."
	^aStructClass ~~ VMCallbackContext