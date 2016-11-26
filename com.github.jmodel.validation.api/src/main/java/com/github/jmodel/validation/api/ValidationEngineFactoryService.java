package com.github.jmodel.validation.api;

import java.util.Iterator;
import java.util.ServiceConfigurationError;
import java.util.ServiceLoader;

import com.github.jmodel.validation.spi.ValidationEngineFactory;

public class ValidationEngineFactoryService {

	private static ValidationEngineFactoryService service;
	private ServiceLoader<ValidationEngineFactory> loader;

	private ValidationEngineFactoryService() {
		loader = ServiceLoader.load(ValidationEngineFactory.class);
	}

	public static synchronized ValidationEngineFactoryService getInstance() {
		if (service == null) {
			service = new ValidationEngineFactoryService();
		}
		return service;
	}

	public ValidationEngine getEngine() {
		ValidationEngine engine = null;

		try {
			Iterator<ValidationEngineFactory> engineFactorys = loader.iterator();
			while (engine == null && engineFactorys.hasNext()) {
				ValidationEngineFactory engineFactory = engineFactorys.next();
				engine = engineFactory.getEngine();
			}
		} catch (ServiceConfigurationError serviceError) {
			engine = null;
			serviceError.printStackTrace();

		}
		return engine;
	}
}
