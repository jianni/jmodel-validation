package com.github.jmodel.validation.plugin.validation

import org.eclipse.xtext.xbase.XExpression

/**
 * Custom validation rules. 
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
class ValidationLanguageValidator extends AbstractValidationLanguageValidator {
	
//	val Map<String, String> xsdKeyCache = new HashMap<String, String>()
//	val Map<String, Map<String, TreeNode<String>>> xsdCache = new HashMap<String, Map<String, TreeNode<String>>>()
//
//	@Check
//	def checkMapping(Mapping mapping) {
//
//		/*
//		 * check name space
//		 */
//		val platformString = mapping.eResource.URI.toPlatformString(true)
//		val myFile = ResourcesPlugin.getWorkspace().getRoot().getFile(new Path(platformString))
//		val proj = myFile.getProject()
//		val IJavaProject javaProject = JavaCore.create(proj)
//
//		var String packageName = null
//		var String xsdFileName = null
//		if (mapping.from.schema != null) {
//			val s = mapping.from.schema.split("\\.")
//			if (s.length > 2) {
//				for (var i = 0; i < (s.length - 2); i++) {
//					if (packageName == null) {
//						packageName = s.get(i)
//					} else {
//						packageName = packageName + '.' + s.get(i)
//					}
//				}
//				xsdFileName = mapping.from.schema.replace(packageName + '.', '')
//			} else {
//				packageName = ""
//				xsdFileName = mapping.from.schema
//			}
//		}
//
//		try {
//			var boolean xsdFound = false
//			val IPackageFragmentRoot[] packageFragmentRoot = javaProject.getAllPackageFragmentRoots();
//			for (var int i = 0; i < packageFragmentRoot.length; i++) {
//				val IPackageFragmentRoot thePFR = packageFragmentRoot.get(i)
//
//				/*
//				 * Try to find node path map from cache, if not exists or expire, convert the schema file to node path map and cache it
//				 */
//				if (mapping.from.schema != null && !xsdFound) {
//					val packageFragment = thePFR.getPackageFragment(packageName);
//					if (packageFragment != null) {
//						val files = packageFragment.getNonJavaResources()
//						for (file : files) {
//							if (file instanceof IFile) {
//								if (file.name.equals(xsdFileName)) {
//									val File xsdFile = file.location.toFile
//									val cacheKey = xsdFile.lastModified + "_" + xsdFile.length
//									val xsdKey = xsdKeyCache.get(mapping.from.schema)
//									if (xsdKey == null) {
//										xsdCache.put(cacheKey,
//											XmlSchema2NodePathMap.convert(file.location.toFile.absolutePath))
//										xsdKeyCache.put(mapping.from.schema, cacheKey)
//									} else {
//										if (xsdKey.equals(cacheKey)) {
//											// still valid
//											var Map<String, TreeNode<String>> nodePathMap = xsdCache.get(cacheKey)
//											if (nodePathMap == null) {
//												xsdCache.put(cacheKey,
//													XmlSchema2NodePathMap.convert(file.location.toFile.absolutePath))
//											}
//										} else {
//											// expired
//											xsdKeyCache.remove(mapping.from.schema)
//											xsdCache.remove(xsdKey)
//											xsdCache.put(cacheKey,
//												XmlSchema2NodePathMap.convert(file.location.toFile.absolutePath))
//											xsdKeyCache.put(mapping.from.schema, cacheKey)
//										}
//									}
//									xsdFound = true
//								}
//							}
//						}
//					}
//				}
//
//				/*
//				 * check mapping's namespace
//				 */
//				if (thePFR.getKind() == IPackageFragmentRoot.K_SOURCE && !thePFR.isArchive()) {
//					val sourceFolderPath = thePFR.path.toString
//					val position = platformString.indexOf(sourceFolderPath)
//					if (position > -1) {
//						val mappingName = platformString.substring(position + sourceFolderPath.length + 1).replace('/',
//							'.')
//						val expectedMappingName = mappingName.substring(0, mappingName.lastIndexOf('.'))
//						if (!expectedMappingName.equals(mapping.name)) {
//							error(
//								'The declared mapping "' + mapping.name + '" does not match the expected mapping "' +
//									expectedMappingName + '"', mapping, null)
//						}
//					}
//
//				}
//			}
//		} catch (JavaModelException e) {
//			e.printStackTrace()
//		}
//
//	}
//
//	@Check
//	def checkBlock(Block block) {
//		/*
//		 * model path can't include two arrays
//		 */
//		var firstPosition = block.sourceModelPath.indexOf('[')
//		if (firstPosition > 0 && firstPosition != block.sourceModelPath.lastIndexOf('[')) {
//			error('Two array models is not allowed in a mapping block', block, null)
//		}
//		firstPosition = block.targetModelPath.indexOf('[')
//		if (firstPosition > 0 && firstPosition != block.targetModelPath.lastIndexOf('[')) {
//			error('Two array models is not allowed in a mapping block', block, null)
//		}
//
//		/*
//		 * 
//		 */
//		val fromSchema = Util.getFromSchema(block)
//		if (fromSchema != null) {
//			val sourceModelPath = Util.getFullModelPath(block, true)
//			val String xsdKey = xsdKeyCache.get(fromSchema)
//			if (xsdKey != null) {
//				val Map<String, TreeNode<String>> nodePathMap = xsdCache.get(xsdKey)
//				if (nodePathMap == null) {
//					error('From Schema file is not found', block, null)
//				} else {
//					if (nodePathMap.get(sourceModelPath) == null) {
//						error('The model path (' + sourceModelPath + ') is not defined in Schema', block, null)
//					}
//				}
//			} else {
//				error('From Schema file is not found', block, null)
//			}
//		}
//
//		/*
//		 * check if model path deviates from model path of parent
//		 */
////		val currentMapping = Util.getBody(block).eContainer as Mapping
////		val superType = currentMapping.superType
////		val tIter = superType.eAllContents.toIterable.filter(typeof(Block)).filter(f|(!f.targetModelPath.equals('.'))).
////			filter(
////				s |
////					(
////						(Util.getFullModelPath(s, false).equals(block.targetModelPath + "[]").operator_or(s.
////							targetModelPath.substring(0, s.targetModelPath.length - 2).equals(
////								Util.getFullModelPath(block, false)))))
////			)
////		if (tIter.iterator.hasNext) {
////			error('The model path "' + block.targetModelPath + '" deviates from the model path in parent mapping',
////				block, null)
////		}
//		/*
//		 * check incorrect dot path
//		 */
//		if (block.eContainer instanceof Body) {
//			if (block.sourceModelPath.equals('.').operator_or(block.targetModelPath.equals('.'))) {
//				error('xxx', block, null)
//			}
//		}
//
//	}
//
//	@Check
//	def checkXBinaryOperation(XBinaryOperation binaryOperation) {
//		if (binaryOperation.leftOperand instanceof XNullLiteral ||
//			binaryOperation.rightOperand instanceof XNullLiteral) {
//			val oper = binaryOperation.getConcreteSyntaxFeatureName()
//			if (!oper.equals("==") && !oper.equals("!=")) {
//				error('The operation "' + oper + '" is not support for null', binaryOperation, null)
//			}
//		}
//	}
//
	/**
	 * important! for ignoring the built-in validation, need to override this method
	 */
	override checkInnerExpressions(XExpression expr) {
		// disabled
	}
}
