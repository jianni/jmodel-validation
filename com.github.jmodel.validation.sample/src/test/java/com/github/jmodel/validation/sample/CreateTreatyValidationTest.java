package com.github.jmodel.validation.sample;

import java.io.InputStream;
import java.util.List;

import com.github.jmodel.api.IllegalException;
import com.github.jmodel.validation.api.ValidationEngine;
import com.github.jmodel.validation.api.ValidationEngineFactoryService;
import com.github.jmodel.validation.api.ValidationResult;

public class CreateTreatyValidationTest {

	public static void main(String[] args) {
		// prepare an JSON input stream
		InputStream f = new CreateTreatyValidationTest().getClass().getResourceAsStream("sample.json");

		// json2json usage

		ValidationEngine vEngine = ValidationEngineFactoryService.getInstance().getEngine();
		try {
			
			ValidationResult result = vEngine.check(f, "com.github.jmodel.validatio.sample.CreateTreaty");
			List<String> msgs = result.getMessages();
			for (String msg : msgs) {
				System.out.println(msg);
			}
			
		} catch (IllegalException e) {
			e.printStackTrace();
		}

	}

}
