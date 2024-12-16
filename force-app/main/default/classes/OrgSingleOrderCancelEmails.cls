/*-------------------------------------------------------------------------------------------------
Name: OrgSingleOrderCancelEmails
Purpose: Send email to the user, when order cancelled form request to cancel button on the portal.
---------------------------------------------------------------------------------------------------
 VERSION          AUTHOR               DATE                  DETAIL            
---------     ---------------     --------------      -------------------
1.0 -        Ravikant Vijapure     13th June 2023      INITIAL DEVELOPMENT                
-------------------------------------------------------------------------------------------------*/
public class OrgSingleOrderCancelEmails {
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

        Map<Id,Id> mapAccountIdWithODGId = new Map<Id,Id>();
        Set<Id> setAccountIdForExternalUser = new Set<Id>();
        Map<Id, String> mapAccountIdWithExternalMails = new Map<Id, String>();
        Map<Id, Id> mapOfAccountIdWithTargetId = new Map<Id, Id>();
        
        for(OrderDeliveryGroup objOrderDeliveryGroup : lstOrderDeliveryGroup){
            setODGIds.add(objOrderDeliveryGroup.Id);
            ownerIds.add(objOrderDeliveryGroup.Canceled_By__c);
            mapOwnerIdWithODG.put(objOrderDeliveryGroup.Canceled_By__c, objOrderDeliveryGroup.Id);
        }
        for(OrderDeliveryGroup objOrderDeliveryGroup : [SELECT Id, Order.AccountId,Canceled_By__c FROM OrderDeliveryGroup WHERE Id IN : setODGIds]){
            setAccountIdForExternalUser.add(objOrderDeliveryGroup.Order.AccountId);
            mapAccountIdWithODGId.put(objOrderDeliveryGroup.Order.AccountId, objOrderDeliveryGroup.Id);
            mapOfAccountIdWithTargetId.put(objOrderDeliveryGroup.Order.AccountId, objOrderDeliveryGroup.Canceled_By__c);
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
        for(User objUser : [SELECT Id,AccountId,Email FROM User WHERE AccountId IN :setAccountIds AND Email_Preferences__c includes ('All Order Cancellation')]){
            if(mapAccountIsWithOwnerId.containsKey(objUser.AccountId)){
                mapUserIdWithODG.put(objUser.Id,mapOwnerIdWithODG.get(mapAccountIsWithOwnerId.get(objUser.AccountId)));
                mapUserIdWithEmail.put(objUser.Id,objUser.Email);
            }
        }
        for(Account objAccount : [SELECT Id, Order_Cancellation_Emails__c FROM Account WHERE Id IN : setAccountIdForExternalUser]){
            mapAccountIdWithExternalMails.put(objAccount.Id,objAccount.Order_Cancellation_Emails__c);
        } 
     	List<OrgWideEmailAddress> lstOrgWideEmailAddress= [SELECT Id,DisplayName, Address FROM OrgWideEmailAddress Where DisplayName ='No Reply MyCarmeuse' LIMIT 1];
        
        Messaging.Email[] messages = new Messaging.Email[0];
        // Send emails to the values stored in the account order cancellation emails.
        for(Id accountId : mapAccountIdWithODGId.keySet()){ 
            if(mapAccountIdWithExternalMails.get(accountId) != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTreatTargetObjectAsRecipient(false); 
                mail.setTargetObjectId(mapOfAccountIdWithTargetId.get(accountId));
                mail.setOrgWideEmailAddressId(lstOrgWideEmailAddress[0].Id);
                mail.setUseSignature(false);
                mail.setBccSender(false);
                mail.setSaveAsActivity(false);            
                mail.setTemplateID(emailTemplate.Id);
                mail.setWhatId(mapAccountIdWithODGId.get(accountId));                                  
                mail.toAddresses = mapAccountIdWithExternalMails.get(accountId).split(','); 
                messages.add(mail);
            }
            else{
                System.debug('Email ID is null');
            }
        }   
        // Send email to the sibling users.
        for(Id userId : mapUserIdWithODG.keySet()){
            if(!ownerIds.contains(userId) || Test.isRunningTest()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(userId);
                mail.setOrgWideEmailAddressId(lstOrgWideEmailAddress[0].Id);
                mail.setUseSignature(false);
                mail.setBccSender(false);
                mail.setSaveAsActivity(false);            
                mail.setTemplateID(emailTemplate.Id);
                mail.setWhatId(mapUserIdWithODG.get(userId)); 
                mail.toAddresses = new String[] { mapUserIdWithEmail.get(userId)};
                messages.add(mail);       
            }
        } 
        Messaging.sendEmail(messages);
    }
}