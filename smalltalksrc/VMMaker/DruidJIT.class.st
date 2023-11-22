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
		  { 1. 10. 10. #gen_PushReceiverVariableBytecode10.
		  #isInstVarRef. #needsFrameNever:. 1 }.
		  { 1. 11. 11. #gen_PushReceiverVariableBytecode11.
		  #isInstVarRef. #needsFrameNever:. 1 }.
		  { 1. 12. 12. #gen_PushReceiverVariableBytecode12.
		  #isInstVarRef. #needsFrameNever:. 1 }.
		  { 1. 13. 13. #gen_PushReceiverVariableBytecode13.
		  #isInstVarRef. #needsFrameNever:. 1 }.
		  { 1. 14. 14. #gen_PushReceiverVariableBytecode14.
		  #isInstVarRef. #needsFrameNever:. 1 }.
		  { 1. 15. 15. #gen_PushReceiverVariableBytecode15.
		  #isInstVarRef. #needsFrameNever:. 1 }.
		  { 1. 16. 16. #gen_PushLiteralVariable16CasesBytecode0.
		  #needsFrameNever:. 1 }.
		  { 1. 17. 17. #gen_PushLiteralVariable16CasesBytecode1.
		  #needsFrameNever:. 1 }.
		  { 1. 18. 18. #gen_PushLiteralVariable16CasesBytecode2.
		  #needsFrameNever:. 1 }.
		  { 1. 19. 19. #gen_PushLiteralVariable16CasesBytecode3.
		  #needsFrameNever:. 1 }.
		  { 1. 20. 20. #gen_PushLiteralVariable16CasesBytecode4.
		  #needsFrameNever:. 1 }.
		  { 1. 21. 21. #gen_PushLiteralVariable16CasesBytecode5.
		  #needsFrameNever:. 1 }.
		  { 1. 22. 22. #gen_PushLiteralVariable16CasesBytecode6.
		  #needsFrameNever:. 1 }.
		  { 1. 23. 23. #gen_PushLiteralVariable16CasesBytecode7.
		  #needsFrameNever:. 1 }.
		  { 1. 24. 24. #gen_PushLiteralVariable16CasesBytecode8.
		  #needsFrameNever:. 1 }.
		  { 1. 25. 25. #gen_PushLiteralVariable16CasesBytecode9.
		  #needsFrameNever:. 1 }.
		  { 1. 26. 26. #gen_PushLiteralVariable16CasesBytecode10.
		  #needsFrameNever:. 1 }.
		  { 1. 27. 27. #gen_PushLiteralVariable16CasesBytecode11.
		  #needsFrameNever:. 1 }.
		  { 1. 28. 28. #gen_PushLiteralVariable16CasesBytecode12.
		  #needsFrameNever:. 1 }.
		  { 1. 29. 29. #gen_PushLiteralVariable16CasesBytecode13.
		  #needsFrameNever:. 1 }.
		  { 1. 30. 30. #gen_PushLiteralVariable16CasesBytecode14.
		  #needsFrameNever:. 1 }.
		  { 1. 31. 31. #gen_PushLiteralVariable16CasesBytecode15.
		  #needsFrameNever:. 1 }.
		  { 1. 32. 32. #gen_PushLiteralConstantBytecode0.
		  #needsFrameNever:. 1 }.
		  { 1. 33. 33. #gen_PushLiteralConstantBytecode1.
		  #needsFrameNever:. 1 }.
		  { 1. 34. 34. #gen_PushLiteralConstantBytecode2.
		  #needsFrameNever:. 1 }.
		  { 1. 35. 35. #gen_PushLiteralConstantBytecode3.
		  #needsFrameNever:. 1 }.
		  { 1. 36. 36. #gen_PushLiteralConstantBytecode4.
		  #needsFrameNever:. 1 }.
		  { 1. 37. 37. #gen_PushLiteralConstantBytecode5.
		  #needsFrameNever:. 1 }.
		  { 1. 38. 38. #gen_PushLiteralConstantBytecode6.
		  #needsFrameNever:. 1 }.
		  { 1. 39. 39. #gen_PushLiteralConstantBytecode7.
		  #needsFrameNever:. 1 }.
		  { 1. 40. 40. #gen_PushLiteralConstantBytecode8.
		  #needsFrameNever:. 1 }.
		  { 1. 41. 41. #gen_PushLiteralConstantBytecode9.
		  #needsFrameNever:. 1 }.
		  { 1. 42. 42. #gen_PushLiteralConstantBytecode10.
		  #needsFrameNever:. 1 }.
		  { 1. 43. 43. #gen_PushLiteralConstantBytecode11.
		  #needsFrameNever:. 1 }.
		  { 1. 44. 44. #gen_PushLiteralConstantBytecode12.
		  #needsFrameNever:. 1 }.
		  { 1. 45. 45. #gen_PushLiteralConstantBytecode13.
		  #needsFrameNever:. 1 }.
		  { 1. 46. 46. #gen_PushLiteralConstantBytecode14.
		  #needsFrameNever:. 1 }.
		  { 1. 47. 47. #gen_PushLiteralConstantBytecode15.
		  #needsFrameNever:. 1 }.
		  { 1. 48. 48. #gen_PushLiteralConstantBytecode16.
		  #needsFrameNever:. 1 }.
		  { 1. 49. 49. #gen_PushLiteralConstantBytecode17.
		  #needsFrameNever:. 1 }.
		  { 1. 50. 50. #gen_PushLiteralConstantBytecode18.
		  #needsFrameNever:. 1 }.
		  { 1. 51. 51. #gen_PushLiteralConstantBytecode19.
		  #needsFrameNever:. 1 }.
		  { 1. 52. 52. #gen_PushLiteralConstantBytecode20.
		  #needsFrameNever:. 1 }.
		  { 1. 53. 53. #gen_PushLiteralConstantBytecode21.
		  #needsFrameNever:. 1 }.
		  { 1. 54. 54. #gen_PushLiteralConstantBytecode22.
		  #needsFrameNever:. 1 }.
		  { 1. 55. 55. #gen_PushLiteralConstantBytecode23.
		  #needsFrameNever:. 1 }.
		  { 1. 56. 56. #gen_PushLiteralConstantBytecode24.
		  #needsFrameNever:. 1 }.
		  { 1. 57. 57. #gen_PushLiteralConstantBytecode25.
		  #needsFrameNever:. 1 }.
		  { 1. 58. 58. #gen_PushLiteralConstantBytecode26.
		  #needsFrameNever:. 1 }.
		  { 1. 59. 59. #gen_PushLiteralConstantBytecode27.
		  #needsFrameNever:. 1 }.
		  { 1. 60. 60. #gen_PushLiteralConstantBytecode28.
		  #needsFrameNever:. 1 }.
		  { 1. 61. 61. #gen_PushLiteralConstantBytecode29.
		  #needsFrameNever:. 1 }.
		  { 1. 62. 62. #gen_PushLiteralConstantBytecode30.
		  #needsFrameNever:. 1 }.
		  { 1. 63. 63. #gen_PushLiteralConstantBytecode31.
		  #needsFrameNever:. 1 }.
		  { 1. 64. 64. #gen_PushTemporaryVariableBytecode0.
		  #needsFrameIfMod16GENumArgs:. 1 }.
		  { 1. 65. 65. #gen_PushTemporaryVariableBytecode1.
		  #needsFrameIfMod16GENumArgs:. 1 }.
		  { 1. 66. 66. #gen_PushTemporaryVariableBytecode2.
		  #needsFrameIfMod16GENumArgs:. 1 }.
		  { 1. 67. 67. #gen_PushTemporaryVariableBytecode3.
		  #needsFrameIfMod16GENumArgs:. 1 }.
		  { 1. 68. 68. #gen_PushTemporaryVariableBytecode4.
		  #needsFrameIfMod16GENumArgs:. 1 }.
		  { 1. 69. 69. #gen_PushTemporaryVariableBytecode5.
		  #needsFrameIfMod16GENumArgs:. 1 }.
		  { 1. 70. 70. #gen_PushTemporaryVariableBytecode6.
		  #needsFrameIfMod16GENumArgs:. 1 }.
		  { 1. 71. 71. #gen_PushTemporaryVariableBytecode7.
		  #needsFrameIfMod16GENumArgs:. 1 }.
		  { 1. 72. 72. #gen_PushTemporaryVariableBytecode8.
		  #needsFrameIfMod16GENumArgs:. 1 }.
		  { 1. 73. 73. #gen_PushTemporaryVariableBytecode9.
		  #needsFrameIfMod16GENumArgs:. 1 }.
		  { 1. 74. 74. #gen_PushTemporaryVariableBytecode10.
		  #needsFrameIfMod16GENumArgs:. 1 }.
		  { 1. 75. 75. #gen_PushTemporaryVariableBytecode11.
		  #needsFrameIfMod16GENumArgs:. 1 }.
		  { 1. 76. 76. #gen_PushReceiverBytecode. #needsFrameNever:.
		  1 }.
		  { 1. 77. 77. #gen_PushConstantTrueBytecode.
		  #needsFrameNever:. 1 }.
		  { 1. 78. 78. #gen_PushConstantFalseBytecode.
		  #needsFrameNever:. 1 }.
		  { 1. 79. 79. #gen_PushConstantNilBytecode.
		  #needsFrameNever:. 1 }.
		  { 1. 80. 80. #gen_PushConstantZeroBytecode.
		  #needsFrameNever:. 1 }.
		  { 1. 81. 81. #gen_PushConstantOneBytecode.
		  #needsFrameNever:. 1 }.
		  { 1. 82. 82. #unknownBytecode }.
		  { 1. 83. 83. #gen_DuplicateTopBytecode. #needsFrameNever:.
		  1 }.
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
		  { 1. 93. 93. #gen_ReturnNilFromBlock. #return. #needsFrameNever:.
		   -1 }.
		  { 1. 94. 94. #gen_ReturnTopFromBlock. #return. #needsFrameNever:.
		   -1 }.
		  { 1. 95. 95. #gen_ExtNopBytecode. #needsFrameNever:.
		  0 }.
		  { 1. 96. 96. #gen_BytecodePrimAdd. #isMapped }.
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
		  { 1. 118. 118. #unknownBytecode }.
		  { 1. 119. 119. #unknownBytecode }.
		  { 1. 120. 120. #unknownBytecode }.
		  { 1. 121. 121. #gen_BytecodePrimValue. #isMapped }.
		  { 1. 122. 122. #gen_BytecodePrimValueWithArg.
		  #isMapped }.
		  { 1. 123. 123. #gen_BytecodePrimDo. #isMapped }.
		  { 1. 124. 124. #gen_BytecodePrimNew. #isMapped }.
		  { 1. 125. 125. #gen_BytecodePrimNewWithArg.
		  #isMapped }.
		  { 1. 126. 126. #gen_BytecodePrimPointX. #isMapped }.
		  { 1. 127. 127. #gen_BytecodePrimPointY. #isMapped }.
		  { 1. 128. 128. #gen_SendLiteralSelector0ArgsBytecode0.
		  #isMapped }.
		  { 1. 129. 129. #gen_SendLiteralSelector0ArgsBytecode1.
		  #isMapped }.
		  { 1. 130. 130. #gen_SendLiteralSelector0ArgsBytecode2.
		  #isMapped }.
		  { 1. 131. 131. #gen_SendLiteralSelector0ArgsBytecode3.
		  #isMapped }.
		  { 1. 132. 132. #gen_SendLiteralSelector0ArgsBytecode4.
		  #isMapped }.
		  { 1. 133. 133. #gen_SendLiteralSelector0ArgsBytecode5.
		  #isMapped }.
		  { 1. 134. 134. #gen_SendLiteralSelector0ArgsBytecode6.
		  #isMapped }.
		  { 1. 135. 135. #gen_SendLiteralSelector0ArgsBytecode7.
		  #isMapped }.
		  { 1. 136. 136. #gen_SendLiteralSelector0ArgsBytecode8.
		  #isMapped }.
		  { 1. 137. 137. #gen_SendLiteralSelector0ArgsBytecode9.
		  #isMapped }.
		  { 1. 138. 138. #gen_SendLiteralSelector0ArgsBytecode10.
		  #isMapped }.
		  { 1. 139. 139. #gen_SendLiteralSelector0ArgsBytecode11.
		  #isMapped }.
		  { 1. 140. 140. #gen_SendLiteralSelector0ArgsBytecode12.
		  #isMapped }.
		  { 1. 141. 141. #gen_SendLiteralSelector0ArgsBytecode13.
		  #isMapped }.
		  { 1. 142. 142. #gen_SendLiteralSelector0ArgsBytecode14.
		  #isMapped }.
		  { 1. 143. 143. #gen_SendLiteralSelector0ArgsBytecode15.
		  #isMapped }.
		  { 1. 144. 144. #gen_SendLiteralSelector1ArgBytecode0.
		  #isMapped }.
		  { 1. 145. 145. #gen_SendLiteralSelector1ArgBytecode1.
		  #isMapped }.
		  { 1. 146. 146. #gen_SendLiteralSelector1ArgBytecode2.
		  #isMapped }.
		  { 1. 147. 147. #gen_SendLiteralSelector1ArgBytecode3.
		  #isMapped }.
		  { 1. 148. 148. #gen_SendLiteralSelector1ArgBytecode4.
		  #isMapped }.
		  { 1. 149. 149. #gen_SendLiteralSelector1ArgBytecode5.
		  #isMapped }.
		  { 1. 150. 150. #gen_SendLiteralSelector1ArgBytecode6.
		  #isMapped }.
		  { 1. 151. 151. #gen_SendLiteralSelector1ArgBytecode7.
		  #isMapped }.
		  { 1. 152. 152. #gen_SendLiteralSelector1ArgBytecode8.
		  #isMapped }.
		  { 1. 153. 153. #gen_SendLiteralSelector1ArgBytecode9.
		  #isMapped }.
		  { 1. 154. 154. #gen_SendLiteralSelector1ArgBytecode10.
		  #isMapped }.
		  { 1. 155. 155. #gen_SendLiteralSelector1ArgBytecode11.
		  #isMapped }.
		  { 1. 156. 156. #gen_SendLiteralSelector1ArgBytecode12.
		  #isMapped }.
		  { 1. 157. 157. #gen_SendLiteralSelector1ArgBytecode13.
		  #isMapped }.
		  { 1. 158. 158. #gen_SendLiteralSelector1ArgBytecode14.
		  #isMapped }.
		  { 1. 159. 159. #gen_SendLiteralSelector1ArgBytecode15.
		  #isMapped }.
		  { 1. 160. 160. #gen_SendLiteralSelector2ArgsBytecode0.
		  #isMapped }.
		  { 1. 161. 161. #gen_SendLiteralSelector2ArgsBytecode1.
		  #isMapped }.
		  { 1. 162. 162. #gen_SendLiteralSelector2ArgsBytecode2.
		  #isMapped }.
		  { 1. 163. 163. #gen_SendLiteralSelector2ArgsBytecode3.
		  #isMapped }.
		  { 1. 164. 164. #gen_SendLiteralSelector2ArgsBytecode4.
		  #isMapped }.
		  { 1. 165. 165. #gen_SendLiteralSelector2ArgsBytecode5.
		  #isMapped }.
		  { 1. 166. 166. #gen_SendLiteralSelector2ArgsBytecode6.
		  #isMapped }.
		  { 1. 167. 167. #gen_SendLiteralSelector2ArgsBytecode7.
		  #isMapped }.
		  { 1. 168. 168. #gen_SendLiteralSelector2ArgsBytecode8.
		  #isMapped }.
		  { 1. 169. 169. #gen_SendLiteralSelector2ArgsBytecode9.
		  #isMapped }.
		  { 1. 170. 170. #gen_SendLiteralSelector2ArgsBytecode10.
		  #isMapped }.
		  { 1. 171. 171. #gen_SendLiteralSelector2ArgsBytecode11.
		  #isMapped }.
		  { 1. 172. 172. #gen_SendLiteralSelector2ArgsBytecode12.
		  #isMapped }.
		  { 1. 173. 173. #gen_SendLiteralSelector2ArgsBytecode13.
		  #isMapped }.
		  { 1. 174. 174. #gen_SendLiteralSelector2ArgsBytecode14.
		  #isMapped }.
		  { 1. 175. 175. #gen_SendLiteralSelector2ArgsBytecode15.
		  #isMapped }.
		  { 1. 176. 176. #gen_ShortUnconditionalJump0.
		  #branch. #v3:ShortForward:Branch:Distance: }.
		  { 1. 177. 177. #gen_ShortUnconditionalJump1.
		  #branch. #v3:ShortForward:Branch:Distance: }.
		  { 1. 178. 178. #gen_ShortUnconditionalJump2.
		  #branch. #v3:ShortForward:Branch:Distance: }.
		  { 1. 179. 179. #gen_ShortUnconditionalJump3.
		  #branch. #v3:ShortForward:Branch:Distance: }.
		  { 1. 180. 180. #gen_ShortUnconditionalJump4.
		  #branch. #v3:ShortForward:Branch:Distance: }.
		  { 1. 181. 181. #gen_ShortUnconditionalJump5.
		  #branch. #v3:ShortForward:Branch:Distance: }.
		  { 1. 182. 182. #gen_ShortUnconditionalJump6.
		  #branch. #v3:ShortForward:Branch:Distance: }.
		  { 1. 183. 183. #gen_ShortUnconditionalJump7.
		  #branch. #v3:ShortForward:Branch:Distance: }.
		  { 1. 184. 184. #gen_ShortConditionalJumpTrue0.
		  #branch. #isBranchTrue. #isMapped. #v3:ShortForward:Branch:Distance: }.
		  { 1. 185. 185. #gen_ShortConditionalJumpTrue1.
		  #branch. #isBranchTrue. #isMapped. #v3:ShortForward:Branch:Distance: }.
		  { 1. 186. 186. #gen_ShortConditionalJumpTrue2.
		  #branch. #isBranchTrue. #isMapped. #v3:ShortForward:Branch:Distance: }.
		  { 1. 187. 187. #gen_ShortConditionalJumpTrue3.
		  #branch. #isBranchTrue. #isMapped. #v3:ShortForward:Branch:Distance: }.
		  { 1. 188. 188. #gen_ShortConditionalJumpTrue4.
		  #branch. #isBranchTrue. #isMapped. #v3:ShortForward:Branch:Distance: }.
		  { 1. 189. 189. #gen_ShortConditionalJumpTrue5.
		  #branch. #isBranchTrue. #isMapped. #v3:ShortForward:Branch:Distance: }.
		  { 1. 190. 190. #gen_ShortConditionalJumpTrue6.
		  #branch. #isBranchTrue. #isMapped. #v3:ShortForward:Branch:Distance: }.
		  { 1. 191. 191. #gen_ShortConditionalJumpTrue7.
		  #branch. #isBranchTrue. #isMapped. #v3:ShortForward:Branch:Distance: }.
		  { 1. 192. 192. #gen_ShortConditionalJumpFalse0.
		  #branch. #isBranchFalse. #isMapped. #v3:ShortForward:Branch:Distance: }.
		  { 1. 193. 193. #gen_ShortConditionalJumpFalse1.
		  #branch. #isBranchFalse. #isMapped. #v3:ShortForward:Branch:Distance: }.
		  { 1. 194. 194. #gen_ShortConditionalJumpFalse2.
		  #branch. #isBranchFalse. #isMapped. #v3:ShortForward:Branch:Distance: }.
		  { 1. 195. 195. #gen_ShortConditionalJumpFalse3.
		  #branch. #isBranchFalse. #isMapped. #v3:ShortForward:Branch:Distance: }.
		  { 1. 196. 196. #gen_ShortConditionalJumpFalse4.
		  #branch. #isBranchFalse. #isMapped. #v3:ShortForward:Branch:Distance: }.
		  { 1. 197. 197. #gen_ShortConditionalJumpFalse5.
		  #branch. #isBranchFalse. #isMapped. #v3:ShortForward:Branch:Distance: }.
		  { 1. 198. 198. #gen_ShortConditionalJumpFalse6.
		  #branch. #isBranchFalse. #isMapped. #v3:ShortForward:Branch:Distance: }.
		  { 1. 199. 199. #gen_ShortConditionalJumpFalse7.
		  #branch. #isBranchFalse. #isMapped. #v3:ShortForward:Branch:Distance: }.
		  { 1. 200. 200. #unknownBytecode }.
		  { 1. 201. 201. #unknownBytecode }.
		  { 1. 202. 202. #unknownBytecode }.
		  { 1. 203. 203. #unknownBytecode }.
		  { 1. 204. 204. #unknownBytecode }.
		  { 1. 205. 205. #unknownBytecode }.
		  { 1. 206. 206. #unknownBytecode }.
		  { 1. 207. 207. #unknownBytecode }.
		  { 1. 208. 208. #gen_StoreAndPopTemporaryVariableBytecode0 }.
		  { 1. 209. 209. #gen_StoreAndPopTemporaryVariableBytecode1 }.
		  { 1. 210. 210. #gen_StoreAndPopTemporaryVariableBytecode2 }.
		  { 1. 211. 211. #gen_StoreAndPopTemporaryVariableBytecode3 }.
		  { 1. 212. 212. #gen_StoreAndPopTemporaryVariableBytecode4 }.
		  { 1. 213. 213. #gen_StoreAndPopTemporaryVariableBytecode5 }.
		  { 1. 214. 214. #gen_StoreAndPopTemporaryVariableBytecode6 }.
		  { 1. 215. 215. #gen_StoreAndPopTemporaryVariableBytecode7 }.
		  { 1. 216. 216. #gen_PopStackBytecode. #needsFrameNever:.
		   -1 }.
		  { 1. 217. 217. #unknownBytecode }.
		  { 1. 218. 218. #unknownBytecode }.
		  { 1. 219. 219. #unknownBytecode }.
		  { 1. 220. 220. #unknownBytecode }.
		  { 1. 221. 221. #unknownBytecode }.
		  { 1. 222. 222. #unknownBytecode }.
		  { 1. 223. 223. #unknownBytecode }.
		  { 2. 224. 224. #gen_ExtABytecode. #extension }.
		  { 2. 225. 225. #gen_ExtBBytecode. #extension }.
		  { 2. 226. 226. #unknownBytecode }.
		  { 2. 227. 227. #gen_ExtPushLiteralVariableBytecode.
		  #needsFrameNever:. 1 }.
		  { 2. 228. 228. #gen_ExtPushLiteralBytecode.
		  #needsFrameNever:. 1 }.
		  { 2. 229. 229. #gen_LongPushTemporaryVariableBytecode }.
		  { 2. 230. 230. #unknownBytecode }.
		  { 2. 231. 231. #unknownBytecode }.
		  { 2. 232. 232. #gen_ExtPushIntegerBytecode.
		  #needsFrameNever:. 1 }.
		  { 2. 233. 233. #gen_ExtPushCharacterBytecode.
		  #needsFrameNever:. 1 }.
		  { 2. 234. 234. #gen_ExtSendBytecode. #isMapped }.
		  { 2. 235. 235. #unknownBytecode }.
		  { 2. 236. 236. #unknownBytecode }.
		  { 2. 237. 237. #gen_ExtUnconditionalJump. #branch. #isMapped.
		  #v4:Long:Branch:Distance: }.
		  { 2. 238. 238. #gen_ExtJumpIfTrue. #branch. #isBranchTrue.
		  #isMapped. #v4:Long:Branch:Distance: }.
		  { 2. 239. 239. #gen_ExtJumpIfFalse. #branch. #isBranchFalse.
		  #isMapped. #v4:Long:Branch:Distance: }.
		  { 2. 240. 240. #unknownBytecode }.
		  { 2. 241. 241. #unknownBytecode }.
		  { 2. 242. 242. #gen_LongStoreAndPopTemporaryVariableBytecode }.
		  { 2. 243. 243. #unknownBytecode }.
		  { 2. 244. 244. #unknownBytecode }.
		  { 2. 245. 245. #gen_LongStoreTemporaryVariableBytecode }.
		  { 2. 246. 246. #unknownBytecode }.
		  { 2. 247. 247. #unknownBytecode }.
		  { 3. 248. 248. #unknownBytecode }.
		  { 3. 249. 249. #unknownBytecode }.
		  { 3. 250. 250. #unknownBytecode }.
		  { 3. 251. 251. #gen_PushRemoteTempLongBytecode }.
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
	MaxCompiledPrimitiveIndex := 15.
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
		  { 9. #gen_PrimitiveMultiply. 1 }.
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
	aBlock value: 16 value: objectMemory baseHeaderSize + 1 "zero-relative"
]

{ #category : #'trait candidates' }
DruidJIT >> cacheTagIsMarked: cacheTag [
	"Answer if the cacheTag is not unmarked, i.e. answer true for compact class
	 indices and immediates; only answer false for unmarked objects.  In Spur
	 linked send cache tags are class indices so effectively they're always marked."
	^true
]

{ #category : #accessing }
DruidJIT >> ceStoreCheckTrampoline: anAddress [

	<doNotGenerate>
	ceStoreCheckTrampoline := anAddress
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
	  and: [self oop: literal isGreaterThanOrEqualTo: objectMemory getMemoryMap startOfObjectMemory]
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
DruidJIT >> genCheckObjectPosition: destReg scratchReg: scratchReg valueReg: valueReg results: resultBlock [ 

	| isDestYoung isOldAndOld isPermAndPerm recvIsPerm exit valueIsMachineCode| 

	<inline: true>
	<var: #recvIsPerm type: #'AbstractInstruction *'>
	<var: #exit type: #'AbstractInstruction *'>

	self CmpCq: objectMemory getMemoryMap getNewSpaceStart  R: valueReg.
	valueIsMachineCode := self JumpBelow: 0.
	
	self CmpCq: objectMemory getMemoryMap fixedPermSpaceStart R: destReg.
	recvIsPerm := self JumpAboveOrEqual: 0.

	self CmpCq: objectMemory getMemoryMap getOldSpaceStart R: destReg.
	isDestYoung := self JumpBelow: 0.

	self CmpCq: objectMemory getMemoryMap getOldSpaceStart R: valueReg.
	isOldAndOld := self JumpAboveOrEqual: 0.
	exit := self Jump: 0.

	recvIsPerm jmpTarget: (self Label).
	self CmpCq: objectMemory getMemoryMap fixedPermSpaceStart R: valueReg.
	isPermAndPerm := self JumpAbove: 0.

	exit jmpTarget: (self Label).
		
	resultBlock value: isDestYoung value: isOldAndOld value: isPermAndPerm value: valueIsMachineCode.
	^ 0 
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
DruidJIT >> genJumpTo: targetBytecodePC [

	deadCode := true. "can't fall through"
	self ssFlushStack.
	self Jump: (self ensureFixupAt: targetBytecodePC).
	^ 0
]

{ #category : #'trait candidates' }
DruidJIT >> genJumpTo: targetBytecodePC followDeadCode: followDeadCode [

	| eventualTarget fixup |
	eventualTarget := self eventualTargetOf: targetBytecodePC.
	self ssFlushTo: simStackPtr.
	fixup := self ensureFixupAt: eventualTarget.
	deadCode := followDeadCode.
	self Jump: fixup.
	^ 0
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

	| jmpImmediate jmpDestYoung jmpOldAndOld jmpPermAndPerm jmpAlreadyRemembered jmpIsMachineCode|

	<var: #jmpImmediate type: #'AbstractInstruction *'>
	<var: #jmpDestYoung type: #'AbstractInstruction *'>
	<var: #jmpOldAndOld type: #'AbstractInstruction *'>
	<var: #jmpPermAndPerm type: #'AbstractInstruction *'>
	<var: #jmpAlreadyRemembered type: #'AbstractInstruction *'>
	<var: #jmpIsMachineCode type: #'AbstractInstruction *'>


	"Is value stored an immediate?  If so we're done"
	jmpImmediate := self genJumpImmediate: valueReg.

	self 
		genCheckObjectPosition: destReg 
		scratchReg: scratchReg 
		valueReg: valueReg
		results: [ :isDestYoung :isOldAndOld :isPermAndPerm :valueIsMachineCode | 
			jmpDestYoung := isDestYoung.
			jmpOldAndOld := isOldAndOld.
			jmpIsMachineCode := valueIsMachineCode.
			jmpPermAndPerm := isPermAndPerm].


	"Need to remember this only if the remembered bit is not already set."
	CheckRememberedInTrampoline ifFalse:
		[jmpAlreadyRemembered := self genCheckRememberedBitOf: destReg scratch: scratchReg].
	"Remembered bit is not set.  Call store check to insert dest into remembered table."
	self assert: destReg = ReceiverResultReg.
	self 
		evaluateTrampolineCallBlock: [self CallRT: ceStoreCheckTrampoline]
		protectLinkRegIfNot: inFrame.
	jmpImmediate jmpTarget:
	(jmpDestYoung jmpTarget:
	(jmpIsMachineCode jmpTarget:
	(jmpOldAndOld jmpTarget: 
	(jmpPermAndPerm jmpTarget:
		self Label)))).

	CheckRememberedInTrampoline ifFalse:
		[jmpAlreadyRemembered jmpTarget: jmpOldAndOld getJmpTarget].
	^0
]

{ #category : #'trait candidates' }
DruidJIT >> genStoreCheckTrampoline [
	| jumpSC |
	<var: #jumpSC type: #'AbstractInstruction *'>
	<inline: true>
	
	CheckRememberedInTrampoline ifTrue:
		[self zeroOpcodeIndex.
		 jumpSC := self genCheckRememberedBitOf: ReceiverResultReg scratch: self backEnd cResultRegister.
		 self assert: jumpSC opcode = JumpNonZero.
		 jumpSC opcode: JumpZero.
		 self RetN: 0.
		 jumpSC jmpTarget: self Label].
	^self
		genTrampolineFor: #rememberObjInCorrectRememberedSet:
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
	 There is no reason why registers cannot be saved over the rememberObjInCorrectRememberedSet: call, but since the
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
	^ self genTrampolineFor: #rememberObjInCorrectRememberedSet:
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
	| immutableJump jmpImmediate jmpDestYoung jmpOldAndOld jmpPermAndPerm jmpAlreadyRemembered jmpIsMachineCode|
	<var: #immutableJump type: #'AbstractInstruction *'>
	<var: #jmpImmediate type: #'AbstractInstruction *'>
	<var: #jmpDestYoung type: #'AbstractInstruction *'>
	<var: #jmpOldAndOld type: #'AbstractInstruction *'>
	<var: #jmpPermAndPerm type: #'AbstractInstruction *'>
	<var: #jmpAlreadyRemembered type: #'AbstractInstruction *'>
	<var: #jmpIsMachineCode type: #'AbstractInstruction *'>

	immutableJump := self genJumpImmutable: destReg scratchReg: scratchReg.
	
	self genTraceStores.
	
	"do the store"
	self MoveR: sourceReg
		   Mw: index * objectMemory wordSize + objectMemory baseHeaderSize
		   r: destReg.

	"store check"
	jmpImmediate := self genJumpImmediate: sourceReg.

	self 
		genCheckObjectPosition: destReg 
		scratchReg: scratchReg 
		valueReg: sourceReg
		results: [ :isDestYoung :isOldAndOld :isPermAndPerm :valueIsMachineCode| 
			jmpDestYoung := isDestYoung.
			jmpOldAndOld := isOldAndOld.
			jmpIsMachineCode := valueIsMachineCode.			
			jmpPermAndPerm := isPermAndPerm].

	"Need to remember this only if the remembered bit is not already set."
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
	(jmpOldAndOld jmpTarget:
	(jmpIsMachineCode jmpTarget:
	(jmpPermAndPerm jmpTarget:
		self Label)))).
	CheckRememberedInTrampoline ifFalse:
		[jmpAlreadyRemembered jmpTarget: jmpOldAndOld getJmpTarget].
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

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -1
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimAt [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -17
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimAtEnd [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: -22
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimAtPut [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 2.
	self
		genMarshalledSend: -18
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimBitAnd [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -15
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimBitOr [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -16
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimBitShift [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -13
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimDiv [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -14
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimDivide [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -10
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimDo [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -28
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimEqualSistaV1 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -7
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimGreaterOrEqualSistaV1 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -6
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimGreaterThanSistaV1 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -4
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimIdenticalSistaV1 [
	"AutoGenerated by Druid"

	| t2 t3 t4 t5 t6 t7 t8 jumpTrue t20 t9 t21 t22 b456 t10 t23 t11 t24 t12 t25 t13 t26 t14 t27 t15 jump1 t28 t16 jump2 t29 t17 jump3 t18 jump4 b461 t0 currentBlock t19 t1 jumpNext |
	t0 := self allocateRegNotConflictingWith: 0.
	(self ssValue: 1) moveToReg: t0.
	t1 := self allocateRegNotConflictingWith: 0.
	(self ssValue: 0) moveToReg: t1.
	t2 := self allocateRegNotConflictingWith: 0.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpZero: 0.
	t3 := self allocateRegNotConflictingWith: 0.
	self MoveCq: 0 R: t3.
	t4 := self allocateRegNotConflictingWith: 0.
	self MoveR: t3 R: t4.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	t5 := self allocateRegNotConflictingWith: 0.
	self MoveM64: 0 r: t0 R: t5.
	self AndCq: 16r3FFFF7 R: t5.
	t6 := self allocateRegNotConflictingWith: 0.
	self CmpCq: 0 R: t5.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t6.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t6.
	jumpNext jmpTarget: self Label.
	self MoveR: t6 R: t4.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 0 R: t4.
	jump2 := self JumpNonZero: 0.
	t7 := self allocateRegNotConflictingWith: 0.
	self MoveR: t0 R: t7.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	t8 := self allocateRegNotConflictingWith: 0.
	self MoveM64: 8 r: t0 R: t8.
	t9 := self allocateRegNotConflictingWith: 0.
	self MoveR: t8 R: t9.
	b456 := self Label.
	t10 := self allocateRegNotConflictingWith: 0.
	self MoveR: t9 R: t10.
	self AndCq: 7 R: t10.
	self CmpCq: 0 R: t10.
	jump2 := self JumpZero: 0.
	t11 := self allocateRegNotConflictingWith: 0.
	self MoveCq: 0 R: t11.
	t12 := self allocateRegNotConflictingWith: 0.
	self MoveR: t11 R: t12.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	t13 := self allocateRegNotConflictingWith: 0.
	self MoveM64: 0 r: t9 R: t13.
	self AndCq: 16r3FFFF7 R: t13.
	t14 := self allocateRegNotConflictingWith: 0.
	self CmpCq: 0 R: t13.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t14.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t14.
	jumpNext jmpTarget: self Label.
	self MoveR: t14 R: t12.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpCq: 0 R: t12.
	jump3 := self JumpNonZero: 0.
	self MoveR: t9 R: t7.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	t15 := self allocateRegNotConflictingWith: 0.
	self MoveR: t1 R: t15.
	self AndCq: 7 R: t15.
	self CmpCq: 0 R: t15.
	jump1 := self JumpZero: 0.
	t16 := self allocateRegNotConflictingWith: 0.
	self MoveCq: 0 R: t16.
	t17 := self allocateRegNotConflictingWith: 0.
	self MoveR: t16 R: t17.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	t18 := self allocateRegNotConflictingWith: 0.
	self MoveM64: 0 r: t1 R: t18.
	self AndCq: 16r3FFFF7 R: t18.
	t19 := self allocateRegNotConflictingWith: 0.
	self CmpCq: 0 R: t18.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t19.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t19.
	jumpNext jmpTarget: self Label.
	self MoveR: t19 R: t17.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 0 R: t17.
	jump2 := self JumpNonZero: 0.
	t20 := self allocateRegNotConflictingWith: 0.
	self MoveR: t1 R: t20.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	t21 := self allocateRegNotConflictingWith: 0.
	self MoveM64: 8 r: t1 R: t21.
	t22 := self allocateRegNotConflictingWith: 0.
	self MoveR: t21 R: t22.
	b461 := self Label.
	t23 := self allocateRegNotConflictingWith: 0.
	self MoveR: t22 R: t23.
	self AndCq: 7 R: t23.
	self CmpCq: 0 R: t23.
	jump2 := self JumpZero: 0.
	t24 := self allocateRegNotConflictingWith: 0.
	self MoveCq: 0 R: t24.
	t25 := self allocateRegNotConflictingWith: 0.
	self MoveR: t24 R: t25.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	t26 := self allocateRegNotConflictingWith: 0.
	self MoveM64: 0 r: t22 R: t26.
	self AndCq: 16r3FFFF7 R: t26.
	t27 := self allocateRegNotConflictingWith: 0.
	self CmpCq: 0 R: t26.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t27.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t27.
	jumpNext jmpTarget: self Label.
	self MoveR: t27 R: t25.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 0 R: t25.
	jump4 := self JumpNonZero: 0.
	self MoveR: t22 R: t20.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self CmpR: t20 R: t7.
	jump1 := self JumpZero: 0.
	self ssPushConstant: objectMemory falseObject.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssPushConstant: objectMemory trueObject.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	t28 := self allocateRegNotConflictingWith: 0.
	self MoveM64: 8 r: t22 R: t28.
	self MoveR: t28 R: t22.
	jump4 := self Jump: b461.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	t29 := self allocateRegNotConflictingWith: 0.
	self MoveM64: 8 r: t9 R: t29.
	self MoveR: t29 R: t9.
	jump3 := self Jump: b456.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimLessOrEqualSistaV1 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -5
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimLessThanSistaV1 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -3
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimMakePoint [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -12
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimMod [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -11
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimMultiply [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -9
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimNew [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: -29
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimNewWithArg [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -30
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimNext [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: -20
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimNextPut [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -21
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimNotEqualSistaV1 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -8
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimNotIdenticalSistaV1 [
	"AutoGenerated by Druid"

	| t2 t3 t4 t5 t6 t7 t8 jumpTrue t20 t9 t21 t22 b456 t10 t23 t11 t24 t12 t25 t13 t26 t14 t27 t15 jump1 t28 t16 jump2 t29 t17 jump3 t18 jump4 b461 t0 currentBlock t19 t1 jumpNext |
	t0 := self allocateRegNotConflictingWith: 0.
	(self ssValue: 1) moveToReg: t0.
	t1 := self allocateRegNotConflictingWith: 0.
	(self ssValue: 0) moveToReg: t1.
	t2 := self allocateRegNotConflictingWith: 0.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpZero: 0.
	t3 := self allocateRegNotConflictingWith: 0.
	self MoveCq: 0 R: t3.
	t4 := self allocateRegNotConflictingWith: 0.
	self MoveR: t3 R: t4.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	t5 := self allocateRegNotConflictingWith: 0.
	self MoveM64: 0 r: t0 R: t5.
	self AndCq: 16r3FFFF7 R: t5.
	t6 := self allocateRegNotConflictingWith: 0.
	self CmpCq: 0 R: t5.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t6.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t6.
	jumpNext jmpTarget: self Label.
	self MoveR: t6 R: t4.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 0 R: t4.
	jump2 := self JumpNonZero: 0.
	t7 := self allocateRegNotConflictingWith: 0.
	self MoveR: t0 R: t7.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	t8 := self allocateRegNotConflictingWith: 0.
	self MoveM64: 8 r: t0 R: t8.
	t9 := self allocateRegNotConflictingWith: 0.
	self MoveR: t8 R: t9.
	b456 := self Label.
	t10 := self allocateRegNotConflictingWith: 0.
	self MoveR: t9 R: t10.
	self AndCq: 7 R: t10.
	self CmpCq: 0 R: t10.
	jump2 := self JumpZero: 0.
	t11 := self allocateRegNotConflictingWith: 0.
	self MoveCq: 0 R: t11.
	t12 := self allocateRegNotConflictingWith: 0.
	self MoveR: t11 R: t12.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	t13 := self allocateRegNotConflictingWith: 0.
	self MoveM64: 0 r: t9 R: t13.
	self AndCq: 16r3FFFF7 R: t13.
	t14 := self allocateRegNotConflictingWith: 0.
	self CmpCq: 0 R: t13.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t14.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t14.
	jumpNext jmpTarget: self Label.
	self MoveR: t14 R: t12.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpCq: 0 R: t12.
	jump3 := self JumpNonZero: 0.
	self MoveR: t9 R: t7.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	t15 := self allocateRegNotConflictingWith: 0.
	self MoveR: t1 R: t15.
	self AndCq: 7 R: t15.
	self CmpCq: 0 R: t15.
	jump1 := self JumpZero: 0.
	t16 := self allocateRegNotConflictingWith: 0.
	self MoveCq: 0 R: t16.
	t17 := self allocateRegNotConflictingWith: 0.
	self MoveR: t16 R: t17.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	t18 := self allocateRegNotConflictingWith: 0.
	self MoveM64: 0 r: t1 R: t18.
	self AndCq: 16r3FFFF7 R: t18.
	t19 := self allocateRegNotConflictingWith: 0.
	self CmpCq: 0 R: t18.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t19.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t19.
	jumpNext jmpTarget: self Label.
	self MoveR: t19 R: t17.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 0 R: t17.
	jump2 := self JumpNonZero: 0.
	t20 := self allocateRegNotConflictingWith: 0.
	self MoveR: t1 R: t20.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	t21 := self allocateRegNotConflictingWith: 0.
	self MoveM64: 8 r: t1 R: t21.
	t22 := self allocateRegNotConflictingWith: 0.
	self MoveR: t21 R: t22.
	b461 := self Label.
	t23 := self allocateRegNotConflictingWith: 0.
	self MoveR: t22 R: t23.
	self AndCq: 7 R: t23.
	self CmpCq: 0 R: t23.
	jump2 := self JumpZero: 0.
	t24 := self allocateRegNotConflictingWith: 0.
	self MoveCq: 0 R: t24.
	t25 := self allocateRegNotConflictingWith: 0.
	self MoveR: t24 R: t25.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	t26 := self allocateRegNotConflictingWith: 0.
	self MoveM64: 0 r: t22 R: t26.
	self AndCq: 16r3FFFF7 R: t26.
	t27 := self allocateRegNotConflictingWith: 0.
	self CmpCq: 0 R: t26.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t27.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t27.
	jumpNext jmpTarget: self Label.
	self MoveR: t27 R: t25.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 0 R: t25.
	jump4 := self JumpNonZero: 0.
	self MoveR: t22 R: t20.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self CmpR: t20 R: t7.
	jump1 := self JumpNonZero: 0.
	self ssPushConstant: objectMemory falseObject.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssPushConstant: objectMemory trueObject.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	t28 := self allocateRegNotConflictingWith: 0.
	self MoveM64: 8 r: t22 R: t28.
	self MoveR: t28 R: t22.
	jump4 := self Jump: b461.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	t29 := self allocateRegNotConflictingWith: 0.
	self MoveM64: 8 r: t9 R: t29.
	self MoveR: t29 R: t9.
	jump3 := self Jump: b456.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimPointX [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: -31
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimPointY [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: -32
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimSize [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: -19
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimSubtract [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -2
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimValue [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: -26
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_BytecodePrimValueWithArg [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: -27
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_DuplicateTopBytecode [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtABytecode [
	"AutoGenerated by Druid"

	| live r1 currentBlock |
	live := 0.
	r1 := extA.
	extA := r1 << 8 + byte1.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtBBytecode [
	"AutoGenerated by Druid"

	| r54 r4 currentBlock live r115 |
	live := 0.
	r4 := numExtB.
	r4=0 ifTrue: [
		| r115 r54 |
		(byte1 > 127)=true ifTrue: [
			| r115 |
			extB := byte1 - 256.
			r115 := numExtB.
			numExtB := r115 + 1.
			^ 0 ].
		r54 := extB.
		extB := r54 << 8 + byte1.
		r115 := numExtB.
		numExtB := r115 + 1.
		^ 0 ].
	r54 := extB.
	extB := r54 << 8 + byte1.
	r115 := numExtB.
	numExtB := r115 + 1.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtJumpIfFalse [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock r3 live jump2 |
	live := 0.
	r3 := extB.
	extA := 0.
	extB := 0.
	numExtB := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory falseObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory trueObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump:
		(self ensureFixupAt: bytecodePC + 1 + (byte1 + (r3 << 8)) + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtJumpIfTrue [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock r3 live jump2 |
	live := 0.
	r3 := extB.
	extA := 0.
	extB := 0.
	numExtB := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory trueObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory falseObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump:
		(self ensureFixupAt: bytecodePC + 1 + (byte1 + (r3 << 8)) + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtNopBytecode [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	extB := 0.
	extA := 0.
	numExtB := 0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtPushCharacterBytecode [
	"AutoGenerated by Druid"

	| live r2 currentBlock |
	live := 0.
	r2 := extB.
	self ssPushConstant: (((byte1 + (r2 << 8)) << 3) + 2).
	extB := 0.
	numExtB := 0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtPushIntegerBytecode [
	"AutoGenerated by Druid"

	| live r2 currentBlock |
	live := 0.
	r2 := extB.
	extB := 0.
	numExtB := 0.
	self ssPushConstant: (((byte1 + (r2 << 8)) << 3) + 1).
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtPushLiteralBytecode [
	"AutoGenerated by Druid"

	| live r2 currentBlock t0 |
	live := 0.
	r2 := extA.
	extA := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: byte1 + (r2 << 8) + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtPushLiteralVariableBytecode [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue r2 jump2 t2 live |
	live := 0.
	r2 := extA.
	extA := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: byte1 + (r2 << 8) + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtSendBytecode [
	"AutoGenerated by Druid"

	| live r5 r13 currentBlock |
	live := 0.
	r5 := extA.
	extA := 0.
	r13 := extB.
	extB := 0.
	numExtB := 0.
	self marshallSendArguments: ((byte1 bitAnd: 7) + (r13 << 3)).
	self
		genMarshalledSend: ((byte1 >> 3) + (r5 << 5))
		numArgs: ((byte1 bitAnd: 7) + (r13 << 3))
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtSendSuperBytecode [
	"AutoGenerated by Druid"

	| live r5 r43 currentBlock |
	live := 0.
	r5 := extA.
	extA := 0.
	BytecodeSetHasDirectedSuperSend=true ifTrue: [
		| r12 r43 |
		r12 := extB.
		r12>=64 ifTrue: [
			| r17 |
			r17 := extB.
			extB := 0.
			numExtB := 0.
			self marshallSendArguments: ((byte1 bitAnd: 7) + ((r17 - 64) << 3)).
			self
				genMarshalledSend: ((byte1 >> 3) + (r5 << 5))
				numArgs: ((byte1 bitAnd: 7) + ((r17 - 64) << 3))
				sendTable: (directedSendUsesBinding
								ifTrue: [directedSuperBindingSendTrampolines]
								ifFalse: [directedSuperSendTrampolines]).
			^ 0 ].
		r43 := extB.
		extB := 0.
		numExtB := 0.
		self marshallSendArguments: ((byte1 bitAnd: 7) + (r43 << 3)).
		self
			genMarshalledSend: ((byte1 >> 3) + (r5 << 5))
			numArgs: ((byte1 bitAnd: 7) + (r43 << 3))
			sendTable: superSendTrampolines.
		^ 0 ].
	r43 := extB.
	extB := 0.
	numExtB := 0.
	self marshallSendArguments: ((byte1 bitAnd: 7) + (r43 << 3)).
	self
		genMarshalledSend: ((byte1 >> 3) + (r5 << 5))
		numArgs: ((byte1 bitAnd: 7) + (r43 << 3))
		sendTable: superSendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtUnconditionalJump [
	"AutoGenerated by Druid"

	| t0 jump1 t1 currentBlock r3 live jump2 |
	live := 0.
	r3 := extB.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveCq: (byte1 + (r3 << 8)) R: t0.
	(byte1 + (r3 << 8))<0 ifTrue: [
		| r11 jump1 jump2 t1 |
		r11 := numExtB.
		self MoveCq: (r11 * 2) R: t0.
		extB := 0.
		numExtB := 0.
		self AddCq: (byte1 + (r3 << 8)) R: t0.
		self ssFlushStack.
		self CmpCq: 0 R: t0.
		jump1 := self JumpGreaterOrEqual: 0.
		self MoveR: SPReg R: t0.
		t1 := self
			      allocateRegNotConflictingWith: live
			      ifNone: [ ^ self unknownBytecode ].
		live := live bitOr: (self registerMaskFor: t1).
		self MoveAw: coInterpreter stackLimitAddress R: t1.
		self CmpR: t1 R: t0.
		jump2 := self JumpAboveOrEqual: 0.
		self CallRT: ceCheckForInterruptTrampoline.
		self annotateBytecode: self Label.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		jump2 jmpTarget: currentBlock.
		self Jump:
			(self ensureFixupAt: bytecodePC + 1 + (byte1 + (r3 << 8)) + 1).
		deadCode := true.
		^ 0 ].
	self MoveCq: 0 R: t0.
	extB := 0.
	numExtB := 0.
	self AddCq: (byte1 + (r3 << 8)) R: t0.
	self ssFlushStack.
	self CmpCq: 0 R: t0.
	jump2 := self JumpGreaterOrEqual: 0.
	self MoveR: SPReg R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveAw: coInterpreter stackLimitAddress R: t1.
	self CmpR: t1 R: t0.
	jump1 := self JumpAboveOrEqual: 0.
	self CallRT: ceCheckForInterruptTrampoline.
	self annotateBytecode: self Label.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	self Jump:
		(self ensureFixupAt: bytecodePC + 1 + (byte1 + (r3 << 8)) + 1).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_LongPushTemporaryVariableBytecode [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: byte1) copyToReg: t0.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_LongStoreAndPopTemporaryVariableBytecode [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssFlushUpThroughTemporaryVariable: byte1.
	self MoveR: t0 Mw: (self frameOffsetOfTemporary: byte1) r: FPReg.
	self ssPop: 1.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_LongStoreTemporaryVariableBytecode [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssFlushUpThroughTemporaryVariable: byte1.
	self MoveR: t0 Mw: (self frameOffsetOfTemporary: byte1) r: FPReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PopStackBytecode [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self ssPop: 1.
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
		Quo: SendNumArgsReg
		Rem: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self
		DivR: ClassReg
		R: TempReg
		Quo: SendNumArgsReg
		Rem: Extra0Reg.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self ArithmeticShiftRightCq: 60 R: Extra0Reg.
	self AddCq: 1 R: Extra0Reg.
	self AndCq: 15 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump5 := self JumpGreater: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 3 R: Extra0Reg.
	self AddCq: 1 R: Extra0Reg.
	self MoveR: Extra0Reg R: ReceiverResultReg.
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
		Quo: Extra2Reg
		Rem: ClassReg.
	self MoveCq: 8 R: ClassReg.
	self SubR: TempReg R: ClassReg.
	self AndCq: 7 R: ClassReg.
	self AddR: ClassReg R: SendNumArgsReg.
	self MoveR: Extra2Reg R: ClassReg.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self MoveR: TempReg R: ClassReg.
	self AddCq: 3 R: ClassReg.
	self MoveCq: 4 R: Extra2Reg.
	self
		DivR: Extra2Reg
		R: ClassReg
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
		Quo: Extra2Reg
		Rem: ClassReg.
	self AndCq: 1 R: TempReg.
	self AddR: TempReg R: SendNumArgsReg.
	self MoveCq: 0 R: TempReg.
	self MoveR: Extra2Reg R: ClassReg.
	self MoveR: TempReg R: Extra2Reg.
	currentBlock := self Label.
	jump13 jmpTarget: currentBlock.
	self MoveR: ClassReg R: TempReg.
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
	self MoveR: ClassReg R: TempReg.
	self MoveR: Extra1Reg R: Extra2Reg.
	currentBlock := self Label.
	jump13 jmpTarget: currentBlock.
	self MoveR: TempReg R: Extra3Reg.
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
DruidJIT >> gen_PushConstantFalseBytecode [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self ssPushConstant: objectMemory falseObject.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushConstantNilBytecode [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self ssPushConstant: objectMemory nilObject.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushConstantOneBytecode [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self ssPushConstant: ConstOne.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushConstantTrueBytecode [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self ssPushConstant: objectMemory trueObject.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushConstantZeroBytecode [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
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

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 0 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode1 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 1 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode10 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 10 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode11 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 11 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode12 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 12 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode13 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 13 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode14 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 14 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode15 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 15 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode16 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 16 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode17 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 17 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode18 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 18 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode19 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 19 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode2 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 2 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode20 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 20 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode21 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 21 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode22 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 22 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode23 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 23 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode24 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 24 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode25 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 25 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode26 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 26 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode27 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 27 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode28 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 28 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode29 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 29 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode3 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 3 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode30 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 30 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode31 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 31 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode4 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 4 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode5 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 5 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode6 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 6 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode7 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 7 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode8 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 8 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode9 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self ssPushBase: t0 offset: 9 + LiteralStart << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode0 [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue jump2 t2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: 0 + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode1 [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue jump2 t2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: 1 + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode10 [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue jump2 t2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: 10 + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode11 [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue jump2 t2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: 11 + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode12 [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue jump2 t2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: 12 + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode13 [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue jump2 t2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: 13 + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode14 [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue jump2 t2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: 14 + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode15 [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue jump2 t2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: 15 + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode2 [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue jump2 t2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: 2 + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode3 [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue jump2 t2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: 3 + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode4 [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue jump2 t2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: 4 + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode5 [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue jump2 t2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: 5 + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode6 [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue jump2 t2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: 6 + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode7 [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue jump2 t2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: 7 + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode8 [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue jump2 t2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: 8 + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode9 [
	"AutoGenerated by Druid"

	| jump1 jumpNext b232 t1 jump3 currentBlock t0 jumpTrue jump2 t2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	self MoveM64: 9 + LiteralStart << 3 + 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t1.
	self MoveR: t1 R: t0.
	b232 := self Label.
	self MoveR: t0 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t1 R: t2.
	self CmpCq: 0 R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: t1.
	jump3 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: t0 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushBase: t1 offset: ValueIndex << 3 + 8.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveM64: 8 r: t0 R: t2.
	self MoveR: t2 R: t0.
	jump3 := self Jump: b232.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverBytecode [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode0 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode1 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: t0 offset: 16.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode10 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: t0 offset: 88.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode11 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: t0 offset: 96.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode12 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: t0 offset: 104.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode13 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: t0 offset: 112.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode14 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: t0 offset: 120.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode15 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: t0 offset: 128.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode2 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: t0 offset: 24.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode3 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: t0 offset: 32.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode4 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: t0 offset: 40.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode5 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: t0 offset: 48.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode6 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: t0 offset: 56.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode7 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: t0 offset: 64.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode8 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: t0 offset: 72.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushReceiverVariableBytecode9 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self ssPushBase: t0 offset: 80.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushRemoteTempLongBytecode [
	"AutoGenerated by Druid"

	| live t1 currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: byte2) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveCq: 1 R: t1.
	true=TempVectReadBarrier ifTrue: [
		| jumpTrue jumpNext jump1 jump3 jump2 b198 t2 |
		self MoveM64: 0 r: t0 R: t1.
		self AndCq: 16r3FFFF7 R: t1.
		self CmpCq: 0 R: t1.
		jump1 := self JumpZero: 0.
		self MoveR: t0 R: t1.
		jump2 := self Jump: 0.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		self MoveM64: 8 r: t0 R: t1.
		self MoveR: t1 R: t0.
		b198 := self Label.
		self MoveR: t0 R: t1.
		self AndCq: 7 R: t1.
		self CmpCq: 0 R: t1.
		jump1 := self JumpNonZero: 0.
		self MoveM64: 0 r: t0 R: t1.
		self AndCq: 16r3FFFF7 R: t1.
		t2 := self
			      allocateRegNotConflictingWith: live
			      ifNone: [ ^ self unknownBytecode ].
		live := live bitOr: (self registerMaskFor: t2).
		self MoveR: t1 R: t2.
		self CmpCq: 0 R: t2.
		jumpTrue := self JumpZero: 0.
		self MoveCq: 0 R: t2.
		jumpNext := self Jump: 0.
		jumpTrue jmpTarget: self Label.
		self MoveCq: 1 R: t2.
		jumpNext jmpTarget: self Label.
		self CmpCq: 0 R: t1.
		jump3 := self JumpZero: 0.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		self MoveR: t0 R: t1.
		currentBlock := self Label.
		jump2 jmpTarget: currentBlock.
		jump2 := self Jump: 0.
		currentBlock := self Label.
		jump3 jmpTarget: currentBlock.
		self MoveM64: 8 r: t0 R: t2.
		self MoveR: t2 R: t0.
		jump3 := self Jump: b198.
		currentBlock := self Label.
		jump2 jmpTarget: currentBlock.
		self ssPushBase: t1 offset: byte1 << 3 + 8.
		^ 0 ].
	self MoveR: t0 R: t1.
	self ssPushBase: t1 offset: byte1 << 3 + 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushTemporaryVariableBytecode0 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: 0) copyToReg: t0.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushTemporaryVariableBytecode1 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: 1) copyToReg: t0.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushTemporaryVariableBytecode10 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: 10) copyToReg: t0.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushTemporaryVariableBytecode11 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: 11) copyToReg: t0.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushTemporaryVariableBytecode2 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: 2) copyToReg: t0.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushTemporaryVariableBytecode3 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: 3) copyToReg: t0.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushTemporaryVariableBytecode4 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: 4) copyToReg: t0.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushTemporaryVariableBytecode5 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: 5) copyToReg: t0.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushTemporaryVariableBytecode6 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: 6) copyToReg: t0.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushTemporaryVariableBytecode7 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: 7) copyToReg: t0.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushTemporaryVariableBytecode8 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: 8) copyToReg: t0.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushTemporaryVariableBytecode9 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: 9) copyToReg: t0.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ReturnFalse [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: objectMemory falseObject R: t0.
	self MoveR: t0 R: ReceiverResultReg.
	self genUpArrowReturn.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ReturnNil [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: objectMemory nilObject R: t0.
	self MoveR: t0 R: ReceiverResultReg.
	self genUpArrowReturn.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ReturnNilFromBlock [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: objectMemory nilObject R: t0.
	self MoveR: t0 R: ReceiverResultReg.
	self genBlockReturn.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ReturnReceiver [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	self MoveR: t0 R: ReceiverResultReg.
	self genUpArrowReturn.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ReturnTopFromBlock [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self MoveR: t0 R: ReceiverResultReg.
	self genBlockReturn.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ReturnTopFromMethod [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self MoveR: t0 R: ReceiverResultReg.
	self genUpArrowReturn.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ReturnTrue [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: objectMemory trueObject R: t0.
	self MoveR: t0 R: ReceiverResultReg.
	self genUpArrowReturn.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode0 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 1
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode10 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 10
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode11 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 11
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode12 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 12
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode13 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 13
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode14 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 14
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode15 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 15
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode2 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 6
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode7 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 7
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode8 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 8
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector0ArgsBytecode9 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 0.
	self
		genMarshalledSend: 9
		numArgs: 0
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode0 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 1
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode10 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 10
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode11 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 11
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode12 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 12
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode13 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 13
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode14 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 14
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode15 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 15
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode2 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 6
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode7 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 7
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode8 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 8
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector1ArgBytecode9 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 1.
	self
		genMarshalledSend: 9
		numArgs: 1
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode0 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 1
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode10 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 10
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode11 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 11
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode12 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 12
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode13 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 13
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode14 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 14
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode15 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 15
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode2 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
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

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 8
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_SendLiteralSelector2ArgsBytecode9 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self marshallSendArguments: 2.
	self
		genMarshalledSend: 9
		numArgs: 2
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpFalse0 [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock jump2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory falseObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory trueObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 1 + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpFalse1 [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock jump2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory falseObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory trueObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 2 + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpFalse2 [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock jump2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory falseObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory trueObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 3 + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpFalse3 [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock jump2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory falseObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory trueObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 4 + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpFalse4 [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock jump2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory falseObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory trueObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 5 + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpFalse5 [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock jump2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory falseObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory trueObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 6 + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpFalse6 [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock jump2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory falseObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory trueObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 7 + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpFalse7 [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock jump2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory falseObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory trueObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 8 + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpTrue0 [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock jump2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory trueObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory falseObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 1 + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpTrue1 [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock jump2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory trueObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory falseObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 2 + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpTrue2 [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock jump2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory trueObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory falseObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 3 + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpTrue3 [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock jump2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory trueObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory falseObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 4 + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpTrue4 [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock jump2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory trueObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory falseObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 5 + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpTrue5 [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock jump2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory trueObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory falseObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 6 + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpTrue6 [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock jump2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory trueObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory falseObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 7 + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpTrue7 [
	"AutoGenerated by Druid"

	| t0 jump3 jump1 currentBlock jump2 live |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	self ssFlushStack.
	self CmpCq: objectMemory trueObject R: t0.
	jump1 := self JumpZero: 0.
	self CmpCq: objectMemory falseObject R: t0.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	self annotateBytecode: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 8 + 1).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortUnconditionalJump0 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self ssFlushStack.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 1 + 1).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortUnconditionalJump1 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self ssFlushStack.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 2 + 1).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortUnconditionalJump2 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self ssFlushStack.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 3 + 1).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortUnconditionalJump3 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self ssFlushStack.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 4 + 1).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortUnconditionalJump4 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self ssFlushStack.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 5 + 1).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortUnconditionalJump5 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self ssFlushStack.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 6 + 1).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortUnconditionalJump6 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self ssFlushStack.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 7 + 1).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortUnconditionalJump7 [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
	self ssFlushStack.
	self Jump: (self ensureFixupAt: bytecodePC + 0 + 8 + 1).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopReceiverVariableBytecode0 [
	"AutoGenerated by Druid"

	| jump1 jump7 jumpNext t1 jump6 jump3 currentBlock t0 jump5 jump2 jumpTrue live t2 jump4 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	self ssPop: 1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getOldSpaceMask R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getNewSpaceMask R: t2.
	jump4 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self CmpCq: objectMemory getMemoryMap getNewSpaceStart R: t2.
	jumpTrue := self JumpGreaterOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 1 R: t2.
	jump4 := self JumpZero: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self ArithmeticShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	self annotateBytecode: self Label.
	self TstCq: 7 R: t1.
	jump6 := self JumpNonZero: 0.
	jump7 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self TstCq: 7 R: t1.
	jump4 := self JumpNonZero: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: objectMemory nilObject R: t1.
	jump7 := self JumpAboveOrEqual: 0.
	self MoveCq: 0 R: t2.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self CmpCq: objectMemory trueObject R: t2.
	jumpTrue := self JumpLessOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 1 R: t2.
	jump5 := self JumpZero: 0.
	self CmpCq: objectMemory getMemoryMap getNewSpaceStart R: t1.
	jump7 := self JumpLess: 0.
	self MoveM64: 0 r: t0 R: t2.
	self ArithmeticShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveR: t0 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getPermSpaceMask R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self CmpCq: 1 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getPermSpaceMask R: t2.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	self annotateBytecode: self Label.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	self MoveR: t1 M64: 8 r: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopReceiverVariableBytecode1 [
	"AutoGenerated by Druid"

	| jump1 jump7 jumpNext t1 jump6 jump3 currentBlock t0 jump5 jump2 jumpTrue live t2 jump4 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	self ssPop: 1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getOldSpaceMask R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getNewSpaceMask R: t2.
	jump4 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self CmpCq: objectMemory getMemoryMap getNewSpaceStart R: t2.
	jumpTrue := self JumpGreaterOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 1 R: t2.
	jump4 := self JumpZero: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self ArithmeticShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	self annotateBytecode: self Label.
	self TstCq: 7 R: t1.
	jump6 := self JumpNonZero: 0.
	jump7 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self TstCq: 7 R: t1.
	jump4 := self JumpNonZero: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: objectMemory nilObject R: t1.
	jump7 := self JumpAboveOrEqual: 0.
	self MoveCq: 0 R: t2.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self CmpCq: objectMemory trueObject R: t2.
	jumpTrue := self JumpLessOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 1 R: t2.
	jump5 := self JumpZero: 0.
	self CmpCq: objectMemory getMemoryMap getNewSpaceStart R: t1.
	jump7 := self JumpLess: 0.
	self MoveM64: 0 r: t0 R: t2.
	self ArithmeticShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveR: t0 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getPermSpaceMask R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self CmpCq: 1 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getPermSpaceMask R: t2.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	self annotateBytecode: self Label.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	self MoveR: t1 M64: 16 r: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopReceiverVariableBytecode2 [
	"AutoGenerated by Druid"

	| jump1 jump7 jumpNext t1 jump6 jump3 currentBlock t0 jump5 jump2 jumpTrue live t2 jump4 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	self ssPop: 1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getOldSpaceMask R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getNewSpaceMask R: t2.
	jump4 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self CmpCq: objectMemory getMemoryMap getNewSpaceStart R: t2.
	jumpTrue := self JumpGreaterOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 1 R: t2.
	jump4 := self JumpZero: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self ArithmeticShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	self annotateBytecode: self Label.
	self TstCq: 7 R: t1.
	jump6 := self JumpNonZero: 0.
	jump7 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self TstCq: 7 R: t1.
	jump4 := self JumpNonZero: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: objectMemory nilObject R: t1.
	jump7 := self JumpAboveOrEqual: 0.
	self MoveCq: 0 R: t2.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self CmpCq: objectMemory trueObject R: t2.
	jumpTrue := self JumpLessOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 1 R: t2.
	jump5 := self JumpZero: 0.
	self CmpCq: objectMemory getMemoryMap getNewSpaceStart R: t1.
	jump7 := self JumpLess: 0.
	self MoveM64: 0 r: t0 R: t2.
	self ArithmeticShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveR: t0 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getPermSpaceMask R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self CmpCq: 1 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getPermSpaceMask R: t2.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	self annotateBytecode: self Label.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	self MoveR: t1 M64: 24 r: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopReceiverVariableBytecode3 [
	"AutoGenerated by Druid"

	| jump1 jump7 jumpNext t1 jump6 jump3 currentBlock t0 jump5 jump2 jumpTrue live t2 jump4 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	self ssPop: 1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getOldSpaceMask R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getNewSpaceMask R: t2.
	jump4 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self CmpCq: objectMemory getMemoryMap getNewSpaceStart R: t2.
	jumpTrue := self JumpGreaterOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 1 R: t2.
	jump4 := self JumpZero: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self ArithmeticShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	self annotateBytecode: self Label.
	self TstCq: 7 R: t1.
	jump6 := self JumpNonZero: 0.
	jump7 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self TstCq: 7 R: t1.
	jump4 := self JumpNonZero: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: objectMemory nilObject R: t1.
	jump7 := self JumpAboveOrEqual: 0.
	self MoveCq: 0 R: t2.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self CmpCq: objectMemory trueObject R: t2.
	jumpTrue := self JumpLessOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 1 R: t2.
	jump5 := self JumpZero: 0.
	self CmpCq: objectMemory getMemoryMap getNewSpaceStart R: t1.
	jump7 := self JumpLess: 0.
	self MoveM64: 0 r: t0 R: t2.
	self ArithmeticShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveR: t0 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getPermSpaceMask R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self CmpCq: 1 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getPermSpaceMask R: t2.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	self annotateBytecode: self Label.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	self MoveR: t1 M64: 32 r: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopReceiverVariableBytecode4 [
	"AutoGenerated by Druid"

	| jump1 jump7 jumpNext t1 jump6 jump3 currentBlock t0 jump5 jump2 jumpTrue live t2 jump4 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	self ssPop: 1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getOldSpaceMask R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getNewSpaceMask R: t2.
	jump4 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self CmpCq: objectMemory getMemoryMap getNewSpaceStart R: t2.
	jumpTrue := self JumpGreaterOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 1 R: t2.
	jump4 := self JumpZero: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self ArithmeticShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	self annotateBytecode: self Label.
	self TstCq: 7 R: t1.
	jump6 := self JumpNonZero: 0.
	jump7 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self TstCq: 7 R: t1.
	jump4 := self JumpNonZero: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: objectMemory nilObject R: t1.
	jump7 := self JumpAboveOrEqual: 0.
	self MoveCq: 0 R: t2.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self CmpCq: objectMemory trueObject R: t2.
	jumpTrue := self JumpLessOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 1 R: t2.
	jump5 := self JumpZero: 0.
	self CmpCq: objectMemory getMemoryMap getNewSpaceStart R: t1.
	jump7 := self JumpLess: 0.
	self MoveM64: 0 r: t0 R: t2.
	self ArithmeticShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveR: t0 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getPermSpaceMask R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self CmpCq: 1 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getPermSpaceMask R: t2.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	self annotateBytecode: self Label.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	self MoveR: t1 M64: 40 r: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopReceiverVariableBytecode5 [
	"AutoGenerated by Druid"

	| jump1 jump7 jumpNext t1 jump6 jump3 currentBlock t0 jump5 jump2 jumpTrue live t2 jump4 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	self ssPop: 1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getOldSpaceMask R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getNewSpaceMask R: t2.
	jump4 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self CmpCq: objectMemory getMemoryMap getNewSpaceStart R: t2.
	jumpTrue := self JumpGreaterOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 1 R: t2.
	jump4 := self JumpZero: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self ArithmeticShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	self annotateBytecode: self Label.
	self TstCq: 7 R: t1.
	jump6 := self JumpNonZero: 0.
	jump7 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self TstCq: 7 R: t1.
	jump4 := self JumpNonZero: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: objectMemory nilObject R: t1.
	jump7 := self JumpAboveOrEqual: 0.
	self MoveCq: 0 R: t2.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self CmpCq: objectMemory trueObject R: t2.
	jumpTrue := self JumpLessOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 1 R: t2.
	jump5 := self JumpZero: 0.
	self CmpCq: objectMemory getMemoryMap getNewSpaceStart R: t1.
	jump7 := self JumpLess: 0.
	self MoveM64: 0 r: t0 R: t2.
	self ArithmeticShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveR: t0 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getPermSpaceMask R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self CmpCq: 1 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getPermSpaceMask R: t2.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	self annotateBytecode: self Label.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	self MoveR: t1 M64: 48 r: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopReceiverVariableBytecode6 [
	"AutoGenerated by Druid"

	| jump1 jump7 jumpNext t1 jump6 jump3 currentBlock t0 jump5 jump2 jumpTrue live t2 jump4 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	self ssPop: 1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getOldSpaceMask R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getNewSpaceMask R: t2.
	jump4 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self CmpCq: objectMemory getMemoryMap getNewSpaceStart R: t2.
	jumpTrue := self JumpGreaterOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 1 R: t2.
	jump4 := self JumpZero: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self ArithmeticShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	self annotateBytecode: self Label.
	self TstCq: 7 R: t1.
	jump6 := self JumpNonZero: 0.
	jump7 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self TstCq: 7 R: t1.
	jump4 := self JumpNonZero: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: objectMemory nilObject R: t1.
	jump7 := self JumpAboveOrEqual: 0.
	self MoveCq: 0 R: t2.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self CmpCq: objectMemory trueObject R: t2.
	jumpTrue := self JumpLessOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 1 R: t2.
	jump5 := self JumpZero: 0.
	self CmpCq: objectMemory getMemoryMap getNewSpaceStart R: t1.
	jump7 := self JumpLess: 0.
	self MoveM64: 0 r: t0 R: t2.
	self ArithmeticShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveR: t0 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getPermSpaceMask R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self CmpCq: 1 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getPermSpaceMask R: t2.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	self annotateBytecode: self Label.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	self MoveR: t1 M64: 56 r: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopReceiverVariableBytecode7 [
	"AutoGenerated by Druid"

	| jump1 jump7 jumpNext t1 jump6 jump3 currentBlock t0 jump5 jump2 jumpTrue live t2 jump4 |
	live := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	self ssPop: 1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getOldSpaceMask R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getNewSpaceMask R: t2.
	jump4 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self CmpCq: objectMemory getMemoryMap getNewSpaceStart R: t2.
	jumpTrue := self JumpGreaterOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 1 R: t2.
	jump4 := self JumpZero: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self ArithmeticShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	self annotateBytecode: self Label.
	self TstCq: 7 R: t1.
	jump6 := self JumpNonZero: 0.
	jump7 := self JumpZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self TstCq: 7 R: t1.
	jump4 := self JumpNonZero: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: objectMemory nilObject R: t1.
	jump7 := self JumpAboveOrEqual: 0.
	self MoveCq: 0 R: t2.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self CmpCq: objectMemory trueObject R: t2.
	jumpTrue := self JumpLessOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 1 R: t2.
	jump5 := self JumpZero: 0.
	self CmpCq: objectMemory getMemoryMap getNewSpaceStart R: t1.
	jump7 := self JumpLess: 0.
	self MoveM64: 0 r: t0 R: t2.
	self ArithmeticShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveR: t0 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getPermSpaceMask R: t2.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self CmpCq: 1 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: objectMemory getMemoryMap getSpaceMaskToUse R: t2.
	self CmpCq: objectMemory getMemoryMap getPermSpaceMask R: t2.
	jump2 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	self annotateBytecode: self Label.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	self MoveR: t1 M64: 64 r: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopTemporaryVariableBytecode0 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssFlushUpThroughTemporaryVariable: 0.
	self MoveR: t0 Mw: (self frameOffsetOfTemporary: 0) r: FPReg.
	self ssPop: 1.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopTemporaryVariableBytecode1 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssFlushUpThroughTemporaryVariable: 1.
	self MoveR: t0 Mw: (self frameOffsetOfTemporary: 1) r: FPReg.
	self ssPop: 1.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopTemporaryVariableBytecode2 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssFlushUpThroughTemporaryVariable: 2.
	self MoveR: t0 Mw: (self frameOffsetOfTemporary: 2) r: FPReg.
	self ssPop: 1.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopTemporaryVariableBytecode3 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssFlushUpThroughTemporaryVariable: 3.
	self MoveR: t0 Mw: (self frameOffsetOfTemporary: 3) r: FPReg.
	self ssPop: 1.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopTemporaryVariableBytecode4 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssFlushUpThroughTemporaryVariable: 4.
	self MoveR: t0 Mw: (self frameOffsetOfTemporary: 4) r: FPReg.
	self ssPop: 1.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopTemporaryVariableBytecode5 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssFlushUpThroughTemporaryVariable: 5.
	self MoveR: t0 Mw: (self frameOffsetOfTemporary: 5) r: FPReg.
	self ssPop: 1.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopTemporaryVariableBytecode6 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssFlushUpThroughTemporaryVariable: 6.
	self MoveR: t0 Mw: (self frameOffsetOfTemporary: 6) r: FPReg.
	self ssPop: 1.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopTemporaryVariableBytecode7 [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssFlushUpThroughTemporaryVariable: 7.
	self MoveR: t0 Mw: (self frameOffsetOfTemporary: 7) r: FPReg.
	self ssPop: 1.
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
		ifTrue: 
			[self cCode: [] inSmalltalk:
				[ceStoreTrampolines := CArrayAccessor on: (Array new: NumStoreTrampolines)].
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
	
	self storeLiteral: objOop atAnnotatedAddress: address.
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
		  and: [objectMemory getMemoryMap isYoungObject: objOop]) ifTrue:
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
