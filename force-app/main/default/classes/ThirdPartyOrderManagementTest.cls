/*----------------------------------------------------------------------
Name:       ThirdPartyOrderManagement.cls
Purpose:    Test Class for ThirdPartyOrderManagement class
------------------------------History----------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          ------------------
1.0         Devang          28-April-2021           Initial Development 
----------------------------------------------------------------------*/
@isTest
public with sharing class ThirdPartyOrderManagementTest {
    @IsTest(SeeAllData=true)
	static void testProcessOrderRecords() {
        TriggerConfiguration.setDoNotRunTrigger();
		final String TEST_PRODUCT_NAME = 'TestProduct';

        SalesChannel sc = new SalesChannel(SalesChannelName = 'SAP', Description = 'SAP');
        insert sc; 

		Product2 prod = new Product2(Name = 'HiCal QL Pulv W/Flo Aid Bulk Test',
		Family = 'Lime', MaterialNumber__c = '000000000000010329', ProductCode = '10329');
		insert prod;

        Id pricebookId = Test.getStandardPricebookId();
       
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;

        Pricebook2 pb = new Pricebook2 (Name = 'PB-TestAccount',  IsActive = true);
        insert pb;

        PricebookEntry custPrice = new PricebookEntry(
            Pricebook2Id = pb.Id, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert custPrice;

        ProductCatalog pc = new ProductCatalog(Name='My Catalog');
        insert pc;
        ProductCategory pcat = new ProductCategory(Name='Lime Products', CatalogId = pc.Id);
        insert pcat;
        ProductCategoryProduct pcp = new ProductCategoryProduct(ProductCategoryId = pcat.Id, ProductId = prod.Id );
        insert pcp;

		Account testAccount = new Account(Name='TestAccount',BillingStreet='Test Street', BillingCountry='United States', BillingPostalCode='44444', AccountExternalNumber__c = '123');
		insert testAccount;

		BuyerAccount buyerAccount = new BuyerAccount(name='test', BuyerId=testAccount.Id, IsActive=true);
		insert buyerAccount;

		BuyerGroup buyerGroup = new BuyerGroup(Name='buyerGroupTest');
		insert buyerGroup;

		BuyerGroupMember buyerGroupMember = new BuyerGroupMember(BuyerId=buyerAccount.BuyerId,BuyerGroupId=buyerGroup.Id);
		insert buyerGroupMember;

        // WebStore ws = new WebStore(Name='Carmeuse Customer Portal');
        // insert ws;

		List<WebStore> testWebStore = [SELECT Id FROM WebStore WHERE Name='Carmeuse Customer Portal'];

        WebStorePricebook wspb = new WebStorePricebook ( IsActive = true, Pricebook2Id = pb.Id, WebStoreId = testWebStore[0].Id );
        insert wspb;

        CommerceEntitlementPolicy cep = new CommerceEntitlementPolicy(Name = 'Test Policy', IsActive = true, CanViewProduct = true);
        insert cep;

        CommerceEntitlementProduct ceprd = new CommerceEntitlementProduct(PolicyId = cep.Id, ProductId = prod.Id);
        insert ceprd;

        CommerceEntitlementBuyerGroup cebg = new CommerceEntitlementBuyerGroup(PolicyId = cep.Id, BuyerGroupId = buyerGroup.Id);
        insert cebg;

		WebStoreBuyerGroup webStoreBuyerGroup = new WebStoreBuyerGroup(BuyerGroupId=buyerGroup.Id, WebStoreId= testWebStore[0].Id);
		insert webStoreBuyerGroup;

		List<WebStoreNetwork> community = [SELECT NetworkId FROM WebStoreNetwork WHERE WebStoreId = :testWebStore[0].Id];

		WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore[0].Id, AccountId=testAccount.Id);
		insert cart;

		CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
		insert cartDeliveryGroup;

		CartItem cartItem = new CartItem(CartId=cart.Id, Sku='SKU_Test1',TotalPrice=10.00, SalesPrice=10.00, Quantity=1.0, Type='Product', Name=TEST_PRODUCT_NAME, CartDeliveryGroupId=cartDeliveryGroup.Id);
		insert cartItem;

        CartCheckoutSession  ccs = new CartCheckoutSession(WebCartId = cart.Id, IsArchived = false, Name = cart.Name, State = 'Order Confirmation' );
        insert ccs;

		Test.startTest();

        //Id orderId = OrderUtils.getOrderIdByCartId(cart.Id);
        List<Id> cartIds = new List<Id>();
        cartIds.add(cart.Id);
        List<Id> orderIds = OrderUtils.getOrderIdsByCartIds(cartIds);
        
        ConnectApi.CartItemCollection cartItemCollection = B2BCartController.getCartItems(community[0].NetworkId, buyerAccount.BuyerId, cart.id,null,null );
        Order o = new Order();
        o.AccountId= testAccount.Id;  // Id from step 3
        o.SalesStoreId= testWebStore[0].Id; // Id from step 2
        o.Status='Draft';
        o.EffectiveDate=date.today();
        //o.OwnerId = buyerId;   // Id from step 5
        o.External__c = true; // very important
        o.OrderedDate = Date.today();
        insert o;

        OrderDeliveryMethod odm = [SELECT Id FROM OrderDeliveryMethod where Name = 'Default Delivery Method'];

        OrderDeliveryGroup odg = new OrderDeliveryGroup();
        odg.OrderId=o.id;
        odg.OrderDeliveryMethodId=odm.Id; // Id from step 1
        odg.DeliverToName='The Shipping Address';
        odg.AccessCode__c = '123';
        odg.BOLNumber__c = '';
        odg.AccountExternalNumber__c = '123';
        odg.MaterialNumber__c = '000000000000010325';
        odg.DesiredDeliveryDate = Date.today(); 
        odg.Quantity__c = 1;
        odg.PONumber__c = '123';
        odg.Description = '';
        odg.DeliveryInstructions = '';
        odg.ShipmentTonnage__c = 900;        
        odg.ShipmentStatus__c = 'Submitted'; 
        odg.ShipmentWeight__c = '100';
        odg.ShipmentSize__c = 10;
        odg.ShipmentSizeType__c = '25';
        odg.ShipmentDateTime__c = Date.today(); 
        odg.DeliverToName = 'TestAccount';
        odg.DeliverToCity =  'New York';
        odg.DeliverToCountry = 'United States';
        odg.DeliverToState =  'New York';
        odg.DeliverToStreet = '2 Paget';
        odg.DeliverToPostalCode =  '12345';
        insert odg;

        OrderItem oi = new OrderItem();
        oi.OrderId=o.Id;
        oi.OrderDeliveryGroupId = odg.Id; //Id received from step 7
        oi.Product2Id=prod.Id; // Retrieve based on Material Number
        oi.Quantity=1;
        oi.ListPrice=999;
        oi.UnitPrice=999;
        oi.TotalLineAmount=999;
        oi.Type='Order Product';
        insert oi;

        Order o1 = new Order();
        o1.Id = o.Id ;
        o1.Status = 'Activated';
        update o1;

        ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
        osir.orderId = o1.Id;
        osir.orderLifeCycleType = 'UNMANAGED';
        ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        
        Order o2 = new Order();
        o2.Id = o.Id ;
        o2.Description = 'Test';
        update o2;
        List<Id> originalOrderIds = new List<Id>();

        originalOrderIds.add(o.Id);
        List<OrderDeliveryGroupSummary> odgsList =  OrderUtils.getOrderDeliveryGroupSummariesByOrderIds(originalOrderIds);
        //System.Debug('odgsList****' + odgsList.size());       
        
        List<OrderSummary> osl = [SELECT Id FROM OrderSummary Limit 1];
        

        List<OrderDeliveryGroupSummary> odgs = [SELECT Id FROM OrderDeliveryGroupSummary Limit 1];        
        
        Map<Id, Id> orderIdsToCartIds = OrderUtils.getOrderIdToCartIdMap(cartIds);
        //List<OrderDeliveryGroup> odgList =  OrderUtils.getRelatedOrderDeliveryGroupsByCartId(cart.Id);
        //odgsList =  OrderUtils.getRelatedOrderDeliveryGroupSummariesByCartId(cart.Id);
        List<CartDeliveryGroup> cdgList = OrderUtils.getCartDeliveryGroupsByCartId(cart.Id);
        cdgList = OrderUtils.getCartDeliveryGroupsByCartIds(cartIds);
        List<CartItem> ciList = OrderUtils.getCartItemsByCartId(cart.Id);

        List<Id> productIds = new List<Id>();
        productIds.add(prod.Id);

        List<Product2> pList = OrderUtils.getProductsByIds(productIds);
        //List<PricebookEntry> pbList =  OrderUtils.getPricebookEntriesByProductIds(productIds);

        List<OrderSummary> osList = OrderUtils.getOrderSummaryById(o1.Id);

        originalOrderIds.add(o1.Id);
        osList = OrderUtils.getOrderSummaryByOriginalOrderId(originalOrderIds);

        List<OrderItemSummary> oisList = OrderUtils.getOrderItemSummaryByOrderSummaryId(osl[0].Id );
        odgsList =  OrderUtils.getOrderDeliveryGroupSummaryByOrderSummaryId(osl[0].Id );
        
        odgsList =  OrderUtils.getOrderDeliveryGroupSummariesByOrderIds(originalOrderIds);
        //odgList =  OrderUtils.getOrderDeliveryGroupsByOrderIds(originalOrderIds);
        odgsList =  OrderUtils.getRelatedOrderDeliveryGroupSummariesByCartIds(cartIds);
        List<Order> orl =  OrderUtils.getOrderById(o1.Id);
        //odgList =  OrderUtils.getOrderDeliveryGroupByOrderId(o1.Id);
        orl = OrderUtils.getOrdersByAccountId(testAccount.Id);
        List<OrderDeliveryGroup> odgl = OrderUtils.getOrderDeliveryGroupByOrderId(o1.Id);
        List<OrderItem> odil =  OrderUtils.getOrderItemByOrderId(o1.Id);
        Test.stopTest();

        System.assertEquals(TEST_PRODUCT_NAME, cartItemCollection.cartItems[0].cartItem.name, 'Name should be TestProduct');
        System.assertNotEquals(odgsList, null);
        //System.assertNotEquals(odgList, null);
	}
}