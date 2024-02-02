Trait {
	#name : #TImageReader,
	#category : #'VMMaker-ImageFormat'
}

{ #category : #translation }
TImageReader classSide >> staticallyResolvedSelectors [

	^ super staticallyResolvedSelectors
	  ,
		  #( #loadImageFromFile:withHeader: readImageNamed: #readPermanentSpaceFromImageFile:header:
		     #readSegmentsFromImageFile:header:
		     #doLoadImageFromFile:withHeader: )
]

{ #category : #api }
TImageReader >> doLoadImageFromFile: imageFile withHeader: header [

	"read in the image in bulk, then swap the bytes if necessary"

	<var: #header type: #SpurImageHeaderStruct>
	| bytesRead oldSpaceBytesRead permSpaceBytesRead |

	oldSpaceBytesRead := self readSegmentsFromImageFile: imageFile header: header.

	permSpaceBytesRead := self readPermanentSpaceFromImageFile: imageFile header: header. 
	
	bytesRead := oldSpaceBytesRead + permSpaceBytesRead.

	self initializeInterpreterFromHeader: header withBytes: bytesRead

]
