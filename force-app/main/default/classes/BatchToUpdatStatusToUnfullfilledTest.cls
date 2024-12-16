/************************************************************************************************************************************
Author : Priyanka Shinde
Description :Test method to BatchToUpdatStatusToUnfullfilled class for updating Order Delivery Group Status
----------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 		DATE 		  AUTHOR 			DETAIL
1.0                           20/04/2022    Priyanka Shinde   Test method to BatchToUpdatStatusToUnfullfilled class for updating Order Delivery Group Status.
1.1       CARMEUSE-                        Ravikant Vijapure  Updated test with 'Cancellation Request' delivery status and test data factory
**************************************************************************************************************************************/

@isTest	
public class BatchToUpdatStatusToUnfullfilledTest {
    @testSetup
    public static void testData() {
        
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
        List<Account> lstAccounts = TestDataFactory.createAccounts(10);
        List<Product2> lstProducts =  TestDataFactory.createProduct(99, 1);
        Test.StopTest();
        
        List<ContactPointAddress> lstShippingAddress = TestDataFactory.createContactPointAddress(lstAccounts, 1);
        List<WebCart> lstCart = TestDataFactory.createWebCart(lstWebStore.Id, lstAccounts, false, 10);
        List<CartDeliveryGroup> lstCartDeliveryGroup = TestDataFactory.createCartDeliveryGroup(lstProducts, lstCart[0].Id, lstShippingAddress[0].Id, 1);
        List<CartItem>  lstCartItem = TestDataFactory.createCartItem(lstCartDeliveryGroup, lstCart[0].Id, 1);
        List<CartCheckoutSession> lstCheckOutSessions = TestDataFactory.createCartCheckout(lstCart, 1);
        List<Order> lstOrder = TestDataFactory.createOrder(lstAccounts, lstWebStore.Id, 1); 
        
        OrderDeliveryMethod odgMethod = TestDataFactory.createOrderDeliveryMethod();
        List<OrderDeliveryGroup> lstOrderDeliveryGroup = TestDataFactory.createOrderDeliveryGroup(lstOrder, odgMethod.Id, 5);
        
        Assert.isNotNull(lstWebStore, 'WebStore should be created');
        Assert.areEqual(lstAccounts.size(), 10, '10 Accounts should be created');
        Assert.areEqual(lstProducts.size(), 1, '1 Products should be created');
        Assert.areEqual(lstShippingAddress.size(), 1, '1 Shipping Address should be created');
        Assert.areEqual(lstCart.size(), 10, '10 WebCart should be created');
        Assert.areEqual(lstCartDeliveryGroup.size(), 1, '1 Cart Delivery Group should be created');
        Assert.areEqual(lstCartItem.size(), 1, '1 Cart Item should be created');
        Assert.areEqual(lstCheckOutSessions.size(), 1, '1 Cart Checkout Session should be created');
        Assert.areEqual(lstOrder.size(), 10, 'Order list should contain exactly 10 order');
        Assert.isNotNull(odgMethod, 'Order Delivery Method should be created');
        Assert.areEqual(lstOrderDeliveryGroup.size(), 50, '50 Order Delivery Group should be created');
    }

    @isTest
    Static void testBatchToUpdatStatusToUnfullfilled(){
        List<OrderDeliveryGroup> lstOrderDeliveryGroups = [SELECT Id, OrderId, OrderDeliveryMethodId, DeliverToName, AccessCode__c, BOLNumber__c, AccountExternalNumber__c, MaterialNumber__c, Material_Number_SF__c, Material__c, DesiredDeliveryDate, Quantity__c, Delivery_Quantity__c, SplitShipmentId__c, PONumber__c, Description, DeliveryInstructions, ShipmentTonnage__c, ShipmentStatus__c, ShipmentWeight__c, ShipmentSize__c, ShipmentSizeType__c, ShipmentDateTime__c, DeliverToCity, DeliverToCountry, DeliverToState, DeliverToStreet, DeliverToPostalCode FROM OrderDeliveryGroup LIMIT 100];
        for(Integer iIndex =0; iIndex< lstOrderDeliveryGroups.size(); iIndex++){
            if(iIndex < 5 ) {
                lstOrderDeliveryGroups[iIndex].ShipmentStatus__c = 'Cancelled';
                lstOrderDeliveryGroups[iIndex].DesiredDeliveryDate = Date.today()-20;
            } else if(iIndex >= 5 && iIndex <= 9) {
                lstOrderDeliveryGroups[iIndex].ShipmentStatus__c = 'Shipped';
                lstOrderDeliveryGroups[iIndex].DesiredDeliveryDate = Date.today()-20;
            } else if(iIndex >= 10 && iIndex <= 14) {
                lstOrderDeliveryGroups[iIndex].ShipmentStatus__c = 'Pending';
                lstOrderDeliveryGroups[iIndex].DesiredDeliveryDate = Date.today()-20;
            } else if(iIndex >= 15 && iIndex <= 19) {
                lstOrderDeliveryGroups[iIndex].ShipmentStatus__c = 'Received';
                lstOrderDeliveryGroups[iIndex].DesiredDeliveryDate = Date.today()-20;
            } else if(iIndex >= 20 && iIndex <= 24) {
                lstOrderDeliveryGroups[iIndex].ShipmentStatus__c = 'Unfulfilled';
                lstOrderDeliveryGroups[iIndex].DesiredDeliveryDate = Date.today()-20;
            } else if(iIndex >= 25 && iIndex <= 29) {
                lstOrderDeliveryGroups[iIndex].ShipmentStatus__c = 'Cancelled By Carmeuse';
                lstOrderDeliveryGroups[iIndex].DesiredDeliveryDate = Date.today()-20;
            } else if( iIndex >= 30 && iIndex <= 34) {
                lstOrderDeliveryGroups[iIndex].ShipmentStatus__c = 'Confirmed';
                lstOrderDeliveryGroups[iIndex].DesiredDeliveryDate = Date.today()-20;
            } else {
                lstOrderDeliveryGroups[iIndex].ShipmentStatus__c = 'Submitted';
                lstOrderDeliveryGroups[iIndex].DesiredDeliveryDate = Date.today()-20;
            }       
        }
        update lstOrderDeliveryGroups;
        List<OrderDeliveryGroup> lstODGWithSubmitAndConfirm = [SELECT Id, ShipmentStatus__c FROM OrderDeliveryGroup WHERE ShipmentStatus__c = 'Submitted' OR ShipmentStatus__c = 'Confirmed'];
        Assert.areEqual(lstODGWithSubmitAndConfirm.size(), 20, '20 Order Delivery Group should be submitted and confirmed');
        Assert.isTrue(!lstODGWithSubmitAndConfirm.isEmpty(), 'There should be records in the list');

        Test.startTest();        
        BatchToUpdatStatusToUnfullfilled objBatchToUpdatStatusToUnfullfilled = new BatchToUpdatStatusToUnfullfilled();
        DataBase.executeBatch(objBatchToUpdatStatusToUnfullfilled,100);
        Test.stopTest();

        List<OrderDeliveryGroup> lstODGWithUnfullfilledStatus = [SELECT Id, ShipmentStatus__c FROM OrderDeliveryGroup WHERE ShipmentStatus__c = 'Unfulfilled'];
        Assert.areEqual(lstODGWithUnfullfilledStatus.size(), 25, '25 Order Delivery Group should be Unfullfilled');
        Assert.isTrue(!lstODGWithUnfullfilledStatus.isEmpty(), 'There should be records in the list'+lstODGWithUnfullfilledStatus.size());
        //UB-001
        for(OrderDeliveryGroup objOrderDeliveryGroup : lstODGWithUnfullfilledStatus) {
            Assert.isTrue(objOrderDeliveryGroup.ShipmentStatus__c == 'Unfulfilled', 'Order Delivery Group status should be Unfullfilled');
            Assert.isTrue(objOrderDeliveryGroup.ShipmentStatus__c != 'Submitted' || objOrderDeliveryGroup.ShipmentStatus__c != 'Confirmed', 'Order Delivery Group status should not be Submitted, Confirmed, Unfulfilled');
            Assert.isNotNull( lstODGWithUnfullfilledStatus, 'There should be records with Unfullfilled status');
            Assert.isNotNull(lstODGWithSubmitAndConfirm, 'There should be records with status as Submitted or Confirmed');
        }
        
        //UB-002
        List<OrderDeliveryGroup> lstOrderDeliveryGroupShipped = [SELECT ShipmentStatus__c FROM OrderDeliveryGroup WHERE ShipmentStatus__c = 'Cancelled' AND ShipmentStatus__c = 'Shipped' AND ShipmentStatus__c = 'Pending' AND ShipmentStatus__c = 'Received' AND ShipmentStatus__c = 'Cancelled By Carmeuse' AND DesiredDeliveryDate < N_DAYS_AGO:3];
        Assert.areEqual(lstOrderDeliveryGroupShipped.size(), 25, '25 Order Delivery Group should be other status except submitted and confirmed');
        Assert.isTrue(!lstOrderDeliveryGroupShipped.isEmpty(), 'There should be records with status as other than Unfullfilled');
        for(OrderDeliveryGroup objOrderDeliveryGroup : lstOrderDeliveryGroupShipped) {
            Assert.areNotEqual('Unfulfilled', objOrderDeliveryGroup.ShipmentStatus__c, 'Check Status is not Unfullfilled');
            Assert.isTrue(objOrderDeliveryGroup.ShipmentStatus__c == 'Cancelled' || objOrderDeliveryGroup.ShipmentStatus__c == 'Shipped' || objOrderDeliveryGroup.ShipmentStatus__c == 'Pending' || objOrderDeliveryGroup.ShipmentStatus__c == 'Received' || objOrderDeliveryGroup.ShipmentStatus__c == 'Cancelled By Carmeuse' , 'Check Status is not Cancelled,Shipped,Pending,Received,Cancelled By Carmeuse');
        }
        
        //UB-003
        for(OrderDeliveryGroup objOrderDeliveryGroup :  [SELECT ShipmentStatus__c FROM OrderDeliveryGroup WHERE ShipmentStatus__c = 'Submitted' AND ShipmentStatus__c = 'Confirmed' AND ShipmentStatus__c = 'Unfulfilled' AND DesiredDeliveryDate < N_DAYS_AGO:3]){
            Assert.areEqual('Unfulfilled', objOrderDeliveryGroup.ShipmentStatus__c,'Check Status is updated to Unfulfilled for order whose DesiredDeliveryDate is less than 3 days ago and Status is Submitted OR Confirmed');
            Assert.areNotEqual('Submitted', objOrderDeliveryGroup.ShipmentStatus__c,'Check Status is not Submitted for order whose DesiredDeliveryDate is less than 3 days ago');
        } 

        for(OrderDeliveryGroup objOrderDeliveryGroup :  [SELECT ShipmentStatus__c, DesiredDeliveryDate FROM OrderDeliveryGroup WHERE (ShipmentStatus__c = 'Submitted' OR ShipmentStatus__c = 'Confirmed') AND DesiredDeliveryDate = N_DAYS_AGO:2]){
            System.assertNotEquals('Unfulfilled', objOrderDeliveryGroup.ShipmentStatus__c,'Check Status is not Unfulfilled for order whose DesiredDeliveryDate is less than 2 days ago and Status is Submitted OR Confirmed');
        }

        //UB-004
        for(OrderDeliveryGroup objOrderDeliveryGroup :  [SELECT ShipmentStatus__c FROM OrderDeliveryGroup WHERE (ShipmentStatus__c = 'Submitted' OR ShipmentStatus__c = 'Confirmed' OR ShipmentStatus__c = 'Pending' OR ShipmentStatus__c = 'Shipped' OR ShipmentStatus__c = 'Cancelled') AND DesiredDeliveryDate > N_DAYS_AGO:3]){
            System.assertNotEquals('Unfulfilled', objOrderDeliveryGroup.ShipmentStatus__c,'Check Status is not Unfulfilled for order whose DesiredDeliveryDate is greather than 3 days ago and Status is Submitted OR Confirmed OR Pending');
        }
    }
    
    @IsTest
    static void verifyBatchToUpdatStatusToUnfullfilledNegative(){ 
        Test.startTest();  
        BatchToUpdatStatusToUnfullfilled objBatchToUpdatStatusToUnfullfilled = new BatchToUpdatStatusToUnfullfilled();
        objBatchToUpdatStatusToUnfullfilled.errorList.add('ERROR');
        DataBase.executeBatch(objBatchToUpdatStatusToUnfullfilled);        
        Test.stopTest(); 
    }
}