package com.github.jmodel.validation.api;

import java.util.List;
import java.util.Map;
import java.util.function.Consumer;
import java.util.function.Predicate;

import com.github.jmodel.api.Entity;
import com.github.jmodel.api.Model;

public class ValidationHelper {

	@SuppressWarnings("unchecked")
	public static void addArg(final Map<String, Object> serviceArgsMap, final String validatorName, final int index,
			String value) {
		Object serviceArgs = serviceArgsMap.get("checkAAA");
		if (serviceArgs == null) {
			return;
		}

		((List<String>) serviceArgs).add(index, value);
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
