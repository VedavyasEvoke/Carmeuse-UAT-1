/*---------------------------------------------------------------------------------------------------------------------------------------------
Author : Ravikant Vijapure.
Description : Test class for account triggers.
-----------------------------------------------------------------------------------------------------------------------------------------------
VERSION    ISSUE NUMBER 	    DATE 		    AUTHOR 			 				DETAIL
1          CARMEUSE-163       05/08/2024    Ravikant Vijapure   	Test class for account triggers.
-----------------------------------------------------------------------------------------------------------------------------------------------*/
@IsTest
public with sharing class AccountTriggerExecutorTest {
    
    @testSetup
    public static void testData(){
        WebStore lstWebStore = TestDataFactory.createWebStore();
        Test.startTest();
        List<Account> lstAccounts = TestDataFactory.createAccount(5);
        Test.stopTest();
        PriceBook2 objPriceBook = new PriceBook2(Name ='PB - Test Account RV', Description ='Test Account RV');
        insert objPriceBook;
    }
    
    @isTest
    public static void testBuyerGroup(){     
        Test.startTest();
        List<Account> lstAccounts = [SELECT Id, Name FROM Account];
        Test.stopTest();
        System.assertEquals(TRUE, !lstAccounts.isEmpty(), 'Account list should not be empty');
        System.assertNotEquals(NULL, lstAccounts.size(), 'Account list should not be empty');
        
        List<Id> accountIds = new List<Id>();
        for (Account acc : lstAccounts) {
            accountIds.add(acc.Id);
        }
        
        List<BuyerGroup> lstBuyerGroup = [SELECT Id, Name, Description, Account__c, OwnerId, Account__r.Name, Account__r.Id FROM BuyerGroup WHERE Account__c IN : accountIds];
        System.assertEquals( lstAccounts.size(), lstBuyerGroup.size(), 'Created number of buyer groups should same as number of accounts.');
        System.assertNotEquals( NULL, lstBuyerGroup.size(), 'List of buyer group should not be null.');
        
        //AT-003
        for(BuyerGroup objBuyerGroup : lstBuyerGroup){
            //Positive
            System.assertEquals('BG-'+ objBuyerGroup.Account__r.Name, objBuyerGroup.Name,'BuyerGroup name should be equal to BG- BuyerGroup\'s Account Name');
            System.assertEquals('Buyer Group for '+ objBuyerGroup.Account__r.Name, objBuyerGroup.Description,'BuyerGroup Description should be equal to Buyer Group for BuyerGroup\'s Account Name');
            System.assertEquals(UserInfo.getUserId(), objBuyerGroup.OwnerId,'BuyerGroup OwnerId should be equal to userId');
            System.assertEquals(objBuyerGroup.Account__r.Id, objBuyerGroup.Account__c,'BuyerGroup Account should be equal to BuyerGroup\'s Account Id');
            //Negative
            System.assertNotEquals(null, objBuyerGroup.Name,'BuyerGroup name should not be null');
            System.assertNotEquals(null, objBuyerGroup.Description,'BuyerGroup Description should not be null');
            System.assertNotEquals('id', objBuyerGroup.OwnerId,'BuyerGroup OwnerId should not be other than userId');
            System.assertNotEquals(null, objBuyerGroup.Account__c,'BuyerGroup Account should not be null');     
        }   
    }
    
    @isTest
    public static void testAccountAsBuyer(){
        Test.startTest();
        List<Account> lstAccounts = [SELECT Id, Name FROM Account];
        Test.stopTest();
        
        List<Id> setAccountIds = new List<Id>();
        for (Account acc : lstAccounts) {
            setAccountIds.add(acc.Id);
        }
        //AT-001
        //AT-002
        List<BuyerAccount> lstBuyerAccount = [SELECT BuyerId, IsActive, Name, OwnerId, CommerceType, Buyer.Name FROM BuyerAccount WHERE BuyerId IN : setAccountIds];
        System.assertEquals( lstAccounts.size(), lstBuyerAccount.size(), 'Created number of buyer accounts should same as number of accounts.');
        System.assertNotEquals( NULL, lstBuyerAccount.size(), 'List of buyer account should not be null.');
        
        for(BuyerAccount objBuyerAccount : lstBuyerAccount){
            //Positive
            System.assertEquals(true, setAccountIds.contains(objBuyerAccount.BuyerId),'Buyer Account record should be created');
            System.assertEquals('Buyer', objBuyerAccount.CommerceType,'BuyerAccount CommerceType should be Buyer');
            System.assertEquals(true, objBuyerAccount.IsActive,'BuyerAccount should be Active');
            System.assertEquals(objBuyerAccount.Buyer.Name, objBuyerAccount.Name,'BuyerAccount Name should be equal to BuyerAccount\'s Buyer name');
            System.assertEquals(UserInfo.getUserId(), objBuyerAccount.OwnerId,'BuyerGroup OwnerId should be equal to userId');
            //Nagative
            System.assertNotEquals(false, setAccountIds.contains(objBuyerAccount.BuyerId),'Buyer Account record should be created');
            System.assertNotEquals('Not Buyer', objBuyerAccount.CommerceType,'BuyerAccount CommerceType should not be other than Buyer');
            System.assertNotEquals(false, objBuyerAccount.IsActive,'BuyerAccount should not be InActive');
            System.assertNotEquals('Test', objBuyerAccount.name,'BuyerAccount Name should not be other than BuyerAccount\'s Buyer name');
            System.assertNotEquals('333', objBuyerAccount.OwnerId,'BuyerAccount OwnerId should not be other than userId');      
        }
    }
    
    @isTest
    public static void testBuyerAccountAssignedToBuyerGroup(){
        Test.startTest();
        List<Account> lstAccounts = [SELECT Id, Name FROM Account];
        Test.stopTest();
        
        List<Id> setAccountIds = new List<Id>();
        for (Account acc : lstAccounts) {
            setAccountIds.add(acc.Id);
        }
        //AT-005
        Map<Id,BuyerGroup> mapBuyerGroup = new Map<Id,BuyerGroup>([SELECT Id FROM BuyerGroup]);
        List<BuyerGroupMember> lstBuyerGroupMember = [SELECT BuyerId, Buyer.Id, BuyerGroupId FROM BuyerGroupMember WHERE BuyerId IN : setAccountIds];
        for(BuyerGroupMember objBuyerGroupMember : lstBuyerGroupMember){
            //Positive
            System.assertEquals(objBuyerGroupMember.BuyerId, objBuyerGroupMember.Buyer.id,'BuyerGroupMember\'s Buyer\'s Id should be equal to BuyerGroupMember\'s BuyerId');
            System.assertEquals(true,mapBuyerGroup.keySet().contains(objBuyerGroupMember.BuyerGroupId),'BuyerGroupMember record should be created and BuyerGroupMember\'s  BuyerGroupId should be equal to BuyerGroup\'s Id created');
            //Nagative
            System.assertNotEquals('34667', objBuyerGroupMember.Buyer.id,'BuyerGroupMember\'s Buyer\'s Id should not be other than BuyerGroupMember\'s BuyerId');
            System.assertNotEquals(false,mapBuyerGroup.keySet().contains(objBuyerGroupMember.BuyerGroupId),'BuyerGroupMember record should be created');
        }        
    }
    
    @isTest
    public static void testBuyerGroupAssignedToStore(){
        Test.startTest();
        WebStore objWebStore = [SELECT Id, Name FROM WebStore LIMIT 1];
        List<Account> lstAccounts = [SELECT Id, Name FROM Account];
        Test.stopTest();
        System.assertNotEquals(null, objWebStore, 'Check store is created or not.');
        //AT-006
        Map<Id,BuyerGroup> mapBuyerGroup = new Map<Id,BuyerGroup>([SELECT Id FROM BuyerGroup]);
        for(WebStoreBuyerGroup objWebStoreBuyerGroup : [SELECT ID, BuyerGroupId, WebStoreId FROM WebStoreBuyerGroup WHERE WebStoreId =: objWebStore.Id]){
            System.assertEquals(true, mapBuyerGroup.keySet().contains(objWebStoreBuyerGroup.BuyerGroupId),'WebStoreBuyerGroup record should be created and WebStoreBuyerGroup\'s  BuyerGroupId should be equal to BuyerGroup\'s Id created');
            System.assertEquals(objWebStore.id,objWebStoreBuyerGroup.WebStoreId,'WebStoreBuyerGroup\'s WebStoreId should be equal to WebStore\'s Id');
            //AT-010 
            System.assertNotEquals(false, mapBuyerGroup.keySet().contains(objWebStoreBuyerGroup.BuyerGroupId),'WebStoreBuyerGroup record should be created');
            System.assertNotEquals('3778',objWebStoreBuyerGroup.WebStoreId,'WebStoreBuyerGroup\'s WebStoreId should not be other than WebStore\'s Id');
        }
    }
    
    @isTest
    public static void testEntitlementPolicyInserted(){
        Test.startTest();
        List<Account> lstAccounts = [SELECT Id, Name FROM Account];
        Test.stopTest();
        //AT-004
        Map<Id,Account> mapAccount = new Map<Id,Account>([SELECT Id, Name FROM Account]);
        List<CommerceEntitlementPolicy> lstCommerceEntitlementPolicy = [SELECT Id, Account__c, Description, IsActive, CanViewProduct, CanViewPrice, Name, OwnerId FROM CommerceEntitlementPolicy WHERE Account__c In : mapAccount.keySet()];
        for(CommerceEntitlementPolicy objCommerceEntitlementPolicy : lstCommerceEntitlementPolicy){
            //Positive
            System.assertEquals(5, lstCommerceEntitlementPolicy.size(),'CommerceEntitlementPolicy should be created for all Account');
            System.assertEquals(true, mapAccount.keySet().contains(objCommerceEntitlementPolicy.Account__c),'CommerceEntitlementPolicy should be created for all Account');
            System.assertEquals(true, objCommerceEntitlementPolicy.IsActive,'CommerceEntitlementPolicy should be Active');
            System.assertEquals(true, objCommerceEntitlementPolicy.CanViewProduct,'CommerceEntitlementPolicy\'s CanViewProduct should be checked');
            System.assertEquals(false, objCommerceEntitlementPolicy.CanViewPrice,'CommerceEntitlementPolicy\'s CanViewPrice should be unchecked');
            System.assertEquals('EP-' + mapAccount.get(objCommerceEntitlementPolicy.Account__c).name, objCommerceEntitlementPolicy.Name,'CommerceEntitlementPolicy\'s Name should be equal to EP- and CommerceEntitlementPolicy\'s Account\'s Name');
            System.assertEquals('Entitlement Policy for ' + mapAccount.get(objCommerceEntitlementPolicy.Account__c).name, objCommerceEntitlementPolicy.Description,'CommerceEntitlementPolicy\'s Description should be equal to Entitlement Policy for and CommerceEntitlementPolicy\'s Account\'s Name');    
            System.assertEquals(UserInfo.getUserId(), objCommerceEntitlementPolicy.OwnerId,'CommerceEntitlementPolicy\'s OwnerId should be equal to userId'); 
            //Negative
            System.assertNotEquals(40, lstCommerceEntitlementPolicy.size(),'CommerceEntitlementPolicy should be created for all Account');
            System.assertNotEquals(false, mapAccount.keySet().contains(objCommerceEntitlementPolicy.Account__c),'CommerceEntitlementPolicy should be created for all Account');
            System.assertNotEquals(false, objCommerceEntitlementPolicy.IsActive,'CommerceEntitlementPolicy should not be InActive');
            System.assertNotEquals(false, objCommerceEntitlementPolicy.CanViewProduct,'CommerceEntitlementPolicy\'s CanViewProduct should not be unchecked');
            System.assertNotEquals(true, objCommerceEntitlementPolicy.CanViewPrice,'CommerceEntitlementPolicy\'s CanViewPrice should not be checked');
            System.assertNotEquals('EP' + mapAccount.get(objCommerceEntitlementPolicy.Account__c).name, objCommerceEntitlementPolicy.Name,'CommerceEntitlementPolicy\'s Name should not be other than EP- and CommerceEntitlementPolicy\'s Account\'s Name');
            System.assertNotEquals('Entitlement ' + mapAccount.get(objCommerceEntitlementPolicy.Account__c).name, objCommerceEntitlementPolicy.Description,'CommerceEntitlementPolicy\'s Description should not be other than Entitlement Policy for and CommerceEntitlementPolicy\'s Account\'s Name');    
            System.assertNotEquals('4556', objCommerceEntitlementPolicy.OwnerId,'CommerceEntitlementPolicy\'s OwnerId should be equal to userId'); 
        }
    }
    
    @isTest
    public static void testEntitlementPolicyAssignedToBuyerGroup(){
        Test.startTest();
        List<Account> lstAccounts = [SELECT Id, Name FROM Account];
        Test.stopTest();
        
        Map<Id,Account> mapAccount = new Map<Id,Account>([SELECT Id, Name FROM Account]);
        Map<Id,BuyerGroup> mapBuyerGroup = new Map<Id,BuyerGroup>([SELECT Id FROM BuyerGroup]);
        Map<Id,CommerceEntitlementPolicy> mapCommerceEntitlementPolicy = new Map<Id,CommerceEntitlementPolicy>([SELECT Id FROM CommerceEntitlementPolicy]);
        List<CommerceEntitlementBuyerGroup> lstCommerceEntitlementBuyerGroup = [SELECT Id, BuyerGroupId, PolicyId FROM CommerceEntitlementBuyerGroup WHERE PolicyId IN : mapCommerceEntitlementPolicy.KeySet()];
        //AT-007
        for(CommerceEntitlementBuyerGroup objCommerceEntitlementBuyerGroup : lstCommerceEntitlementBuyerGroup){
            //Positive
            system.assertEquals(true,mapBuyerGroup.keySet().contains(objCommerceEntitlementBuyerGroup.BuyerGroupId),'CommerceEntitlementPolicy should be assigned to BuyerGroup');
            system.assertEquals(true,mapCommerceEntitlementPolicy.keySet().contains(objCommerceEntitlementBuyerGroup.PolicyId),'PolicyId from CommerceEntitlementBuyerGroup should be equal to CommerceEntitlementPolicy\'s Id');
            //Negative
            system.assertNotEquals(false,mapBuyerGroup.keySet().contains(objCommerceEntitlementBuyerGroup.BuyerGroupId),'CommerceEntitlementPolicy should be assigned to BuyerGroup');
            system.assertNotEquals(false,mapCommerceEntitlementPolicy.keySet().contains(objCommerceEntitlementBuyerGroup.PolicyId),'PolicyId from CommerceEntitlementBuyerGroup should not be other than CommerceEntitlementPolicy\'s Id');
        }
    }
    
    @isTest
    public static void testPricebookAssignedToBuyerGroup(){ 
        Test.startTest();
        List<Account> lstAccounts = new List<Account>{
            new Account(Name = 'Test Account RV', AccountExternalNumber__c = '0000739293', B2B_Customer__c=true)
                };
                    insert lstAccounts;
        Test.stopTest();
        
        //AT-008
        Map<Id, Account> mapAccount = new Map<Id, Account>(lstAccounts);
        Map<Id,BuyerGroup> mapBuyerGroup = new Map<Id,BuyerGroup>([SELECT Id FROM BuyerGroup WHERE Account__c IN : mapAccount.keySet()]);
        Map<Id,Pricebook2> mapPricebook2 = new Map<Id,Pricebook2>([SELECT Id, Name FROM Pricebook2 WHERE Description LIKE 'Test%']);
        List<BuyerGroupPricebook> lstBuyerGroupPricebook = new List<BuyerGroupPricebook>([SELECT Id, BuyergroupId, Pricebook2Id FROM BuyerGroupPricebook]);
        for(BuyerGroupPricebook objBuyerGroupPricebook : lstBuyerGroupPricebook){
            //Positive
            System.assertEquals(true, mapBuyerGroup.keySet().contains(objBuyerGroupPricebook.BuyergroupId),'PriceBook should be assigned to BuyerGroup');
            System.assertEquals(true, mapPricebook2.keySet().contains(objBuyerGroupPricebook.Pricebook2Id),'Pricebook2Id from CommerceEntitlementBuyerGroup should be equal to CommerceEntitlementPolicy\'s Id');
            //Negative
            System.assertNotEquals(false, mapBuyerGroup.keySet().contains(objBuyerGroupPricebook.BuyergroupId),'PriceBook should be assigned to BuyerGroup');
            System.assertNotEquals(false, mapPricebook2.keySet().contains(objBuyerGroupPricebook.Pricebook2Id),'Pricebook2Id from CommerceEntitlementBuyerGroup should not be other than CommerceEntitlementPolicy\'s Id');            
        }
        //AT-009
        Map<Id,Pricebook2> mapPricebook2NotAssigned = new Map<Id,Pricebook2>([SELECT Id FROM Pricebook2 WHERE Description LIKE 'RV-%']);
        List<BuyerGroupPricebook> lstBuyerGroupPricebookNotAssigned = new List<BuyerGroupPricebook>([SELECT Id, BuyergroupId, Pricebook2Id FROM BuyerGroupPricebook WHERE Pricebook2Id In : mapPricebook2NotAssigned.keySet()]);
        for(BuyerGroupPricebook objBuyerGroupPricebook : lstBuyerGroupPricebookNotAssigned){
            //Positive
            System.assertEquals(false, mapBuyerGroup.keySet().contains(objBuyerGroupPricebook.BuyergroupId),'PriceBook should not be assigned to BuyerGroup when PriceBook\'s Description not same as Account Name');
            System.assertEquals(false, mapPricebook2NotAssigned.keySet().contains(objBuyerGroupPricebook.Pricebook2Id),'Pricebook2Id from CommerceEntitlementBuyerGroup should not be equal to CommerceEntitlementPolicy\'s Id when PriceBook\'s Description not same as Account Name');
            //Negative
            System.assertNotEquals(true, mapBuyerGroup.keySet().contains(objBuyerGroupPricebook.BuyergroupId),'PriceBook should not be assigned to BuyerGroup when PriceBook\'s Description not same as Account Name');
            System.assertNotEquals(true, mapPricebook2NotAssigned.keySet().contains(objBuyerGroupPricebook.Pricebook2Id),'Pricebook2Id from CommerceEntitlementBuyerGroup should not be equal to CommerceEntitlementPolicy\'s Id when PriceBook\'s Description not same as Account Name');
            
        }
    }

    @isTest
    public static void testAfterUpdateAccount() {  
        List<Account> accountsToUpdate = new List<Account>(); 
        List<Account> lstAccounts = new List<Account>{
            new Account(Name = 'Test Account RV', AccountExternalNumber__c = '0000739293', B2B_Customer__c=false)
                };
                    insert lstAccounts; 
        Test.startTest();
        WebStore objWebStore = [SELECT Id, Name FROM WebStore LIMIT 1];
        for (Account acc : [SELECT Id, B2B_Customer__c FROM Account WHERE Id IN :lstAccounts]) {
            acc.B2B_Customer__c = true;
            accountsToUpdate.add(acc);
        }
        update accountsToUpdate;
        Test.stopTest();
        List<Account> lstUpdatedAccount = [SELECT Id, Name, B2B_Customer__c FROM Account WHERE Name ='Test Account RV'];
        System.assertEquals(TRUE, !lstUpdatedAccount.isEmpty(), 'Account list after update should not be empty');
        System.assertNotEquals(NULL, lstUpdatedAccount.size(), 'Account list after update should not be empty');
        
        List<BuyerGroup> lstBuyerGroup = [SELECT Id, Name, Description, Account__c, OwnerId, Account__r.Name, Account__r.Id FROM BuyerGroup WHERE Account__c IN : lstUpdatedAccount];
        System.assertEquals( lstUpdatedAccount.size(), lstBuyerGroup.size(), 'Created number of buyer groups should same as number of accounts.');
        System.assertNotEquals( NULL, lstBuyerGroup.size(), 'List of buyer group should not be null.');
        
        List<BuyerAccount> lstBuyerAccount = [SELECT BuyerId, IsActive, Name, OwnerId, CommerceType, Buyer.Name FROM BuyerAccount WHERE BuyerId IN : lstUpdatedAccount];
        System.assertEquals( lstUpdatedAccount.size(), lstBuyerAccount.size(), 'Created number of buyer accounts should same as number of accounts.');
        System.assertNotEquals( NULL, lstBuyerAccount.size(), 'List of buyer account should not be null.');
        
        List<BuyerGroupMember> lstBuyerGroupMember = [SELECT BuyerId, Buyer.Id, BuyerGroupId FROM BuyerGroupMember WHERE BuyerId IN : lstUpdatedAccount];
        System.assertEquals( lstUpdatedAccount.size(), lstBuyerGroupMember.size(), 'Created number of buyer group member should same as number of accounts.');
        System.assertNotEquals( NULL, lstBuyerAccount.size(), 'List of buyer group member should not be null.');
        
        List<CommerceEntitlementPolicy> lstCommerceEntitlementPolicy = [SELECT Id, Account__c, Description, IsActive, CanViewProduct, CanViewPrice, Name, OwnerId FROM CommerceEntitlementPolicy WHERE Account__c In : lstUpdatedAccount];
        System.assertEquals( lstUpdatedAccount.size(), lstCommerceEntitlementPolicy.size(), 'Created number of entitlment policy should same as number of accounts.');
        System.assertNotEquals( NULL, lstCommerceEntitlementPolicy.size(), 'List of entitlment policy should not be null.');       
    }
    
    @isTest
    public static void testUpdateAccount(){
        WebStore objWebStore = TestDataFactory.createWebStore(); 
        Test.startTest();
        Account testAccount = new Account(Name='TestAccount',BillingStreet='Test Street', BillingCountry='United States', BillingPostalCode='44444', AccountExternalNumber__c = '123');
        insert testAccount;
        Test.stopTest();
        testAccount.BillingCity = 'New City';
        update testAccount;
    }
    
    @isTest
    public static void testDeleteAccount() {
        WebStore objWebStore = TestDataFactory.createWebStore(); 
        Account testAccount = new Account(
            Name = 'TestAccount',
            BillingStreet = 'Test Street',
            BillingCountry = 'United States',
            BillingPostalCode = '44444',
            AccountExternalNumber__c = '123'
        );
        Test.startTest();
        insert testAccount;
        Test.stopTest();
        delete testAccount;
        
        List<Account> lstAccountAfterDelete = [SELECT Id FROM Account WHERE Id = :testAccount.Id];
        //Positive
        System.assertEquals(0, lstAccountAfterDelete.size(),'Account should be deleted successfully');
        //Negative
        System.assertNotEquals(1, lstAccountAfterDelete.size(),'Account should be deleted successfully');
    }
}