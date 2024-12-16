/**
* Class Name         : ev_SalesOrg_By_PlantSelector
* Developer          : D Sridhar           
* Created Date       : 15-04-2024
* @description       : This class is used for querying data of SalesOrg_By_Plant__c
* Last Modified Date : 
*/
public with sharing class ev_SalesOrg_By_PlantSelector {
    static ev_SalesOrg_By_PlantSelector instance = null;   //Instance of this class
    
    /**
* @description Creates and returns the instance of this class.
* @return Instance of this class
*/
    public static ev_SalesOrg_By_PlantSelector getInstance() {
        if(instance == null) {
            instance = new ev_SalesOrg_By_PlantSelector();
        }
        return instance;
    }
    
    /**
* @description Fetches SalesOrg_By_Plant__c records w.r.t fields, filter, child queries, etc.
* @param parameterMap Map of all parameters like fields, filter, child queries, etc.
* @return Map of Id and its SalesOrg_By_Plant__c record
*/
    public Map<Id,SalesOrg_By_Plant__c> fetchQLIs(Map<String,Object> parameterMap) {
        List<String> fields = (List<String>)JSON.deserialize(JSON.serialize(parameterMap.get('fields')), List<String>.class);
        String filter = (String)parameterMap.get('filter') ;
        if(fields != null && !fields.isEmpty()) {
            filter = (filter != null) ? (' WHERE ' + filter) : '';  
            String query = 'SELECT ' + String.join(fields,',') + ' FROM SalesOrg_By_Plant__c ' + filter + ' ';
            try {
                List<SalesOrg_By_Plant__c> records = Database.query(query);
                if(records != null) {
                    return new Map<Id,SalesOrg_By_Plant__c>(records);
                }
            }
            catch(Exception e) {
                throw new AuraHandledException(e.getMessage());   //Throws an exception
            }
        }
        return null;
    }
}