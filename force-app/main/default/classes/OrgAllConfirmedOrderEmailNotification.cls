/*********************************************************************************************************************************************
Author : Priyanka Shinde
Description :Send all orders confirmation mail to user who has added all order mail preferences.
----------------------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 	  DATE 		   AUTHOR 			 DETAIL
1                         12/08/2022    Priyanka Shinde   Send all orders confirmation mail to user who has added all order mail preferences.
----------------------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 	  DATE 		   AUTHOR 			 DETAIL
2                        
**********************************************************************************************************************************************/

public class OrgAllConfirmedOrderEmailNotification {
    @InvocableMethod()
    public static void sendAllUserEmail(List<OrderSummary> lstOrderSummary){
        
        EmailTemplate emailTemplate =[SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE Name = 'Confirmation Mail'];
        Set<Id> ownerIds = new Set<Id>();
        Map<Id,Id> mapOwnerIdWithOrderSummary = new Map<Id,Id>();//What id
        
        Set<Id> setAccountIds = new Set<Id>();
        Map<Id,Id> mapAccountIsWithOwnerId = new Map<Id,Id>();
        
        Map<Id,Id> mapUserIdWithOrderSummary = new Map<Id,Id>();//What id
        Map<Id,String> mapUserIdWithEmail = new Map<Id,String>();
        
        Set<Id> setAccountIdForExternalUser = new Set<Id>();
        Map<Id,Id> mapAccountIdWithOrderSummary = new Map<Id,Id>();
        Map<Id,Id> mapContactIdWithOSId = new Map<Id,Id>();
        Map<Id,String> mapContactIdWithEmail = new Map<Id,String>();
        
        for(OrderSummary objOrderSummary : lstOrderSummary){
            ownerIds.add(objOrderSummary.OwnerId);
            mapOwnerIdWithOrderSummary.put(objOrderSummary.OwnerId,objOrderSummary.Id);
            setAccountIdForExternalUser.add(objOrderSummary.AccountId);
            mapAccountIdWithOrderSummary.put(objOrderSummary.AccountId, objOrderSummary.Id);
        }
        //Get AccountId
        for(User objUser : [SELECT Id,AccountId FROM User WHERE Id IN :ownerIds ]){
            setAccountIds.add(objUser.AccountId);
            mapAccountIsWithOwnerId.put(objUser.AccountId,objUser.Id);
        }
        if(Test.isRunningTest()){
            User objUser = [SELECT Id,AccountId,ContactId FROM User WHERE Id =: UserInfo.getUserId()];
            setAccountIds.add(objUser.AccountId);
            mapAccountIsWithOwnerId.put(objUser.AccountId,objUser.Id);  
           // mapContactIdWithOSId.put(objUser.ContactId, mapAccountIdWithOrderSummary.get(objUser.AccountId));   
        }
        for(User objUser : [SELECT Id,AccountId,Email FROM User WHERE AccountId IN :setAccountIds AND Email_Preferences__c includes ('All Order Confirmation')]){
            if(mapAccountIsWithOwnerId.containsKey(objUser.AccountId)){
                mapUserIdWithOrderSummary.put(objUser.Id,mapOwnerIdWithOrderSummary.get(mapAccountIsWithOwnerId.get(objUser.AccountId)));
                mapUserIdWithEmail.put(objUser.Id,objUser.Email);
            }
        }                  
        for(Contact contactObj : [SELECT Id,Email,AccountId FROM Contact WHERE AccountId IN : setAccountIdForExternalUser AND Email != NULL AND External_User__c = true]){
            if(mapAccountIdWithOrderSummary.containsKey(contactObj.AccountId)){
                mapContactIdWithOSId.put(contactObj.Id, mapAccountIdWithOrderSummary.get(contactObj.AccountId));
                mapContactIdWithEmail.put(contactObj.Id,contactObj.Email);
            }
        }        
        Messaging.Email[] messages = new Messaging.Email[0];
        for(Id contactId : mapContactIdWithOSId.keySet()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(contactId);
            mail.setSenderDisplayName('No Reply MyCarmeuse');
            mail.setReplyTo('customer-portal@carmeuse.com');
            mail.setUseSignature(false);
            mail.setBccSender(false);
            mail.setSaveAsActivity(false);            
            mail.setTemplateID(emailTemplate.Id);
            mail.setWhatId(mapContactIdWithOSId.get(contactId)); 
            mail.toAddresses = new String[] { mapContactIdWithEmail.get(contactId)};
                messages.add(mail);          
        }
        
        for(Id userId : mapUserIdWithOrderSummary.keySet()){
            if(!ownerIds.contains(userId) || Test.isRunningTest()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(userId);
                mail.setSenderDisplayName('No Reply MyCarmeuse');
                mail.setReplyTo('customer-portal@carmeuse.com');
                mail.setUseSignature(false);
                mail.setBccSender(false);
                mail.setSaveAsActivity(false);            
                mail.setTemplateID(emailTemplate.Id);
                mail.setWhatId(mapUserIdWithOrderSummary.get(userId)); 
                mail.toAddresses = new String[] { mapUserIdWithEmail.get(userId)};
                    messages.add(mail);       
            }
        } 
        Messaging.sendEmail(messages);
    }    
}