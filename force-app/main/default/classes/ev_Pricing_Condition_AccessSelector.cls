/**
* Class Name         : SBQQ_QuoteLineSelector
* Developer          : D Sridhar           
* Created Date       : 29-03-2024
* @description       : This class is used for querying data of Pricing_Condition_Access__c
* Last Modified Date : 
*/
public with sharing class ev_Pricing_Condition_AccessSelector {
    static ev_Pricing_Condition_AccessSelector instance = null;   //Instance of this class
    
    /**
* @description Creates and returns the instance of this class.
* @return Instance of this class
*/
    public static ev_Pricing_Condition_AccessSelector getInstance() {
        if(instance == null) {
            instance = new ev_Pricing_Condition_AccessSelector();
        }
        return instance;
    }
    
    /**
* @description Fetches Pricing_Condition_Access__c records w.r.t fields, filter, child queries, etc.
* @param parameterMap Map of all parameters like fields, filter, child queries, etc.
* @return Map of Id and its Pricing_Condition_Access__c record
*/
    public Map<Id,Pricing_Condition_Access__c> fetchPCAs(Map<String,Object> parameterMap) {
        List<String> fields = (List<String>)JSON.deserialize(JSON.serialize(parameterMap.get('fields')), List<String>.class);
        String filter = (String)parameterMap.get('filter') ;
        String orderby = (String)parameterMap.get('orderby') ;
        if(fields != null && !fields.isEmpty()) {
            filter = (filter != null) ? (' WHERE ' + filter) : '';
            orderby = (orderby != null) ? orderby : '';  
            String query = 'SELECT ' + String.join(fields,',') + ' FROM Pricing_Condition_Access__c ' + filter + ' ' + orderby;
            try {
                List<Pricing_Condition_Access__c> records = Database.query(query);
                if(records != null) {
                    return new Map<Id,Pricing_Condition_Access__c>(records);
                }
            }
            catch(Exception e) {
                throw new AuraHandledException(e.getMessage());   //Throws an exception
            }
        }
        return null;
    }
}