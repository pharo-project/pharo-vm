ckformat
generateCkFormatProgram: programName on: stream
	"Generate source code for an image format version reader. The program
	is intended for testing image file format from a unix shell script such that
	the shell script can decide what VM to run based on image requirements."

	| formatNumber |
	stream nextPutAll: '/* ', programName, ': Print the image format number on standard output */'; cr;
			nextPutAll: '/* for use in a shell script to test image format requirements. */'; cr;
			nextPutAll: '/* A non-zero return status code indicates failure. */'; cr; cr;
			nextPutAll: '/* Usage: ', programName, ' imageFileName */'; cr; cr;
			nextPutAll: '/* --- DO NOT EDIT THIS FILE --- */'; cr;
			nextPutAll: '/* --- Automatically generated from class ', self name, ' ', DateAndTime now asString, '--- */'; cr;
			nextPutAll: '/* --- Source code is in package ImageFormat in the VMMaker repository --- */'; cr;
			nextPutAll: '/* --- DO NOT EDIT THIS FILE --- */'; cr; cr;
			nextPutAll: '#include <stdio.h>'; cr;
			nextPutAll: '#include <stdlib.h>'; cr;
			nextPutAll: '#include <string.h>'; cr; cr;
			nextPutAll: 'main(int argc, char **argv) {'; cr;
			tab; nextPutAll: 'FILE *f;'; cr;
			tab; nextPutAll: 'unsigned char buf[8];'; cr;		
			tab; nextPutAll: 'int formatNumber;'; cr;		
			tab; nextPutAll: 'unsigned char c;'; cr;		
			tab; nextPutAll: 'int match;'; cr;		
			tab; nextPutAll: 'if (argc != 2) {'; cr;
			tab; tab; nextPutAll: 'printf("usage: ', programName,  ' imageFileName\n");'; cr;
			tab; tab; nextPutAll: 'exit(1);'; cr;
			tab; nextPutAll: '}'; cr;
			tab; nextPutAll: 'f = fopen(argv[1], "r");'; cr;
			tab; nextPutAll: 'if (f == NULL) {'; cr;
			tab; tab; nextPutAll: 'perror(argv[1]);'; cr;
			tab; tab; nextPutAll: 'exit(2);'; cr;
			tab; nextPutAll: '}'; cr.
	{ 0. 512 } do: [:offset |
		stream
			tab; nextPutAll: 'if(fseek(f, '; nextPutAll: offset asString; nextPutAll: 'L, SEEK_SET) != 0) {';cr;
			tab; tab; nextPutAll: 'fprintf(stderr, "cannot go to pos %d in %s\n", '; nextPutAll: offset asString; nextPutAll: ', argv[1]);'; cr;
			tab; tab; nextPutAll: 'exit(3);'; cr;
			tab; nextPutAll: '}'; cr;
			tab; nextPutAll: 'if (fread(buf, 1, 8, f) < 8) {'; cr;
			tab; tab; nextPutAll: 'fprintf(stderr, "cannot read %s\n", argv[1]);'; cr;
			tab; tab; nextPutAll: 'exit(3);'; cr;
			tab; nextPutAll: '}'; cr.
		self versionNumberByteArrays withIndexDo: [ :v :tag | | b |
			formatNumber := (self fromBytes: v) asInteger.
			b := 'b_', formatNumber asString, '_', tag asString.
			stream tab; nextPutAll: '{'; cr; tab; nextPutAll: 'unsigned char ', b, '[', v size asString, ']= { '.
			v inject: true into: [:first : elem |
				first ifFalse: [stream nextPutAll: ', '].
				stream nextPutAll: elem asString.
				false].
			stream nextPutAll: '};'; cr;
					tab; nextPutAll: 'if (strncmp(buf, ', b, ', ', v size asString, ') == 0) {'; cr;
					tab; tab; nextPutAll: 'printf("%d\n", ', formatNumber, ');'; cr;
					tab; tab; nextPutAll: 'exit(0);'; cr;
					tab; nextPutAll: '}'; cr; tab; nextPutAll: '}'; cr]].
	stream tab; nextPutAll: 'printf("0\n"); /* print an invalid format number */';cr;
			tab; nextPutAll: 'exit (-1); /* not found, exit with error code */'; cr;
			nextPutAll: '}'; cr
