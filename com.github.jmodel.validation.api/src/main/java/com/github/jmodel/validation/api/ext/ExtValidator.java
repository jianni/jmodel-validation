package com.github.jmodel.validation.api.ext;

import com.github.jmodel.validation.api.ValidationResult;

public interface ExtValidator {

	public ValidationResult check(String... args);

}
