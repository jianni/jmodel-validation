package com.github.jmodel.validatio.sample;

import com.github.jmodel.api.Model;
import com.github.jmodel.validation.api.Validation;
import com.github.jmodel.validation.api.ValidationResult;
import java.util.Locale;

@SuppressWarnings("all")
public class CreateTreaty extends Validation {
  private static Validation instance;
  
  public static synchronized Validation getInstance() {
    if (instance == null) {
    	instance = new com.github.jmodel.validatio.sample.CreateTreaty();
    	
    	instance.init(instance);
    }	
    
    return instance;
    
  }
  
  @Override
  public void init(final Validation myInstance) {
    super.init(myInstance);
    myInstance.setFormat(com.github.jmodel.api.FormatEnum.JSON);														
    
    com.github.jmodel.api.Entity rootModel = new com.github.jmodel.impl.EntityImpl();
    myInstance.setTemplateModel(rootModel);
    
    myInstance.getVocMap().put("checkBBB",com.github.jmodel.validation.api.ValidationHelper.getService("com.github.jmodel.validatio.sample.MyValidationService"));
    			
    
    
    myInstance.getRawFieldPaths().add("Treaty._");
    
    	myInstance.getRawFieldPaths().add("Treaty.EffectiveDate");
    myInstance.getRawFieldPaths().add("Treaty._");
    
    	myInstance.getRawFieldPaths().add("Treaty.EffectiveDate");
    	myInstance.getRawFieldPaths().add("Treaty.ExpiryDate");
    	myInstance.getRawFieldPaths().add("Treaty.PolicyCustomerList[].Customer.PartyCode");
    myInstance.getRawFieldPaths().add("Treaty.PolicyCustomerList[]._");
    
    	myInstance.getRawFieldPaths().add("Treaty.ExpiryDate");
    	myInstance.getRawFieldPaths().add("Treaty.PolicyCustomerList[].Customer.PartyCode");
    
    	myInstance.getRawFieldPaths().add("Treaty.Type");
    
  }
  
  @Override
  public void execute(final Model model, final ValidationResult result, final Locale currentLocale) {
    super.execute(model, result, currentLocale);
    {
    {
    if ((com.github.jmodel.api.ModelHelper.predict(model.getFieldPathMap().get("Treaty.EffectiveDate").getValue(),"2016-08-15",com.github.jmodel.api.OperationEnum.GT, currentLocale))) {
      result.getMessages().add("EffectiveDate is wrongxxx");
    }
    }
    }
    if((com.github.jmodel.api.ModelHelper.predict(model.getFieldPathMap().get("Treaty.Type").getValue(),"QuotaShare",com.github.jmodel.api.OperationEnum.EQUALS, currentLocale))) {
    {
    {
    if ((com.github.jmodel.api.ModelHelper.predict(model.getFieldPathMap().get("Treaty.EffectiveDate").getValue(),"2016-08-15",com.github.jmodel.api.OperationEnum.GT, currentLocale))) {
      result.getMessages().add("EffectiveDate is wrong");
    }
    }
    {
    java.util.function.Predicate<String> p = null;
    com.github.jmodel.validation.api.ValidationHelper.arrayCheck(model.getModelPathMap().get("Treaty.PolicyCustomerList[]"), "Treaty.PolicyCustomerList[]", p,
    (String m_2) ->
    {
    {
    if ((com.github.jmodel.api.ModelHelper.predict((com.github.jmodel.api.ModelHelper.predict(model.getFieldPathMap().get("Treaty.ExpiryDate").getValue(),"2017-08-21",com.github.jmodel.api.OperationEnum.EQUALS, currentLocale)),(com.github.jmodel.api.ModelHelper.predict(model.getFieldPathMap().get(m_2 + ".Customer.PartyCode").getValue(),"001265",com.github.jmodel.api.OperationEnum.EQUALS, currentLocale)),com.github.jmodel.api.OperationEnum.AND, currentLocale))) {
      result.getMessages().add("Party Code is wrong");
    }
    }
    });
    }
    }
    }
  }
}
