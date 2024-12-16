/**
* Class Name         : ev_Price_ListSelector
* Developer          : D Sridhar           
* Created Date       : 24-05-2024
* @description       : This class is used for querying data of Price_List__c
* Last Modified Date : 
*/
public with sharing class ev_Price_ListSelector {
    static ev_Price_ListSelector instance = null;   //Instance of this class
    
    /**
* @description Creates and returns the instance of this class.
* @return Instance of this class
*/
    public static ev_Price_ListSelector getInstance() {
        if(instance == null) {
            instance = new ev_Price_ListSelector();
        }
        return instance;
    }
    
    /**
* @description Fetches Price_List__c records w.r.t fields, filter, child queries, etc.
* @param parameterMap Map of all parameters like fields, filter, child queries, etc.
* @return Map of Id and its Price_List__c record
*/
    public List<Price_List__c> fetchRecords(Map<String,Object> parameterMap) {
        List<String> fields = (List<String>)JSON.deserialize(JSON.serialize(parameterMap.get('fields')), List<String>.class);
        String filter = (String)parameterMap.get('filter') ;
        if(fields != null && !fields.isEmpty()) {
            filter = (filter != null) ? (' WHERE ' + filter) : '';  
            String query = 'SELECT ' + String.join(fields,',') + ' FROM Price_List__c ' + filter + ' ';
            try {
                System.debug('query==>'+query);
                return Database.query(query);
            }
            catch(Exception e) {
                throw new AuraHandledException(e.getMessage());   //Throws an exception
            }
        }
        return null;
    }
}