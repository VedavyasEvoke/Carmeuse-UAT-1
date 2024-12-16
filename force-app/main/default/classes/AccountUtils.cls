/*---------------------------------------------------------------------------------------------------------------------------------------------
Author : Priyanka Shinde.
Description : Provides reusable utility methods for retrieving, validating, and managing Account-related data.
-----------------------------------------------------------------------------------------------------------------------------------------------
VERSION      ISSUE NUMBER 	     DATE 		    AUTHOR 			 				DETAIL
1.0          CARMEUSE-63       27/01/2023     Priyanka Shinde   	
1.1          CARMEUSE-180      22/10/2024    Ravikant Vijapure       Account invoice report issues resolved. 
-----------------------------------------------------------------------------------------------------------------------------------------------*/

public with sharing class AccountUtils {
    @testVisible 
    private static Boolean showException = false;

    //This method is used to get accounts with invoices in string format which is used in creating report in csv file.
    @AuraEnabled
    public static List<Id> getInvoicesWithDocuments(){
        Set<Id> setAccountInvoiceIds = new Set<Id>();
        List<ContentDocumentLink> lstContentDocumentLinks = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN ( SELECT Id FROM AccountInvoice__c WHERE AccountInvoiceRelation__r.B2B_Business_Sub_Unit__c != NULL AND CreatedDate >= LAST_N_DAYS:240 ) AND LinkedEntity.Type = 'AccountInvoice__c' LIMIT 49999];
        for(ContentDocumentLink links : lstContentDocumentLinks) {
            setAccountInvoiceIds.add(links.LinkedEntityId);
        }
                
        return new List<Id>(setAccountInvoiceIds);
    }
    
    //This method is used to return list of invoices, which is used in creating report in csv file.
    @AuraEnabled
    public static List<AccountInvoice__c> getAccountInvoices(List<Id> setIds, String fileType){
        Set<Id> setInvoiceIds = new Set<Id>();
        List<AccountInvoice__c> lstAccountInvoices = new List<AccountInvoice__c>();
        if(fileType == 'With Files') {
            lstAccountInvoices =  [SELECT Id,Name,Invoice_Number__c,AccountInvoiceRelation__c,InvoiceExternalAccountNumber__c,InvoiceDate__c FROM AccountInvoice__c WHERE Id IN : setIds];
        } else if(fileType == 'Without Files') {
            lstAccountInvoices = [SELECT Id, Name, Invoice_Number__c, AccountInvoiceRelation__c, InvoiceExternalAccountNumber__c, InvoiceDate__c FROM AccountInvoice__c WHERE AccountInvoiceRelation__r.B2B_Business_Sub_Unit__c != null AND CreatedDate >= LAST_N_DAYS:240 ORDER BY CreatedDate DESC LIMIT 49999];
        }
        
        if(!lstAccountInvoices.isEmpty()) {
             return lstAccountInvoices;
        } else {
            return new List<AccountInvoice__c>();
        }
    }
    
    //This method get the accounts that not placed any order in string format which is used in creating report in csv file.
    @AuraEnabled
    public static String getAccountNotPlacedOrder(){
        Set<Id> setOfAccount = new Set<Id>();
        Set<Id> setOfBoomiUser = new Set<Id>();
        Set<Id> setContactId = new Set<Id>();
        Set<Id> setProfileId = new Set<Id>();
        String details = 'Ship To Name\n'; 
        for(Profile objProfile : [SELECT Id FROM Profile WHERE Name='Boomi Integration User']){
            setProfileId.add(objProfile.Id);
        } 
        for(User objUser :[SELECT id, Username FROM User WHERE ProfileId IN : setProfileId]){
            setOfBoomiUser.add(objUser.Id);
        }
        
        for(User us: [SELECT id, Username, IsActive, contactid FROM user WHERE IsActive= true]){
            setContactId.add(us.ContactId);
        }
        for(Account acc : [SELECT Id,name From Account WHERE Id NOT IN (SELECT AccountId FROM Order WHERE OwnerId Not IN : setOfBoomiUser) AND Id IN (SELECT AccountId FROM Contact WHERE Id IN : setContactId )]){                     
            setOfAccount.add(acc.id);
            details += acc.Name+'\n';
        }
        return details;
    }
    
    //This method is used to get the details of account by passing accountId.
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountDetails(Id accountId){
        try{
            return [ SELECT Id, Name, AccountExternalNumber__c, Business_Unit__c, SPC_Email__c, B2B_Business_Sub_Unit__c FROM Account WHERE Id =: accountId LIMIT 1];      
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }   
}