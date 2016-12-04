package com.github.jmodel.validation.api;

import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.ResourceBundle;
import java.util.function.Consumer;
import java.util.function.Predicate;

import com.github.jmodel.api.Entity;
import com.github.jmodel.api.IllegalException;
import com.github.jmodel.api.Model;
import com.github.jmodel.validation.api.ext.ExtValidator;
import com.github.jmodel.validation.api.ext.ExtValidatorProviderService;

public class ValidationHelper {

	public static ValidationService getService(String serviceName) {
		ResourceBundle messages = ResourceBundle.getBundle("com.github.jmodel.validation.api.MessagesBundle",
				Locale.getDefault());
		Class<?> mappingClz;
		try {
			mappingClz = Class.forName(serviceName);
			return (ValidationService) (mappingClz.newInstance());
		} catch (Exception e) {
			throw new IllegalException(messages.getString("V_IS_MISSING"));
		}
	}

	public static <T> void arrayCheck(final Model model, final String modelPath, final Predicate<String> p,
			final Consumer<T> c) {
		if (model == null) {
			return;
		}
		doIt(model, modelPath, p, c);
	}

	@SuppressWarnings("unchecked")
	private static <T> void doIt(final Model model, final String modelPath, final Predicate<String> p,
			final Consumer<T> c) {

		if (model instanceof Entity) {
			if (p != null && !p.test(modelPath)) {
				// not pass the condition
				return;
			}
			c.accept((T) modelPath);
		} else {
			List<Model> subModels = model.getSubModels();
			for (Model subModel : subModels) {
				doIt(subModel, subModel.getModelPath(), p, c);
			}
		}
	}
}
