/*---------------------------------------------------------------------------------------------------------------------------------------------
Author : Ravikant Vijapure.
Description : Test class for the OrderDeliveryGroup trigger.
-----------------------------------------------------------------------------------------------------------------------------------------------
VERSION    ISSUE NUMBER 	    DATE 		    AUTHOR 			 				DETAIL
1.0        CARMEUSE-       06/12/2024    Ravikant Vijapure      Test class for the OrderDeliveryGroup trigger.
-----------------------------------------------------------------------------------------------------------------------------------------------*/

@IsTest(SeeAllData=true)
public with sharing class OrderDeliveryGroupExecutorTest {

    @isTest
    public static void testOrderDeliveryGroupBeforeInsert() {

        WebStore objStore = TestDataFactory.createWebStore();
        Test.startTest();
        List<Account> lstAccounts = TestDataFactory.createAccounts(5);
        Test.stopTest();
        List<Order> lstOrder = TestDataFactory.createOrder(lstAccounts, objStore.Id, 1);
        OrderDeliveryMethod objDeliveryMethod = TestDataFactory.createOrderDeliveryMethod();
        List<OrderDeliveryGroup> lstODG = TestDataFactory.createOrderDeliveryGroup(lstOrder, objDeliveryMethod.Id, 2);

        Assert.isTrue(!lstAccounts.isEmpty(), 'Account should be created');
        Assert.isTrue(!lstOrder.isEmpty(), 'Order should be created');
        Assert.isTrue(!lstODG.isEmpty(), 'OrderDeliveryGroup should be created');
        Assert.isNotNull(objStore, 'WebStore should be created');
        Assert.isNotNull(objDeliveryMethod, 'OrderDeliveryMethod should be created');

        List<Bill_Of_Lading__c> testBOL = [SELECT Id, BOL_Number__c FROM Bill_Of_Lading__c WHERE BOL_Number__c != Null];
        Assert.isTrue(!testBOL.isEmpty(), 'Bill_Of_Lading__c should be created');
    }

    @isTest
    public static void testOrderDeliveryGroupBeforeUpdate() {

        WebStore objStore = TestDataFactory.createWebStore();
        Test.startTest();
        List<Account> lstAccounts = TestDataFactory.createAccounts(5);
        Test.stopTest();
        List<Order> lstOrder = TestDataFactory.createOrder(lstAccounts, objStore.Id, 1);
        OrderDeliveryMethod objDeliveryMethod = TestDataFactory.createOrderDeliveryMethod();
        List<OrderDeliveryGroup> lstODG = TestDataFactory.createOrderDeliveryGroup(lstOrder, objDeliveryMethod.Id, 2);

        Assert.isTrue(!lstAccounts.isEmpty(), 'Account should be created');
        Assert.isTrue(!lstOrder.isEmpty(), 'Order should be created');
        Assert.isTrue(!lstODG.isEmpty(), 'OrderDeliveryGroup should be created');
        Assert.isNotNull(objStore, 'WebStore should be created');
        Assert.isNotNull(objDeliveryMethod, 'OrderDeliveryMethod should be created');

        List<Bill_Of_Lading__c> testBOL = [SELECT Id, BOL_Number__c FROM Bill_Of_Lading__c WHERE BOL_Number__c != Null];
        Assert.isTrue(!testBOL.isEmpty(), 'Bill_Of_Lading__c should be created');

        for(OrderDeliveryGroup objODG : lstODG) {
            objODG.BOLNumber__c = 'UpdatedBOLNumber';
        }
        update lstODG;

        List<Bill_Of_Lading__c> bolRecords = [SELECT Id, BOL_Number__c, Ac_GI_Date__c, Delivery_Quantity__c, Material__c FROM Bill_Of_Lading__c WHERE BOL_Number__c LIKE 'UpdatedBOLNumber%'];
        Assert.isTrue(bolRecords.size() == lstODG.size(), 'Bill_Of_Lading__c should be created');

        OrderDeliveryGroup objOrderDeliveryGroup = new OrderDeliveryGroup(OrderId=lstOrder[0].Id, DeliverToName='Test Address');
        insert objOrderDeliveryGroup;

        objOrderDeliveryGroup.BOLNumber__c = 'BOLNumber';
        update objOrderDeliveryGroup;

        List<Bill_Of_Lading__c> lstBOL = [SELECT Id, BOL_Number__c, Ac_GI_Date__c, Delivery_Quantity__c, Material__c FROM Bill_Of_Lading__c WHERE BOL_Number__c LIKE 'BOLNumber%']; 
        Assert.isTrue(!lstBOL.isEmpty(), 'Bill_Of_Lading__c should be created');
    }


    @isTest
    public static void testGetOrdersRollUpStatus(){
        WebStore objStore = TestDataFactory.createWebStore();
        Test.startTest();
        List<Account> lstAccounts = TestDataFactory.createAccounts(5);
        Test.stopTest();
        List<Order> lstOrder = TestDataFactory.createOrder(lstAccounts, objStore.Id, 1);
        OrderDeliveryMethod objDeliveryMethod = TestDataFactory.createOrderDeliveryMethod();

        List<OrderDeliveryGroup> lstOrderDeliveryGroup = new List<OrderDeliveryGroup>();
        Set<Id> setOrderIds = new Set<Id>();
        for (Order objOrder : lstOrder) {
            setOrderIds.add(objOrder.Id);
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Submitted', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Pending', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Confirmed', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Confirmed', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Confirmed', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
        }
        insert lstOrderDeliveryGroup;

        OrderDeliveryGroupExecutor objTriggerExecutor = new OrderDeliveryGroupExecutor();
        Map<Id, String> result = objTriggerExecutor.getOrdersRollUpStatus(setOrderIds);
        for (Order objOrder : lstOrder) {
            Assert.areEqual('Confirmed', result.get(objOrder.Id), 'Order should be confirmed for Order Id: ' + objOrder.Id);
        }
        Assert.isFalse(result.isEmpty(), 'Result should not be empty');
    }

    @isTest
    public static void testGetConfirmedAll(){
        WebStore objStore = TestDataFactory.createWebStore();
        Test.startTest();
        List<Account> lstAccounts = TestDataFactory.createAccounts(5);
        Test.stopTest();
        List<Order> lstOrder = TestDataFactory.createOrder(lstAccounts, objStore.Id, 1);
        OrderDeliveryMethod objDeliveryMethod = TestDataFactory.createOrderDeliveryMethod();

        List<OrderDeliveryGroup> lstOrderDeliveryGroup = new List<OrderDeliveryGroup>();
        Set<Id> setOrderIds = new Set<Id>();
        for (Order objOrder : lstOrder) {
            setOrderIds.add(objOrder.Id);
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Cancellation Requested', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Cancelled', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Confirmed', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Confirmed', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Confirmed', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
        }
        insert lstOrderDeliveryGroup;

        OrderDeliveryGroupExecutor objTriggerExecutor = new OrderDeliveryGroupExecutor();
        Map<Id, Boolean> result = objTriggerExecutor.getConfirmedAll(setOrderIds);
        for(Order objOrder : lstOrder){
            Assert.areEqual(true, result.get(objOrder.Id), 'Order should be confirmed');
        }
        Assert.isFalse(result.isEmpty(), 'Result should not be empty');
    }

    @isTest
    public static void testGetNextDayOrdersRollUp(){
        WebStore objStore = TestDataFactory.createWebStore();
        Test.startTest();
        List<Account> lstAccounts = TestDataFactory.createAccounts(5);
        Test.stopTest();
        List<Order> lstOrder = TestDataFactory.createOrder(lstAccounts, objStore.Id, 1);
        OrderDeliveryMethod objDeliveryMethod = TestDataFactory.createOrderDeliveryMethod();

        List<OrderDeliveryGroup> lstOrderDeliveryGroup = new List<OrderDeliveryGroup>();
        Set<Id> setOrderIds = new Set<Id>();
        for (Order objOrder : lstOrder) {
            setOrderIds.add(objOrder.Id);
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Submitted', OrderDeliveryMethodId = objDeliveryMethod.Id, Next_Day_Order__c =True, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Confirmed', OrderDeliveryMethodId = objDeliveryMethod.Id, Next_Day_Order__c =True, DeliverToName = 'Test Address'));
        }
        insert lstOrderDeliveryGroup;

        OrderDeliveryGroupExecutor objTriggerExecutor = new OrderDeliveryGroupExecutor();
        Map<Id, String> result = objTriggerExecutor.getNextDayOrdersRollUp(setOrderIds);
        for(Order objOrder : lstOrder){
            Assert.areEqual('TRUE', result.get(objOrder.Id), 'Next day order should be TRUE');
        }
        Assert.isFalse(result.isEmpty(), 'Result should not be empty');
    }

    @isTest
    public static void testGetCancelledAll(){
        WebStore objStore = TestDataFactory.createWebStore();
        Test.startTest();
        List<Account> lstAccounts = TestDataFactory.createAccounts(5);
        Test.stopTest();
        List<Order> lstOrder = TestDataFactory.createOrder(lstAccounts, objStore.Id, 1);
        OrderDeliveryMethod objDeliveryMethod = TestDataFactory.createOrderDeliveryMethod();

        List<OrderDeliveryGroup> lstOrderDeliveryGroup = new List<OrderDeliveryGroup>();
        Set<Id> setOrderIds = new Set<Id>();
        for (Order objOrder : lstOrder) {
            setOrderIds.add(objOrder.Id);
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Pending', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Shipped', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Pending', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Cancelled', OrderDeliveryMethodId = objDeliveryMethod.Id, Is_All_Cancelled__c = true, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Cancelled', OrderDeliveryMethodId = objDeliveryMethod.Id, Is_All_Cancelled__c = true, DeliverToName = 'Test Address'));
        }
        insert lstOrderDeliveryGroup;

        OrderDeliveryGroupExecutor objTriggerExecutor = new OrderDeliveryGroupExecutor();
        Map<Id, Boolean> result = objTriggerExecutor.getCancelAll(setOrderIds);
        for (Order objOrder : lstOrder) {
            Assert.areEqual(true, result.get(objOrder.Id), 'Order should be cancelled');
        }
        Assert.isFalse(result.isEmpty(), 'Result should not be empty');
    }

    @isTest
    public static void testGetOrderDeliveryGroupStatusCount(){
        WebStore objStore = TestDataFactory.createWebStore();
        Test.startTest();
        List<Account> lstAccounts = TestDataFactory.createAccounts(5);
        Test.stopTest();
        List<Order> lstOrder = TestDataFactory.createOrder(lstAccounts, objStore.Id, 1);
        OrderDeliveryMethod objDeliveryMethod = TestDataFactory.createOrderDeliveryMethod();

        List<OrderDeliveryGroup> lstOrderDeliveryGroup = new List<OrderDeliveryGroup>();
        Set<Id> setOrderIds = new Set<Id>();
        for (Order objOrder : lstOrder) {
            setOrderIds.add(objOrder.Id);
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Pending', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Shipped', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Pending', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Confirmed', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = objOrder.Id, ShipmentStatus__c = 'Submitted', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
        }
        insert lstOrderDeliveryGroup;
        
        OrderDeliveryGroupExecutor objTriggerExecutor = new OrderDeliveryGroupExecutor();
        Map<Id, Integer> result = objTriggerExecutor.getOrderDeliveryGroupStatusCount(setOrderIds);
        for (Order objOrder : lstOrder) {
            Assert.areEqual(5, result.get(objOrder.Id), 'Order should have all groups');
        }
        Assert.isFalse(result.isEmpty(), 'Result should not be empty');
    }

    @isTest
    public static void testAfterUpdate(){
        WebStore objStore = TestDataFactory.createWebStore();
        ProductCatalog objCatalog = TestDataFactory.createProductCatalog();
        ProductCategory objCatagory = TestDataFactory.createProductCategory(objCatalog.Id);
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;

        Test.startTest();
        List<Account> lstAccounts = TestDataFactory.createAccounts(1);
        List<Product2> lstProducts =  TestDataFactory.createProduct(99, 1);
        Test.stopTest();
        
        List<Order> lstOrder = TestDataFactory.createOrder(lstAccounts, objStore.Id, 5);
        OrderDeliveryMethod objDeliveryMethod = TestDataFactory.createOrderDeliveryMethod();

        List<OrderDeliveryGroup> lstOrderDeliveryGroup = new List<OrderDeliveryGroup>();
        Set<Id> setOrderIds = new Set<Id>();
        for (Order objOrder : lstOrder) {
            setOrderIds.add(objOrder.Id);
            //order deliveries for rollup status.
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = lstOrder[0].Id, ShipmentStatus__c = 'Confirmed', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = lstOrder[0].Id, ShipmentStatus__c = 'Shipped', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = lstOrder[0].Id, ShipmentStatus__c = 'Pending', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = lstOrder[0].Id, ShipmentStatus__c = 'Confirmed', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = lstOrder[0].Id, ShipmentStatus__c = 'Confirmed', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            //order deliveries for next day order.
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = lstOrder[1].Id, ShipmentStatus__c = 'Submitted', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address', Next_Day_Order__c = true));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = lstOrder[1].Id, ShipmentStatus__c = 'Pending', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address', Next_Day_Order__c = true));
            ///order delivery for confrim all order.
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = lstOrder[2].Id, ShipmentStatus__c = 'Cancelled', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = lstOrder[2].Id, ShipmentStatus__c = 'Confirmed', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = lstOrder[2].Id, ShipmentStatus__c = 'Confirmed', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            //order delivery for cancel all order.
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = lstOrder[3].Id, ShipmentStatus__c = 'Pending', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = lstOrder[3].Id, ShipmentStatus__c = 'Shipped', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = lstOrder[3].Id, ShipmentStatus__c = 'Pending', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = lstOrder[3].Id, ShipmentStatus__c = 'Cancelled', OrderDeliveryMethodId = objDeliveryMethod.Id, Is_All_Cancelled__c = true, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = lstOrder[3].Id, ShipmentStatus__c = 'Cancelled', OrderDeliveryMethodId = objDeliveryMethod.Id, Is_All_Cancelled__c = true, DeliverToName = 'Test Address'));
            lstOrderDeliveryGroup.add(new OrderDeliveryGroup(OrderId = lstOrder[4].Id, ShipmentStatus__c = 'Cancelled', OrderDeliveryMethodId = objDeliveryMethod.Id, DeliverToName = 'Test Address', IsHold__c =true));
        }
        insert lstOrderDeliveryGroup;

        List<OrderItem> lstOrderItem = TestDataFactory.createOrderItem(lstOrderDeliveryGroup, lstOrder, lstProducts);

        for(Order objOrder : lstOrder){
            objOrder.Status = 'Activated';
        }
        update lstOrder;

        for(Order objOrder : lstOrder){
            ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
            osir.orderId = objOrder.Id;
            osir.orderLifeCycleType = 'UNMANAGED';
            ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        }

        for (OrderDeliveryGroup odg : lstOrderDeliveryGroup) {
            odg.IsHold__c = false;
        }
        update lstOrderDeliveryGroup;

        List<OrderSummary> lstOrderSummary = [SELECT Id,  Status, Is_All_Order_Cancelled__c , Next_Day_Order__c, IsHold__c, OriginalOrderId FROM OrderSummary WHERE OriginalOrderId IN :setOrderIds];
        Assert.isTrue(lstOrderSummary.size() == setOrderIds.size(), 'Order Summary Created Count should be match Order count');
        Assert.isFalse(lstOrderSummary.isEmpty(), 'List of OrderSummary should not be empty');

        for (OrderSummary os : lstOrderSummary) {
            if (os.OriginalOrderId == lstOrder[0].Id) {
                Assert.areEqual('Confirmed', os.Status, 'Order 0 status should be Confirmed');
            }
            if (os.OriginalOrderId == lstOrder[1].Id) {
                Assert.areEqual('Yes', os.Next_Day_Order__c, 'Order 1 should not be marked as next day order');
            }
            if (os.OriginalOrderId == lstOrder[2].Id) {
                Assert.areEqual('All Confirmed', os.Status, 'Order 2 should be marked as AllConfirmed');
            }
            if (os.OriginalOrderId == lstOrder[3].Id) {
                Assert.isTrue(os.Is_All_Order_Cancelled__c, 'Order 3 should be marked as cancelled');
            }
        }
    }
}