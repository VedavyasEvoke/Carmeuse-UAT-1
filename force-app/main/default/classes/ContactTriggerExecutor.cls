/*----------------------------------------------------------------------
Name:       ContactTriggerExecutor.cls
Purpose:    Use to enable contact as user when contact is created by Portal.
------------------------------History----------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          ------------------
1.0         Priyanka         15-Feb-2022           Initial Development 
----------------------------------------------------------------------*/
public  without sharing class ContactTriggerExecutor implements TriggerExecutor_I {
    
    public Schema.SObjectType getSObjectType() {
        return Contact.SObjectType;
    }	
    
    public void beforeInsert(List<Contact> triggerNew) {
        //If email exists in org, we are giving an error.
        List<Contact> contactList = new List<Contact>();
        List<User> userList = new List<User>();
        Set<Id> userId = new Set<Id>();
        Set<Id> userRoleId = new Set<Id>();
        Set<Id> customerPortalUser = new Set<Id>();
        Map<Id,User> parentPortalUser = new Map<Id,User>();
        Set<String> allEmail = new Set<String>();
        Set<String> existingUserName = new Set<String>();
        for(UserRole role : [Select Id From UserRole Where PortalType = 'CustomerPortal']){
            userRoleId.add(role.Id);
        }
        for(Contact contact : triggerNew) {
            // Evoke added contact.Profile__c check so the below code excecutes only to portal users
            if(contact.Email != NULL && contact.Profile__c != null){
                allEmail.add(contact.Email);                
                userId.add(UserInfo.getUserId());
                contactList.add(contact); 
            }            
        }
        // Evoke Added null check for allEmail
        if(!allEmail.isEmpty()){
        for(User user : [SELECT Id,Username FROM User WHERE Username IN: allEmail]) {
            existingUserName.add(user.Username);
        }
        }
         // Evoke Added null check for UserId
        if(!userId.isEmpty()){
        for(User user : [SELECT Id,ProfileId,languagelocalekey,localesidkey,TimezoneSidKey FROM User WHERE Id IN : userId AND UserRoleId IN : userRoleId]) {
            customerPortalUser.add(user.Id);
            parentPortalUser.put(user.Id,user);
        }
        }
        for(Contact contact : contactList){
            if(customerPortalUser.size() > 0 && customerPortalUser.contains(UserInfo.getUserId()) == TRUE ){
                if(existingUserName.contains(contact.Email)){
                    contact.addError('User with same username detected');
                }
            }
        }
        
    }
    
    public void beforeUpdate(Map<Id, SObject> triggerOldMap, List<Contact> triggerNew) {
    }
    
    public void beforeDelete(List<Contact> triggerOld) {
    }
    
    public void afterInsert(List<Contact> triggerNew) {
        //This method create a user, when contact is created from portal.
        List<Contact> contactList = new List<Contact>();
        List<User> userList = new List<User>();
        Set<Id> userId = new Set<Id>();
        Set<Id> userRoleId = new Set<Id>();
        Set<Id> customerPortalUser = new Set<Id>();
        Map<Id,User> parentPortalUser = new Map<Id,User>();
        Set<String> profileName = new Set<String>();
        Map<String,Id> profileNameWithId = new Map<String,Id>();
        
        for(UserRole role : [Select Id From UserRole Where PortalType = 'CustomerPortal']){
            userRoleId.add(role.Id);
        }
        for(Contact contact : triggerNew) {
            // Evoke added contact.Profile__c check so the below code excecutes only to portal users
            if(contact.Email != NULL && contact.Profile__c != NULL){
                userId.add(contact.createdById);
                contactList.add(contact);
                if(contact.Profile__c != NULL){
                    profileName.add(contact.Profile__c);
                } 
                
            }            
        }
        // Evoke Added null check for profileName
        if(!profileName.isEmpty()){
        for(Profile profileObj : [SELECT Id,Name FROM Profile WHERE Name IN : profileName]) {
            profileNameWithId.put(profileObj.Name,profileObj.Id);
        }
        }
        // Evoke Added null check for UserId
        if(!userId.isEmpty()){
        for(User user : [SELECT Id,ProfileId,languagelocalekey,localesidkey,TimezoneSidKey FROM User WHERE Id IN : userId AND UserRoleId IN : userRoleId]) {
            customerPortalUser.add(user.Id);
            parentPortalUser.put(user.Id,user);
        }
        }
        for(Contact contact : contactList){
            if(customerPortalUser.size() > 0 && customerPortalUser.contains(contact.createdById) == TRUE ){
                User parentUser = parentPortalUser.get(contact.createdById);
                User objUser = new User();
                objUser.ContactId = contact.Id;
                objUser.ProfileId = profileNameWithId.get(contact.Profile__c);
                objUser.IsActive  = TRUE;    
                objUser.Email=contact.Email;
                objUser.Username = contact.Email;
                objUser.Lastname=contact.LastName;
                string alias = '';
                string nickname = '';
                if(contact.FirstName != NULL){
                    objUser.Firstname=contact.FirstName;
                    alias += contact.FirstName;
                   // nickname += contact.FirstName+' ';
                }
                if(contact.Title != NULL){
                    objUser.Title=contact.Title;
                }
                alias += contact.LastName;
                //nickname += contact.LastName;               
                if(alias.length() > 8){
                    alias = alias.substring(0, 7);
                }
                if(contact.MiddleName != NULL){
                    objUser.MiddleName=contact.MiddleName;
                }
                //Evoke Just commented Suffix for removing in UI Level
               /* if(contact.Suffix != NULL){
                    objUser.Suffix=contact.Suffix;
                }*/
                if(contact.Phone != NULL){
                    objUser.Phone=contact.Phone;
                }
                if(contact.Fax != NULL){
                    objUser.Fax=contact.Fax;
                }
                if(contact.MobilePhone != NULL){
                    objUser.MobilePhone=contact.MobilePhone;
                }
                if(contact.MailingStreet != NULL){
                    objUser.Street=contact.MailingStreet;
                }
                if(contact.MailingCity != NULL){
                    objUser.City=contact.MailingCity;
                }
                if(contact.MailingPostalCode != NULL){
                    objUser.PostalCode=contact.MailingPostalCode;
                }
                if(contact.MailingState != NULL){
                    objUser.State=contact.MailingState;
                }
                if(contact.MailingCountry != NULL){
                    objUser.Country=contact.MobilePhone;
                }
                if(contact.Department != NULL){
                    objUser.Department=contact.Department;
                }
                objUser.Alias = alias;
               // objUser.CommunityNickname = nickname;               
                objUser.EmailEncodingKey='UTF-8';
                objUser.LanguageLocaleKey=parentUser.languagelocalekey;
                objUser.LocaleSidKey=parentUser.localesidkey;
                objUser.TimeZoneSidKey=parentUser.TimezoneSidKey;
                userList.add(objUser); 
            }            
        }
        if(userList.size() > 0){
            insert userList;
        }        
    }
    
    public void afterUpdate(Map<Id, SObject> triggerOldMap, List<Contact> triggerNew) {
        
    }
    
    public void afterDelete(List<Contact> triggerOld) {
        
    }
}