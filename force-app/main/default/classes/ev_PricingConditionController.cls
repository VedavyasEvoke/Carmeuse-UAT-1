/**
* Class Name         : Ev_PricingConditionController
* Developer          : D Sridhar           
* Created Date       : 13-03-2024
* @description       : This class contains all the AuraEnabled methods of Ev_PricingCondition LWC and uses its Service class for executing complex logic
* Last Modified Date : 13-03-2024
*/
public with sharing class ev_PricingConditionController {
    static ev_PricingConditionService ev_PricingConditionServiceInstance = ev_PricingConditionService.getInstance();
    
    /**
* @description Fetches all the fields from Pricing_Condition_Header_Fields fieldset of Quote
* @return Stringified JSON of the fieldset
*/
    @AuraEnabled
    public static String fetchQuotePricingConditionFieldset(String fieldSetName) {
        return ev_PricingConditionServiceInstance.fetchQuotePricingConditionFieldset(fieldSetName);
    }
    
    /**
* @description Fetches all the fields from Pricing_Condition_Header_Fields fieldset of Quote Line Item
* @return Stringified JSON of the fieldset
*/
    @AuraEnabled
    public static String fetchQliPricingConditionFieldset(String fieldSetName) {
        return ev_PricingConditionServiceInstance.fetchQliPricingConditionFieldset(fieldSetName);
    }
    
    /**
* @description Fetches a list of records w.r.t fields, filter, child queries, etc.
* @param parameterMap JSON string containing all parameters like fields, filter, child queries, etc.
* @return List of SBQQ__Quote__c records
*/
    @AuraEnabled
    public static List<SBQQ__Quote__c> fetchQuote(String parameters) {
        return ev_PricingConditionServiceInstance.fetchQuote(parameters);
    }
    
    /**
* @description Fetches a list of records w.r.t fields, filter, child queries, etc.
* @param parameterMap JSON string containing all parameters like fields, filter, child queries, etc.
* @return List of SBQQ__QuoteLine__c records
*/
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> fetchQLIsofQuote(String parameters) {
        return ev_PricingConditionServiceInstance.fetchQLIsofQuote(parameters);
    }
    
    /**
* @description Prepares a map of Plant Picklist Value and its Label.
* @return Map of Plant Picklist Value and its Label
*/
    @AuraEnabled
    public static Map<String,String> fetchPlantPicklistEntries() {
        return ev_PricingConditionServiceInstance.fetchPlantPicklistEntries();
    }
    
    /**
* @description Fetches a list of records w.r.t fields, filter, child queries, etc.
* @param parameterMap JSON string containing all parameters like fields, filter, child queries, etc.
* @return List of SalesOrg_By_Plant__c records
*/
    @AuraEnabled
    public static List<SalesOrg_By_Plant__c> fetchSalesOrgByPlant() {
        return ev_PricingConditionServiceInstance.fetchSalesOrgByPlant();
    }
    
    /**
* @description Fetches a list of records w.r.t fields, filter, child queries, etc.
* @param parameterMap JSON string containing all parameters like fields, filter, child queries, etc.
* @return List of Pricing_Category__c records grouped by some parameters
*/
    @AuraEnabled
    public static List<AggregateResult> fetchPricingCategories(String parameters) {
        return ev_PricingConditionServiceInstance.fetchPricingCategories(parameters, true);
    }
    
    /**
* @description Fetches a list of records w.r.t fields, filter, child queries, etc.
* @param parameterMap JSON string containing all parameters like fields, filter, child queries, etc.
* @return List of Pricing_Condition_Access__c records
*/
    @AuraEnabled
    public static List<Pricing_Condition_Access__c> fetchPCAs(String parameters) {
        return ev_PricingConditionServiceInstance.fetchPCAs(parameters);
    }
    
    /**
* @description Updates SBQQ__Quote__c record.
* @param quote SBQQ__Quote__c record which is to be updated.
* @return Status of the DML Operation
*/
    @AuraEnabled
    public static Boolean updateQuote(SBQQ__Quote__c quote) {
        return ev_PricingConditionServiceInstance.updateQuote(quote);
    }

    /**
* @description Updates SBQQ__QuoteLine__c records with Pricing Category information and prices.
* @param qlis List of SBQQ__QuoteLine__c records with updated Pricing Category information and prices
* @return Status of the DML Operation
*/
    @AuraEnabled
    public static Boolean updateQLIsWithPricingCategs(List<SBQQ__QuoteLine__c> qlis) {
        return ev_PricingConditionServiceInstance.updateQLIsWithPricingCategs(qlis);
    }
    
    /**
* @description Fetches a list of records w.r.t fields, filter, child queries, etc.
* @param parameterMap JSON string containing all parameters like fields, filter, child queries, etc.
* @return List of Pricing_Category__c records
*/
    @AuraEnabled
    public static List<Price_List__c> fetchPriceLists(String parameters) {
        return ev_PricingConditionServiceInstance.fetchPriceLists(parameters);
    }
}