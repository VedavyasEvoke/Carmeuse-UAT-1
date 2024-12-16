/**
* Class Name         : Ev_Site_Visit_AssigneeSelector
* Developer          : D Sridhar           
* Created Date       : 16-03-2024
* @description       : This class is used for querying data of Site_Visit_Assignee__c
* Last Modified Date : 
*/
public with sharing class Ev_Site_Visit_AssigneeSelector {
    static Ev_Site_Visit_AssigneeSelector instance = null;   //Instance of this class
    
    /**
* @description Creates and returns the instance of this class.
* @return Instance of this class
*/
    public static Ev_Site_Visit_AssigneeSelector getInstance() {
        if(instance == null) {
            instance = new Ev_Site_Visit_AssigneeSelector();
        }
        return instance;
    }
    
    /**
* @description Fetches Site_Visit_Assignee__c records w.r.t fields, filter, child queries, etc.
* @param parameterMap Map of all parameters like fields, filter, child queries, etc.
* @return Map of Id and its Site_Visit_Assignee__c record
*/
    public List<Site_Visit_Assignee__c> fetchRecords(Map<String,Object> parameterMap) {
        List<String> fields = (List<String>)JSON.deserialize(JSON.serialize(parameterMap.get('fields')), List<String>.class);
        String filter = (String)parameterMap.get('filter') ;
        if(fields != null && !fields.isEmpty()) {
            filter = (filter != null) ? (' WHERE ' + filter) : '';  
            String query = 'SELECT ' + String.join(fields,',') + ' FROM Site_Visit_Assignee__c ' + filter;
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