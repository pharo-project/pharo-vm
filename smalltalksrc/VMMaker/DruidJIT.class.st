Class {
	#name : #DruidJIT,
	#superclass : #StackToRegisterMappingCogit,
	#instVars : [
		'ceDereferenceSelectorIndex',
		'ceStoreTrampolines',
		'ceNewHashTrampoline',
		'ceInlineNewHashTrampoline',
		'ceStoreCheckTrampoline',
		'ceStoreCheckContextReceiverTrampoline',
		'ceScheduleScavengeTrampoline',
		'ceSmallActiveContextInMethodTrampoline',
		'ceSmallActiveContextInFullBlockTrampoline',
		'ceLargeActiveContextInMethodTrampoline',
		'ceLargeActiveContextInFullBlockTrampoline'
	],
	#classVars : [
		'CheckRememberedInTrampoline',
		'NumStoreTrampolines'
	],
	#category : #'VMMaker-JIT'
}

{ #category : #'class initialization' }
DruidJIT class >> bytecodeTable [

	<generated>
	^ {
		  { 1. 0. 0. #gen_PushReceiverVariableBytecode0.
		  #isInstVarRef. #needsFrameNever:. 1 }.
		  { 1. 1. 1. #gen_PushReceiverVariableBytecode1.
		  #isInstVarRef. #needsFrameNever:. 1 }.
		  { 1. 2. 2. #gen_PushReceiverVariableBytecode2.
		  #isInstVarRef. #needsFrameNever:. 1 }.
		  { 1. 3. 3. #gen_PushReceiverVariableBytecode3.
		  #isInstVarRef. #needsFrameNever:. 1 }.
		  { 1. 4. 4. #gen_PushReceiverVariableBytecode4.
		  #isInstVarRef. #needsFrameNever:. 1 }.
		  { 1. 5. 5. #gen_PushReceiverVariableBytecode5.
		  #isInstVarRef. #needsFrameNever:. 1 }.
		  { 1. 6. 6. #gen_PushReceiverVariableBytecode6.
		  #isInstVarRef. #needsFrameNever:. 1 }.
		  { 1. 7. 7. #gen_PushReceiverVariableBytecode7.
		  #isInstVarRef. #needsFrameNever:. 1 }.
		  { 1. 8. 8. #gen_PushReceiverVariableBytecode8.
		  #isInstVarRef. #needsFrameNever:. 1 }.
		  { 1. 9. 9. #gen_PushReceiverVariableBytecode9.
		  #isInstVarRef. #needsFrameNever:. 1 }.
		  { 1. 10. 10. #unknownBytecode }.
		  { 1. 11. 11. #unknownBytecode }.
		  { 1. 12. 12. #unknownBytecode }.
		  { 1. 13. 13. #unknownBytecode }.
		  { 1. 14. 14. #unknownBytecode }.
		  { 1. 15. 15. #unknownBytecode }.
		  { 1. 16. 16. #unknownBytecode }.
		  { 1. 17. 17. #unknownBytecode }.
		  { 1. 18. 18. #unknownBytecode }.
		  { 1. 19. 19. #unknownBytecode }.
		  { 1. 20. 20. #unknownBytecode }.
		  { 1. 21. 21. #unknownBytecode }.
		  { 1. 22. 22. #unknownBytecode }.
		  { 1. 23. 23. #unknownBytecode }.
		  { 1. 24. 24. #unknownBytecode }.
		  { 1. 25. 25. #unknownBytecode }.
		  { 1. 26. 26. #unknownBytecode }.
		  { 1. 27. 27. #unknownBytecode }.
		  { 1. 28. 28. #unknownBytecode }.
		  { 1. 29. 29. #unknownBytecode }.
		  { 1. 30. 30. #unknownBytecode }.
		  { 1. 31. 31. #unknownBytecode }.
		  { 1. 32. 32. #unknownBytecode }.
		  { 1. 33. 33. #unknownBytecode }.
		  { 1. 34. 34. #unknownBytecode }.
		  { 1. 35. 35. #unknownBytecode }.
		  { 1. 36. 36. #unknownBytecode }.
		  { 1. 37. 37. #unknownBytecode }.
		  { 1. 38. 38. #unknownBytecode }.
		  { 1. 39. 39. #unknownBytecode }.
		  { 1. 40. 40. #unknownBytecode }.
		  { 1. 41. 41. #unknownBytecode }.
		  { 1. 42. 42. #unknownBytecode }.
		  { 1. 43. 43. #unknownBytecode }.
		  { 1. 44. 44. #unknownBytecode }.
		  { 1. 45. 45. #unknownBytecode }.
		  { 1. 46. 46. #unknownBytecode }.
		  { 1. 47. 47. #unknownBytecode }.
		  { 1. 48. 48. #unknownBytecode }.
		  { 1. 49. 49. #unknownBytecode }.
		  { 1. 50. 50. #unknownBytecode }.
		  { 1. 51. 51. #unknownBytecode }.
		  { 1. 52. 52. #unknownBytecode }.
		  { 1. 53. 53. #unknownBytecode }.
		  { 1. 54. 54. #unknownBytecode }.
		  { 1. 55. 55. #unknownBytecode }.
		  { 1. 56. 56. #unknownBytecode }.
		  { 1. 57. 57. #unknownBytecode }.
		  { 1. 58. 58. #unknownBytecode }.
		  { 1. 59. 59. #unknownBytecode }.
		  { 1. 60. 60. #unknownBytecode }.
		  { 1. 61. 61. #unknownBytecode }.
		  { 1. 62. 62. #unknownBytecode }.
		  { 1. 63. 63. #unknownBytecode }.
		  { 1. 64. 64. #gen_PushTemporaryVariableBytecode0.
		  #needsFrameIfMod16GENumArgs:. 1 }.
		  { 1. 65. 65. #gen_PushTemporaryVariableBytecode1.
		  #needsFrameIfMod16GENumArgs:. 1 }.
		  { 1. 66. 66. #gen_PushTemporaryVariableBytecode2.
		  #needsFrameIfMod16GENumArgs:. 1 }.
		  { 1. 67. 67. #unknownBytecode }.
		  { 1. 68. 68. #unknownBytecode }.
		  { 1. 69. 69. #unknownBytecode }.
		  { 1. 70. 70. #unknownBytecode }.
		  { 1. 71. 71. #unknownBytecode }.
		  { 1. 72. 72. #unknownBytecode }.
		  { 1. 73. 73. #unknownBytecode }.
		  { 1. 74. 74. #unknownBytecode }.
		  { 1. 75. 75. #unknownBytecode }.
		  { 1. 76. 76. #gen_PushReceiverBytecode. #needsFrameNever:.
		  1 }.
		  { 1. 77. 77. #unknownBytecode }.
		  { 1. 78. 78. #unknownBytecode }.
		  { 1. 79. 79. #unknownBytecode }.
		  { 1. 80. 80. #gen_PushConstantZeroBytecode.
		  #needsFrameNever:. 1 }.
		  { 1. 81. 81. #gen_PushConstantOneBytecode }.
		  { 1. 82. 82. #unknownBytecode }.
		  { 1. 83. 83. #unknownBytecode }.
		  { 1. 84. 84. #unknownBytecode }.
		  { 1. 85. 85. #unknownBytecode }.
		  { 1. 86. 86. #unknownBytecode }.
		  { 1. 87. 87. #unknownBytecode }.
		  { 1. 88. 88. #gen_ReturnReceiver. #return. #isMappedInBlock.
		  #needsFrameIfInBlock:. 0 }.
		  { 1. 89. 89. #gen_ReturnTrue. #return. #isMappedInBlock.
		  #needsFrameIfInBlock:. 0 }.
		  { 1. 90. 90. #gen_ReturnFalse. #return. #isMappedInBlock.
		  #needsFrameIfInBlock:. 0 }.
		  { 1. 91. 91. #gen_ReturnNil. #return. #isMappedInBlock.
		  #needsFrameIfInBlock:. 0 }.
		  { 1. 92. 92. #gen_ReturnTopFromMethod. #return. #isMappedInBlock.
		  #needsFrameIfInBlock:.  -1 }.
		  { 1. 93. 93. #unknownBytecode }.
		  { 1. 94. 94. #unknownBytecode }.
		  { 1. 95. 95. #unknownBytecode }.
		  { 1. 96. 96. #gen_BytecodePrimAdd }.
		  { 1. 97. 97. #gen_BytecodePrimSubtract. #isMapped }.
		  { 1. 98. 98. #gen_BytecodePrimLessThanSistaV1.
		  #isMapped }.
		  { 1. 99. 99. #gen_BytecodePrimGreaterThanSistaV1.
		  #isMapped }.
		  { 1. 100. 100. #gen_BytecodePrimLessOrEqualSistaV1.
		  #isMapped }.
		  { 1. 101. 101. #gen_BytecodePrimGreaterOrEqualSistaV1.
		  #isMapped }.
		  { 1. 102. 102. #gen_BytecodePrimEqualSistaV1.
		  #isMapped }.
		  { 1. 103. 103. #gen_BytecodePrimNotEqualSistaV1.
		  #isMapped }.
		  { 1. 104. 104. #gen_BytecodePrimMultiply. #isMapped }.
		  { 1. 105. 105. #gen_BytecodePrimDivide. #isMapped }.
		  { 1. 106. 106. #gen_BytecodePrimMod. #isMapped }.
		  { 1. 107. 107. #gen_BytecodePrimMakePoint.
		  #isMapped }.
		  { 1. 108. 108. #gen_BytecodePrimBitShift. #isMapped }.
		  { 1. 109. 109. #gen_BytecodePrimDiv. #isMapped }.
		  { 1. 110. 110. #gen_BytecodePrimBitAnd. #isMapped }.
		  { 1. 111. 111. #gen_BytecodePrimBitOr. #isMapped }.
		  { 1. 112. 112. #gen_BytecodePrimAt. #isMapped }.
		  { 1. 113. 113. #gen_BytecodePrimAtPut. #isMapped }.
		  { 1. 114. 114. #gen_BytecodePrimSize. #isMapped }.
		  { 1. 115. 115. #gen_BytecodePrimNext. #isMapped }.
		  { 1. 116. 116. #gen_BytecodePrimNextPut. #isMapped }.
		  { 1. 117. 117. #gen_BytecodePrimAtEnd. #isMapped }.
		  { 1. 118. 118. #gen_BytecodePrimIdenticalSistaV1.
		  #notMapped. #needsFrameNever:.  -1 }.
		  { 1. 119. 119. #unknownBytecode }.
		  { 1. 120. 120. #gen_BytecodePrimNotIdenticalSistaV1.
		  #notMapped. #needsFrameNever:.  -1 }.
		  { 1. 121. 121. #gen_BytecodePrimValue. #isMapped }.
		  { 1. 122. 122. #gen_BytecodePrimValueWithArg.
		  #isMapped }.
		  { 1. 123. 123. #gen_BytecodePrimDo. #isMapped }.
		  { 1. 124. 124. #gen_BytecodePrimNew. #isMapped }.
		  { 1. 125. 125. #gen_BytecodePrimNewWithArg.
		  #isMapped }.
		  { 1. 126. 126. #gen_BytecodePrimPointX. #isMapped }.
		  { 1. 127. 127. #gen_BytecodePrimPointY. #isMapped }.
		  { 1. 128. 128. #gen_SendLiteralSelector0ArgsBytecode0 }.
		  { 1. 129. 129. #gen_SendLiteralSelector0ArgsBytecode1 }.
		  { 1. 130. 130. #gen_SendLiteralSelector0ArgsBytecode2 }.
		  { 1. 131. 131. #gen_SendLiteralSelector0ArgsBytecode3 }.
		  { 1. 132. 132. #gen_SendLiteralSelector0ArgsBytecode4 }.
		  { 1. 133. 133. #gen_SendLiteralSelector0ArgsBytecode5 }.
		  { 1. 134. 134. #gen_SendLiteralSelector0ArgsBytecode6 }.
		  { 1. 135. 135. #unknownBytecode }.
		  { 1. 136. 136. #unknownBytecode }.
		  { 1. 137. 137. #unknownBytecode }.
		  { 1. 138. 138. #unknownBytecode }.
		  { 1. 139. 139. #unknownBytecode }.
		  { 1. 140. 140. #unknownBytecode }.
		  { 1. 141. 141. #unknownBytecode }.
		  { 1. 142. 142. #unknownBytecode }.
		  { 1. 143. 143. #unknownBytecode }.
		  { 1. 144. 144. #gen_SendLiteralSelector1ArgBytecode0 }.
		  { 1. 145. 145. #gen_SendLiteralSelector1ArgBytecode1 }.
		  { 1. 146. 146. #gen_SendLiteralSelector1ArgBytecode2 }.
		  { 1. 147. 147. #gen_SendLiteralSelector1ArgBytecode3 }.
		  { 1. 148. 148. #gen_SendLiteralSelector1ArgBytecode4 }.
		  { 1. 149. 149. #gen_SendLiteralSelector1ArgBytecode5 }.
		  { 1. 150. 150. #gen_SendLiteralSelector1ArgBytecode6 }.
		  { 1. 151. 151. #unknownBytecode }.
		  { 1. 152. 152. #unknownBytecode }.
		  { 1. 153. 153. #unknownBytecode }.
		  { 1. 154. 154. #unknownBytecode }.
		  { 1. 155. 155. #unknownBytecode }.
		  { 1. 156. 156. #unknownBytecode }.
		  { 1. 157. 157. #unknownBytecode }.
		  { 1. 158. 158. #unknownBytecode }.
		  { 1. 159. 159. #unknownBytecode }.
		  { 1. 160. 160. #gen_SendLiteralSelector2ArgsBytecode0 }.
		  { 1. 161. 161. #gen_SendLiteralSelector2ArgsBytecode1 }.
		  { 1. 162. 162. #gen_SendLiteralSelector2ArgsBytecode2 }.
		  { 1. 163. 163. #gen_SendLiteralSelector2ArgsBytecode3 }.
		  { 1. 164. 164. #gen_SendLiteralSelector2ArgsBytecode4 }.
		  { 1. 165. 165. #gen_SendLiteralSelector2ArgsBytecode5 }.
		  { 1. 166. 166. #gen_SendLiteralSelector2ArgsBytecode6 }.
		  { 1. 167. 167. #gen_SendLiteralSelector2ArgsBytecode7 }.
		  { 1. 168. 168. #gen_SendLiteralSelector2ArgsBytecode8 }.
		  { 1. 169. 169. #unknownBytecode }.
		  { 1. 170. 170. #unknownBytecode }.
		  { 1. 171. 171. #unknownBytecode }.
		  { 1. 172. 172. #unknownBytecode }.
		  { 1. 173. 173. #unknownBytecode }.
		  { 1. 174. 174. #unknownBytecode }.
		  { 1. 175. 175. #unknownBytecode }.
		  { 1. 176. 176. #unknownBytecode }.
		  { 1. 177. 177. #unknownBytecode }.
		  { 1. 178. 178. #unknownBytecode }.
		  { 1. 179. 179. #unknownBytecode }.
		  { 1. 180. 180. #unknownBytecode }.
		  { 1. 181. 181. #unknownBytecode }.
		  { 1. 182. 182. #unknownBytecode }.
		  { 1. 183. 183. #unknownBytecode }.
		  { 1. 184. 184. #unknownBytecode }.
		  { 1. 185. 185. #unknownBytecode }.
		  { 1. 186. 186. #unknownBytecode }.
		  { 1. 187. 187. #unknownBytecode }.
		  { 1. 188. 188. #unknownBytecode }.
		  { 1. 189. 189. #unknownBytecode }.
		  { 1. 190. 190. #unknownBytecode }.
		  { 1. 191. 191. #unknownBytecode }.
		  { 1. 192. 192. #unknownBytecode }.
		  { 1. 193. 193. #unknownBytecode }.
		  { 1. 194. 194. #unknownBytecode }.
		  { 1. 195. 195. #unknownBytecode }.
		  { 1. 196. 196. #unknownBytecode }.
		  { 1. 197. 197. #unknownBytecode }.
		  { 1. 198. 198. #unknownBytecode }.
		  { 1. 199. 199. #unknownBytecode }.
		  { 1. 200. 200. #unknownBytecode }.
		  { 1. 201. 201. #unknownBytecode }.
		  { 1. 202. 202. #unknownBytecode }.
		  { 1. 203. 203. #unknownBytecode }.
		  { 1. 204. 204. #unknownBytecode }.
		  { 1. 205. 205. #unknownBytecode }.
		  { 1. 206. 206. #unknownBytecode }.
		  { 1. 207. 207. #unknownBytecode }.
		  { 1. 208. 208. #unknownBytecode }.
		  { 1. 209. 209. #unknownBytecode }.
		  { 1. 210. 210. #unknownBytecode }.
		  { 1. 211. 211. #unknownBytecode }.
		  { 1. 212. 212. #unknownBytecode }.
		  { 1. 213. 213. #unknownBytecode }.
		  { 1. 214. 214. #unknownBytecode }.
		  { 1. 215. 215. #unknownBytecode }.
		  { 1. 216. 216. #unknownBytecode }.
		  { 1. 217. 217. #unknownBytecode }.
		  { 1. 218. 218. #unknownBytecode }.
		  { 1. 219. 219. #unknownBytecode }.
		  { 1. 220. 220. #unknownBytecode }.
		  { 1. 221. 221. #unknownBytecode }.
		  { 1. 222. 222. #unknownBytecode }.
		  { 1. 223. 223. #unknownBytecode }.
		  { 2. 224. 224. #unknownBytecode }.
		  { 2. 225. 225. #unknownBytecode }.
		  { 2. 226. 226. #unknownBytecode }.
		  { 2. 227. 227. #unknownBytecode }.
		  { 2. 228. 228. #unknownBytecode }.
		  { 2. 229. 229. #unknownBytecode }.
		  { 2. 230. 230. #unknownBytecode }.
		  { 2. 231. 231. #unknownBytecode }.
		  { 2. 232. 232. #unknownBytecode }.
		  { 2. 233. 233. #unknownBytecode }.
		  { 2. 234. 234. #unknownBytecode }.
		  { 2. 235. 235. #unknownBytecode }.
		  { 2. 236. 236. #unknownBytecode }.
		  { 2. 237. 237. #unknownBytecode }.
		  { 2. 238. 238. #unknownBytecode }.
		  { 2. 239. 239. #unknownBytecode }.
		  { 2. 240. 240. #unknownBytecode }.
		  { 2. 241. 241. #unknownBytecode }.
		  { 2. 242. 242. #unknownBytecode }.
		  { 2. 243. 243. #unknownBytecode }.
		  { 2. 244. 244. #unknownBytecode }.
		  { 2. 245. 245. #unknownBytecode }.
		  { 2. 246. 246. #unknownBytecode }.
		  { 2. 247. 247. #unknownBytecode }.
		  { 3. 248. 248. #unknownBytecode }.
		  { 3. 249. 249. #unknownBytecode }.
		  { 3. 250. 250. #unknownBytecode }.
		  { 3. 251. 251. #unknownBytecode }.
		  { 3. 252. 252. #unknownBytecode }.
		  { 3. 253. 253. #unknownBytecode }.
		  { 3. 254. 254. #unknownBytecode }.
		  { 3. 255. 255. #unknownBytecode } }
]

{ #category : #translation }
DruidJIT class >> declareCVarsIn: aCodeGen [
	"Deal wuth the fact that the number of trampolines depends on IMMUTABILITY
	 and that IMMUTABILITY can be defined at compile time.  Yes, this is a mess."
	| current values |
	current := InitializationOptions at: #IMMUTABILITY ifAbsent: nil.
	values := #(true false) collect:
				[:bool|
				 InitializationOptions at: #IMMUTABILITY put: bool.
				 self initializeNumTrampolines.
				 (Cogit classPool at: #NumTrampolines) printString].
	current
		ifNil: [InitializationOptions removeKey: #IMMUTABILITY]
		ifNotNil: [InitializationOptions at: #IMMUTABILITY put: current].
	values first ~= values last ifTrue:
		[aCodeGen addConstantForBinding: #NumTrampolines -> ('(IMMUTABILITY ? ' , values first , ' : ' , values last , ')')].

	aCodeGen
		var: #ceStoreTrampolines
		declareC: ('#if IMMUTABILITY\sqInt ceStoreTrampolines[', NumStoreTrampolines printString, '];\#endif') withCRs
]

{ #category : #initialization }
DruidJIT class >> initialize [
	
	NumStoreTrampolines := 5
]

{ #category : #'class initialization' }
DruidJIT class >> initializeBytecodeTableForSistaV1 [

	<generated>
	numPushNilsFunction := #sistaV1:Num:Push:Nils:.
	pushNilSizeFunction := #sistaV1PushNilSize:numInitialNils:.
	BytecodeSetHasDirectedSuperSend := true.
	BytecodeSetHasExtensions := true.
	FirstSpecialSelector := 96.
	NumSpecialSelectors := 32.
	self generatorTableFrom: self bytecodeTable
]

{ #category : #'class initialization' }
DruidJIT class >> initializePrimitiveTable [

	<generated>
	MaxCompiledPrimitiveIndex := 20.
	primitiveTable := CArrayAccessor on:
		                  (Array new: MaxCompiledPrimitiveIndex + 1).
	self table: primitiveTable from: self primitiveTableArray.
	^ primitiveTable
]

{ #category : #translation }
DruidJIT class >> objectRepresentationAncilliaryClasses [

	^ Array empty
]

{ #category : #'accessing class hierarchy' }
DruidJIT class >> objectRepresentationClass [

]

{ #category : #'class initialization' }
DruidJIT class >> primitiveTableArray [

	<generated>
	^ {
		  { 1. #gen_PrimitiveAdd. 1 }.
		  { 2. #gen_PrimitiveSubtract. 1 }.
		  { 3. #gen_PrimitiveLessThan. 1 }.
		  { 4. #gen_PrimitiveGreaterThan. 1 }.
		  { 5. #gen_PrimitiveLessOrEqual. 1 }.
		  { 6. #gen_PrimitiveGreaterOrEqual. 1 }.
		  { 7. #gen_PrimitiveEqual. 1 }.
		  { 8. #gen_PrimitiveNotEqual. 1 }.
		  { 9. #gen_PrimitiveMultiply. 1 }.
		  { 10. #gen_PrimitiveDivide. 1 }.
		  { 60. #gen_PrimitiveAt. 1 }.
		  { 70. #gen_PrimitiveNew. 0 }.
		  { 71. #gen_PrimitiveNewWithArg. 1 }.
		  { 73. #genNonImplementedPrimitive.  -1. #maycallback }.
		  { 117. #genNonImplementedPrimitive.  -1. #maycallback }.
		  { 120. #genNonImplementedPrimitive.  -1. #maycallback }.
		  { 148. #genNonImplementedPrimitive.  -1. #maycallback }.
		  { 160. #genNonImplementedPrimitive.  -1. #maycallback }.
		  { 173. #genNonImplementedPrimitive.  -1. #maycallback }.
		  { 216. #genNonImplementedPrimitive.  -1. #maycallback } }
]

{ #category : #'trait candidates' }
DruidJIT >> allYoungObjectsAgeInFullGC [
	^false
]

{ #category : #'trait candidates' }
DruidJIT >> bitAndByteOffsetOfIsFullBlockBitInto: aBlock [

	"This supplies the bitmask for the isFullBlock bit, and the offset of the byte containing
	 that bit in a CogMethod header to aBlock.  We don't have named variables holding this
	 offset.  The following assert tests whether the values are correct by creating a surrogate
	 on an empty ByteArray, setting the bit, and checking that the expected values are set
	 in the ByteArray."
	self cCode: [] inSmalltalk:
		[| m |
		m := ByteArray new: 16.
		CogBlockMethodSurrogate64 new
			at: 0 memory: m headerSize: 8 cogit: nil;
			cpicHasMNUCaseOrCMIsFullBlock: true.
		self assert: m = #[0 0 0 0 0 0 0 0 16 0 0 0 0 0 0 0 ].
		self assert: (m at: objectMemory baseHeaderSize + 1) = 16].
	aBlock value: 16 value: objectMemory baseHeaderSize + 1 "zero-relative"
]

{ #category : #'trait candidates' }
DruidJIT >> cacheTagIsMarked: cacheTag [
	"Answer if the cacheTag is not unmarked, i.e. answer true for compact class
	 indices and immediates; only answer false for unmarked objects.  In Spur
	 linked send cache tags are class indices so effectively they're always marked."
	^true
]

{ #category : #'trait candidates' }
DruidJIT >> checkValidObjectReference: anOop [
	^(objectMemory isImmediate: anOop) not
	   and: [(objectMemory heapMapAtWord: (self pointerForOop: anOop)) ~= 0]
]

{ #category : #'trait candidates' }
DruidJIT >> checkValidOopReference: anOop [
	^(objectMemory isImmediate: anOop)
	   or: [(objectMemory heapMapAtWord: (self pointerForOop: anOop)) ~= 0]
]

{ #category : #'trait candidates' }
DruidJIT >> classForInlineCacheTag: classIndex [
	^objectMemory classOrNilAtIndex: classIndex
]

{ #category : #'trait candidates' }
DruidJIT >> couldBeObject: literal [
	^(objectMemory isNonImmediate: literal)
	  and: [self oop: literal isGreaterThanOrEqualTo: objectMemory startOfMemory]
]

{ #category : #'trait candidates' }
DruidJIT >> genActiveContextTrampolineLarge: isLarge inBlock: isInBlock called: aString [
	<var: #aString type: #'char *'>
	"Create a trampoline to answer the active context that will
	 answer it if a frame is already married, and create it otherwise.
	 Assume numArgs is in SendNumArgsReg and ClassReg is free."
	| startAddress |
	startAddress := self methodZoneBase.
	self zeroOpcodeIndex.
	self genGetActiveContextLarge: isLarge inBlock: isInBlock.
	self outputInstructionsForGeneratedRuntimeAt: startAddress.
	self recordGeneratedRunTime: aString address: startAddress.
	self recordRunTimeObjectReferences.
	^startAddress
]

{ #category : #'trait candidates' }
DruidJIT >> genCheckRememberedBitOf: objReg scratch: scratchReg [
	"Check the remembered bit of the object in objReg; answer the jump taken if the bit is already set.
	 Only need to fetch the byte containing it, which reduces the size of the mask constant."
	| rememberedBitByteOffset mask |
	rememberedBitByteOffset := self backEnd isBigEndian
									ifTrue: [objectMemory baseHeaderSize - 1 - (objectMemory rememberedBitShift // 8)]
									ifFalse:[objectMemory rememberedBitShift // 8].
	mask := 1 << (objectMemory rememberedBitShift \\ 8).
	self MoveMb: rememberedBitByteOffset r: objReg R: scratchReg.
	self TstCq: mask R: scratchReg.
	^self JumpNonZero: 0
]

{ #category : #'trait candidates' }
DruidJIT >> genConvertIntegerToSmallIntegerInReg: reg [

	self LogicalShiftLeftCq: objectMemory numTagBits R: reg.
	self AddCq: 1 R: reg.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genCreateFullClosure: compiledBlock numArgs: numArgs numCopied: numCopied ignoreContext: ignoreContext contextNumArgs: contextNumArgs large: contextIsLarge inBlock: contextIsBlock [
	"Create a full closure with the given values."
	| numSlots byteSize header skip |
	<var: #skip type: #'AbstractInstruction *'>

	"First get thisContext into ReceiverResultReg and thence in ClassReg."
	ignoreContext
		ifTrue: [ self genMoveNilR: ClassReg ]
		ifFalse: 
			[self genGetActiveContextNumArgs: contextNumArgs large: contextIsLarge inBlock: contextIsBlock.
			self MoveR: ReceiverResultReg R: ClassReg ].
	
	numSlots := FullClosureFirstCopiedValueIndex + numCopied.
	byteSize := objectMemory smallObjectBytesForSlots: numSlots.
	self assert: ClassFullBlockClosureCompactIndex ~= 0.
	header := objectMemory
					headerForSlots: numSlots
					format: objectMemory indexablePointersFormat
					classIndex: ClassFullBlockClosureCompactIndex.
	self MoveAw: objectMemory freeStartAddress R: ReceiverResultReg.
	self genStoreHeader: header intoNewInstance: ReceiverResultReg using: TempReg.
	self
		LoadEffectiveAddressMw: byteSize r: ReceiverResultReg R: TempReg;
		MoveR: TempReg Aw: objectMemory freeStartAddress;
		CmpCq: objectMemory getScavengeThreshold R: TempReg.
	skip := self JumpBelow: 0.
	self CallRT: ceScheduleScavengeTrampoline.
	skip jmpTarget: self Label.

	self
		MoveR: ClassReg Mw: FullClosureOuterContextIndex * objectMemory bytesPerOop + objectMemory baseHeaderSize r: ReceiverResultReg;
		genMoveConstant: compiledBlock R: TempReg;
		MoveR: TempReg Mw: FullClosureCompiledBlockIndex * objectMemory bytesPerOop + objectMemory baseHeaderSize r: ReceiverResultReg;
		MoveCq: (objectMemory integerObjectOf: numArgs) R: TempReg;
		MoveR: TempReg Mw: FullClosureNumArgsIndex * objectMemory bytesPerOop + objectMemory baseHeaderSize r: ReceiverResultReg.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genEnsureObjInRegNotForwarded: reg scratchReg: scratch [
	"Make sure that the object in reg is not forwarded.  This routine assumes the object will
	 never be forwarded to an immediate, as it is used to unforward  literal variables (associations). 
	 Use the fact that isForwardedObjectClassIndexPun is a power of two to save an instruction."
	| loop ok |
	<var: #ok type: #'AbstractInstruction *'>
	<var: #loop type: #'AbstractInstruction *'>
	self assert: reg ~= scratch.
	loop := self Label.
	"notionally
		self genGetClassIndexOfNonImm: reg into: scratch.
		cogit CmpCq: objectMemory isForwardedObjectClassIndexPun R: TempReg.
	 but the following is an instruction shorter:"
	self MoveMw: 0 r: reg R: scratch.
	self
		AndCq: objectMemory classIndexMask - objectMemory isForwardedObjectClassIndexPun
		R: scratch.
	ok := self JumpNonZero:  0.
	self genLoadSlot: 0 sourceReg: reg destReg: reg.
	self Jump: loop.
	ok jmpTarget: self Label.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genEnsureOopInRegNotForwarded: reg scratchReg: scratch [
	^ self 
		genEnsureOopInRegNotForwarded: reg 
		scratchReg: scratch 
		jumpBackTo: self Label "label is just before the forwarder check"
]

{ #category : #'trait candidates' }
DruidJIT >> genEnsureOopInRegNotForwarded: reg scratchReg: scratch ifForwarder: fwdJumpTarget ifNotForwarder: nonFwdJumpTargetOrZero [
	"Make sure that the oop in reg is not forwarded.  
	 Use the fact that isForwardedObjectClassIndexPun is a power of two to save an instruction."
	| imm ok finished |
	self assert: reg ~= scratch.
	imm := self genJumpImmediate: reg.
	"notionally
		self genGetClassIndexOfNonImm: reg into: scratch.
		cogit CmpCq: objectMemory isForwardedObjectClassIndexPun R: TempReg.
	 but the following is an instruction shorter:"
	self MoveMw: 0 r: reg R: scratch.
	self
		AndCq: objectMemory classIndexMask - objectMemory isForwardedObjectClassIndexPun
		R: scratch.
	ok := self JumpNonZero: 0.
	self genLoadSlot: 0 sourceReg: reg destReg: reg.
	self Jump: fwdJumpTarget.
	finished := nonFwdJumpTargetOrZero asUnsignedInteger = 0
					ifTrue: [self Label]
					ifFalse: [nonFwdJumpTargetOrZero].
	imm jmpTarget: (ok jmpTarget: finished).
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genEnsureOopInRegNotForwarded: reg scratchReg: scratch jumpBackTo: instruction [
	<var: #instruction type: #'AbstractInstruction *'>
	<inline: true>
	^ self 
		genEnsureOopInRegNotForwarded: reg 
		scratchReg: scratch 
		ifForwarder: instruction
		ifNotForwarder: 0
]

{ #category : #'trait candidates' }
DruidJIT >> genEnsureOopInRegNotForwarded: reg scratchReg: scratch updatingSlot: index in: objReg [
	"Make sure that the oop in reg is not forwarded, updating the slot in objReg with the value."
	| loop imm ok |
	<var: #ok type: #'AbstractInstruction *'>
	<var: #imm type: #'AbstractInstruction *'>
	<var: #loop type: #'AbstractInstruction *'>
	"Open-code
		self genEnsureOopInRegNotForwarded: reg
			scratchReg: scratch
			updatingMw: index * objectMemory wordSize + objectMemory baseHeaderSize
			r: objReg.
	 to avoid calling the store check unless the receiver is forwarded."
	self assert: (reg ~= scratch and: [objReg ~= scratch]).
	loop := self Label.
	imm := self genJumpImmediate: reg.
	"notionally
		self genGetClassIndexOfNonImm: reg into: scratch.
		cogit CmpCq: objectMemory isForwardedObjectClassIndexPun R: TempReg.
	 but the following is an instruction shorter:"
	self MoveMw: 0 r: reg R: scratch.
	self
		AndCq: objectMemory classIndexMask - objectMemory isForwardedObjectClassIndexPun
		R: scratch.
	ok := self JumpNonZero:  0.
	self genLoadSlot: 0 sourceReg: reg destReg: reg.
	self MoveR: reg Mw: index * objectMemory wordSize + objectMemory baseHeaderSize r: objReg.

	"Check that we're meeting the contract of ceStoreCheckContextReceiverTrampoline."
	self assert: (reg = Arg0Reg and: [scratch = TempReg and: [objReg = ReceiverResultReg]]).
	self CallRT: ceStoreCheckContextReceiverTrampoline.

	self Jump: loop.
	ok jmpTarget: (imm jmpTarget: self Label).
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genGetActiveContextLarge: isLarge inBlock: isInBlock [
	"Create a trampoline to answer the active context that will
	 answer it if a frame is already married, and create it otherwise.
	 Assume numArgs is in SendNumArgsReg and ClassReg is free."
	| header slotSize jumpSingle loopHead jumpNeedScavenge continuation exit |
	<var: #jumpNeedScavenge type: #'AbstractInstruction *'>
	<var: #continuation type: #'AbstractInstruction *'>
	<var: #jumpSingle type: #'AbstractInstruction *'>
	<var: #loopHead type: #'AbstractInstruction *'>
	<var: #exit type: #'AbstractInstruction *'>
	self "load the flag; stash it in both TempReg & ClassReg; do the compare (a prime candidated for use of AndCq:R:R:)"
		MoveMw: FoxMethod r: FPReg R: ClassReg;
		AndCq: MFMethodFlagHasContextFlag R: ClassReg R: TempReg.
	jumpSingle := self JumpZero: 0. "jump if flag bit not set"
	self "since the flag bit was set, get the context in the receiver reg and return"
		MoveMw: FoxThisContext r: FPReg R: ReceiverResultReg;
		RetN: 0.
	jumpSingle jmpTarget: self Label.

	"OK, it doesn't exist; instantiate and initialize it"
	"set the hasContext flag; See CoInterpreter class>>initializeFrameIndices"
	self
		OrCq: MFMethodFlagHasContextFlag R: ClassReg;
		MoveR: ClassReg Mw: FoxMethod r: FPReg.
	"now get the home CogMethod into ClassReg and save for post-instantiation."
	isInBlock caseOf: {
	[InFullBlock]	-> [self SubCq: 3 R: ClassReg]. "-3 is -(hasContext+isBlock) flags"
	[0]				-> [self SubCq: 1 R: ClassReg]. "-1 is hasContext flag" }.

	"instantiate the context..."
	slotSize := isLarge ifTrue: [LargeContextSlots] ifFalse: [SmallContextSlots].
	header := objectMemory
					headerForSlots: slotSize
					format: objectMemory indexablePointersFormat
					classIndex: ClassMethodContextCompactIndex.
	self flag: #endianness.
	self MoveAw: objectMemory freeStartAddress R: ReceiverResultReg.
	self genStoreHeader: header intoNewInstance: ReceiverResultReg using: TempReg.
	self
		MoveR: ReceiverResultReg R: TempReg;
		AddCq: (objectMemory smallObjectBytesForSlots: slotSize) R: TempReg;
		MoveR: TempReg Aw: objectMemory freeStartAddress;
		CmpCq: objectMemory getScavengeThreshold R: TempReg.
	jumpNeedScavenge := self JumpAboveOrEqual: 0.

	"Now initialize the fields of the context.  See CoInterpreter>>marryFrame:SP:copyTemps:"
	"sender gets frame pointer as a SmallInteger"
	continuation :=
	self MoveR: FPReg R: TempReg.
	self genSetSmallIntegerTagsIn: TempReg.
	self MoveR: TempReg Mw: objectMemory baseHeaderSize + (SenderIndex * objectMemory bytesPerOop) r: ReceiverResultReg.

	"pc gets frame caller as a SmallInteger"
	self MoveMw: FoxSavedFP r: FPReg R: TempReg.
	self genSetSmallIntegerTagsIn: TempReg.
	self MoveR: TempReg Mw: objectMemory baseHeaderSize + (InstructionPointerIndex * objectMemory bytesPerOop) r: ReceiverResultReg.

	"Set the method field, freeing up ClassReg again, and frame's context field,"
	self
		MoveMw: (self offset: CogMethod of: #methodObject) r: ClassReg R: TempReg;
		MoveR: TempReg Mw: objectMemory baseHeaderSize + (MethodIndex * objectMemory wordSize) r: ReceiverResultReg;
		MoveR: ReceiverResultReg Mw: FoxThisContext r: FPReg.

	"Now compute stack pointer; this is stackPointer (- 1 for return pc if a CISC) - framePointer - wordSize (1 each for saved pc, method, context, receiver) + 1 (1-relative) + numArgs"
	"TPR note - the code here is actually doing
	context stackPointer := ((((fp - sp) / wordSize) - [3|4]) + num args) asSmallInteger"
	self
		MoveR: FPReg R: TempReg;
		SubR: SPReg R: TempReg;
		LogicalShiftRightCq: self log2BytesPerWord R: TempReg;
		SubCq: (self backEnd hasLinkRegister ifTrue: [3] ifFalse: [4]) R: TempReg;
		AddR: SendNumArgsReg R: TempReg.
	self genConvertIntegerToSmallIntegerInReg: TempReg.
	self MoveR: TempReg Mw: objectMemory baseHeaderSize + (StackPointerIndex * objectMemory bytesPerOop) r: ReceiverResultReg.

	"Set closureOrNil to either the stacked receiver or nil"
	isInBlock > 0
		ifTrue:
			[self
				MoveR: SendNumArgsReg R: TempReg;
				AddCq: 2 R: TempReg; "+2 for saved fp and saved pc"
				MoveXwr: TempReg R: FPReg R: TempReg]
		ifFalse:
			[self genMoveNilR: TempReg].
	self MoveR: TempReg Mw: objectMemory baseHeaderSize + (ClosureIndex * objectMemory bytesPerOop) r: ReceiverResultReg.

	"Set the receiver"
	self
		MoveMw: FoxMFReceiver r: FPReg R: TempReg;
		MoveR: TempReg Mw: objectMemory baseHeaderSize + (ReceiverIndex * objectMemory bytesPerOop) r: ReceiverResultReg.

	"Now copy the arguments.  This is tricky because of the shortage of registers,.  ClassReg ranges
	 from 1 to numArgs (SendNumArgsReg), and from ReceiverIndex + 1 to ReceiverIndex + numArgs.
	 1 to: numArgs do:
		[:i|
		temp := longAt(FPReg + ((SendNumArgs - i + 2) * wordSize)). +2 for saved pc and savedfp
		longAtput(FPReg + FoxMFReceiver + (i * wordSize), temp)]"
	"TPR note: this is a prime candidate for passing off to the backend to do at least faintly optimal code"
	self MoveCq: 1 R: ClassReg.
	loopHead := self CmpR: SendNumArgsReg R: ClassReg.
	exit := self JumpGreater: 0.
	self
		MoveR: SendNumArgsReg R: TempReg;
		SubR: ClassReg R: TempReg;
		AddCq: 2 R: TempReg; "+2 for saved fp and saved pc"
		MoveXwr: TempReg R: FPReg R: TempReg;
		AddCq: ReceiverIndex + (objectMemory baseHeaderSize / objectMemory wordSize) R: ClassReg; "Now convert ClassReg from frame index to context index"
		MoveR: TempReg Xwr: ClassReg R: ReceiverResultReg;
		SubCq: ReceiverIndex + (objectMemory baseHeaderSize / objectMemory wordSize) - 1 R: ClassReg; "convert back adding 1 ;-)"
		Jump: loopHead.
	exit jmpTarget: self Label.

	"Finally nil or copy the non-argument temps.
	 ClassReg := FPReg + FoxMFReceiver.
	 SendNumArgsReg := SendNumArgsReg+ReceiverIndex.
	 [ClassReg := ClassReg - wordSize.
	  backEnd hasLinkRegister
			ifTrue: [ClassReg > SPReg]
			ifFalse: [ClassReg >= SPReg]] whileTrue:
		[receiver[SendNumArgsReg] := *ClassReg.
		 SendNumArgsReg := SendNumArgsReg + 1]]"
	coInterpreter marryFrameCopiesTemps ifFalse:
		[self MoveCq: objectMemory nilObject R: TempReg].
	self
		MoveR: FPReg R: ClassReg;
		AddCq: FoxMFReceiver R: ClassReg;
		AddCq: ReceiverIndex + 1 + (objectMemory baseHeaderSize / objectMemory wordSize) R: SendNumArgsReg.
	loopHead :=
	self SubCq: objectMemory wordSize R: ClassReg.
	self CmpR: SPReg R: ClassReg.
	"If on a CISC there's a retpc for the trampoline call on top of stack; if on a RISC there isn't."
	exit := self backEnd hasLinkRegister
				ifTrue: [self JumpBelow: 0]
				ifFalse: [self JumpBelowOrEqual: 0].
	coInterpreter marryFrameCopiesTemps ifTrue:
		[self MoveMw: 0 r: ClassReg R: TempReg].
	self
		MoveR: TempReg Xwr: SendNumArgsReg R: ReceiverResultReg;
		AddCq: 1 R: SendNumArgsReg;
		Jump: loopHead.
	exit jmpTarget: self Label.

	self RetN: 0.
	
	jumpNeedScavenge jmpTarget: self Label.
	self backEnd saveAndRestoreLinkRegAround:
		[self
			CallRT: ceScheduleScavengeTrampoline
			registersToBeSavedMask: (self registerMaskFor: ReceiverResultReg and: SendNumArgsReg and: ClassReg)].
	self Jump: continuation.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genGetActiveContextNumArgs: numArgs large: isLargeContext inBlock: isInBlock [
	"Get the active context into ReceiverResultReg, creating it if necessary."
	| routine |
	routine := isLargeContext
				ifFalse: [isInBlock caseOf: {
						[0]				-> [ceSmallActiveContextInMethodTrampoline].
						[InFullBlock]	-> [ceSmallActiveContextInFullBlockTrampoline] }]
				ifTrue: [isInBlock caseOf: {
						[0]				-> [ceLargeActiveContextInMethodTrampoline].
						[InFullBlock]	-> [ceLargeActiveContextInFullBlockTrampoline] }].
	self
		MoveCq: numArgs R: SendNumArgsReg;
		CallRT: routine.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genGetClassObjectOf: instReg into: destReg scratchReg: scratchReg instRegIsReceiver: instRegIsReceiver [
	"Fetch the instance's class into destReg.  If the instance is not the receiver and is forwarded, follow forwarding."
	| jumpIsImm jumpNotForwarded loop |
	<var: #jumpIsImm type: #'AbstractInstruction *'>
	<var: #jumpNotForwarded type: #'AbstractInstruction *'>
	<var: #loop type: #'AbstractInstruction *'>
	(instReg = destReg or: [instReg = scratchReg or: [destReg = scratchReg]]) ifTrue:
		[^BadRegisterSet].
	loop := self MoveR: instReg R: scratchReg.
	self AndCq: objectMemory tagMask R: scratchReg.
	jumpIsImm := self JumpNonZero: 0.
	self flag: #endianness.
	"Get least significant half of header word in destReg"
	self MoveMw: 0 r: instReg R: scratchReg.
	"mask off class index"
	self AndCq: objectMemory classIndexMask R: scratchReg.
	instRegIsReceiver ifFalse:
		["if it is forwarded..."
		self CmpCq: objectMemory isForwardedObjectClassIndexPun R: scratchReg.
		jumpNotForwarded := self JumpNonZero: 0.
		"...follow the forwarding pointer and loop to fetch its classIndex"
		self MoveMw: objectMemory baseHeaderSize r: instReg R: instReg.
		self Jump: loop.
		jumpNotForwarded jmpTarget: self Label].
	jumpIsImm jmpTarget:
	(self MoveR: scratchReg R: destReg).
	scratchReg = TempReg
		ifTrue:
			[self PushR: instReg.
			 self genGetClassObjectOfClassIndex: destReg into: instReg scratchReg: TempReg.
			 self MoveR: instReg R: destReg.
			 self PopR: instReg]
		ifFalse:
			[self genGetClassObjectOfClassIndex: destReg into: scratchReg scratchReg: TempReg.
			 self MoveR: scratchReg R: destReg].
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genGetClassObjectOfClassIndex: instReg into: destReg scratchReg: scratchReg [
	"Fetch the class object whose index is in instReg into destReg.
	 It is non-obvious, but the Cogit assumes loading a class does not involve
	 a runtime call, so do not call classAtIndex:"
	self assert: instReg ~= destReg.
	self assert: instReg ~= scratchReg.
	self assert: destReg ~= scratchReg.
	self
		MoveR: instReg R: scratchReg;
		LogicalShiftRightCq: objectMemory classTableMajorIndexShift R: scratchReg;
		LogicalShiftLeftCq: objectMemory shiftForWord R: scratchReg.
	self assert: (self shouldAnnotateObjectReference: objectMemory classTableRootObj) not.
	(self backEnd isWithinMwOffsetRange: objectMemory classTableRootObj + objectMemory baseHeaderSize)
		ifTrue: [self MoveMw: objectMemory classTableRootObj + objectMemory baseHeaderSize r: scratchReg R: destReg]
		ifFalse: [self
					AddCq: objectMemory classTableRootObj R: scratchReg;
					MoveMw: objectMemory baseHeaderSize r: scratchReg R: destReg].
	self
		MoveR: instReg R: scratchReg;
		AndCq: objectMemory classTableMinorIndexMask R: scratchReg;
		AddCq: objectMemory baseHeaderSize >> objectMemory shiftForWord R: scratchReg;
		MoveXwr: scratchReg R: destReg R: destReg.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genGetClassTagOf: instReg into: destReg scratchReg: scratchReg [
	^self genGetInlineCacheClassTagFrom: instReg into: destReg forEntry: true
]

{ #category : #'trait candidates' }
DruidJIT >> genGetInlineCacheClassTagFrom: sourceReg into: destReg forEntry: forEntry [
	"Extract the inline cache tag for the object in sourceReg into destReg. The inline
	 cache tag for a given object is the value loaded in inline caches to distinguish
	 objects of different classes.  In Spur this is either the tags for immediates, or
	 the receiver's classIndex.  Answer the label for the start of the sequence."
	| jumpImm entryLabel |
	<var: #jumpImm type: #'AbstractInstruction *'>
	<var: #entryLabel type: #'AbstractInstruction *'>
	forEntry ifTrue:
		[ self AlignmentNops: objectMemory wordSize].
	entryLabel := self Label.
	self AndCq: objectMemory tagMask R: sourceReg R: destReg.
	jumpImm := self JumpNonZero: 0.
	"Get least significant half of header word in destReg"
	self flag: #endianness.
	self MoveMw: 0 r: sourceReg R: destReg.
	self AndCq: objectMemory classIndexMask R: destReg.

	"The entry and the noCheckEntry (that will generated after) need to be aligned differently.
	We do that by forcing some odd number of extra Nop operations here.
	One Nop is not enough because that causes x86-64 entries to have the same allignment.
	
	In ARM64 all instructions are 4 byte long, thus 3 Nops make 
	   - the entry to be aligned to 8 bytes and
	   - the no check entry aligned to 4 bytes.
	
	In x86-64 instruction size is variable, and 3 Nops take 3 bytes."
	forEntry ifTrue: [ 
		self Nop.
		self Nop.
		self Nop.
	].

	jumpImm jmpTarget: self Label.
	^entryLabel
]

{ #category : #'trait candidates' }
DruidJIT >> genInlinedIdenticalOrNotIfGuts: orNot [
	<inline: true>

	^ self genForwardersInlinedIdenticalOrNotIf: orNot
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpBaseHeaderImmutable: baseHeaderReg [
	"baseHeader holds at least the least significant 32 bits of the object"
	<returnTypeC: #'AbstractInstruction *'>
	<option: #IMMUTABILITY>
	<inline: true>
	
	self  TstCq: objectMemory immutableBitMask R: baseHeaderReg.
	^ self JumpNonZero: 0
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpBaseHeaderMutable: baseHeaderReg [
	"baseHeader holds at least the least significant 32 bits of the object"
	<returnTypeC: #'AbstractInstruction *'>
	<option: #IMMUTABILITY>
	<inline: true>
	self TstCq: objectMemory immutableBitMask R: baseHeaderReg.
	^ self JumpZero: 0
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpImmediate: aRegister [
	<returnTypeC: #'AbstractInstruction *'>

	self TstCq: objectMemory tagMask R: aRegister.
	^ self JumpNonZero: 0
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpImmutable: sourceReg scratchReg: scratchReg [
	<returnTypeC: #'AbstractInstruction *'>
	<option: #IMMUTABILITY>
	self MoveMw: 0 r: sourceReg R: scratchReg. 
	^ self genJumpBaseHeaderImmutable: scratchReg
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpInOldSpace: reg [
	"Jump if reg is old."
	<inline: true>
	^ self
		CmpCq: objectMemory storeCheckBoundary R: reg; "N.B. FLAGS := destReg - scratchReg"
		JumpAboveOrEqual: 0
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpMutable: sourceReg scratchReg: scratchReg [
	<returnTypeC: #'AbstractInstruction *'>
	<option: #IMMUTABILITY>

	self MoveMw: 0 r: sourceReg R: scratchReg. 
	^ self genJumpBaseHeaderMutable: scratchReg
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpNotSmallInteger: reg [
	"Generate a compare and branch to test if aRegister contains other than a SmallInteger."
	^ self
		TstCq: objectMemory smallIntegerTag R: reg;
		JumpZero: 0
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpNotSmallIntegerInScratchReg: aRegister [
	<inline: true>
	^self genJumpNotSmallInteger: aRegister
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpNotSmallIntegersIn: aRegister and: bRegister scratch: scratchRegister [
	"Generate a compare and branch to test if aRegister and bRegister contains other than SmallIntegers,
	 i.e. don't branch if both aRegister and bRegister contain SmallIntegers.
	 Answer the jump.  Destroy scratchRegister if required."
	<returnTypeC: #'AbstractInstruction *'>
	<inline: true>
	self
		MoveR: aRegister R: scratchRegister;
		AndR: bRegister R: scratchRegister.
	^self genJumpNotSmallIntegerInScratchReg: scratchRegister
]

{ #category : #'trait candidates' }
DruidJIT >> genLoadSlot: index sourceReg: sourceReg destReg: destReg [
	
	self
		MoveMw: index * objectMemory wordSize + objectMemory baseHeaderSize
		r: sourceReg
		R: destReg.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genNewArrayOfSize: size initialized: initialized [
	"Generate a call to code that allocates a new Array of size.
	 The Array should be initialized with nils iff initialized is true.
	 The size arg is passed in SendNumArgsReg, the result
	 must come back in ReceiverResultReg."
	| header skip |
	<var: #skip type: #'AbstractInstruction *'>
	self assert: size < objectMemory numSlotsMask.
	header := objectMemory
					headerForSlots: size
					format: objectMemory arrayFormat
					classIndex: ClassArrayCompactIndex.
	self MoveAw: objectMemory freeStartAddress R: ReceiverResultReg.
	self genStoreHeader: header intoNewInstance: ReceiverResultReg using: TempReg.
	(initialized and: [size > 0]) ifTrue:
		[self genMoveConstant: objectMemory nilObject R: TempReg.
		 0 to: size - 1 do:
			[:i| self MoveR: TempReg
					Mw: i * objectMemory wordSize + objectMemory baseHeaderSize
					r: ReceiverResultReg]].
	self
		LoadEffectiveAddressMw: (objectMemory smallObjectBytesForSlots: size) r: ReceiverResultReg R: TempReg;
		MoveR: TempReg Aw: objectMemory freeStartAddress;
		CmpCq: objectMemory getScavengeThreshold R: TempReg.
	skip := self JumpBelow: 0.
	self CallRT: ceScheduleScavengeTrampoline.
	skip jmpTarget: self Label.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genNewHashTrampoline: saveRegs called: name [
	"In non sista VM this is used only from the identityHash primitive, hence only the result of the trampoline, the hash, should be in ReceiverResultReg, other registers can just be ignored.
	In the sista VM, the inlined hash operation requires registers to be saved"
	<inline: true>
	^ self
		genTrampolineFor: #ceNewHashOf:
		called: name
		numArgs: 1
		arg: ReceiverResultReg
		arg: nil
		arg: nil
		arg: nil
		regsToSave: (saveRegs
						ifTrue: [CallerSavedRegisterMask bitClear: (self registerMaskFor: ReceiverResultReg)]
						ifFalse: [self emptyRegisterMask])
		pushLinkReg: true
		resultReg: ReceiverResultReg
		appendOpcodes: false
]

{ #category : #'trait candidates' }
DruidJIT >> genRemoveSmallIntegerTagsInScratchReg: scratchReg [

	self SubCq: 1 R: scratchReg.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genSetSmallIntegerTagsIn: scratchReg [
	self OrCq: 1 R: scratchReg.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreCheckContextReceiverTrampoline [
	"Create a trampoline to store-check the update of the receiver in a closure's
	 outerContext in compileBlockFrameBuild:."
	| startAddress |
	startAddress := self methodZoneBase.
	self zeroOpcodeIndex.
	self genStoreCheckReceiverReg: ReceiverResultReg valueReg: Arg0Reg scratchReg: TempReg inFrame: false.
	self RetN: 0.
	self outputInstructionsForGeneratedRuntimeAt: startAddress.
	self recordGeneratedRunTime: 'ceStoreCheckContextReceiver' address: startAddress.
	self recordRunTimeObjectReferences.
	^startAddress
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreCheckReceiverReg: destReg valueReg: valueReg scratchReg: scratchReg inFrame: inFrame [
	"Generate the code for a store check of valueReg into destReg."
	| jmpImmediate jmpDestYoung jmpSourceOld jmpAlreadyRemembered |
	<var: #jmpImmediate type: #'AbstractInstruction *'>
	<var: #jmpDestYoung type: #'AbstractInstruction *'>
	<var: #jmpSourceOld type: #'AbstractInstruction *'>
	<var: #jmpAlreadyRemembered type: #'AbstractInstruction *'>
	"Is value stored an immediate?  If so we're done"
	jmpImmediate := self genJumpImmediate: valueReg.
	"Get the old/new boundary in scratchReg"
	self MoveCw: objectMemory storeCheckBoundary R: scratchReg.
	"Is target young?  If so we're done"
	self CmpR: scratchReg R: destReg. "N.B. FLAGS := destReg - scratchReg"
	jmpDestYoung := self JumpBelow: 0.
	"Is value stored old?  If so we're done."
	self CmpR: scratchReg R: valueReg. "N.B. FLAGS := valueReg - scratchReg"
	jmpSourceOld := self JumpAboveOrEqual: 0.
	"value is young and target is old.
	 Need to remember this only if the remembered bit is not already set."
	CheckRememberedInTrampoline ifFalse:
		[jmpAlreadyRemembered := self genCheckRememberedBitOf: destReg scratch: scratchReg].
	"Remembered bit is not set.  Call store check to insert dest into remembered table."
	self assert: destReg = ReceiverResultReg.
	self 
		evaluateTrampolineCallBlock: [self CallRT: ceStoreCheckTrampoline]
		protectLinkRegIfNot: inFrame.
	jmpImmediate jmpTarget:
	(jmpDestYoung jmpTarget:
	(jmpSourceOld jmpTarget:
		self Label)).
	CheckRememberedInTrampoline ifFalse:
		[jmpAlreadyRemembered jmpTarget: jmpSourceOld getJmpTarget].
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreCheckTrampoline [
	| jumpSC |
	<var: #jumpSC type: #'AbstractInstruction *'>
	<inline: true>
	CheckRememberedInTrampoline ifTrue:
		[ self zeroOpcodeIndex.
		 jumpSC := self genCheckRememberedBitOf: ReceiverResultReg scratch: self backEnd cResultRegister.
		 self assert: jumpSC opcode = JumpNonZero.
		 jumpSC opcode: JumpZero.
		 self RetN: 0.
		 jumpSC jmpTarget: self Label].
	^ self
		genTrampolineFor: #remember:
		called: 'ceStoreCheckTrampoline'
		numArgs: 1
		arg: ReceiverResultReg
		arg: nil
		arg: nil
		arg: nil
		regsToSave: (CallerSavedRegisterMask bitClear: (self registerMaskFor: ReceiverResultReg))
		pushLinkReg: true
		resultReg: self returnRegForStoreCheck
		appendOpcodes: CheckRememberedInTrampoline
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreHeader: header intoNewInstance: rcvrReg using: scratchReg [
	"Generate the instructions to move the constant header into a new instance pointed to by rcvrReg."
	<inline: true>
	self
		MoveCq: header R: scratchReg;
		MoveR: scratchReg Mw: 0 r: rcvrReg
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreSourceReg: sourceReg slotIndex: index destReg: destReg scratchReg: scratchReg inFrame: inFrame [
	<inline: true>
	self 
		cppIf: IMMUTABILITY
		ifTrue:
			[ ^ self 
				genStoreWithImmutabilityCheckSourceReg: sourceReg 
				slotIndex: index 
				destReg: destReg 
				scratchReg: scratchReg 
				needsStoreCheck: true 
				needRestoreRcvr: false "RcvrResultReg doesn't need to be live across the instructions" ]
		ifFalse: 
			[ ^ self 
				genStoreSourceReg: sourceReg 
				slotIndex: index 
				destReg: destReg 
				scratchReg: scratchReg 
				inFrame: inFrame 
				needsStoreCheck: true ]
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreSourceReg: sourceReg slotIndex: index destReg: destReg scratchReg: scratchReg inFrame: inFrame needsStoreCheck: needsStoreCheck [
	
	self genTraceStores.
	"do the store"
	self MoveR: sourceReg
		   Mw: index * objectMemory wordSize + objectMemory baseHeaderSize
		   r: destReg.
	"now the check. needStoreCheck is false if the JIT has figured out that the value stored does not need the check (immediate, nil, true, false)"
	needsStoreCheck ifTrue: 
		[ ^ self 
			genStoreCheckReceiverReg: destReg 
			valueReg: sourceReg 
			scratchReg: scratchReg 
			inFrame: inFrame ].
	^ 0
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreSourceReg: sourceReg slotIndex: index intoNewObjectInDestReg: destReg [
	"This method is used for unchecked stores in objects after their creation (typically, inlined creation of Array, closures and some temp vectors). 
	Currently there is no need to do the immutability check here"

	self MoveR: sourceReg
		   Mw: index * objectMemory wordSize + objectMemory baseHeaderSize
		   r: destReg.
	^ 0
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreTrampolineCall: instVarIndex [
	<inline: true>
	self assert: IMMUTABILITY.
	instVarIndex >= (NumStoreTrampolines - 1)
		ifTrue: 
			[ self MoveCq: instVarIndex R: TempReg.
			  self CallRT: (ceStoreTrampolines at: NumStoreTrampolines - 1) ]
		ifFalse: 
			[ self CallRT: (ceStoreTrampolines at: instVarIndex) ].
	 self annotateBytecode: self Label
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreTrampolineCalled: trampolineName instVarIndex: instVarIndex [
	"Convention:
	- RcvrResultReg holds the object mutated.
	If immutability failure:
	- TempReg holds the instance variable index mutated 
		if instVarIndex > numDedicatedStoreTrampoline
	- ClassReg holds the value to store
	Registers are not lived across this trampoline as the 
	immutability failure may need new stack frames."
	
	| jumpSC jumpRC |
	<option: #IMMUTABILITY>
	<var: #trampolineName type: #'char *'>
	<var: #jumpSC type: #'AbstractInstruction *'>
	<var: #jumpRC type: #'AbstractInstruction *'>
	<inline: false>
	self zeroOpcodeIndex.
	"SendNumArgsReg is mutated but we don't care as register are not live across the trampoline.
	 There is no reason why registers cannot be saved over the remember: call, but since the
	 immutability check is a suspension point, registers cannot remain live."
	jumpSC := self genJumpMutable: ReceiverResultReg scratchReg: SendNumArgsReg.
	self
		compileTrampolineFor: #ceCannotAssignTo:withIndex:valueToAssign:
		numArgs: 3
		arg: ReceiverResultReg
		arg: (instVarIndex < (NumStoreTrampolines - 1)
				ifTrue: [self trampolineArgConstant: instVarIndex]
				ifFalse: [TempReg])
		arg: ClassReg
		arg: nil
		regsToSave: self emptyRegisterMask
		pushLinkReg: true
		resultReg: NoReg.
		
	"Store check"
	jumpSC jmpTarget: self Label.
	"If on 64-bits and doing the remembered bit test here, we can combine the tests to fetch the header once."
	CheckRememberedInTrampoline ifTrue:
		[objectMemory wordSize = 8
			ifTrue:
				[self TstCq: 1 << objectMemory rememberedBitShift R: SendNumArgsReg.
				 jumpRC := self JumpZero: 0.
				 self RetN: 0]
			ifFalse:
				[jumpRC := self genCheckRememberedBitOf: ReceiverResultReg scratch: SendNumArgsReg.
				 self assert: jumpRC opcode = JumpNonZero.
				 jumpRC opcode: JumpZero.
				 self RetN: 0].
		 jumpRC jmpTarget: self Label].
	^ self genTrampolineFor: #remember:
		called: trampolineName
		numArgs: 1
		arg: ReceiverResultReg
		arg: nil
		arg: nil
		arg: nil
		regsToSave: self emptyRegisterMask
		pushLinkReg: true
		resultReg: NoReg
		appendOpcodes: true
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreWithImmutabilityAndStoreCheckSourceReg: sourceReg slotIndex: index destReg: destReg scratchReg: scratchReg needRestoreRcvr: needRestoreRcvr [ 
	"Store check code is duplicated to use a single trampoline"
	<option: #IMMUTABILITY>
	| immutableJump jmpImmediate jmpDestYoung jmpSourceOld jmpAlreadyRemembered |
	<var: #immutableJump type: #'AbstractInstruction *'>
	<var: #jmpImmediate type: #'AbstractInstruction *'>
	<var: #jmpDestYoung type: #'AbstractInstruction *'>
	<var: #jmpSourceOld type: #'AbstractInstruction *'>
	<var: #jmpAlreadyRemembered type: #'AbstractInstruction *'>

	immutableJump := self genJumpImmutable: destReg scratchReg: scratchReg.
	
	self genTraceStores.
	
	"do the store"
	self MoveR: sourceReg
		   Mw: index * objectMemory wordSize + objectMemory baseHeaderSize
		   r: destReg.
	
	"store check"
	jmpImmediate := self genJumpImmediate: sourceReg.
	"Get the old/new boundary in scratchReg"
	self MoveCw: objectMemory storeCheckBoundary R: scratchReg.
	"Is target young?  If so we're done"
	self CmpR: scratchReg R: destReg. "N.B. FLAGS := destReg - scratchReg"
	jmpDestYoung := self JumpBelow: 0.
	"Is value stored old?  If so we're done."
	self CmpR: scratchReg R: sourceReg. "N.B. FLAGS := valueReg - scratchReg"
	jmpSourceOld := self JumpAboveOrEqual: 0.
	"value is young and target is old.
	 Need to remember this only if the remembered bit is not already set."
	CheckRememberedInTrampoline ifFalse:
		[jmpAlreadyRemembered := self genCheckRememberedBitOf: destReg scratch: scratchReg].
	"Set the inst var index for the benefit of the immutability check. The trampoline will
	 repeat the check to choose between the immutbality violation and the store check."
	immutableJump jmpTarget: self Label.
	self genStoreTrampolineCall: index.
	self voidReceiverOptStatus.
	needRestoreRcvr ifTrue:
		[self putSelfInReceiverResultReg].

	jmpImmediate jmpTarget:
	(jmpDestYoung jmpTarget:
	(jmpSourceOld jmpTarget:
		self Label)).
	CheckRememberedInTrampoline ifFalse:
		[jmpAlreadyRemembered jmpTarget: jmpSourceOld getJmpTarget].
	^ 0
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreWithImmutabilityButNoStoreCheckSourceReg: sourceReg slotIndex: index destReg: destReg scratchReg: scratchReg needRestoreRcvr: needRestoreRcvr [
	"Gen an immutability check with no store check (e.g. assigning an immediate literal)"
	<option: #IMMUTABILITY>
	<var: #mutableJump type: #'AbstractInstruction *'>
	<var: #immutabilityFailure type: #'AbstractInstruction *'>
	| immutabilityFailure mutableJump |
	
	"imm check has its own trampoline"
	mutableJump := self genJumpMutable: destReg scratchReg: scratchReg.
	self genStoreTrampolineCall: index.
	self voidReceiverOptStatus.
	needRestoreRcvr ifTrue:
		[self putSelfInReceiverResultReg].
	immutabilityFailure := self Jump: 0.
	mutableJump jmpTarget: self Label.

	self genTraceStores.
	
	"do the store"
	self MoveR: sourceReg
		   Mw: index * objectMemory wordSize + objectMemory baseHeaderSize
		   r: destReg.
		
	immutabilityFailure jmpTarget: self Label.

	^ 0
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreWithImmutabilityCheckSourceReg: sourceReg slotIndex: index destReg: destReg scratchReg: scratchReg needsStoreCheck: needsStoreCheck needRestoreRcvr: needRestoreRcvr [
	<option: #IMMUTABILITY>
	"We know there is a frame as immutability check requires a frame"
	"needRestoreRcvr has to be true to keep RcvrResultReg live with the receiver in it across the trampoline"
	
	"Trampoline convention..."
	self assert: destReg == ReceiverResultReg.
	self assert: scratchReg == TempReg.
  	self assert: sourceReg == ClassReg.
	
	"The two paths are very different as the trampoline is shared in 1 case so we split here"
	needsStoreCheck
		ifTrue: 
			[ self 
				genStoreWithImmutabilityAndStoreCheckSourceReg: sourceReg 
				slotIndex: index 
				destReg: destReg 
				scratchReg: scratchReg 
				needRestoreRcvr: needRestoreRcvr ]
		ifFalse: 
			[ self 
				genStoreWithImmutabilityButNoStoreCheckSourceReg: sourceReg 
				slotIndex: index 
				destReg: destReg 
				scratchReg: scratchReg 
				needRestoreRcvr: needRestoreRcvr ].
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimAdd [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -1
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimAt [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -17
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimAtEnd [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 0.
	self
		genMarshalledSend:  -22
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimAtPut [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 2.
	self
		genMarshalledSend:  -18
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimBitAnd [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -15
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimBitOr [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -16
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimBitShift [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -13
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimDiv [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -14
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimDivide [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -10
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimDo [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -28
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimEqualSistaV1 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -7
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimGreaterOrEqualSistaV1 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -6
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimGreaterThanSistaV1 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -4
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimIdenticalSistaV1 [
	"AutoGenerated by Druid"

	| jump1 jumpNext t4 t1 b459 jump3 currentBlock t3 t0 b455 jumpTrue jump2 t2 jump4 |
	t0 := self allocateRegNotConflictingWith: 0.
	(self ssValue: 1) moveToReg: t0.
	t1 := self allocateRegNotConflictingWith: 0.
	(self ssValue: 0) moveToReg: t1.
	t2 := self allocateRegNotConflictingWith: 0.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: TempReg R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveM64: 8 r: TempReg R: t2.
	self MoveR: t2 R: t0.
	b455 := self Label.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveM64: 0 r: TempReg R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	t3 := self allocateRegNotConflictingWith: 0.
	self MoveR: t1 R: t3.
	self AndCq: 7 R: t3.
	self CmpCq: 0 R: t3.
	jump1 := self JumpZero: 0.
	self MoveCq: 0 R: t3.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: t3.
	self AndCq: 16r3FFFF7 R: t3.
	self CmpCq: 0 R: t3.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t3.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t3.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 0 R: t3.
	jump2 := self JumpNonZero: 0.
	self MoveR: t1 R: t3.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveM64: 8 r: ClassReg R: t3.
	t4 := self allocateRegNotConflictingWith: 0.
	self MoveR: t3 R: t4.
	b459 := self Label.
	self MoveR: t4 R: t3.
	self AndCq: 7 R: t3.
	self CmpCq: 0 R: t3.
	jump2 := self JumpZero: 0.
	self MoveCq: 0 R: t3.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveM64: 0 r: Extra1Reg R: t3.
	self AndCq: 16r3FFFF7 R: t3.
	self CmpCq: 0 R: t3.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t3.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t3.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 0 R: t3.
	jump4 := self JumpNonZero: 0.
	self MoveR: t4 R: t3.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self CmpR: t3 R: t2.
	jump1 := self JumpZero: 0.
	self ssPushConstant: objectMemory falseObject.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self ssPushConstant: objectMemory trueObject.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveM64: 8 r: Extra1Reg R: t3.
	self MoveR: t3 R: t4.
	jump4 := self Jump: b459.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: TempReg R: t3.
	self MoveR: t3 R: t0.
	jump3 := self Jump: b455.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimLessOrEqualSistaV1 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -5
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimLessThanSistaV1 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -3
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimMakePoint [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -12
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimMod [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -11
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimMultiply [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -9
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimNew [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 0.
	self
		genMarshalledSend:  -29
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimNewWithArg [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -30
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimNext [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 0.
	self
		genMarshalledSend:  -20
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimNextPut [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -21
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimNotEqualSistaV1 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -8
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimNotIdenticalSistaV1 [
	"AutoGenerated by Druid"

	| jump1 jumpNext t4 t1 b459 jump3 currentBlock t3 t0 b455 jumpTrue jump2 t2 jump4 |
	t0 := self allocateRegNotConflictingWith: 0.
	(self ssValue: 1) moveToReg: t0.
	t1 := self allocateRegNotConflictingWith: 0.
	(self ssValue: 0) moveToReg: t1.
	t2 := self allocateRegNotConflictingWith: 0.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: TempReg R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveM64: 8 r: TempReg R: t2.
	self MoveR: t2 R: t0.
	b455 := self Label.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveM64: 0 r: TempReg R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	t3 := self allocateRegNotConflictingWith: 0.
	self MoveR: t1 R: t3.
	self AndCq: 7 R: t3.
	self CmpCq: 0 R: t3.
	jump1 := self JumpZero: 0.
	self MoveCq: 0 R: t3.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: t3.
	self AndCq: 16r3FFFF7 R: t3.
	self CmpCq: 0 R: t3.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t3.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t3.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 0 R: t3.
	jump2 := self JumpNonZero: 0.
	self MoveR: t1 R: t3.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveM64: 8 r: ClassReg R: t3.
	t4 := self allocateRegNotConflictingWith: 0.
	self MoveR: t3 R: t4.
	b459 := self Label.
	self MoveR: t4 R: t3.
	self AndCq: 7 R: t3.
	self CmpCq: 0 R: t3.
	jump2 := self JumpZero: 0.
	self MoveCq: 0 R: t3.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveM64: 0 r: Extra1Reg R: t3.
	self AndCq: 16r3FFFF7 R: t3.
	self CmpCq: 0 R: t3.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t3.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t3.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 0 R: t3.
	jump4 := self JumpNonZero: 0.
	self MoveR: t4 R: t3.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self CmpR: t3 R: t2.
	jump1 := self JumpNonZero: 0.
	self ssPushConstant: objectMemory falseObject.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self ssPushConstant: objectMemory trueObject.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveM64: 8 r: Extra1Reg R: t3.
	self MoveR: t3 R: t4.
	jump4 := self Jump: b459.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: TempReg R: t3.
	self MoveR: t3 R: t0.
	jump3 := self Jump: b455.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimPointX [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 0.
	self
		genMarshalledSend:  -31
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimPointY [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 0.
	self
		genMarshalledSend:  -32
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimSize [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 0.
	self
		genMarshalledSend:  -19
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimSubtract [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -2
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimValue [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 0.
	self
		genMarshalledSend:  -26
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimValueWithArg [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend:  -27
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveAdd [
	"AutoGenerated by Druid"

	| jump1 jump2 currentBlock |
	self mclassIsSmallInteger ifFalse: [ ^ UnimplementedPrimitive ].
	self TstCq: 1 R: Arg0Reg.
	jump1 := self JumpZero: 0.
	self MoveR: Arg0Reg R: TempReg.
	self AddCq:  -1 R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AddR: ClassReg R: TempReg.
	jump2 := self JumpOverflow: 0.
	self MoveR: TempReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveAt [
	"AutoGenerated by Druid"

	| jump1 jump10 jumpNext jump9 jump6 jump3 currentBlock jump8 jump5 jumpTrue jump2 jump7 jump4 |
	self TstCq: 7 R: ReceiverResultReg.
	jump1 := self JumpNonZero: 0.
	self MoveCq: 1 R: TempReg.
	self MoveR: Arg0Reg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self CmpCq: 0 R: TempReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: ClassReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: ClassReg.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: TempReg.
	jump2 := self JumpZero: 0.
	self MoveCq: 0 R: ClassReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpCq: 0 R: ClassReg.
	jump3 := self JumpNonZero: 0.
	self MoveR: Arg0Reg R: ClassReg.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self MoveM64: 0 r: ReceiverResultReg R: TempReg.
	self MoveR: TempReg R: SendNumArgsReg.
	self ArithmeticShiftRightCq: 24 R: SendNumArgsReg.
	self AndCq: 31 R: SendNumArgsReg.
	self MoveMb: 7 r: ReceiverResultReg R: Extra0Reg.
	self AndCq: 255 R: Extra0Reg.
	self CmpCq: 255 R: Extra0Reg.
	jump2 := self JumpZero: 0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveM64: -8 r: ReceiverResultReg R: Extra0Reg.
	self LogicalShiftLeftCq: 8 R: Extra0Reg.
	self ArithmeticShiftRightCq: 8 R: Extra0Reg.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 5 R: SendNumArgsReg.
	jump4 := self JumpLessOrEqual: 0.
	self CmpCq: 16 R: SendNumArgsReg.
	jump2 := self JumpGreaterOrEqual: 0.
	self CmpCq: 12 R: SendNumArgsReg.
	jump5 := self JumpGreaterOrEqual: 0.
	self CmpCq: 10 R: SendNumArgsReg.
	jump6 := self JumpGreaterOrEqual: 0.
	self CmpCq: 9 R: SendNumArgsReg.
	jump7 := self JumpZero: 0.
	self MoveCq: 0 R: Extra0Reg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self LogicalShiftLeftCq: 1 R: Extra0Reg.
	self MoveR: SendNumArgsReg R: Extra1Reg.
	self AndCq: 1 R: Extra1Reg.
	self SubR: Extra1Reg R: Extra0Reg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 9 R: SendNumArgsReg.
	jumpTrue := self JumpGreaterOrEqual: 0.
	self MoveCq: 0 R: Extra1Reg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: Extra1Reg.
	jumpNext jmpTarget: self Label.
	self CmpCq: 9 R: SendNumArgsReg.
	jump7 := self JumpGreaterOrEqual: 0.
	self MoveR: Extra0Reg R: Extra1Reg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self LogicalShiftLeftCq: 2 R: Extra0Reg.
	self MoveR: SendNumArgsReg R: Extra1Reg.
	self AndCq: 3 R: Extra1Reg.
	self SubR: Extra1Reg R: Extra0Reg.
	self MoveR: Extra0Reg R: Extra1Reg.
	self CmpCq: 9 R: SendNumArgsReg.
	jumpTrue := self JumpGreaterOrEqual: 0.
	self MoveCq: 0 R: Extra2Reg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: Extra2Reg.
	jumpNext jmpTarget: self Label.
	self MoveR: Extra1Reg R: Extra0Reg.
	self MoveR: Extra2Reg R: Extra1Reg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: Extra2Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self LogicalShiftLeftCq: 3 R: Extra0Reg.
	self MoveR: SendNumArgsReg R: Extra1Reg.
	self AndCq: 7 R: Extra1Reg.
	self SubR: Extra1Reg R: Extra0Reg.
	self CmpCq: 9 R: SendNumArgsReg.
	jumpTrue := self JumpGreaterOrEqual: 0.
	self MoveCq: 0 R: Extra1Reg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: Extra1Reg.
	jumpNext jmpTarget: self Label.
	self MoveR: Extra0Reg R: Extra2Reg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra1Reg R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: Extra1Reg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self CmpCq: 2 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: Extra2Reg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: Extra2Reg.
	jumpNext jmpTarget: self Label.
	self MoveR: Extra2Reg R: Extra0Reg.
	self MoveR: Extra1Reg R: Extra2Reg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 0 R: Extra0Reg.
	jump7 := self JumpNonZero: 0.
	self CmpCq: 2 R: SendNumArgsReg.
	jump8 := self JumpLess: 0.
	self MoveM64: 0 r: ReceiverResultReg R: Extra1Reg.
	self AndCq: 16r3FFFFF R: Extra1Reg.
	self CmpCq: 31 R: Extra1Reg.
	jump4 := self JumpGreater: 0.
	self CmpCq: 31 R: Extra1Reg.
	jump2 := self JumpZero: 0.
	self CmpCq: 8 R: Extra1Reg.
	jump5 := self JumpZero: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra1Reg R: Extra0Reg.
	self ArithmeticShiftRightCq: 10 R: Extra0Reg.
	self LogicalShiftLeftCq: 3 R: Extra0Reg.
	self MoveM64: objectMemory nilObject + 8 r: Extra0Reg R: Extra0Reg.
	self CmpCq: objectMemory nilObject R: Extra0Reg.
	jump4 := self JumpZero: 0.
	self AndCq: 1023 R: Extra1Reg.
	self LogicalShiftLeftCq: 3 R: Extra1Reg.
	self AddR: Extra1Reg R: Extra0Reg.
	self MoveM64: 8 r: Extra0Reg R: Extra0Reg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveCq: objectMemory nilObject R: Extra0Reg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveCq: objectMemory nilObject R: Extra0Reg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveR: ReceiverResultReg R: Extra0Reg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 24 r: Extra0Reg R: Extra0Reg.
	self ArithmeticShiftRightCq: 3 R: Extra0Reg.
	self AndCq: 16rFFFF R: Extra0Reg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self MoveR: Extra2Reg R: Extra0Reg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveCq: 0 R: Extra0Reg.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self CmpCq: 3 R: SendNumArgsReg.
	jump8 := self JumpZero: 0.
	self MoveCq: 0 R: TempReg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self AndCq: 16r3FFFFF R: TempReg.
	self CmpCq: 36 R: TempReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: TempReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: TempReg.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 0 R: TempReg.
	jump5 := self JumpNonZero: 0.
	self SubR: Extra0Reg R: Extra2Reg.
	self CmpCq: 24 R: SendNumArgsReg.
	jump8 := self JumpGreaterOrEqual: 0.
	self CmpCq: 1 R: ClassReg.
	jump7 := self JumpGreaterOrEqual: 0.
	self MoveCq: 0 R: TempReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpR: Extra2Reg R: ClassReg.
	jumpTrue := self JumpLessOrEqual: 0.
	self MoveCq: 0 R: TempReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: TempReg.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self CmpCq: 0 R: TempReg.
	jump6 := self JumpZero: 0.
	self AddR: Extra0Reg R: ClassReg.
	self CmpCq: 5 R: SendNumArgsReg.
	jump7 := self JumpLessOrEqual: 0.
	self CmpCq: 16 R: SendNumArgsReg.
	jump2 := self JumpGreaterOrEqual: 0.
	self CmpCq: 12 R: SendNumArgsReg.
	jump4 := self JumpGreaterOrEqual: 0.
	self CmpCq: 9 R: SendNumArgsReg.
	jump9 := self JumpZero: 0.
	self MoveCq: 0 R: ReceiverResultReg.
	jump10 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self SubCq: 1 R: ClassReg.
	self LogicalShiftLeftCq: 1 R: ClassReg.
	self MoveR: ReceiverResultReg R: TempReg.
	self AddR: TempReg R: ClassReg.
	self MoveM16: 8 r: ClassReg R: TempReg.
	self AndCq: 16rFFFF R: TempReg.
	self LogicalShiftLeftCq: 3 R: TempReg.
	self AddCq: 1 R: TempReg.
	self MoveR: TempReg R: ReceiverResultReg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveR: ReceiverResultReg R: TempReg.
	self AddR: TempReg R: ClassReg.
	self AddCq:  -1 R: ClassReg.
	self MoveMb: 8 r: ClassReg R: TempReg.
	self AndCq: 255 R: TempReg.
	self LogicalShiftLeftCq: 3 R: TempReg.
	self AddCq: 1 R: TempReg.
	self MoveR: TempReg R: ReceiverResultReg.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self SubCq: 1 R: ClassReg.
	self LogicalShiftLeftCq: 3 R: ClassReg.
	self MoveR: ReceiverResultReg R: TempReg.
	self AddR: TempReg R: ClassReg.
	self MoveM64: 8 r: ClassReg R: TempReg.
	self MoveR: TempReg R: ReceiverResultReg.
	currentBlock := self Label.
	jump10 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveDivide [
	"AutoGenerated by Druid"

	| jump5 jump3 jump1 currentBlock jump4 jump2 |
	self TstCq: 1 R: ReceiverResultReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: TempReg.
	self ArithmeticShiftRightCq: 3 R: TempReg.
	self TstCq: 1 R: Arg0Reg.
	jump2 := self JumpZero: 0.
	self MoveR: Arg0Reg R: ClassReg.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jump3 := self JumpZero: 0.
	self
		DivR: ClassReg
		R: TempReg
		Quo: Extra0Reg
		Rem: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump4 := self JumpNonZero: 0.
	self
		DivR: ClassReg
		R: TempReg
		Quo: Extra0Reg
		Rem: SendNumArgsReg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self ArithmeticShiftRightCq: 60 R: SendNumArgsReg.
	self AddCq: 1 R: SendNumArgsReg.
	self AndCq: 15 R: SendNumArgsReg.
	self CmpCq: 1 R: SendNumArgsReg.
	jump5 := self JumpGreater: 0.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 1 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveEqual [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpZero: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveGreaterOrEqual [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpGreaterOrEqual: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveGreaterThan [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpGreater: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveLessOrEqual [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpLessOrEqual: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveLessThan [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpLess: 0.
	self MoveCq: objectMemory falseObject R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveMultiply [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self TstCq: 1 R: ReceiverResultReg.
	jump1 := self JumpZero: 0.
	self TstCq: 1 R: Arg0Reg.
	jump2 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: TempReg.
	self ArithmeticShiftRightCq: 3 R: TempReg.
	self MoveR: Arg0Reg R: ClassReg.
	self SubCq: 1 R: ClassReg.
	self MulR: ClassReg R: TempReg.
	jump3 := self JumpMultiplyOverflow: 0.
	self AddCq: 1 R: TempReg.
	self MoveR: TempReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveNew [
	"AutoGenerated by Druid"

	| jump1 b391 jumpNext jump6 jump3 currentBlock jump8 jump5 jumpTrue jump2 jump7 jump4 |
	self MoveM64: 24 r: ReceiverResultReg R: TempReg.
	self ArithmeticShiftRightCq: 3 R: TempReg.
	self MoveR: TempReg R: ClassReg.
	self ArithmeticShiftRightCq: 16 R: ClassReg.
	self AndCq: 31 R: ClassReg.
	self CmpCq: 1 R: ClassReg.
	jumpTrue := self JumpLessOrEqual: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	self CmpCq: 1 R: ClassReg.
	jump1 := self JumpLessOrEqual: 0.
	self CmpCq: 5 R: ClassReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 0 R: SendNumArgsReg.
	jump2 := self JumpNonZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveM32: 4 r: ReceiverResultReg R: SendNumArgsReg.
	self AndCq: 16rFFFFFFFF R: SendNumArgsReg.
	self AndCq: 16r3FFFFF R: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump2 := self JumpZero: 0.
	self CmpCq: 0 R: SendNumArgsReg.
	jump3 := self JumpLess: 0.
	self AndCq: 16rFFFF R: TempReg.
	self CmpCq: 255 R: TempReg.
	jump4 := self JumpGreaterOrEqual: 0.
	self CmpCq: 1 R: TempReg.
	jump5 := self JumpLess: 0.
	self MoveCq: 8 R: Extra0Reg.
	self MulR: TempReg R: Extra0Reg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveCq: 8 R: Extra0Reg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self AddCq: 8 R: Extra0Reg.
	self MoveAw: objectMemory freeStartAddress R: Extra1Reg.
	self AddR: Extra0Reg R: Extra1Reg.
	self CmpCq: objectMemory getScavengeThreshold R: Extra1Reg.
	jump6 := self JumpGreater: 0.
	self MoveR: Extra0Reg R: Extra1Reg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self MoveR: TempReg R: Extra2Reg.
	self LogicalShiftLeftCq: 56 R: Extra2Reg.
	self LogicalShiftLeftCq: 24 R: ClassReg.
	self AddR: ClassReg R: Extra2Reg.
	self AddR: SendNumArgsReg R: Extra2Reg.
	self OrCq: 0 R: Extra2Reg.
	self MoveR: Extra2Reg M64: 0 r: Extra0Reg.
	self MoveR: Extra1Reg R: Extra2Reg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: TempReg R: Extra0Reg.
	self ArithmeticShiftRightCq: 56 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump4 := self JumpGreater: 0.
	self MoveCq: 8 R: Extra0Reg.
	self MulR: TempReg R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	self MoveAw: objectMemory freeStartAddress R: Extra2Reg.
	self AddR: Extra0Reg R: Extra2Reg.
	self CmpCq: objectMemory getScavengeThreshold R: Extra2Reg.
	jump7 := self JumpGreater: 0.
	self MoveR: Extra0Reg R: Extra2Reg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self MoveR: TempReg R: Extra1Reg.
	self AddCq: 16rFF00000000000000 R: Extra1Reg.
	self MoveR: Extra1Reg M64: 0 r: Extra0Reg.
	self LogicalShiftLeftCq: 24 R: ClassReg.
	self AddR: SendNumArgsReg R: ClassReg.
	self AddCq: 16rFF00000000000000 R: ClassReg.
	self OrCq: 0 R: ClassReg.
	self MoveR: ClassReg M64: 8 r: Extra0Reg.
	self AddCq: 8 R: Extra0Reg.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveAw: objectMemory freeStartAddress R: Extra1Reg.
	self AddR: Extra2Reg R: Extra1Reg.
	self MoveR: Extra1Reg Aw: objectMemory freeStartAddress.
	self MoveR: Extra0Reg R: Extra1Reg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveCq: 0 R: Extra1Reg.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 0 R: Extra1Reg.
	jump5 := self JumpZero: 0.
	self MoveR: Extra1Reg R: Extra0Reg.
	self AddCq: 8 R: Extra0Reg.
	self MoveCq: 8 R: Extra2Reg.
	self MulR: TempReg R: Extra2Reg.
	self MoveR: Extra1Reg R: TempReg.
	self AddR: Extra2Reg R: TempReg.
	self AddCq: 8 R: TempReg.
	self SubCq: 1 R: TempReg.
	self MoveR: ReceiverResultReg R: Extra2Reg.
	b391 := self Label.
	self CmpR: Extra0Reg R: TempReg.
	jump4 := self JumpGreaterOrEqual: 0.
	self MoveR: Extra2Reg R: ClassReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveCq: objectMemory nilObject R: ClassReg.
	self MoveR: ClassReg M64: 0 r: Extra0Reg.
	self MoveR: Extra0Reg R: ClassReg.
	self AddCq: 8 R: ClassReg.
	self MoveR: ClassReg R: Extra0Reg.
	jump4 := self Jump: b391.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveR: ReceiverResultReg R: ClassReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self MoveR: Extra1Reg R: SendNumArgsReg.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self CmpCq: 0 R: SendNumArgsReg.
	jump1 := self JumpZero: 0.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: ClassReg R: ReceiverResultReg.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveNewWithArg [
	"AutoGenerated by Druid"

	| jump1 jump10 jumpNext jump13 jump9 jump6 jump3 jump12 currentBlock jump8 jump5 jump2 jumpTrue jump11 b986 jump7 jump4 |
	self AddCq: 32 R: SPReg.
	self TstCq: 1 R: Arg0Reg.
	jump1 := self JumpZero: 0.
	self MoveR: Arg0Reg R: TempReg.
	self ArithmeticShiftRightCq: 3 R: TempReg.
	self CmpCq: 0 R: TempReg.
	jump2 := self JumpLess: 0.
	self MoveM64: 24 r: ReceiverResultReg R: ClassReg.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self MoveR: ClassReg R: SendNumArgsReg.
	self ArithmeticShiftRightCq: 16 R: SendNumArgsReg.
	self AndCq: 31 R: SendNumArgsReg.
	self MoveM32: 4 r: ReceiverResultReg R: Extra0Reg.
	self AndCq: 16rFFFFFFFF R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self MoveCq: 0 R: Extra1Reg.
	self CmpCq: 2 R: SendNumArgsReg.
	jump3 := self JumpZero: 0.
	self CmpCq: 3 R: SendNumArgsReg.
	jump4 := self JumpZero: 0.
	self CmpCq: 4 R: SendNumArgsReg.
	jump5 := self JumpZero: 0.
	self CmpCq: 9 R: SendNumArgsReg.
	jump6 := self JumpZero: 0.
	self CmpCq: 10 R: SendNumArgsReg.
	jump7 := self JumpZero: 0.
	self CmpCq: 12 R: SendNumArgsReg.
	jump8 := self JumpZero: 0.
	self CmpCq: 16 R: SendNumArgsReg.
	jump9 := self JumpZero: 0.
	self CmpCq: 0 R: TempReg.
	jumpTrue := self JumpNonZero: 0.
	self MoveCq: 0 R: Extra1Reg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: Extra1Reg.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: TempReg.
	jump10 := self JumpNonZero: 0.
	self CmpCq: 5 R: SendNumArgsReg.
	jumpTrue := self JumpGreater: 0.
	self MoveCq: 0 R: Extra1Reg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: Extra1Reg.
	jumpNext jmpTarget: self Label.
	jump11 := self Jump: 0.
	currentBlock := self Label.
	jump10 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump11 jmpTarget: currentBlock.
	self CmpCq: 0 R: Extra1Reg.
	jump11 := self JumpNonZero: 0.
	self AndCq: 16rFFFF R: ClassReg.
	self MoveCq: objectMemory nilObject R: Extra1Reg.
	jump10 := self Jump: 0.
	currentBlock := self Label.
	jump11 jmpTarget: currentBlock.
	self MoveCq: 0 R: Extra1Reg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	jump11 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self MoveR: TempReg R: ClassReg.
	self AddCq: 7 R: ClassReg.
	self MoveCq: 8 R: Extra2Reg.
	self
		DivR: Extra2Reg
		R: ClassReg
		Quo: ClassReg
		Rem: Extra2Reg.
	self MoveCq: 8 R: Extra2Reg.
	self SubR: TempReg R: Extra2Reg.
	self AndCq: 7 R: Extra2Reg.
	self AddR: Extra2Reg R: SendNumArgsReg.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self MoveR: TempReg R: Extra2Reg.
	self AddCq: 3 R: Extra2Reg.
	self MoveCq: 4 R: ClassReg.
	self
		DivR: ClassReg
		R: Extra2Reg
		Quo: Extra2Reg
		Rem: ClassReg.
	self MoveCq: 4 R: ClassReg.
	self SubR: TempReg R: ClassReg.
	self AndCq: 3 R: ClassReg.
	self AddR: ClassReg R: SendNumArgsReg.
	self MoveR: Extra2Reg R: ClassReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 34 R: Extra0Reg.
	jump7 := self JumpZero: 0.
	self MoveR: TempReg R: ClassReg.
	self AddCq: 1 R: ClassReg.
	self MoveCq: 2 R: Extra2Reg.
	self
		DivR: Extra2Reg
		R: ClassReg
		Quo: ClassReg
		Rem: Extra2Reg.
	self AndCq: 1 R: TempReg.
	self AddR: TempReg R: SendNumArgsReg.
	self MoveCq: 0 R: Extra2Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump12 := self JumpZero: 0.
	jump13 := self Jump: 0.
	currentBlock := self Label.
	jump12 jmpTarget: currentBlock.
	jump12 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 2 R: TempReg.
	jump7 := self JumpNonZero: 0.
	self MoveR: TempReg R: Extra2Reg.
	self AddCq: 1 R: Extra2Reg.
	self MoveCq: 2 R: ClassReg.
	self
		DivR: ClassReg
		R: Extra2Reg
		Quo: ClassReg
		Rem: Extra2Reg.
	self AndCq: 1 R: TempReg.
	self AddR: TempReg R: SendNumArgsReg.
	self MoveCq: 0 R: Extra2Reg.
	currentBlock := self Label.
	jump13 jmpTarget: currentBlock.
	jump13 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self MoveR: TempReg R: ClassReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self AndCq: 16rFFFF R: ClassReg.
	self AddR: TempReg R: ClassReg.
	self MoveCq: objectMemory nilObject R: Extra2Reg.
	self MoveR: Extra2Reg R: Extra1Reg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self AndCq: 16rFFFF R: ClassReg.
	self AddR: TempReg R: ClassReg.
	self MoveCq: objectMemory nilObject R: Extra2Reg.
	self MoveR: Extra2Reg R: Extra1Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveCq: objectMemory nilObject R: Extra2Reg.
	self MoveR: TempReg R: ClassReg.
	self MoveR: Extra2Reg R: Extra1Reg.
	currentBlock := self Label.
	jump10 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 0 R: Extra0Reg.
	jump4 := self JumpZero: 0.
	self MoveR: Extra1Reg R: Extra2Reg.
	currentBlock := self Label.
	jump13 jmpTarget: currentBlock.
	self MoveR: ClassReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveR: SendNumArgsReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveR: Extra2Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 24 r: SPReg.
	jump13 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra1Reg R: Extra2Reg.
	currentBlock := self Label.
	jump12 jmpTarget: currentBlock.
	self MoveM32: 4 r: ReceiverResultReg R: Extra0Reg.
	self AndCq: 16rFFFFFFFF R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump12 := self JumpZero: 0.
	self CmpCq: 0 R: Extra0Reg.
	jump4 := self JumpLess: 0.
	self MoveR: ClassReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveR: SendNumArgsReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveR: Extra2Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 24 r: SPReg.
	currentBlock := self Label.
	jump13 jmpTarget: currentBlock.
	self MoveR: Arg0Reg R: ClassReg.
	self MoveR: ReceiverResultReg R: Extra1Reg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self CmpCq: 255 R: Extra3Reg.
	jump13 := self JumpGreaterOrEqual: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self CmpCq: 1 R: Extra3Reg.
	jump5 := self JumpLess: 0.
	self MoveCq: 8 R: TempReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MulR: Extra3Reg R: TempReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveCq: 8 R: TempReg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self AddCq: 8 R: TempReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump13 jmpTarget: currentBlock.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: TempReg.
	self ArithmeticShiftRightCq: 56 R: TempReg.
	self CmpCq: 0 R: TempReg.
	jump13 := self JumpGreater: 0.
	self MoveCq: 8 R: TempReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MulR: Extra3Reg R: TempReg.
	self AddCq: 16 R: TempReg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self MoveAw: objectMemory freeStartAddress R: SendNumArgsReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self CmpCq: 255 R: Extra3Reg.
	jump6 := self JumpGreaterOrEqual: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra2Reg.
	self LogicalShiftLeftCq: 56 R: Extra2Reg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self LogicalShiftLeftCq: 24 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self AddR: Extra3Reg R: Extra2Reg.
	self AddR: Extra0Reg R: Extra2Reg.
	self OrCq: 0 R: Extra2Reg.
	self MoveR: Extra2Reg M64: 0 r: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: Extra2Reg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra2Reg.
	self AddCq: 16rFF00000000000000 R: Extra2Reg.
	self MoveR: Extra2Reg M64: 0 r: SendNumArgsReg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self LogicalShiftLeftCq: 24 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self AddR: Extra0Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self AddCq: 16rFF00000000000000 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self OrCq: 0 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg M64: 8 r: SendNumArgsReg.
	self AddCq: 8 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: Extra2Reg.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveAw: objectMemory freeStartAddress R: SendNumArgsReg.
	self AddR: TempReg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Aw: objectMemory freeStartAddress.
	self MoveR: Extra2Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 32 r: SPReg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump13 jmpTarget: currentBlock.
	self MoveCq: 0 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 32 r: SPReg.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveMw: 32 r: SPReg R: Extra3Reg.
	self CmpCq: 0 R: Extra3Reg.
	jump5 := self JumpZero: 0.
	self MoveMw: 32 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra2Reg.
	self AddCq: 8 R: Extra2Reg.
	self MoveCq: 8 R: TempReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MulR: Extra3Reg R: TempReg.
	self MoveMw: 32 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self AddR: TempReg R: Extra0Reg.
	self AddCq: 8 R: Extra0Reg.
	self SubCq: 1 R: Extra0Reg.
	b986 := self Label.
	self CmpR: Extra2Reg R: Extra0Reg.
	jump13 := self JumpGreaterOrEqual: 0.
	self MoveR: ClassReg R: TempReg.
	self MoveR: Extra1Reg R: SendNumArgsReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump13 jmpTarget: currentBlock.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg M64: 0 r: Extra2Reg.
	self MoveR: Extra2Reg R: SendNumArgsReg.
	self AddCq: 8 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: Extra2Reg.
	jump13 := self Jump: b986.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveR: ClassReg R: TempReg.
	self MoveR: Extra1Reg R: SendNumArgsReg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self MoveMw: 32 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra1Reg.
	self MoveR: TempReg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ClassReg.
	currentBlock := self Label.
	jump11 jmpTarget: currentBlock.
	self CmpCq: 0 R: Extra1Reg.
	jump11 := self JumpZero: 0.
	self MoveR: Extra1Reg R: ReceiverResultReg.
	self SubCq: 32 R: SPReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump11 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Arg0Reg.
	self MoveR: ClassReg R: ReceiverResultReg.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump12 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self SubCq: 32 R: SPReg.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveNotEqual [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: Arg0Reg R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self AndR: ClassReg R: TempReg.
	self TstCq: 1 R: TempReg.
	jump1 := self JumpZero: 0.
	self MoveR: ReceiverResultReg R: ClassReg.
	self CmpR: Arg0Reg R: ClassReg.
	jump2 := self JumpNonZero: 0.
	self MoveCq: objectMemory falseObject R: ClassReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveCq: objectMemory trueObject R: ClassReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveR: ClassReg R: ReceiverResultReg.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self genPrimReturn.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveSubtract [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self TstCq: 1 R: ReceiverResultReg.
	jump1 := self JumpZero: 0.
	self TstCq: 1 R: Arg0Reg.
	jump2 := self JumpZero: 0.
	self MoveR: Arg0Reg R: TempReg.
	self AddCq:  -1 R: TempReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self SubR: TempReg R: ClassReg.
	jump3 := self JumpOverflow: 0.
	self MoveR: ClassReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PushConstantOneBytecode [
	"AutoGenerated by Druid"

	| currentBlock |
	self ssPushConstant: ConstOne.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushConstantZeroBytecode [
	"AutoGenerated by Druid"

	| currentBlock |
	self ssPushConstant: ConstZero.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode [
	"AutoGenerated by Druid"

	| currentBlock |
	self MoveCq: ((methodObj + 8) + ((0 + LiteralStart) << 3)) R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode0 [
	"AutoGenerated by Druid"

	| currentBlock |
	self MoveCq: ((methodObj + 8) + ((0 + LiteralStart) << 3)) R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode1 [
	"AutoGenerated by Druid"

	| currentBlock |
	self MoveCq: ((methodObj + 8) + ((1 + LiteralStart) << 3)) R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode10 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((10 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode11 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((11 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode12 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((12 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode13 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((13 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode14 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((14 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode15 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((15 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode16 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((16 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode17 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((17 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode18 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((18 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode19 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((19 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode2 [
	"AutoGenerated by Druid"

	| currentBlock |
	self MoveCq: ((methodObj + 8) + ((2 + LiteralStart) << 3)) R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode20 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((20 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode21 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((21 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode22 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((22 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode23 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((23 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode24 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((24 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode25 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((25 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode26 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((26 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode27 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((27 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode28 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((28 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode29 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((29 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode3 [
	"AutoGenerated by Druid"

	| currentBlock |
	self MoveCq: ((methodObj + 8) + ((3 + LiteralStart) << 3)) R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode30 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((30 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode31 [
	"AutoGenerated by Druid"

	| currentBlock |
	self
		MoveCq: ((methodObj + 8) + ((31 + LiteralStart) << 3))
		R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode4 [
	"AutoGenerated by Druid"

	| currentBlock |
	self MoveCq: ((methodObj + 8) + ((4 + LiteralStart) << 3)) R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode5 [
	"AutoGenerated by Druid"

	| currentBlock |
	self MoveCq: ((methodObj + 8) + ((5 + LiteralStart) << 3)) R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode6 [
	"AutoGenerated by Druid"

	| currentBlock |
	self MoveCq: ((methodObj + 8) + ((6 + LiteralStart) << 3)) R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode7 [
	"AutoGenerated by Druid"

	| currentBlock |
	self MoveCq: ((methodObj + 8) + ((7 + LiteralStart) << 3)) R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode8 [
	"AutoGenerated by Druid"

	| currentBlock |
	self MoveCq: ((methodObj + 8) + ((8 + LiteralStart) << 3)) R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode9 [
	"AutoGenerated by Druid"

	| currentBlock |
	self MoveCq: ((methodObj + 8) + ((9 + LiteralStart) << 3)) R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode0 [
	"AutoGenerated by Druid"

	| jumpTrue jump3 jump1 jumpNext currentBlock jump2 b229 |
	self MoveCq: ((methodObj + 8) + ((0 + LiteralStart) << 3)) R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self MoveM64: 0 r: TempReg R: ClassReg.
	self AndCq: 16r3FFFF7 R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jump1 := self JumpZero: 0.
	self MoveR: TempReg R: ClassReg.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: TempReg R: ClassReg.
	self MoveR: ClassReg R: TempReg.
	b229 := self Label.
	self MoveR: TempReg R: ClassReg.
	self AndCq: 7 R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jump1 := self JumpZero: 0.
	self MoveCq: 0 R: ClassReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: TempReg R: ClassReg.
	self AndCq: 16r3FFFF7 R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: ClassReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: ClassReg.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpCq: 0 R: ClassReg.
	jump3 := self JumpNonZero: 0.
	self MoveR: TempReg R: ClassReg.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: ClassReg offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: TempReg R: ClassReg.
	self MoveR: ClassReg R: TempReg.
	jump3 := self Jump: b229.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode1 [
	"AutoGenerated by Druid"

	| jumpTrue jump3 jump1 jumpNext currentBlock jump2 b229 |
	self MoveCq: ((methodObj + 8) + ((1 + LiteralStart) << 3)) R: TempReg.
	self MoveM64: 0 r: TempReg R: TempReg.
	self MoveM64: 0 r: TempReg R: ClassReg.
	self AndCq: 16r3FFFF7 R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jump1 := self JumpZero: 0.
	self MoveR: TempReg R: ClassReg.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: TempReg R: ClassReg.
	self MoveR: ClassReg R: TempReg.
	b229 := self Label.
	self MoveR: TempReg R: ClassReg.
	self AndCq: 7 R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jump1 := self JumpZero: 0.
	self MoveCq: 0 R: ClassReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: TempReg R: ClassReg.
	self AndCq: 16r3FFFF7 R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: ClassReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: ClassReg.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpCq: 0 R: ClassReg.
	jump3 := self JumpNonZero: 0.
	self MoveR: TempReg R: ClassReg.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: ClassReg offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: TempReg R: ClassReg.
	self MoveR: ClassReg R: TempReg.
	jump3 := self Jump: b229.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverBytecode [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	self ensureReceiverResultRegContainsSelf.
	t0 := self allocateRegNotConflictingWith: 0.
	self MoveR: ReceiverResultReg R: t0.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode0 [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	self ensureReceiverResultRegContainsSelf.
	t0 := self allocateRegNotConflictingWith: 0.
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: TempReg offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode1 [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	self ensureReceiverResultRegContainsSelf.
	t0 := self allocateRegNotConflictingWith: 0.
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: TempReg offset: 16.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode2 [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	self ensureReceiverResultRegContainsSelf.
	t0 := self allocateRegNotConflictingWith: 0.
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: TempReg offset: 24.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode3 [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	self ensureReceiverResultRegContainsSelf.
	t0 := self allocateRegNotConflictingWith: 0.
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: TempReg offset: 32.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode4 [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	self ensureReceiverResultRegContainsSelf.
	t0 := self allocateRegNotConflictingWith: 0.
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: TempReg offset: 40.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode5 [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	self ensureReceiverResultRegContainsSelf.
	t0 := self allocateRegNotConflictingWith: 0.
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: TempReg offset: 48.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode6 [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	self ensureReceiverResultRegContainsSelf.
	t0 := self allocateRegNotConflictingWith: 0.
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: TempReg offset: 56.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode7 [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	self ensureReceiverResultRegContainsSelf.
	t0 := self allocateRegNotConflictingWith: 0.
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: TempReg offset: 64.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode8 [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	self ensureReceiverResultRegContainsSelf.
	t0 := self allocateRegNotConflictingWith: 0.
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: TempReg offset: 72.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode9 [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	self ensureReceiverResultRegContainsSelf.
	t0 := self allocateRegNotConflictingWith: 0.
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: TempReg offset: 80.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushTemporaryVariableBytecode0 [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	t0 := self allocateRegNotConflictingWith: 0.
	(self simStackTempAt: 0) moveToReg: t0.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushTemporaryVariableBytecode1 [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	t0 := self allocateRegNotConflictingWith: 0.
	(self simStackTempAt: 1) moveToReg: t0.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushTemporaryVariableBytecode2 [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	t0 := self allocateRegNotConflictingWith: 0.
	(self simStackTempAt: 2) moveToReg: t0.
	self ssPushRegister: TempReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ReturnFalse [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	t0 := self allocateRegNotConflictingWith: 0.
	self MoveCq: objectMemory falseObject R: t0.
	self MoveR: t0 R: ReceiverResultReg.
	self genUpArrowReturn.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ReturnNil [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	t0 := self allocateRegNotConflictingWith: 0.
	self MoveCq: objectMemory nilObject R: t0.
	self MoveR: t0 R: ReceiverResultReg.
	self genUpArrowReturn.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ReturnReceiver [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	self ensureReceiverResultRegContainsSelf.
	t0 := self allocateRegNotConflictingWith: 0.
	self MoveR: ReceiverResultReg R: t0.
	self MoveR: t0 R: ReceiverResultReg.
	self genUpArrowReturn.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ReturnTopFromMethod [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	t0 := self allocateRegNotConflictingWith: 0.
	(self ssValue: 0) moveToReg: t0.
	self MoveR: t0 R: ReceiverResultReg.
	self genUpArrowReturn.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ReturnTrue [
	"AutoGenerated by Druid"

	| currentBlock t0 |
	t0 := self allocateRegNotConflictingWith: 0.
	self MoveCq: objectMemory trueObject R: t0.
	self MoveR: t0 R: ReceiverResultReg.
	self genUpArrowReturn.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode0 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 0
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode1 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 1
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode2 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 2
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode3 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 3
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode4 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 4
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode5 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 5
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode6 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 6
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode0 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 0
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode1 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 1
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode2 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 2
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode3 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 3
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode4 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 4
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode5 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 5
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode6 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 6
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode0 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 0
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode1 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 1
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode2 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 2
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode3 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 3
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode4 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 4
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode5 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 5
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode6 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 6
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode7 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 7
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode8 [
	"AutoGenerated by Druid"

	| currentBlock |
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 8
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #'trait candidates' }
DruidJIT >> generateObjectRepresentationTrampolines [
	"Do the store check.  Answer the argument for the benefit of the code generator;
	 ReceiverResultReg may be caller-saved and hence smashed by this call.  Answering
	 it allows the code generator to reload ReceiverResultReg cheaply.
	 In Spur the only thing we leave to the run-time is adding the receiver to the
	 remembered set and setting its isRemembered bit."
	self 
		cppIf: IMMUTABILITY
		ifTrue: [
			self 
				cCode: [] 
				inSmalltalk: [ ceStoreTrampolines := CArrayAccessor on: (Array new: NumStoreTrampolines) ].
				
			 0 to: NumStoreTrampolines - 1 do:
				[:instVarIndex |
				 ceStoreTrampolines
					at: instVarIndex
					put: (self 
							genStoreTrampolineCalled: (self 
															trampolineName: 'ceStoreTrampoline' 
															numArgs: instVarIndex 
															limit: NumStoreTrampolines - 2) 
							instVarIndex: instVarIndex)]].
	ceNewHashTrampoline := self genNewHashTrampoline: false called: 'ceNewHash'.
	SistaVM ifTrue: [ceInlineNewHashTrampoline := self genNewHashTrampoline: true  called: 'ceInlineNewHash'].
	ceStoreCheckTrampoline := self genStoreCheckTrampoline.
	ceStoreCheckContextReceiverTrampoline := self genStoreCheckContextReceiverTrampoline.
	ceScheduleScavengeTrampoline := self
											genTrampolineFor: #ceScheduleScavenge
											called: 'ceScheduleScavengeTrampoline'
											regsToSave: CallerSavedRegisterMask.
	ceSmallActiveContextInMethodTrampoline := self genActiveContextTrampolineLarge: false inBlock: 0 called: 'ceSmallMethodContext'.
	SistaV1BytecodeSet ifTrue:
		[ceSmallActiveContextInFullBlockTrampoline := self genActiveContextTrampolineLarge: false inBlock: InFullBlock called: 'ceSmallFullBlockContext'].
	ceLargeActiveContextInMethodTrampoline := self genActiveContextTrampolineLarge: true inBlock: 0 called: 'ceLargeMethodContext'.
	SistaV1BytecodeSet ifTrue:
		[ceLargeActiveContextInFullBlockTrampoline := self genActiveContextTrampolineLarge: true inBlock: InFullBlock called: 'ceLargeFullBlockContext'].
]

{ #category : #'trait candidates' }
DruidJIT >> getActiveContextAllocatesInMachineCode [
	"Make sure SendNumArgsReg and ClassReg are available in addition to
	 ReceiverResultReg and TempReg in genGetActiveContextNumArgs:large:inBlock:."
	^true
]

{ #category : #'trait candidates' }
DruidJIT >> hasValidHeaderPostGC: cogMethod [
	<var: #cogMethod type: #'CogMethod *'>
	<inline: true>
	^cogMethod objectHeader = objectMemory nullHeaderForMachineCodeMethod
]

{ #category : #'trait candidates' }
DruidJIT >> initialize [

	<doNotGenerate>
	super initialize.
	
	ceStoreTrampolines := (CArrayAccessor on: (Array new: NumStoreTrampolines))
]

{ #category : #'trait candidates' }
DruidJIT >> inlineCacheTagForInstance: oop [
	"Answer the relevant inline cache tag for an instance.
	 c.f. getInlineCacheClassTagFrom:into: & inlineCacheTagForClass:"
	^(objectMemory isImmediate: oop)
		ifTrue: [oop bitAnd: objectMemory tagMask]
		ifFalse: [objectMemory classIndexOf: oop]
]

{ #category : #'trait candidates' }
DruidJIT >> inlineCacheTagIsYoung: cacheTag [
	"Since all cache tags in Spur are class indices none of
	 them are young or have to be updated in a scavenge."
	^false
]

{ #category : #'trait candidates' }
DruidJIT >> isUnannotatableConstant: simStackEntry [
	<inline: true>
	<var: 'simStackEntry' type: #'CogSimStackEntry *'>
	^simStackEntry type = SSConstant
	  and: [(objectMemory isImmediate: simStackEntry constant)
		or: [(self shouldAnnotateObjectReference: simStackEntry constant) not]]
]

{ #category : #'trait candidates' }
DruidJIT >> log2BytesPerWord [
	^3
]

{ #category : #'trait candidates' }
DruidJIT >> markAndTraceCacheTagLiteral: literal in: cogMethodOrNil atpc: address [
	"Mark and trace a literal in an inline cache preceding address in cogMethodOrNil.
	 Answer if code was modified.  In 64-bit Spur, cache tags are either selector
	 indices or class indices and so this is a noop."
	<var: #cogMethodOrNil type: #'CogMethod *'>
	<var: #address type: #usqInt>
	<inline: true>
	^false
]

{ #category : #'trait candidates' }
DruidJIT >> markAndTraceLiteral: literal in: cogMethod at: address [
	"Mark and trace a literal in a sqInt variable of cogMethod."
	<var: #cogMethod type: #'CogMethod *'>
	<var: #address type: #'sqInt *'>
	| objOop |
	(self couldBeObject: literal) ifFalse:
		[^self].
	self assert: (objectMemory addressCouldBeObj: literal).
	(objectMemory isForwarded: literal) ifFalse:
		[objectMemory markAndTrace: literal.
		 ^self].
	objOop := objectMemory followForwarded: literal.
	address at: 0 put: objOop.
	self markAndTraceUpdatedLiteral: objOop in: cogMethod
]

{ #category : #'trait candidates' }
DruidJIT >> markAndTraceLiteral: literal in: cogMethodOrNil atpc: address [
	"Mark and trace a literal in a machine code instruction preceding address in cogMethodOrNil.
	 Answer if code was modified."
	<var: #cogMethodOrNil type: #'CogMethod *'>
	<var: #address type: #usqInt>
	| objOop |
	(self couldBeObject: literal) ifFalse:
		[^false].
	self assert: (objectMemory addressCouldBeObj: literal).
	(objectMemory isForwarded: literal) ifFalse:
		[objectMemory markAndTrace: literal.
		 ^false].
	objOop := objectMemory followForwarded: literal.
	self backEnd storeLiteral: objOop beforeFollowingAddress: address.
	self markAndTraceUpdatedLiteral: objOop in: cogMethodOrNil.
	^true
]

{ #category : #'trait candidates' }
DruidJIT >> markAndTraceUpdatedLiteral: objOop in: cogMethodOrNil [
	"Common code to mark a literal in cogMethod and add
	 the cogMethod to youngReferrers if the literal is young."
	<var: #cogMethodOrNil type: #'CogMethod *'>
	(objectMemory isNonImmediate: objOop) ifTrue:
		[(cogMethodOrNil notNil
		  and: [objectMemory isYoungObject: objOop]) ifTrue:
			[methodZone ensureInYoungReferrers: cogMethodOrNil].
		 objectMemory markAndTrace: objOop]
]

{ #category : #'trait candidates' }
DruidJIT >> maybeCompileRetryOnPrimitiveFail: primIndex [
	"If primIndex has an accessorDepth and fails, or it is external and fails with PrimErrNoMemory,
	 call ceCheckAndMaybeRetryPrimitive if so  If ceCheck.... answers true, retry the primitive."
	| jmp |
	<var: #jmp type: #'AbstractInstruction *'>
	(coInterpreter accessorDepthForPrimitiveIndex: primIndex) >= 0
		ifTrue:
			[jmp := self
				MoveAw: coInterpreter primFailCodeAddress R: TempReg;
				CmpCq: 0 R: TempReg;
				JumpZero: 0]
		ifFalse:
			[coInterpreter primNumberExternalCall ~= primIndex ifTrue:
				[^0].
			 jmp := self
				MoveAw: coInterpreter primFailCodeAddress R: TempReg;
				CmpCq: PrimErrNoMemory R: TempReg;
				JumpNonZero: 0].
	self
		compileCallFor: #ceCheckAndMaybeRetryPrimitive:
		numArgs: 1
		arg: (self trampolineArgConstant: primIndex)
		arg: nil
		arg: nil
		arg: nil
		resultReg: TempReg
		regsToSave: self emptyRegisterMask.
	jmp jmpTarget: self Label.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> maybeGenerateSelectorIndexDereferenceRoutine [
	"Generate the routine that converts selector indices into selector objects.
	 It is called from the send trampolines.
	 If the selector index is negative, convert it into a positive index into the
	 special selectors array and index that.  Otherwise, index the current method.
	 The routine uses Extra0Reg & Extra1Reg, which are available, since they
	 are not live at point of send."
	| jumpNegative jumpNotBlock jumpFullBlock |
	<var: 'jumpNegative' type: #'AbstractInstruction *'>
	<var: 'jumpNotBlock' type: #'AbstractInstruction *'>
	<var: 'jumpFullBlock' type: #'AbstractInstruction *'>
	self zeroOpcodeIndex.
	self CmpCq: 0 R: ClassReg.
	jumpNegative := self JumpLess: 0.
	self
		MoveMw: FoxMethod r: FPReg R: Extra0Reg;
		AddCq: 2 R: ClassReg; "Change selector index to 1-relative, skipping the method header"
		TstCq: MFMethodFlagIsBlockFlag R: Extra0Reg.
	jumpNotBlock := self JumpZero: 0.
	"If in a block, need to find the home method...  If using full blocks, need to test the cpicHasMNUCaseOrCMIsFullBlock bit"
	self AndCq: methodZone zoneAlignment negated R: Extra0Reg.
	SistaV1BytecodeSet ifTrue:
		[self bitAndByteOffsetOfIsFullBlockBitInto:
			[:bitmask :byteOffset|
			jumpFullBlock := self
				MoveMb: byteOffset r: Extra0Reg R: Extra1Reg;
				TstCq: bitmask R: Extra1Reg;
				JumpNonZero: 0]].
	self 
		MoveM16: 0 r: Extra0Reg R: Extra1Reg;
		SubR: Extra1Reg R: Extra0Reg.
	jumpNotBlock jmpTarget: self Label.
	SistaV1BytecodeSet ifTrue:
		[jumpFullBlock jmpTarget: jumpNotBlock getJmpTarget].
	self "Now fetch the method object and index with the literal index to retrieve the selector"
		AndCq: methodZone zoneAlignment negated R: Extra0Reg;
		MoveMw: (self offset: CogMethod of: #methodObject) r: Extra0Reg R: Extra1Reg;
		MoveXwr: ClassReg R: Extra1Reg R: ClassReg;
		RetN: 0.
	jumpNegative jmpTarget: self Label.
	self
		NegateR: ClassReg;
		LogicalShiftLeftCq: 1 R: ClassReg;
		MoveAw: objectMemory specialObjectsArrayAddress R: Extra0Reg;
		SubCq: 1 R: ClassReg;
		MoveMw: SpecialSelectors + 1 * objectMemory wordSize r: Extra0Reg R: Extra1Reg; "Index, including header size"
		MoveXwr: ClassReg R: Extra1Reg R: ClassReg;
		RetN: 0.
	ceDereferenceSelectorIndex := self methodZoneBase.
	self
		outputInstructionsForGeneratedRuntimeAt: ceDereferenceSelectorIndex;
		recordGeneratedRunTime: 'ceDereferenceSelectorIndex' address: ceDereferenceSelectorIndex;
		recordRunTimeObjectReferences
]

{ #category : #'trait candidates' }
DruidJIT >> maybeShiftClassTagRegisterForMethodCacheProbe: classTagReg [
	"Generate a shift of the register containing the class tag in a method cache probe.
	 c.f. SpurMemoryManager>>methodCacheHashOf:with:"

	self LogicalShiftLeftCq: 2 R: classTagReg.
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> numRegArgs [
	"Define how many register arguments a StackToRegisterMappingCogit can
	 and should use with the receiver.  The value must be 0, 1 or 2.  Note that a
	 SimpleStackBasedCogit always has 0 register args (although the receiver is
	 passed in a register).  The Spur object representation is simple enough that
	 implementing at:put: is straight-forward and hence 2 register args are worth
	 while.  The method must be inlined in CoInterpreter, and dead code eliminated
	 so that the register-popping enilopmarts such as enterRegisterArgCogMethod:-
	 at:receiver: do not have to be implemented in SimpleStackBasedCogit."
	<api>
	<option: #StackToRegisterMappingCogit>
	^2
]

{ #category : #'trait candidates' }
DruidJIT >> remapObject: objOop [
	self assert: (objectMemory addressCouldBeObj: objOop).
	^(objectMemory shouldRemapObj: objOop)
		ifTrue: [objectMemory remapObj: objOop]
		ifFalse: [objOop]
]

{ #category : #'trait candidates' }
DruidJIT >> remapOop: objOop [
	^(objectMemory shouldRemapOop: objOop)
		ifTrue: [objectMemory remapObj: objOop]
		ifFalse: [objOop]
]

{ #category : #'trait candidates' }
DruidJIT >> selectorIndexDereferenceRoutine [
	"If the object representation is 64-bits, selectors must be accessed via indices in the inline caches.
	 Answer the routine that will map from indices to selector objects if so, otherwise nil."
	^ceDereferenceSelectorIndex
]

{ #category : #'trait candidates' }
DruidJIT >> shouldAnnotateObjectReference: anOop [
	"Objects in newSpace or oldSpace except nil, true, false & classTableRootObj need to be annotated."
	^(objectMemory isNonImmediate: anOop)
	  and: [(self oop: anOop isGreaterThan: objectMemory classTableRootObj)
		or: [self oop: anOop isLessThan: objectMemory nilObject]]
]

{ #category : #'trait candidates' }
DruidJIT >> slotOffsetOfInstVarIndex: index [
	^index * objectMemory wordSize + objectMemory baseHeaderSize
]

{ #category : #'trait candidates' }
DruidJIT >> validInlineCacheTag: classIndexOrTagPattern [
	"The three valid tag patterns are 1 (SmallInteger), 2 (Character) and 3 (SmallFloat64)."
	^(classIndexOrTagPattern >= 1
	  and: [classIndexOrTagPattern <= 3])
	  or: [(objectMemory classAtIndex: classIndexOrTagPattern) notNil]
]

{ #category : #'trait candidates' }
DruidJIT >> valueOfAssociation: associationOop [
	| association |
	association := associationOop.
	(objectMemory isForwarded: association) ifTrue:
		[association := objectMemory followForwarded: association].
	^objectMemory fetchPointer: ValueIndex ofObject: association
]
