/*---------------------------------------------------------------------------------------------------------------------------------------------
Author : Ravikant Vijapure.
Description : Test class for B2BSplitShipmentTest class.
-----------------------------------------------------------------------------------------------------------------------------------------------
VERSION    ISSUE NUMBER 	    DATE 		    AUTHOR 			 				DETAIL
1          CARMEUSE-180       25/10/2024    Ravikant Vijapure   	Test class for B2BSplitShipmentTest class.
-----------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
public with sharing class B2BSplitShipmentTest {
    
    @testSetup
    public static void testData(){
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        Test.StartTest();
        WebStore store = TestDataFactory.createWebStore();
        List<Account> lstAccounts = TestDataFactory.createAccounts(1);   
        if (!lstAccounts.isEmpty()) {
            Account acc = lstAccounts[0];
            acc.Default_Delivery_Text__c='Test';
            acc.Default_Load_Volume__c=24;
            acc.DefaultPONumber__c = '456';
            acc.Default_Shipment_Type__c='Truck';
            
            update acc;
        }
        ProductCatalog objCatalog = TestDataFactory.createProductCatalog();
        ProductCategory objCategory = TestDataFactory.createProductCategory(objCatalog.Id);
        List<Product2> lstProducts = TestDataFactory.createProduct(99, 1); 
        Test.StopTest();
        List<PriceBook2> lstPriceBooks = TestDataFactory.createPricebook(lstAccounts, 1);
        List<ContactPointAddress> lstShippingAddress = TestDataFactory.createContactPointAddress(lstAccounts, 1);
        List<WebCart> lstCart = TestDataFactory.createWebCart(store.Id, lstAccounts, false, 1);
        List<CartDeliveryGroup> lstCartDeliveryGroup = TestDataFactory.createCartDeliveryGroup(lstProducts, lstCart[0].Id, lstShippingAddress[0].Id, 1);
        List<CartItem>  lstCartItem = TestDataFactory.createCartItem(lstCartDeliveryGroup, lstCart[0].Id, 1);
        if (!lstCartItem.isEmpty()) {
            CartItem items = lstCartItem[0];
            items.Product2Id = lstProducts[0].Id;
            update items;
        }
    }
    
    @isTest
    public static void testGetSplitShipmentDefaults() {
        Test.startTest();      
        Account objAccount = [SELECT Default_Delivery_Text__c,Default_Load_Volume__c,DefaultPONumber__c,Default_Shipment_Type__c FROM Account];
        WebCart objWebCart = [SELECT Id FROM WebCart];
        String getStringDefaultData = B2BSplitShipment.getSplitShipmentDefaults(objWebCart.Id);
        Test.stopTest();
        System.assertNotEquals(NULL, getStringDefaultData);
        
        //Positive Scenario
        System.assertEquals(TRUE, getStringDefaultData.contains(objAccount.Default_Delivery_Text__c),'Check getSplitShipmentDefaults returns Default_Delivery_Text__c');
        System.assertEquals(TRUE, getStringDefaultData.contains(objAccount.DefaultPONumber__c),'Check getSplitShipmentDefaults returns DefaultPONumber__c');
        System.assertEquals(TRUE, getStringDefaultData.contains(objAccount.Default_Shipment_Type__c),'Check getSplitShipmentDefaults returns Default_Shipment_Type__c');
        System.assertEquals(TRUE, getStringDefaultData.contains(String.valueOf(objAccount.Default_Load_Volume__c)),'Check getSplitShipmentDefaults returns Default_Load_Volume__c');
        //Negative Scenario
        System.assertNotEquals(False, getStringDefaultData.contains(objAccount.Default_Delivery_Text__c),'Check negative scenario for getSplitShipmentDefaults returns Default_Delivery_Text__c ');
        System.assertNotEquals(False, getStringDefaultData.contains(objAccount.DefaultPONumber__c),'Check negative scenario for getSplitShipmentDefaults returns DefaultPONumber__c ');
        System.assertNotEquals(False, getStringDefaultData.contains(objAccount.Default_Shipment_Type__c),'Check negative scenario for getSplitShipmentDefaults returns Default_Shipment_Type__c ');
        System.assertNotEquals(False, getStringDefaultData.contains(String.valueOf(objAccount.Default_Load_Volume__c)),'Check negative scenario for getSplitShipmentDefaults returns Default_Load_Volume__c ');
    }
    
    @IsTest
    public static void testSplitShipments() {
        Test.startTest(); 
        WebCart objWebCart = [SELECT Id FROM WebCart LIMIT 1];
        Product2 objPoduct2 = [SELECT Id FROM Product2 LIMIT 1];
        List<CartDeliveryGroup> lstCartDeliveryGroup = [SELECT Id,Quantity__c FROM CartDeliveryGroup];
        Map<Id, List<CartDeliveryGroup>> productIdToNewDeliveryGroups = new  Map<Id, List<CartDeliveryGroup>>();
        productIdToNewDeliveryGroups.put(objPoduct2.Id, lstCartDeliveryGroup);        
        
        List<CartItem> lstCartItem = [SELECT Id,Quantity,CartDeliveryGroupId FROM CartItem];
        System.assertEquals(1, lstCartItem.size());
        System.assertNotEquals(0, lstCartItem.size());
        System.debug('productIdToNewDeliveryGroups-->'+productIdToNewDeliveryGroups);
        B2BSplitShipment.splitShipments(productIdToNewDeliveryGroups,objWebCart.Id);
        Test.stopTest();
        
        //Postive Scenario
        System.assertEquals(lstCartDeliveryGroup.size(), lstCartItem.size(),'Cart Item should get created equal to number of Cart Delivery Group');
        System.assertEquals(lstCartDeliveryGroup[0].Id,lstCartItem[0].CartDeliveryGroupId,'Cart Delivery Group Id should get populated for Cart Item');      
        System.assertEquals(lstCartDeliveryGroup[0].Quantity__c,lstCartItem[0].Quantity,'Quantity of Cart Item should equal to Cart Delivery Group Quantity');
        
        //Negative Scenario        
        System.assertNotEquals(null, lstCartItem.size(),'Check cart item size should not be 0');
        System.assertNotEquals('2132321', lstCartItem[0].CartDeliveryGroupId,'No other Id than Cart Delivery Group should get populated on Cart Item');
        System.assertNotEquals(1212, lstCartItem[0].Quantity,'Quantity of Cart Item should not be other than Cart Delivery Group Quantity');        
    }
    
    @isTest
    public static void testQuickSaveSplitShipments() {
        Test.startTest(); 
        WebCart objWebCart = [SELECT Id FROM WebCart LIMIT 1];
        CartItem objCartItem = [SELECT Id,List_Of_Line_Items__c FROM CartItem WHERE CartId = :objWebCart.Id LIMIT 1];
        System.assertEquals(NULL, objCartItem.List_Of_Line_Items__c);
        String testPayload = '{"'+objCartItem.Id+'":'+
            '{"ProductDetail":{"Product":"'+objCartItem.Id+'","startDate":"2023-05-03T00:00:00.000Z","endDate":"2023-05-04T00:00:00.000Z","loadVolume":25,"shippingMode":"38","shippingType":"Oversize TLR Pneu","shippingCondition":"Deliv.(carriers)","quantity":1,"poNumber":"21237745","productId":null,"deliveryText":"Test","isFile":null,"plantCode":"BU","productCode":"13714","validFrom":null,"validTo":null,"carrier":null},'+
            '"listOfLineItem":[{"Tonnage":25,"Quantity":1,"Product":"'+objCartItem.Id+'","PoNumber":"21237745","index":0,"DeliveryText":"Test","deliveryDay":"Wednesday","deliveryDate":"2023-05-03","CartItemId":"3946291672146758"}]}}';
        B2BSplitShipment.quickSaveSplitShipments(objWebCart.Id, testPayload);    
        objCartItem = [SELECT Id,List_Of_Line_Items__c FROM CartItem WHERE CartId = :objWebCart.Id LIMIT 1];
        System.assertNotEquals(NULL, objCartItem.List_Of_Line_Items__c,'quickSaveSplitShipments should not return NULL List_Of_Line_Items__c ');
        
        String getStringDefaultData = B2BSplitShipment.getSplitShipmentDefaults(objWebCart.Id);
        System.assertEquals(TRUE, getStringDefaultData.contains('listofLineItems'),'quickSaveSplitShipments should return listofLineItems');
        System.assertNotEquals(False, getStringDefaultData.contains('listofLineItems'),'quickSaveSplitShipments should return listofLineItems');
        
        try{
            String testWrongPayload = 
                '"' +
                '{"ProductDetail":' +
                '{"Product":"' + cartItem.Id + '","startDate":"2021-05-03","endDate":"2021-05-04","loadVolume":"5","shippingMode":"25","quantity":"1","poNumber":"1","deliveryText":"1"},' +
                '"listOfLineItem":[' + 
                '{"Product":"' + cartItem.Id + '","deliveryDate":"2021-05-03","Quantity":"1","Tonnage":"5","DeliveryText":"1","PoNumber":"1","index":0},' + 
                '{"Product":"' + cartItem.Id + '","deliveryDate":"2021-05-04","Quantity":"1","Tonnage":"5","DeliveryText":"1","PoNumber":"1","index":1}' + 
                ']' + 
                '}"';
            
            B2BSplitShipment.quickSaveSplitShipments(objWebCart.Id, testWrongPayload);
        }catch(Exception exp){
            System.assertEquals('Script-thrown exception', exp.getMessage(),'Check exception is thrown for invalid quickSaveSplitShipments inputs');
        }        
    }
    @isTest
    public static void testWrapperClass(){
        B2BSplitShipment.QuickSaveProductDetails ObjQuickSaveProductDetails = new B2BSplitShipment.QuickSaveProductDetails();
        ObjQuickSaveProductDetails.CartItemId = null;
        ObjQuickSaveProductDetails.startDate = null;
        ObjQuickSaveProductDetails.endDate = null;
        ObjQuickSaveProductDetails.unitOfMeasure = null;
        ObjQuickSaveProductDetails.shippingMode = null;
        ObjQuickSaveProductDetails.loadVolume = null;
        ObjQuickSaveProductDetails.quantity = null;
        ObjQuickSaveProductDetails.poNumber = null;
        ObjQuickSaveProductDetails.DeliveryText = null;
        ObjQuickSaveProductDetails.shippingType = null;
        ObjQuickSaveProductDetails.shippingCondition = null;
        ObjQuickSaveProductDetails.isFile = null;
        ObjQuickSaveProductDetails.plantCode = null;
        ObjQuickSaveProductDetails.productCode= null;
        ObjQuickSaveProductDetails.validFrom = null;
        ObjQuickSaveProductDetails.validTo = null;
        System.assertNotEquals(NULL, ObjQuickSaveProductDetails,'Wrapper class QuickSaveProductDetails object should not be null');
        
        B2BSplitShipment.QuickSaveShipmentLineItem ObjQuickSaveShipmentLineItem = new B2BSplitShipment.QuickSaveShipmentLineItem();
        ObjQuickSaveShipmentLineItem.Product = null;
        ObjQuickSaveShipmentLineItem.CartItemId = null;
        ObjQuickSaveShipmentLineItem.deliveryDate = null;
        ObjQuickSaveShipmentLineItem.deliveryDay = null;
        ObjQuickSaveShipmentLineItem.Quantity = null;
        ObjQuickSaveShipmentLineItem.Tonnage = null;
        ObjQuickSaveShipmentLineItem.DeliveryText = null;
        ObjQuickSaveShipmentLineItem.PoNumber = null;
        ObjQuickSaveShipmentLineItem.index = null;
        System.assertNotEquals(NULL, ObjQuickSaveShipmentLineItem,'Wrapper class QuickSaveShipmentLineItem object should not be null');
    }
}