package com.github.jmodel.validation.spi.ext;

import com.github.jmodel.validation.api.ext.ExtValidator;

public interface ExtValidatorProvider {

	public ExtValidator getValidator(String validatorName);
}
