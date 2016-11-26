package com.github.jmodel.validation.plugin.jvmmodel

import org.eclipse.xtext.xbase.XBinaryOperation
import org.eclipse.xtext.xbase.XBooleanLiteral
import org.eclipse.xtext.xbase.XExpression
import org.eclipse.xtext.xbase.XIfExpression
import org.eclipse.xtext.xbase.XNullLiteral
import org.eclipse.xtext.xbase.XNumberLiteral
import org.eclipse.xtext.xbase.XStringLiteral
import org.eclipse.xtext.xbase.compiler.XbaseCompiler
import org.eclipse.xtext.xbase.compiler.output.ITreeAppendable
import com.github.jmodel.validation.plugin.util.Util
import com.github.jmodel.validation.plugin.validationLanguage.Body
import com.github.jmodel.validation.plugin.validationLanguage.Check
import com.github.jmodel.validation.plugin.validationLanguage.Block
import com.github.jmodel.validation.plugin.validationLanguage.Rule
import com.github.jmodel.validation.plugin.validationLanguage.SingleFieldPath
import com.github.jmodel.validation.plugin.validationLanguage.FailedMessageSetting

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
				append('''super.execute(model, result, currentLocale);''')

				for (check : expr.checks) {
					doInternalToJavaStatement(check, it, isReferenced)
				}
			}
			Check: {
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

				for (rule : expr.rules) {
					doInternalToJavaStatement(rule, it, isReferenced)
				}

				for (block : expr.blocks) {
					doInternalToJavaStatement(block, it, isReferenced)
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
				if (Util.isInPrecondition(expr)) {
					append('''model.getFieldPathMap().get("«expr.content»").getValue()''')
				} else {
					val fullModelPath = Util.getFullModelPath(expr)
					if (Util.isArrayPath(expr)) {
						if (Util.isInFilter(expr)) {
							val f = getName(fullModelPath + "_f")
							append('''model.getFieldPathMap().get(«f» + ".«expr.content»").getValue()''')
						} else {
							var String m = null
							if (expr.absolutePath != null) {
								val sourceModelPathByPath = Util.getSourceModelPathByPath(expr)
								m = getName(sourceModelPathByPath + "_m")
							} else {
								m = getName(fullModelPath + "_m")
							}
							append('''model.getFieldPathMap().get(«m» + ".«expr.content»").getValue()''')
						}

					} else {
						append('''model.getFieldPathMap().get("«fullModelPath».«expr.content»").getValue()''')
					}
				}
			}
			FailedMessageSetting: {
				newLine
				append('''result.getMessages().add("«expr.message»");''')
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
