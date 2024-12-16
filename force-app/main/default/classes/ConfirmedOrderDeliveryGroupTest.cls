/************************************************************************************************************************************
Author : Priyanka Shinde
Description :OrderSummaryEmailTemplate visualforce component controller apex class test class.
----------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 	  DATE 		   AUTHOR 			  DETAIL
1.0.1       CARMEUSE-159    29/01/2024    Ravikant Vijapure   OrderSummaryEmailTemplate visualforce component controller apex class test class.
********************************************************************************************************************************/

@isTest
public with sharing class ConfirmedOrderDeliveryGroupTest {
    @TestSetup
    public static void demoData(){
        TriggerConfiguration.setDoNotRunTrigger();
        
       	Account testAccount = new Account(Name='TestAccount',BillingStreet='Test Street', BillingCountry='United States', BillingPostalCode='44444', AccountExternalNumber__c = '000123');
        insert testAccount;
        
        Product2 testPrimaryProduct = new Product2(Name = 'HiCal QL Pulv W/Flo Aid Bulk',
                                                   Family = 'Lime', MaterialNumber__c = '000000000000010325-000123-00012348',StockKeepingUnit = '000000000000010325-000123-00012348',ProductCode = '10325',Plant_code__c='TEST');
        insert testPrimaryProduct;
        
        WebStore testWebStore = new WebStore(Name='Carmeuse Customer Portal');
        insert testWebStore;
        
        Product2 testDuplicateProduct = new Product2(Name = 'HiCal QL Pulv W/Flo Aid Bulk',
                                                     Family = 'Lime', MaterialNumber__c = '000000000000010325-000123-00012349',StockKeepingUnit = '000000000000010325-000123-00012349',ProductCode = '10325',Plant_code__c='TEST');
        insert testDuplicateProduct;
        
        Id stdPricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrimaryPriceEntry = new PricebookEntry(
            Pricebook2Id = stdPricebookId, Product2Id = testPrimaryProduct.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrimaryPriceEntry;
        
        PricebookEntry standardDuplicateProduct = new PricebookEntry(
            Pricebook2Id = stdPricebookId, Product2Id = testDuplicateProduct.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardDuplicateProduct;
        
        Pricebook2 customPriceBook = new Pricebook2 (Name = 'PB-TestAccount',  IsActive = true);
        insert customPriceBook;
        
        Pricebook2 duplicateCustomPriceBook = new Pricebook2 (Name = 'PB-TestAccount Duplicate',  IsActive = true);
        insert duplicateCustomPriceBook;
        
        PricebookEntry customPriceBookEntry = new PricebookEntry(
            Pricebook2Id = customPriceBook.Id, Product2Id = testPrimaryProduct.Id,
            UnitPrice = 10000, IsActive = true ,ValidFrom__c = Date.today()+1,ValidTo__c=Date.today()+9);
        insert customPriceBookEntry;
        
        PricebookEntry customDuplicatePriceBookEntry = new PricebookEntry(
            Pricebook2Id = customPriceBook.Id, Product2Id = testDuplicateProduct.Id,
            UnitPrice = 10000, IsActive = true ,ValidFrom__c = Date.today()+10,ValidTo__c=Date.today()+70,Quote_Number__c='Update');
        insert customDuplicatePriceBookEntry;       
        
        SalesChannel testSalesChannelObj = new SalesChannel(SalesChannelName = 'SAP', Description = 'SAP');
        insert testSalesChannelObj; 
        
        BuyerAccount testBuyerAccount = new BuyerAccount(name='test', BuyerId=testAccount.Id, IsActive=true);
        insert testBuyerAccount;
        
        BuyerGroup testBuyerGroup = new BuyerGroup(Name='buyerGroupTest');
        insert testBuyerGroup;
        
        BuyerGroupMember testBuyerGroupMember = new BuyerGroupMember(BuyerId=testBuyerAccount.BuyerId,BuyerGroupId=testBuyerGroup.Id);
        insert testBuyerGroupMember;
        
        BuyerGroupPricebook testBuyerGroupPriceBook = new BuyerGroupPricebook();
        testBuyerGroupPriceBook.BuyerGroupId = testBuyerGroup.Id;
        testBuyerGroupPriceBook.Pricebook2Id = customPriceBook.Id;
        testBuyerGroupPriceBook.IsActive = TRUE;
        insert testBuyerGroupPriceBook;
        
        BuyerGroupPricebook testDuplicateBuyerGroupPriceBook = new BuyerGroupPricebook();
        testDuplicateBuyerGroupPriceBook.BuyerGroupId = testBuyerGroup.Id;
        testDuplicateBuyerGroupPriceBook.Pricebook2Id = duplicateCustomPriceBook.Id;
        testDuplicateBuyerGroupPriceBook.IsActive = TRUE;
        insert testDuplicateBuyerGroupPriceBook;

        WebStorePricebook testWebStorePricebook = new WebStorePricebook ( IsActive = true, Pricebook2Id = customPriceBook.Id, WebStoreId = testWebStore.Id );
        insert testWebStorePricebook;
        
        CommerceEntitlementPolicy testCommerceEntitlementPolicy = new CommerceEntitlementPolicy(Name = 'Test Policy', IsActive = true, CanViewProduct = true);
        insert testCommerceEntitlementPolicy;
        
        CommerceEntitlementProduct testCommerceEntitlementProduct = new CommerceEntitlementProduct(PolicyId = testCommerceEntitlementPolicy.Id, ProductId = testPrimaryProduct.Id);
        insert testCommerceEntitlementProduct;
        
        CommerceEntitlementBuyerGroup testCommerceEntitlementBuyerGroup = new CommerceEntitlementBuyerGroup(PolicyId = testCommerceEntitlementPolicy.Id, BuyerGroupId = testBuyerGroup.Id);
        insert testCommerceEntitlementBuyerGroup;
        
        WebStoreBuyerGroup testWebStoreBuyerGroup = new WebStoreBuyerGroup(BuyerGroupId=testBuyerGroup.Id, WebStoreId= testWebStore.Id);
        insert testWebStoreBuyerGroup;
        
        List<WebStoreNetwork> community = [SELECT NetworkId FROM WebStoreNetwork WHERE WebStoreId = :testWebStore.Id];
        
        WebCart testWebCart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert testWebCart;
        
        CartDeliveryGroup testCartDeliveryGroup = new CartDeliveryGroup(CartId=testWebCart.Id, Name='Default Delivery',DesiredDeliveryDate = Date.today());
        insert testCartDeliveryGroup;
        
        CartItem testCartItem = new CartItem(CartId=testWebCart.Id, Sku='000000000000010325-000123-00012348',TotalPrice=10.00, SalesPrice=10.00, Quantity=1.0, Type='Product', Name='HiCal QL Pulv W/Flo Aid Bulk', CartDeliveryGroupId=testCartDeliveryGroup.Id);
        insert testCartItem;
        
        CartCheckoutSession  testCartCheckoutSession = new CartCheckoutSession(WebCartId = testWebCart.Id, IsArchived = false, Name = testWebCart.Name, State = 'Order Confirmation' );
        insert testCartCheckoutSession;
        
        List<Order> lstOrder = new List<Order>();
        for(Integer iIndex = 0 ; iIndex <50; iIndex++){
            Order testOrder = new Order();
            testOrder.AccountId= testAccount.Id;  
            testOrder.SalesStoreId= testWebStore.Id; 
            testOrder.Status='Draft';
            testOrder.EffectiveDate=date.today();
            testOrder.External__c = true;
            testOrder.OrderedDate=Date.Today();
            lstOrder.add(testOrder);
        }
        insert lstOrder;
   
        OrderDeliveryMethod objOrderDeliveryMethod = new OrderDeliveryMethod(Name = 'Default Delivery Method');
        insert objOrderDeliveryMethod;
        
        List<OrderDeliveryGroup> lstOrderDeliveryGroup = new List<OrderDeliveryGroup>();        
        for(Integer iIndex = 0 ; iIndex < 10; iIndex++){
            OrderDeliveryGroup testOrderDeliveryGroup = new OrderDeliveryGroup();
            testOrderDeliveryGroup.OrderId=lstOrder[0].Id;
            testOrderDeliveryGroup.OrderDeliveryMethodId=objOrderDeliveryMethod.Id; 
            testOrderDeliveryGroup.DeliverToName='The Shipping Address';
            testOrderDeliveryGroup.AccessCode__c = '123';
            testOrderDeliveryGroup.BOLNumber__c = '';
            testOrderDeliveryGroup.AccountExternalNumber__c = '123';
            testOrderDeliveryGroup.MaterialNumber__c = '000000000000010325-000123-00012348';
            testOrderDeliveryGroup.DesiredDeliveryDate = Date.today()+iIndex+1; 
            testOrderDeliveryGroup.Quantity__c = 1;
            testOrderDeliveryGroup.PONumber__c = '123';
            testOrderDeliveryGroup.Description = '';
            testOrderDeliveryGroup.DeliveryInstructions = '';
            testOrderDeliveryGroup.ShipmentTonnage__c = 900;        
            testOrderDeliveryGroup.ShipmentStatus__c = 'Confirmed'; 
            testOrderDeliveryGroup.ShipmentWeight__c = '100';
            testOrderDeliveryGroup.ShipmentSize__c = 10;
            testOrderDeliveryGroup.ShipmentSizeType__c = '25';
            testOrderDeliveryGroup.ShipmentDateTime__c = Date.today(); 
            testOrderDeliveryGroup.DeliverToName = 'TestAccount';
            testOrderDeliveryGroup.DeliverToCity =  'New York';
            testOrderDeliveryGroup.DeliverToCountry = 'United States';
            testOrderDeliveryGroup.DeliverToState =  'New York';
            testOrderDeliveryGroup.DeliverToStreet = '2 Paget';
            testOrderDeliveryGroup.DeliverToPostalCode =  '12345';
            lstOrderDeliveryGroup.add(testOrderDeliveryGroup);
        }       
        insert lstOrderDeliveryGroup;        
        
        List<OrderItem> lstobjOrderItem = new List<OrderItem>();
        for(OrderDeliveryGroup objOD : lstOrderDeliveryGroup){
            OrderItem objOrderItem = new OrderItem();
            objOrderItem.OrderId=objOD.OrderId;
            objOrderItem.OrderDeliveryGroupId = objOD.Id; 
            objOrderItem.Product2Id=testPrimaryProduct.Id; 
            objOrderItem.Quantity=1;
            objOrderItem.ListPrice=999;
            objOrderItem.UnitPrice=999;
            objOrderItem.TotalLineAmount=999;
            objOrderItem.Type='Order Product';
            lstobjOrderItem.add(objOrderItem);
        }
        insert lstobjOrderItem;  
    }
    
    @isTest
    public static void testgetlstOrderItems(){
        List<Order> lstOrder = [SELECT Id FROM Order LIMIT 1];
		List<OrderItem>  testOrderItems = [SELECT Id, OrderId, OrderDeliveryGroupId, Product2Id, ListPrice, UnitPrice, TotalLineAmount FROM OrderItem WHERE OrderId =: lstOrder[0].Id]; 
        
        ConfirmedOrderDeliveryGroup objConfirmedOrderDeliveryGroup = new ConfirmedOrderDeliveryGroup();
        objConfirmedOrderDeliveryGroup.osId = lstOrder[0].Id;
        List<OrderItem> lstOrderItem = objConfirmedOrderDeliveryGroup.getlstOrderItems();
        
        System.assertEquals(testOrderItems.size(), lstOrderItem.size(), 'The number of returned OrderItems should match the number of created test OrderItems');
        System.assertNotEquals(0, lstOrderItem.size(), 'The list of OrderItems should not be empty');
        
        for(Integer i = 0; i < lstOrderItem.size(); i++){
            OrderItem returnedItem = lstOrderItem[i];
        	OrderItem expectedItem = testOrderItems[i];
            //Positive
            System.assertEquals(expectedItem.OrderId, returnedItem.OrderId, 'OrderId should match for OrderItem ');
            System.assertEquals(expectedItem.OrderDeliveryGroupId, returnedItem.OrderDeliveryGroupId, 'OrderDeliveryGroupId should match for OrderItem ');
            System.assertEquals(expectedItem.Product2Id, returnedItem.Product2Id, 'Product2Id should match for OrderItem ');
            //Negative
            System.assertNotEquals(NULL, returnedItem.OrderId, 'OrderId should match for OrderItem, it should not be null');
            System.assertNotEquals(NULL, returnedItem.OrderDeliveryGroupId, 'OrderDeliveryGroupId should match for OrderItem, it should not be null ');
            System.assertNotEquals(NULL, returnedItem.Product2Id, 'Product2Id should match for OrderItem, it should not be null ');
        }
    }
}