/**
* Class Name         : Ev_SBQQ_QuoteSelector
* Developer          : D Sridhar           
* Created Date       : 13-03-2024
* @description       : This class is used for querying data of SBQQ__Quote__c
* Last Modified Date : 
*/
public with sharing class Ev_SBQQ_QuoteSelector {
    static Ev_SBQQ_QuoteSelector instance = null;   //Instance of this class
    
    /**
* @description Creates and returns the instance of this class.
* @return Instance of this class
*/
    public static Ev_SBQQ_QuoteSelector getInstance() {
        if(instance == null) {
            instance = new Ev_SBQQ_QuoteSelector();
        }
        return instance;
    }
    
    /**
* @description Fetches SBQQ__Quote__c records w.r.t fields, filter, child queries, etc.
* @param parameterMap Map of all parameters like fields, filter, child queries, etc.
* @return Map of Id and its SBQQ__Quote__c record
*/
    public List<SBQQ__Quote__c> getRecords(Map<String,Object> parameterMap) {
        List<String> fields = (List<String>)JSON.deserialize(JSON.serialize(parameterMap.get('fields')), List<String>.class);
        String filter = (String)parameterMap.get('filter') ;
        if(fields != null && !fields.isEmpty()) {
            filter = (filter != null) ? (' WHERE ' + filter) : '';  
            String query = 'SELECT ' + String.join(fields,',') + ' FROM SBQQ__Quote__c ' + filter + ' ';
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