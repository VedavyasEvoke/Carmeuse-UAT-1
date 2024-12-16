/*---------------------------------------------------------------------------------------------------------------------------------------------
Author : Ravikant Vijapure.
Description : Test class for OrderDetailsUtility class.
-----------------------------------------------------------------------------------------------------------------------------------------------
VERSION    ISSUE NUMBER 	    DATE 		    AUTHOR 			 				DETAIL
1.0        CARMEUSE-188       02/12/2024    Ravikant Vijapure   	Test class for OrderDetailsUtility class.
-----------------------------------------------------------------------------------------------------------------------------------------------*/
@IsTest
public with sharing class OrderDetailsUtilityTest {
    @isTest(SeeAllData=true)
    public static void testOrderDetailsUtilityMethods() {
      
        WebStore lstWebStore = TestDataFactory.createWebStore();
        ProductCatalog objCatalog = TestDataFactory.createProductCatalog();
        ProductCategory objCatagory = TestDataFactory.createProductCategory(objCatalog.Id);
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        Test.StartTest();
        List<Account> lstAccounts = TestDataFactory.createAccounts(1);
        List<Product2> lstProducts =  TestDataFactory.createProduct(99, 1);
        Test.StopTest();
        
        List<ContactPointAddress> lstShippingAddress = TestDataFactory.createContactPointAddress(lstAccounts, 1);
        List<WebCart> lstCart = TestDataFactory.createWebCart(lstWebStore.Id, lstAccounts, false, 1);
        List<CartDeliveryGroup> lstCartDeliveryGroup = TestDataFactory.createCartDeliveryGroup(lstProducts, lstCart[0].Id, lstShippingAddress[0].Id, 25);
        List<CartItem>  lstCartItem = TestDataFactory.createCartItem(lstCartDeliveryGroup, lstCart[0].Id, 1);
        List<CartCheckoutSession> lstCheckOutSessions = TestDataFactory.createCartCheckout(lstCart, 1);
        List<Order> lstOrder = TestDataFactory.createOrder(lstAccounts, lstWebStore.Id, 5); 
        
        OrderDeliveryMethod odgMethod = TestDataFactory.createOrderDeliveryMethod();
        List<OrderDeliveryGroup> lstOrderDeliveryGroup = TestDataFactory.createOrderDeliveryGroup(lstOrder, odgMethod.Id, 5);
        List<OrderItem> lstOrderItem = TestDataFactory.createOrderItem(lstOrderDeliveryGroup, lstOrder, lstProducts);
        List<Order> lstOrderActivated = new List<Order>();
        for(Integer index = 0; index < 5; index ++){
            Order objUpdateOrder = new Order();
            objUpdateOrder.Id = lstOrder[index].Id;
            objUpdateOrder.Status = 'Activated';
            lstOrderActivated.add(objUpdateOrder);
        }
        
        update lstOrderActivated;
        
        Map<Id,Order> mapOrderActivated =new Map<Id,Order>(lstOrderActivated);

        for(Integer index = 0; index < 5; index ++){
            ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
            osir.orderId = lstOrder[index].Id;
            osir.orderLifeCycleType = 'UNMANAGED';
            ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        }
        
        List<OrderSummary> lstOrderSummary = [SELECT Id,OriginalOrderId,AccountId,TotalAmount,Status,OrderNumber,OrderedDate,Account.Name,Account.AccountExternalNumber__c,PoNumber,Description,BillingCity,BillingCountry,
                                              BillingState,BillingStreet,BillingPostalCode,OwnerId FROM OrderSummary WHERE OriginalOrderId IN : mapOrderActivated.keySet()];
        
        List<Id> lstOrderSummaryId = new List<Id>();
        Set<String> expectedAccessCodes = new Set<String>();
        Set<String> expectedPONumbers = new Set<String>();
        for(OrderSummary objOrderSummary : lstOrderSummary){
            lstOrderSummaryId.add(objOrderSummary.Id);
        }
        for (OrderDeliveryGroup objOrderDeliveryGroup : lstOrderDeliveryGroup) {
            expectedAccessCodes.add(objOrderDeliveryGroup.AccessCode__c);
            expectedPONumbers.add(objOrderDeliveryGroup.PONumber__c);
        }
	
        Assert.isNotNull(lstWebStore, 'WebStore should be created');
        Assert.areEqual(lstAccounts.size(), 1, '1 Accounts should be created');
        Assert.areEqual(lstProducts.size(), 1, '1 Products should be created');
        Assert.areEqual(lstShippingAddress.size(), 1, '1 Shipping Address should be created');
        Assert.areEqual(lstCart.size(), 1, '1 WebCart should be created');
        Assert.areEqual(lstCartDeliveryGroup.size(), 25, '25 Cart Delivery Group should be created');
        Assert.areEqual(lstCartItem.size(), 1, '1 Cart Item should be created');
        Assert.areEqual(lstCheckOutSessions.size(), 1, '1 Cart Checkout Session should be created');
        Assert.areEqual(lstOrder.size(), 5, 'Order list should contain exactly 5 order');
        Assert.isNotNull(odgMethod, 'Order Delivery Method should be created');
        Assert.areEqual(lstOrderDeliveryGroup.size(), 25, '25 Order Delivery Group should be created');
        Assert.areEqual( lstOrderItem.size(), 25, '25 Order Item should be created');
        Assert.isTrue(!lstOrderSummary.isEmpty(),'OrderSummary list should not be empty');
        
        List<OrderDeliveryGroupSummary> lstOrderDeliveryGroupSummaries = OrderDetailsUtility.getAccessCodeOrPOAllSummaries(lstOrderDeliveryGroup[0].AccessCode__c,lstOrderDeliveryGroup[0].PONumber__c, lstOrderSummaryId);
        Assert.isTrue(!lstOrderDeliveryGroupSummaries.isEmpty(),'OrderDeliveryGroupSummary list should not be empty');
        
        for(OrderDeliveryGroupSummary objODGS : lstOrderDeliveryGroupSummaries){
            Assert.isTrue(expectedAccessCodes.contains(objODGS.AccessCode__c), 'AccessCode ' + objODGS.AccessCode__c + ' should be one of the expected AccessCodes');
            Assert.isTrue(lstOrderSummaryId.contains(objODGS.OrderSummaryId), 'OrderSummaryId ' + objODGS.OrderSummaryId + ' should be one of the passed OrderSummaryIds');
            Assert.isTrue(expectedPONumbers.contains(objODGS.PONumber__c), 'PONumber ' + objODGS.PONumber__c + ' should be one of the expected PONumbers');

            Assert.isNotNull(objODGS.AccessCode__c, 'Access Code should not be null');
            Assert.isNotNull(objODGS.PONumber__c, 'PO Number should not be null');
        }


        List<OrderSummary> lstOrderSummaries = OrderDetailsUtility.getOrderSummariesByAccountId(lstAccounts[0].Id);
        Assert.isTrue(!lstOrderSummaries.isEmpty(),'OrderSummary list should not be empty');

        for(OrderSummary objOS : lstOrderSummaries){
            Assert.isTrue(objOS.AccountId == lstOrderSummary[0].AccountId, 'OrderSummary Account Id should be same as Order Account Id');
            Assert.areEqual('Created',objOS.Status, 'Status of OrderSummary should be Created');

            Assert.isNotNull( objOS.Status, 'OrderSummary Status should not be null');
            Assert.isNotNull(objOS.OrderNumber, 'OrderSummary Order Number should not be null');
            Assert.isNotNull(objOS.OrderedDate, 'OrderSummary Ordered Date should not be null');
        }
        
        Date myDate = Date.today();
        Date newDeliveryDate = mydate.addDays(5);
        Boolean isUpdateDate = OrderDetailsUtility.updateOrderDeliveryDate(lstOrderDeliveryGroup[0].Id, lstOrderActivated[0].Id, newDeliveryDate);
        Assert.isTrue(isUpdateDate, 'If desired delivery date updated successfully then updateOrderDeliveryDate should return true');
        
        List<OrderDeliveryGroup> lstUpdatedODG = [SELECT Id, OrderId,  DesiredDeliveryDate, ShipmentStatus__c, Change_Requested_By__c, Change_Requested_On__c  FROM OrderDeliveryGroup WHERE Id =: lstOrderDeliveryGroup[0].Id AND OrderId =: lstOrderActivated[0].Id LIMIT 1];
        Assert.areEqual(lstOrderDeliveryGroup[0].Id, lstUpdatedODG[0].Id, 'Order delivery group Id and updated odg Id should be same');
        Assert.areEqual(lstOrderActivated[0].Id, lstUpdatedODG[0].OrderId, 'Order Id and updated order should be same');
        Assert.areEqual(newDeliveryDate, lstUpdatedODG[0].DesiredDeliveryDate, 'Desired delivery date should be same as updated delivery date');
        Assert.areEqual('Change Requested', lstUpdatedODG[0].ShipmentStatus__c, 'Order delivery group status should be updated to Change Requested');

        Assert.isNotNull(lstUpdatedODG[0].ShipmentStatus__c, 'Shipment status should not be null.');
        Assert.isNotNull(lstUpdatedODG[0].DesiredDeliveryDate, 'Desired delivery date should not be null.');
        Assert.isNotNull(lstUpdatedODG[0].Change_Requested_By__c, 'Change requested by field should not be null');
        Assert.isNotNull(lstUpdatedODG[0].Change_Requested_On__c, 'Change requested on field should not be null');



        List<Product2> result = OrderDetailsUtility.getProdutDetails(lstProducts[0].StockKeepingUnit);
        Assert.isTrue(!result.isEmpty(),'lstProduct list should not be empty');
        Assert.isFalse(result.isEmpty(), 'lstProduct list should not be empty');

        OrderDetailsUtility.throwException = true; 
        Boolean isUpdateDate1 = OrderDetailsUtility.updateOrderDeliveryDate(NULL, NULL, NULL);  
        Assert.areEqual(FALSE, isUpdateDate1, 'If delivery date, id, or order id is null metod returns false');  
        try{
            List<OrderDeliveryGroupSummary> lstOrderDeliveryGroupSummariesException = OrderDetailsUtility.getAccessCodeOrPOAllSummaries(NULL,NULL,NULL);
            Assert.areEqual(false, 'Should have thrown an exception');
        }catch(Exception e){
            Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception message was wrong');
        }
        try{
            List<OrderSummary> lstOrderSummariesException = OrderDetailsUtility.getOrderSummariesByAccountId(NULL);
            Assert.areEqual(false, 'Should have thrown an exception');
        }catch(Exception e){
            Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception message was wrong');
        }
        try{
            List<Product2> lstProductException = OrderDetailsUtility.getProdutDetails(NULL);
            Assert.areEqual(false, 'Should have thrown an exception');
        }catch(Exception e){
            Assert.isTrue(e.getMessage().contains('Script-thrown exception'), 'Exception message was wrong');
        }
    }
}