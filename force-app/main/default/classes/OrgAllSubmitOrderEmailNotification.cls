/**********************************************************************************************************************************************
Author : Priyanka Shinde
Description :Send all orders submission mail to user who has added all order mail preferences.
-----------------------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 	  DATE 		   AUTHOR 			 DETAIL
1                         12/08/2022    Priyanka Shinde   Send all orders submission mail to user who has added all order mail preferences.
**********************************************************************************************************************************************/

public class OrgAllSubmitOrderEmailNotification {
    @InvocableMethod()
    public static void sendAllUserEmail(List<OrderSummary> lstOrderSummary){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();     
        Set<Id> ids = new Set<Id>(); 
        Set<Id> ownerIds = new Set<Id>();
        Map<Id,Id> mapOwnerIdWithOrderSummary = new Map<Id,Id>();
        Set<Id> setAccountIds = new Set<Id>();
        Map<Id,Id> mapAccountIsWithOwnerId = new Map<Id,Id>();
        Map<Id,String> mapAccountIdWithExternalMails = new Map<Id,String>();
        Map<Id, Id> mapOfAccountIdWithTargetId = new Map<Id, Id>();
        Map<Id,Id> mapAccountIdWithOrderSummary = new Map<Id,Id>();
        Map<Id,OrderSummary> mapOfAccIdAndOrderSummary = new Map<Id,OrderSummary>();
        Map<Id,Id> mapUserIdWithOrderSummary = new Map<Id,Id>();
        Map<Id,String> mapUserIdWithEmail = new Map<Id,String>();
        Map<Id,OrderSummary> mapOwnerIdWithOS = new Map<Id,OrderSummary>();
        Map<Id,OrderSummary> mapUserWithOS = new Map<Id,OrderSummary>();
        Set<Id> setAccountIdForExternalUser = new Set<Id>();
        Map<Id,Id> mapContactIdWithOSId = new Map<Id,Id>();
        Map<Id,String> mapContactIdWithEmail = new Map<Id,String>();
        
        String subject = 'Your order has been received.';
        String PortalURL = System.label.Portal_URL;
        String userTimeZone = UserInfo.getTimezone().toString();
        String formattedDate = ''; 
        
        for(OrderSummary objOrderSummary : lstOrderSummary){
            ids.add(objOrderSummary.Id);
            setAccountIdForExternalUser.add(objOrderSummary.AccountId);
            formattedDate = objOrderSummary.OrderedDate.format('EEE MMM d hh:mm:ss z yyyy',userTimeZone);
        }
        for(OrderSummary objOrderSummary : [SELECT Id,OwnerId,Owner.Name,OrderNumber,Account.Name,OrderedDate,OriginalOrderId FROM OrderSummary WHERE Id IN :ids]){
            ownerIds.add(objOrderSummary.OwnerId);
            mapOwnerIdWithOrderSummary.put(objOrderSummary.OwnerId,objOrderSummary.Id);
            mapOwnerIdWithOS.put(objOrderSummary.OwnerId,objOrderSummary);
            mapAccountIdWithOrderSummary.put(objOrderSummary.AccountId, objOrderSummary.Id);
            mapOfAccountIdWithTargetId.put(objOrderSummary.AccountId, objOrderSummary.OwnerId);
            mapOfAccIdAndOrderSummary.put(objOrderSummary.AccountId, objOrderSummary);
        }
        for(User objUser : [SELECT Id,AccountId FROM User WHERE Id IN :ownerIds ]){
            setAccountIds.add(objUser.AccountId);
            mapAccountIsWithOwnerId.put(objUser.AccountId,objUser.Id);
        }
        if(Test.isRunningTest()){
            User objUser = [SELECT Id,AccountId FROM User WHERE Id =: UserInfo.getUserId()];
            setAccountIds.add(objUser.AccountId);
            mapAccountIsWithOwnerId.put(objUser.AccountId,objUser.Id);            
        }
        if(!setAccountIds.isEmpty()){
            for(User objUser : [SELECT Id,AccountId,Email FROM User WHERE AccountId IN :setAccountIds AND Email_Preferences__c includes ('All Order Submission')]){
                if(mapAccountIsWithOwnerId.containsKey(objUser.AccountId)){
                    mapUserIdWithOrderSummary.put(objUser.Id,mapOwnerIdWithOrderSummary.get(mapAccountIsWithOwnerId.get(objUser.AccountId)));
                    mapUserIdWithEmail.put(objUser.Id,objUser.Email);
                    mapUserWithOS.put(objUser.Id,mapOwnerIdWithOS.get(mapAccountIsWithOwnerId.get(objUser.AccountId)));
                }
            }
        }

        for(Account objAccount : [SELECT Id, SPC_Email__c,Order_Submission_Emails__c FROM Account WHERE Id IN : setAccountIdForExternalUser]){
            String accountEmails = '';
            if(!String.isEmpty(objAccount.SPC_Email__c)){
                accountEmails += objAccount.SPC_Email__c; 
            }
            if(!String.isEmpty(objAccount.Order_Submission_Emails__c)){
                if(!String.isEmpty(accountEmails)){
                    accountEmails += ',';
                }
                accountEmails += objAccount.Order_Submission_Emails__c;
            }
            if(!String.isBlank(accountEmails)){
                mapAccountIdWithExternalMails.put(objAccount.Id, accountEmails);
            }  
        }     
        Messaging.Email[] messages = new Messaging.Email[0];
       // Send emails to the values stored in the account order submission emails.
        List<OrgWideEmailAddress> lstOrgWideEmailAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Displayname = 'No Reply MyCarmeuse' LIMIT 1];
        for(Id accountId : mapAccountIdWithOrderSummary.keySet()){ 
            OrderSummary objOS = mapOfAccIdAndOrderSummary.get(accountId);
            if(mapAccountIdWithExternalMails.get(accountId) != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String baseURL = '<a href="'+PortalURL+'/s/OrderSummary/'+objOS.Id+'">'+objOS.OrderNumber+'</a>';
                mail.setSubject(subject);
                mail.setHtmlBody('Hello '+objOS.Owner.Name+',<br><br> Thank you for placing your order. We are processing it.<br><br>Here are your order details<br><br>Order Placed For : '+objOS.Account.Name+'<br>Order Placed On : '+formattedDate+'<br>Order Summary Number : '+objOS.OrderNumber+'<br><br>Use your browser to track your order status using the link: '+baseURL+'<br><br>Thanks,<br>CARMEUSE');
                mail.setTreatTargetObjectAsRecipient(false); 
                mail.setTargetObjectId(mapOfAccountIdWithTargetId.get(accountId));
                mail.setOrgWideEmailAddressId(lstOrgWideEmailAddress[0].Id);  
                mail.setUseSignature(false);
                mail.setBccSender(false);
                mail.setSaveAsActivity(false);            
                mail.setWhatId(mapAccountIdWithOrderSummary.get(accountId));          
                mail.toAddresses = mapAccountIdWithExternalMails.get(accountId).split(',');
                emails.add(mail);
            }
            else{
                System.debug('Email ID is null');
            }
        }
        // Send email to the sibling users.
        for(Id userId : mapUserIdWithOrderSummary.keySet()){
            OrderSummary objOS = mapUserWithOS.get(userId);
            if(objOS != NULL){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String baseURL = '<a href="'+PortalURL+'/s/OrderSummary/'+objOS.Id+'">'+objOS.OrderNumber+'</a>';
                mail.setSubject(subject);
                mail.setHtmlBody('Hello '+objOS.Owner.Name+',<br><br> Thank you for placing your order. We are processing it.<br><br>Here are your order details<br><br>Order Placed For : '+objOS.Account.Name+'<br>Order Placed On : '+formattedDate+'<br>Order Summary Number : '+objOS.OrderNumber+'<br><br>Use your browser to track your order status using the link: '+baseURL+'<br><br>Thanks,<br>CARMEUSE');
                mail.setTargetObjectId(userId);
                mail.setOrgWideEmailAddressId(lstOrgWideEmailAddress[0].Id);  
                mail.setUseSignature(false);
                mail.setBccSender(false);              
                mail.setSaveAsActivity(false); 
                mail.setWhatId(mapUserIdWithOrderSummary.get(userId)); 
                mail.toAddresses = new String[] { mapUserIdWithEmail.get(userId) };
                    emails.add(mail);
            }
        } 
        Messaging.sendEmail(emails);
    }    
}