package com.github.jmodel.validation.api.ext;

import java.util.Iterator;
import java.util.ServiceConfigurationError;
import java.util.ServiceLoader;

import com.github.jmodel.validation.spi.ext.ExtValidatorProvider;

public class ExtValidatorProviderService {

	private static ExtValidatorProviderService service;
	private ServiceLoader<ExtValidatorProvider> loader;

	private ExtValidatorProviderService() {
		loader = ServiceLoader.load(ExtValidatorProvider.class);
	}

	public static synchronized ExtValidatorProviderService getInstance() {
		if (service == null) {
			service = new ExtValidatorProviderService();
		}
		return service;
	}

	public ExtValidator getValidator(String validatorName) {
		ExtValidator validator = null;

		try {
			Iterator<ExtValidatorProvider> validatorProviders = loader.iterator();
			while (validator == null && validatorProviders.hasNext()) {
				ExtValidatorProvider validatorProvider = validatorProviders.next();
				validator = validatorProvider.getValidator(validatorName);
			}
		} catch (ServiceConfigurationError serviceError) {
			validator = null;
			serviceError.printStackTrace();

		}
		return validator;
	}
}
