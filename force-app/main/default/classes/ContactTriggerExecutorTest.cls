@isTest(SeeAllData=true)
public class ContactTriggerExecutorTest {
    @IsTest
    static void testContactCreation() {
        test.startTest();
        UserRole role = [Select Id From UserRole Where PortalType = 'CustomerPortal' LIMIT 1];
        Profile profileObj = [SELECT Id,Name FROM Profile WHERE Name = 'Level 4 – Access to Level 1, Level 2 & Delegated Admin' LIMIT 1];
        User user = [SELECT Id,ContactId,ProfileId FROM User WHERE IsPortalEnabled = TRUE AND IsActive = TRUE AND ProfileId =: profileObj.Id LIMIT 1];
        Contact parentContact = [SELECT AccountId FROM Contact WHERE Id =: user.ContactId];  
        System.runAs(user) { 
            List<Contact> lstContacts = new List<Contact>();
            for(Integer i = 0 ; i < 100 ; i++){
                Contact objContact = new Contact();
                objContact.Lastname= 'usertesting'+i;
                objContact.AccountId = parentContact.AccountId;
                objContact.FirstName = 'FirstNameTest'+i;
                objContact.Email='contactusertesting@test1.com'+i;
                objContact.Profile__c='Level 1 – Access to Order Placing and Order History';
                objContact.Fax = 'test';
                objContact.MailingCity = 'test';
                objContact.MailingCountry = 'test';
                objContact.MailingPostalCode = '123';
                objContact.MailingState = 'test';
                objContact.MailingStreet = 'test';
                objContact.Department = 'test';
                objContact.Title = 'test';
                objContact.MobilePhone ='123';
                 //Evoke Just commented Suffix for removing in UI Level
                //objContact.Suffix ='test';
                objContact.MiddleName ='test';
                objContact.Phone = '123';
                lstContacts.add(objContact);
            }
            insert lstContacts;
        }
        test.stopTest();
    }
}