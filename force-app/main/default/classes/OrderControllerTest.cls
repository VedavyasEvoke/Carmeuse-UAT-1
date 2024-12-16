/*----------------------------------------------------------------------
Name:       OrderControllerTest.cls
Purpose:    Test Class for OrderController class
------------------------------History----------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          ------------------
1.0         Devang          06-April-2021           Initial Development 
----------------------------------------------------------------------*/

@isTest
public with sharing class OrderControllerTest {
    
    @IsTest(SeeAllData=true)
    static void testGetOrderDetail() {
        
        TriggerConfiguration.setDoNotRunTrigger();
        Product2 testPrimaryProduct = new Product2(Name = 'HiCal QL Pulv W/Flo Aid Bulk',
                                                   Family = 'Lime', MaterialNumber__c = '000000000000010325-0000000123-0000123456',StockKeepingUnit = '000000000000010325-0000000123-0000123456',ProductCode = '10325');
        insert testPrimaryProduct;
        Product2 testBackupProduct = new Product2(Name = 'HiCal QL Pulv W/Flo Aid Bulk2',
                                                  Family = 'Lime', MaterialNumber__c = '000000000000010325-0000000123-0000123457',StockKeepingUnit = '000000000000010325-0000000123-0000123457',ProductCode = '10325');
        insert testBackupProduct;  
        
        Id stdPricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrimaryPriceEntry = new PricebookEntry(
            Pricebook2Id = stdPricebookId, Product2Id = testPrimaryProduct.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrimaryPriceEntry; 
        
        Pricebook2 customPriceBook = new Pricebook2 (Name = 'PB-TestAccount',  IsActive = true);
        insert customPriceBook;
        
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        PricebookEntry customPriceBookEntry = new PricebookEntry(
            Pricebook2Id = customPriceBook.Id, Product2Id = testPrimaryProduct.Id,
            UnitPrice = 10000, IsActive = true ,ValidFrom__c = Date.today()-10,ValidTo__c=Date.today()-9,PO_Number__c='PO-TEST');
        insert customPriceBookEntry;
        
        Account testAccount = new Account(Name='TestAccount',BillingStreet='Test Street', BillingCountry='United States', BillingPostalCode='44444', AccountExternalNumber__c = '000123');
        insert testAccount;        
        
        SalesChannel sc = new SalesChannel(SalesChannelName = 'SAP', Description = 'SAP');
        insert sc; 
        
        BuyerAccount buyerAccount = new BuyerAccount(name='test', BuyerId=testAccount.Id, IsActive=true);
        insert buyerAccount;
        
        BuyerGroup buyerGroup = new BuyerGroup(Name='buyerGroupTest');
        insert buyerGroup;
        
        BuyerGroupMember buyerGroupMember = new BuyerGroupMember(BuyerId=buyerAccount.BuyerId,BuyerGroupId=buyerGroup.Id);
        insert buyerGroupMember;
        
        BuyerGroupPricebook bgPricebook = new BuyerGroupPricebook();
        bgPricebook.BuyerGroupId = buyerGroup.Id;
        bgPricebook.Pricebook2Id = customPriceBook.Id;
        bgPricebook.IsActive = TRUE;
        insert bgPricebook;
        
        System.debug('bgPricebook'+bgPricebook);
        
        List<WebStore> testWebStore = [SELECT Id FROM WebStore WHERE Name='Carmeuse Customer Portal'];
        
        WebStorePricebook wspb = new WebStorePricebook ( IsActive = true, Pricebook2Id = customPriceBook.Id, WebStoreId = testWebStore[0].Id );
        insert wspb;
        
        CommerceEntitlementPolicy cep = new CommerceEntitlementPolicy(Name = 'Test Policy', IsActive = true, CanViewProduct = true);
        insert cep;
        
        CommerceEntitlementProduct ceprd = new CommerceEntitlementProduct(PolicyId = cep.Id, ProductId = testPrimaryProduct.Id);
        insert ceprd;
        
        CommerceEntitlementBuyerGroup cebg = new CommerceEntitlementBuyerGroup(PolicyId = cep.Id, BuyerGroupId = buyerGroup.Id);
        insert cebg;
        
        WebStoreBuyerGroup webStoreBuyerGroup = new WebStoreBuyerGroup(BuyerGroupId=buyerGroup.Id, WebStoreId= testWebStore[0].Id);
        insert webStoreBuyerGroup;
        
        List<WebStoreNetwork> community = [SELECT NetworkId FROM WebStoreNetwork WHERE WebStoreId = :testWebStore[0].Id];
        
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore[0].Id, AccountId=testAccount.Id);
        insert cart;        
        
        ContactPointAddress billingAddress = new ContactPointAddress(ParentId=testAccount.Id,AddressType = 'Billing',Street='Test',Name='Test',City='test');
        insert billingAddress;
        
        ContactPointAddress shippingAddress = new ContactPointAddress(ParentId=testAccount.Id,AddressType = 'Shipping',Street='Test',Name='Test',City='test',State='test',PostalCode='test',Country='test');
        insert shippingAddress;
        
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery',DesiredDeliveryDate = Date.today(),BillingAddress__c=billingAddress.Id,ShippingAddress__c=shippingAddress.Id,DeliveryText__c='Test Method',Quote_Number__c='76543',PONumber__c='PO TEST');
        insert cartDeliveryGroup;
        
        CartItem cartItem = new CartItem(CartId=cart.Id, Sku='000000000000010325-000123-00012348',TotalPrice=10.00, SalesPrice=10.00, Quantity=1.0, Type='Product', Name='HiCal QL Pulv W/Flo Aid Bulk', CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem;
        
        CartCheckoutSession  checkOutSessions = new CartCheckoutSession(WebCartId = cart.Id, IsArchived = false, Name = cart.Name, State = 'Order Confirmation' );
        insert checkOutSessions;
        
        Test.startTest();
        Order objOrder = new Order();
        objOrder.AccountId= testAccount.Id;  // Id from step 3
        objOrder.SalesStoreId= testWebStore[0].Id; // Id from step 2
        objOrder.Status='Draft';
        objOrder.EffectiveDate=date.today();
        objOrder.External__c = true; // very important
        objOrder.OrderedDate = Date.today();
        insert objOrder;
        
        checkOutSessions.IsArchived = false;
        checkOutSessions.OrderId = objOrder.Id;
        update checkOutSessions;
        
        OrderDeliveryMethod objOrderDeliveryMethod = [SELECT Id FROM OrderDeliveryMethod where Name = 'Default Delivery Method'];
        
        List<OrderDeliveryGroup> lstODG = new List<OrderDeliveryGroup>();
        for(Integer index=0 ; index < 2;index++){
            OrderDeliveryGroup objODG = new OrderDeliveryGroup();
            objODG.OrderId=objOrder.id;
            objODG.OrderDeliveryMethodId=objOrderDeliveryMethod.Id; // Id from step 1
            objODG.DeliverToName='The Shipping Address';
            objODG.AccessCode__c = '123';
            objODG.BOLNumber__c = '';
            objODG.AccountExternalNumber__c = '123';
            objODG.MaterialNumber__c = '000000000000010325-0000000123-0000123456';
            objODG.DesiredDeliveryDate = Date.today(); 
            objODG.Quantity__c = 1;
            objODG.PONumber__c = '123';
            objODG.Description = '';
            objODG.DeliveryInstructions = '';
            objODG.ShipmentTonnage__c = 900;        
            objODG.ShipmentStatus__c = 'Submitted'; 
            objODG.ShipmentWeight__c = '100';
            objODG.ShipmentSize__c = 10;
            objODG.ShipmentSizeType__c = '25';
            objODG.ShipmentDateTime__c = Date.today(); 
            objODG.DeliverToName = 'TestAccount';
            objODG.DeliverToCity =  'New York';
            objODG.DeliverToCountry = 'United States';
            objODG.DeliverToState =  'New York';
            objODG.DeliverToStreet = '2 Paget';
            objODG.DeliverToPostalCode =  '12345';
            lstODG.add(objODG);
        }        
        insert lstODG; 
        
        List<Id> lstOrderDeliveryGroupId = new List<Id>();
        for(OrderDeliveryGroup objODG : lstODG){
            lstOrderDeliveryGroupId.add(objODG.Id);
        }
        System.debug('IDSSS-->'+lstOrderDeliveryGroupId);
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        for(Integer index=0 ; index < lstODG.size();index++){
            OrderItem objOrderItem = new OrderItem();
            objOrderItem.OrderId=objOrder.Id;
            objOrderItem.OrderDeliveryGroupId = lstODG[0].Id; 
            objOrderItem.Product2Id=testPrimaryProduct.Id; 
            objOrderItem.Quantity=1;
            objOrderItem.ListPrice=999;
            objOrderItem.UnitPrice=999;
            objOrderItem.TotalLineAmount=999;
            objOrderItem.Type='Order Product';
            lstOrderItem.add(objOrderItem);
        }
        insert lstOrderItem;
        
        Order objUpdateOrder = new Order();
        objUpdateOrder.Id = objOrder.Id ;
        objUpdateOrder.Status = 'Activated';
        update objUpdateOrder;
        
        ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
        osir.orderId = objUpdateOrder.Id;
        osir.orderLifeCycleType = 'UNMANAGED';
        ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        
        OrderSummary objOrderSummary = [SELECT Id FROM OrderSummary WHERE OriginalOrderId =: objOrder.Id ];
        System.debug('objOrderSummary --->'+objOrderSummary);
        OrderController.OrderDetailWrapper orderDetails = OrderController.getOrderDetail(objOrderSummary.Id);
        System.debug('orderDetails --->'+orderDetails);
        System.assertNotEquals(NULL, orderDetails);
        
        Boolean isQuoteNumberUpdated =  OrderController.updateQuoteNumber(lstODG[0].Id, '12345');
        System.assertEquals(TRUE, isQuoteNumberUpdated);       
        
        Boolean isOrderDeliveryGroupUpdatedByCSR =  OrderController.updateOrderDeliveryGroupByCSR(lstODG[0].Id, '12345', '000000000018', '000000000018');
        System.assertEquals(TRUE, isOrderDeliveryGroupUpdatedByCSR);
        
        Id accountId = OrderController.getAccountId();        
        System.assertEquals(NULL, accountId);
        
        List<Order> accountOrders = OrderController.getUserOrders(testAccount.Id, '000', 'EffectiveDate', 'desc', objOrder.EffectiveDate, objOrder.EffectiveDate);
        System.assertNotEquals(NULL, accountOrders);
        
        List<OrderSummary> getOrderSummaryDetails = OrderController.getOrderSummaryByOriginalOrderId(objOrder.Id);
        System.assertEquals(objOrderSummary.Id, getOrderSummaryDetails[0].Id);
        
        Order getOrderDetails = OrderController.getOrderByOrderId(objOrder.Id);
        System.assertEquals(objOrder.Id,getOrderDetails.Id);
        
        List<OrderDeliveryGroup> lstOrderDeliveryGroup = OrderController.getOrderDeliveryGroupByOrderId(objOrder.Id);
        System.assertEquals(2,lstOrderDeliveryGroup.size());
        
        OrderDeliveryGroup objOrderDeliveryGrp = OrderController.getOrderDeliveryGroupData(lstODG[0].Id);
        System.assertNotEquals(NULL, objOrderDeliveryGrp);
        System.debug('objOrderDeliveryGrp '+objOrderDeliveryGrp);
        
        List<String> extendenEntitlement = OrderController.getExtendedEntitlement(testAccount.Id);
        System.assertEquals(0,extendenEntitlement.size());
        
        
        
        String poNumber = OrderController.getPONumber(testPrimaryProduct.Id);
        System.assertEquals('PO-TEST',poNumber);
        
        List<Order> accountsBOL = OrderController.getUserBOLs(testAccount.Id, '000', 'BOL_Number__c', 'desc', objOrder.EffectiveDate, objOrder.EffectiveDate);
        System.assertNotEquals(NULL, accountsBOL);
        
        List<Id> lstToCancelODG = new List<Id>();
        lstToCancelODG.add(lstODG[0].Id);
        
        OrderDeliveryGroup objgetOrderDeliveryGroupData = OrderController.getOrderDeliveryGroupData(lstODG[0].Id);
        System.assertNotEquals(NULL, objgetOrderDeliveryGroupData);
        
        List<OrderDeliveryGroup> lstgetOrderDeliveryGroupsData = OrderController.getOrderDeliveryGroupsData(lstODG[0].Id+','+lstODG[1].Id);
        System.assertEquals(2, lstgetOrderDeliveryGroupsData.size());
        
        Boolean isRelease= OrderController.releaseAllOrderDeliveryGroupByCSR(lstToCancelODG);
        System.assertEquals(true,isRelease);
        
        String releaseMsg = OrderController.getReleaseMessageOrderDeliveryGroupByCSR(lstToCancelODG[0]);
        System.assertNotEquals(NULL, releaseMsg);
        
        Boolean isAllCancelled = OrderController.cancelAllOrderDeliveryGroupByPortalUser(lstToCancelODG);
        System.assertEquals(true,isAllCancelled);
        
        String cancelMsg = OrderController.getCancelMessageOrderDeliveryGroupByCSR(lstODG[0].Id);
        System.assertNotEquals(NULL, cancelMsg);
        
        Boolean isOrderCancelByPortalUser = OrderController.cancelOrderDeliveryGroupByPortalUser(lstODG[1].Id,objOrder.Id);
        System.assertEquals(true,isOrderCancelByPortalUser);
        
        lstToCancelODG.add(lstODG[1].Id);
        Boolean isCalledByCSR = OrderController.cancelAllOrderDeliveryGroupByCSR(lstToCancelODG);
        System.assertEquals(true,isCalledByCSR);
        
        ExtendedEntitlement__c testEEP = new ExtendedEntitlement__c(AccountExtendedEntitlement__c=testAccount.Id,MaterialNumber__c='00000000001234-000987-000987',Plant_Code__c='PO');
        insert testEEP;
        List<String>  ExtendedEntitlement = OrderController.getPlantCode(testAccount.Id);
        System.assertNotEquals(NULL, ExtendedEntitlement);
        
        extendenEntitlement = OrderController.getExtendedEntitlement(testAccount.Id);
        System.assertEquals(1,extendenEntitlement.size());
        
        List<AccountInvoice__c> lstUserInvoices =  OrderController.getUserInvoices(testAccount.Id,'000','Name','desc', date.today(),date.today());
        System.assertEquals(0,lstUserInvoices.size());
        
        Boolean isOrderDeliveryGroupUpdatedALLBySPC =  OrderController.updateAllOrderDeliveryGroupBySPC(lstOrderDeliveryGroupId, '10325', '0000123456', '0000123457');
        System.assertEquals(TRUE, isOrderDeliveryGroupUpdatedALLBySPC);
        Test.stopTest();
    }
}