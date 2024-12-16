@isTest
public with sharing class Car_OrderTemplateControllerTest {
    @IsTest(SeeAllData=true)
	static void testOrderTemplateControllerMethods() {
        
        TriggerConfiguration.setDoNotRunTrigger();
		final String TEST_PRODUCT_NAME = 'TestProduct';

        SalesChannel sc = new SalesChannel(SalesChannelName = 'SAP', Description = 'SAP');
        insert sc; 

        Product2 prod = new Product2(Name = 'HiCal QL Pulv W/Flo Aid Bulk',
                                     Family = 'Lime', MaterialNumber__c = '000000000000010325', ProductCode = '10325');
        insert prod;
       
        Id pricebookId = Test.getStandardPricebookId();
       
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;

		Account testAccount = new Account(Name='TestAccount',BillingStreet='Test Street', BillingCountry='United States', BillingPostalCode='44444', AccountExternalNumber__c = '123');
		insert testAccount;

		BuyerAccount buyerAccount = new BuyerAccount(name='test', BuyerId=testAccount.Id, IsActive=true);
		insert buyerAccount;

		BuyerGroup buyerGroup = new BuyerGroup(Name='buyerGroupTest');
		insert buyerGroup;

		BuyerGroupMember buyerGroupMember = new BuyerGroupMember(BuyerId=buyerAccount.BuyerId,BuyerGroupId=buyerGroup.Id);
		insert buyerGroupMember;

		List<WebStore> testWebStore = [SELECT Id FROM WebStore WHERE Name='Carmeuse Customer Portal'];

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
        
        List<OrderSummary> osl = [SELECT Id FROM OrderSummary Limit 1];        

        Car_OrderTemplateController otc = new Car_OrderTemplateController();
        otc.orderToDisplayId = osl[0].Id;
        OrderSummary os =  otc.getorderdetails();

        Folder f = [Select Id from Folder where Name = 'Shared Documents'];

        Document d = new Document(DeveloperName = 'Carmeuse_Logo_test', Name = 'Carmeuse Logo1', FolderId = f.Id );
        insert d;
        
        String s = otc.getStrLogoUrl();
        
        Test.stopTest();
        System.assertNotEquals(os, null);
       
     
	}
}