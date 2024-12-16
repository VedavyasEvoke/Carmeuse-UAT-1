/**
* Class Name         : Ev_ContractReviewApprovalsService
* Developer          : D Sridhar           
* Created Date       : 18-04-2024
* @description       : This class is used to perform complex logic 
* Last Modified Date : 
*/
public class Ev_ContractReviewApprovalsService {
    static Ev_ContractReviewApprovalsService instance;
    static Ev_Contract_Review_ApproverSelector Ev_Contract_Review_ApproverSelectorInstance = Ev_Contract_Review_ApproverSelector.getInstance();    
    
    /**
* @description Creates and returns the instance of this class 
* @return Instance of this class
*/    
    public static Ev_ContractReviewApprovalsService getInstance() {
        if(instance == null) {
            instance = new Ev_ContractReviewApprovalsService();
        }
        return instance;
    }
    
    /**
* @description Fetches a list of records w.r.t fields, filter etc.
* @param parameterMap JSON string containing all parameters like fields, filter, child queries, etc.
* @return List of Contract_Review_Approver__c records 
*/
    public List<Contract_Review_Approver__c> fetchApproverRecords(String parameters) {
        Map<String, Object> parameterMap = (Map<String, Object>)JSON.deserializeUntyped(parameters);  //converting json string to map
        String recordId = (String)parameterMap.get('recordId');
        
        List<String> fields = new List<String>{'Id', 'CreatedDate', 'First_Name__c', 'Last_Name__c', 'Role_Name__c'};
            String filter = ' Contract_Review_Form__c = \'' + String.escapeSingleQuotes(recordId) + '\' '; 
        Map<String, Object> newParameterMap = new Map<String, Object>{'fields'=>fields, 'filter'=>filter};
            return Ev_Contract_Review_ApproverSelectorInstance.getRecords(newParameterMap);
    }
    
}