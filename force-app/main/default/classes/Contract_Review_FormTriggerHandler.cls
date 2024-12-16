/**
* Class Name         : Contract_Review_FormTriggerHandler
* Developer          : D Sridhar           
* Created Date       : 18-04-2024
* @description       : This class is used to handle trigger logic 
* Last Modified Date : 
*/
public with sharing class Contract_Review_FormTriggerHandler {
    
    /**
* @description Executes the method for after insert event
* @param newRecords List of new records
*/
    public static void afterInsert(List<sObject> newRecords) {
        checkForContractRevConfigs(newRecords);
    }
    
    /**
* @description Executes the method for after update event
* @param newRecords List of new records
*/
    public static void afterUpdate(List<sObject> newRecords) {
        checkForContractRevConfigs(newRecords);
    }
    
    /**
* @description Deletes the existing Contract Review Approver records of the newly inserted/modified Contract Review Form records
and creates new Contract Review Approver records for these inserted/modified Contract Review Form records based on the Plant field by fetching 
the Plant specific records from the Contract Review Configuration object
* @param newRecords List of new records
*/
    public static void checkForContractRevConfigs(List<sObject> newRecords) {
        Set<String> plantNamesSet = new Set<String>();
        Set<Id> crfIdSet = new Set<Id>();
        
        /* Collecting all the Plant Names - to retrieve related Contract_Review_Configuration__c records and Contract_Review_Form__c record Ids - to 
query for all its related Contract_Review_Approver_c records and delete them as we are anyway creating new Contract_Review_Approver_c 
records later */
        for(Contract_Review_Form__c crf : (List<Contract_Review_Form__c>)newRecords) {
            if(String.isNotBlank(crf.Carmeuse_Plant__c)) {
                plantNamesSet.add(crf.Carmeuse_Plant__c);
                crfIdSet.add(crf.Id);
            }
        }
        
        /* Querying all the related Contract_Review_Approver_c records and deleting them */        
        List<Contract_Review_Approver__c> deleteApprovers = [SELECT Id FROM Contract_Review_Approver__c WHERE Contract_Review_Form__c IN :crfIdSet WITH SECURITY_ENFORCED];
        if(!deleteApprovers.isEmpty()) {
            try {
                delete deleteApprovers;
            } catch(exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        /* Querying all the Contract_Review_Configuration__c records based on the PlantNames collected and creating a map with Plant Name as key and
a list of all the Contract_Review_Configuration__c records containing the same PlantName as value to the key */ 
        Map<String, List<Contract_Review_Configuration__c>> plantCrcMap = new Map<String, List<Contract_Review_Configuration__c>>();
        if(plantNamesSet.size() > 0) {
            for(Contract_Review_Configuration__c crc : [SELECT Id, Plant_Name__c, First_Name__c, Last_Name__c, Role_Name__c, User_ID__c FROM Contract_Review_Configuration__c 
                                                        WHERE Plant_Name__c != null AND Plant_Name__c IN :plantNamesSet WITH SECURITY_ENFORCED]) {
                List<Contract_Review_Configuration__c> existingCrcs = new List<Contract_Review_Configuration__c>();
                if(plantCrcMap.containsKey(crc.Plant_Name__c)) {
                    existingCrcs = plantCrcMap.get(crc.Plant_Name__c);
                }
                existingCrcs.add(crc);
                plantCrcMap.put(crc.Plant_Name__c, existingCrcs);
            }
        }
        
        /* Looping through all the Contract_Review_Form__c records so as to get all the Contract_Review_Configuration__c records 
based on the PlantName with the help of the previously created map. Then we loop through all the Contract_Review_Configuration__c records to
create Contract_Review_Approver__c record from each Contract_Review_Configuration__c record and link it to the Contract_Review_Form__c record */ 
        List<Contract_Review_Approver__c> approvers = new List<Contract_Review_Approver__c>();
        for(Contract_Review_Form__c crf : (List<Contract_Review_Form__c>)newRecords) {
            if(String.isNotBlank(crf.Carmeuse_Plant__c) && plantCrcMap.containsKey(crf.Carmeuse_Plant__c)) {
                for(Contract_Review_Configuration__c crc: plantCrcMap.get(crf.Carmeuse_Plant__c)) {
                    Contract_Review_Approver__c cra = new Contract_Review_Approver__c();
                    cra.First_Name__c =crc.First_Name__c ;
                    cra.Last_Name__c = crc.Last_Name__c;
                    cra.Plant_Name__c = crc.Plant_Name__c;
                    cra.Role_Name__c = crc.Role_Name__c;
                    cra.User_ID__c = crc.User_ID__c;
                    cra.Contract_Review_Form__c = crf.Id;
                    approvers.add(cra);
                }
            }
        }
        if(!approvers.isEmpty()) {
            try {
                insert approvers;
            } catch(exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
    }
}