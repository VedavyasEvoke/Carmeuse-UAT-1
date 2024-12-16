/**
* Class Name         : SBQQ_QuoteLineSelector
* Developer          : D Sridhar           
* Created Date       : 13-03-2024
* @description       : This class is used for querying data of SBQQ__QuoteLine__c
* Last Modified Date : 
*/
public with sharing class ev_SBQQ_QuoteLineSelector {
    static ev_SBQQ_QuoteLineSelector instance = null;   //Instance of this class
    
    /**
* @description Creates and returns the instance of this class.
* @return Instance of this class
*/
    public static ev_SBQQ_QuoteLineSelector getInstance() {
        if(instance == null) {
            instance = new ev_SBQQ_QuoteLineSelector();
        }
        return instance;
    }
    
    /**
* @description Fetches SBQQ__QuoteLine__c records w.r.t fields, filter, child queries, etc.
* @param parameterMap Map of all parameters like fields, filter, child queries, etc.
* @return Map of Id and its SBQQ__QuoteLine__c record
*/
    public Map<Id,SBQQ__QuoteLine__c> fetchQLIs(Map<String,Object> parameterMap) {
        List<String> fields = (List<String>)JSON.deserialize(JSON.serialize(parameterMap.get('fields')), List<String>.class);
        String filter = (String)parameterMap.get('filter') ;
        if(fields != null && !fields.isEmpty()) {
            filter = (filter != null) ? (' WHERE ' + filter) : '';  
            String query = 'SELECT ' + String.join(fields,',') + ' FROM SBQQ__QuoteLine__c ' + filter + ' ';
            try {
                List<SBQQ__QuoteLine__c> records = Database.query(query);
                if(records != null) {
                    return new Map<Id,SBQQ__QuoteLine__c>(records);
                }
            }
            catch(Exception e) {
                throw new AuraHandledException(e.getMessage());   //Throws an exception
            }
        }
        return null;
    }
}