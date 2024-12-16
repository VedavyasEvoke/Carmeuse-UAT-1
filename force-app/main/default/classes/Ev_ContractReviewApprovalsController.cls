/**
* Class Name         : Ev_ContractReviewApprovalsController
* Developer          : D Sridhar           
* Created Date       : 18-04-2024
* @description       : This class contains all the AuraEnabled methods of Ev_ContractReviewApprovals LWC and uses its Service class for executing complex logic 
* Last Modified Date : 
*/
public class Ev_ContractReviewApprovalsController {
    static Ev_ContractReviewApprovalsService Ev_ContractReviewApprovalsServiceInstance = Ev_ContractReviewApprovalsService.getInstance();
    
    /**
* @description Fetches a list of records w.r.t fields, filter etc.
* @param parameterMap JSON string containing all parameters like fields, filter, child queries, etc.
* @return List of Contract_Review_Approver__c records
*/ 
    @AuraEnabled
    public static List<Contract_Review_Approver__c> fetchApproverRecords(String parameters) {
        return Ev_ContractReviewApprovalsServiceInstance.fetchApproverRecords(parameters);
    }
}