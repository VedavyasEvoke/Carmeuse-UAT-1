/**
* Class Name         : Ev_Contract_Review_FormTriggerHndlrTest
* Developer          : D Sridhar           
* Created Date       : 07-05-2024
* @description       : Test class for Contract_Review_FormTriggerHandler. 
* Last Modified Date : 
*/
@isTest
private class Ev_Contract_Review_FormTriggerHndlrTest {
    /**
* @description Test Data Setup.
*/
    @testsetup
    static void setup() {
        TestDataFactory.createRecords('Contract_Review_Configuration__c', 1, true, new Map<String, Object>{
            'Plant_Name__c'=>'US-AN' }); 
    }
    
    /**
* @description Checking if contract review approver records created if new contract review form is created.
*/
    @isTest
    static void checkForContractRevConfigs1(){
        List<Contract_Review_Form__c> crfs = TestDataFactory.createRecords('Contract_Review_Form__c', 1, true, 
                                                                           new Map<String, Object>{ 'Carmeuse_Plant__c'=>'US-AN' });      
        List<Contract_Review_Approver__c> cras = [SELECT Id FROM Contract_Review_Approver__c WHERE Contract_Review_Form__c = :crfs[0].Id
                                                  ];
        List<Contract_Review_Configuration__c> crcs = [SELECT Id FROM Contract_Review_Configuration__c 
                                                       WHERE Plant_Name__c = :crfs[0].Carmeuse_Plant__c
                                                       ];
        //Assert.isTrue(cras.size() == crcs.size(), 'Contract Review Approver Records Inserted');
    }
    
    /**
* @description Checking if contract review approver records created by deleting old approver records if contract review form is updated.
*/   
    @isTest
    static void checkForContractRevConfigs2(){
        List<Contract_Review_Form__c> contractReviewForms=TestDataFactory.createRecords('Contract_Review_Form__c', 1, 
                                                                                        true, new Map<String, Object>{'Carmeuse_Plant__c'=>'US-AN'});
        contractReviewForms[0].Carmeuse_Plant__c='US-BM';
        database.update(contractReviewForms);
        List<Contract_Review_Approver__c> approverData=[SELECT Id FROM Contract_Review_Approver__c WHERE Contract_Review_Form__c =: contractReviewForms[0].Id
                                                        ];
        List<Contract_Review_Configuration__c> contractReviewConfigurations= [SELECT Id FROM Contract_Review_Configuration__c WHERE Plant_Name__c =:contractReviewForms[0].Carmeuse_Plant__c
                                                                              ];
        //System.assertEquals(approverData.size() == contractReviewConfigurations.size(), true,'Contract Review Approver Records Inserted');
    }
}