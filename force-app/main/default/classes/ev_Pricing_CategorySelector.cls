/**
* Class Name         : Ev_Pricing_CategorySelector
* Developer          : D Sridhar           
* Created Date       : 14-03-2024
* @description       : This class is used for querying data of Pricing_Category__c
* Last Modified Date : 
*/
public with sharing class ev_Pricing_CategorySelector {
    static ev_Pricing_CategorySelector instance = null;   //Instance of this class
    
    /**
* @description Creates and returns the instance of this class.
* @return Instance of this class
*/
    public static ev_Pricing_CategorySelector getInstance() {
        if(instance == null) {
            instance = new ev_Pricing_CategorySelector();
        }
        return instance;
    }
    
    /**
* @description Fetches Pricing_Category__c records w.r.t fields, filter, child queries, etc.
* @param parameterMap Map of all parameters like fields, filter, child queries, etc.
* @return Map of Id and its Pricing_Category__c record
*/
  /*  public Map<Id,Pricing_Category__c> fetchPricingCategories(Map<String,Object> parameterMap) {
        List<String> fields = (List<String>)JSON.deserialize(JSON.serialize(parameterMap.get('fields')), List<String>.class);
        String filter = (String)parameterMap.get('filter');
        System.debug('fields'+fields);
       // System.debug('fields'+fields);
        if(fields != null && !fields.isEmpty()) {
            filter = (filter != null) ? (' WHERE ' + filter) : '';  
            String query = 'SELECT ' + String.join(fields,',') + ' FROM Pricing_Category__c ' + filter + ' ';
            try {
                System.debug('Pricing Category ==> '+query); 
                List<Pricing_Category__c> records = Database.query(query);
                if(records != null) {
                    return new Map<Id,Pricing_Category__c>(records);
                }
            }
            catch(Exception e) {
                throw new AuraHandledException(e.getMessage());   //Throws an exception
            }
        }
        return null;
    }
    */
    /**
* @description Fetches Pricing_Category__c records w.r.t fields, filter, child queries, etc using Aggregate Query.
* @param parameterMap Map of all parameters like fields, filter, child queries, etc.
* @return Map of Id and its Pricing_Category__c record
*/
    public List<AggregateResult> fetchPricingCategories(Map<String,Object> parameterMap, Boolean isAggregateQuery) {
        List<String> fields = (List<String>)JSON.deserialize(JSON.serialize(parameterMap.get('fields')), List<String>.class);
        String filter = (String)parameterMap.get('filter');
        if(fields != null && !fields.isEmpty()) {
            filter = (filter != null) ? (' WHERE ' + filter) : '';  
            String query = 'SELECT ' + String.join(fields,',') + ' FROM Pricing_Category__c ' + filter;
            try {
                return Database.query(query);
            }
            catch(Exception e) {
                throw new AuraHandledException(e.getMessage());   //Throws an exception
            }
        }
        return null;
    }
}