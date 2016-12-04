package com.github.jmodel.validation.plugin.util

import com.github.jmodel.validation.plugin.validationLanguage.Block
import com.github.jmodel.validation.plugin.validationLanguage.CheckModel
import com.github.jmodel.validation.plugin.validationLanguage.Filter
import com.github.jmodel.validation.plugin.validationLanguage.Precondition
import com.github.jmodel.validation.plugin.validationLanguage.SingleFieldPath
import java.util.Stack
import org.eclipse.emf.ecore.EObject
import com.github.jmodel.validation.plugin.validationLanguage.Body

class Util {

	def static boolean isPredict(String oper) {
		if (oper.equals("==") || oper.equals("!=") || oper.equals(">") || oper.equals(">=") || oper.equals("<") ||
			oper.equals("<=") || oper.equals("in") || oper.equals("!in") || oper.equals("||") || oper.equals("&&")) {
			return true
		} else {
			return false
		}
	}

	def static String operEnum(String oper) {
		switch oper {
			case "==": "com.github.jmodel.api.OperationEnum.EQUALS"
			case "!=": "com.github.jmodel.api.OperationEnum.NOTEQUALS"
			case ">": "com.github.jmodel.api.OperationEnum.GT"
			case ">=": "com.github.jmodel.api.OperationEnum.GTE"
			case "<": "com.github.jmodel.api.OperationEnum.LT"
			case "<=": "com.github.jmodel.api.OperationEnum.LTE"
			case "in": "com.github.jmodel.api.OperationEnum.IN"
			case "!in": "com.github.jmodel.api.OperationEnum.NOTIN"
			case "||": "com.github.jmodel.api.OperationEnum.OR"
			case "&&": "com.github.jmodel.api.OperationEnum.AND"
			case "+": "com.github.jmodel.api.OperationEnum.PLUS"
			default: "The operation is not supported"
		}
	}

//	def static String getFromSchema(EObject x) {
//		if(x instanceof Mapping){
//			return x.from.schema
//		}else{
//			getFromSchema(x.eContainer)
//		}
//	}
	def static String getVariableName(String variableDeclaration) {
		variableDeclaration.substring(2, variableDeclaration.length - 1)
	}

	def static boolean isDot(String x) {
		if (x.equals(".")) {
			true
		} else {
			false
		}
	}

//	def static boolean isInAppendPath(EObject x) {
//		if (x instanceof Body) {
//			return false;
//		} else if (x instanceof Block) {
//			if (x.isAppend != null) {
//				return true;
//			}
//		}
//		return isInAppendPath(x.eContainer);
//	}
//	def static boolean isInXIfExpression(EObject x) {
//		if (x instanceof XIfExpression) {
//			return true;
//		} else if (x instanceof Block) {
//			return false;
//		} else {
//			return isInFilter(x.eContainer);
//		}
//	}
//	/**
//	 * If the EObject is in a array path, include self, then return true 
//	 */
//	def static boolean isArrayPath(EObject eObj) {
//		val sourceModelPath = getFullModelPath(eObj, true)
//		val targetModelPath = getFullModelPath(eObj, false)
//		sourceModelPath.contains("[") || targetModelPath.contains("[")
//	}
//
//	/**
//	 * If the EObject is in a source array path, include self, then return true 
//	 */
//	def static boolean isSourceArrayPath(EObject eObj) {
//		val sourceModelPath = getFullModelPath(eObj, true)
//		sourceModelPath.contains("[")
//	}
//
//	def private static boolean isTargetModelInArrayPath(EObject eObj) {
//		val targetModelPath = getFullModelPath(eObj, false)
//		val lastDotPosition = targetModelPath.lastIndexOf(".");
//		if (lastDotPosition < 0) {
//			false
//		} else {
//			targetModelPath.substring(0, lastDotPosition).contains("[")
//		}
//	}
//
//
//	def private static boolean isTargetModelArray(EObject eObj) {
//		val targetModelPath = getFullModelPath(eObj, false)
//		val lastDotPosition = targetModelPath.lastIndexOf(".");
//		if (lastDotPosition < 0) {
//			targetModelPath.contains("[")
//		} else {
//			targetModelPath.substring(lastDotPosition).contains("[")
//		}
//	}
//
//	def static String getTargetModelPathByPath(EObject eObj) {
//		getFullModelPath(getBlockByPath(eObj), false)
//	}
//
//
//	def static Block getCurrentBlock(EObject eObj) {
//
//		if (eObj instanceof SingleSourceFieldPath) {
//			if (eObj.absolutePath != null) {
//				return getBlockByPath(eObj)
//			}
//		}
//
//		if (eObj instanceof Block) {
//			return eObj
//		} else {
//			return getCurrentBlock(eObj.eContainer)
//		}
//	}
//
//	def static Block getCurrentAliasedBlockForTargetModelPath(EObject eObj) {
//		if (eObj instanceof Block && !isDot((eObj as Block).targetModelPath)) {
//			return eObj as Block
//		} else {
//			return getCurrentAliasedBlockForTargetModelPath(eObj.eContainer)
//		}
//	}
//
//	def static Block getAppendedBlock(Body body, String fullTargetModelPath) {
//		for (block : body.blocks) {
//			val appendedBlock = getAppendedBlock0(block as Block, fullTargetModelPath)
//			if (appendedBlock != null) {
//				return appendedBlock
//			}
//		}
//		return null
//	}
//
//	def private static Block getAppendedBlock0(Block block, String fullTargetModelPath) {
//		if (!(block.targetModelPath.equals(".")) && block.isAppend == null &&
//			fullTargetModelPath.equals(getFullModelPath(block, false))) {
//			return block
//		} else {
//			for (subBlock : block.blocks) {
//				return getAppendedBlock0(subBlock as Block, fullTargetModelPath)
//			}
//			return null
//		}
//	}
//
//
//	def static Body getBody(EObject eObj) {
//		if (eObj instanceof Body) {
//			return eObj
//		} else {
//			return getBody(eObj.eContainer)
//		}
//	}
//
//	def static String getCurrentSourceModelPath(EObject eObj) {
//		if (eObj instanceof Block) {
//			if (!(eObj.sourceModelPath.equals("."))) {
//				return eObj.sourceModelPath
//			}
//		}
//		getCurrentSourceModelPath(eObj.eContainer)
//	}
//
	// get source model path of last array, if no array, return null
//	def static String[] getLastArrayModelPath(EObject eObj, boolean isSourceModelPath) {
//		var String[] modelPaths = newArrayOfSize(2)
//		var String modelPath = null
//		if (isSourceModelPath) {
//			modelPath = getFullModelPath(eObj, true)
//		} else {
//			modelPath = getFullModelPath(eObj, false)
//		}
//
//		val lastDotPosition = modelPath.lastIndexOf(".");
//		if (lastDotPosition < 0) {
//			return null
//		} else {
//			val parentModelPath = modelPath.substring(0, lastDotPosition)
//			val lastArrayPosition = parentModelPath.lastIndexOf("[")
//			if (lastArrayPosition < 0) {
//				return null
//			} else {
//				modelPaths.set(0, parentModelPath.substring(0, lastArrayPosition) + "[]")
//				modelPaths.set(1, modelPath.substring(lastArrayPosition + 2))
//				return modelPaths
//			}
//		}
//	}
	def static Block getBlockByPath0(Stack<Block> blockStack, int index) {
		if (index == 1) {
			blockStack.pop
		} else {
			blockStack.pop
			getBlockByPath0(blockStack, index - 1)
		}
	}

	def static void buildBlockStack(Stack<Block> blockStack, EObject eObj) {
		if (eObj instanceof Block) {
			blockStack.push(eObj)
			if (eObj.eContainer instanceof CheckModel) {
				return
			}
		}
		buildBlockStack(blockStack, eObj.eContainer)
	}

	def static Block getBlockByPath(EObject eObj) {

		val Stack<Block> blockStack = new Stack<Block>()
		buildBlockStack(blockStack, eObj)
		if (eObj instanceof Block) {
			getBlockByPath0(blockStack, 1)
		} else if (eObj instanceof SingleFieldPath) {
			getBlockByPath0(blockStack, eObj.absolutePath.length)
		} else if (eObj instanceof CheckModel) {
			throw new RuntimeException("please contact system administrator");
		} else {
			getBlockByPath(eObj.eContainer);
		}
	}

	def static Block getCurrentBlock(EObject eObj) {

		if (eObj instanceof SingleFieldPath) {
			if (eObj.absolutePath != null) {
				return getBlockByPath(eObj)
			}
		}

		if (eObj instanceof Block) {
			return eObj
		} else {
			return getCurrentBlock(eObj.eContainer)
		}
	}

	def static String getFullModelPath(EObject eObj) {
		val currentBlock = getCurrentBlock(eObj)
		if (currentBlock.eContainer instanceof Body) {
			return currentBlock.modelPath

		}
		return getFullModelPath0(currentBlock, "")
	}

	def private static String getFullModelPath0(EObject eObj, String modelPath) {
		if (eObj instanceof Body) {
			return modelPath;
		}

		if (!(eObj instanceof Block)) {
			return getFullModelPath0(eObj.eContainer, modelPath)
		}

		val Block block = (eObj as Block)

		if (block.absolutePath != null) {
			if (block.modelPath.equals(".")) {
				return getSourceModelPathByPath(block)
			} else {
				return getSourceModelPathByPath(block) + '.' + block.modelPath
			}
		} else {
			if (block.modelPath.equals(".")) {
				return getFullModelPath0(eObj.eContainer, modelPath)
			} else {
				if (modelPath.trim.length == 0) {
					return getFullModelPath0(eObj.eContainer, block.modelPath)
				} else {
					return getFullModelPath0(eObj.eContainer, block.modelPath + '.' + modelPath)
				}

			}
		}

	}

	def static String getSourceModelPathByPath(EObject eObj) {
		getFullModelPath(getBlockByPath(eObj))
	}

	/**
	 * If the EObject is in a array path, not include self, then return true 
	 */
	def static boolean isInArrayPath(EObject eObj) {
		val modelPath = getFullModelPath(eObj)
		val lastDotPosition = modelPath.lastIndexOf(".");
		if (lastDotPosition < 0) {
			false
		} else {
			modelPath.substring(0, lastDotPosition).contains("[")
		}
	}

	def static Block getLastArrayBlock(EObject eObj) {
		getLastArrayBlock0(eObj, 0);
	}

	def private static Block getLastArrayBlock0(EObject eObj, int found) {
		if (eObj instanceof CheckModel) {
			return null;
		} else if (eObj instanceof Block) {
			if (isArray(eObj)) {
				if (found == 1) {
					return eObj
				} else {
					return getLastArrayBlock0(eObj.eContainer, found + 1)
				}
			}
		}
		return getLastArrayBlock0(eObj.eContainer, found)
	}

	/**
	 * If the EObject is in a array 
	 */
	def static boolean isArray(EObject eObj) {
		val modelPath = getFullModelPath(eObj)
		val lastDotPosition = modelPath.lastIndexOf(".");
		if (lastDotPosition < 0) {
			modelPath.contains("[")
		} else {
			modelPath.substring(lastDotPosition).contains("[")
		}
	}

	/**
	 * If the EObject is in a array path, include self, then return true 
	 */
	def static boolean isArrayPath(EObject eObj) {
		val modelPath = getFullModelPath(eObj)
		modelPath.contains("[")
	}

	def static boolean isInFilter(EObject x) {
		if (x instanceof Filter) {
			return true;
		} else if (x instanceof Block) {
			return false;
		} else {
			return isInFilter(x.eContainer);
		}
	}

	def static boolean isInPrecondition(EObject x) {
		if (x instanceof Precondition) {
			return true;
		} else if (x instanceof CheckModel) {
			return false;
		} else {
			return isInPrecondition(x.eContainer);
		}
	}

}
