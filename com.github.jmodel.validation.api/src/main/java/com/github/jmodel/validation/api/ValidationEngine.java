package com.github.jmodel.validation.api;

import java.util.Locale;
import java.util.Map;

import com.github.jmodel.api.Model;

public interface ValidationEngine {

	public <T> ValidationResult check(T sourceObj, String validationURI);

	public <T> ValidationResult check(T sourceObj, String validationURI, Map<String, Object> argsMap);

	public <T> ValidationResult check(T sourceObj, String validationURI, Locale currentLocale);

	public <T> ValidationResult check(T sourceObj, String validationURI, Map<String, Object> argsMap,
			Locale currentLocale);

	public ValidationResult checkByModel(Model model, String validationURI);

	public ValidationResult checkByModel(Model model, String validationURI, Locale currentLocale);

}
