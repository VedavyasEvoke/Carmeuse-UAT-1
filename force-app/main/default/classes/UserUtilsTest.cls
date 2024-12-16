/********************************************************************************************************************************************
Author : Priyanka Shinde
Description :Test class for User utils class with all User related methods
----------------------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 	  DATE 		   AUTHOR 			 DETAIL
1.0                          17/08/2022    Priyanka Shinde   Test class for User utils class with all User related methods.
1.1         CARMEUSE-180     29/10/2024    Ravikant Vijapure Test class issue due to custom validation rule added by Evoke team.
**********************************************************************************************************************************************/
@isTest
public with sharing class UserUtilsTest {
    @TestSetup
    public static void setUp(){
        
        TriggerConfiguration.setDoNotRunTrigger();
        
        Account accountObj = new Account();
        accountObj.name = '1215-Test Account';
        accountObj.AccountExternalNumber__c = '00001215';
        accountObj.SPC_Email__c = 'testenz@enz.com';
        accountObj.BillingStreet = 'Street';
        accountObj.BillingCountry = 'Country';
        accountObj.BillingPostalCode =  '234';
        insert accountObj;
        Contact objContact = new Contact();
        objContact.Lastname= 'usertesting';
        objContact.AccountId = accountObj.Id;
        objContact.Email = 'usertesting@gmail.com';
        insert objContact;
        UserRole userRole =[SELECT Id, Name FROM UserRole WHERE Id='00E09000000Hlf9EAC'];
        Profile profileObj = [SELECT Id FROM Profile WHERE Name='Level 4 – Access to Level 1, Level 2 & Delegated Admin' LIMIT 1]; 
        UserLicense objLicense = [SELECT Id, Name FROM UserLicense where Name ='Customer Community Plus' LIMIT 1];
        User userObj = new User(Alias = 'standt', Email='testenz@enz.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',ContactID = objContact.Id,
                                LocaleSidKey='en_US', ProfileId = profileObj.Id, Email_Preferences__c ='Order Submission; Order Confirmation; Order Cancellation; All Order Submission; All Order Confirmation; All Order Cancellation;', 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testenz@enz.com', IsActive = true,Show_Pop_Up__c =false);
        insert userObj;
        
        User portalUser = [SELECT Id,ContactId,AccountId,ProfileId FROM User WHERE IsPortalEnabled = TRUE AND IsActive = TRUE LIMIT 1];
        
        List<Ordering_Rule__c> lstOrderingRule = new List<Ordering_Rule__c>();
        Ordering_Rule__c objOrderingRule1 = new Ordering_Rule__c();
        objOrderingRule1.Ordering_Rule_Days__c = 2;
        objOrderingRule1.Plant_Code__c='AN';
        objOrderingRule1.Product_Code__c='12345';
        objOrderingRule1.No_Weekend_Order__c=true;
        lstOrderingRule.add(objOrderingRule1);
        
        Ordering_Rule__c objOrderingRule2 = new Ordering_Rule__c();
        objOrderingRule2.Plant_Code__c='RV';
        objOrderingRule2.Product_Code__c='88768';
        lstOrderingRule.add(objOrderingRule2);
        
        List <Ship_To_Override_Tonnage_Limits__c > lstTonnageShipTo = new List <Ship_To_Override_Tonnage_Limits__c >();
        List<Ship_To_With_Gallon_Products__c>  lstGallonShipTo = new List<Ship_To_With_Gallon_Products__c>();
        
        for(Integer index=1; index<=10; index++){
            Ship_To_Override_Tonnage_Limits__c  tonnageShipToObj = new  Ship_To_Override_Tonnage_Limits__c();
            tonnageShipToObj.Name = 'Test'+index;
            tonnageShipToObj.Ship_To__c ='00021212'+index;
            lstTonnageShipTo.add(tonnageShipToObj);
        }
        for(Integer index=1; index<=10; index++){
            Ship_To_With_Gallon_Products__c  gallonShipToObj = new  Ship_To_With_Gallon_Products__c();
            gallonShipToObj.Name = 'Test'+index;
            gallonShipToObj.ShipTo__c ='00021212'+index;
            lstGallonShipTo.add(gallonShipToObj);
        }
        
        test.startTest();
        insert lstOrderingRule;
        insert lstTonnageShipTo;
        insert lstGallonShipTo;
        test.stopTest();
    }
    @isTest
    public static void testGetUserDetails(){
        List<User> lstUser = [SELECT Id, UserName, Show_Pop_Up__c FROM User WHERE UserName='testenz@enz.com' LIMIT 1];
        
        Boolean userDetails = UserUtils.getUserDetails(lstUser[0].Id);
        
        System.assertNotEquals(NULL, userDetails,'Check User data is inserted in Test setup');
        System.assertEquals(lstUser[0].Show_Pop_Up__c, userDetails,'To test getUserDetails returns valid User data');
        
        UserUtils.showException = true;        
        try{
            UserUtils.getUserDetails(lstUser[0].Id);
            System.assert(false, 'Should have thrown an exception');
        }catch(Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Exception message was wrong');
        }
    }
    
    @isTest
    public static void testCloseModal(){
        List<User> lstUser = [SELECT Id, UserName, Show_Pop_Up__c,Email FROM User WHERE UserName='testenz@enz.com' LIMIT 1];
        System.assertEquals(false, lstUser[0].Show_Pop_Up__c);
        System.assertNotEquals(true, lstUser[0].Show_Pop_Up__c);
        
        UserUtils.closeModal(lstUser[0].Id);
        
        List<User> lstUserUpdated = [SELECT Id, UserName, Show_Pop_Up__c FROM User WHERE UserName='testenz@enz.com' LIMIT 1];
        System.assertEquals(true, lstUserUpdated[0].Show_Pop_Up__c,'To test user Show_Pop_Up__c field is updated by closeModal method');
        System.assertNotEquals(false, lstUserUpdated[0].Show_Pop_Up__c,'To test user Show_Pop_Up__c field is not updated invalidly by closeModal method');
        
        UserUtils.showException = true;        
        try{
            UserUtils.closeModal(lstUser[0].Id);
            System.assert(false, 'Should have thrown an exception');
        }catch(Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Exception message was wrong');
        }
    }
    
    @isTest
    public static void testUpdateUserEmailPreferences(){
        List<User> lstUser = [SELECT Id, UserName, Show_Pop_Up__c, Email_Preferences__c FROM User WHERE UserName='testenz@enz.com' LIMIT 1];
        
        Boolean UserEmailPreferences = UserUtils.updateUserEmailPreferences(lstUser[0].Id, true,true,true,false,true,true,true);
        
        System.assertEquals('Order Submission;Order Confirmation;Order Cancellation;All Order Submission;All Order Confirmation;All Order Cancellation', lstUser[0].Email_Preferences__c,'To test updateUserEmailPreferences method returns valid email preferences');
        System.assertNotEquals(NULL, lstUser[0].Email_Preferences__c,'To test user email preferences are not null');
        
        UserUtils.showException = true;        
        try{
            UserUtils.updateUserEmailPreferences(lstUser[0].Id,false,false,false,false,false,false,false);
            System.assert(false, 'Should have thrown an exception');
        }catch(Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Exception message was wrong');
        }
    }
    
    @isTest
    public static void testUpdateUserNoEmailPreferences(){
        List<User> lstUser = [SELECT Id, UserName, Show_Pop_Up__c, Email_Preferences__c FROM User WHERE UserName='testenz@enz.com' LIMIT 1];
        
        Boolean UserEmailPreferences = UserUtils.updateUserEmailPreferences(lstUser[0].Id,false,false,false,true,false,false,false);
        
        List<User> lstUserUpdated = [SELECT Id, UserName, Show_Pop_Up__c, Email_Preferences__c FROM User WHERE UserName='testenz@enz.com' LIMIT 1];
        
        System.assertEquals('No Email', lstUserUpdated[0].Email_Preferences__c);
        System.assertNotEquals(NULL, lstUserUpdated[0].Email_Preferences__c);
    }
    
    @isTest
    public static void testGetUserEmailPreferences(){
        List<User> lstUser = [SELECT Id, UserName, Show_Pop_Up__c, Email_Preferences__c FROM User WHERE UserName='testenz@enz.com' LIMIT 1];
        
        String result = UserUtils.getUserEmailPreferences(lstUser[0].Id);
        
        System.assertEquals(result, lstUser[0].Email_Preferences__c,'To test getUserEmailPreferences returns valid Email Preferences');
        System.assertNotEquals(NULL, lstUser[0].Email_Preferences__c,'To test getUserEmailPreferences does not returns NULL Email Preferences');
        
        UserUtils.showException = true;        
        try{
            UserUtils.getUserEmailPreferences(lstUser[0].Id);
            System.assert(false, 'Should have thrown an exception');
        }catch(Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Exception message was wrong');
        }
    }
    
    @isTest
    public static void testGetShipToOverrideTonnageLimit(){
        List <Ship_To_Override_Tonnage_Limits__c > lstTonnageShipTo = [SELECT Ship_To__c FROM Ship_To_Override_Tonnage_Limits__c WHERE Ship_To__c LIKE '00021212%'];
        
        List <Ship_To_Override_Tonnage_Limits__c > result = UserUtils.getShipToOverrideTonnageLimit();
        
        System.assertEquals(result, lstTonnageShipTo,'To test getShipToOverrideTonnageLimit returns valid Ship_To_Override_Tonnage_Limits__c');
        System.assertNotEquals(NULL, lstTonnageShipTo,'To test override shipto custom setting not contains data');
        System.assertNotEquals(NULL, result,'To test getShipToOverrideTonnageLimit does not return null Ship_To_Override_Tonnage_Limits__c');
        
        UserUtils.showException = true;        
        try{
            UserUtils.getShipToOverrideTonnageLimit();
            System.assert(false, 'Should have thrown an exception');
        }catch(Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Exception message was wrong');
        }
    }
    
    @isTest
    public static void testGetShipToOverrideGallonLimit(){
        List <Ship_To_With_Gallon_Products__c > lstGallonShipTo = [SELECT ShipTo__c FROM Ship_To_With_Gallon_Products__c WHERE ShipTo__c LIKE '00021212%'];
        
        List <Ship_To_With_Gallon_Products__c > result = UserUtils.getShipToOverrideGallonLimit();
        
        System.assertEquals(result, lstGallonShipTo,'To test getShipToOverrideGallonLimit returns valid Ship_To_With_Gallon_Products__c');
        System.assertNotEquals(NULL, result,'To test getShipToOverrideGallonLimit does not return null Ship_To_With_Gallon_Products__c');
        System.assertNotEquals(NULL, lstGallonShipTo,'To test override shipto custom setting not contains data');
        
        UserUtils.showException = true;        
        try{
            UserUtils.getShipToOverrideGallonLimit();
            System.assert(false, 'Should have thrown an exception');
        }catch(Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Exception message was wrong');
        }
    }
    
    @isTest
    public static void testGetPlantCodesForValidation(){
        List<Ordering_Rule__c> lstOrderingRule = [SELECT Ordering_Rule_Days__c,No_Weekend_Order__c, Product_Code__c, Plant_Code__c FROM Ordering_Rule__c WHERE Plant_Code__c ='AN' OR Plant_Code__c ='RV'];
        
        List<Ordering_Rule__c> result = UserUtils.getPlantCodesForValidation('AN', '12345');
        
        System.assertNotEquals(Null, result,'To test getPlantCodesForValidation does not return empty');
        
        for(Ordering_Rule__c ordruleObj : result){
            System.assertEquals(ordruleObj.Ordering_Rule_Days__c , lstOrderingRule[0].Ordering_Rule_Days__c,'To test getPlantCodesForValidation returns valid Ordering_Rule_Days__c');
            System.assertEquals(ordruleObj.No_Weekend_Order__c , lstOrderingRule[0].No_Weekend_Order__c,'To test getPlantCodesForValidation returns valid No_Weekend_Order__c');
            
            System.assertNotEquals(NULL, lstOrderingRule[0].Ordering_Rule_Days__c,'To test getPlantCodesForValidation should not returns null');
            System.assertNotEquals(NULL, lstOrderingRule[0].No_Weekend_Order__c,'To test getPlantCodesForValidation  should not returns null');
        }
        
        UserUtils.showException = true;        
        try{
            UserUtils.getPlantCodesForValidation('RV', '215132');
            System.assert(false, 'Should have thrown an exception');
        }catch(Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Exception message was wrong');
        }
    }
    
    @isTest
    public static void testGetAccountDetails(){
        List<Account> lstAccount = [SELECT Id, Name, SPC_Email__c FROM Account WHERE Name='1215-Test Account' LIMIT 1];
        List<User> lstUser= [SELECT Id, ContactId, AccountId, FirstName, LastName,Phone,Email FROM User WHERE  Email =: lstAccount[0].SPC_Email__c];
        
        User spcUser = UserUtils.getSPCDetails(lstAccount[0].Id);
        System.assertNotEquals(NULL, spcUser, 'If SPC email present in the user object, it will return a value');
        
        System.assertEquals(spcUser.Id, lstUser[0].Id, 'To getaccountDetails returns user Id and list of user should be same'); 
        System.assertEquals(spcUser.ContactId, lstUser[0].ContactId, 'To getaccountDetails returns contactId and list should be return same contact Id'); 
        System.assertEquals(spcUser.FirstName, lstUser[0].FirstName, 'To getaccountDetails returns firstName and list should be return same first name');
        System.assertEquals(spcUser.LastName, lstUser[0].LastName, 'To getaccountDetails returns last name and list should be return same last name');
        System.assertEquals(spcUser.Phone, lstUser[0].Phone, 'To getaccountDetails returns phone and list should be return same phone');
        System.assertEquals(spcUser.Email, lstAccount[0].SPC_Email__c, 'To getaccountDetails returns Email and list SPC email should be same');
        System.assertEquals(spcUser.AccountId, lstAccount[0].Id, 'To getaccountDetails returns users accountId and accountId should be same');
        
        System.assertNotEquals(NULL, spcUser.Id, 'To getaccountDetails should not return null'); 
        System.assertNotEquals(NULL, spcUser.ContactId, 'To getaccountDetails returns contactId and list should be return same contact Id'); 
        System.assertNotEquals('8734', spcUser.FirstName, 'To getaccountDetails not returns a any number it return name');
        System.assertNotEquals('989485', spcUser.LastName, 'To getaccountDetails not returns a any number it return name');
        System.assertNotEquals('test31', spcUser.Phone, 'To getaccountDetails  phone and list should be return same phone');
        System.assertNotEquals(NULL, spcUser.Email, 'To getaccountDetails returns Email and list SPC email should be same');
        System.assertNotEquals('test2328', spcUser.AccountId, 'To getaccountDetails returns users accountId and accountId should be same');
        
        UserUtils.showException = true;        
        try{
            UserUtils.getSPCDetails(NULL);
            System.assert(false, 'Should have thrown an exception');
        }catch(Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Exception message was wrong');
        }
    }
    
}