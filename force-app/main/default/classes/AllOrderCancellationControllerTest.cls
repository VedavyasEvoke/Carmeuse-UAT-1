/******************************************************************************************************************************************************
Author : Ravikant Vijapure
Description :AllOrderCancellationEmailComponent visualforce component controller apex class test class.
-------------------------------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 	  DATE 		   AUTHOR 			  DETAIL
1           CARMEUSE-159     22/01/2024    Ravikant Vijapure  AllOrderCancellationEmailComponent visualforce component controller apex class test class.
********************************************************************************************************************************************************/

@isTest
public with sharing class AllOrderCancellationControllerTest {   
    @TestSetup
    public static void setUp(){
        TriggerConfiguration.setDoNotRunTrigger();
        Account testAccount = new Account(Name='Test Account',BillingStreet='Test Street', BillingCountry='United States', BillingPostalCode='44444', AccountExternalNumber__c = '0000002123');
        insert testAccount;

        Contact conObj = new Contact(LastName='Test Contact 1', AccountId=testAccount.Id, Email='test123@gmail.com');
        insert conObj;

        Order objOrder = new Order();
        objOrder.AccountId= testAccount.Id;
        objOrder.Status='Draft';
        objOrder.EffectiveDate=date.today();
        objOrder.External__c = true;
        objOrder.OrderedDate = Date.today();
        insert objOrder;

        OrderDeliveryGroup objODG = new OrderDeliveryGroup();
        objODG.OrderId=objOrder.id;
        objODG.DeliverToName='The Shipping Address';
        objODG.AccessCode__c = '123';
        objODG.BOLNumber__c = '';
        objODG.AccountExternalNumber__c = '123';
        objODG.MaterialNumber__c = '000000000000010325';
        objODG.DesiredDeliveryDate = Date.today(); 
        objODG.Quantity__c = 1;
        objODG.PONumber__c = '123';
        objODG.Description = '';
        objODG.DeliveryInstructions = '';
        objODG.ShipmentTonnage__c = 900;        
        objODG.ShipmentStatus__c = 'Cancelled'; 
        objODG.ShipmentWeight__c = '100';
        objODG.ShipmentSize__c = 10;
        objODG.ShipmentSizeType__c = '25';
        objODG.ShipmentDateTime__c = Date.today();
        objODG.DeliverToStreet = '2 Paget';
        objODG.DeliverToCity =  'New York';
        objODG.DeliverToState =  'New York 11';
        objODG.DeliverToPostalCode =  '12345';  
        objODG.DeliverToCountry = 'United States';
        objODG.DeliverToName = 'TestAccount';
        objODG.Is_All_Cancelled__c = true;
        insert objODG;        
    }

    @isTest
    public static void testGetLstOrderDeliveryGroup(){
        List<Account> lstAccount = [SELECT Id, Name FROM Account WHERE Name ='Test Account'];
        List<Order> lstOrder = [SELECT Id, AccountId FROM Order WHERE AccountId IN : lstAccount];
        List<OrderDeliveryGroup> lstOrderDeliveryGroup = [SELECT Id,QuoteNumber__c,AccountExternalNumber__c,PONumber__c,Cancel_Requested_By__r.Name,Cancel_Requested_On__c,OrderDeliveryGroupNumber,AccessCode__c,ShipmentTonnage__c,DesiredDeliveryDate, OrderId FROM OrderDeliveryGroup WHERE OrderId IN : lstOrder AND ShipmentStatus__c = 'Cancelled' AND Is_All_Cancelled__c = TRUE];

        AllOrderCancellationController controller = new AllOrderCancellationController();
        controller.osId = lstOrderDeliveryGroup[0].OrderId;

        List<OrderDeliveryGroup> result = controller.getlstOrderDeliveryGroup();

        System.assertEquals(1, lstOrderDeliveryGroup.size());
        System.assertNotEquals(null, lstOrderDeliveryGroup.size());

        System.assertEquals(1, result.size());
        System.assertNotEquals(null, result.size());

        //Positive Scenario
        System.assertEquals(lstOrderDeliveryGroup[0].Id, result[0].Id,'Check Order Deliver Group Id is valid');
        System.assertEquals(lstOrderDeliveryGroup[0].QuoteNumber__c, result[0].QuoteNumber__c,'Check QuoteNumber__c is as equal to expected QuoteNumber__c');
        System.assertEquals(lstOrderDeliveryGroup[0].AccountExternalNumber__c, result[0].AccountExternalNumber__c,'Check AccountExternalNumber__c is as equal to expected AccountExternalNumber__c');
        System.assertEquals(lstOrderDeliveryGroup[0].PONumber__c, result[0].PONumber__c,'Check PONumber__c is as equal to expected PONumber__c');
        System.assertEquals(lstOrderDeliveryGroup[0].OrderDeliveryGroupNumber, result[0].OrderDeliveryGroupNumber,'Check OrderDeliveryGroupNumber is as equal to expected OrderDeliveryGroupNumber');
        System.assertEquals(lstOrderDeliveryGroup[0].AccessCode__c, result[0].AccessCode__c,'Check AccessCode__c is as equal to expected AccessCode__c');
        System.assertEquals(lstOrderDeliveryGroup[0].ShipmentTonnage__c, result[0].ShipmentTonnage__c,'Check ShipmentTonnage__c is as equal to expected ShipmentTonnage__c');
        System.assertEquals(lstOrderDeliveryGroup[0].DesiredDeliveryDate, result[0].DesiredDeliveryDate,'Check DesiredDeliveryDate is as equal to expected DesiredDeliveryDate');

        //Negative Scenario
        System.assertNotEquals(null, result[0].Id,'Check Id is not invalid');
        System.assertNotEquals('432342', result[0].QuoteNumber__c,'Check QuoteNumber__c is not invalid');
        System.assertNotEquals('23133', result[0].AccountExternalNumber__c,'Check AccountExternalNumber__c is not invalid');
        System.assertNotEquals('131', result[0].PONumber__c,'Check PONumber__c is not invalid');
        System.assertNotEquals('67342', result[0].OrderDeliveryGroupNumber,'Check OrderDeliveryGroupNumber is not invalid');
        System.assertNotEquals('32323', result[0].AccessCode__c,'Check AccessCode__c is not invalid');
        System.assertNotEquals(898, result[0].ShipmentTonnage__c,'Check ShipmentTonnage__c is not invalid');
        System.assertNotEquals(null, result[0].DesiredDeliveryDate,'Check DesiredDeliveryDate is not invalid');
    }   

}