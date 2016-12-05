package com.github.jmodel.validation.plugin.jvmmodel

import com.github.jmodel.validation.plugin.util.Util
import com.github.jmodel.validation.plugin.validationLanguage.Block
import com.github.jmodel.validation.plugin.validationLanguage.Body
import com.github.jmodel.validation.plugin.validationLanguage.CheckModel
import com.github.jmodel.validation.plugin.validationLanguage.FailedMessageSetting
import com.github.jmodel.validation.plugin.validationLanguage.Rule
import com.github.jmodel.validation.plugin.validationLanguage.SingleFieldPath
import org.eclipse.xtext.xbase.XBinaryOperation
import org.eclipse.xtext.xbase.XBooleanLiteral
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.XIfExpression
import org.eclipse.xtext.xbase.XNullLiteral
import org.eclipse.xtext.xbase.XNumberLiteral
import org.eclipse.xtext.xbase.XStringLiteral
import org.eclipse.xtext.xbase.compiler.XbaseCompiler
import org.eclipse.xtext.xbase.compiler.output.ITreeAppendable
import com.github.jmodel.validation.plugin.validationLanguage.CheckService
import com.github.jmodel.validation.plugin.validationLanguage.ArgsSetting
import com.github.jmodel.validation.plugin.validationLanguage.Arg
import com.github.jmodel.validation.plugin.validationLanguage.Variable

/**
 * The main procedure of compiling:
 * <ul>
 * <li>doInternalToJavaStatement</li> 
 * <li>_toJavaStatement</li>
 * <li>internalToJavaStatement</li>
 * <li>internalToJavaExpression</li>
 * <li>internalToConvertedExpression</li>
 * <li>_toJavaExpression</li>
 * </ul>
 */
class ValidationXbaseCompiler extends XbaseCompiler {

	override protected doInternalToJavaStatement(XExpression expr, ITreeAppendable it, boolean isReferenced) {
		switch expr {
			Body: {
				newLine
				append('''super.execute(model, serviceArgsMap, myVariablesMap, result, currentLocale);''')

				for (check : expr.checkModels) {
					doInternalToJavaStatement(check, it, isReferenced)
				}
				
				if(expr.checkService != null) {
					doInternalToJavaStatement(expr.checkService, it, isReferenced)
				}
			}
			CheckModel: {
				if (expr.precondition != null) {
					newLine
					append('''if(''')

					doInternalToJavaStatement(expr.precondition.expression, it, isReferenced)

					append(''') {''')

				}

				for (block : expr.blocks) {
					doInternalToJavaStatement(block, it, isReferenced)
				}
				
				if (expr.precondition != null) {
					newLine
					append('''}''')
				}

			}
			CheckService: {
				for(validator : expr.services) {
					newLine
					append('''{''')
					
					newLine
					append('''com.github.jmodel.validation.api.ext.ExtValidator validator = com.github.jmodel.validation.api.ext.ExtValidatorProviderService.getInstance().getValidator("«validator.serviceName»");''')
					
					newLine
					append('''if (validator != null) {''')
										
					newLine
					append('''java.util.List<String> args = (java.util.List<String>)(serviceArgsMap.get("«validator.serviceName»"));''')
					
					newLine
					append('''ValidationResult extResult = validator.check(''')
					
					for(var i = 0; i < validator.argsCount; i++) {
						if(i == 0) {
							append('''args.get(«i»)''')						
						}else{
							append(''', args.get(«i»)''')
						}
					}
					append(''');''')	
					
					newLine
					append('''result.getMessages().addAll(extResult.getMessages());''')		
					
					newLine
					append('''}''')	
										
					newLine
					append('''}''')						
				}
				
			}
			ArgsSetting: {
				newLine
				append('''com.github.jmodel.validation.api.ValidationHelper.addArg(serviceArgsMap, "«expr.serviceName»", «expr.argIndex-1», ''')
				
				doInternalToJavaStatement((expr.arg as Arg).expression, it, isReferenced)
				
				append(''');''')
			}
			Block: {
				val fullModelPath = Util.getFullModelPath(expr)
				val m = declareUniqueNameVariable(fullModelPath + "_m", "m");

				newLine
				append('''{''')

				var String strModel
				var String strModelPath

				if (expr.eContainer instanceof Block) {

					// in a array path (not include self)
					if (Util.isInArrayPath(expr)) {

						// always can be found
						val lastArrayBlock = Util.getLastArrayBlock(expr)
						val lastArrayModelPath = Util.getFullModelPath(lastArrayBlock)

						val l_m = getName(lastArrayModelPath + "_m")
						if (lastArrayModelPath.equals(fullModelPath)) {
							strModel = '''model.getModelPathMap().get(«l_m»)'''
							strModelPath = '''«l_m»'''
						} else {
							val lastArrayModelPathAfter = fullModelPath.replace(lastArrayModelPath, "")
							strModel = '''model.getModelPathMap().get(«l_m» + "«lastArrayModelPathAfter»")'''
							strModelPath = '''«l_m»[0] + "«lastArrayModelPathAfter»"'''
						}
					} else {
						strModel = '''model.getModelPathMap().get("«fullModelPath»")'''
						strModelPath = '''"«fullModelPath»"'''
					}

				} else {
					// root model path
					strModel = '''model.getModelPathMap().get("«expr.modelPath»")'''
					strModelPath = '''"«expr.modelPath»"'''
				}

				// self is array
				if (Util.isArray(expr)) {
					val p = declareUniqueNameVariable(fullModelPath + "_p", "p")
					newLine
					append('''java.util.function.Predicate<String> «p» = null;''')

					if (expr.filter != null) {
						val f = declareUniqueNameVariable(fullModelPath + "_f", "f")

						newLine
						append('''«p» = (String «f») -> (''')
						doInternalToJavaStatement(expr.filter.expression, it,
							isReferenced)
						append(''');''')
					}

					newLine
					append('''com.github.jmodel.validation.api.ValidationHelper.arrayCheck(«strModel», «strModelPath», «p»,''')

					newLine
					append('''(String «m») ->''')

					newLine
					append('''{''')

				}

				for (blockContent : expr.blockContents) {
					doInternalToJavaStatement(blockContent.content, it, isReferenced)
				}

				// self is array
				if (Util.isArray(expr)) {
					newLine
					append('''});''')
				}

				newLine
				append('''}''')
			}
			Rule: {
				newLine
				append('''{''')
				doInternalToJavaStatement(expr.fieldPathIf, it, isReferenced)
				newLine
				append('''}''')

			}
			SingleFieldPath: {
				var String fieldValue = null;
				if (Util.isInPrecondition(expr)) {
					fieldValue = '''com.github.jmodel.api.ModelHelper.getFieldValue(model.getFieldPathMap().get("«expr.content»"))'''
				} else {
					val fullModelPath = Util.getFullModelPath(expr)
					if (Util.isArrayPath(expr)) {
						if (Util.isInFilter(expr)) {
							val f = getName(fullModelPath + "_f")
							fieldValue = '''com.github.jmodel.api.ModelHelper.getFieldValue(model.getFieldPathMap().get(«f» + ".«expr.content»"))'''
						} else {
							var String m = null
							if (expr.absolutePath != null) {
								val sourceModelPathByPath = Util.getSourceModelPathByPath(expr)
								m = getName(sourceModelPathByPath + "_m")
							} else {
								m = getName(fullModelPath + "_m")
							}
							fieldValue = '''com.github.jmodel.api.ModelHelper.getFieldValue(model.getFieldPathMap().get(«m» + ".«expr.content»"))'''
						}

					} else {
						fieldValue = '''com.github.jmodel.api.ModelHelper.getFieldValue(model.getFieldPathMap().get("«fullModelPath».«expr.content»"))'''
					}
				}
				
				switch(expr.dataType){
					case BOOL: {
					}
					case DATE: {
						if(expr.pattern != null) {
							append('''com.github.jmodel.api.ModelHelper.getDate(«fieldValue», "«expr.pattern»")''')
						}else {
							append('''com.github.jmodel.api.ModelHelper.getDate(«fieldValue»)''')
						}
					}
					case DEC: {
					}
					case INT: {
					}
					case LONG: {
					}
					default: {
						append('''String.valueOf(«fieldValue»)''')
					}					
				}				
				
				
			}
			FailedMessageSetting: {
				newLine
				append('''result.getMessages().add("«expr.message»");''')
			}
			Variable: {
				var String variableValue = '''myVariablesMap.get("«Util.getVariableName(expr.expression)»")''';
				switch(expr.dataType){
					case BOOL: {
					}
					case DATE: {
						if(expr.pattern != null) {
							append('''com.github.jmodel.api.ModelHelper.getDate(String.valueOf(«variableValue»), "«expr.pattern»")''')
						}else {
							append('''com.github.jmodel.api.ModelHelper.getDate(String.valueOf(«variableValue»))''')
						}
					}
					case DEC: {
					}
					case INT: {
					}
					case LONG: {
					}
					default: {
						append('''String.valueOf(«variableValue»)''')
					}					
				}				
			}
			XIfExpression: {
				newLine
				append("if (")
				doInternalToJavaStatement(expr.getIf(), it, isReferenced)
				append(") {").increaseIndentation()
				doInternalToJavaStatement(expr.getThen(), it, isReferenced)
				decreaseIndentation().newLine().append("}")
			}
			XBinaryOperation: {
				val operation = expr.getConcreteSyntaxFeatureName()
				if (Util.isPredict(operation)) {
					append('''(com.github.jmodel.api.ModelHelper.predict(''')
				} else {
					append('''(com.github.jmodel.api.ModelHelper.calc(''')
				}
				doInternalToJavaStatement(expr.leftOperand, it, isReferenced)
				append(''',''')
				if (operation.equals("in")) {
					append('''(java.util.List)(''')
					doInternalToJavaStatement(expr.rightOperand, it, isReferenced)
					append(''')''')
				} else {
					doInternalToJavaStatement(expr.rightOperand, it, isReferenced)
				}
				append(''',''')
				append('''«Util.operEnum(operation)», currentLocale''')
				append('''))''')
			}
			XStringLiteral: {
				append('''"«expr.value»"''')
			}
			XNumberLiteral: {
				append(expr.value)
			}
			XNullLiteral: {
				// always be used as comparable value
				append("(Comparable)null")
			}
			XBooleanLiteral: {
				append('''"«expr.isIsTrue()»"''')
			}
			default:
				super.doInternalToJavaStatement(expr, it, isReferenced)
		}
	}
}
