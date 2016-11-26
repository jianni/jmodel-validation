package com.github.jmodel.validation.impl;

import com.github.jmodel.validation.api.ValidationEngine;
import com.github.jmodel.validation.spi.ValidationEngineFactory;

public class ValidationEngineFactoryImpl implements ValidationEngineFactory {

	@Override
	public ValidationEngine getEngine() {
		return new ValidationEngineImpl();
	}
}
