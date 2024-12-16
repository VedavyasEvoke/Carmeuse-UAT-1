/**
* Class Name         : Ev_Contract_Review_ApproverSelector
* Developer          : D Sridhar           
* Created Date       : 18-04-2024
* @description       : This class is used to fetch Contract_Review_Approver__c records
* Last Modified Date : 
*/
public class Ev_Contract_Review_ApproverSelector {
    static Ev_Contract_Review_ApproverSelector instance;
    
    /**
* @description Creates and returns the instance of this class 
* @return Instance of this class
*/    
    public static Ev_Contract_Review_ApproverSelector getInstance() {
        if(instance == null) {
            instance = new Ev_Contract_Review_ApproverSelector();
        }
        return instance;
    }
    
    /**
* @description Fetches Contract_Review_Approver__c records w.r.t fields, filter etc.
* @param List of all parameters like fields, filter, child queries, etc.
* @return List of Contract_Review_Approver__c record
*/   
    public List<Contract_Review_Approver__c> getRecords(Map<String, Object> parameterMap) {
        List<String> fields = (List<String>)JSON.deserialize(JSON.serialize(parameterMap.get('fields')), List<String>.class);  //converting object to list of string
        String filter = (String)parameterMap.get('filter');
        
        if(fields != null && !fields.isEmpty()) {
            filter = (String.isBlank(filter)) ? '' : ('WHERE ' + filter);
                String query = 'SELECT ' + String.join(fields, ', ') + ' FROM Contract_Review_Approver__c ' + filter + ' ';
            return Database.query(query);
        }
        return null;
    }
}