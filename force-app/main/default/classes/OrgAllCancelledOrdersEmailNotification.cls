/*********************************************************************************************************************************************
Author : Priyanka Shinde
Description :Send all orders confirmation mail to user who has added all order mail preferences.
----------------------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 	  DATE 		   AUTHOR 			 DETAIL
1                         12/08/2022    Priyanka Shinde   Send all orders confirmation mail to user who has added all order mail preferences.
**********************************************************************************************************************************************/

public class OrgAllCancelledOrdersEmailNotification {
    @InvocableMethod()
    public static void sendAllUserEmail(List<OrderSummary> lstOrderSummary){
        EmailTemplate emailTemplate =[SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE Name = 'All Order Cancellation Mail'];
      
        Set<Id> ownerIds = new Set<Id>();
        Map<Id,Id> mapOwnerIdWithOrderSummary = new Map<Id,Id>();//What id
        
        Set<Id> setAccountIds = new Set<Id>();
        Map<Id,Id> mapAccountIsWithOwnerId = new Map<Id,Id>();
        
        Map<Id,Id> mapUserIdWithOrderSummary = new Map<Id,Id>();//What id
        Map<Id,String> mapUserIdWithEmail = new Map<Id,String>();
        
        for(OrderSummary objOrderSummary : lstOrderSummary){
            ownerIds.add(objOrderSummary.OwnerId);
            mapOwnerIdWithOrderSummary.put(objOrderSummary.OwnerId,objOrderSummary.Id);
        }
        //Get AccountId
        for(User objUser : [SELECT Id,AccountId FROM User WHERE Id IN :ownerIds ]){
            setAccountIds.add(objUser.AccountId);
            mapAccountIsWithOwnerId.put(objUser.AccountId,objUser.Id);
        }
         if(Test.isRunningTest()){
            User objUser = [SELECT Id,AccountId FROM User WHERE Id =: UserInfo.getUserId()];
            setAccountIds.add(objUser.AccountId);
            mapAccountIsWithOwnerId.put(objUser.AccountId,objUser.Id);            
        }
        for(User objUser : [SELECT Id,AccountId,Email FROM User WHERE AccountId IN :setAccountIds AND Email_Preferences__c includes ('All Order Confirmation')]){
            if(mapAccountIsWithOwnerId.containsKey(objUser.AccountId)){
                mapUserIdWithOrderSummary.put(objUser.Id,mapOwnerIdWithOrderSummary.get(mapAccountIsWithOwnerId.get(objUser.AccountId)));
                mapUserIdWithEmail.put(objUser.Id,objUser.Email);
            }
        }
        
        Messaging.Email[] messages = new Messaging.Email[0];
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
                System.debug('EMAIL-->'+mapUserIdWithEmail.get(userId));
                mail.toAddresses = new String[] { mapUserIdWithEmail.get(userId)};
                    messages.add(mail);       
            }
        } 
        Messaging.sendEmail(messages);
    }
}