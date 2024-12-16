/**
* Class Name         : Ev_ContractReviewApprovalsControllerTest
* Developer          : D Sridhar           
* Created Date       : 07-05-2024
* @description       : Test class for Ev_ContractReviewApprovalsController.
* Last Modified Date : 
*/
@isTest
public class Ev_ContractReviewApprovalsControllerTest {
    /**
* @description Test Data Setup.
*/ 
    @testsetup
    static void setup(){  
        TestDataFactory.createRecords('Contract_Review_Configuration__c', 1, true, new Map<String, Object>{
            'Plant_Name__c'=>'US-AN' });
        List<Contract_Review_Form__c> crfs = TestDataFactory.createRecords('Contract_Review_Form__c', 1, true,
                                                                           new Map<String, Object>{'Carmeuse_Plant__c'=>'US-AN'});
        TestDataFactory.createRecords('Contract_Review_Approver__c', 1, true, new Map<String, Object>{
            'Contract_Review_Form__c'=>crfs[0].Id, 'First_Name__c'=>'George', 'Last_Name__c'=>'McKotch',
                'Plant_Name__c'=>'US-AN', 'Role_Name__c'=>'Site Operations Manager' });
    }
    
    /**
* @description check if list of contract review approver records fetched.
*/ 
    @isTest
    static void fetchApproverRecordsTestMethod1(){
        List<Contract_Review_Form__c> crfs = [SELECT Id, (SELECT Id FROM Contract_Review_Approvers__r ) FROM Contract_Review_Form__c];
        Map<String, Object> parameterMap = new Map<String, Object>();
        parameterMap.put('recordId', crfs[0].Id);
        String parameters = JSON.serialize(parameterMap);
        Test.startTest();
        List<Contract_Review_Approver__c> cras = Ev_ContractReviewApprovalsController.fetchApproverRecords(parameters);
        Test.stopTest();
        Assert.isTrue(cras.size() == crfs[0].Contract_Review_Approvers__r.size(), 'Contract Review Approver Records fetched');
    }
}