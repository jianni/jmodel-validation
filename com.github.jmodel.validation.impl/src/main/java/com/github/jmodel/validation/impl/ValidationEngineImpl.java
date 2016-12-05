package com.github.jmodel.validation.impl;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.regex.Pattern;

import org.apache.commons.lang3.StringUtils;

import com.github.jmodel.api.Analyzer;
import com.github.jmodel.api.AnalyzerFactoryService;
import com.github.jmodel.api.Array;
import com.github.jmodel.api.Entity;
import com.github.jmodel.api.Field;
import com.github.jmodel.api.IllegalException;
import com.github.jmodel.api.Model;
import com.github.jmodel.impl.ArrayImpl;
import com.github.jmodel.impl.EntityImpl;
import com.github.jmodel.impl.FieldImpl;
import com.github.jmodel.validation.api.Validation;
import com.github.jmodel.validation.api.ValidationEngine;
import com.github.jmodel.validation.api.ValidationResult;

public class ValidationEngineImpl implements ValidationEngine {

	protected ResourceBundle messages;

	protected static String NAME_PATTERN = "([a-zA-Z_][a-zA-Z\\d_]*\\.)*[a-zA-Z_][a-zA-Z\\d_]*";

	public <T> ValidationResult check(T sourceObj, String validationURI) {
		return check(sourceObj, validationURI, null, Locale.getDefault());
	}

	public <T> ValidationResult check(T sourceObj, String validationURI, Map<String, Object> argsMap) {
		return check(sourceObj, validationURI, argsMap, Locale.getDefault());
	}

	public <T> ValidationResult check(T sourceObj, String validationURI, Locale currentLocale) {
		return check(sourceObj, validationURI, null, Locale.getDefault());
	}

	public <T> ValidationResult check(T sourceObj, String validationURI, Map<String, Object> argsMap,
			Locale currentLocale) {

		messages = ResourceBundle.getBundle("com.github.jmodel.validation.api.MessagesBundle", currentLocale);

		if (validationURI == null || !Pattern.matches(NAME_PATTERN, validationURI)) {
			throw new IllegalException(messages.getString("V_NAME_IS_ILLEGAL"));
		}

		// TODO consider more loading mechanism later, local or remote
		Class<?> validationClz;
		try {
			validationClz = Class.forName(validationURI);
		} catch (ClassNotFoundException e) {
			throw new IllegalException(messages.getString("V_IS_MISSING"));
		}

		Validation validation;
		try {
			Method method = validationClz.getMethod("getInstance");
			validation = (Validation) (method.invoke(null));
		} catch (Exception e) {
			throw new IllegalException(messages.getString("V_IS_ILLEGAL"));
		}

		// check variables
		if (validation.getRawVariables().size() > 0) {
			if (argsMap == null || argsMap.size() == 0) {
				throw new IllegalException(messages.getString("V_NOT_FOUND"));
			}
			if (argsMap.keySet().parallelStream().filter(s -> validation.getRawVariables().contains(s)).count() == 0) {
				throw new IllegalException(messages.getString("V_NOT_FOUND"));
			}
		}

		AnalyzerFactoryService analyzerFactoryService = AnalyzerFactoryService.getInstance();
		Analyzer analyzer = analyzerFactoryService.getAnalyzer(validation.getFormat(), null);

		Model templateModel = validation.getTemplateModel();

		if (!validation.isTemplateReady()) {
			populateModel(templateModel, validation.getRawFieldPaths());
			validation.setTemplateReady(true);
		}

		Model sourceModel = analyzer.process(templateModel.clone(), sourceObj, false);
		ValidationResult result = new ValidationResult();
		Map<String, List<String>> serviceArgsMap = new HashMap<String, List<String>>();
		List<String> serviceList = validation.getServiceList();
		for (String service : serviceList) {
			serviceArgsMap.put(service, new ArrayList<String>());
		}
		validation.execute(sourceModel, serviceArgsMap, argsMap, result, currentLocale);
		if (result.getMessages().size() > 0) {
			result.setSuccess(false);
		} else {
			result.setSuccess(true);
		}
		return result;
	}

	@Override
	public ValidationResult checkByModel(Model model, String validationURI) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public ValidationResult checkByModel(Model model, String validationURI, Locale currentLocale) {
		// TODO Auto-generated method stub
		return null;
	}

	private void populateModel(final Model root, final List<String> fieldPaths) {
		final Map<String, Object> modelOrFieldMap = new HashMap<String, Object>();

		for (String fieldPath : fieldPaths) {

			String[] paths = fieldPath.split("\\.");

			String currentPath = "";
			String parentPath = "";

			for (int i = 0; i < paths.length - 1; i++) {

				if (parentPath.equals("")) {
					currentPath = paths[i];
				} else {
					currentPath = parentPath.replace("[]", "[0]") + "." + paths[i];
				}

				Model currentModel = (Model) modelOrFieldMap.get(currentPath);
				if (currentModel == null) {
					// create model object
					if (parentPath.equals("")) {
						currentModel = root;
					} else {
						if (paths[i].indexOf("[]") != -1) {
							currentModel = new ArrayImpl();
							currentModel.setName(StringUtils.substringBefore(paths[i], "[]"));
						} else {
							currentModel = new EntityImpl();
							currentModel.setName(paths[i]);
						}
					}
					if (currentModel.getName() == null) {
						currentModel.setName(paths[i]);
					}
					currentModel.setModelPath(currentPath);
					modelOrFieldMap.put(currentPath, currentModel);

					// if current Model is Array,create a existing entity
					if (currentModel instanceof Array) {
						Entity subEntity = new EntityImpl();
						String entityName = StringUtils.substringBefore(paths[i], "[]");
						subEntity.setName(entityName);
						currentPath = currentPath.replace("[]", "[0]");
						subEntity.setModelPath(currentPath);
						subEntity.setParentModel(currentModel);
						currentModel.getSubModels().add(subEntity);
						modelOrFieldMap.put(currentPath, subEntity);

					}

					// maintenence parent model relation
					Model parentModel = (Model) modelOrFieldMap.get(parentPath.replaceAll("\\[\\]", "\\[0\\]"));
					if (parentModel != null) {
						currentModel.setParentModel(parentModel);
						List<Model> subModelList = parentModel.getSubModels();
						if (subModelList == null) {
							subModelList = new ArrayList<Model>();
							parentModel.setSubModels(subModelList);
						}
						subModelList.add(currentModel);

					}

				}
				// set parentPath
				parentPath = currentPath;
			}

			// set field list
			String fieldName = paths[paths.length - 1];
			if (!fieldName.equals("_")) {
				currentPath = currentPath + "." + fieldName;
				Field currentField = (Field) modelOrFieldMap.get(currentPath);
				if (currentField == null) {
					currentField = new FieldImpl();
					currentField.setName(fieldName);
					modelOrFieldMap.put(currentPath, currentField);
					Entity currentModel = null;
					Object model = modelOrFieldMap.get(parentPath);
					if (model instanceof Entity) {
						currentModel = (Entity) model;
					} else if (model instanceof Array) {
						Array aModel = (Array) model;
						currentModel = (Entity) aModel.getSubModels().get(0);
					}
					List<Field> fieldList = currentModel.getFields();
					if (fieldList == null) {
						fieldList = new ArrayList<Field>();
						currentModel.setFields(fieldList);
					}
					fieldList.add(currentField);
				}
			}
		}
	}

}
