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
		  #isInstVarRef }.
		  { 1. 1. 1. #gen_PushReceiverVariableBytecode1.
		  #isInstVarRef }.
		  { 1. 2. 2. #gen_PushReceiverVariableBytecode2.
		  #isInstVarRef }.
		  { 1. 3. 3. #gen_PushReceiverVariableBytecode3.
		  #isInstVarRef }.
		  { 1. 4. 4. #gen_PushReceiverVariableBytecode4.
		  #isInstVarRef }.
		  { 1. 5. 5. #gen_PushReceiverVariableBytecode5.
		  #isInstVarRef }.
		  { 1. 6. 6. #gen_PushReceiverVariableBytecode6.
		  #isInstVarRef }.
		  { 1. 7. 7. #gen_PushReceiverVariableBytecode7.
		  #isInstVarRef }.
		  { 1. 8. 8. #gen_PushReceiverVariableBytecode8.
		  #isInstVarRef }.
		  { 1. 9. 9. #gen_PushReceiverVariableBytecode9.
		  #isInstVarRef }.
		  { 1. 10. 10. #gen_PushReceiverVariableBytecode10.
		  #isInstVarRef }.
		  { 1. 11. 11. #gen_PushReceiverVariableBytecode11.
		  #isInstVarRef }.
		  { 1. 12. 12. #gen_PushReceiverVariableBytecode12.
		  #isInstVarRef }.
		  { 1. 13. 13. #gen_PushReceiverVariableBytecode13.
		  #isInstVarRef }.
		  { 1. 14. 14. #gen_PushReceiverVariableBytecode14.
		  #isInstVarRef }.
		  { 1. 15. 15. #gen_PushReceiverVariableBytecode15.
		  #isInstVarRef }.
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
		  { 1. 64. 64. #gen_PushTemporaryVariableBytecode0 }.
		  { 1. 65. 65. #gen_PushTemporaryVariableBytecode1 }.
		  { 1. 66. 66. #gen_PushTemporaryVariableBytecode2 }.
		  { 1. 67. 67. #gen_PushTemporaryVariableBytecode3 }.
		  { 1. 68. 68. #gen_PushTemporaryVariableBytecode4 }.
		  { 1. 69. 69. #gen_PushTemporaryVariableBytecode5 }.
		  { 1. 70. 70. #gen_PushTemporaryVariableBytecode6 }.
		  { 1. 71. 71. #gen_PushTemporaryVariableBytecode7 }.
		  { 1. 72. 72. #gen_PushTemporaryVariableBytecode8 }.
		  { 1. 73. 73. #gen_PushTemporaryVariableBytecode9 }.
		  { 1. 74. 74. #gen_PushTemporaryVariableBytecode10 }.
		  { 1. 75. 75. #gen_PushTemporaryVariableBytecode11 }.
		  { 1. 76. 76. #gen_PushReceiverBytecode }.
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
		  { 1. 118. 118. #gen_BytecodePrimIdenticalSistaV1 }.
		  { 1. 119. 119. #unknownBytecode }.
		  { 1. 120. 120. #gen_BytecodePrimNotIdenticalSistaV1 }.
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
		  { 1. 200. 200. #gen_StoreAndPopReceiverVariableBytecode0.
		  #isInstVarRef. #isMappedIfImmutability. #needsFrameIfImmutability:.
		   -1 }.
		  { 1. 201. 201. #gen_StoreAndPopReceiverVariableBytecode1.
		  #isInstVarRef. #isMappedIfImmutability. #needsFrameIfImmutability:.
		   -1 }.
		  { 1. 202. 202. #gen_StoreAndPopReceiverVariableBytecode2.
		  #isInstVarRef. #isMappedIfImmutability. #needsFrameIfImmutability:.
		   -1 }.
		  { 1. 203. 203. #gen_StoreAndPopReceiverVariableBytecode3.
		  #isInstVarRef. #isMappedIfImmutability. #needsFrameIfImmutability:.
		   -1 }.
		  { 1. 204. 204. #gen_StoreAndPopReceiverVariableBytecode4.
		  #isInstVarRef. #isMappedIfImmutability. #needsFrameIfImmutability:.
		   -1 }.
		  { 1. 205. 205. #gen_StoreAndPopReceiverVariableBytecode5.
		  #isInstVarRef. #isMappedIfImmutability. #needsFrameIfImmutability:.
		   -1 }.
		  { 1. 206. 206. #gen_StoreAndPopReceiverVariableBytecode6.
		  #isInstVarRef. #isMappedIfImmutability. #needsFrameIfImmutability:.
		   -1 }.
		  { 1. 207. 207. #gen_StoreAndPopReceiverVariableBytecode7.
		  #isInstVarRef. #isMappedIfImmutability. #needsFrameIfImmutability:.
		   -1 }.
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
		  { 2. 226. 226. #gen_ExtPushReceiverVariableBytecode.
		  #isInstVarRef. #isMappedIfImmutability }.
		  { 2. 227. 227. #gen_ExtPushLiteralVariableBytecode.
		  #needsFrameNever:. 1 }.
		  { 2. 228. 228. #gen_ExtPushLiteralBytecode.
		  #needsFrameNever:. 1 }.
		  { 2. 229. 229. #gen_LongPushTemporaryVariableBytecode }.
		  { 2. 230. 230. #unknownBytecode }.
		  { 2. 231. 231. #gen_PushNewArrayBytecode }.
		  { 2. 232. 232. #gen_ExtPushIntegerBytecode.
		  #needsFrameNever:. 1 }.
		  { 2. 233. 233. #gen_ExtPushCharacterBytecode.
		  #needsFrameNever:. 1 }.
		  { 2. 234. 234. #gen_ExtSendBytecode. #isMapped }.
		  { 2. 235. 235. #gen_ExtSendSuperBytecode. #isMapped }.
		  { 2. 236. 236. #unknownBytecode }.
		  { 2. 237. 237. #gen_ExtUnconditionalJump. #branch. #isMapped.
		  #v4:Long:Branch:Distance: }.
		  { 2. 238. 238. #gen_ExtJumpIfTrue. #branch. #isBranchTrue.
		  #isMapped. #v4:Long:Branch:Distance: }.
		  { 2. 239. 239. #gen_ExtJumpIfFalse. #branch. #isBranchFalse.
		  #isMapped. #v4:Long:Branch:Distance: }.
		  { 2. 240. 240. #gen_ExtStoreAndPopReceiverVariableBytecode.
		  #isInstVarRef. #isMappedIfImmutability }.
		  { 2. 241. 241. #gen_ExtStoreAndPopLiteralVariableBytecode.
		  #isMappedIfImmutability }.
		  { 2. 242. 242. #gen_LongStoreAndPopTemporaryVariableBytecode }.
		  { 2. 243. 243. #gen_ExtStoreReceiverVariableBytecode.
		  #isInstVarRef. #isMappedIfImmutability. #needsFrameIfImmutability:.
		  0 }.
		  { 2. 244. 244. #gen_ExtStoreLiteralVariableBytecode.
		  #isMappedIfImmutability }.
		  { 2. 245. 245. #gen_LongStoreTemporaryVariableBytecode }.
		  { 2. 246. 246. #unknownBytecode }.
		  { 2. 247. 247. #unknownBytecode }.
		  { 3. 248. 248. #gen_CallPrimitiveBytecode }.
		  { 3. 249. 249. #gen_ExtPushFullClosureBytecode }.
		  { 3. 250. 250. #unknownBytecode }.
		  { 3. 251. 251. #gen_PushRemoteTempLongBytecode }.
		  { 3. 252. 252. #gen_StoreRemoteTempLongBytecode.
		  #isMappedIfImmutability. #needsFrameIfImmutability:.
		  0 }.
		  { 3. 253. 253. #gen_StoreAndPopRemoteTempLongBytecode.
		  #isMappedIfImmutability. #needsFrameIfImmutability:.
		   -1 }.
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
	MaxCompiledPrimitiveIndex := 550.
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
		  { 11. #gen_PrimitiveMod. 1 }.
		  { 12. #gen_PrimitiveDiv. 1 }.
		  { 13. #gen_PrimitiveQuo. 1 }.
		  { 14. #gen_PrimitiveBitAnd. 1 }.
		  { 15. #gen_PrimitiveBitOr. 1 }.
		  { 16. #gen_PrimitiveBitXor. 1 }.
		  { 17. #gen_PrimitiveBitShift. 1 }.
		  { 40. #gen_PrimitiveAsFloat. 0 }.
		  { 41. #gen_PrimitiveFloatAdd. 1 }.
		  { 42. #gen_PrimitiveFloatSubtract. 1 }.
		  { 43. #gen_PrimitiveFloatLessThan. 1 }.
		  { 44. #gen_PrimitiveFloatGreaterThan.
		  1 }.
		  { 45. #gen_PrimitiveFloatLessOrEqual.
		  1 }.
		  { 46. #gen_PrimitiveFloatGreaterOrEqual.
		  1 }.
		  { 47. #gen_PrimitiveFloatEqual. 1 }.
		  { 48. #gen_PrimitiveFloatNotEqual. 1 }.
		  { 49. #gen_PrimitiveFloatMultiply. 1 }.
		  { 60. #gen_PrimitiveAt. 1 }.
		  { 61. #gen_PrimitiveAtPut. 2 }.
		  { 62. #gen_PrimitiveSize. 0 }.
		  { 63. #gen_PrimitiveStringAt. 1 }.
		  { 64. #gen_PrimitiveStringAtPut. 2 }.
		  { 70. #gen_PrimitiveNew. 0 }.
		  { 71. #gen_PrimitiveNewWithArg. 1 }.
		  { 73. #genNonImplementedPrimitive.  -1. #maycallback }.
		  { 75. #gen_PrimitiveIdentityHash. 0 }.
		  { 110. #gen_PrimitiveIdentical. 1 }.
		  { 111. #gen_PrimitiveClass }.
		  { 117. #genNonImplementedPrimitive.  -1. #maycallback }.
		  { 120. #genNonImplementedPrimitive.  -1. #maycallback }.
		  { 148. #genNonImplementedPrimitive.  -1. #maycallback }.
		  { 160. #genNonImplementedPrimitive.  -1. #maycallback }.
		  { 169. #gen_PrimitiveNotIdentical. 1 }.
		  { 170. #gen_PrimitiveAsCharacter }.
		  { 171. #gen_PrimitiveImmediateAsInteger }.
		  { 173. #genNonImplementedPrimitive.  -1. #maycallback }.
		  { 207. #gen_PrimitiveFullClosureValue }.
		  { 209. #gen_PrimitiveFullClosureValueNoContextSwitch }.
		  { 216. #genNonImplementedPrimitive.  -1. #maycallback }.
		  { 541. #gen_PrimitiveSmallFloatAdd. 1 }.
		  { 542. #gen_PrimitiveSmallFloatSubtract.
		  1 }.
		  { 543. #gen_PrimitiveSmallFloatLessThan.
		  1 }.
		  { 544. #gen_PrimitiveSmallFloatGreaterThan.
		  1 }.
		  { 545. #gen_PrimitiveSmallFloatLessOrEqual.
		  1 }.
		  { 546. #gen_PrimitiveSmallFloatGreaterOrEqual.
		  1 }.
		  { 547. #gen_PrimitiveSmallFloatEqual. 1 }.
		  { 548. #gen_PrimitiveSmallFloatNotEqual.
		  1 }.
		  { 549. #gen_PrimitiveSmallFloatMultiply.
		  1 }.
		  { 550. #gen_PrimitiveSmallFloatDivide.
		  1 } }
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
DruidJIT >> ceNewHashTrampoline: anInteger [

	<doNotGenerate>
	ceNewHashTrampoline := anInteger
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
DruidJIT >> genCreateFullClosureInIndex: anIndex numCopied: numCopied ignoreContext: ignoreContext contextNumArgs: contextNumArgs large: contextIsLarge inBlock: contextIsBlock intoRegister: destinationRegister [
	"Create a full closure with the given values."

	<var: #skip type: #'AbstractInstruction *'>
	| numSlots byteSize header skip numArgs compiledBlock |
	compiledBlock := self getLiteral: anIndex.
	numArgs := coInterpreter argumentCountOf: compiledBlock.

	"First get thisContext into destinationRegister and thence in ClassReg."
	ignoreContext
		ifTrue: [ self genMoveNilR: ClassReg ]
		ifFalse: [
			self voidReceiverResultRegContainsSelf.
			self
				genGetActiveContextNumArgs: contextNumArgs
				large: contextIsLarge
				inBlock: contextIsBlock.
			self MoveR: ReceiverResultReg R: ClassReg ].

	numSlots := FullClosureFirstCopiedValueIndex + numCopied.
	byteSize := objectMemory smallObjectBytesForSlots: numSlots.
	self assert: ClassFullBlockClosureCompactIndex ~= 0.
	header := objectMemory
		          headerForSlots: numSlots
		          format: objectMemory indexablePointersFormat
		          classIndex: ClassFullBlockClosureCompactIndex.
	self MoveAw: objectMemory freeStartAddress R: destinationRegister.
	self
		genStoreHeader: header
		intoNewInstance: destinationRegister
		using: TempReg.
	self
		LoadEffectiveAddressMw: byteSize r: destinationRegister R: TempReg;
		MoveR: TempReg Aw: objectMemory freeStartAddress;
		CmpCq: objectMemory getScavengeThreshold R: TempReg.
	skip := self JumpBelow: 0.
	self CallRT: ceScheduleScavengeTrampoline.
	skip jmpTarget: self Label.

	self
		MoveR: ClassReg
		Mw: FullClosureOuterContextIndex * objectMemory bytesPerOop
			+ objectMemory baseHeaderSize
		r: destinationRegister;
		genMoveConstant: compiledBlock R: TempReg;
		MoveR: TempReg
		Mw: FullClosureCompiledBlockIndex * objectMemory bytesPerOop
			+ objectMemory baseHeaderSize
		r: destinationRegister;
		MoveCq: (objectMemory integerObjectOf: numArgs) R: TempReg;
		MoveR: TempReg
		Mw: FullClosureNumArgsIndex * objectMemory bytesPerOop
			+ objectMemory baseHeaderSize
		r: destinationRegister.
	^ 0
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
		genTrampolineFor: #newHashBitsOf:
		called: name
		numArgs: 1
		arg: TempReg 
		arg: nil
		arg: nil
		arg: nil
		regsToSave: (saveRegs
						ifTrue: [CallerSavedRegisterMask bitClear: (self registerMaskFor: TempReg)]
						ifFalse: [self emptyRegisterMask])
		pushLinkReg: true
		resultReg: TempReg
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
		 jumpSC := self genCheckRememberedBitOf: TempReg scratch: self backEnd cResultRegister.
		 self assert: jumpSC opcode = JumpNonZero.
		 jumpSC opcode: JumpZero.
		 self RetN: 0.
		 jumpSC jmpTarget: self Label].
	^self
		genTrampolineFor: #rememberObjInCorrectRememberedSet:
		called: 'ceStoreCheckTrampoline'
		numArgs: 1
		arg: TempReg
		arg: nil
		arg: nil
		arg: nil
		regsToSave: (CallerSavedRegisterMask bitClear: (self registerMaskFor: TempReg))
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

	| jump1 s57 s54 t1 jump6 jump3 b509 currentBlock nextBytecode t0 jump5 jump2 b505 live t2 jump4 |
	nextBytecode := objectMemory
		                fetchByte: bytecodePC + 1
		                ofObject: methodObj.
	nextBytecode = 184 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpTrue_1 ].
	nextBytecode = 185 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpTrue_2 ].
	nextBytecode = 186 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpTrue_3 ].
	nextBytecode = 187 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpTrue_4 ].
	nextBytecode = 188 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpTrue_5 ].
	nextBytecode = 189 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpTrue_6 ].
	nextBytecode = 190 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpTrue_7 ].
	nextBytecode = 191 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpTrue_8 ].
	nextBytecode = 192 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpFalse_9 ].
	nextBytecode = 193 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpFalse_10 ].
	nextBytecode = 194 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpFalse_11 ].
	nextBytecode = 195 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpFalse_12 ].
	nextBytecode = 196 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpFalse_13 ].
	nextBytecode = 197 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpFalse_14 ].
	nextBytecode = 198 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpFalse_15 ].
	nextBytecode = 199 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpFalse_16 ].
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b509 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b509.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b505 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b505.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	s54 := objectMemory trueObject.
	self MoveCq: s54 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := objectMemory falseObject.
	self MoveCq: s57 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushRegister: t1.
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

	| jump1 s57 s54 t1 jump6 jump3 b509 currentBlock nextBytecode t0 jump5 jump2 b505 live t2 jump4 |
	nextBytecode := objectMemory
		                fetchByte: bytecodePC + 1
		                ofObject: methodObj.
	nextBytecode = 184 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self
			  gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpTrue_1 ].
	nextBytecode = 185 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self
			  gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpTrue_2 ].
	nextBytecode = 186 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self
			  gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpTrue_3 ].
	nextBytecode = 187 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self
			  gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpTrue_4 ].
	nextBytecode = 188 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self
			  gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpTrue_5 ].
	nextBytecode = 189 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self
			  gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpTrue_6 ].
	nextBytecode = 190 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self
			  gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpTrue_7 ].
	nextBytecode = 191 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self
			  gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpTrue_8 ].
	nextBytecode = 192 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self
			  gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpFalse_9 ].
	nextBytecode = 193 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self
			  gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpFalse_10 ].
	nextBytecode = 194 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self
			  gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpFalse_11 ].
	nextBytecode = 195 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self
			  gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpFalse_12 ].
	nextBytecode = 196 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self
			  gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpFalse_13 ].
	nextBytecode = 197 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self
			  gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpFalse_14 ].
	nextBytecode = 198 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self
			  gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpFalse_15 ].
	nextBytecode = 199 ifTrue: [
		bytecodePC := bytecodePC + 1.
		^ self
			  gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpFalse_16 ].
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b509 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b509.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b505 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b505.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	s54 := objectMemory trueObject.
	self MoveCq: s54 R: t1.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := objectMemory falseObject.
	self MoveCq: s57 R: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self ssPushRegister: t1.
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
DruidJIT >> gen_CallPrimitiveBytecode [
	"AutoGenerated by Druid"

	| live currentBlock |
	live := 0.
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

	| s5 s4 s2 currentBlock live s3 |
	live := 0.
	s2 := extA.
	s3 := s2 << 8.
	s4 := byte1.
	s5 := s3 + s4.
	extA := s5.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtBBytecode [
	"AutoGenerated by Druid"

	| s6 s3 s16 s10 s2 currentBlock s7 s4 s17 s11 live s9 |
	live := 0.
	s2 := byte1.
	s3 := numExtB.
	s3 = 0 ifTrue: [
		s2 > 127 ifTrue: [
			s6 := s2 - 256.
			s7 := s6.
			extB := s7.
			s16 := numExtB.
			s17 := s16 + 1.
			numExtB := s17.
			^ 0 ].
		s9 := extB.
		s10 := s9 << 8.
		s11 := s10 + s2.
		s7 := s11.
		extB := s7.
		s16 := numExtB.
		s17 := s16 + 1.
		numExtB := s17.
		^ 0 ].
	s9 := extB.
	s10 := s9 << 8.
	s11 := s10 + s2.
	s7 := s11.
	extB := s7.
	s16 := numExtB.
	s17 := s16 + 1.
	numExtB := s17.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtJumpIfFalse [
	"AutoGenerated by Druid"

	| s6 s3 jump1 s16 s5 s2 s15 currentBlock s12 t0 jump2 s4 s17 live s20 |
	live := 0.
	self annotateBytecode: self Label.
	s3 := byte1.
	s4 := extB.
	s5 := s4 << 8.
	s6 := s3 + s5.
	extA := 0.
	extB := 0.
	numExtB := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s12 := objectMemory falseObject.
	self ssFlushStack.
	self CmpCq: s12 R: t0.
	jump1 := self JumpNonZero: 0.
	s15 := bytecodePC.
	s16 := s15 + s6.
	s17 := s16 + 2.
	self Jump: (self ensureFixupAt: s17).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s20 := objectMemory trueObject.
	self CmpCq: s20 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtJumpIfTrue [
	"AutoGenerated by Druid"

	| s6 s3 jump1 s16 s5 s2 s15 currentBlock s12 t0 jump2 s4 s17 live s20 |
	live := 0.
	self annotateBytecode: self Label.
	s3 := byte1.
	s4 := extB.
	s5 := s4 << 8.
	s6 := s3 + s5.
	extA := 0.
	extB := 0.
	numExtB := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s12 := objectMemory trueObject.
	self ssFlushStack.
	self CmpCq: s12 R: t0.
	jump1 := self JumpNonZero: 0.
	s15 := bytecodePC.
	s16 := s15 + s6.
	s17 := s16 + 2.
	self Jump: (self ensureFixupAt: s17).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s20 := objectMemory falseObject.
	self CmpCq: s20 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
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

	| s5 s6 s4 s2 currentBlock s7 live s3 |
	live := 0.
	s2 := byte1.
	s3 := extB.
	s4 := s3 << 8.
	s5 := s2 + s4.
	s6 := s5 << 3.
	s7 := s6 + 2.
	self ssPushConstant: s7.
	extB := 0.
	numExtB := 0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtPushFullClosureBytecode [
	"AutoGenerated by Druid"

	| s4 s38 s9 s2 s20 currentBlock t1 s19 s12 s7 s25 b10 live s5 s15 s3 s37 s21 t2 s8 t0 s18 s11 |
	live := 0.
	s2 := byte1.
	s3 := extA.
	s4 := s3 << 8.
	s5 := s2 + s4.
	extA := 0.
	s7 := byte2.
	s8 := s7 bitAnd: 63.
	s9 := s7 anyMask: 64.
	live := live bitOr: (self registerMaskFor: ReceiverResultReg).
	live := live bitOr: (self registerMaskFor: SendNumArgsReg).
	live := live bitOr: (self registerMaskFor: ClassReg).
	self voidReceiverResultRegContainsSelf.
	self
		ssAllocateCallReg: ReceiverResultReg
		and: SendNumArgsReg
		and: ClassReg.
	self
		genCreateFullClosureInIndex: s5
		numCopied: s8
		ignoreContext: s9
		contextNumArgs: methodOrBlockNumArgs
		large: (coInterpreter methodNeedsLargeContext: methodObj)
		inBlock: inBlock
		intoRegister: ReceiverResultReg.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	s11 := 1.
	s12 := s11.
	b10 := self Label.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	[ ((s12<=s8)) ] whileTrue: [
		(self ssValue: 0) copyToReg: t1.
		self ssPop: 1.
		s18 := FullClosureFirstCopiedValueIndex.
		s19 := s18 + s8.
		s20 := s19 - s12.
		s21 := s20 << 3.
		self MoveR: t0 R: t2.
		self AddCq: s21 R: t2.
		self MoveR: t1 M64: 8 r: t2.
		s25 := s12 + 1.
		s12 := s25 ].
	(s7 anyMask: 128) ifTrue: [
		(self ssValue: 0) copyToReg: t2.
		self ssPop: 1.
		self MoveR: t2 R: t1.
		s37 := FullClosureReceiverIndex.
		s38 := s37 << 3.
		self MoveR: t0 R: t2.
		self AddCq: s38 R: t2.
		self MoveR: t1 M64: 8 r: t2.
		self ssPushRegister: t0.
		^ 0 ].
	self ensureReceiverResultRegContainsSelf.
	self MoveR: ReceiverResultReg R: t1.
	s37 := FullClosureReceiverIndex.
	s38 := s37 << 3.
	self MoveR: t0 R: t2.
	self AddCq: s38 R: t2.
	self MoveR: t1 M64: 8 r: t2.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtPushIntegerBytecode [
	"AutoGenerated by Druid"

	| s5 s8 s4 s2 currentBlock s9 s10 live s3 |
	live := 0.
	s2 := byte1.
	s3 := extB.
	s4 := s3 << 8.
	s5 := s2 + s4.
	extB := 0.
	numExtB := 0.
	s8 := s2 + s4.
	s9 := s8 << 3.
	s10 := s9 + 1.
	self ssPushConstant: s10.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtPushLiteralBytecode [
	"AutoGenerated by Druid"

	| s3 s10 s8 s5 s2 currentBlock t0 s4 live s9 |
	live := 0.
	s2 := byte1.
	s3 := extA.
	s4 := s3 << 8.
	s5 := s2 + s4.
	extA := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s8 := LiteralStart.
	s9 := s5 + s8.
	s10 := s9 << 3.
	self AddCq: s10 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtPushLiteralVariableBytecode [
	"AutoGenerated by Druid"

	| s34 s3 jump1 jump4 s10 t1 s8 s5 s2 b237 currentBlock jump3 t0 s35 s4 jump2 live s9 |
	live := 0.
	s2 := byte1.
	s3 := extA.
	s4 := s3 << 8.
	s5 := s2 + s4.
	extA := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s8 := LiteralStart.
	s9 := s5 + s8.
	s10 := s9 << 3.
	self AddCq: s10 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s34 := ValueIndex.
	s35 := s34 << 3.
	self AddCq: s35 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtPushReceiverVariableBytecode [
	"AutoGenerated by Druid"

	| s6 s3 s13 t1 s5 s2 s18 currentBlock t0 s4 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	s3 := byte1.
	s4 := extA.
	s5 := s4 << 8.
	s6 := s3 + s5.
	extA := 0.
	self ensureReceiverResultRegContainsSelf.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveR: ReceiverResultReg R: t0.
	s9 := StackPointerIndex.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	s6 <= s9 ifTrue: [
		| jump1 jump2 |
		self MoveM64: 0 r: t0 R: t1.
		self AndCq: 16r3FFFFF R: t1.
		s13 := ClassMethodContextCompactIndex.
		self ssFlushStack.
		self CmpCq: s13 R: t1.
		jump1 := self JumpNonZero: 0.
		self deoptimize.
		jump2 := self Jump: 0.
		deadCode := false.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		s18 := s6 << 3.
		self AddCq: s18 R: t0.
		self ssPushBase: t0 offset: 8.
		currentBlock := self Label.
		jump2 jmpTarget: currentBlock.
		^ 0 ].
	s18 := s6 << 3.
	self AddCq: s18 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtSendBytecode [
	"AutoGenerated by Druid"

	| s6 s3 s10 s8 s5 s2 currentBlock s4 live s11 s9 |
	live := 0.
	s2 := byte1.
	s3 := s2 >> 3.
	s4 := extA.
	s5 := s4 << 5.
	s6 := s3 + s5.
	extA := 0.
	s8 := s2 bitAnd: 7.
	s9 := extB.
	s10 := s9 << 3.
	s11 := s8 + s10.
	extB := 0.
	numExtB := 0.
	self marshallSendArguments: s11.
	self
		genMarshalledSend: s6
		numArgs: s11
		sendTable: ordinarySendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtSendSuperBytecode [
	"AutoGenerated by Druid"

	| s6 s3 s16 s10 s8 s5 s2 s18 currentBlock s15 s4 s17 live s9 |
	live := 0.
	s2 := byte1.
	s3 := s2 >> 3.
	s4 := extA.
	s5 := s4 << 5.
	s6 := s3 + s5.
	extA := 0.
	s8 := BytecodeSetHasDirectedSuperSend.
	s8 ifTrue: [
		s10 := extB.
		s10 >= 64 ifTrue: [
			self ssFlushStack.
			self deoptimize.
			deadCode := false.
			^ 0 ].
		s15 := s2 bitAnd: 7.
		s16 := extB.
		s17 := s16 << 3.
		s18 := s15 + s17.
		extB := 0.
		numExtB := 0.
		self marshallSendArguments: s18.
		self
			genMarshalledSend: s6
			numArgs: s18
			sendTable: superSendTrampolines.
		^ 0 ].
	s15 := s2 bitAnd: 7.
	s16 := extB.
	s17 := s16 << 3.
	s18 := s15 + s17.
	extB := 0.
	numExtB := 0.
	self marshallSendArguments: s18.
	self
		genMarshalledSend: s6
		numArgs: s18
		sendTable: superSendTrampolines.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtStoreAndPopLiteralVariableBytecode [
	"AutoGenerated by Druid"

	| s6 jump5 s4 jump3 jump8 s2 t1 currentBlock jump1 s51 s12 jump6 s89 jumpNext s56 live s5 b617 jump4 jumpTrue jump9 s3 s37 s85 t2 s59 s13 s61 jump2 t0 s83 s48 jump7 s11 |
	live := 0.
	self annotateBytecode: self Label.
	s3 := byte1.
	s4 := extA.
	s5 := s4 << 8.
	s6 := s3 + s5.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	extA := 0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self genMoveConstant: methodObj R: t1.
	s11 := LiteralStart.
	s12 := s6 + s11.
	s13 := s12 << 3.
	self AddCq: s13 R: t1.
	self MoveM64: 8 r: t1 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b617 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump4 := self Jump: b617.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s37 := ValueIndex.
	self MoveM64: 0 r: t1 R: t2.
	self LogicalShiftRightCq: 23 R: t2.
	self AndCq: 1 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump3 := self JumpZero: 0.
	self deoptimize.
	jump1 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	s48 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t1 R: t2.
	self AndCq: s48 R: t2.
	s51 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s51 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump5 := self JumpNonZero: 0.
	s56 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t0 R: t2.
	self AndCq: s56 R: t2.
	s59 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s59 R: t2.
	jump6 := self JumpNonZero: 0.
	s61 := objectMemory getMemoryMap getNewSpaceStart.
	self MoveR: t0 R: t2.
	self CmpCq: s61 R: t2.
	jumpTrue := self JumpAboveOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 1 R: t2.
	jump7 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump8 := self JumpNonZero: 0.
	self MoveR: t1 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	self MoveM64: 0 r: t1 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump9 := self JumpNonZero: 0.
	self TstCq: 7 R: t0.
	jump8 := self JumpNonZero: 0.
	self CmpCq: 16r20000000000 R: t1.
	jump7 := self JumpBelow: 0.
	self CmpCq: 16r20000000000 R: t0.
	jump5 := self JumpGreaterOrEqual: 0.
	self genMoveConstant: objectMemory nilObject R: t2.
	self CmpR: t2 R: t0.
	jump2 := self JumpBelow: 0.
	s83 := objectMemory trueObject.
	self CmpCq: s83 R: t0.
	jump3 := self JumpBelowOrEqual: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	s85 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s85 R: t0.
	jump2 := self JumpBelow: 0.
	self MoveR: t1 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	s89 := s37 << 3.
	self AddCq: s89 R: t1.
	self MoveR: t0 M64: 8 r: t1.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtStoreAndPopReceiverVariableBytecode [
	"AutoGenerated by Druid"

	| s6 jump5 s33 s46 s4 jump3 s44 s14 s69 s2 t1 s36 currentBlock s9 jump1 jump6 s65 s5 live jump4 s63 s3 t2 jump2 jump7 t0 s41 |
	live := 0.
	self annotateBytecode: self Label.
	s3 := byte1.
	s4 := extA.
	s5 := s4 << 8.
	s6 := s3 + s5.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ensureReceiverResultRegContainsSelf.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveR: ReceiverResultReg R: t1.
	s9 := ReceiverIndex.
	self ssFlushStack.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	s6 <= s9 ifTrue: [
		| jump7 jump5 jump3 jump1 jump8 jump6 jump4 jump2 |
		self MoveM64: 0 r: t1 R: t2.
		self AndCq: 16r3FFFFF R: t2.
		s14 := ClassMethodContextCompactIndex.
		self CmpCq: s14 R: t2.
		jump1 := self JumpNonZero: 0.
		self deoptimize.
		jump2 := self Jump: 0.
		deadCode := false.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		self ssPop: 1.
		self MoveM64: 0 r: t1 R: t2.
		self LogicalShiftRightCq: 23 R: t2.
		self AndCq: 1 R: t2.
		self CmpCq: 0 R: t2.
		jump1 := self JumpZero: 0.
		self deoptimize.
		jump3 := self Jump: 0.
		deadCode := false.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		self MoveR: t1 R: t2.
		self AndCq: 7 R: t2.
		self CmpCq: 0 R: t2.
		jump1 := self JumpNonZero: 0.
		s33 := objectMemory getMemoryMap getSpaceMaskToUse.
		self MoveR: t1 R: t2.
		self AndCq: s33 R: t2.
		s36 := objectMemory getMemoryMap getOldSpaceMask.
		self CmpCq: s36 R: t2.
		jump4 := self JumpNonZero: 0.
		self MoveR: t0 R: t2.
		self AndCq: 7 R: t2.
		self CmpCq: 0 R: t2.
		jump5 := self JumpNonZero: 0.
		s41 := objectMemory getMemoryMap getSpaceMaskToUse.
		self MoveR: t0 R: t2.
		self AndCq: s41 R: t2.
		s44 := objectMemory getMemoryMap getNewSpaceMask.
		self CmpCq: s44 R: t2.
		jump6 := self JumpNonZero: 0.
		s46 := objectMemory getMemoryMap getNewSpaceStart.
		self CmpCq: s46 R: t0.
		jump7 := self JumpBelow: 0.
		self MoveM64: 0 r: t1 R: t2.
		self LogicalShiftRightCq: 29 R: t2.
		self AndCq: 1 R: t2.
		self CmpCq: 0 R: t2.
		jump8 := self JumpNonZero: 0.
		self MoveR: t1 R: TempReg.
		backEnd saveAndRestoreLinkRegAround: [
			self CallRT: ceStoreCheckTrampoline ].
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		jump4 jmpTarget: currentBlock.
		jump5 jmpTarget: currentBlock.
		jump6 jmpTarget: currentBlock.
		jump7 jmpTarget: currentBlock.
		jump8 jmpTarget: currentBlock.
		self MoveM64: 0 r: t1 R: t2.
		self LogicalShiftRightCq: 29 R: t2.
		self AndCq: 1 R: t2.
		self CmpCq: 0 R: t2.
		jump8 := self JumpNonZero: 0.
		self TstCq: 7 R: t0.
		jump7 := self JumpNonZero: 0.
		self CmpCq: 16r20000000000 R: t1.
		jump6 := self JumpLess: 0.
		self CmpCq: 16r20000000000 R: t0.
		jump5 := self JumpGreaterOrEqual: 0.
		self genMoveConstant: objectMemory nilObject R: t2.
		self CmpR: t2 R: t0.
		jump4 := self JumpBelow: 0.
		s63 := objectMemory trueObject.
		self CmpCq: s63 R: t0.
		jump1 := self JumpBelowOrEqual: 0.
		currentBlock := self Label.
		jump4 jmpTarget: currentBlock.
		s65 := objectMemory getMemoryMap getNewSpaceStart.
		self CmpCq: s65 R: t0.
		jump4 := self JumpBelow: 0.
		self MoveR: t1 R: TempReg.
		backEnd saveAndRestoreLinkRegAround: [
			self CallRT: ceStoreCheckTrampoline ].
		currentBlock := self Label.
		jump8 jmpTarget: currentBlock.
		jump7 jmpTarget: currentBlock.
		jump6 jmpTarget: currentBlock.
		jump5 jmpTarget: currentBlock.
		jump1 jmpTarget: currentBlock.
		jump4 jmpTarget: currentBlock.
		s69 := s6 << 3.
		self AddCq: s69 R: t1.
		self MoveR: t0 M64: 8 r: t1.
		currentBlock := self Label.
		jump2 jmpTarget: currentBlock.
		jump3 jmpTarget: currentBlock.
		extA := 0.
		^ 0 ].
	self ssPop: 1.
	self MoveM64: 0 r: t1 R: t2.
	self LogicalShiftRightCq: 23 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpZero: 0.
	self deoptimize.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	s33 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t1 R: t2.
	self AndCq: s33 R: t2.
	s36 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s36 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	s41 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t0 R: t2.
	self AndCq: s41 R: t2.
	s44 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s44 R: t2.
	jump5 := self JumpNonZero: 0.
	s46 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s46 R: t0.
	jump6 := self JumpBelow: 0.
	self MoveM64: 0 r: t1 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self MoveR: t1 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	self MoveM64: 0 r: t1 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self TstCq: 7 R: t0.
	jump6 := self JumpNonZero: 0.
	self CmpCq: 16r20000000000 R: t1.
	jump5 := self JumpLess: 0.
	self CmpCq: 16r20000000000 R: t0.
	jump1 := self JumpGreaterOrEqual: 0.
	self genMoveConstant: objectMemory nilObject R: t2.
	self CmpR: t2 R: t0.
	jump4 := self JumpBelow: 0.
	s63 := objectMemory trueObject.
	self CmpCq: s63 R: t0.
	jump3 := self JumpBelowOrEqual: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	s65 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s65 R: t0.
	jump4 := self JumpBelow: 0.
	self MoveR: t1 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	s69 := s6 << 3.
	self AddCq: s69 R: t1.
	self MoveR: t0 M64: 8 r: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	extA := 0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtStoreLiteralVariableBytecode [
	"AutoGenerated by Druid"

	| s6 s11 s88 jump5 s55 s4 jump3 jump8 s2 s36 currentBlock s84 s58 s12 s60 t1 jump1 s82 s47 jump6 s10 s5 live b617 jump4 jumpTrue jumpNext jump9 s3 t2 jump2 jump7 t0 s50 |
	live := 0.
	self annotateBytecode: self Label.
	s3 := byte1.
	s4 := extA.
	s5 := s4 << 8.
	s6 := s3 + s5.
	extA := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self genMoveConstant: methodObj R: t1.
	s10 := LiteralStart.
	s11 := s6 + s10.
	s12 := s11 << 3.
	self AddCq: s12 R: t1.
	self MoveM64: 8 r: t1 R: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b617 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump4 := self Jump: b617.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s36 := ValueIndex.
	self MoveM64: 0 r: t1 R: t2.
	self LogicalShiftRightCq: 23 R: t2.
	self AndCq: 1 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump3 := self JumpZero: 0.
	self deoptimize.
	jump1 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	s47 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t1 R: t2.
	self AndCq: s47 R: t2.
	s50 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s50 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump5 := self JumpNonZero: 0.
	s55 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t0 R: t2.
	self AndCq: s55 R: t2.
	s58 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s58 R: t2.
	jump6 := self JumpNonZero: 0.
	s60 := objectMemory getMemoryMap getNewSpaceStart.
	self MoveR: t0 R: t2.
	self CmpCq: s60 R: t2.
	jumpTrue := self JumpAboveOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 1 R: t2.
	jump7 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump8 := self JumpNonZero: 0.
	self MoveR: t1 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	self MoveM64: 0 r: t1 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump9 := self JumpNonZero: 0.
	self TstCq: 7 R: t0.
	jump8 := self JumpNonZero: 0.
	self CmpCq: 16r20000000000 R: t1.
	jump7 := self JumpBelow: 0.
	self CmpCq: 16r20000000000 R: t0.
	jump5 := self JumpGreaterOrEqual: 0.
	self genMoveConstant: objectMemory nilObject R: t2.
	self CmpR: t2 R: t0.
	jump2 := self JumpBelow: 0.
	s82 := objectMemory trueObject.
	self CmpCq: s82 R: t0.
	jump3 := self JumpBelowOrEqual: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	s84 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s84 R: t0.
	jump2 := self JumpBelow: 0.
	self MoveR: t1 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	s88 := s36 << 3.
	self AddCq: s88 R: t1.
	self MoveR: t0 M64: 8 r: t1.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtStoreReceiverVariableBytecode [
	"AutoGenerated by Druid"

	| s6 jump5 s4 jump3 s31 s44 s14 s9 s2 t1 currentBlock jump1 s42 s67 jump6 s34 live s5 s39 jump4 s63 s3 t2 jump2 s61 jump7 t0 |
	live := 0.
	self annotateBytecode: self Label.
	s3 := byte1.
	s4 := extA.
	s5 := s4 << 8.
	s6 := s3 + s5.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ensureReceiverResultRegContainsSelf.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveR: ReceiverResultReg R: t1.
	s9 := ReceiverIndex.
	self ssFlushStack.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	s6 <= s9 ifTrue: [
		| jump7 jump5 jump3 jump1 jump8 jump6 jump4 jump2 |
		self MoveM64: 0 r: t1 R: t2.
		self AndCq: 16r3FFFFF R: t2.
		s14 := ClassMethodContextCompactIndex.
		self CmpCq: s14 R: t2.
		jump1 := self JumpNonZero: 0.
		self deoptimize.
		jump2 := self Jump: 0.
		deadCode := false.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		self MoveM64: 0 r: t1 R: t2.
		self LogicalShiftRightCq: 23 R: t2.
		self AndCq: 1 R: t2.
		self CmpCq: 0 R: t2.
		jump1 := self JumpZero: 0.
		self deoptimize.
		jump3 := self Jump: 0.
		deadCode := false.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		self MoveR: t1 R: t2.
		self AndCq: 7 R: t2.
		self CmpCq: 0 R: t2.
		jump1 := self JumpNonZero: 0.
		s31 := objectMemory getMemoryMap getSpaceMaskToUse.
		self MoveR: t1 R: t2.
		self AndCq: s31 R: t2.
		s34 := objectMemory getMemoryMap getOldSpaceMask.
		self CmpCq: s34 R: t2.
		jump4 := self JumpNonZero: 0.
		self MoveR: t0 R: t2.
		self AndCq: 7 R: t2.
		self CmpCq: 0 R: t2.
		jump5 := self JumpNonZero: 0.
		s39 := objectMemory getMemoryMap getSpaceMaskToUse.
		self MoveR: t0 R: t2.
		self AndCq: s39 R: t2.
		s42 := objectMemory getMemoryMap getNewSpaceMask.
		self CmpCq: s42 R: t2.
		jump6 := self JumpNonZero: 0.
		s44 := objectMemory getMemoryMap getNewSpaceStart.
		self CmpCq: s44 R: t0.
		jump7 := self JumpBelow: 0.
		self MoveM64: 0 r: t1 R: t2.
		self LogicalShiftRightCq: 29 R: t2.
		self AndCq: 1 R: t2.
		self CmpCq: 0 R: t2.
		jump8 := self JumpNonZero: 0.
		self MoveR: t1 R: TempReg.
		backEnd saveAndRestoreLinkRegAround: [
			self CallRT: ceStoreCheckTrampoline ].
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		jump4 jmpTarget: currentBlock.
		jump5 jmpTarget: currentBlock.
		jump6 jmpTarget: currentBlock.
		jump7 jmpTarget: currentBlock.
		jump8 jmpTarget: currentBlock.
		self MoveM64: 0 r: t1 R: t2.
		self LogicalShiftRightCq: 29 R: t2.
		self AndCq: 1 R: t2.
		self CmpCq: 0 R: t2.
		jump8 := self JumpNonZero: 0.
		self TstCq: 7 R: t0.
		jump7 := self JumpNonZero: 0.
		self CmpCq: 16r20000000000 R: t1.
		jump6 := self JumpLess: 0.
		self CmpCq: 16r20000000000 R: t0.
		jump5 := self JumpGreaterOrEqual: 0.
		self genMoveConstant: objectMemory nilObject R: t2.
		self CmpR: t2 R: t0.
		jump4 := self JumpBelow: 0.
		s61 := objectMemory trueObject.
		self CmpCq: s61 R: t0.
		jump1 := self JumpBelowOrEqual: 0.
		currentBlock := self Label.
		jump4 jmpTarget: currentBlock.
		s63 := objectMemory getMemoryMap getNewSpaceStart.
		self CmpCq: s63 R: t0.
		jump4 := self JumpBelow: 0.
		self MoveR: t1 R: TempReg.
		backEnd saveAndRestoreLinkRegAround: [
			self CallRT: ceStoreCheckTrampoline ].
		currentBlock := self Label.
		jump8 jmpTarget: currentBlock.
		jump7 jmpTarget: currentBlock.
		jump6 jmpTarget: currentBlock.
		jump5 jmpTarget: currentBlock.
		jump1 jmpTarget: currentBlock.
		jump4 jmpTarget: currentBlock.
		s67 := s6 << 3.
		self AddCq: s67 R: t1.
		self MoveR: t0 M64: 8 r: t1.
		currentBlock := self Label.
		jump2 jmpTarget: currentBlock.
		jump3 jmpTarget: currentBlock.
		extA := 0.
		^ 0 ].
	self MoveM64: 0 r: t1 R: t2.
	self LogicalShiftRightCq: 23 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpZero: 0.
	self deoptimize.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump3 := self JumpNonZero: 0.
	s31 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t1 R: t2.
	self AndCq: s31 R: t2.
	s34 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s34 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	s39 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t0 R: t2.
	self AndCq: s39 R: t2.
	s42 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s42 R: t2.
	jump5 := self JumpNonZero: 0.
	s44 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s44 R: t0.
	jump6 := self JumpBelow: 0.
	self MoveM64: 0 r: t1 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self MoveR: t1 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	self MoveM64: 0 r: t1 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self TstCq: 7 R: t0.
	jump6 := self JumpNonZero: 0.
	self CmpCq: 16r20000000000 R: t1.
	jump5 := self JumpLess: 0.
	self CmpCq: 16r20000000000 R: t0.
	jump1 := self JumpGreaterOrEqual: 0.
	self genMoveConstant: objectMemory nilObject R: t2.
	self CmpR: t2 R: t0.
	jump4 := self JumpBelow: 0.
	s61 := objectMemory trueObject.
	self CmpCq: s61 R: t0.
	jump3 := self JumpBelowOrEqual: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	s63 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s63 R: t0.
	jump4 := self JumpBelow: 0.
	self MoveR: t1 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	s67 := s6 << 3.
	self AddCq: s67 R: t1.
	self MoveR: t0 M64: 8 r: t1.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	extA := 0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ExtUnconditionalJump [
	"AutoGenerated by Druid"

	| s6 s3 jump1 s28 s10 t1 s8 s5 s2 s18 currentBlock s12 s27 t0 s4 s26 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	s3 := byte1.
	s4 := extB.
	s5 := s4 << 8.
	s6 := s3 + s5.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	s6 < 0 ifTrue: [
		| jump1 |
		s8 := numExtB.
		s9 := s8 << 1.
		s10 := s9.
		extB := 0.
		numExtB := 0.
		s18 := s6 + s10.
		self ssFlushStack.
		s18 >= 0 ifTrue: [
			s26 := bytecodePC.
			s27 := s26 + s6.
			s28 := s27 + 2.
			self Jump: (self ensureFixupAt: s28).
			deadCode := true.
			^ 0 ].
		self MoveR: SPReg R: t0.
		self MoveAw: coInterpreter stackLimitAddress R: t1.
		self CmpR: t1 R: t0.
		jump1 := self JumpAboveOrEqual: 0.
		self CallRT: ceCheckForInterruptTrampoline.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		s26 := bytecodePC.
		s27 := s26 + s6.
		s28 := s27 + 2.
		self Jump: (self ensureFixupAt: s28).
		deadCode := true.
		^ 0 ].
	s12 := 0.
	s10 := s12.
	extB := 0.
	numExtB := 0.
	s18 := s6 + s10.
	self ssFlushStack.
	s18 >= 0 ifTrue: [
		s26 := bytecodePC.
		s27 := s26 + s6.
		s28 := s27 + 2.
		self Jump: (self ensureFixupAt: s28).
		deadCode := true.
		^ 0 ].
	self MoveR: SPReg R: t0.
	self MoveAw: coInterpreter stackLimitAddress R: t1.
	self CmpR: t1 R: t0.
	jump1 := self JumpAboveOrEqual: 0.
	self CallRT: ceCheckForInterruptTrampoline.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s26 := bytecodePC.
	s27 := s26 + s6.
	s28 := s27 + 2.
	self Jump: (self ensureFixupAt: s28).
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
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self TstCq: 1 R: SendNumArgsReg.
	jump1 := self JumpZero: 0.
	self AddCq:  -1 R: SendNumArgsReg.
	self AddR: ClassReg R: SendNumArgsReg.
	jump2 := self JumpOverflow: 0.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveAsCharacter [
	"AutoGenerated by Druid"

	| s3 s13 currentBlock s2 |
	s2 := self methodNumArgs.
	s2 = 0 ifTrue: [
		| jump1 jump2 jump3 |
		self MoveR: ReceiverResultReg R: ClassReg.
		self TstCq: 1 R: ClassReg.
		jump1 := self JumpZero: 0.
		self ArithmeticShiftRightCq: 3 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump2 := self JumpLess: 0.
		self CmpCq: 16r3FFFFFFF R: ClassReg.
		jump3 := self JumpGreater: 0.
		self LogicalShiftLeftCq: 3 R: ClassReg.
		self AddCq: 2 R: ClassReg.
		self MoveR: ClassReg R: ReceiverResultReg.
		self genPrimReturn.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		jump2 jmpTarget: currentBlock.
		jump3 jmpTarget: currentBlock.
		^ 0 ].
	s13 := self methodNumArgs.
	s13 = 1 ifTrue: [
		| jump3 jump2 jump1 |
		self MoveR: Arg0Reg R: ClassReg.
		self TstCq: 1 R: ClassReg.
		jump3 := self JumpZero: 0.
		self ArithmeticShiftRightCq: 3 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump2 := self JumpLess: 0.
		self CmpCq: 16r3FFFFFFF R: ClassReg.
		jump1 := self JumpGreater: 0.
		self LogicalShiftLeftCq: 3 R: ClassReg.
		self AddCq: 2 R: ClassReg.
		self MoveR: ClassReg R: ReceiverResultReg.
		self genPrimReturn.
		currentBlock := self Label.
		jump3 jmpTarget: currentBlock.
		jump2 jmpTarget: currentBlock.
		jump1 jmpTarget: currentBlock.
		^ 0 ].
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveAsFloat [
	"AutoGenerated by Druid"

	| jump1 jumpNext s19 jump3 currentBlock s15 jumpTrue s44 s47 jump2 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	self MoveRd: DPFPReg0 R: ClassReg.
	self MoveR: ClassReg R: SendNumArgsReg.
	self LogicalShiftRightCq: 52 R: SendNumArgsReg.
	self AndCq: 2047 R: SendNumArgsReg.
	self CmpCq: 896 R: SendNumArgsReg.
	jump1 := self JumpBelowOrEqual: 0.
	self CmpCq: 1151 R: SendNumArgsReg.
	jumpTrue := self JumpBelowOrEqual: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self AndCq: 16rFFFFFFFFFFFFF R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jump1 := self JumpNonZero: 0.
	s15 := 0.
	self CmpCq: s15 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s19 := 896.
	self CmpCq: s19 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: SendNumArgsReg.
	jump2 := self JumpNonZero: 0.
	self MoveRd: DPFPReg0 R: SendNumArgsReg.
	self RotateLeftCq: 1 R: SendNumArgsReg.
	self CmpCq: 1 R: SendNumArgsReg.
	jump3 := self JumpBelowOrEqual: 0.
	self SubCq: 16r7000000000000000 R: SendNumArgsReg.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 4 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self MoveAw: objectMemory freeStartAddress R: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: ClassReg.
	self AddCq: 16 R: ClassReg.
	s44 := objectMemory getScavengeThreshold.
	self CmpCq: s44 R: ClassReg.
	jump2 := self JumpAbove: 0.
	s47 := 72057594205700130.
	self MoveCq: s47 R: ClassReg.
	self MoveR: ClassReg M64: 0 r: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: ClassReg.
	self AddCq: 16 R: ClassReg.
	self MoveR: ClassReg Aw: objectMemory freeStartAddress.
	self MoveRd: DPFPReg0 M64: 8 r: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveAt [
	"AutoGenerated by Druid"

	| jump1 jump10 jump9 jump6 jump3 jump12 currentBlock jump8 jump5 jump2 s73 jump11 s55 s93 jump7 jump4 |
	self SubCq: 24 R: SPReg.
	self MoveR: ReceiverResultReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveR: Arg0Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self TstCq: 7 R: Extra3Reg.
	jump1 := self JumpNonZero: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self AndCq: 1 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump2 := self JumpZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: Extra0Reg.
	self AndCq: 16r3FFFF7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump3 := self JumpZero: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self ArithmeticShiftRightCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra1Reg.
	self LogicalShiftRightCq: 24 R: Extra1Reg.
	self AndCq: 31 R: Extra1Reg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveMb: 7 r: Extra3Reg R: Extra2Reg.
	self AndCq: 255 R: Extra2Reg.
	self CmpCq: 255 R: Extra2Reg.
	jump4 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: -8 r: Extra3Reg R: Extra2Reg.
	self LogicalShiftLeftCq: 8 R: Extra2Reg.
	self LogicalShiftRightCq: 8 R: Extra2Reg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 5 R: Extra1Reg.
	jump5 := self JumpAbove: 0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 16 R: Extra1Reg.
	jump5 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 3 R: Extra2Reg.
	self MoveR: Extra1Reg R: ClassReg.
	self AndCq: 7 R: ClassReg.
	self SubR: ClassReg R: Extra2Reg.
	self MoveR: Extra2Reg R: ClassReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 12 R: Extra1Reg.
	jump5 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 2 R: Extra2Reg.
	self MoveR: Extra1Reg R: ClassReg.
	self AndCq: 3 R: ClassReg.
	self SubR: ClassReg R: Extra2Reg.
	self MoveR: Extra2Reg R: ClassReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 10 R: Extra1Reg.
	jump5 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 1 R: Extra2Reg.
	self MoveR: Extra1Reg R: ClassReg.
	self AndCq: 1 R: ClassReg.
	self SubR: ClassReg R: Extra2Reg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 9 R: Extra1Reg.
	jump5 := self JumpNonZero: 0.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	s55 := 0.
	self MoveCq: s55 R: Extra2Reg.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	self CmpCq: 9 R: Extra1Reg.
	jump9 := self JumpBelow: 0.
	self MoveR: Extra2Reg R: ClassReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self CmpCq: 2 R: Extra1Reg.
	jump9 := self JumpNonZero: 0.
	self MoveR: Extra2Reg R: ClassReg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	s73 := 0.
	self MoveCq: s73 R: SendNumArgsReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self CmpCq: 2 R: Extra1Reg.
	jump9 := self JumpAboveOrEqual: 0.
	self MoveR: Extra2Reg R: SendNumArgsReg.
	self MoveR: Extra2Reg R: ClassReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: ClassReg.
	self AndCq: 16r3FFFFF R: ClassReg.
	self CmpCq: 31 R: ClassReg.
	jump9 := self JumpAbove: 0.
	self CmpCq: 31 R: ClassReg.
	jump8 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ClassReg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self CmpCq: 8 R: ClassReg.
	jump8 := self JumpNonZero: 0.
	self genMoveConstant: objectMemory nilObject R: ClassReg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self MoveR: ClassReg R: SendNumArgsReg.
	self LogicalShiftRightCq: 10 R: SendNumArgsReg.
	s93 := objectMemory hiddenRootsObject.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: s93 R: SendNumArgsReg.
	self MoveM64: 8 r: SendNumArgsReg R: SendNumArgsReg.
	self genMoveConstant: objectMemory nilObject R: Extra0Reg.
	self CmpR: Extra0Reg R: SendNumArgsReg.
	jump8 := self JumpNonZero: 0.
	self genMoveConstant: objectMemory nilObject R: Extra0Reg.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self AndCq: 1023 R: ClassReg.
	self LogicalShiftLeftCq: 3 R: ClassReg.
	self AddR: ClassReg R: SendNumArgsReg.
	self MoveM64: 8 r: SendNumArgsReg R: Extra0Reg.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 24 r: ClassReg R: Extra0Reg.
	self ArithmeticShiftRightCq: 3 R: Extra0Reg.
	self AndCq: 16rFFFF R: Extra0Reg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self MoveR: Extra2Reg R: ClassReg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 3 R: Extra1Reg.
	jump7 := self JumpNonZero: 0.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self AndCq: 16r3FFFFF R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self CmpCq: 36 R: Extra3Reg.
	jump6 := self JumpZero: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self SubR: SendNumArgsReg R: ClassReg.
	self CmpCq: 24 R: Extra1Reg.
	jump7 := self JumpAboveOrEqual: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self CmpCq: 1 R: Extra3Reg.
	jump5 := self JumpBelow: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self CmpR: ClassReg R: Extra3Reg.
	jump4 := self JumpAbove: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self AddR: SendNumArgsReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self CmpCq: 5 R: Extra1Reg.
	jump9 := self JumpAbove: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self SubCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self LogicalShiftLeftCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveMw: 8 r: SPReg R: Extra4Reg.
	self AddR: Extra4Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 8 r: Extra3Reg R: Extra0Reg.
	self MoveR: Extra0Reg R: ReceiverResultReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self CmpCq: 16 R: Extra1Reg.
	jump9 := self JumpBelow: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveMw: 0 r: SPReg R: Extra4Reg.
	self AddR: Extra4Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self AddCq:  -1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveMb: 8 r: Extra3Reg R: Extra0Reg.
	self AndCq: 255 R: Extra0Reg.
	self LogicalShiftLeftCq: 3 R: Extra0Reg.
	self AddCq: 1 R: Extra0Reg.
	self MoveR: Extra0Reg R: ReceiverResultReg.
	jump10 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self CmpCq: 12 R: Extra1Reg.
	jump9 := self JumpBelow: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self SubCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self LogicalShiftLeftCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveMw: 8 r: SPReg R: Extra4Reg.
	self AddR: Extra4Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM16: 8 r: Extra3Reg R: Extra0Reg.
	self AndCq: 16rFFFF R: Extra0Reg.
	self LogicalShiftLeftCq: 3 R: Extra0Reg.
	self AddCq: 1 R: Extra0Reg.
	self MoveR: Extra0Reg R: ReceiverResultReg.
	jump11 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self CmpCq: 9 R: Extra1Reg.
	jump9 := self JumpNonZero: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self SubCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self LogicalShiftLeftCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveMw: 8 r: SPReg R: Extra4Reg.
	self AddR: Extra4Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 8 r: Extra3Reg R: Extra0Reg.
	self CmpCq: 16rFFFFFFFFFFFFFFF R: Extra0Reg.
	jump12 := self JumpAbove: 0.
	self LogicalShiftLeftCq: 3 R: Extra0Reg.
	self AddCq: 1 R: Extra0Reg.
	self MoveR: Extra0Reg R: ReceiverResultReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	jump10 jmpTarget: currentBlock.
	jump11 jmpTarget: currentBlock.
	self AddCq: 24 R: SPReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	jump12 jmpTarget: currentBlock.
	self AddCq: 24 R: SPReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveAtPut [
	"AutoGenerated by Druid"

	| s131 jump5 jump17 jump10 s94 jump3 jump15 jump8 jump1 s134 currentBlock jump13 s139 jump6 jumpNext jump18 jump11 jump4 s168 jumpTrue jump16 jump9 jump2 s144 s166 s59 jump14 jump7 s142 s74 jump12 |
	self SubCq: 24 R: SPReg.
	self MoveR: ReceiverResultReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveR: Arg0Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveR: Arg1Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self TstCq: 7 R: Extra3Reg.
	jump1 := self JumpNonZero: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra1Reg.
	self AndCq: 1 R: Extra1Reg.
	self CmpCq: 0 R: Extra1Reg.
	jump2 := self JumpZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: Extra1Reg.
	self AndCq: 16r3FFFF7 R: Extra1Reg.
	self CmpCq: 0 R: Extra1Reg.
	jump3 := self JumpZero: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self ArithmeticShiftRightCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: Extra1Reg.
	self MoveR: Extra1Reg R: Extra2Reg.
	self AndCq: 16r3FFFFF R: Extra2Reg.
	self CmpCq: 36 R: Extra2Reg.
	jump4 := self JumpZero: 0.
	self LogicalShiftRightCq: 24 R: Extra1Reg.
	self AndCq: 31 R: Extra1Reg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveMb: 7 r: Extra3Reg R: Extra2Reg.
	self AndCq: 255 R: Extra2Reg.
	self CmpCq: 255 R: Extra2Reg.
	jump5 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: -8 r: Extra3Reg R: Extra2Reg.
	self LogicalShiftLeftCq: 8 R: Extra2Reg.
	self LogicalShiftRightCq: 8 R: Extra2Reg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self CmpCq: 5 R: Extra1Reg.
	jump6 := self JumpAbove: 0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self CmpCq: 16 R: Extra1Reg.
	jump6 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 3 R: Extra2Reg.
	self MoveR: Extra1Reg R: ClassReg.
	self AndCq: 7 R: ClassReg.
	self SubR: ClassReg R: Extra2Reg.
	self MoveR: Extra2Reg R: ClassReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self CmpCq: 12 R: Extra1Reg.
	jump6 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 2 R: Extra2Reg.
	self MoveR: Extra1Reg R: ClassReg.
	self AndCq: 3 R: ClassReg.
	self SubR: ClassReg R: Extra2Reg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self CmpCq: 10 R: Extra1Reg.
	jump6 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 1 R: Extra2Reg.
	self MoveR: Extra1Reg R: ClassReg.
	self AndCq: 1 R: ClassReg.
	self SubR: ClassReg R: Extra2Reg.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self CmpCq: 9 R: Extra1Reg.
	jump6 := self JumpNonZero: 0.
	jump10 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	s59 := 0.
	self MoveCq: s59 R: Extra2Reg.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	jump10 jmpTarget: currentBlock.
	self CmpCq: 9 R: Extra1Reg.
	jump10 := self JumpBelow: 0.
	self MoveR: Extra2Reg R: ClassReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump10 jmpTarget: currentBlock.
	self CmpCq: 2 R: Extra1Reg.
	jump10 := self JumpNonZero: 0.
	self MoveR: Extra2Reg R: ClassReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	s74 := 0.
	self MoveCq: s74 R: SendNumArgsReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump10 jmpTarget: currentBlock.
	self CmpCq: 2 R: Extra1Reg.
	jump10 := self JumpAboveOrEqual: 0.
	self MoveR: Extra2Reg R: SendNumArgsReg.
	self MoveR: Extra2Reg R: ClassReg.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump10 jmpTarget: currentBlock.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: ClassReg.
	self AndCq: 16r3FFFFF R: ClassReg.
	self CmpCq: 31 R: ClassReg.
	jump10 := self JumpAbove: 0.
	self CmpCq: 31 R: ClassReg.
	jump8 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ClassReg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self CmpCq: 8 R: ClassReg.
	jump8 := self JumpNonZero: 0.
	self genMoveConstant: objectMemory nilObject R: ClassReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump10 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self MoveR: ClassReg R: SendNumArgsReg.
	self LogicalShiftRightCq: 10 R: SendNumArgsReg.
	s94 := objectMemory hiddenRootsObject.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: s94 R: SendNumArgsReg.
	self MoveM64: 8 r: SendNumArgsReg R: SendNumArgsReg.
	self genMoveConstant: objectMemory nilObject R: Extra0Reg.
	self CmpR: Extra0Reg R: SendNumArgsReg.
	jump8 := self JumpNonZero: 0.
	self genMoveConstant: objectMemory nilObject R: Extra0Reg.
	jump10 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self AndCq: 1023 R: ClassReg.
	self LogicalShiftLeftCq: 3 R: ClassReg.
	self AddR: ClassReg R: SendNumArgsReg.
	self MoveM64: 8 r: SendNumArgsReg R: Extra0Reg.
	currentBlock := self Label.
	jump10 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	self MoveM64: 24 r: ClassReg R: Extra0Reg.
	self ArithmeticShiftRightCq: 3 R: Extra0Reg.
	self AndCq: 16rFFFF R: Extra0Reg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self MoveR: Extra2Reg R: ClassReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	self SubR: SendNumArgsReg R: ClassReg.
	self CmpCq: 24 R: Extra1Reg.
	jump9 := self JumpAboveOrEqual: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self CmpCq: 1 R: Extra3Reg.
	jump7 := self JumpBelow: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self CmpR: ClassReg R: Extra3Reg.
	jump6 := self JumpAbove: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self AddR: SendNumArgsReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self CmpCq: 5 R: Extra1Reg.
	jump5 := self JumpAbove: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self SubCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump10 := self JumpNonZero: 0.
	s131 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self AndCq: s131 R: Extra0Reg.
	s134 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s134 R: Extra0Reg.
	jump8 := self JumpNonZero: 0.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump11 := self JumpNonZero: 0.
	s139 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self AndCq: s139 R: Extra0Reg.
	s142 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s142 R: Extra0Reg.
	jump12 := self JumpNonZero: 0.
	s144 := objectMemory getMemoryMap getNewSpaceStart.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self CmpCq: s144 R: Extra0Reg.
	jumpTrue := self JumpAboveOrEqual: 0.
	self MoveCq: 0 R: Extra0Reg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: Extra0Reg.
	jumpNext jmpTarget: self Label.
	self CmpCq: 1 R: Extra0Reg.
	jump13 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: Extra0Reg.
	self LogicalShiftRightCq: 29 R: Extra0Reg.
	self AndCq: 1 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump14 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	jump15 := self Jump: 0.
	currentBlock := self Label.
	jump12 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump10 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump11 jmpTarget: currentBlock.
	jump13 jmpTarget: currentBlock.
	jump14 jmpTarget: currentBlock.
	jump15 jmpTarget: currentBlock.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: Extra0Reg.
	self LogicalShiftRightCq: 29 R: Extra0Reg.
	self AndCq: 1 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump15 := self JumpNonZero: 0.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self TstCq: 7 R: Extra3Reg.
	jump14 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self CmpCq: 16r20000000000 R: Extra3Reg.
	jump13 := self JumpBelow: 0.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self CmpCq: 16r20000000000 R: Extra3Reg.
	jump11 := self JumpAboveOrEqual: 0.
	self genMoveConstant: objectMemory nilObject R: Extra0Reg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self CmpR: Extra0Reg R: Extra3Reg.
	jump8 := self JumpBelow: 0.
	s166 := objectMemory trueObject.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self CmpCq: s166 R: Extra3Reg.
	jump10 := self JumpBelowOrEqual: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s168 := objectMemory getMemoryMap getNewSpaceStart.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self CmpCq: s168 R: Extra3Reg.
	jump8 := self JumpBelow: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump15 jmpTarget: currentBlock.
	jump14 jmpTarget: currentBlock.
	jump13 jmpTarget: currentBlock.
	jump11 jmpTarget: currentBlock.
	jump10 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self LogicalShiftLeftCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveMw: 8 r: SPReg R: Extra4Reg.
	self AddR: Extra4Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveMw: 0 r: SPReg R: Extra4Reg.
	self MoveR: Extra3Reg M64: 8 r: Extra4Reg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ReceiverResultReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 16 R: Extra1Reg.
	jump5 := self JumpBelow: 0.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self TstCq: 1 R: Extra3Reg.
	jump10 := self JumpZero: 0.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self ArithmeticShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump11 := self JumpBelow: 0.
	self CmpCq: 255 R: Extra0Reg.
	jump13 := self JumpAbove: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveMw: 0 r: SPReg R: Extra4Reg.
	self AddR: Extra4Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self AddCq:  -1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveR: Extra0Reg Mb: 8 r: Extra3Reg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ReceiverResultReg.
	jump14 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 12 R: Extra1Reg.
	jump5 := self JumpBelow: 0.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self TstCq: 1 R: Extra3Reg.
	jump15 := self JumpZero: 0.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self ArithmeticShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump12 := self JumpBelow: 0.
	self CmpCq: 16rFFFF R: Extra0Reg.
	jump16 := self JumpAbove: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self SubCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self LogicalShiftLeftCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveMw: 8 r: SPReg R: Extra4Reg.
	self AddR: Extra4Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra2Reg.
	self AddCq: 8 R: Extra2Reg.
	self MoveR: Extra2Reg R: Extra1Reg.
	self AndCq: 2 R: Extra1Reg.
	self CmpCq: 0 R: Extra1Reg.
	jump17 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM32: 8 r: Extra3Reg R: Extra1Reg.
	self AndCq: 16rFFFFFFFF R: Extra1Reg.
	self AndCq: 16rFFFF0000 R: Extra1Reg.
	self OrR: Extra0Reg R: Extra1Reg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra1Reg M32: 8 r: Extra3Reg.
	jump18 := self Jump: 0.
	currentBlock := self Label.
	jump17 jmpTarget: currentBlock.
	self MoveM32: -2 r: Extra2Reg R: Extra1Reg.
	self AndCq: 16rFFFFFFFF R: Extra1Reg.
	self AndCq: 16rFFFF R: Extra1Reg.
	self LogicalShiftLeftCq: 16 R: Extra0Reg.
	self OrR: Extra0Reg R: Extra1Reg.
	self MoveR: Extra1Reg M32: -2 r: Extra2Reg.
	currentBlock := self Label.
	jump18 jmpTarget: currentBlock.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ReceiverResultReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	jump14 jmpTarget: currentBlock.
	self AddCq: 24 R: SPReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump10 jmpTarget: currentBlock.
	jump11 jmpTarget: currentBlock.
	jump13 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump15 jmpTarget: currentBlock.
	jump12 jmpTarget: currentBlock.
	jump16 jmpTarget: currentBlock.
	self AddCq: 24 R: SPReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveBehaviorHash [
	"AutoGenerated by Druid"

	| jump1 jump2 currentBlock |
	self MoveR: ReceiverResultReg R: TempReg.
	self MoveM32: 4 r: TempReg R: TempReg.
	self AndCq: 16rFFFFFFFF R: TempReg.
	self AndCq: 16r3FFFFF R: TempReg.
	self CmpCq: 0 R: TempReg.
	jump1 := self JumpZero: 0.
	self CmpCq: 0 R: TempReg.
	jump2 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 3 R: TempReg.
	self AddCq: 1 R: TempReg.
	self MoveR: TempReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	^ CompletePrimitive
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveBitAnd [
	"AutoGenerated by Druid"

	| jump1 currentBlock |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndR: ClassReg R: Extra0Reg.
	self TstCq: 1 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self AndR: ClassReg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveBitOr [
	"AutoGenerated by Druid"

	| jump1 currentBlock |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndR: ClassReg R: Extra0Reg.
	self TstCq: 1 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self OrR: ClassReg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveBitShift [
	"AutoGenerated by Druid"

	| jump1 s63 s54 jump9 jump6 jump3 s42 currentBlock jump8 jump5 jump2 s41 s17 jump7 jump4 |
	self mclassIsSmallInteger ifFalse: [ ^ UnimplementedPrimitive ].
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self TstCq: 1 R: SendNumArgsReg.
	jump1 := self JumpZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump2 := self JumpLess: 0.
	self CmpCq: 61 R: SendNumArgsReg.
	jump3 := self JumpGreater: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftR: SendNumArgsReg R: Extra0Reg.
	self MoveR: Extra0Reg R: Extra1Reg.
	self ArithmeticShiftRightR: SendNumArgsReg R: Extra1Reg.
	self CmpR: Extra1Reg R: ClassReg.
	jump4 := self JumpNonZero: 0.
	self MoveR: Extra0Reg R: Extra1Reg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq:  -61 R: SendNumArgsReg.
	jump2 := self JumpLess: 0.
	s17 := 0.
	self MoveCq: s17 R: Extra1Reg.
	self SubR: SendNumArgsReg R: Extra1Reg.
	self ArithmeticShiftRightR: Extra1Reg R: ClassReg.
	self MoveR: ClassReg R: Extra1Reg.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveR: Extra1Reg R: SendNumArgsReg.
	self LogicalShiftRightCq: 60 R: SendNumArgsReg.
	self AddCq: 1 R: SendNumArgsReg.
	self AndCq: 15 R: SendNumArgsReg.
	self CmpCq: 1 R: SendNumArgsReg.
	jump5 := self JumpAbove: 0.
	self MoveR: Extra1Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 1 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 0 R: Extra1Reg.
	jump5 := self JumpGreaterOrEqual: 0.
	self CmpCq:  -1152921504606846976 R: Extra1Reg.
	jump7 := self JumpLess: 0.
	self MoveR: Extra1Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 1 R: SendNumArgsReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	s41 := 32.
	s42 := 0.
	self MoveCq: s42 R: SendNumArgsReg.
	self SubR: Extra1Reg R: SendNumArgsReg.
	self MoveCq: s41 R: ClassReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 16rFFFFFFFFFFFFFFF R: Extra1Reg.
	jump5 := self JumpGreater: 0.
	self MoveR: Extra1Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 1 R: SendNumArgsReg.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	s54 := 33.
	self MoveCq: s54 R: ClassReg.
	self MoveR: Extra1Reg R: SendNumArgsReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveAw: objectMemory freeStartAddress R: Extra1Reg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	s63 := objectMemory getScavengeThreshold.
	self CmpCq: s63 R: Extra0Reg.
	jump7 := self JumpAbove: 0.
	self AddCq: 16r100000010000000 R: ClassReg.
	self MoveR: ClassReg M64: 0 r: Extra1Reg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	self MoveR: Extra0Reg Aw: objectMemory freeStartAddress.
	self AndCq: 16rFFFFFFFFFFFFFFFF R: SendNumArgsReg.
	self MoveR: SendNumArgsReg M64: 8 r: Extra1Reg.
	self MoveR: Extra1Reg R: SendNumArgsReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveBitXor [
	"AutoGenerated by Druid"

	| jump1 jump2 currentBlock |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self TstCq: 1 R: SendNumArgsReg.
	jump1 := self JumpZero: 0.
	self TstCq: 1 R: ClassReg.
	jump2 := self JumpZero: 0.
	self XorR: ClassReg R: SendNumArgsReg.
	self AddCq: 1 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveClass [
	"AutoGenerated by Druid"

	| s32 s87 s2 s56 currentBlock s3 |
	s2 := self methodNumArgs.
	s2 = 0 ifTrue: [
		| jump5 jump3 jump1 jump6 jump4 jump2 |
		self MoveR: ReceiverResultReg R: ClassReg.
		self MoveR: ClassReg R: SendNumArgsReg.
		self AndCq: 7 R: SendNumArgsReg.
		self CmpCq: 0 R: SendNumArgsReg.
		jump1 := self JumpNonZero: 0.
		self MoveM64: 0 r: ClassReg R: SendNumArgsReg.
		self AndCq: 16r3FFFF7 R: SendNumArgsReg.
		self CmpCq: 0 R: SendNumArgsReg.
		jump2 := self JumpZero: 0.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		self MoveR: ClassReg R: SendNumArgsReg.
		self AndCq: 7 R: SendNumArgsReg.
		self CmpCq: 0 R: SendNumArgsReg.
		jump1 := self JumpZero: 0.
		self MoveAw: objectMemory hiddenRootsObject + 8 R: ClassReg.
		self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
		self AddR: SendNumArgsReg R: ClassReg.
		self MoveM64: 8 r: ClassReg R: ClassReg.
		jump3 := self Jump: 0.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		self MoveM64: 0 r: ClassReg R: SendNumArgsReg.
		self AndCq: 16r3FFFFF R: SendNumArgsReg.
		self CmpCq: 31 R: SendNumArgsReg.
		jump1 := self JumpAbove: 0.
		self CmpCq: 31 R: SendNumArgsReg.
		jump4 := self JumpNonZero: 0.
		self MoveR: ClassReg R: SendNumArgsReg.
		jump5 := self Jump: 0.
		currentBlock := self Label.
		jump4 jmpTarget: currentBlock.
		self CmpCq: 8 R: SendNumArgsReg.
		jump4 := self JumpNonZero: 0.
		self genMoveConstant: objectMemory nilObject R: SendNumArgsReg.
		jump6 := self Jump: 0.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		jump4 jmpTarget: currentBlock.
		self MoveR: SendNumArgsReg R: ClassReg.
		self LogicalShiftRightCq: 10 R: ClassReg.
		s32 := objectMemory hiddenRootsObject.
		self LogicalShiftLeftCq: 3 R: ClassReg.
		self AddCq: s32 R: ClassReg.
		self MoveM64: 8 r: ClassReg R: ClassReg.
		self genMoveConstant: objectMemory nilObject R: Extra0Reg.
		self CmpR: Extra0Reg R: ClassReg.
		jump4 := self JumpNonZero: 0.
		self genMoveConstant: objectMemory nilObject R: Extra0Reg.
		jump1 := self Jump: 0.
		currentBlock := self Label.
		jump4 jmpTarget: currentBlock.
		self AndCq: 1023 R: SendNumArgsReg.
		self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
		self AddR: SendNumArgsReg R: ClassReg.
		self MoveM64: 8 r: ClassReg R: Extra0Reg.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		self MoveR: Extra0Reg R: SendNumArgsReg.
		currentBlock := self Label.
		jump5 jmpTarget: currentBlock.
		jump6 jmpTarget: currentBlock.
		self MoveR: SendNumArgsReg R: ClassReg.
		currentBlock := self Label.
		jump3 jmpTarget: currentBlock.
		self MoveR: ClassReg R: ReceiverResultReg.
		self genPrimReturn.
		currentBlock := self Label.
		jump2 jmpTarget: currentBlock.
		^ 0 ].
	s56 := self methodNumArgs.
	s56 = 1 ifTrue: [
		| jump5 jump3 jump1 jump6 jump4 jump2 |
		self MoveR: Arg0Reg R: Extra0Reg.
		self MoveR: Extra0Reg R: ClassReg.
		self AndCq: 7 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump2 := self JumpNonZero: 0.
		self MoveM64: 0 r: Extra0Reg R: ClassReg.
		self AndCq: 16r3FFFF7 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump3 := self JumpZero: 0.
		currentBlock := self Label.
		jump2 jmpTarget: currentBlock.
		self MoveR: Extra0Reg R: ClassReg.
		self AndCq: 7 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump2 := self JumpZero: 0.
		self MoveAw: objectMemory hiddenRootsObject + 8 R: Extra0Reg.
		self LogicalShiftLeftCq: 3 R: ClassReg.
		self AddR: ClassReg R: Extra0Reg.
		self MoveM64: 8 r: Extra0Reg R: Extra0Reg.
		jump6 := self Jump: 0.
		currentBlock := self Label.
		jump2 jmpTarget: currentBlock.
		self MoveM64: 0 r: Extra0Reg R: ClassReg.
		self AndCq: 16r3FFFFF R: ClassReg.
		self CmpCq: 31 R: ClassReg.
		jump2 := self JumpAbove: 0.
		self CmpCq: 31 R: ClassReg.
		jump5 := self JumpNonZero: 0.
		self MoveR: Extra0Reg R: ClassReg.
		jump1 := self Jump: 0.
		currentBlock := self Label.
		jump5 jmpTarget: currentBlock.
		self CmpCq: 8 R: ClassReg.
		jump5 := self JumpNonZero: 0.
		self genMoveConstant: objectMemory nilObject R: ClassReg.
		jump4 := self Jump: 0.
		currentBlock := self Label.
		jump2 jmpTarget: currentBlock.
		jump5 jmpTarget: currentBlock.
		self MoveR: ClassReg R: Extra0Reg.
		self LogicalShiftRightCq: 10 R: Extra0Reg.
		s87 := objectMemory hiddenRootsObject.
		self LogicalShiftLeftCq: 3 R: Extra0Reg.
		self AddCq: s87 R: Extra0Reg.
		self MoveM64: 8 r: Extra0Reg R: Extra0Reg.
		self genMoveConstant: objectMemory nilObject R: SendNumArgsReg.
		self CmpR: SendNumArgsReg R: Extra0Reg.
		jump5 := self JumpNonZero: 0.
		self genMoveConstant: objectMemory nilObject R: SendNumArgsReg.
		jump2 := self Jump: 0.
		currentBlock := self Label.
		jump5 jmpTarget: currentBlock.
		self AndCq: 1023 R: ClassReg.
		self LogicalShiftLeftCq: 3 R: ClassReg.
		self AddR: ClassReg R: Extra0Reg.
		self MoveM64: 8 r: Extra0Reg R: SendNumArgsReg.
		currentBlock := self Label.
		jump2 jmpTarget: currentBlock.
		self MoveR: SendNumArgsReg R: ClassReg.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		jump4 jmpTarget: currentBlock.
		self MoveR: ClassReg R: Extra0Reg.
		currentBlock := self Label.
		jump6 jmpTarget: currentBlock.
		self MoveR: Extra0Reg R: ReceiverResultReg.
		self genPrimReturn.
		currentBlock := self Label.
		jump3 jmpTarget: currentBlock.
		^ 0 ].
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveDiv [
	"AutoGenerated by Druid"

	| jump1 s43 s22 jump3 s30 currentBlock s15 s38 jump2 jump5 jump4 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndR: SendNumArgsReg R: Extra0Reg.
	self TstCq: 1 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump2 := self JumpZero: 0.
	self CmpCq: 0 R: ClassReg.
	jump3 := self JumpLessOrEqual: 0.
	self CmpCq: 0 R: SendNumArgsReg.
	jump4 := self JumpLessOrEqual: 0.
	self
		DivR: SendNumArgsReg
		R: ClassReg
		Quo: Extra0Reg
		Rem: SendNumArgsReg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	s15 := 0.
	self MoveCq: s15 R: Extra0Reg.
	self SubR: SendNumArgsReg R: Extra0Reg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self AddR: ClassReg R: SendNumArgsReg.
	self AddCq:  -1 R: SendNumArgsReg.
	self
		DivR: Extra0Reg
		R: SendNumArgsReg
		Quo: SendNumArgsReg
		Rem: Extra0Reg.
	s22 := 0.
	self MoveCq: s22 R: Extra0Reg.
	self SubR: SendNumArgsReg R: Extra0Reg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s30 := 0.
	self MoveCq: s30 R: Extra0Reg.
	self SubR: ClassReg R: Extra0Reg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump3 := self JumpLessOrEqual: 0.
	self MoveR: SendNumArgsReg R: ClassReg.
	self AddR: Extra0Reg R: ClassReg.
	self AddCq:  -1 R: ClassReg.
	self
		DivR: SendNumArgsReg
		R: ClassReg
		Quo: ClassReg
		Rem: Extra0Reg.
	s38 := 0.
	self MoveCq: s38 R: Extra0Reg.
	self SubR: ClassReg R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s43 := 0.
	self MoveCq: s43 R: ClassReg.
	self SubR: SendNumArgsReg R: ClassReg.
	self
		DivR: ClassReg
		R: Extra0Reg
		Quo: ClassReg
		Rem: Extra0Reg.
	self MoveR: ClassReg R: Extra0Reg.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftRightCq: 60 R: ClassReg.
	self AddCq: 1 R: ClassReg.
	self AndCq: 15 R: ClassReg.
	self CmpCq: 1 R: ClassReg.
	jump5 := self JumpAbove: 0.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftRightCq: 60 R: ClassReg.
	self AddCq: 1 R: ClassReg.
	self AndCq: 15 R: ClassReg.
	self CmpCq: 1 R: ClassReg.
	jump4 := self JumpAbove: 0.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 3 R: ClassReg.
	self AddCq: 1 R: ClassReg.
	self MoveR: ClassReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveDivide [
	"AutoGenerated by Druid"

	| jump5 jump3 jump1 currentBlock jump4 jump2 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self TstCq: 1 R: ClassReg.
	jump1 := self JumpZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self TstCq: 1 R: SendNumArgsReg.
	jump2 := self JumpZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump3 := self JumpZero: 0.
	self
		DivR: SendNumArgsReg
		R: ClassReg
		Quo: Extra1Reg
		Rem: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self
		DivR: SendNumArgsReg
		R: ClassReg
		Quo: Extra0Reg
		Rem: Extra1Reg.
	self MoveR: Extra0Reg R: Extra1Reg.
	self LogicalShiftRightCq: 60 R: Extra1Reg.
	self AddCq: 1 R: Extra1Reg.
	self AndCq: 15 R: Extra1Reg.
	self CmpCq: 1 R: Extra1Reg.
	jump5 := self JumpAbove: 0.
	self MoveR: Extra0Reg R: Extra1Reg.
	self LogicalShiftLeftCq: 3 R: Extra1Reg.
	self AddCq: 1 R: Extra1Reg.
	self MoveR: Extra1Reg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveEqual [
	"AutoGenerated by Druid"

	| s11 s8 jump1 jump3 currentBlock jump2 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndR: SendNumArgsReg R: Extra0Reg.
	self TstCq: 1 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpR: SendNumArgsReg R: ClassReg.
	jump2 := self JumpNonZero: 0.
	s8 := objectMemory trueObject.
	self MoveCq: s8 R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	s11 := objectMemory falseObject.
	self MoveCq: s11 R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveFloatAdd [
	"AutoGenerated by Druid"

	| jump1 s89 jumpNext jump9 jump6 jump3 currentBlock jump8 jump5 jump2 s121 jumpTrue s118 s93 jump7 jump4 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self AddRd: DPFPReg1 Rd: DPFPReg0.
	self MoveRd: DPFPReg0 R: Extra0Reg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftRightCq: 52 R: SendNumArgsReg.
	self AndCq: 2047 R: SendNumArgsReg.
	self CmpCq: 896 R: SendNumArgsReg.
	jump8 := self JumpBelowOrEqual: 0.
	self CmpCq: 1151 R: SendNumArgsReg.
	jumpTrue := self JumpBelowOrEqual: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self AndCq: 16rFFFFFFFFFFFFF R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump8 := self JumpNonZero: 0.
	s89 := 0.
	self CmpCq: s89 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s93 := 896.
	self CmpCq: s93 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 1 R: SendNumArgsReg.
	jump7 := self JumpNonZero: 0.
	self MoveRd: DPFPReg0 R: SendNumArgsReg.
	self RotateLeftCq: 1 R: SendNumArgsReg.
	self CmpCq: 1 R: SendNumArgsReg.
	jump9 := self JumpBelowOrEqual: 0.
	self SubCq: 16r7000000000000000 R: SendNumArgsReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 4 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveAw: objectMemory freeStartAddress R: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	s118 := objectMemory getScavengeThreshold.
	self CmpCq: s118 R: Extra0Reg.
	jump7 := self JumpAbove: 0.
	s121 := 72057594205700130.
	self MoveCq: s121 R: Extra0Reg.
	self MoveR: Extra0Reg M64: 0 r: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	self MoveR: Extra0Reg Aw: objectMemory freeStartAddress.
	self MoveRd: DPFPReg0 M64: 8 r: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveFloatEqual [
	"AutoGenerated by Druid"

	| jump1 jump6 jump3 currentBlock s82 jump8 jump5 s79 jump2 jump7 jump4 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self CmpRd: DPFPReg1 Rd: DPFPReg0.
	jump8 := self JumpFPNotEqual: 0.
	s79 := objectMemory trueObject.
	self MoveCq: s79 R: ReceiverResultReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s82 := objectMemory falseObject.
	self MoveCq: s82 R: ReceiverResultReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveFloatGreaterOrEqual [
	"AutoGenerated by Druid"

	| jump1 jump6 jump3 currentBlock s82 jump8 jump5 s79 jump2 jump7 jump4 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self CmpRd: DPFPReg1 Rd: DPFPReg0.
	jump8 := self JumpFPLess: 0.
	s79 := objectMemory trueObject.
	self MoveCq: s79 R: ReceiverResultReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s82 := objectMemory falseObject.
	self MoveCq: s82 R: ReceiverResultReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveFloatGreaterThan [
	"AutoGenerated by Druid"

	| jump1 jump6 jump3 currentBlock s82 jump8 jump5 s79 jump2 jump7 jump4 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self CmpRd: DPFPReg1 Rd: DPFPReg0.
	jump8 := self JumpFPLessOrEqual: 0.
	s79 := objectMemory trueObject.
	self MoveCq: s79 R: ReceiverResultReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s82 := objectMemory falseObject.
	self MoveCq: s82 R: ReceiverResultReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveFloatLessOrEqual [
	"AutoGenerated by Druid"

	| jump1 jump6 jump3 currentBlock s82 jump8 jump5 s79 jump2 jump7 jump4 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self CmpRd: DPFPReg1 Rd: DPFPReg0.
	jump8 := self JumpFPGreater: 0.
	s79 := objectMemory trueObject.
	self MoveCq: s79 R: ReceiverResultReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s82 := objectMemory falseObject.
	self MoveCq: s82 R: ReceiverResultReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveFloatLessThan [
	"AutoGenerated by Druid"

	| jump1 jump6 jump3 currentBlock s82 jump8 jump5 s79 jump2 jump7 jump4 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self CmpRd: DPFPReg1 Rd: DPFPReg0.
	jump8 := self JumpFPGreaterOrEqual: 0.
	s79 := objectMemory trueObject.
	self MoveCq: s79 R: ReceiverResultReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s82 := objectMemory falseObject.
	self MoveCq: s82 R: ReceiverResultReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveFloatMultiply [
	"AutoGenerated by Druid"

	| jump1 s89 jumpNext jump9 jump6 jump3 currentBlock jump8 jump5 jump2 s121 jumpTrue s118 s93 jump7 jump4 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self MulRd: DPFPReg1 Rd: DPFPReg0.
	self MoveRd: DPFPReg0 R: Extra0Reg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftRightCq: 52 R: SendNumArgsReg.
	self AndCq: 2047 R: SendNumArgsReg.
	self CmpCq: 896 R: SendNumArgsReg.
	jump8 := self JumpBelowOrEqual: 0.
	self CmpCq: 1151 R: SendNumArgsReg.
	jumpTrue := self JumpBelowOrEqual: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self AndCq: 16rFFFFFFFFFFFFF R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump8 := self JumpNonZero: 0.
	s89 := 0.
	self CmpCq: s89 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s93 := 896.
	self CmpCq: s93 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 1 R: SendNumArgsReg.
	jump7 := self JumpNonZero: 0.
	self MoveRd: DPFPReg0 R: SendNumArgsReg.
	self RotateLeftCq: 1 R: SendNumArgsReg.
	self CmpCq: 1 R: SendNumArgsReg.
	jump9 := self JumpBelowOrEqual: 0.
	self SubCq: 16r7000000000000000 R: SendNumArgsReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 4 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveAw: objectMemory freeStartAddress R: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	s118 := objectMemory getScavengeThreshold.
	self CmpCq: s118 R: Extra0Reg.
	jump7 := self JumpAbove: 0.
	s121 := 72057594205700130.
	self MoveCq: s121 R: Extra0Reg.
	self MoveR: Extra0Reg M64: 0 r: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	self MoveR: Extra0Reg Aw: objectMemory freeStartAddress.
	self MoveRd: DPFPReg0 M64: 8 r: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveFloatNotEqual [
	"AutoGenerated by Druid"

	| jump1 jump6 jump3 currentBlock s82 jump8 jump5 s79 jump2 jump7 jump4 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self CmpRd: DPFPReg1 Rd: DPFPReg0.
	jump8 := self JumpFPNotEqual: 0.
	s79 := objectMemory falseObject.
	self MoveCq: s79 R: ReceiverResultReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s82 := objectMemory trueObject.
	self MoveCq: s82 R: ReceiverResultReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveFloatSubtract [
	"AutoGenerated by Druid"

	| jump1 s89 jumpNext jump9 jump6 jump3 currentBlock jump8 jump5 jump2 s121 jumpTrue s118 s93 jump7 jump4 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self SubRd: DPFPReg1 Rd: DPFPReg0.
	self MoveRd: DPFPReg0 R: Extra0Reg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftRightCq: 52 R: SendNumArgsReg.
	self AndCq: 2047 R: SendNumArgsReg.
	self CmpCq: 896 R: SendNumArgsReg.
	jump8 := self JumpBelowOrEqual: 0.
	self CmpCq: 1151 R: SendNumArgsReg.
	jumpTrue := self JumpBelowOrEqual: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self AndCq: 16rFFFFFFFFFFFFF R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump8 := self JumpNonZero: 0.
	s89 := 0.
	self CmpCq: s89 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s93 := 896.
	self CmpCq: s93 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 1 R: SendNumArgsReg.
	jump7 := self JumpNonZero: 0.
	self MoveRd: DPFPReg0 R: SendNumArgsReg.
	self RotateLeftCq: 1 R: SendNumArgsReg.
	self CmpCq: 1 R: SendNumArgsReg.
	jump9 := self JumpBelowOrEqual: 0.
	self SubCq: 16r7000000000000000 R: SendNumArgsReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 4 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveAw: objectMemory freeStartAddress R: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	s118 := objectMemory getScavengeThreshold.
	self CmpCq: s118 R: Extra0Reg.
	jump7 := self JumpAbove: 0.
	s121 := 72057594205700130.
	self MoveCq: s121 R: Extra0Reg.
	self MoveR: Extra0Reg M64: 0 r: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	self MoveR: Extra0Reg Aw: objectMemory freeStartAddress.
	self MoveRd: DPFPReg0 M64: 8 r: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveFullClosureValue [
	"AutoGenerated by Druid"

	| s2 currentBlock s22 s43 s3 |
	s2 := self methodNumArgs.
	s2 = 0 ifTrue: [
		| jump1 jump2 jump3 jump4 |
		self MoveR: ReceiverResultReg R: ClassReg.
		self MoveM64: 24 r: ClassReg R: SendNumArgsReg.
		self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
		self CmpCq: 0 R: SendNumArgsReg.
		jump1 := self JumpNonZero: 0.
		self MoveM64: 16 r: ClassReg R: SendNumArgsReg.
		self MoveR: SendNumArgsReg R: ClassReg.
		self AndCq: 7 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump2 := self JumpNonZero: 0.
		self MoveM64: 0 r: SendNumArgsReg R: ClassReg.
		self LogicalShiftRightCq: 24 R: ClassReg.
		self AndCq: 31 R: ClassReg.
		self CmpCq: 24 R: ClassReg.
		jump3 := self JumpBelow: 0.
		self MoveM64: 8 r: SendNumArgsReg R: ClassReg.
		self AndCq: 1 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump4 := self JumpNonZero: 0.
		self MoveM64: 8 r: SendNumArgsReg R: ClassReg.
		self AddCq: self fullBlockEntryOffset R: ClassReg.
		self JumpR: ClassReg.
		self genPrimReturn.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		jump2 jmpTarget: currentBlock.
		jump3 jmpTarget: currentBlock.
		jump4 jmpTarget: currentBlock.
		^ 0 ].
	s22 := self methodNumArgs.
	s22 = 1 ifTrue: [
		| jump4 jump3 jump2 jump1 |
		self MoveR: ReceiverResultReg R: ClassReg.
		self MoveR: Arg0Reg R: SendNumArgsReg.
		self MoveM64: 24 r: ClassReg R: SendNumArgsReg.
		self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
		self CmpCq: 1 R: SendNumArgsReg.
		jump4 := self JumpNonZero: 0.
		self MoveM64: 16 r: ClassReg R: SendNumArgsReg.
		self MoveR: SendNumArgsReg R: ClassReg.
		self AndCq: 7 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump3 := self JumpNonZero: 0.
		self MoveM64: 0 r: SendNumArgsReg R: ClassReg.
		self LogicalShiftRightCq: 24 R: ClassReg.
		self AndCq: 31 R: ClassReg.
		self CmpCq: 24 R: ClassReg.
		jump2 := self JumpBelow: 0.
		self MoveM64: 8 r: SendNumArgsReg R: ClassReg.
		self AndCq: 1 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump1 := self JumpNonZero: 0.
		self MoveM64: 8 r: SendNumArgsReg R: ClassReg.
		self AddCq: self fullBlockEntryOffset R: ClassReg.
		self JumpR: ClassReg.
		self genPrimReturn.
		currentBlock := self Label.
		jump4 jmpTarget: currentBlock.
		jump3 jmpTarget: currentBlock.
		jump2 jmpTarget: currentBlock.
		jump1 jmpTarget: currentBlock.
		^ 0 ].
	s43 := self methodNumArgs.
	s43 = 2 ifTrue: [
		| jump1 jump2 jump3 jump4 |
		self MoveR: ReceiverResultReg R: ClassReg.
		self MoveR: Arg0Reg R: SendNumArgsReg.
		self MoveR: Arg1Reg R: SendNumArgsReg.
		self MoveM64: 24 r: ClassReg R: SendNumArgsReg.
		self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
		self CmpCq: 2 R: SendNumArgsReg.
		jump1 := self JumpNonZero: 0.
		self MoveM64: 16 r: ClassReg R: SendNumArgsReg.
		self MoveR: SendNumArgsReg R: ClassReg.
		self AndCq: 7 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump2 := self JumpNonZero: 0.
		self MoveM64: 0 r: SendNumArgsReg R: ClassReg.
		self LogicalShiftRightCq: 24 R: ClassReg.
		self AndCq: 31 R: ClassReg.
		self CmpCq: 24 R: ClassReg.
		jump3 := self JumpBelow: 0.
		self MoveM64: 8 r: SendNumArgsReg R: ClassReg.
		self AndCq: 1 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump4 := self JumpNonZero: 0.
		self MoveM64: 8 r: SendNumArgsReg R: ClassReg.
		self AddCq: self fullBlockEntryOffset R: ClassReg.
		self JumpR: ClassReg.
		self genPrimReturn.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		jump2 jmpTarget: currentBlock.
		jump3 jmpTarget: currentBlock.
		jump4 jmpTarget: currentBlock.
		^ 0 ].
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveFullClosureValueNoContextSwitch [
	"AutoGenerated by Druid"

	| s2 currentBlock s22 s43 s3 |
	s2 := self methodNumArgs.
	s2 = 0 ifTrue: [
		| jump1 jump2 jump3 jump4 |
		self MoveR: ReceiverResultReg R: ClassReg.
		self MoveM64: 24 r: ClassReg R: SendNumArgsReg.
		self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
		self CmpCq: 0 R: SendNumArgsReg.
		jump1 := self JumpNonZero: 0.
		self MoveM64: 16 r: ClassReg R: SendNumArgsReg.
		self MoveR: SendNumArgsReg R: ClassReg.
		self AndCq: 7 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump2 := self JumpNonZero: 0.
		self MoveM64: 0 r: SendNumArgsReg R: ClassReg.
		self LogicalShiftRightCq: 24 R: ClassReg.
		self AndCq: 31 R: ClassReg.
		self CmpCq: 24 R: ClassReg.
		jump3 := self JumpBelow: 0.
		self MoveM64: 8 r: SendNumArgsReg R: ClassReg.
		self AndCq: 1 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump4 := self JumpNonZero: 0.
		self MoveM64: 8 r: SendNumArgsReg R: ClassReg.
		self AddCq: self fullBlockNoContextSwitchEntryOffset R: ClassReg.
		self JumpR: ClassReg.
		self genPrimReturn.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		jump2 jmpTarget: currentBlock.
		jump3 jmpTarget: currentBlock.
		jump4 jmpTarget: currentBlock.
		^ 0 ].
	s22 := self methodNumArgs.
	s22 = 1 ifTrue: [
		| jump4 jump3 jump2 jump1 |
		self MoveR: ReceiverResultReg R: ClassReg.
		self MoveR: Arg0Reg R: SendNumArgsReg.
		self MoveM64: 24 r: ClassReg R: SendNumArgsReg.
		self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
		self CmpCq: 1 R: SendNumArgsReg.
		jump4 := self JumpNonZero: 0.
		self MoveM64: 16 r: ClassReg R: SendNumArgsReg.
		self MoveR: SendNumArgsReg R: ClassReg.
		self AndCq: 7 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump3 := self JumpNonZero: 0.
		self MoveM64: 0 r: SendNumArgsReg R: ClassReg.
		self LogicalShiftRightCq: 24 R: ClassReg.
		self AndCq: 31 R: ClassReg.
		self CmpCq: 24 R: ClassReg.
		jump2 := self JumpBelow: 0.
		self MoveM64: 8 r: SendNumArgsReg R: ClassReg.
		self AndCq: 1 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump1 := self JumpNonZero: 0.
		self MoveM64: 8 r: SendNumArgsReg R: ClassReg.
		self AddCq: self fullBlockNoContextSwitchEntryOffset R: ClassReg.
		self JumpR: ClassReg.
		self genPrimReturn.
		currentBlock := self Label.
		jump4 jmpTarget: currentBlock.
		jump3 jmpTarget: currentBlock.
		jump2 jmpTarget: currentBlock.
		jump1 jmpTarget: currentBlock.
		^ 0 ].
	s43 := self methodNumArgs.
	s43 = 2 ifTrue: [
		| jump1 jump2 jump3 jump4 |
		self MoveR: ReceiverResultReg R: ClassReg.
		self MoveR: Arg0Reg R: SendNumArgsReg.
		self MoveR: Arg1Reg R: SendNumArgsReg.
		self MoveM64: 24 r: ClassReg R: SendNumArgsReg.
		self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
		self CmpCq: 2 R: SendNumArgsReg.
		jump1 := self JumpNonZero: 0.
		self MoveM64: 16 r: ClassReg R: SendNumArgsReg.
		self MoveR: SendNumArgsReg R: ClassReg.
		self AndCq: 7 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump2 := self JumpNonZero: 0.
		self MoveM64: 0 r: SendNumArgsReg R: ClassReg.
		self LogicalShiftRightCq: 24 R: ClassReg.
		self AndCq: 31 R: ClassReg.
		self CmpCq: 24 R: ClassReg.
		jump3 := self JumpBelow: 0.
		self MoveM64: 8 r: SendNumArgsReg R: ClassReg.
		self AndCq: 1 R: ClassReg.
		self CmpCq: 0 R: ClassReg.
		jump4 := self JumpNonZero: 0.
		self MoveM64: 8 r: SendNumArgsReg R: ClassReg.
		self AddCq: self fullBlockNoContextSwitchEntryOffset R: ClassReg.
		self JumpR: ClassReg.
		self genPrimReturn.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		jump2 jmpTarget: currentBlock.
		jump3 jmpTarget: currentBlock.
		jump4 jmpTarget: currentBlock.
		^ 0 ].
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveGreaterOrEqual [
	"AutoGenerated by Druid"

	| s11 s8 jump1 jump3 currentBlock jump2 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndR: SendNumArgsReg R: Extra0Reg.
	self TstCq: 1 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpR: SendNumArgsReg R: ClassReg.
	jump2 := self JumpLess: 0.
	s8 := objectMemory trueObject.
	self MoveCq: s8 R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	s11 := objectMemory falseObject.
	self MoveCq: s11 R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveGreaterThan [
	"AutoGenerated by Druid"

	| s11 s8 jump1 jump3 currentBlock jump2 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndR: SendNumArgsReg R: Extra0Reg.
	self TstCq: 1 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpR: SendNumArgsReg R: ClassReg.
	jump2 := self JumpLessOrEqual: 0.
	s8 := objectMemory trueObject.
	self MoveCq: s8 R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	s11 := objectMemory falseObject.
	self MoveCq: s11 R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveIdentical [
	"AutoGenerated by Druid"

	| b451 jump1 jump6 jump3 s56 s53 currentBlock jump5 jump2 b455 jump4 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFF7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg R: Extra0Reg.
	b455 := self Label.
	self MoveR: Extra0Reg R: ClassReg.
	self AndCq: 7 R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: Extra0Reg R: ClassReg.
	self AndCq: 16r3FFFF7 R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: Extra0Reg R: ClassReg.
	self MoveR: ClassReg R: Extra0Reg.
	jump5 := self Jump: b455.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFF7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg R: Extra0Reg.
	b451 := self Label.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self AndCq: 7 R: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: Extra0Reg R: SendNumArgsReg.
	self AndCq: 16r3FFFF7 R: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	jump6 := self Jump: b451.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpR: ClassReg R: SendNumArgsReg.
	jump3 := self JumpNonZero: 0.
	s53 := objectMemory trueObject.
	self MoveCq: s53 R: ReceiverResultReg.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s56 := objectMemory falseObject.
	self MoveCq: s56 R: ReceiverResultReg.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self genPrimReturn.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveIdentityHash [
	"AutoGenerated by Druid"

	| jump3 jump1 currentBlock jump4 jump2 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self TstCq: 7 R: ClassReg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: ClassReg R: SendNumArgsReg.
	self AndCq: 16r3FFFF7 R: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump2 := self JumpZero: 0.
	self MoveM32: 4 r: ClassReg R: SendNumArgsReg.
	self AndCq: 16rFFFFFFFF R: SendNumArgsReg.
	self AndCq: 16r3FFFFF R: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump3 := self JumpNonZero: 0.
	self MoveR: ClassReg R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceNewHashTrampoline ].
	self MoveR: TempReg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 1 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 1 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveImmediateAsInteger [
	"AutoGenerated by Druid"

	| s59 s21 s40 s2 s24 currentBlock s56 s3 |
	s2 := self methodNumArgs.
	s2 = 0 ifTrue: [
		| jump5 jump3 jump1 jump4 jump2 |
		self MoveR: ReceiverResultReg R: ClassReg.
		self TstCq: 1 R: ClassReg.
		jump1 := self JumpZero: 0.
		self ArithmeticShiftRightCq: 3 R: ClassReg.
		self LogicalShiftLeftCq: 3 R: ClassReg.
		self AddCq: 1 R: ClassReg.
		jump2 := self Jump: 0.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		self TstCq: 2 R: ClassReg.
		jump1 := self JumpZero: 0.
		self LogicalShiftRightCq: 3 R: ClassReg.
		jump3 := self Jump: 0.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		self TstCq: 4 R: ClassReg.
		jump1 := self JumpZero: 0.
		self MoveR: ClassReg R: SendNumArgsReg.
		self LogicalShiftRightCq: 4 R: SendNumArgsReg.
		self TstCq: 8 R: ClassReg.
		jump4 := self JumpZero: 0.
		s21 :=  -1152921504606846976.
		self MoveCq: s21 R: ClassReg.
		jump5 := self Jump: 0.
		currentBlock := self Label.
		jump4 jmpTarget: currentBlock.
		s24 := 0.
		self MoveCq: s24 R: ClassReg.
		currentBlock := self Label.
		jump5 jmpTarget: currentBlock.
		self AddR: ClassReg R: SendNumArgsReg.
		self MoveR: SendNumArgsReg R: ClassReg.
		currentBlock := self Label.
		jump3 jmpTarget: currentBlock.
		self LogicalShiftLeftCq: 3 R: ClassReg.
		self AddCq: 1 R: ClassReg.
		currentBlock := self Label.
		jump2 jmpTarget: currentBlock.
		self MoveR: ClassReg R: ReceiverResultReg.
		self genPrimReturn.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		^ 0 ].
	s40 := self methodNumArgs.
	s40 = 1 ifTrue: [
		| jump5 jump3 jump1 jump4 jump2 |
		self MoveR: Arg0Reg R: ClassReg.
		self TstCq: 1 R: ClassReg.
		jump1 := self JumpZero: 0.
		self ArithmeticShiftRightCq: 3 R: ClassReg.
		jump2 := self Jump: 0.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		self TstCq: 2 R: ClassReg.
		jump1 := self JumpZero: 0.
		self LogicalShiftRightCq: 3 R: ClassReg.
		jump3 := self Jump: 0.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		self TstCq: 4 R: ClassReg.
		jump1 := self JumpZero: 0.
		self MoveR: ClassReg R: SendNumArgsReg.
		self LogicalShiftRightCq: 4 R: SendNumArgsReg.
		self TstCq: 8 R: ClassReg.
		jump5 := self JumpZero: 0.
		s56 :=  -1152921504606846976.
		self MoveCq: s56 R: ClassReg.
		jump4 := self Jump: 0.
		currentBlock := self Label.
		jump5 jmpTarget: currentBlock.
		s59 := 0.
		self MoveCq: s59 R: ClassReg.
		currentBlock := self Label.
		jump4 jmpTarget: currentBlock.
		self AddR: ClassReg R: SendNumArgsReg.
		self MoveR: SendNumArgsReg R: ClassReg.
		currentBlock := self Label.
		jump3 jmpTarget: currentBlock.
		currentBlock := self Label.
		jump2 jmpTarget: currentBlock.
		self LogicalShiftLeftCq: 3 R: ClassReg.
		self AddCq: 1 R: ClassReg.
		self MoveR: ClassReg R: ReceiverResultReg.
		self genPrimReturn.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		^ 0 ].
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveLessOrEqual [
	"AutoGenerated by Druid"

	| s11 s8 jump1 jump3 currentBlock jump2 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndR: SendNumArgsReg R: Extra0Reg.
	self TstCq: 1 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpR: SendNumArgsReg R: ClassReg.
	jump2 := self JumpGreater: 0.
	s8 := objectMemory trueObject.
	self MoveCq: s8 R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	s11 := objectMemory falseObject.
	self MoveCq: s11 R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveLessThan [
	"AutoGenerated by Druid"

	| s11 s8 jump1 jump3 currentBlock jump2 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndR: SendNumArgsReg R: Extra0Reg.
	self TstCq: 1 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpR: SendNumArgsReg R: ClassReg.
	jump2 := self JumpGreaterOrEqual: 0.
	s8 := objectMemory trueObject.
	self MoveCq: s8 R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	s11 := objectMemory falseObject.
	self MoveCq: s11 R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveMod [
	"AutoGenerated by Druid"

	| jump5 jump3 jump1 currentBlock jump4 jump2 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndR: SendNumArgsReg R: Extra0Reg.
	self TstCq: 1 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump2 := self JumpZero: 0.
	self
		DivR: SendNumArgsReg
		R: ClassReg
		Quo: ClassReg
		Rem: Extra0Reg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump3 := self JumpGreaterOrEqual: 0.
	self CmpCq: 0 R: Extra0Reg.
	jump4 := self JumpLessOrEqual: 0.
	self AddR: SendNumArgsReg R: Extra0Reg.
	self MoveR: Extra0Reg R: ClassReg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpCq: 0 R: Extra0Reg.
	jump3 := self JumpGreaterOrEqual: 0.
	self AddR: SendNumArgsReg R: Extra0Reg.
	self MoveR: Extra0Reg R: ClassReg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 60 R: Extra0Reg.
	self AddCq: 1 R: Extra0Reg.
	self AndCq: 15 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump5 := self JumpAbove: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 60 R: Extra0Reg.
	self AddCq: 1 R: Extra0Reg.
	self AndCq: 15 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpAbove: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 3 R: Extra0Reg.
	self AddCq: 1 R: Extra0Reg.
	self MoveR: Extra0Reg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveMultiply [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self TstCq: 1 R: ClassReg.
	jump1 := self JumpZero: 0.
	self TstCq: 1 R: SendNumArgsReg.
	jump2 := self JumpZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self SubCq: 1 R: SendNumArgsReg.
	self MulR: ClassReg R: SendNumArgsReg.
	jump3 := self JumpMultiplyOverflow: 0.
	self AddCq: 1 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveNew [
	"AutoGenerated by Druid"

	| jump1 s28 jump6 b361 jump3 currentBlock jump5 jump2 s17 jump7 jump4 |
	self SubCq: 8 R: SPReg.
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveM64: 24 r: ClassReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self ArithmeticShiftRightCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self LogicalShiftRightCq: 16 R: Extra0Reg.
	self AndCq: 31 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump1 := self JumpBelowOrEqual: 0.
	self CmpCq: 5 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM32: 4 r: ClassReg R: ClassReg.
	self AndCq: 16rFFFFFFFF R: ClassReg.
	self AndCq: 16r3FFFFF R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jump1 := self JumpZero: 0.
	self CmpCq: 0 R: ClassReg.
	jump3 := self JumpBelow: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self AndCq: 16rFFFF R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self CmpCq: 255 R: Extra3Reg.
	jump4 := self JumpAboveOrEqual: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self CmpCq: 1 R: Extra3Reg.
	jump5 := self JumpAboveOrEqual: 0.
	s17 := 8.
	self MoveCq: s17 R: Extra1Reg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra1Reg.
	self LogicalShiftLeftCq: 3 R: Extra1Reg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self AddCq: 8 R: Extra1Reg.
	self MoveAw: objectMemory freeStartAddress R: Extra2Reg.
	self AddR: Extra1Reg R: Extra2Reg.
	s28 := objectMemory getScavengeThreshold.
	self CmpCq: s28 R: Extra2Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self CmpCq: s28 R: Extra2Reg.
	jump5 := self JumpAbove: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self MoveAw: objectMemory freeStartAddress R: Extra2Reg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 56 R: SendNumArgsReg.
	self LogicalShiftLeftCq: 24 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self AddR: ClassReg R: SendNumArgsReg.
	self OrCq: 0 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg M64: 0 r: Extra2Reg.
	self MoveAw: objectMemory freeStartAddress R: SendNumArgsReg.
	self AddR: Extra1Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Aw: objectMemory freeStartAddress.
	self genMoveConstant: objectMemory nilObject R: SendNumArgsReg.
	self MoveR: Extra2Reg R: Extra1Reg.
	self AddCq: 8 R: Extra1Reg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self LogicalShiftLeftCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveR: Extra2Reg R: ClassReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self AddR: Extra3Reg R: ClassReg.
	self AddCq: 8 R: ClassReg.
	self SubCq: 1 R: ClassReg.
	b361 := self Label.
	self CmpR: Extra1Reg R: ClassReg.
	jump6 := self JumpLess: 0.
	self MoveR: SendNumArgsReg M64: 0 r: Extra1Reg.
	self MoveR: Extra1Reg R: Extra0Reg.
	self AddCq: 8 R: Extra0Reg.
	self MoveR: Extra0Reg R: Extra1Reg.
	jump7 := self Jump: b361.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self MoveR: Extra2Reg R: ReceiverResultReg.
	self AddCq: 8 R: SPReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self AddCq: 8 R: SPReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveNewWithArg [
	"AutoGenerated by Druid"

	| jump5 jump10 s94 s55 jump3 b702 jump8 jump1 s36 currentBlock s101 s58 jump13 jump6 s73 s82 s47 jump11 jump4 s78 s168 jump9 jump2 s85 s157 s98 jump7 jump12 |
	self SubCq: 32 R: SPReg.
	self MoveR: ReceiverResultReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self TstCq: 1 R: SendNumArgsReg.
	jump1 := self JumpZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump2 := self JumpLess: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 24 r: Extra3Reg R: Extra0Reg.
	self ArithmeticShiftRightCq: 3 R: Extra0Reg.
	self MoveR: Extra0Reg R: Extra1Reg.
	self LogicalShiftRightCq: 16 R: Extra1Reg.
	self AndCq: 31 R: Extra1Reg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM32: 4 r: Extra3Reg R: Extra3Reg.
	self AndCq: 16rFFFFFFFF R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self AndCq: 16r3FFFFF R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self CmpCq: 2 R: Extra1Reg.
	jump3 := self JumpNonZero: 0.
	self genMoveConstant: objectMemory nilObject R: Extra0Reg.
	self MoveR: Extra0Reg R: ClassReg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpCq: 3 R: Extra1Reg.
	jump3 := self JumpNonZero: 0.
	self AndCq: 16rFFFF R: Extra0Reg.
	self AddR: SendNumArgsReg R: Extra0Reg.
	self genMoveConstant: objectMemory nilObject R: ClassReg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpCq: 4 R: Extra1Reg.
	jump3 := self JumpNonZero: 0.
	self AndCq: 16rFFFF R: Extra0Reg.
	self AddR: SendNumArgsReg R: Extra0Reg.
	self genMoveConstant: objectMemory nilObject R: ClassReg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s36 := 0.
	self CmpCq: 9 R: Extra1Reg.
	jump3 := self JumpNonZero: 0.
	self MoveCq: s36 R: ClassReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpCq: 10 R: Extra1Reg.
	jump3 := self JumpNonZero: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self CmpCq: 34 R: Extra3Reg.
	jump8 := self JumpNonZero: 0.
	self CmpCq: 2 R: SendNumArgsReg.
	jump9 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: ClassReg.
	self AddCq: 1 R: ClassReg.
	s47 := 2.
	self MoveCq: s47 R: Extra0Reg.
	self
		DivR: Extra0Reg
		R: ClassReg
		Quo: ClassReg
		Rem: Extra0Reg.
	self AndCq: 1 R: SendNumArgsReg.
	self AddR: SendNumArgsReg R: Extra1Reg.
	jump10 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s55 := 0.
	self MoveR: SendNumArgsReg R: ClassReg.
	self AddCq: 1 R: ClassReg.
	s58 := 2.
	self MoveCq: s58 R: Extra0Reg.
	self
		DivR: Extra0Reg
		R: ClassReg
		Quo: Extra0Reg
		Rem: ClassReg.
	self AndCq: 1 R: SendNumArgsReg.
	self AddR: SendNumArgsReg R: Extra1Reg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self CmpCq: 0 R: Extra3Reg.
	jump8 := self JumpNonZero: 0.
	self MoveCq: s55 R: ClassReg.
	jump11 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	currentBlock := self Label.
	jump10 jmpTarget: currentBlock.
	s73 := 0.
	self MoveCq: s73 R: Extra0Reg.
	jump10 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s78 := 0.
	self CmpCq: 12 R: Extra1Reg.
	jump3 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: ClassReg.
	self AddCq: 3 R: ClassReg.
	s82 := 4.
	self MoveCq: s82 R: Extra0Reg.
	self
		DivR: Extra0Reg
		R: ClassReg
		Quo: Extra2Reg
		Rem: Extra0Reg.
	s85 := 4.
	self MoveCq: s85 R: Extra0Reg.
	self SubR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 3 R: Extra0Reg.
	self AddR: Extra0Reg R: Extra1Reg.
	self MoveCq: s78 R: ClassReg.
	self MoveR: Extra2Reg R: SendNumArgsReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s94 := 0.
	self CmpCq: 16 R: Extra1Reg.
	jump3 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AddCq: 7 R: Extra0Reg.
	s98 := 8.
	self MoveCq: s98 R: Extra2Reg.
	self
		DivR: Extra2Reg
		R: Extra0Reg
		Quo: Extra0Reg
		Rem: Extra2Reg.
	s101 := 8.
	self MoveCq: s101 R: Extra2Reg.
	self SubR: SendNumArgsReg R: Extra2Reg.
	self AndCq: 7 R: Extra2Reg.
	self AddR: Extra2Reg R: Extra1Reg.
	self MoveCq: s94 R: ClassReg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	jump12 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpCq: 0 R: SendNumArgsReg.
	jump3 := self JumpNonZero: 0.
	self CmpCq: 5 R: Extra1Reg.
	jump13 := self JumpAbove: 0.
	self AndCq: 16rFFFF R: Extra0Reg.
	self genMoveConstant: objectMemory nilObject R: Extra2Reg.
	self MoveR: Extra2Reg R: ClassReg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump12 jmpTarget: currentBlock.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self CmpCq: 0 R: Extra3Reg.
	jump12 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	currentBlock := self Label.
	jump11 jmpTarget: currentBlock.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM32: 4 r: Extra3Reg R: Extra2Reg.
	self AndCq: 16rFFFFFFFF R: Extra2Reg.
	self AndCq: 16r3FFFFF R: Extra2Reg.
	self CmpCq: 0 R: Extra2Reg.
	jump11 := self JumpZero: 0.
	self CmpCq: 0 R: Extra2Reg.
	jump8 := self JumpBelow: 0.
	self MoveR: ClassReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveR: Extra0Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 24 r: SPReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump12 jmpTarget: currentBlock.
	self MoveR: ClassReg R: Extra0Reg.
	self MoveR: SendNumArgsReg R: ClassReg.
	currentBlock := self Label.
	jump10 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveR: ClassReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 24 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra2Reg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self CmpCq: 16rFFFF R: Extra3Reg.
	jump7 := self JumpAbove: 0.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self CmpCq: 255 R: Extra3Reg.
	jump10 := self JumpAboveOrEqual: 0.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self CmpCq: 1 R: Extra3Reg.
	jump12 := self JumpAboveOrEqual: 0.
	s157 := 8.
	self MoveCq: s157 R: ClassReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump12 jmpTarget: currentBlock.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ClassReg.
	self LogicalShiftLeftCq: 3 R: ClassReg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self AddCq: 8 R: ClassReg.
	self MoveAw: objectMemory freeStartAddress R: SendNumArgsReg.
	self AddR: ClassReg R: SendNumArgsReg.
	s168 := objectMemory getScavengeThreshold.
	self CmpCq: s168 R: SendNumArgsReg.
	jump6 := self JumpBelowOrEqual: 0.
	self CmpCq: s168 R: SendNumArgsReg.
	jump12 := self JumpAbove: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self MoveAw: objectMemory freeStartAddress R: SendNumArgsReg.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self LogicalShiftLeftCq: 56 R: Extra0Reg.
	self LogicalShiftLeftCq: 24 R: Extra1Reg.
	self AddR: Extra1Reg R: Extra0Reg.
	self AddR: Extra2Reg R: Extra0Reg.
	self OrCq: 0 R: Extra0Reg.
	self MoveR: Extra0Reg M64: 0 r: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddR: ClassReg R: Extra0Reg.
	self MoveR: Extra0Reg Aw: objectMemory freeStartAddress.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AddCq: 8 R: Extra0Reg.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self LogicalShiftLeftCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 24 r: SPReg.
	self MoveR: SendNumArgsReg R: ClassReg.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self AddR: Extra3Reg R: ClassReg.
	self AddCq: 8 R: ClassReg.
	self SubCq: 1 R: ClassReg.
	b702 := self Label.
	self CmpR: Extra0Reg R: ClassReg.
	jump6 := self JumpLess: 0.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg M64: 0 r: Extra0Reg.
	self MoveR: Extra0Reg R: Extra2Reg.
	self AddCq: 8 R: Extra2Reg.
	self MoveR: Extra2Reg R: Extra0Reg.
	jump5 := self Jump: b702.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	self AddCq: 32 R: SPReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump13 jmpTarget: currentBlock.
	jump11 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump10 jmpTarget: currentBlock.
	jump12 jmpTarget: currentBlock.
	self AddCq: 32 R: SPReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveNotEqual [
	"AutoGenerated by Druid"

	| s11 s8 jump1 jump3 currentBlock jump2 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndR: SendNumArgsReg R: Extra0Reg.
	self TstCq: 1 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpR: SendNumArgsReg R: ClassReg.
	jump2 := self JumpZero: 0.
	s8 := objectMemory trueObject.
	self MoveCq: s8 R: ReceiverResultReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	s11 := objectMemory falseObject.
	self MoveCq: s11 R: ReceiverResultReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveNotIdentical [
	"AutoGenerated by Druid"

	| b451 jump1 jump6 jump3 s56 s53 currentBlock jump5 jump2 b455 jump4 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFF7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg R: Extra0Reg.
	b455 := self Label.
	self MoveR: Extra0Reg R: ClassReg.
	self AndCq: 7 R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: Extra0Reg R: ClassReg.
	self AndCq: 16r3FFFF7 R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: Extra0Reg R: ClassReg.
	self MoveR: ClassReg R: Extra0Reg.
	jump5 := self Jump: b455.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFF7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg R: Extra0Reg.
	b451 := self Label.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self AndCq: 7 R: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: Extra0Reg R: SendNumArgsReg.
	self AndCq: 16r3FFFF7 R: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	jump6 := self Jump: b451.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpR: ClassReg R: SendNumArgsReg.
	jump3 := self JumpZero: 0.
	s53 := objectMemory trueObject.
	self MoveCq: s53 R: ReceiverResultReg.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s56 := objectMemory falseObject.
	self MoveCq: s56 R: ReceiverResultReg.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self genPrimReturn.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveQuo [
	"AutoGenerated by Druid"

	| jump1 s31 s39 s36 jump3 jump6 s18 currentBlock s27 jump5 jump2 s14 jump4 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self TstCq: 1 R: ClassReg.
	jump1 := self JumpZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self TstCq: 1 R: SendNumArgsReg.
	jump2 := self JumpZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump3 := self JumpZero: 0.
	self CmpCq: 0 R: ClassReg.
	jump4 := self JumpLessOrEqual: 0.
	self CmpCq: 0 R: SendNumArgsReg.
	jump5 := self JumpLessOrEqual: 0.
	self
		DivR: SendNumArgsReg
		R: ClassReg
		Quo: SendNumArgsReg
		Rem: ClassReg.
	self MoveR: SendNumArgsReg R: ClassReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	s14 := 0.
	self MoveCq: s14 R: Extra0Reg.
	self SubR: SendNumArgsReg R: Extra0Reg.
	self
		DivR: Extra0Reg
		R: ClassReg
		Quo: SendNumArgsReg
		Rem: Extra0Reg.
	s18 := 0.
	self MoveCq: s18 R: Extra0Reg.
	self SubR: SendNumArgsReg R: Extra0Reg.
	self MoveR: Extra0Reg R: ClassReg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self MoveR: ClassReg R: Extra0Reg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 0 R: SendNumArgsReg.
	jump4 := self JumpLessOrEqual: 0.
	s27 := 0.
	self MoveCq: s27 R: Extra0Reg.
	self SubR: ClassReg R: Extra0Reg.
	self
		DivR: SendNumArgsReg
		R: Extra0Reg
		Quo: SendNumArgsReg
		Rem: Extra0Reg.
	s31 := 0.
	self MoveCq: s31 R: Extra0Reg.
	self SubR: SendNumArgsReg R: Extra0Reg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	s36 := 0.
	self MoveCq: s36 R: Extra0Reg.
	self SubR: ClassReg R: Extra0Reg.
	s39 := 0.
	self MoveCq: s39 R: ClassReg.
	self SubR: SendNumArgsReg R: ClassReg.
	self
		DivR: ClassReg
		R: Extra0Reg
		Quo: Extra0Reg
		Rem: ClassReg.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftRightCq: 60 R: ClassReg.
	self AddCq: 1 R: ClassReg.
	self AndCq: 15 R: ClassReg.
	self CmpCq: 1 R: ClassReg.
	jump6 := self JumpAbove: 0.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 3 R: ClassReg.
	self AddCq: 1 R: ClassReg.
	self MoveR: ClassReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveSize [
	"AutoGenerated by Druid"

	| jump1 jump4 jumpNext jump6 jump3 currentBlock jump8 jump5 jumpTrue s107 jump2 s14 jump7 s138 |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: ClassReg R: Extra1Reg.
	self CmpCq: 7 R: Extra1Reg.
	jumpTrue := self JumpNonZero: 0.
	self MoveCq: 0 R: Extra1Reg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: Extra1Reg.
	jumpNext jmpTarget: self Label.
	self TstCq: 7 R: ClassReg.
	jump1 := self JumpZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra1Reg.
	self AndCq: 16r3FFFF7 R: Extra1Reg.
	s14 := 0.
	self MoveR: Extra1Reg R: Extra2Reg.
	self CmpCq: s14 R: Extra2Reg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: Extra2Reg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: Extra2Reg.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: Extra1Reg.
	jump1 := self JumpNonZero: 0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 24 R: Extra0Reg.
	self AndCq: 31 R: Extra0Reg.
	self MoveR: Extra0Reg R: Extra2Reg.
	self CmpCq: 2 R: Extra2Reg.
	jumpTrue := self JumpBelow: 0.
	self MoveCq: 0 R: Extra2Reg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: Extra2Reg.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveR: Extra2Reg R: Extra1Reg.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra1Reg.
	jump2 := self JumpZero: 0.
	self CmpCq: 3 R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self AndCq: 16r3FFFFF R: SendNumArgsReg.
	self CmpCq: 36 R: SendNumArgsReg.
	jump1 := self JumpZero: 0.
	self MoveMb: 7 r: ClassReg R: Extra2Reg.
	self AndCq: 255 R: Extra2Reg.
	self CmpCq: 255 R: Extra2Reg.
	jump4 := self JumpNonZero: 0.
	self MoveM64: -8 r: ClassReg R: Extra2Reg.
	self LogicalShiftLeftCq: 8 R: Extra2Reg.
	self LogicalShiftRightCq: 8 R: Extra2Reg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveMb: 7 r: ClassReg R: Extra2Reg.
	self AndCq: 255 R: Extra2Reg.
	self CmpCq: 255 R: Extra2Reg.
	jump3 := self JumpNonZero: 0.
	self MoveM64: -8 r: ClassReg R: Extra2Reg.
	self LogicalShiftLeftCq: 8 R: Extra2Reg.
	self LogicalShiftRightCq: 8 R: Extra2Reg.
	self CmpCq: 5 R: Extra0Reg.
	jump6 := self JumpAbove: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpCq: 5 R: Extra0Reg.
	jump3 := self JumpAbove: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self CmpCq: 16 R: Extra0Reg.
	jump6 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 3 R: Extra2Reg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self AndCq: 7 R: SendNumArgsReg.
	self SubR: SendNumArgsReg R: Extra2Reg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self CmpCq: 12 R: Extra0Reg.
	jump6 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 2 R: Extra2Reg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self AndCq: 3 R: SendNumArgsReg.
	self SubR: SendNumArgsReg R: Extra2Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self CmpCq: 10 R: Extra0Reg.
	jump6 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 1 R: Extra2Reg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self AndCq: 1 R: SendNumArgsReg.
	self SubR: SendNumArgsReg R: Extra2Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self CmpCq: 9 R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	s107 := 0.
	self MoveCq: s107 R: Extra2Reg.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self CmpCq: 9 R: Extra0Reg.
	jump8 := self JumpAboveOrEqual: 0.
	self CmpCq: 2 R: Extra0Reg.
	jump7 := self JumpNonZero: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self SubCq: 0 R: Extra2Reg.
	self MoveR: Extra2Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 1 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 2 R: Extra0Reg.
	jump7 := self JumpAboveOrEqual: 0.
	self SubR: Extra2Reg R: Extra2Reg.
	self MoveR: Extra2Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 1 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: SendNumArgsReg.
	self AndCq: 16r3FFFFF R: SendNumArgsReg.
	self CmpCq: 31 R: SendNumArgsReg.
	jump7 := self JumpAbove: 0.
	self CmpCq: 31 R: SendNumArgsReg.
	jump3 := self JumpNonZero: 0.
	self MoveR: ClassReg R: SendNumArgsReg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpCq: 8 R: SendNumArgsReg.
	jump3 := self JumpNonZero: 0.
	self genMoveConstant: objectMemory nilObject R: SendNumArgsReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: ClassReg.
	self LogicalShiftRightCq: 10 R: ClassReg.
	s138 := objectMemory hiddenRootsObject.
	self LogicalShiftLeftCq: 3 R: ClassReg.
	self AddCq: s138 R: ClassReg.
	self MoveM64: 8 r: ClassReg R: ClassReg.
	self genMoveConstant: objectMemory nilObject R: Extra0Reg.
	self CmpR: Extra0Reg R: ClassReg.
	jump3 := self JumpNonZero: 0.
	self genMoveConstant: objectMemory nilObject R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self AndCq: 1023 R: SendNumArgsReg.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddR: SendNumArgsReg R: ClassReg.
	self MoveM64: 8 r: ClassReg R: Extra0Reg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	self MoveM64: 24 r: SendNumArgsReg R: Extra0Reg.
	self ArithmeticShiftRightCq: 3 R: Extra0Reg.
	self AndCq: 16rFFFF R: Extra0Reg.
	self SubR: Extra0Reg R: Extra2Reg.
	self MoveR: Extra2Reg R: Extra0Reg.
	self LogicalShiftLeftCq: 3 R: Extra0Reg.
	self AddCq: 1 R: Extra0Reg.
	self MoveR: Extra0Reg R: ReceiverResultReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveSmallFloatAdd [
	"AutoGenerated by Druid"

	| jump1 s89 jumpNext jump9 jump6 jump3 currentBlock jump8 jump5 jump2 s121 jumpTrue s118 s93 jump7 jump4 |
	self mclassIsSmallFloat ifFalse: [ ^ UnimplementedPrimitive ].
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self AddRd: DPFPReg1 Rd: DPFPReg0.
	self MoveRd: DPFPReg0 R: Extra0Reg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftRightCq: 52 R: SendNumArgsReg.
	self AndCq: 2047 R: SendNumArgsReg.
	self CmpCq: 896 R: SendNumArgsReg.
	jump8 := self JumpBelowOrEqual: 0.
	self CmpCq: 1151 R: SendNumArgsReg.
	jumpTrue := self JumpBelowOrEqual: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self AndCq: 16rFFFFFFFFFFFFF R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump8 := self JumpNonZero: 0.
	s89 := 0.
	self CmpCq: s89 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s93 := 896.
	self CmpCq: s93 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 1 R: SendNumArgsReg.
	jump7 := self JumpNonZero: 0.
	self MoveRd: DPFPReg0 R: SendNumArgsReg.
	self RotateLeftCq: 1 R: SendNumArgsReg.
	self CmpCq: 1 R: SendNumArgsReg.
	jump9 := self JumpBelowOrEqual: 0.
	self SubCq: 16r7000000000000000 R: SendNumArgsReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 4 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveAw: objectMemory freeStartAddress R: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	s118 := objectMemory getScavengeThreshold.
	self CmpCq: s118 R: Extra0Reg.
	jump7 := self JumpAbove: 0.
	s121 := 72057594205700130.
	self MoveCq: s121 R: Extra0Reg.
	self MoveR: Extra0Reg M64: 0 r: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	self MoveR: Extra0Reg Aw: objectMemory freeStartAddress.
	self MoveRd: DPFPReg0 M64: 8 r: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveSmallFloatDivide [
	"AutoGenerated by Druid"

	| jump1 jump10 jumpNext s92 jump6 jump3 jump9 currentBlock jump8 jump5 jump2 s121 s124 jumpTrue s96 jump7 jump4 |
	self mclassIsSmallFloat ifFalse: [ ^ UnimplementedPrimitive ].
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self MoveCq: (objectMemory rawFloatBitsOf: 0.0) R: Extra0Reg.
	self MoveR: Extra0Reg Rd: DPFPReg2.
	self CmpRd: DPFPReg2 Rd: DPFPReg1.
	jump8 := self JumpFPEqual: 0.
	self DivRd: DPFPReg1 Rd: DPFPReg0.
	self MoveRd: DPFPReg0 R: Extra0Reg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftRightCq: 52 R: SendNumArgsReg.
	self AndCq: 2047 R: SendNumArgsReg.
	self CmpCq: 896 R: SendNumArgsReg.
	jump7 := self JumpBelowOrEqual: 0.
	self CmpCq: 1151 R: SendNumArgsReg.
	jumpTrue := self JumpBelowOrEqual: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self AndCq: 16rFFFFFFFFFFFFF R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump7 := self JumpNonZero: 0.
	s92 := 0.
	self CmpCq: s92 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump10 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	s96 := 896.
	self CmpCq: s96 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump10 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self CmpCq: 1 R: SendNumArgsReg.
	jump9 := self JumpNonZero: 0.
	self MoveRd: DPFPReg0 R: SendNumArgsReg.
	self RotateLeftCq: 1 R: SendNumArgsReg.
	self CmpCq: 1 R: SendNumArgsReg.
	jump10 := self JumpBelowOrEqual: 0.
	self SubCq: 16r7000000000000000 R: SendNumArgsReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump10 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 4 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self MoveAw: objectMemory freeStartAddress R: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	s121 := objectMemory getScavengeThreshold.
	self CmpCq: s121 R: Extra0Reg.
	jump9 := self JumpAbove: 0.
	s124 := 72057594205700130.
	self MoveCq: s124 R: Extra0Reg.
	self MoveR: Extra0Reg M64: 0 r: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	self MoveR: Extra0Reg Aw: objectMemory freeStartAddress.
	self MoveRd: DPFPReg0 M64: 8 r: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveSmallFloatEqual [
	"AutoGenerated by Druid"

	| jump1 jump6 jump3 currentBlock s82 jump8 jump5 s79 jump2 jump7 jump4 |
	self mclassIsSmallFloat ifFalse: [ ^ UnimplementedPrimitive ].
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self CmpRd: DPFPReg1 Rd: DPFPReg0.
	jump8 := self JumpFPNotEqual: 0.
	s79 := objectMemory trueObject.
	self MoveCq: s79 R: ReceiverResultReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s82 := objectMemory falseObject.
	self MoveCq: s82 R: ReceiverResultReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveSmallFloatGreaterOrEqual [
	"AutoGenerated by Druid"

	| jump1 jump6 jump3 currentBlock s82 jump8 jump5 s79 jump2 jump7 jump4 |
	self mclassIsSmallFloat ifFalse: [ ^ UnimplementedPrimitive ].
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self CmpRd: DPFPReg1 Rd: DPFPReg0.
	jump8 := self JumpFPLess: 0.
	s79 := objectMemory trueObject.
	self MoveCq: s79 R: ReceiverResultReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s82 := objectMemory falseObject.
	self MoveCq: s82 R: ReceiverResultReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveSmallFloatGreaterThan [
	"AutoGenerated by Druid"

	| jump1 jump6 jump3 currentBlock s82 jump8 jump5 s79 jump2 jump7 jump4 |
	self mclassIsSmallFloat ifFalse: [ ^ UnimplementedPrimitive ].
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self CmpRd: DPFPReg1 Rd: DPFPReg0.
	jump8 := self JumpFPLessOrEqual: 0.
	s79 := objectMemory trueObject.
	self MoveCq: s79 R: ReceiverResultReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s82 := objectMemory falseObject.
	self MoveCq: s82 R: ReceiverResultReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveSmallFloatLessOrEqual [
	"AutoGenerated by Druid"

	| jump1 jump6 jump3 currentBlock s82 jump8 jump5 s79 jump2 jump7 jump4 |
	self mclassIsSmallFloat ifFalse: [ ^ UnimplementedPrimitive ].
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self CmpRd: DPFPReg1 Rd: DPFPReg0.
	jump8 := self JumpFPGreater: 0.
	s79 := objectMemory trueObject.
	self MoveCq: s79 R: ReceiverResultReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s82 := objectMemory falseObject.
	self MoveCq: s82 R: ReceiverResultReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveSmallFloatLessThan [
	"AutoGenerated by Druid"

	| jump1 jump6 jump3 currentBlock s82 jump8 jump5 s79 jump2 jump7 jump4 |
	self mclassIsSmallFloat ifFalse: [ ^ UnimplementedPrimitive ].
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self CmpRd: DPFPReg1 Rd: DPFPReg0.
	jump8 := self JumpFPGreaterOrEqual: 0.
	s79 := objectMemory trueObject.
	self MoveCq: s79 R: ReceiverResultReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s82 := objectMemory falseObject.
	self MoveCq: s82 R: ReceiverResultReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveSmallFloatMultiply [
	"AutoGenerated by Druid"

	| jump1 s89 jumpNext jump9 jump6 jump3 currentBlock jump8 jump5 jump2 s121 jumpTrue s118 s93 jump7 jump4 |
	self mclassIsSmallFloat ifFalse: [ ^ UnimplementedPrimitive ].
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self MulRd: DPFPReg1 Rd: DPFPReg0.
	self MoveRd: DPFPReg0 R: Extra0Reg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftRightCq: 52 R: SendNumArgsReg.
	self AndCq: 2047 R: SendNumArgsReg.
	self CmpCq: 896 R: SendNumArgsReg.
	jump8 := self JumpBelowOrEqual: 0.
	self CmpCq: 1151 R: SendNumArgsReg.
	jumpTrue := self JumpBelowOrEqual: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self AndCq: 16rFFFFFFFFFFFFF R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump8 := self JumpNonZero: 0.
	s89 := 0.
	self CmpCq: s89 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s93 := 896.
	self CmpCq: s93 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 1 R: SendNumArgsReg.
	jump7 := self JumpNonZero: 0.
	self MoveRd: DPFPReg0 R: SendNumArgsReg.
	self RotateLeftCq: 1 R: SendNumArgsReg.
	self CmpCq: 1 R: SendNumArgsReg.
	jump9 := self JumpBelowOrEqual: 0.
	self SubCq: 16r7000000000000000 R: SendNumArgsReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 4 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveAw: objectMemory freeStartAddress R: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	s118 := objectMemory getScavengeThreshold.
	self CmpCq: s118 R: Extra0Reg.
	jump7 := self JumpAbove: 0.
	s121 := 72057594205700130.
	self MoveCq: s121 R: Extra0Reg.
	self MoveR: Extra0Reg M64: 0 r: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	self MoveR: Extra0Reg Aw: objectMemory freeStartAddress.
	self MoveRd: DPFPReg0 M64: 8 r: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveSmallFloatNotEqual [
	"AutoGenerated by Druid"

	| jump1 jump6 jump3 currentBlock s82 jump8 jump5 s79 jump2 jump7 jump4 |
	self mclassIsSmallFloat ifFalse: [ ^ UnimplementedPrimitive ].
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self CmpRd: DPFPReg1 Rd: DPFPReg0.
	jump8 := self JumpFPNotEqual: 0.
	s79 := objectMemory falseObject.
	self MoveCq: s79 R: ReceiverResultReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s82 := objectMemory trueObject.
	self MoveCq: s82 R: ReceiverResultReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveSmallFloatSubtract [
	"AutoGenerated by Druid"

	| jump1 s89 jumpNext jump9 jump6 jump3 currentBlock jump8 jump5 jump2 s121 jumpTrue s118 s93 jump7 jump4 |
	self mclassIsSmallFloat ifFalse: [ ^ UnimplementedPrimitive ].
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump1 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump3 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 63 R: ClassReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg Rd: DPFPReg0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump2 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: ClassReg R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self ConvertR: ClassReg Rd: DPFPReg0.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveM64: 0 r: ClassReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: ClassReg Rd: DPFPReg0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump5 := self JumpZero: 0.
	self CmpCq: 4 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 3 R: Extra0Reg.
	self CmpCq: 1 R: Extra0Reg.
	jump6 := self JumpBelowOrEqual: 0.
	self AddCq: 16r7000000000000000 R: Extra0Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 63 R: SendNumArgsReg.
	self LogicalShiftRightCq: 1 R: Extra0Reg.
	self AddR: Extra0Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg Rd: DPFPReg1.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 1 R: Extra0Reg.
	jump4 := self JumpNonZero: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 9 R: Extra0Reg.
	self ArithmeticShiftRightCq: 9 R: Extra0Reg.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self ArithmeticShiftRightCq: 3 R: SendNumArgsReg.
	self ConvertR: SendNumArgsReg Rd: DPFPReg1.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: SendNumArgsReg R: Extra0Reg.
	self AndCq: 16r3FFFFF R: Extra0Reg.
	self CmpCq: 34 R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self MoveM64: 8 r: SendNumArgsReg Rd: DPFPReg1.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self SubRd: DPFPReg1 Rd: DPFPReg0.
	self MoveRd: DPFPReg0 R: Extra0Reg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self LogicalShiftRightCq: 52 R: SendNumArgsReg.
	self AndCq: 2047 R: SendNumArgsReg.
	self CmpCq: 896 R: SendNumArgsReg.
	jump8 := self JumpBelowOrEqual: 0.
	self CmpCq: 1151 R: SendNumArgsReg.
	jumpTrue := self JumpBelowOrEqual: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self AndCq: 16rFFFFFFFFFFFFF R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump8 := self JumpNonZero: 0.
	s89 := 0.
	self CmpCq: s89 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s93 := 896.
	self CmpCq: s93 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 1 R: SendNumArgsReg.
	jump7 := self JumpNonZero: 0.
	self MoveRd: DPFPReg0 R: SendNumArgsReg.
	self RotateLeftCq: 1 R: SendNumArgsReg.
	self CmpCq: 1 R: SendNumArgsReg.
	jump9 := self JumpBelowOrEqual: 0.
	self SubCq: 16r7000000000000000 R: SendNumArgsReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: 4 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self MoveAw: objectMemory freeStartAddress R: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	s118 := objectMemory getScavengeThreshold.
	self CmpCq: s118 R: Extra0Reg.
	jump7 := self JumpAbove: 0.
	s121 := 72057594205700130.
	self MoveCq: s121 R: Extra0Reg.
	self MoveR: Extra0Reg M64: 0 r: SendNumArgsReg.
	self MoveAw: objectMemory freeStartAddress R: Extra0Reg.
	self AddCq: 16 R: Extra0Reg.
	self MoveR: Extra0Reg Aw: objectMemory freeStartAddress.
	self MoveRd: DPFPReg0 M64: 8 r: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self genPrimReturn.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveStringAt [
	"AutoGenerated by Druid"

	| jump1 jump10 jump9 jump6 jump3 jump12 currentBlock jump8 jump5 jump2 s73 jump11 s55 s93 jump7 jump4 |
	self SubCq: 24 R: SPReg.
	self MoveR: ReceiverResultReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveR: Arg0Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self TstCq: 7 R: Extra3Reg.
	jump1 := self JumpNonZero: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self AndCq: 1 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump2 := self JumpZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: Extra0Reg.
	self AndCq: 16r3FFFF7 R: Extra0Reg.
	self CmpCq: 0 R: Extra0Reg.
	jump3 := self JumpZero: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self ArithmeticShiftRightCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra1Reg.
	self LogicalShiftRightCq: 24 R: Extra1Reg.
	self AndCq: 31 R: Extra1Reg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveMb: 7 r: Extra3Reg R: Extra2Reg.
	self AndCq: 255 R: Extra2Reg.
	self CmpCq: 255 R: Extra2Reg.
	jump4 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: -8 r: Extra3Reg R: Extra2Reg.
	self LogicalShiftLeftCq: 8 R: Extra2Reg.
	self LogicalShiftRightCq: 8 R: Extra2Reg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 5 R: Extra1Reg.
	jump5 := self JumpAbove: 0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 16 R: Extra1Reg.
	jump5 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 3 R: Extra2Reg.
	self MoveR: Extra1Reg R: ClassReg.
	self AndCq: 7 R: ClassReg.
	self SubR: ClassReg R: Extra2Reg.
	self MoveR: Extra2Reg R: ClassReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 12 R: Extra1Reg.
	jump5 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 2 R: Extra2Reg.
	self MoveR: Extra1Reg R: ClassReg.
	self AndCq: 3 R: ClassReg.
	self SubR: ClassReg R: Extra2Reg.
	self MoveR: Extra2Reg R: ClassReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 10 R: Extra1Reg.
	jump5 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 1 R: Extra2Reg.
	self MoveR: Extra1Reg R: ClassReg.
	self AndCq: 1 R: ClassReg.
	self SubR: ClassReg R: Extra2Reg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 9 R: Extra1Reg.
	jump5 := self JumpNonZero: 0.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	s55 := 0.
	self MoveCq: s55 R: Extra2Reg.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	self CmpCq: 9 R: Extra1Reg.
	jump9 := self JumpBelow: 0.
	self MoveR: Extra2Reg R: ClassReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self CmpCq: 2 R: Extra1Reg.
	jump9 := self JumpNonZero: 0.
	self MoveR: Extra2Reg R: ClassReg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	s73 := 0.
	self MoveCq: s73 R: SendNumArgsReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self CmpCq: 2 R: Extra1Reg.
	jump9 := self JumpAboveOrEqual: 0.
	self MoveR: Extra2Reg R: SendNumArgsReg.
	self MoveR: Extra2Reg R: ClassReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: ClassReg.
	self AndCq: 16r3FFFFF R: ClassReg.
	self CmpCq: 31 R: ClassReg.
	jump9 := self JumpAbove: 0.
	self CmpCq: 31 R: ClassReg.
	jump8 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ClassReg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self CmpCq: 8 R: ClassReg.
	jump8 := self JumpNonZero: 0.
	self genMoveConstant: objectMemory nilObject R: ClassReg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self MoveR: ClassReg R: SendNumArgsReg.
	self LogicalShiftRightCq: 10 R: SendNumArgsReg.
	s93 := objectMemory hiddenRootsObject.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddCq: s93 R: SendNumArgsReg.
	self MoveM64: 8 r: SendNumArgsReg R: SendNumArgsReg.
	self genMoveConstant: objectMemory nilObject R: Extra0Reg.
	self CmpR: Extra0Reg R: SendNumArgsReg.
	jump8 := self JumpNonZero: 0.
	self genMoveConstant: objectMemory nilObject R: Extra0Reg.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self AndCq: 1023 R: ClassReg.
	self LogicalShiftLeftCq: 3 R: ClassReg.
	self AddR: ClassReg R: SendNumArgsReg.
	self MoveM64: 8 r: SendNumArgsReg R: Extra0Reg.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 24 r: ClassReg R: Extra0Reg.
	self ArithmeticShiftRightCq: 3 R: Extra0Reg.
	self AndCq: 16rFFFF R: Extra0Reg.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self MoveR: Extra2Reg R: ClassReg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 3 R: Extra1Reg.
	jump7 := self JumpNonZero: 0.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self AndCq: 16r3FFFFF R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self CmpCq: 36 R: Extra3Reg.
	jump6 := self JumpZero: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self SubR: SendNumArgsReg R: ClassReg.
	self CmpCq: 24 R: Extra1Reg.
	jump7 := self JumpAboveOrEqual: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self CmpCq: 1 R: Extra3Reg.
	jump5 := self JumpBelow: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self CmpR: ClassReg R: Extra3Reg.
	jump4 := self JumpAbove: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self AddR: SendNumArgsReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self CmpCq: 5 R: Extra1Reg.
	jump9 := self JumpAbove: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self SubCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self LogicalShiftLeftCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveMw: 8 r: SPReg R: Extra4Reg.
	self AddR: Extra4Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 8 r: Extra3Reg R: Extra0Reg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self CmpCq: 16 R: Extra1Reg.
	jump9 := self JumpBelow: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveMw: 0 r: SPReg R: Extra4Reg.
	self AddR: Extra4Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self AddCq:  -1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveMb: 8 r: Extra3Reg R: Extra0Reg.
	self AndCq: 255 R: Extra0Reg.
	self LogicalShiftLeftCq: 3 R: Extra0Reg.
	self AddCq: 1 R: Extra0Reg.
	jump10 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self CmpCq: 12 R: Extra1Reg.
	jump9 := self JumpBelow: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self SubCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self LogicalShiftLeftCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveMw: 8 r: SPReg R: Extra4Reg.
	self AddR: Extra4Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM16: 8 r: Extra3Reg R: Extra0Reg.
	self AndCq: 16rFFFF R: Extra0Reg.
	self LogicalShiftLeftCq: 3 R: Extra0Reg.
	self AddCq: 1 R: Extra0Reg.
	jump11 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self CmpCq: 9 R: Extra1Reg.
	jump9 := self JumpNonZero: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self SubCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self LogicalShiftLeftCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveMw: 8 r: SPReg R: Extra4Reg.
	self AddR: Extra4Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 8 r: Extra3Reg R: Extra0Reg.
	self CmpCq: 16rFFFFFFFFFFFFFFF R: Extra0Reg.
	jump12 := self JumpAbove: 0.
	self LogicalShiftLeftCq: 3 R: Extra0Reg.
	self AddCq: 1 R: Extra0Reg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	jump10 jmpTarget: currentBlock.
	jump11 jmpTarget: currentBlock.
	self CmpCq: 0 R: Extra0Reg.
	jump11 := self JumpLess: 0.
	self CmpCq: 16r3FFFFFFF R: Extra0Reg.
	jump10 := self JumpGreater: 0.
	self ArithmeticShiftRightCq: 3 R: Extra0Reg.
	self LogicalShiftLeftCq: 3 R: Extra0Reg.
	self AddCq: 2 R: Extra0Reg.
	self MoveR: Extra0Reg R: ReceiverResultReg.
	self AddCq: 24 R: SPReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	jump12 jmpTarget: currentBlock.
	jump11 jmpTarget: currentBlock.
	jump10 jmpTarget: currentBlock.
	self AddCq: 24 R: SPReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveStringAtPut [
	"AutoGenerated by Druid"

	| s147 jump5 s169 jump10 jump17 s145 s77 jump3 jump15 jump8 jump1 s134 s62 currentBlock s97 jump13 s171 jump6 jumpNext jump18 jump11 s137 jump4 jumpTrue jump16 jump9 jump2 jump14 jump7 s142 jump19 jump12 |
	self SubCq: 32 R: SPReg.
	self MoveR: ReceiverResultReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveR: Arg0Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveR: Arg1Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self TstCq: 7 R: Extra3Reg.
	jump1 := self JumpNonZero: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra1Reg.
	self AndCq: 1 R: Extra1Reg.
	self CmpCq: 0 R: Extra1Reg.
	jump2 := self JumpZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: Extra1Reg.
	self AndCq: 16r3FFFF7 R: Extra1Reg.
	self CmpCq: 0 R: Extra1Reg.
	jump3 := self JumpZero: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self ArithmeticShiftRightCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self TstCq: 2 R: Extra3Reg.
	jump4 := self JumpZero: 0.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 24 r: SPReg.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self SubCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 24 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: Extra2Reg.
	self MoveR: Extra2Reg R: ClassReg.
	self AndCq: 16r3FFFFF R: ClassReg.
	self CmpCq: 36 R: ClassReg.
	jump5 := self JumpZero: 0.
	self LogicalShiftRightCq: 24 R: Extra2Reg.
	self AndCq: 31 R: Extra2Reg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveMb: 7 r: Extra3Reg R: ClassReg.
	self AndCq: 255 R: ClassReg.
	self CmpCq: 255 R: ClassReg.
	jump6 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: -8 r: Extra3Reg R: ClassReg.
	self LogicalShiftLeftCq: 8 R: ClassReg.
	self LogicalShiftRightCq: 8 R: ClassReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 5 R: Extra2Reg.
	jump7 := self JumpAbove: 0.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 16 R: Extra2Reg.
	jump7 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 3 R: ClassReg.
	self MoveR: Extra2Reg R: SendNumArgsReg.
	self AndCq: 7 R: SendNumArgsReg.
	self SubR: SendNumArgsReg R: ClassReg.
	self MoveR: ClassReg R: SendNumArgsReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 12 R: Extra2Reg.
	jump7 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 2 R: ClassReg.
	self MoveR: Extra2Reg R: SendNumArgsReg.
	self AndCq: 3 R: SendNumArgsReg.
	self SubR: SendNumArgsReg R: ClassReg.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 10 R: Extra2Reg.
	jump7 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 1 R: ClassReg.
	self MoveR: Extra2Reg R: SendNumArgsReg.
	self AndCq: 1 R: SendNumArgsReg.
	self SubR: SendNumArgsReg R: ClassReg.
	jump10 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 9 R: Extra2Reg.
	jump7 := self JumpNonZero: 0.
	jump11 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	s62 := 0.
	self MoveCq: s62 R: ClassReg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	jump10 jmpTarget: currentBlock.
	jump11 jmpTarget: currentBlock.
	self CmpCq: 9 R: Extra2Reg.
	jump11 := self JumpBelow: 0.
	self MoveR: ClassReg R: SendNumArgsReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump11 jmpTarget: currentBlock.
	self CmpCq: 2 R: Extra2Reg.
	jump11 := self JumpNonZero: 0.
	self MoveR: ClassReg R: SendNumArgsReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s77 := 0.
	self MoveCq: s77 R: Extra0Reg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump11 jmpTarget: currentBlock.
	self CmpCq: 2 R: Extra2Reg.
	jump11 := self JumpAboveOrEqual: 0.
	self MoveR: ClassReg R: Extra0Reg.
	self MoveR: ClassReg R: SendNumArgsReg.
	jump10 := self Jump: 0.
	currentBlock := self Label.
	jump11 jmpTarget: currentBlock.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: SendNumArgsReg.
	self AndCq: 16r3FFFFF R: SendNumArgsReg.
	self CmpCq: 31 R: SendNumArgsReg.
	jump11 := self JumpAbove: 0.
	self CmpCq: 31 R: SendNumArgsReg.
	jump9 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: SendNumArgsReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self CmpCq: 8 R: SendNumArgsReg.
	jump9 := self JumpNonZero: 0.
	self genMoveConstant: objectMemory nilObject R: SendNumArgsReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump11 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 10 R: Extra0Reg.
	s97 := objectMemory hiddenRootsObject.
	self LogicalShiftLeftCq: 3 R: Extra0Reg.
	self AddCq: s97 R: Extra0Reg.
	self MoveM64: 8 r: Extra0Reg R: Extra0Reg.
	self genMoveConstant: objectMemory nilObject R: Extra1Reg.
	self CmpR: Extra1Reg R: Extra0Reg.
	jump9 := self JumpNonZero: 0.
	self genMoveConstant: objectMemory nilObject R: Extra1Reg.
	jump11 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self AndCq: 1023 R: SendNumArgsReg.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddR: SendNumArgsReg R: Extra0Reg.
	self MoveM64: 8 r: Extra0Reg R: Extra1Reg.
	currentBlock := self Label.
	jump11 jmpTarget: currentBlock.
	self MoveR: Extra1Reg R: SendNumArgsReg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	self MoveM64: 24 r: SendNumArgsReg R: Extra1Reg.
	self ArithmeticShiftRightCq: 3 R: Extra1Reg.
	self AndCq: 16rFFFF R: Extra1Reg.
	self MoveR: Extra1Reg R: Extra0Reg.
	self MoveR: ClassReg R: SendNumArgsReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	jump10 jmpTarget: currentBlock.
	self SubR: Extra0Reg R: SendNumArgsReg.
	self CmpCq: 24 R: Extra2Reg.
	jump10 := self JumpAboveOrEqual: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self CmpCq: 1 R: Extra3Reg.
	jump8 := self JumpBelow: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self CmpR: SendNumArgsReg R: Extra3Reg.
	jump7 := self JumpAbove: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self AddR: Extra0Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self CmpCq: 5 R: Extra2Reg.
	jump6 := self JumpAbove: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self SubCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra1Reg.
	self AndCq: 7 R: Extra1Reg.
	self CmpCq: 0 R: Extra1Reg.
	jump11 := self JumpNonZero: 0.
	s134 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra1Reg.
	self AndCq: s134 R: Extra1Reg.
	s137 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s137 R: Extra1Reg.
	jump9 := self JumpNonZero: 0.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra1Reg.
	self AndCq: 7 R: Extra1Reg.
	self CmpCq: 0 R: Extra1Reg.
	jump12 := self JumpNonZero: 0.
	s142 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra1Reg.
	self AndCq: s142 R: Extra1Reg.
	s145 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s145 R: Extra1Reg.
	jump13 := self JumpNonZero: 0.
	s147 := objectMemory getMemoryMap getNewSpaceStart.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra1Reg.
	self CmpCq: s147 R: Extra1Reg.
	jumpTrue := self JumpAboveOrEqual: 0.
	self MoveCq: 0 R: Extra1Reg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: Extra1Reg.
	jumpNext jmpTarget: self Label.
	self CmpCq: 1 R: Extra1Reg.
	jump14 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: Extra1Reg.
	self LogicalShiftRightCq: 29 R: Extra1Reg.
	self AndCq: 1 R: Extra1Reg.
	self CmpCq: 0 R: Extra1Reg.
	jump15 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	jump16 := self Jump: 0.
	currentBlock := self Label.
	jump13 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump11 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	jump12 jmpTarget: currentBlock.
	jump14 jmpTarget: currentBlock.
	jump15 jmpTarget: currentBlock.
	jump16 jmpTarget: currentBlock.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: Extra1Reg.
	self LogicalShiftRightCq: 29 R: Extra1Reg.
	self AndCq: 1 R: Extra1Reg.
	self CmpCq: 0 R: Extra1Reg.
	jump16 := self JumpNonZero: 0.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self TstCq: 7 R: Extra3Reg.
	jump15 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self CmpCq: 16r20000000000 R: Extra3Reg.
	jump14 := self JumpBelow: 0.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self CmpCq: 16r20000000000 R: Extra3Reg.
	jump12 := self JumpAboveOrEqual: 0.
	self genMoveConstant: objectMemory nilObject R: Extra1Reg.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self CmpR: Extra1Reg R: Extra3Reg.
	jump9 := self JumpBelow: 0.
	s169 := objectMemory trueObject.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self CmpCq: s169 R: Extra3Reg.
	jump11 := self JumpBelowOrEqual: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	s171 := objectMemory getMemoryMap getNewSpaceStart.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self CmpCq: s171 R: Extra3Reg.
	jump9 := self JumpBelow: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump16 jmpTarget: currentBlock.
	jump15 jmpTarget: currentBlock.
	jump14 jmpTarget: currentBlock.
	jump12 jmpTarget: currentBlock.
	jump11 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self LogicalShiftLeftCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveMw: 8 r: SPReg R: Extra4Reg.
	self AddR: Extra4Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self MoveMw: 0 r: SPReg R: Extra4Reg.
	self MoveR: Extra3Reg M64: 8 r: Extra4Reg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ReceiverResultReg.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self CmpCq: 16 R: Extra2Reg.
	jump6 := self JumpBelow: 0.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self TstCq: 1 R: Extra3Reg.
	jump11 := self JumpZero: 0.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self ArithmeticShiftRightCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 24 r: SPReg.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self CmpCq: 0 R: Extra3Reg.
	jump12 := self JumpBelow: 0.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self CmpCq: 255 R: Extra3Reg.
	jump14 := self JumpAbove: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveMw: 0 r: SPReg R: Extra4Reg.
	self AddR: Extra4Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self AddCq:  -1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self MoveMw: 8 r: SPReg R: Extra4Reg.
	self MoveR: Extra3Reg Mb: 8 r: Extra4Reg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ReceiverResultReg.
	jump15 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self CmpCq: 12 R: Extra2Reg.
	jump6 := self JumpBelow: 0.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self TstCq: 1 R: Extra3Reg.
	jump16 := self JumpZero: 0.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self ArithmeticShiftRightCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 24 r: SPReg.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self CmpCq: 0 R: Extra3Reg.
	jump13 := self JumpBelow: 0.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self CmpCq: 16rFFFF R: Extra3Reg.
	jump17 := self JumpAbove: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self SubCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self LogicalShiftLeftCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveMw: 8 r: SPReg R: Extra4Reg.
	self AddR: Extra4Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra1Reg.
	self AddCq: 8 R: Extra1Reg.
	self MoveR: Extra1Reg R: ClassReg.
	self AndCq: 2 R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jump18 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM32: 8 r: Extra3Reg R: ClassReg.
	self AndCq: 16rFFFFFFFF R: ClassReg.
	self AndCq: 16rFFFF0000 R: ClassReg.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self OrR: Extra3Reg R: ClassReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: ClassReg M32: 8 r: Extra3Reg.
	jump19 := self Jump: 0.
	currentBlock := self Label.
	jump18 jmpTarget: currentBlock.
	self MoveM32: -2 r: Extra1Reg R: ClassReg.
	self AndCq: 16rFFFFFFFF R: ClassReg.
	self AndCq: 16rFFFF R: ClassReg.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self LogicalShiftLeftCq: 16 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 24 r: SPReg.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self OrR: Extra3Reg R: ClassReg.
	self MoveR: ClassReg M32: -2 r: Extra1Reg.
	currentBlock := self Label.
	jump19 jmpTarget: currentBlock.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ReceiverResultReg.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	jump15 jmpTarget: currentBlock.
	self AddCq: 32 R: SPReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump10 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump11 jmpTarget: currentBlock.
	jump12 jmpTarget: currentBlock.
	jump14 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump16 jmpTarget: currentBlock.
	jump13 jmpTarget: currentBlock.
	jump17 jmpTarget: currentBlock.
	self AddCq: 32 R: SPReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveStringReplace [
	"AutoGenerated by Druid"

	| jump6 s349 jump10 b1281 s321 s195 s144 jump7 s360 jump8 s299 jump11 jump12 s361 s287 s84 jump9 jump13 b1309 b1002 b876 jump14 s325 s376 s428 s223 s339 jumpTrue s440 b1148 b1176 s177 s316 s342 s355 jump1 s241 s344 s319 jump2 s293 s168 jump3 s281 jump4 s434 currentBlock jump5 s422 jumpNext |
	self SubCq: 152 R: SPReg.
	self MoveR: ReceiverResultReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 0 r: SPReg.
	self MoveR: Arg3Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 32 r: SPReg.
	self MoveR: Extra3Reg Mw: 24 r: SPReg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveR: Arg2Reg R: Extra3Reg.
	self MoveR: Arg1Reg R: Extra3Reg.
	self MoveR: Arg0Reg R: Extra3Reg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ClassReg.
	self AndCq: 1 R: ClassReg.
	self MoveR: ClassReg R: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: ClassReg.
	jump1 := self JumpNonZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: SendNumArgsReg.
	self AndCq: 1 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: ClassReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: ClassReg.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: SendNumArgsReg.
	jump1 := self JumpNonZero: 0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveMw: 32 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ClassReg.
	self AndCq: 1 R: ClassReg.
	self MoveR: ClassReg R: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jumpTrue := self JumpZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	self CmpCq: 0 R: ClassReg.
	jump1 := self JumpNonZero: 0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: SendNumArgsReg.
	self CmpCq: 7 R: SendNumArgsReg.
	jumpTrue := self JumpNonZero: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: ClassReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveR: ClassReg R: SendNumArgsReg.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	self CmpCq: 1 R: SendNumArgsReg.
	jump2 := self JumpZero: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self ArithmeticShiftRightCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 8 r: SPReg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self ArithmeticShiftRightCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 16 r: SPReg.
	self MoveMw: 32 r: SPReg R: Extra3Reg.
	self ArithmeticShiftRightCq: 3 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 32 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: SendNumArgsReg.
	self LogicalShiftRightCq: 24 R: SendNumArgsReg.
	self AndCq: 31 R: SendNumArgsReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveMb: 7 r: Extra3Reg R: ClassReg.
	self AndCq: 255 R: ClassReg.
	self CmpCq: 255 R: ClassReg.
	jump3 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: -8 r: Extra3Reg R: ClassReg.
	self LogicalShiftLeftCq: 8 R: ClassReg.
	self LogicalShiftRightCq: 8 R: ClassReg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 5 R: SendNumArgsReg.
	jump4 := self JumpAbove: 0.
	self MoveR: ClassReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 40 r: SPReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 16 R: SendNumArgsReg.
	jump4 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 3 R: ClassReg.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 7 R: Extra0Reg.
	self SubR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 40 r: SPReg.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 12 R: SendNumArgsReg.
	jump4 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 2 R: ClassReg.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 3 R: Extra0Reg.
	self SubR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 40 r: SPReg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 10 R: SendNumArgsReg.
	jump4 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 1 R: ClassReg.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self AndCq: 1 R: Extra0Reg.
	self SubR: Extra0Reg R: ClassReg.
	self MoveR: ClassReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 40 r: SPReg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 9 R: SendNumArgsReg.
	jump4 := self JumpNonZero: 0.
	self MoveR: ClassReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 40 r: SPReg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	s84 := 0.
	self MoveCq: s84 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 40 r: SPReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 16 R: SendNumArgsReg.
	jump7 := self JumpBelow: 0.
	self AndCq:  -8 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 9 R: SendNumArgsReg.
	jump7 := self JumpAbove: 0.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 12 R: SendNumArgsReg.
	jump7 := self JumpAboveOrEqual: 0.
	self AndCq:  -2 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self AndCq:  -4 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: SendNumArgsReg.
	self LogicalShiftRightCq: 24 R: SendNumArgsReg.
	self AndCq: 31 R: SendNumArgsReg.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self MoveMb: 7 r: Extra3Reg R: Extra1Reg.
	self AndCq: 255 R: Extra1Reg.
	self CmpCq: 255 R: Extra1Reg.
	jump1 := self JumpNonZero: 0.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self MoveM64: -8 r: Extra3Reg R: Extra1Reg.
	self LogicalShiftLeftCq: 8 R: Extra1Reg.
	self LogicalShiftRightCq: 8 R: Extra1Reg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 5 R: SendNumArgsReg.
	jump5 := self JumpAbove: 0.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 16 R: SendNumArgsReg.
	jump5 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 3 R: Extra1Reg.
	self MoveR: SendNumArgsReg R: Extra2Reg.
	self AndCq: 7 R: Extra2Reg.
	self SubR: Extra2Reg R: Extra1Reg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 12 R: SendNumArgsReg.
	jump5 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 2 R: Extra1Reg.
	self MoveR: SendNumArgsReg R: Extra2Reg.
	self AndCq: 3 R: Extra2Reg.
	self SubR: Extra2Reg R: Extra1Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 10 R: SendNumArgsReg.
	jump5 := self JumpBelow: 0.
	self LogicalShiftLeftCq: 1 R: Extra1Reg.
	self MoveR: SendNumArgsReg R: Extra2Reg.
	self AndCq: 1 R: Extra2Reg.
	self SubR: Extra2Reg R: Extra1Reg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 9 R: SendNumArgsReg.
	jump5 := self JumpNonZero: 0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	s144 := 0.
	self MoveCq: s144 R: Extra1Reg.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 16 R: SendNumArgsReg.
	jump4 := self JumpBelow: 0.
	self AndCq:  -8 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: Extra2Reg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 9 R: SendNumArgsReg.
	jump4 := self JumpAbove: 0.
	self MoveR: SendNumArgsReg R: Extra2Reg.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self CmpCq: 12 R: SendNumArgsReg.
	jump4 := self JumpAboveOrEqual: 0.
	self AndCq:  -2 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: Extra2Reg.
	jump6 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self AndCq:  -4 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: Extra2Reg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	self CmpR: Extra2Reg R: Extra0Reg.
	jump6 := self JumpNonZero: 0.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self CmpCq: 24 R: SendNumArgsReg.
	jumpTrue := self JumpBelow: 0.
	self MoveCq: 0 R: SendNumArgsReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: SendNumArgsReg.
	jumpNext jmpTarget: self Label.
	jump7 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	s168 := 0.
	self MoveCq: s168 R: SendNumArgsReg.
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	self CmpCq: 1 R: SendNumArgsReg.
	jump7 := self JumpNonZero: 0.
	self CmpCq: 5 R: Extra0Reg.
	jump6 := self JumpAbove: 0.
	self CmpCq: 9 R: Extra0Reg.
	jump3 := self JumpBelow: 0.
	self CmpCq: 9 R: Extra0Reg.
	jump4 := self JumpAboveOrEqual: 0.
	jump1 := self JumpBelow: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self CmpCq: 2 R: Extra0Reg.
	jump3 := self JumpNonZero: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	s177 := 0.
	self MoveCq: s177 R: SendNumArgsReg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self CmpCq: 2 R: Extra0Reg.
	jump3 := self JumpAboveOrEqual: 0.
	self MoveMw: 40 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: SendNumArgsReg.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: SendNumArgsReg.
	self AndCq: 16r3FFFFF R: SendNumArgsReg.
	self CmpCq: 31 R: SendNumArgsReg.
	jump3 := self JumpAbove: 0.
	self CmpCq: 31 R: SendNumArgsReg.
	jump5 := self JumpNonZero: 0.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: SendNumArgsReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self CmpCq: 8 R: SendNumArgsReg.
	jump5 := self JumpNonZero: 0.
	self genMoveConstant: objectMemory nilObject R: SendNumArgsReg.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftRightCq: 10 R: Extra0Reg.
	s195 := objectMemory hiddenRootsObject.
	self LogicalShiftLeftCq: 3 R: Extra0Reg.
	self AddCq: s195 R: Extra0Reg.
	self MoveM64: 8 r: Extra0Reg R: Extra0Reg.
	self genMoveConstant: objectMemory nilObject R: ClassReg.
	self CmpR: ClassReg R: Extra0Reg.
	jump5 := self JumpNonZero: 0.
	self genMoveConstant: objectMemory nilObject R: ClassReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self AndCq: 1023 R: SendNumArgsReg.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self AddR: SendNumArgsReg R: Extra0Reg.
	self MoveM64: 8 r: Extra0Reg R: ClassReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self MoveR: ClassReg R: SendNumArgsReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	self MoveM64: 24 r: SendNumArgsReg R: ClassReg.
	self ArithmeticShiftRightCq: 3 R: ClassReg.
	self AndCq: 16rFFFF R: ClassReg.
	self MoveR: ClassReg R: SendNumArgsReg.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	self CmpCq: 9 R: Extra2Reg.
	jump1 := self JumpBelow: 0.
	self CmpCq: 9 R: Extra2Reg.
	jump4 := self JumpAboveOrEqual: 0.
	jump9 := self JumpBelow: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self CmpCq: 2 R: Extra2Reg.
	jump1 := self JumpNonZero: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	s223 := 0.
	self MoveCq: s223 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 48 r: SPReg.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	self CmpCq: 2 R: Extra2Reg.
	jump1 := self JumpAboveOrEqual: 0.
	self MoveR: Extra1Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 48 r: SPReg.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self MoveM64: 0 r: Extra3Reg R: ClassReg.
	self AndCq: 16r3FFFFF R: ClassReg.
	self CmpCq: 31 R: ClassReg.
	jump1 := self JumpAbove: 0.
	self CmpCq: 31 R: ClassReg.
	jump8 := self JumpNonZero: 0.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ClassReg.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self CmpCq: 8 R: ClassReg.
	jump8 := self JumpNonZero: 0.
	self genMoveConstant: objectMemory nilObject R: ClassReg.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self MoveR: ClassReg R: Extra2Reg.
	self LogicalShiftRightCq: 10 R: Extra2Reg.
	s241 := objectMemory hiddenRootsObject.
	self LogicalShiftLeftCq: 3 R: Extra2Reg.
	self AddCq: s241 R: Extra2Reg.
	self MoveM64: 8 r: Extra2Reg R: Extra2Reg.
	self genMoveConstant: objectMemory nilObject R: Extra0Reg.
	self CmpR: Extra0Reg R: Extra2Reg.
	jump8 := self JumpNonZero: 0.
	self genMoveConstant: objectMemory nilObject R: Extra0Reg.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self AndCq: 1023 R: ClassReg.
	self LogicalShiftLeftCq: 3 R: ClassReg.
	self AddR: ClassReg R: Extra2Reg.
	self MoveM64: 8 r: Extra2Reg R: Extra0Reg.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 24 r: ClassReg R: Extra0Reg.
	self ArithmeticShiftRightCq: 3 R: Extra0Reg.
	self AndCq: 16rFFFF R: Extra0Reg.
	self MoveR: Extra0Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 48 r: SPReg.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump9 jmpTarget: currentBlock.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self CmpCq: 1 R: Extra3Reg.
	jump9 := self JumpBelow: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self SubCq: 1 R: Extra0Reg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self CmpR: Extra3Reg R: Extra0Reg.
	jump4 := self JumpAbove: 0.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self AddR: SendNumArgsReg R: Extra0Reg.
	self MoveMw: 40 r: SPReg R: Extra3Reg.
	self CmpR: Extra3Reg R: Extra0Reg.
	jump5 := self JumpAbove: 0.
	self MoveMw: 32 r: SPReg R: Extra3Reg.
	self CmpCq: 1 R: Extra3Reg.
	jump3 := self JumpBelow: 0.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self SubR: Extra3Reg R: Extra0Reg.
	self MoveMw: 32 r: SPReg R: Extra3Reg.
	self AddR: Extra3Reg R: Extra0Reg.
	self MoveMw: 48 r: SPReg R: Extra3Reg.
	self AddR: Extra3Reg R: Extra0Reg.
	self CmpR: Extra1Reg R: Extra0Reg.
	jumpTrue := self JumpBelowOrEqual: 0.
	self MoveCq: 0 R: Extra0Reg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: Extra0Reg.
	jumpNext jmpTarget: self Label.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s281 := 0.
	self MoveCq: s281 R: Extra0Reg.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	s287 := 0.
	self MoveCq: s287 R: Extra0Reg.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	s293 := 0.
	self MoveCq: s293 R: Extra0Reg.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 56 r: SPReg.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	s299 := 0.
	self MoveCq: s299 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 56 r: SPReg.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 72 r: SPReg.
	self MoveR: Extra3Reg Mw: 64 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: SendNumArgsReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 80 r: SPReg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ClassReg.
	self MoveMw: 48 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 88 r: SPReg.
	self MoveMw: 32 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 96 r: SPReg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: SendNumArgsReg.
	self MoveMw: 56 r: SPReg R: Extra3Reg.
	self CmpCq: 1 R: Extra3Reg.
	jump1 := self JumpNonZero: 0.
	self MoveMw: 80 r: SPReg R: Extra3Reg.
	self AddR: Extra3Reg R: ClassReg.
	self MoveMw: 80 r: SPReg R: Extra3Reg.
	self AddR: Extra3Reg R: SendNumArgsReg.
	self MoveMw: 96 r: SPReg R: Extra3Reg.
	self AddR: Extra0Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 96 r: SPReg.
	self MoveMw: 96 r: SPReg R: Extra3Reg.
	self SubR: ClassReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 96 r: SPReg.
	s316 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveMw: 72 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self AndCq: s316 R: Extra0Reg.
	s319 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s319 R: Extra0Reg.
	jump9 := self JumpNonZero: 0.
	s321 := 0.
	self SubCq: 1 R: ClassReg.
	self SubCq: 1 R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra0Reg.
	s325 := s321.
	b876 := self Label.
	self CmpR: SendNumArgsReg R: Extra0Reg.
	jump4 := self JumpAbove: 0.
	self MoveMw: 96 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ClassReg.
	self AddR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 3 R: ClassReg.
	self MoveMw: 88 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra1Reg.
	self AddR: ClassReg R: Extra1Reg.
	self MoveM64: 8 r: Extra1Reg R: Extra1Reg.
	self MoveR: Extra1Reg R: ClassReg.
	self AndCq: 7 R: ClassReg.
	self CmpCq: 0 R: ClassReg.
	jump5 := self JumpNonZero: 0.
	s339 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: Extra1Reg R: ClassReg.
	self AndCq: s339 R: ClassReg.
	s342 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s342 R: ClassReg.
	jump3 := self JumpNonZero: 0.
	s344 := objectMemory getMemoryMap getNewSpaceStart.
	self MoveR: Extra1Reg R: ClassReg.
	self CmpCq: s344 R: ClassReg.
	jumpTrue := self JumpAboveOrEqual: 0.
	self MoveCq: 0 R: ClassReg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: ClassReg.
	jumpNext jmpTarget: self Label.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s349 := 0.
	self MoveCq: s349 R: ClassReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	s355 := 0.
	self MoveCq: s355 R: ClassReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self CmpCq: 1 R: ClassReg.
	jump8 := self JumpNonZero: 0.
	s360 := 1.
	s361 := s360.
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s361 := s325.
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 3 R: ClassReg.
	self MoveMw: 72 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra2Reg.
	self AddR: ClassReg R: Extra2Reg.
	self MoveR: Extra1Reg M64: 8 r: Extra2Reg.
	self MoveR: Extra0Reg R: Extra2Reg.
	self AddCq: 1 R: Extra2Reg.
	self MoveR: Extra2Reg R: Extra0Reg.
	s325 := s361.
	jump5 := self Jump: b876.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	s325 ifTrue: [
		| jump4 |
		self MoveMw: 72 r: SPReg R: Extra3Reg.
		self MoveM64: 0 r: Extra3Reg R: Extra2Reg.
		self LogicalShiftRightCq: 29 R: Extra2Reg.
		self AndCq: 1 R: Extra2Reg.
		self CmpCq: 0 R: Extra2Reg.
		jump4 := self JumpNonZero: 0.
		self ssFlushStack.
		self MoveMw: 72 r: SPReg R: Extra3Reg.
		self MoveR: Extra3Reg R: TempReg.
		backEnd saveAndRestoreLinkRegAround: [
			self CallRT: ceStoreCheckTrampoline ].
		currentBlock := self Label.
		jump4 jmpTarget: currentBlock.
		self MoveMw: 64 r: SPReg R: Extra3Reg.
		self MoveR: Extra3Reg R: Extra1Reg.
		self MoveR: Extra1Reg R: ReceiverResultReg.
		self AddCq: 152 R: SPReg.
		self genPrimReturn.
		self AddCq: 152 R: SPReg.
		^ 0 ].
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self SubCq: 1 R: ClassReg.
	self SubCq: 1 R: SendNumArgsReg.
	self MoveR: ClassReg R: Extra2Reg.
	b1002 := self Label.
	self CmpR: SendNumArgsReg R: Extra2Reg.
	jump9 := self JumpAbove: 0.
	self MoveMw: 96 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self AddR: Extra2Reg R: Extra0Reg.
	self LogicalShiftLeftCq: 3 R: Extra0Reg.
	self MoveMw: 88 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ClassReg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveM64: 8 r: ClassReg R: ClassReg.
	self MoveR: Extra2Reg R: Extra0Reg.
	self LogicalShiftLeftCq: 3 R: Extra0Reg.
	self MoveMw: 72 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra1Reg.
	self AddR: Extra0Reg R: Extra1Reg.
	self MoveR: ClassReg M64: 8 r: Extra1Reg.
	self MoveR: Extra2Reg R: Extra1Reg.
	self AddCq: 1 R: Extra1Reg.
	self MoveR: Extra1Reg R: Extra2Reg.
	jump4 := self Jump: b1002.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self MoveMw: 64 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra1Reg.
	self MoveR: Extra1Reg R: ReceiverResultReg.
	jump9 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self MoveMw: 64 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ReceiverResultReg.
	jump1 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self CmpCq: 1 R: Extra3Reg.
	jump6 := self JumpBelow: 0.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra2Reg.
	self SubCq: 1 R: Extra2Reg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self CmpR: Extra3Reg R: Extra2Reg.
	jump8 := self JumpAbove: 0.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveMw: 40 r: SPReg R: Extra4Reg.
	self CmpR: Extra4Reg R: Extra3Reg.
	jump3 := self JumpAbove: 0.
	self MoveMw: 32 r: SPReg R: Extra3Reg.
	self CmpCq: 1 R: Extra3Reg.
	jump10 := self JumpBelow: 0.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra2Reg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self SubR: Extra3Reg R: Extra2Reg.
	self MoveMw: 32 r: SPReg R: Extra3Reg.
	self AddR: Extra3Reg R: Extra2Reg.
	self CmpR: Extra1Reg R: Extra2Reg.
	jumpTrue := self JumpBelowOrEqual: 0.
	self MoveCq: 0 R: Extra2Reg.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: Extra2Reg.
	jumpNext jmpTarget: self Label.
	jump11 := self Jump: 0.
	currentBlock := self Label.
	jump10 jmpTarget: currentBlock.
	s422 := 0.
	self MoveCq: s422 R: Extra2Reg.
	currentBlock := self Label.
	jump11 jmpTarget: currentBlock.
	jump11 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s428 := 0.
	self MoveCq: s428 R: Extra2Reg.
	currentBlock := self Label.
	jump11 jmpTarget: currentBlock.
	jump11 := self Jump: 0.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	s434 := 0.
	self MoveCq: s434 R: Extra2Reg.
	currentBlock := self Label.
	jump11 jmpTarget: currentBlock.
	self MoveR: Extra2Reg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 104 r: SPReg.
	jump11 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	s440 := 0.
	self MoveCq: s440 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 104 r: SPReg.
	currentBlock := self Label.
	jump11 jmpTarget: currentBlock.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 120 r: SPReg.
	self MoveR: Extra3Reg Mw: 112 r: SPReg.
	self MoveMw: 0 r: SPReg R: Extra3Reg.
	self MoveMw: 8 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ClassReg.
	self MoveMw: 24 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 128 r: SPReg.
	self MoveMw: 32 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 136 r: SPReg.
	self MoveMw: 16 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 144 r: SPReg.
	self MoveMw: 104 r: SPReg R: Extra3Reg.
	self CmpCq: 1 R: Extra3Reg.
	jump11 := self JumpNonZero: 0.
	self MoveMw: 136 r: SPReg R: Extra3Reg.
	self SubR: ClassReg R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 136 r: SPReg.
	self CmpCq: 12 R: Extra0Reg.
	jump6 := self JumpBelow: 0.
	self CmpCq: 16 R: Extra0Reg.
	jump8 := self JumpBelow: 0.
	self SubCq: 1 R: ClassReg.
	self MoveMw: 144 r: SPReg R: Extra3Reg.
	self SubCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 144 r: SPReg.
	b1148 := self Label.
	self MoveMw: 144 r: SPReg R: Extra3Reg.
	self CmpR: Extra3Reg R: ClassReg.
	jump3 := self JumpAbove: 0.
	self MoveMw: 136 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self AddR: ClassReg R: Extra0Reg.
	self MoveMw: 128 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra2Reg.
	self AddR: Extra0Reg R: Extra2Reg.
	self MoveMb: 8 r: Extra2Reg R: Extra2Reg.
	self AndCq: 255 R: Extra2Reg.
	self MoveMw: 120 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self AddR: ClassReg R: Extra0Reg.
	self MoveR: Extra2Reg Mb: 8 r: Extra0Reg.
	self MoveR: ClassReg R: Extra0Reg.
	self AddCq: 1 R: Extra0Reg.
	self MoveR: Extra0Reg R: ClassReg.
	jump10 := self Jump: b1148.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self SubCq: 1 R: ClassReg.
	self MoveMw: 144 r: SPReg R: Extra3Reg.
	self SubCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 144 r: SPReg.
	self MoveR: ClassReg R: Extra0Reg.
	b1176 := self Label.
	self MoveMw: 144 r: SPReg R: Extra3Reg.
	self CmpR: Extra3Reg R: Extra0Reg.
	jump8 := self JumpAbove: 0.
	self MoveMw: 136 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ClassReg.
	self AddR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 1 R: ClassReg.
	self MoveMw: 128 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra2Reg.
	self AddR: ClassReg R: Extra2Reg.
	self AddCq: 8 R: Extra2Reg.
	self MoveR: Extra2Reg R: ClassReg.
	self AndCq: 2 R: ClassReg.
	self SubR: ClassReg R: Extra2Reg.
	self MoveM64: 0 r: Extra2Reg R: Extra2Reg.
	self AndCq: 16rFFFFFFFF R: Extra2Reg.
	self CmpCq: 2 R: ClassReg.
	jump12 := self JumpNonZero: 0.
	self LogicalShiftRightCq: 16 R: Extra2Reg.
	jump13 := self Jump: 0.
	currentBlock := self Label.
	jump12 jmpTarget: currentBlock.
	self AndCq: 16rFFFF R: Extra2Reg.
	currentBlock := self Label.
	jump13 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: ClassReg.
	self LogicalShiftLeftCq: 1 R: ClassReg.
	self MoveMw: 120 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra1Reg.
	self AddR: ClassReg R: Extra1Reg.
	self MoveR: Extra1Reg R: ClassReg.
	self AddCq: 8 R: ClassReg.
	self MoveR: ClassReg R: SendNumArgsReg.
	self AndCq: 2 R: SendNumArgsReg.
	self CmpCq: 0 R: SendNumArgsReg.
	jump13 := self JumpNonZero: 0.
	self MoveM32: 8 r: Extra1Reg R: SendNumArgsReg.
	self AndCq: 16rFFFFFFFF R: SendNumArgsReg.
	self AndCq: 16rFFFF0000 R: SendNumArgsReg.
	self OrR: Extra2Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg M32: 8 r: Extra1Reg.
	jump12 := self Jump: 0.
	currentBlock := self Label.
	jump13 jmpTarget: currentBlock.
	self MoveM32: -2 r: ClassReg R: SendNumArgsReg.
	self AndCq: 16rFFFFFFFF R: SendNumArgsReg.
	self AndCq: 16rFFFF R: SendNumArgsReg.
	self LogicalShiftLeftCq: 16 R: Extra2Reg.
	self OrR: Extra2Reg R: SendNumArgsReg.
	self MoveR: SendNumArgsReg M32: -2 r: ClassReg.
	currentBlock := self Label.
	jump12 jmpTarget: currentBlock.
	self MoveR: Extra0Reg R: SendNumArgsReg.
	self AddCq: 1 R: SendNumArgsReg.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	jump12 := self Jump: b1176.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	self MoveMw: 112 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: SendNumArgsReg.
	jump8 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self CmpCq: 10 R: Extra0Reg.
	jump6 := self JumpBelow: 0.
	self SubCq: 1 R: ClassReg.
	self MoveMw: 144 r: SPReg R: Extra3Reg.
	self SubCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 144 r: SPReg.
	self MoveR: ClassReg R: SendNumArgsReg.
	b1281 := self Label.
	self MoveMw: 144 r: SPReg R: Extra3Reg.
	self CmpR: Extra3Reg R: SendNumArgsReg.
	jump3 := self JumpAbove: 0.
	self MoveMw: 136 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self AddR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 2 R: Extra0Reg.
	self MoveMw: 128 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ClassReg.
	self AddR: Extra0Reg R: ClassReg.
	self MoveM32: 8 r: ClassReg R: ClassReg.
	self AndCq: 16rFFFFFFFF R: ClassReg.
	self MoveR: SendNumArgsReg R: Extra0Reg.
	self LogicalShiftLeftCq: 2 R: Extra0Reg.
	self MoveMw: 120 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra2Reg.
	self AddR: Extra0Reg R: Extra2Reg.
	self MoveR: ClassReg M32: 8 r: Extra2Reg.
	self MoveR: SendNumArgsReg R: Extra2Reg.
	self AddCq: 1 R: Extra2Reg.
	self MoveR: Extra2Reg R: SendNumArgsReg.
	jump13 := self Jump: b1281.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	self SubCq: 1 R: ClassReg.
	self MoveMw: 144 r: SPReg R: Extra3Reg.
	self SubCq: 1 R: Extra3Reg.
	self MoveR: Extra3Reg Mw: 144 r: SPReg.
	self MoveR: ClassReg R: Extra2Reg.
	b1309 := self Label.
	self MoveMw: 144 r: SPReg R: Extra3Reg.
	self CmpR: Extra3Reg R: Extra2Reg.
	jump6 := self JumpAbove: 0.
	self MoveMw: 136 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: SendNumArgsReg.
	self AddR: Extra2Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self MoveMw: 128 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: Extra0Reg.
	self AddR: SendNumArgsReg R: Extra0Reg.
	self MoveM64: 8 r: Extra0Reg R: Extra0Reg.
	self MoveR: Extra2Reg R: SendNumArgsReg.
	self LogicalShiftLeftCq: 3 R: SendNumArgsReg.
	self MoveMw: 120 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ClassReg.
	self AddR: SendNumArgsReg R: ClassReg.
	self MoveR: Extra0Reg M64: 8 r: ClassReg.
	self MoveR: Extra2Reg R: ClassReg.
	self AddCq: 1 R: ClassReg.
	self MoveR: ClassReg R: Extra2Reg.
	jump14 := self Jump: b1309.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	self MoveMw: 112 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: SendNumArgsReg.
	currentBlock := self Label.
	jump8 jmpTarget: currentBlock.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	currentBlock := self Label.
	jump9 jmpTarget: currentBlock.
	self AddCq: 152 R: SPReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump11 jmpTarget: currentBlock.
	self MoveMw: 112 r: SPReg R: Extra3Reg.
	self MoveR: Extra3Reg R: ReceiverResultReg.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	self AddCq: 152 R: SPReg.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PrimitiveSubtract [
	"AutoGenerated by Druid"

	| jump1 jump2 jump3 currentBlock |
	self MoveR: ReceiverResultReg R: ClassReg.
	self MoveR: Arg0Reg R: SendNumArgsReg.
	self TstCq: 1 R: ClassReg.
	jump1 := self JumpZero: 0.
	self TstCq: 1 R: SendNumArgsReg.
	jump2 := self JumpZero: 0.
	self AddCq:  -1 R: SendNumArgsReg.
	self SubR: SendNumArgsReg R: ClassReg.
	jump3 := self JumpOverflow: 0.
	self MoveR: ClassReg R: ReceiverResultReg.
	self genPrimReturn.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushConstantFalseBytecode [
	"AutoGenerated by Druid"

	| live currentBlock s2 |
	live := 0.
	s2 := objectMemory falseObject.
	self ssPushConstant: s2.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushConstantNilBytecode [
	"AutoGenerated by Druid"

	| live currentBlock t0 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: objectMemory nilObject R: t0.
	self ssPushRegister: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushConstantOneBytecode [
	"AutoGenerated by Druid"

	| live currentBlock s2 |
	live := 0.
	s2 := ConstOne.
	self ssPushConstant: s2.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushConstantTrueBytecode [
	"AutoGenerated by Druid"

	| live currentBlock s2 |
	live := 0.
	s2 := objectMemory trueObject.
	self ssPushConstant: s2.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushConstantZeroBytecode [
	"AutoGenerated by Druid"

	| live currentBlock s2 |
	live := 0.
	s2 := ConstZero.
	self ssPushConstant: s2.
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

	| t0 s4 currentBlock live s3 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 << 3.
	self AddCq: s4 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode1 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 1.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode10 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 10.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode11 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 11.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode12 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 12.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode13 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 13.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode14 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 14.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode15 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 15.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode16 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 16.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode17 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 17.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode18 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 18.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode19 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 19.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode2 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 2.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode20 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 20.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode21 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 21.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode22 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 22.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode23 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 23.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode24 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 24.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode25 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 25.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode26 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 26.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode27 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 27.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode28 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 28.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode29 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 29.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode3 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 3.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode30 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 30.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode31 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 31.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode4 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 4.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode5 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 5.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode6 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 6.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode7 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 7.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode8 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 8.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralConstantBytecode9 [
	"AutoGenerated by Druid"

	| s3 t0 s4 currentBlock live s5 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 9.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode0 [
	"AutoGenerated by Druid"

	| jump1 s3 s28 t1 jump3 b237 currentBlock t0 jump2 s4 s29 live jump4 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 << 3.
	self AddCq: s4 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s28 := ValueIndex.
	s29 := s28 << 3.
	self AddCq: s29 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode1 [
	"AutoGenerated by Druid"

	| jump1 s3 t1 jump3 s5 s30 b237 currentBlock t0 jump2 s4 s29 live jump4 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 1.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s29 := ValueIndex.
	s30 := s29 << 3.
	self AddCq: s30 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode10 [
	"AutoGenerated by Druid"

	| jump1 s3 t1 jump3 s5 s30 b237 currentBlock t0 jump2 s4 s29 live jump4 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 10.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s29 := ValueIndex.
	s30 := s29 << 3.
	self AddCq: s30 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode11 [
	"AutoGenerated by Druid"

	| jump1 s3 t1 jump3 s5 s30 b237 currentBlock t0 jump2 s4 s29 live jump4 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 11.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s29 := ValueIndex.
	s30 := s29 << 3.
	self AddCq: s30 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode12 [
	"AutoGenerated by Druid"

	| jump1 s3 t1 jump3 s5 s30 b237 currentBlock t0 jump2 s4 s29 live jump4 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 12.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s29 := ValueIndex.
	s30 := s29 << 3.
	self AddCq: s30 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode13 [
	"AutoGenerated by Druid"

	| jump1 s3 t1 jump3 s5 s30 b237 currentBlock t0 jump2 s4 s29 live jump4 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 13.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s29 := ValueIndex.
	s30 := s29 << 3.
	self AddCq: s30 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode14 [
	"AutoGenerated by Druid"

	| jump1 s3 t1 jump3 s5 s30 b237 currentBlock t0 jump2 s4 s29 live jump4 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 14.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s29 := ValueIndex.
	s30 := s29 << 3.
	self AddCq: s30 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode15 [
	"AutoGenerated by Druid"

	| jump1 s3 t1 jump3 s5 s30 b237 currentBlock t0 jump2 s4 s29 live jump4 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 15.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s29 := ValueIndex.
	s30 := s29 << 3.
	self AddCq: s30 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode2 [
	"AutoGenerated by Druid"

	| jump1 s3 t1 jump3 s5 s30 b237 currentBlock t0 jump2 s4 s29 live jump4 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 2.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s29 := ValueIndex.
	s30 := s29 << 3.
	self AddCq: s30 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode3 [
	"AutoGenerated by Druid"

	| jump1 s3 t1 jump3 s5 s30 b237 currentBlock t0 jump2 s4 s29 live jump4 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 3.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s29 := ValueIndex.
	s30 := s29 << 3.
	self AddCq: s30 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode4 [
	"AutoGenerated by Druid"

	| jump1 s3 t1 jump3 s5 s30 b237 currentBlock t0 jump2 s4 s29 live jump4 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 4.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s29 := ValueIndex.
	s30 := s29 << 3.
	self AddCq: s30 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode5 [
	"AutoGenerated by Druid"

	| jump1 s3 t1 jump3 s5 s30 b237 currentBlock t0 jump2 s4 s29 live jump4 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 5.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s29 := ValueIndex.
	s30 := s29 << 3.
	self AddCq: s30 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode6 [
	"AutoGenerated by Druid"

	| jump1 s3 t1 jump3 s5 s30 b237 currentBlock t0 jump2 s4 s29 live jump4 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 6.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s29 := ValueIndex.
	s30 := s29 << 3.
	self AddCq: s30 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode7 [
	"AutoGenerated by Druid"

	| jump1 s3 t1 jump3 s5 s30 b237 currentBlock t0 jump2 s4 s29 live jump4 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 7.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s29 := ValueIndex.
	s30 := s29 << 3.
	self AddCq: s30 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode8 [
	"AutoGenerated by Druid"

	| jump1 s3 t1 jump3 s5 s30 b237 currentBlock t0 jump2 s4 s29 live jump4 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 8.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s29 := ValueIndex.
	s30 := s29 << 3.
	self AddCq: s30 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushLiteralVariable16CasesBytecode9 [
	"AutoGenerated by Druid"

	| jump1 s3 t1 jump3 s5 s30 b237 currentBlock t0 jump2 s4 s29 live jump4 |
	live := 0.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self genMoveConstant: methodObj R: t0.
	s3 := LiteralStart.
	s4 := s3 + 9.
	s5 := s4 << 3.
	self AddCq: s5 R: t0.
	self MoveM64: 8 r: t0 R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	self MoveM64: 0 r: t0 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t1.
	b237 := self Label.
	self MoveR: t1 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t0.
	self MoveR: t0 R: t1.
	jump4 := self Jump: b237.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 R: t0.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s29 := ValueIndex.
	s30 := s29 << 3.
	self AddCq: s30 R: t0.
	self ssPushBase: t0 offset: 8.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_PushNewArrayBytecode [
	"AutoGenerated by Druid"

	| s6 s46 s4 s29 s38 s2 s20 currentBlock t1 s19 s42 s7 jump1 s34 s47 s17 s10 live s56 s45 s3 s28 s30 s21 t2 s52 s8 b117 s35 t0 s11 |
	live := 0.
	s2 := byte1.
	s3 := s2 bitAnd: 127.
	s4 := ClassArrayCompactIndex.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	self MoveAw: objectMemory freeStartAddress R: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	s3 < 1 ifTrue: [
		| jump1 b117 |
		s7 := 16.
		s8 := s7.
		self MoveAw: objectMemory freeStartAddress R: t1.
		self AddCq: s8 R: t1.
		s17 := objectMemory getScavengeThreshold.
		self CmpCq: s17 R: t1.
		jump1 := self JumpAbove: 0.
		s19 := s3 << 56.
		s20 := s19 + s4.
		s21 := s20 + 33554432.
		self MoveCq: s21 R: t1.
		self MoveR: t1 M64: 0 r: t0.
		self MoveAw: objectMemory freeStartAddress R: t1.
		self AddCq: s8 R: t1.
		self MoveR: t1 Aw: objectMemory freeStartAddress.
		s2 > 127 ifTrue: [
			| b89 |
			s28 := 0.
			s29 := s3 - 1.
			s30 := s28.
			b89 := self Label.
			[ ((s30<=s29)) ] whileTrue: [
				s34 := s3 - s30.
				s35 := s34 - 1.
				(self ssValue: 0) copyToReg: t1.
				self ssPop: 1.
				s38 := s35 << 3.
				self MoveR: t0 R: t2.
				self AddCq: s38 R: t2.
				self MoveR: t1 M64: 8 r: t2.
				s42 := s30 + 1.
				s30 := s42 ].
			self ssPushRegister: t0.
			currentBlock := self Label.
			jump1 jmpTarget: currentBlock.
			^ 0 ].
		s45 := 0.
		s46 := s3 - 1.
		s47 := s45.
		b117 := self Label.
		[ ((s47<=s46)) ] whileTrue: [
			self genMoveConstant: objectMemory nilObject R: t2.
			s52 := s47 << 3.
			self MoveR: t0 R: t1.
			self AddCq: s52 R: t1.
			self MoveR: t2 M64: 8 r: t1.
			s56 := s47 + 1.
			s47 := s56 ].
		self ssPushRegister: t0.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		^ 0 ].
	s10 := s3 << 3.
	s11 := s10 + 8.
	s8 := s11.
	self MoveAw: objectMemory freeStartAddress R: t1.
	self AddCq: s8 R: t1.
	s17 := objectMemory getScavengeThreshold.
	self CmpCq: s17 R: t1.
	jump1 := self JumpAbove: 0.
	s19 := s3 << 56.
	s20 := s19 + s4.
	s21 := s20 + 33554432.
	self MoveCq: s21 R: t1.
	self MoveR: t1 M64: 0 r: t0.
	self MoveAw: objectMemory freeStartAddress R: t1.
	self AddCq: s8 R: t1.
	self MoveR: t1 Aw: objectMemory freeStartAddress.
	s2 > 127 ifTrue: [
		| b89 |
		s28 := 0.
		s29 := s3 - 1.
		s30 := s28.
		b89 := self Label.
		[ ((s30<=s29)) ] whileTrue: [
			s34 := s3 - s30.
			s35 := s34 - 1.
			(self ssValue: 0) copyToReg: t1.
			self ssPop: 1.
			s38 := s35 << 3.
			self MoveR: t0 R: t2.
			self AddCq: s38 R: t2.
			self MoveR: t1 M64: 8 r: t2.
			s42 := s30 + 1.
			s30 := s42 ].
		self ssPushRegister: t0.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		^ 0 ].
	s45 := 0.
	s46 := s3 - 1.
	s47 := s45.
	b117 := self Label.
	[ ((s47<=s46)) ] whileTrue: [
		self genMoveConstant: objectMemory nilObject R: t2.
		s52 := s47 << 3.
		self MoveR: t0 R: t1.
		self AddCq: s52 R: t1.
		self MoveR: t2 M64: 8 r: t1.
		s56 := s47 + 1.
		s47 := s56 ].
	self ssPushRegister: t0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
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

	| t0 s32 s4 s2 currentBlock t1 live s5 |
	live := 0.
	s2 := byte1.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: byte2) copyToReg: t0.
	s4 := TempVectReadBarrier.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	s4 ifTrue: [
		| jump3 jump1 b203 jump4 jump2 |
		self MoveM64: 0 r: t0 R: t1.
		self AndCq: 16r3FFFF7 R: t1.
		self CmpCq: 0 R: t1.
		jump1 := self JumpNonZero: 0.
		self MoveM64: 8 r: t0 R: t1.
		b203 := self Label.
		self MoveR: t1 R: t0.
		self AndCq: 7 R: t0.
		self CmpCq: 0 R: t0.
		jump2 := self JumpNonZero: 0.
		self MoveM64: 0 r: t1 R: t0.
		self AndCq: 16r3FFFF7 R: t0.
		self CmpCq: 0 R: t0.
		jump3 := self JumpNonZero: 0.
		self MoveM64: 8 r: t1 R: t0.
		self MoveR: t0 R: t1.
		jump4 := self Jump: b203.
		currentBlock := self Label.
		jump2 jmpTarget: currentBlock.
		jump3 jmpTarget: currentBlock.
		self MoveR: t1 R: t0.
		jump3 := self Jump: 0.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		currentBlock := self Label.
		jump3 jmpTarget: currentBlock.
		s32 := s2 << 3.
		self AddCq: s32 R: t0.
		self ssPushBase: t0 offset: 8.
		^ 0 ].
	s32 := s2 << 3.
	self AddCq: s32 R: t0.
	self ssPushBase: t0 offset: 8.
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

	| live currentBlock s2 |
	live := 0.
	s2 := objectMemory falseObject.
	self MoveCq: s2 R: ReceiverResultReg.
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

	| live currentBlock s2 |
	live := 0.
	s2 := objectMemory trueObject.
	self MoveCq: s2 R: ReceiverResultReg.
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

	| jump1 s8 s5 s2 currentBlock s12 t0 jump2 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s5 := objectMemory falseObject.
	self ssFlushStack.
	self CmpCq: s5 R: t0.
	jump1 := self JumpNonZero: 0.
	s8 := bytecodePC.
	s9 := s8 + 2.
	self Jump: (self ensureFixupAt: s9).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s12 := objectMemory trueObject.
	self CmpCq: s12 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpFalse1 [
	"AutoGenerated by Druid"

	| jump1 s8 s5 s2 currentBlock s12 t0 jump2 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s5 := objectMemory falseObject.
	self ssFlushStack.
	self CmpCq: s5 R: t0.
	jump1 := self JumpNonZero: 0.
	s8 := bytecodePC.
	s9 := s8 + 3.
	self Jump: (self ensureFixupAt: s9).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s12 := objectMemory trueObject.
	self CmpCq: s12 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpFalse2 [
	"AutoGenerated by Druid"

	| jump1 s8 s5 s2 currentBlock s12 t0 jump2 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s5 := objectMemory falseObject.
	self ssFlushStack.
	self CmpCq: s5 R: t0.
	jump1 := self JumpNonZero: 0.
	s8 := bytecodePC.
	s9 := s8 + 4.
	self Jump: (self ensureFixupAt: s9).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s12 := objectMemory trueObject.
	self CmpCq: s12 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpFalse3 [
	"AutoGenerated by Druid"

	| jump1 s8 s5 s2 currentBlock s12 t0 jump2 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s5 := objectMemory falseObject.
	self ssFlushStack.
	self CmpCq: s5 R: t0.
	jump1 := self JumpNonZero: 0.
	s8 := bytecodePC.
	s9 := s8 + 5.
	self Jump: (self ensureFixupAt: s9).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s12 := objectMemory trueObject.
	self CmpCq: s12 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpFalse4 [
	"AutoGenerated by Druid"

	| jump1 s8 s5 s2 currentBlock s12 t0 jump2 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s5 := objectMemory falseObject.
	self ssFlushStack.
	self CmpCq: s5 R: t0.
	jump1 := self JumpNonZero: 0.
	s8 := bytecodePC.
	s9 := s8 + 6.
	self Jump: (self ensureFixupAt: s9).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s12 := objectMemory trueObject.
	self CmpCq: s12 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpFalse5 [
	"AutoGenerated by Druid"

	| jump1 s8 s5 s2 currentBlock s12 t0 jump2 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s5 := objectMemory falseObject.
	self ssFlushStack.
	self CmpCq: s5 R: t0.
	jump1 := self JumpNonZero: 0.
	s8 := bytecodePC.
	s9 := s8 + 7.
	self Jump: (self ensureFixupAt: s9).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s12 := objectMemory trueObject.
	self CmpCq: s12 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpFalse6 [
	"AutoGenerated by Druid"

	| jump1 s8 s5 s2 currentBlock s12 t0 jump2 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s5 := objectMemory falseObject.
	self ssFlushStack.
	self CmpCq: s5 R: t0.
	jump1 := self JumpNonZero: 0.
	s8 := bytecodePC.
	s9 := s8 + 8.
	self Jump: (self ensureFixupAt: s9).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s12 := objectMemory trueObject.
	self CmpCq: s12 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpFalse7 [
	"AutoGenerated by Druid"

	| jump1 s8 s5 s2 currentBlock s12 t0 jump2 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s5 := objectMemory falseObject.
	self ssFlushStack.
	self CmpCq: s5 R: t0.
	jump1 := self JumpNonZero: 0.
	s8 := bytecodePC.
	s9 := s8 + 9.
	self Jump: (self ensureFixupAt: s9).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s12 := objectMemory trueObject.
	self CmpCq: s12 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpTrue0 [
	"AutoGenerated by Druid"

	| jump1 s8 s5 s2 currentBlock s12 t0 jump2 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s5 := objectMemory trueObject.
	self ssFlushStack.
	self CmpCq: s5 R: t0.
	jump1 := self JumpNonZero: 0.
	s8 := bytecodePC.
	s9 := s8 + 2.
	self Jump: (self ensureFixupAt: s9).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s12 := objectMemory falseObject.
	self CmpCq: s12 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpTrue1 [
	"AutoGenerated by Druid"

	| jump1 s8 s5 s2 currentBlock s12 t0 jump2 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s5 := objectMemory trueObject.
	self ssFlushStack.
	self CmpCq: s5 R: t0.
	jump1 := self JumpNonZero: 0.
	s8 := bytecodePC.
	s9 := s8 + 3.
	self Jump: (self ensureFixupAt: s9).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s12 := objectMemory falseObject.
	self CmpCq: s12 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpTrue2 [
	"AutoGenerated by Druid"

	| jump1 s8 s5 s2 currentBlock s12 t0 jump2 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s5 := objectMemory trueObject.
	self ssFlushStack.
	self CmpCq: s5 R: t0.
	jump1 := self JumpNonZero: 0.
	s8 := bytecodePC.
	s9 := s8 + 4.
	self Jump: (self ensureFixupAt: s9).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s12 := objectMemory falseObject.
	self CmpCq: s12 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpTrue3 [
	"AutoGenerated by Druid"

	| jump1 s8 s5 s2 currentBlock s12 t0 jump2 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s5 := objectMemory trueObject.
	self ssFlushStack.
	self CmpCq: s5 R: t0.
	jump1 := self JumpNonZero: 0.
	s8 := bytecodePC.
	s9 := s8 + 5.
	self Jump: (self ensureFixupAt: s9).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s12 := objectMemory falseObject.
	self CmpCq: s12 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpTrue4 [
	"AutoGenerated by Druid"

	| jump1 s8 s5 s2 currentBlock s12 t0 jump2 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s5 := objectMemory trueObject.
	self ssFlushStack.
	self CmpCq: s5 R: t0.
	jump1 := self JumpNonZero: 0.
	s8 := bytecodePC.
	s9 := s8 + 6.
	self Jump: (self ensureFixupAt: s9).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s12 := objectMemory falseObject.
	self CmpCq: s12 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpTrue5 [
	"AutoGenerated by Druid"

	| jump1 s8 s5 s2 currentBlock s12 t0 jump2 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s5 := objectMemory trueObject.
	self ssFlushStack.
	self CmpCq: s5 R: t0.
	jump1 := self JumpNonZero: 0.
	s8 := bytecodePC.
	s9 := s8 + 7.
	self Jump: (self ensureFixupAt: s9).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s12 := objectMemory falseObject.
	self CmpCq: s12 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpTrue6 [
	"AutoGenerated by Druid"

	| jump1 s8 s5 s2 currentBlock s12 t0 jump2 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s5 := objectMemory trueObject.
	self ssFlushStack.
	self CmpCq: s5 R: t0.
	jump1 := self JumpNonZero: 0.
	s8 := bytecodePC.
	s9 := s8 + 8.
	self Jump: (self ensureFixupAt: s9).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s12 := objectMemory falseObject.
	self CmpCq: s12 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortConditionalJumpTrue7 [
	"AutoGenerated by Druid"

	| jump1 s8 s5 s2 currentBlock s12 t0 jump2 live s9 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 0) copyToReg: t0.
	self ssPop: 1.
	s5 := objectMemory trueObject.
	self ssFlushStack.
	self CmpCq: s5 R: t0.
	jump1 := self JumpNonZero: 0.
	s8 := bytecodePC.
	s9 := s8 + 9.
	self Jump: (self ensureFixupAt: s9).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	s12 := objectMemory falseObject.
	self CmpCq: s12 R: t0.
	jump1 := self JumpZero: 0.
	self MoveR: t0 R: TempReg.
	self CallRT: ceSendMustBeBooleanTrampoline.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortUnconditionalJump0 [
	"AutoGenerated by Druid"

	| s5 s2 currentBlock live s3 |
	live := 0.
	s2 := bytecodePC.
	s3 := s2 + 2.
	self ssFlushStack.
	self Jump: (self ensureFixupAt: s3).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortUnconditionalJump1 [
	"AutoGenerated by Druid"

	| s5 s2 currentBlock live s3 |
	live := 0.
	s2 := bytecodePC.
	s3 := s2 + 3.
	self ssFlushStack.
	self Jump: (self ensureFixupAt: s3).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortUnconditionalJump2 [
	"AutoGenerated by Druid"

	| s5 s2 currentBlock live s3 |
	live := 0.
	s2 := bytecodePC.
	s3 := s2 + 4.
	self ssFlushStack.
	self Jump: (self ensureFixupAt: s3).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortUnconditionalJump3 [
	"AutoGenerated by Druid"

	| s5 s2 currentBlock live s3 |
	live := 0.
	s2 := bytecodePC.
	s3 := s2 + 5.
	self ssFlushStack.
	self Jump: (self ensureFixupAt: s3).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortUnconditionalJump4 [
	"AutoGenerated by Druid"

	| s5 s2 currentBlock live s3 |
	live := 0.
	s2 := bytecodePC.
	s3 := s2 + 6.
	self ssFlushStack.
	self Jump: (self ensureFixupAt: s3).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortUnconditionalJump5 [
	"AutoGenerated by Druid"

	| s5 s2 currentBlock live s3 |
	live := 0.
	s2 := bytecodePC.
	s3 := s2 + 7.
	self ssFlushStack.
	self Jump: (self ensureFixupAt: s3).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortUnconditionalJump6 [
	"AutoGenerated by Druid"

	| s5 s2 currentBlock live s3 |
	live := 0.
	s2 := bytecodePC.
	s3 := s2 + 8.
	self ssFlushStack.
	self Jump: (self ensureFixupAt: s3).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_ShortUnconditionalJump7 [
	"AutoGenerated by Druid"

	| s5 s2 currentBlock live s3 |
	live := 0.
	s2 := bytecodePC.
	s3 := s2 + 9.
	self ssFlushStack.
	self Jump: (self ensureFixupAt: s3).
	deadCode := true.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopReceiverVariableBytecode0 [
	"AutoGenerated by Druid"

	| jump5 s24 s46 s16 jump3 s29 jump1 t1 s2 currentBlock s19 s27 jump6 live jump4 jump2 t2 jump7 t0 s48 |
	live := 0.
	self annotateBytecode: self Label.
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
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 23 R: t2.
	self AndCq: 1 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpZero: 0.
	self deoptimize.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self ssPop: 1.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	s16 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t0 R: t2.
	self AndCq: s16 R: t2.
	s19 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s19 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	s24 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t1 R: t2.
	self AndCq: s24 R: t2.
	s27 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s27 R: t2.
	jump5 := self JumpNonZero: 0.
	s29 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s29 R: t1.
	jump6 := self JumpBelow: 0.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self TstCq: 7 R: t1.
	jump6 := self JumpNonZero: 0.
	self CmpCq: 16r20000000000 R: t0.
	jump5 := self JumpLess: 0.
	self CmpCq: 16r20000000000 R: t1.
	jump4 := self JumpGreaterOrEqual: 0.
	self genMoveConstant: objectMemory nilObject R: t2.
	self CmpR: t2 R: t1.
	jump3 := self JumpBelow: 0.
	s46 := objectMemory trueObject.
	self CmpCq: s46 R: t1.
	jump1 := self JumpBelowOrEqual: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s48 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s48 R: t1.
	jump3 := self JumpBelow: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 M64: 8 r: t0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopReceiverVariableBytecode1 [
	"AutoGenerated by Druid"

	| jump5 s24 s46 s16 jump3 s29 jump1 t1 s2 currentBlock s19 s27 jump6 live jump4 jump2 t2 jump7 t0 s48 |
	live := 0.
	self annotateBytecode: self Label.
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
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 23 R: t2.
	self AndCq: 1 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpZero: 0.
	self deoptimize.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self ssPop: 1.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	s16 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t0 R: t2.
	self AndCq: s16 R: t2.
	s19 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s19 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	s24 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t1 R: t2.
	self AndCq: s24 R: t2.
	s27 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s27 R: t2.
	jump5 := self JumpNonZero: 0.
	s29 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s29 R: t1.
	jump6 := self JumpBelow: 0.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self TstCq: 7 R: t1.
	jump6 := self JumpNonZero: 0.
	self CmpCq: 16r20000000000 R: t0.
	jump5 := self JumpLess: 0.
	self CmpCq: 16r20000000000 R: t1.
	jump4 := self JumpGreaterOrEqual: 0.
	self genMoveConstant: objectMemory nilObject R: t2.
	self CmpR: t2 R: t1.
	jump3 := self JumpBelow: 0.
	s46 := objectMemory trueObject.
	self CmpCq: s46 R: t1.
	jump1 := self JumpBelowOrEqual: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s48 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s48 R: t1.
	jump3 := self JumpBelow: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 M64: 16 r: t0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopReceiverVariableBytecode2 [
	"AutoGenerated by Druid"

	| jump5 s24 s46 s16 jump3 s29 jump1 t1 s2 currentBlock s19 s27 jump6 live jump4 jump2 t2 jump7 t0 s48 |
	live := 0.
	self annotateBytecode: self Label.
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
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 23 R: t2.
	self AndCq: 1 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpZero: 0.
	self deoptimize.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self ssPop: 1.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	s16 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t0 R: t2.
	self AndCq: s16 R: t2.
	s19 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s19 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	s24 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t1 R: t2.
	self AndCq: s24 R: t2.
	s27 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s27 R: t2.
	jump5 := self JumpNonZero: 0.
	s29 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s29 R: t1.
	jump6 := self JumpBelow: 0.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self TstCq: 7 R: t1.
	jump6 := self JumpNonZero: 0.
	self CmpCq: 16r20000000000 R: t0.
	jump5 := self JumpLess: 0.
	self CmpCq: 16r20000000000 R: t1.
	jump4 := self JumpGreaterOrEqual: 0.
	self genMoveConstant: objectMemory nilObject R: t2.
	self CmpR: t2 R: t1.
	jump3 := self JumpBelow: 0.
	s46 := objectMemory trueObject.
	self CmpCq: s46 R: t1.
	jump1 := self JumpBelowOrEqual: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s48 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s48 R: t1.
	jump3 := self JumpBelow: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 M64: 24 r: t0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopReceiverVariableBytecode3 [
	"AutoGenerated by Druid"

	| jump5 s24 s46 s16 jump3 s29 jump1 t1 s2 currentBlock s19 s27 jump6 live jump4 jump2 t2 jump7 t0 s48 |
	live := 0.
	self annotateBytecode: self Label.
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
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 23 R: t2.
	self AndCq: 1 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpZero: 0.
	self deoptimize.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self ssPop: 1.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	s16 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t0 R: t2.
	self AndCq: s16 R: t2.
	s19 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s19 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	s24 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t1 R: t2.
	self AndCq: s24 R: t2.
	s27 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s27 R: t2.
	jump5 := self JumpNonZero: 0.
	s29 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s29 R: t1.
	jump6 := self JumpBelow: 0.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self TstCq: 7 R: t1.
	jump6 := self JumpNonZero: 0.
	self CmpCq: 16r20000000000 R: t0.
	jump5 := self JumpLess: 0.
	self CmpCq: 16r20000000000 R: t1.
	jump4 := self JumpGreaterOrEqual: 0.
	self genMoveConstant: objectMemory nilObject R: t2.
	self CmpR: t2 R: t1.
	jump3 := self JumpBelow: 0.
	s46 := objectMemory trueObject.
	self CmpCq: s46 R: t1.
	jump1 := self JumpBelowOrEqual: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s48 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s48 R: t1.
	jump3 := self JumpBelow: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 M64: 32 r: t0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopReceiverVariableBytecode4 [
	"AutoGenerated by Druid"

	| jump5 s24 s46 s16 jump3 s29 jump1 t1 s2 currentBlock s19 s27 jump6 live jump4 jump2 t2 jump7 t0 s48 |
	live := 0.
	self annotateBytecode: self Label.
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
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 23 R: t2.
	self AndCq: 1 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpZero: 0.
	self deoptimize.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self ssPop: 1.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	s16 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t0 R: t2.
	self AndCq: s16 R: t2.
	s19 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s19 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	s24 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t1 R: t2.
	self AndCq: s24 R: t2.
	s27 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s27 R: t2.
	jump5 := self JumpNonZero: 0.
	s29 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s29 R: t1.
	jump6 := self JumpBelow: 0.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self TstCq: 7 R: t1.
	jump6 := self JumpNonZero: 0.
	self CmpCq: 16r20000000000 R: t0.
	jump5 := self JumpLess: 0.
	self CmpCq: 16r20000000000 R: t1.
	jump4 := self JumpGreaterOrEqual: 0.
	self genMoveConstant: objectMemory nilObject R: t2.
	self CmpR: t2 R: t1.
	jump3 := self JumpBelow: 0.
	s46 := objectMemory trueObject.
	self CmpCq: s46 R: t1.
	jump1 := self JumpBelowOrEqual: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s48 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s48 R: t1.
	jump3 := self JumpBelow: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 M64: 40 r: t0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopReceiverVariableBytecode5 [
	"AutoGenerated by Druid"

	| jump5 s24 s46 s16 jump3 s29 jump1 t1 s2 currentBlock s19 s27 jump6 live jump4 jump2 t2 jump7 t0 s48 |
	live := 0.
	self annotateBytecode: self Label.
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
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 23 R: t2.
	self AndCq: 1 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpZero: 0.
	self deoptimize.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self ssPop: 1.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	s16 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t0 R: t2.
	self AndCq: s16 R: t2.
	s19 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s19 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	s24 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t1 R: t2.
	self AndCq: s24 R: t2.
	s27 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s27 R: t2.
	jump5 := self JumpNonZero: 0.
	s29 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s29 R: t1.
	jump6 := self JumpBelow: 0.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self TstCq: 7 R: t1.
	jump6 := self JumpNonZero: 0.
	self CmpCq: 16r20000000000 R: t0.
	jump5 := self JumpLess: 0.
	self CmpCq: 16r20000000000 R: t1.
	jump4 := self JumpGreaterOrEqual: 0.
	self genMoveConstant: objectMemory nilObject R: t2.
	self CmpR: t2 R: t1.
	jump3 := self JumpBelow: 0.
	s46 := objectMemory trueObject.
	self CmpCq: s46 R: t1.
	jump1 := self JumpBelowOrEqual: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s48 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s48 R: t1.
	jump3 := self JumpBelow: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 M64: 48 r: t0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopReceiverVariableBytecode6 [
	"AutoGenerated by Druid"

	| jump5 s24 s46 s16 jump3 s29 jump1 t1 s2 currentBlock s19 s27 jump6 live jump4 jump2 t2 jump7 t0 s48 |
	live := 0.
	self annotateBytecode: self Label.
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
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 23 R: t2.
	self AndCq: 1 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpZero: 0.
	self deoptimize.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self ssPop: 1.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	s16 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t0 R: t2.
	self AndCq: s16 R: t2.
	s19 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s19 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	s24 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t1 R: t2.
	self AndCq: s24 R: t2.
	s27 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s27 R: t2.
	jump5 := self JumpNonZero: 0.
	s29 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s29 R: t1.
	jump6 := self JumpBelow: 0.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self TstCq: 7 R: t1.
	jump6 := self JumpNonZero: 0.
	self CmpCq: 16r20000000000 R: t0.
	jump5 := self JumpLess: 0.
	self CmpCq: 16r20000000000 R: t1.
	jump4 := self JumpGreaterOrEqual: 0.
	self genMoveConstant: objectMemory nilObject R: t2.
	self CmpR: t2 R: t1.
	jump3 := self JumpBelow: 0.
	s46 := objectMemory trueObject.
	self CmpCq: s46 R: t1.
	jump1 := self JumpBelowOrEqual: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s48 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s48 R: t1.
	jump3 := self JumpBelow: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 M64: 56 r: t0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopReceiverVariableBytecode7 [
	"AutoGenerated by Druid"

	| jump5 s24 s46 s16 jump3 s29 jump1 t1 s2 currentBlock s19 s27 jump6 live jump4 jump2 t2 jump7 t0 s48 |
	live := 0.
	self annotateBytecode: self Label.
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
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 23 R: t2.
	self AndCq: 1 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpZero: 0.
	self deoptimize.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	self ssPop: 1.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	s16 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t0 R: t2.
	self AndCq: s16 R: t2.
	s19 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s19 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	s24 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t1 R: t2.
	self AndCq: s24 R: t2.
	s27 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s27 R: t2.
	jump5 := self JumpNonZero: 0.
	s29 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s29 R: t1.
	jump6 := self JumpBelow: 0.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump7 := self JumpNonZero: 0.
	self TstCq: 7 R: t1.
	jump6 := self JumpNonZero: 0.
	self CmpCq: 16r20000000000 R: t0.
	jump5 := self JumpLess: 0.
	self CmpCq: 16r20000000000 R: t1.
	jump4 := self JumpGreaterOrEqual: 0.
	self genMoveConstant: objectMemory nilObject R: t2.
	self CmpR: t2 R: t1.
	jump3 := self JumpBelow: 0.
	s46 := objectMemory trueObject.
	self CmpCq: s46 R: t1.
	jump1 := self JumpBelowOrEqual: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s48 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s48 R: t1.
	jump3 := self JumpBelow: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump7 jmpTarget: currentBlock.
	jump6 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t1 M64: 64 r: t0.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_StoreAndPopRemoteTempLongBytecode [
	"AutoGenerated by Druid"

	| jump5 s79 s46 jump3 s38 jump8 jump1 s75 t1 s2 currentBlock s51 s49 jump6 s73 jumpNext live s5 jumpTrue s3 jump2 t2 jump7 t0 s41 |
	live := 0.
	self annotateBytecode: self Label.
	s3 := byte1.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: byte2) copyToReg: t0.
	s5 := TempVectReadBarrier.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	s5 ifTrue: [
		| jump1 jumpNext jump6 jump3 jump8 jump5 b561 jumpTrue jump2 jump7 jump4 |
		self MoveM64: 0 r: t0 R: t1.
		self AndCq: 16r3FFFF7 R: t1.
		self CmpCq: 0 R: t1.
		jump1 := self JumpNonZero: 0.
		self MoveM64: 8 r: t0 R: t1.
		b561 := self Label.
		self MoveR: t1 R: t0.
		self AndCq: 7 R: t0.
		self CmpCq: 0 R: t0.
		jump2 := self JumpNonZero: 0.
		self MoveM64: 0 r: t1 R: t0.
		self AndCq: 16r3FFFF7 R: t0.
		self CmpCq: 0 R: t0.
		jump3 := self JumpNonZero: 0.
		self MoveM64: 8 r: t1 R: t0.
		self MoveR: t0 R: t1.
		jump4 := self Jump: b561.
		currentBlock := self Label.
		jump2 jmpTarget: currentBlock.
		jump3 jmpTarget: currentBlock.
		self MoveR: t1 R: t0.
		jump3 := self Jump: 0.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		currentBlock := self Label.
		jump3 jmpTarget: currentBlock.
		(self ssValue: 0) copyToReg: t1.
		self MoveR: t0 R: t2.
		self AndCq: 7 R: t2.
		self ssFlushStack.
		self CmpCq: 0 R: t2.
		jump3 := self JumpNonZero: 0.
		s38 := objectMemory getMemoryMap getSpaceMaskToUse.
		self MoveR: t0 R: t2.
		self AndCq: s38 R: t2.
		s41 := objectMemory getMemoryMap getOldSpaceMask.
		self CmpCq: s41 R: t2.
		jump1 := self JumpNonZero: 0.
		self MoveR: t1 R: t2.
		self AndCq: 7 R: t2.
		self CmpCq: 0 R: t2.
		jump2 := self JumpNonZero: 0.
		s46 := objectMemory getMemoryMap getSpaceMaskToUse.
		self MoveR: t1 R: t2.
		self AndCq: s46 R: t2.
		s49 := objectMemory getMemoryMap getNewSpaceMask.
		self CmpCq: s49 R: t2.
		jump5 := self JumpNonZero: 0.
		s51 := objectMemory getMemoryMap getNewSpaceStart.
		self MoveR: t1 R: t2.
		self CmpCq: s51 R: t2.
		jumpTrue := self JumpAboveOrEqual: 0.
		self MoveCq: 0 R: t2.
		jumpNext := self Jump: 0.
		jumpTrue jmpTarget: self Label.
		self MoveCq: 1 R: t2.
		jumpNext jmpTarget: self Label.
		self CmpCq: 1 R: t2.
		jump6 := self JumpNonZero: 0.
		self MoveM64: 0 r: t0 R: t2.
		self LogicalShiftRightCq: 29 R: t2.
		self AndCq: 1 R: t2.
		self CmpCq: 0 R: t2.
		jump7 := self JumpNonZero: 0.
		self MoveR: t0 R: TempReg.
		backEnd saveAndRestoreLinkRegAround: [
			self CallRT: ceStoreCheckTrampoline ].
		jump8 := self Jump: 0.
		currentBlock := self Label.
		jump5 jmpTarget: currentBlock.
		currentBlock := self Label.
		jump3 jmpTarget: currentBlock.
		jump1 jmpTarget: currentBlock.
		jump2 jmpTarget: currentBlock.
		jump6 jmpTarget: currentBlock.
		jump7 jmpTarget: currentBlock.
		jump8 jmpTarget: currentBlock.
		self MoveM64: 0 r: t0 R: t2.
		self LogicalShiftRightCq: 29 R: t2.
		self AndCq: 1 R: t2.
		self CmpCq: 0 R: t2.
		jump8 := self JumpNonZero: 0.
		self TstCq: 7 R: t1.
		jump7 := self JumpNonZero: 0.
		self CmpCq: 16r20000000000 R: t0.
		jump6 := self JumpLess: 0.
		self CmpCq: 16r20000000000 R: t1.
		jump2 := self JumpGreaterOrEqual: 0.
		self genMoveConstant: objectMemory nilObject R: t2.
		self CmpR: t2 R: t1.
		jump1 := self JumpBelow: 0.
		s73 := objectMemory trueObject.
		self CmpCq: s73 R: t1.
		jump3 := self JumpBelowOrEqual: 0.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		s75 := objectMemory getMemoryMap getNewSpaceStart.
		self CmpCq: s75 R: t1.
		jump1 := self JumpBelow: 0.
		self MoveR: t0 R: TempReg.
		backEnd saveAndRestoreLinkRegAround: [
			self CallRT: ceStoreCheckTrampoline ].
		currentBlock := self Label.
		jump8 jmpTarget: currentBlock.
		jump7 jmpTarget: currentBlock.
		jump6 jmpTarget: currentBlock.
		jump2 jmpTarget: currentBlock.
		jump3 jmpTarget: currentBlock.
		jump1 jmpTarget: currentBlock.
		s79 := s3 << 3.
		self AddCq: s79 R: t0.
		self MoveR: t1 M64: 8 r: t0.
		self ssPop: 1.
		^ 0 ].
	(self ssValue: 0) copyToReg: t1.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	s38 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t0 R: t2.
	self AndCq: s38 R: t2.
	s41 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s41 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	s46 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t1 R: t2.
	self AndCq: s46 R: t2.
	s49 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s49 R: t2.
	jump6 := self JumpNonZero: 0.
	s51 := objectMemory getMemoryMap getNewSpaceStart.
	self MoveR: t1 R: t2.
	self CmpCq: s51 R: t2.
	jumpTrue := self JumpAboveOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 1 R: t2.
	jump7 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump8 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump5 := self JumpNonZero: 0.
	self TstCq: 7 R: t1.
	jump8 := self JumpNonZero: 0.
	self CmpCq: 16r20000000000 R: t0.
	jump7 := self JumpLess: 0.
	self CmpCq: 16r20000000000 R: t1.
	jump2 := self JumpGreaterOrEqual: 0.
	self genMoveConstant: objectMemory nilObject R: t2.
	self CmpR: t2 R: t1.
	jump3 := self JumpBelow: 0.
	s73 := objectMemory trueObject.
	self CmpCq: s73 R: t1.
	jump1 := self JumpBelowOrEqual: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s75 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s75 R: t1.
	jump3 := self JumpBelow: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	s79 := s3 << 3.
	self AddCq: s79 R: t0.
	self MoveR: t1 M64: 8 r: t0.
	self ssPop: 1.
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

{ #category : #generated }
DruidJIT >> gen_StoreRemoteTempLongBytecode [
	"AutoGenerated by Druid"

	| jump5 s79 s46 jump3 s38 jump8 jump1 s75 t1 s2 currentBlock s51 s49 jump6 s73 jumpNext live s5 jumpTrue s3 jump2 t2 jump7 t0 s41 |
	live := 0.
	self annotateBytecode: self Label.
	s3 := byte1.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self simStackTempAt: byte2) copyToReg: t0.
	s5 := TempVectReadBarrier.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	s5 ifTrue: [
		| jump1 jumpNext jump6 jump3 jump8 jump5 jumpTrue jump2 b555 jump7 jump4 |
		self MoveM64: 0 r: t0 R: t1.
		self AndCq: 16r3FFFF7 R: t1.
		self CmpCq: 0 R: t1.
		jump1 := self JumpNonZero: 0.
		self MoveM64: 8 r: t0 R: t1.
		b555 := self Label.
		self MoveR: t1 R: t0.
		self AndCq: 7 R: t0.
		self CmpCq: 0 R: t0.
		jump2 := self JumpNonZero: 0.
		self MoveM64: 0 r: t1 R: t0.
		self AndCq: 16r3FFFF7 R: t0.
		self CmpCq: 0 R: t0.
		jump3 := self JumpNonZero: 0.
		self MoveM64: 8 r: t1 R: t0.
		self MoveR: t0 R: t1.
		jump4 := self Jump: b555.
		currentBlock := self Label.
		jump2 jmpTarget: currentBlock.
		jump3 jmpTarget: currentBlock.
		self MoveR: t1 R: t0.
		jump3 := self Jump: 0.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		currentBlock := self Label.
		jump3 jmpTarget: currentBlock.
		(self ssValue: 0) copyToReg: t1.
		self MoveR: t0 R: t2.
		self AndCq: 7 R: t2.
		self ssFlushStack.
		self CmpCq: 0 R: t2.
		jump3 := self JumpNonZero: 0.
		s38 := objectMemory getMemoryMap getSpaceMaskToUse.
		self MoveR: t0 R: t2.
		self AndCq: s38 R: t2.
		s41 := objectMemory getMemoryMap getOldSpaceMask.
		self CmpCq: s41 R: t2.
		jump1 := self JumpNonZero: 0.
		self MoveR: t1 R: t2.
		self AndCq: 7 R: t2.
		self CmpCq: 0 R: t2.
		jump2 := self JumpNonZero: 0.
		s46 := objectMemory getMemoryMap getSpaceMaskToUse.
		self MoveR: t1 R: t2.
		self AndCq: s46 R: t2.
		s49 := objectMemory getMemoryMap getNewSpaceMask.
		self CmpCq: s49 R: t2.
		jump5 := self JumpNonZero: 0.
		s51 := objectMemory getMemoryMap getNewSpaceStart.
		self MoveR: t1 R: t2.
		self CmpCq: s51 R: t2.
		jumpTrue := self JumpAboveOrEqual: 0.
		self MoveCq: 0 R: t2.
		jumpNext := self Jump: 0.
		jumpTrue jmpTarget: self Label.
		self MoveCq: 1 R: t2.
		jumpNext jmpTarget: self Label.
		self CmpCq: 1 R: t2.
		jump6 := self JumpNonZero: 0.
		self MoveM64: 0 r: t0 R: t2.
		self LogicalShiftRightCq: 29 R: t2.
		self AndCq: 1 R: t2.
		self CmpCq: 0 R: t2.
		jump7 := self JumpNonZero: 0.
		self MoveR: t0 R: TempReg.
		backEnd saveAndRestoreLinkRegAround: [
			self CallRT: ceStoreCheckTrampoline ].
		jump8 := self Jump: 0.
		currentBlock := self Label.
		jump5 jmpTarget: currentBlock.
		currentBlock := self Label.
		jump3 jmpTarget: currentBlock.
		jump1 jmpTarget: currentBlock.
		jump2 jmpTarget: currentBlock.
		jump6 jmpTarget: currentBlock.
		jump7 jmpTarget: currentBlock.
		jump8 jmpTarget: currentBlock.
		self MoveM64: 0 r: t0 R: t2.
		self LogicalShiftRightCq: 29 R: t2.
		self AndCq: 1 R: t2.
		self CmpCq: 0 R: t2.
		jump8 := self JumpNonZero: 0.
		self TstCq: 7 R: t1.
		jump7 := self JumpNonZero: 0.
		self CmpCq: 16r20000000000 R: t0.
		jump6 := self JumpLess: 0.
		self CmpCq: 16r20000000000 R: t1.
		jump2 := self JumpGreaterOrEqual: 0.
		self genMoveConstant: objectMemory nilObject R: t2.
		self CmpR: t2 R: t1.
		jump1 := self JumpBelow: 0.
		s73 := objectMemory trueObject.
		self CmpCq: s73 R: t1.
		jump3 := self JumpBelowOrEqual: 0.
		currentBlock := self Label.
		jump1 jmpTarget: currentBlock.
		s75 := objectMemory getMemoryMap getNewSpaceStart.
		self CmpCq: s75 R: t1.
		jump1 := self JumpBelow: 0.
		self MoveR: t0 R: TempReg.
		backEnd saveAndRestoreLinkRegAround: [
			self CallRT: ceStoreCheckTrampoline ].
		currentBlock := self Label.
		jump8 jmpTarget: currentBlock.
		jump7 jmpTarget: currentBlock.
		jump6 jmpTarget: currentBlock.
		jump2 jmpTarget: currentBlock.
		jump3 jmpTarget: currentBlock.
		jump1 jmpTarget: currentBlock.
		s79 := s3 << 3.
		self AddCq: s79 R: t0.
		self MoveR: t1 M64: 8 r: t0.
		^ 0 ].
	(self ssValue: 0) copyToReg: t1.
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self ssFlushStack.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	s38 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t0 R: t2.
	self AndCq: s38 R: t2.
	s41 := objectMemory getMemoryMap getOldSpaceMask.
	self CmpCq: s41 R: t2.
	jump3 := self JumpNonZero: 0.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	s46 := objectMemory getMemoryMap getSpaceMaskToUse.
	self MoveR: t1 R: t2.
	self AndCq: s46 R: t2.
	s49 := objectMemory getMemoryMap getNewSpaceMask.
	self CmpCq: s49 R: t2.
	jump6 := self JumpNonZero: 0.
	s51 := objectMemory getMemoryMap getNewSpaceStart.
	self MoveR: t1 R: t2.
	self CmpCq: s51 R: t2.
	jumpTrue := self JumpAboveOrEqual: 0.
	self MoveCq: 0 R: t2.
	jumpNext := self Jump: 0.
	jumpTrue jmpTarget: self Label.
	self MoveCq: 1 R: t2.
	jumpNext jmpTarget: self Label.
	self CmpCq: 1 R: t2.
	jump7 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump8 := self JumpNonZero: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	jump5 := self Jump: 0.
	currentBlock := self Label.
	jump6 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump5 jmpTarget: currentBlock.
	self MoveM64: 0 r: t0 R: t2.
	self LogicalShiftRightCq: 29 R: t2.
	self AndCq: 1 R: t2.
	self CmpCq: 0 R: t2.
	jump5 := self JumpNonZero: 0.
	self TstCq: 7 R: t1.
	jump8 := self JumpNonZero: 0.
	self CmpCq: 16r20000000000 R: t0.
	jump7 := self JumpLess: 0.
	self CmpCq: 16r20000000000 R: t1.
	jump2 := self JumpGreaterOrEqual: 0.
	self genMoveConstant: objectMemory nilObject R: t2.
	self CmpR: t2 R: t1.
	jump3 := self JumpBelow: 0.
	s73 := objectMemory trueObject.
	self CmpCq: s73 R: t1.
	jump1 := self JumpBelowOrEqual: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s75 := objectMemory getMemoryMap getNewSpaceStart.
	self CmpCq: s75 R: t1.
	jump3 := self JumpBelow: 0.
	self MoveR: t0 R: TempReg.
	backEnd saveAndRestoreLinkRegAround: [
		self CallRT: ceStoreCheckTrampoline ].
	currentBlock := self Label.
	jump5 jmpTarget: currentBlock.
	jump8 jmpTarget: currentBlock.
	jump7 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	s79 := s3 << 3.
	self AddCq: s79 R: t0.
	self MoveR: t1 M64: 8 r: t0.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpFalse_10 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 currentBlock t0 jump5 jump2 b558 s58 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := bytecodePC.
	s58 := s57 + 3.
	self Jump: (self ensureFixupAt: s58).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpFalse_11 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 currentBlock t0 jump5 jump2 b558 s58 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := bytecodePC.
	s58 := s57 + 4.
	self Jump: (self ensureFixupAt: s58).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpFalse_12 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 currentBlock t0 jump5 jump2 b558 s58 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := bytecodePC.
	s58 := s57 + 5.
	self Jump: (self ensureFixupAt: s58).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpFalse_13 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 currentBlock t0 jump5 jump2 b558 s58 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := bytecodePC.
	s58 := s57 + 6.
	self Jump: (self ensureFixupAt: s58).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpFalse_14 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 currentBlock t0 jump5 jump2 b558 s58 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := bytecodePC.
	s58 := s57 + 7.
	self Jump: (self ensureFixupAt: s58).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpFalse_15 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 currentBlock t0 jump5 jump2 b558 s58 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := bytecodePC.
	s58 := s57 + 8.
	self Jump: (self ensureFixupAt: s58).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpFalse_16 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 currentBlock t0 jump5 jump2 b558 s58 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := bytecodePC.
	s58 := s57 + 9.
	self Jump: (self ensureFixupAt: s58).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpFalse_9 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 currentBlock t0 jump5 jump2 b558 s58 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := bytecodePC.
	s58 := s57 + 2.
	self Jump: (self ensureFixupAt: s58).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpTrue_1 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 s56 currentBlock t0 jump5 jump2 b558 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	s56 := bytecodePC.
	s57 := s56 + 2.
	self Jump: (self ensureFixupAt: s57).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpTrue_2 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 s56 currentBlock t0 jump5 jump2 b558 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	s56 := bytecodePC.
	s57 := s56 + 3.
	self Jump: (self ensureFixupAt: s57).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpTrue_3 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 s56 currentBlock t0 jump5 jump2 b558 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	s56 := bytecodePC.
	s57 := s56 + 4.
	self Jump: (self ensureFixupAt: s57).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpTrue_4 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 s56 currentBlock t0 jump5 jump2 b558 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	s56 := bytecodePC.
	s57 := s56 + 5.
	self Jump: (self ensureFixupAt: s57).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpTrue_5 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 s56 currentBlock t0 jump5 jump2 b558 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	s56 := bytecodePC.
	s57 := s56 + 6.
	self Jump: (self ensureFixupAt: s57).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpTrue_6 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 s56 currentBlock t0 jump5 jump2 b558 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	s56 := bytecodePC.
	s57 := s56 + 7.
	self Jump: (self ensureFixupAt: s57).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpTrue_7 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 s56 currentBlock t0 jump5 jump2 b558 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	s56 := bytecodePC.
	s57 := s56 + 8.
	self Jump: (self ensureFixupAt: s57).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimIdenticalSistaV1_shortConditionalJumpTrue_8 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 s56 currentBlock t0 jump5 jump2 b558 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpNonZero: 0.
	s56 := bytecodePC.
	s57 := s56 + 9.
	self Jump: (self ensureFixupAt: s57).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpFalse_10 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 currentBlock t0 jump5 jump2 b558 s58 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := bytecodePC.
	s58 := s57 + 3.
	self Jump: (self ensureFixupAt: s58).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpFalse_11 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 currentBlock t0 jump5 jump2 b558 s58 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := bytecodePC.
	s58 := s57 + 4.
	self Jump: (self ensureFixupAt: s58).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpFalse_12 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 currentBlock t0 jump5 jump2 b558 s58 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := bytecodePC.
	s58 := s57 + 5.
	self Jump: (self ensureFixupAt: s58).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpFalse_13 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 currentBlock t0 jump5 jump2 b558 s58 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := bytecodePC.
	s58 := s57 + 6.
	self Jump: (self ensureFixupAt: s58).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpFalse_14 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 currentBlock t0 jump5 jump2 b558 s58 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := bytecodePC.
	s58 := s57 + 7.
	self Jump: (self ensureFixupAt: s58).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpFalse_15 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 currentBlock t0 jump5 jump2 b558 s58 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := bytecodePC.
	s58 := s57 + 8.
	self Jump: (self ensureFixupAt: s58).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpFalse_16 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 currentBlock t0 jump5 jump2 b558 s58 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := bytecodePC.
	s58 := s57 + 9.
	self Jump: (self ensureFixupAt: s58).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpFalse_9 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 currentBlock t0 jump5 jump2 b558 s58 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	jump2 := self Jump: 0.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	s57 := bytecodePC.
	s58 := s57 + 2.
	self Jump: (self ensureFixupAt: s58).
	deadCode := true.
	deadCode := false.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpTrue_1 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 s56 currentBlock t0 jump5 jump2 b558 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	s56 := bytecodePC.
	s57 := s56 + 2.
	self Jump: (self ensureFixupAt: s57).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpTrue_2 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 s56 currentBlock t0 jump5 jump2 b558 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	s56 := bytecodePC.
	s57 := s56 + 3.
	self Jump: (self ensureFixupAt: s57).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpTrue_3 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 s56 currentBlock t0 jump5 jump2 b558 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	s56 := bytecodePC.
	s57 := s56 + 4.
	self Jump: (self ensureFixupAt: s57).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpTrue_4 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 s56 currentBlock t0 jump5 jump2 b558 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	s56 := bytecodePC.
	s57 := s56 + 5.
	self Jump: (self ensureFixupAt: s57).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpTrue_5 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 s56 currentBlock t0 jump5 jump2 b558 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	s56 := bytecodePC.
	s57 := s56 + 6.
	self Jump: (self ensureFixupAt: s57).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpTrue_6 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 s56 currentBlock t0 jump5 jump2 b558 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	s56 := bytecodePC.
	s57 := s56 + 7.
	self Jump: (self ensureFixupAt: s57).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpTrue_7 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 s56 currentBlock t0 jump5 jump2 b558 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	s56 := bytecodePC.
	s57 := s56 + 8.
	self Jump: (self ensureFixupAt: s57).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
	^ 0
]

{ #category : #generated }
DruidJIT >> gen_bytecodePrimNotIdenticalSistaV1_shortConditionalJumpTrue_8 [
	"AutoGenerated by Druid"

	| jump1 s57 t1 jump6 b562 jump3 s2 s56 currentBlock t0 jump5 jump2 b558 live t2 jump4 |
	live := 0.
	self annotateBytecode: self Label.
	t0 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t0).
	(self ssValue: 1) copyToReg: t0.
	t1 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t1).
	(self ssValue: 0) copyToReg: t1.
	t2 := self
		      allocateRegNotConflictingWith: live
		      ifNone: [ ^ self unknownBytecode ].
	live := live bitOr: (self registerMaskFor: t2).
	self MoveR: t0 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t0 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t0 R: t2.
	b562 := self Label.
	self MoveR: t2 R: t0.
	self AndCq: 7 R: t0.
	self CmpCq: 0 R: t0.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t0.
	self AndCq: 16r3FFFF7 R: t0.
	self CmpCq: 0 R: t0.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t0.
	self MoveR: t0 R: t2.
	jump5 := self Jump: b562.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	jump4 jmpTarget: currentBlock.
	self MoveR: t2 R: t0.
	jump4 := self Jump: 0.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	self MoveR: t1 R: t2.
	self AndCq: 7 R: t2.
	self CmpCq: 0 R: t2.
	jump4 := self JumpNonZero: 0.
	self MoveM64: 0 r: t1 R: t2.
	self AndCq: 16r3FFFF7 R: t2.
	self CmpCq: 0 R: t2.
	jump2 := self JumpNonZero: 0.
	self MoveM64: 8 r: t1 R: t2.
	b558 := self Label.
	self MoveR: t2 R: t1.
	self AndCq: 7 R: t1.
	self CmpCq: 0 R: t1.
	jump1 := self JumpNonZero: 0.
	self MoveM64: 0 r: t2 R: t1.
	self AndCq: 16r3FFFF7 R: t1.
	self CmpCq: 0 R: t1.
	jump3 := self JumpNonZero: 0.
	self MoveM64: 8 r: t2 R: t1.
	self MoveR: t1 R: t2.
	jump6 := self Jump: b558.
	currentBlock := self Label.
	jump1 jmpTarget: currentBlock.
	jump3 jmpTarget: currentBlock.
	self MoveR: t2 R: t1.
	jump3 := self Jump: 0.
	currentBlock := self Label.
	jump4 jmpTarget: currentBlock.
	jump2 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	self ssPop: 2.
	self ssFlushStack.
	self CmpR: t1 R: t0.
	jump3 := self JumpZero: 0.
	s56 := bytecodePC.
	s57 := s56 + 9.
	self Jump: (self ensureFixupAt: s57).
	deadCode := true.
	jump2 := self Jump: 0.
	deadCode := false.
	currentBlock := self Label.
	jump3 jmpTarget: currentBlock.
	currentBlock := self Label.
	jump2 jmpTarget: currentBlock.
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
