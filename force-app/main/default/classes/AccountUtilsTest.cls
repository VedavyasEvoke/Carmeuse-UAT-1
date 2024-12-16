/*---------------------------------------------------------------------------------------------------------------------------------------------
Author : Ravikant Vijapure.
Description : Test class for AccountUtils class.
-----------------------------------------------------------------------------------------------------------------------------------------------
VERSION    ISSUE NUMBER 	    DATE 		    AUTHOR 			 				DETAIL
1          CARMEUSE-163       20/05/2024    Ravikant Vijapure   	Test class for AccountUtils class.
-----------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class AccountUtilsTest {
    
    @testSetup
    public static void testData(){
        
        WebStore lstWebStore = TestDataFactory.createWebStore();
        Test.startTest();
        List<Account> lstAccounts = TestDataFactory.createAccounts(6);
        Test.stopTest();
        List<AccountInvoice__c> lstAccountInvoices = TestDataFactory.createAccountInvoice(lstAccounts, 1);

        Date previousDate = Date.today().addDays(-60);
        
        for (AccountInvoice__c objAccountInvoice : lstAccountInvoices) {
            Test.setCreatedDate(objAccountInvoice.Id, previousDate);
        }

        ContentVersion content = new ContentVersion(); 
        content.Title = 'Header_Picture1'; 
        content.PathOnClient = '/' + content.Title + '.jpg'; 
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData = bodyBlob; 
        content.origin = 'H';
        insert content;
        
        List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>();
        Integer halfCount = (Integer)  Math.ceil(lstAccountInvoices.size() / 2);
        Id contentDocumentId = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :content.Id LIMIT 1].Id;
        
        for (Integer i = 0; i < halfCount; i++) {
            ContentDocumentLink contentLink = new ContentDocumentLink();
            contentLink.LinkedEntityId = lstAccountInvoices[i].Id;
            contentLink.ContentDocumentId = contentDocumentId;
            contentLink.ShareType = 'I';
            contentLink.Visibility = 'AllUsers';  
            contentLinks.add(contentLink);
        }
        insert contentLinks;
    }
    
    @isTest
    public static void testGetInvoicesWithDocuments(){
        List<AccountInvoice__c> lstAccountInvoices = [SELECT Id, Name, Invoice_Number__c, AccountInvoiceRelation__c, InvoiceExternalAccountNumber__c, InvoiceDate__c, AccountInvoiceRelation__r.B2B_Customer__c, CreatedDate FROM AccountInvoice__c];
        List<ContentDocumentLink> lstContentDocumentLinks = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN ( SELECT Id FROM AccountInvoice__c WHERE AccountInvoiceRelation__r.B2B_Business_Sub_Unit__c != NULL AND CreatedDate >= LAST_N_DAYS:240 ) AND LinkedEntity.Type = 'AccountInvoice__c'];
        
        Test.startTest();
        List<Id> lstlinkedInvoices = AccountUtils.getInvoicesWithDocuments();
        Test.stopTest();
        
        List<Id> expectedInvoiceIds = new List<Id>();
        for (ContentDocumentLink link : lstContentDocumentLinks) {
            expectedInvoiceIds.add(link.LinkedEntityId);
        }
        
        //AIR-002
        Assert.isTrue(!lstlinkedInvoices.isEmpty(), 'Linked Ids should not be empty');
        Assert.areEqual(expectedInvoiceIds.size(), lstlinkedInvoices.size(), 'The number of invoices with documents should match the expected count.');
        for (Id invoiceId : lstlinkedInvoices) {
            Assert.isTrue(expectedInvoiceIds.contains(invoiceId), 'Invoice with ID ' + invoiceId + ' should be in the list of invoices with documents.');
        }
    }
        
    @isTest
    public static void testGetAccountInvoicesWithFiles() {
        List<AccountInvoice__c> lstInvoices = [SELECT Id FROM AccountInvoice__c];
        List<ContentDocumentLink> lstContentDocumentLinks = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN ( SELECT Id FROM AccountInvoice__c WHERE AccountInvoiceRelation__r.B2B_Business_Sub_Unit__c != NULL AND CreatedDate >= LAST_N_DAYS:240 ) AND LinkedEntity.Type = 'AccountInvoice__c'];
        List<Id> setIds = new List<Id>();
        
        for (ContentDocumentLink link : lstContentDocumentLinks) {
            setIds.add(link.LinkedEntityId);
        }

        Test.startTest();
        List<AccountInvoice__c> result = AccountUtils.getAccountInvoices(setIds, 'With Files');
        Test.stopTest();

        //AIR-002
        Assert.areEqual(lstContentDocumentLinks.size(), result.size(), 'The number of invoices returned should match the number of invoices in setIds.');
        Assert.isTrue(!result.isEmpty(), 'The list of invoices should not be empty.');

        for (AccountInvoice__c invoice : result) {
            Assert.isTrue(setIds.contains(invoice.Id), 'The list of invoices should contain all the Ids in setIds.');
        }
    }
    
    @isTest
    public static void testGetAccountInvoicesWithoutFiles() {
        List<AccountInvoice__c> lstInvoices = [SELECT Id, AccountInvoiceRelation__r.B2B_Business_Sub_Unit__c FROM AccountInvoice__c];
        List<ContentDocumentLink> lstContentDocumentLinks = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN ( SELECT Id FROM AccountInvoice__c WHERE AccountInvoiceRelation__r.B2B_Business_Sub_Unit__c != NULL AND CreatedDate >= LAST_N_DAYS:240 ) AND LinkedEntity.Type = 'AccountInvoice__c'];
        List<Id> linkedInvoiceIds = new List<Id>();
        
        Test.startTest();
        List<AccountInvoice__c> result = AccountUtils.getAccountInvoices(linkedInvoiceIds, 'Without Files');
        Test.stopTest();
        
        //AIR-002
        Assert.areEqual(lstInvoices.size(), result.size(), 'The number of invoices returned should match the expected invoices without files.');
        Assert.isTrue(!result.isEmpty(), 'result should not be empty.');
    }
    
    @isTest
    public static void testGetAccountInvoicesInvalidFileType() {
        Test.startTest();
        List<AccountInvoice__c> result = AccountUtils.getAccountInvoices(new List<Id>(), 'Invalid File Type');
        Test.stopTest();
        
        Assert.areEqual(0, result.size(), 'The result should be an empty list for invalid fileType.');
    }

    @isTest
    public static void testAccountNotPlacedOrder(){
        
        List<Account> lstAccount = new List<Account>();
        Account acctTest = new Account(Name='acctTest', AccountExternalNumber__c = '123454');
        lstAccount.add(acctTest);
        
        Account acctBoomi = new Account(Name='acctBoomi', AccountExternalNumber__c = '123455');
        lstAccount.add(acctBoomi);
        
        Account acctContactNoOrder = new Account(Name='acctContactNoOrder', AccountExternalNumber__c = '123456');
        lstAccount.add(acctContactNoOrder);
        
        Account acctContactOrderBoomi = new Account(Name='acctContactOrderBoomi', AccountExternalNumber__c = '123457');
        lstAccount.add(acctContactOrderBoomi);
        
        Account acctContactOrder = new Account(Name='acctContactOrder', AccountExternalNumber__c = '123458');
        lstAccount.add(acctContactOrder);
        
        Account acctNoContactNoOrder = new Account(Name='acctNoContactNoOrder', AccountExternalNumber__c = '123459');
        lstAccount.add(acctNoContactNoOrder);
        
        insert lstAccount;
        
        List<Contact> lstContact = new List<Contact>();
        Contact contTest = new Contact(LastName='contTest', AccountId=lstAccount[0].Id, Email='test123454@gmail.com');
        lstContact.add(contTest);
        
        Contact contBoomi = new Contact(LastName='contBoomi', AccountId=lstAccount[1].Id, Email='test123455@gmail.com');
        lstContact.add(contBoomi);
        
        Contact contContactNoOrder = new Contact(LastName='contContactNoOrder', AccountId=lstAccount[2].Id, Email='test123456@gmail.com');
        lstContact.add(contContactNoOrder);
        
        Contact contContactOrderBoomi = new Contact(LastName='contContactOrderBoomi', AccountId=lstAccount[3].Id, Email='test123457Boomi@gmail.com');
        lstContact.add(contContactOrderBoomi);
        
        Contact contContactOrder = new Contact(LastName='contContactOrder', AccountId=lstAccount[4].Id, Email='test123458@gmail.com');
        lstContact.add(contContactOrder);
        insert lstContact;
        
        Profile lstProfile = [SELECT Id FROM Profile WHERE Name='Level 3 – Access to Level 1 & Level 2']; 
        Profile lstProfileBoomi = [SELECT Id FROM Profile WHERE Name='Boomi Integration User']; 
        
        List<User> lstUser = new List<User>();
        
        User acctContactNoOrderUser = new User(Alias = 'NoOrder', Email='test123456@gmail.com', 
                                               EmailEncodingKey='UTF-8', FirstName='acctContactNoOrderUser', LastName='acctContactNoOrderUser', LanguageLocaleKey='en_US', 
                                               LocaleSidKey='en_US', ProfileId = lstProfile.Id, IsActive=true,ContactId=lstContact[2].Id,
                                               TimeZoneSidKey='America/Los_Angeles', UserName='trcvest456@gmail.com'
                                              );
        lstUser.add(acctContactNoOrderUser);
        
        User acctContactOrderUser = new User(Alias = 'order', Email='test123458@gmail.com', 
                                             EmailEncodingKey='UTF-8', FirstName='placed', LastName='placedUser', LanguageLocaleKey='en_US', 
                                             LocaleSidKey='en_US', ProfileId = lstProfile.Id, IsActive=true,ContactId=lstContact[4].Id,
                                             TimeZoneSidKey='America/Los_Angeles', UserName='tesrvt458@gmail.com'
                                            );
        lstUser.add(acctContactOrderUser);
        
        User acctTestUser = new User(Alias = 'test', Email='test123454@gmail.com', 
                                     EmailEncodingKey='UTF-8', FirstName='place', LastName='placeUser', LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', ProfileId = lstProfile.Id, IsActive=true,ContactId=lstContact[0].Id,
                                     TimeZoneSidKey='America/Los_Angeles', UserName='test4rv54@gmail.com'
                                    );
        lstUser.add(acctTestUser);
        
        User acctUser = new User(Alias = 'test1', Email='test123456@gmail.com', 
                                 EmailEncodingKey='UTF-8', FirstName='test', LastName='User', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = lstProfile.Id, IsActive=true,ContactId=lstContact[3].Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testrv4566@gmail.com'
                                );
        lstUser.add(acctUser);
        
        User acctContactOrderBoomiUser = new User(Alias = 'boomi', Email='test123457@enzigma.com', 
                                                  EmailEncodingKey='UTF-8', FirstName='Boomii', LastName='IntegrationUserr', LanguageLocaleKey='en_US', 
                                                  LocaleSidKey='en_US', ProfileId = lstProfileBoomi.Id, IsActive=true,
                                                  TimeZoneSidKey='America/Los_Angeles', UserName='test457rv@gmail.com'
                                                 );
        lstUser.add(acctContactOrderBoomiUser);
        insert lstUser;
        List<Order> lstOrder = new List<Order>();
        Order order = new Order(AccountId=lstAccount[3].Id, OwnerId=lstUser[4].id, Status='Draft', EffectiveDate=Date.newInstance(2023, 02, 11));
        lstOrder.add(order);
        
        Order orders = new Order(AccountId=lstAccount[2].Id, OwnerId=lstUser[1].id, Status='Draft', EffectiveDate=Date.newInstance(2023, 02, 11));
        lstOrder.add(orders);
        
        insert lstOrder;
        
        String accountWithoutOrder = AccountUtils.getAccountNotPlacedOrder();
        
        String[] lines = accountWithoutOrder.split('\n');
        lines.sort();
        System.assertEquals('Ship To Name', lines[0]);
        System.assertEquals(4, lines.size());
        System.assertNotEquals(null, lines.size());
        //AWO - 001
        System.assertEquals('acctTest', lines[3],'If Account has enabled contact with Order Owner not from enabled contact,account should shows in downloaded Report');
        System.assertNotEquals(NULL, lines[3],'If Account has enabled contact with Order Owner not from enabled contact,account should not be shown as null report');
        //AWO - 002
        System.assertEquals('acctContactOrderBoomi', lines[2],'If Account has enabled contact with Order Owner as BOOMI,account should shows in downloaded Report');
        System.assertNotEquals(NULL, lines[2],'If Account has enabled contact with Order Owner as BOOMI,account should not be shown as null report');
        //AWO - 003
        System.assertEquals('acctContactOrder', lines[1],'If Account has enabled contact with Order Owner not from enabled contact,account should shows in downloaded Report ');
        System.assertNotEquals(NULL, lines[1],'If Account has enabled contact with Order Owner not from enabled contact,account should not be shown as null report');
        //AWO - 004
        System.assertEquals(false,lines[1].contains('acctNoContactNoOrder'),'If Account does not have contact and Order,account should not shows in downloaded report');
        System.assertEquals(false,lines[2].contains('acctNoContactNoOrder'),'If Account does not have contact and Order,account should not shows in downloaded report');
        System.assertEquals(false,lines[3].contains('acctNoContactNoOrder'),'If Account does not have contact and Order,account should not shows in downloaded report');
        
        System.assertNotEquals(NULL,lines[1].contains('acctNoContactNoOrder'),'If Account does not have contact and Order,account should not shows in downloaded report');
        System.assertNotEquals(NULL,lines[2].contains('acctNoContactNoOrder'),'If Account does not have contact and Order,account should not shows in downloaded report');
        System.assertNotEquals(NULL,lines[3].contains('acctNoContactNoOrder'),'If Account does not have contact and Order,account should not shows in downloaded report');
    }
    
    @isTest
    public static void testGetAccountDetails(){
        Test.startTest();
        List<Account> lstAccount  = [SELECT Id, Name, AccountExternalNumber__c, Business_Unit__c FROM Account LIMIT 1];
        Test.stopTest();
        List<Account> result = AccountUtils.getAccountDetails(lstAccount[0].Id);
        System.assertNotEquals(NULL, result, 'To test getAccountDetails does not return empty');
        
        for(Account objAccount : result){
            System.assertEquals(objAccount.Id, lstAccount[0].Id,'Account Id of the result and id of account in the list should be same');
            System.assertEquals(objAccount.Name, lstAccount[0].Name,'Account Name of the result and name account in the list should be same');
            System.assertEquals(objAccount.AccountExternalNumber__c, lstAccount[0].AccountExternalNumber__c,'Account.AccountExternalNumber of the result and AccountExternalNumber__c of the account in the list should be same');
            System.assertEquals(objAccount.Business_Unit__c, lstAccount[0].Business_Unit__c,'Business_Unit__c account in the result and Business_Unit__c of the account list should be same');
            
            System.assertNotEquals('00647ty666', lstAccount[0].Id,'Account Id of the result and id of account in the list should not be different');
            System.assertNotEquals(NULL, lstAccount[0].Name,'Account Name of the result and name account in the list should not be different');
            System.assertNotEquals('TEST 77', lstAccount[0].AccountExternalNumber__c,'Account.AccountExternalNumber of the result and AccountExternalNumber__c of the account in the list should not be different');
            System.assertNotEquals('LIME', lstAccount[0].Business_Unit__c,'Business_Unit__c account in the result and Business_Unit__c of the account list should not be different');
        }
        /*get account details exception*/
        List<Account> lstAccountExp = AccountUtils.getAccountDetails(NULL);
        System.assertEquals(TRUE, lstAccountExp.isEmpty(), 'List should be return empty');
    }
}