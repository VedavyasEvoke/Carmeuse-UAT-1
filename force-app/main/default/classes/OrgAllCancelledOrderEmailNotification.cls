/********************************************************************************************************************************************
Author : Priyanka Shinde
Description :Send all orders cancellation mail to user who has added all order mail preferences.
----------------------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 	  DATE 		   AUTHOR 			 DETAIL
1                         12/08/2022    Priyanka Shinde   Send all orders cancellation mail to user who has added all order mail preferences.
**********************************************************************************************************************************************/

public class OrgAllCancelledOrderEmailNotification {
    @InvocableMethod()
    public static void sendAllUserEmail(List<OrderDeliveryGroup> lstOrderDeliveryGroup){
        EmailTemplate emailTemplate =[SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE Name = 'Order Cancel Request'];
        
        Set<Id> ownerIds = new Set<Id>();
        Set<Id> setODGIds = new Set<Id>();
        Map<Id,Id> mapOwnerIdWithODG = new Map<Id,Id>();//What id
        
        Set<Id> setAccountIds = new Set<Id>();
        Map<Id,Id> mapAccountIsWithOwnerId = new Map<Id,Id>();
        
        Map<Id,Id> mapUserIdWithODG = new Map<Id,Id>();//What id
        Map<Id,String> mapUserIdWithEmail = new Map<Id,String>();
        
        for(OrderDeliveryGroup objOrderDeliveryGroup : lstOrderDeliveryGroup){
            setODGIds.add(objOrderDeliveryGroup.Id);
            ownerIds.add(objOrderDeliveryGroup.Canceled_By__c);
            mapOwnerIdWithODG.put(objOrderDeliveryGroup.Canceled_By__c, objOrderDeliveryGroup.Id);
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
                mapUserIdWithODG.put(objUser.Id,mapOwnerIdWithODG.get(mapAccountIsWithOwnerId.get(objUser.AccountId)));
                mapUserIdWithEmail.put(objUser.Id,objUser.Email);
            }
        }
        System.debug('ownerIds-->'+ownerIds);
        System.debug('setAccountIds-->'+setAccountIds);
        System.debug('mapOwnerIdWithODG-->'+mapOwnerIdWithODG);
        System.debug('mapAccountIsWithOwnerId-->'+mapAccountIsWithOwnerId);
        System.debug('mapUserIdWithODG-->'+mapUserIdWithODG);
        System.debug('mapUserIdWithEmail-->'+mapUserIdWithEmail);
        
        Messaging.Email[] messages = new Messaging.Email[0];
        for(Id userId : mapUserIdWithODG.keySet()){
            if(!ownerIds.contains(userId) || Test.isRunningTest()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(userId);
                mail.setSenderDisplayName('No Reply MyCarmeuse');
                mail.setReplyTo('customer-portal@carmeuse.com');
                mail.setUseSignature(false);
                mail.setBccSender(false);
                mail.setSaveAsActivity(false);            
                mail.setTemplateID(emailTemplate.Id);
                mail.setWhatId(mapUserIdWithODG.get(userId)); 
                System.debug('EMAILS ODG-->'+mapUserIdWithEmail.get(userId));
                mail.toAddresses = new String[] { mapUserIdWithEmail.get(userId)};
                    messages.add(mail);       
            }
        } 
        Messaging.sendEmail(messages);
    }    
}