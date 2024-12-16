@isTest
public class OrgAllOrderCancelEmailsTest {
   @IsTest(SeeAllData=true)
    public static void testOrgAllOrderCancelEmails(){ 
        TriggerConfiguration.setDoNotRunTrigger();
        
        SalesChannel testSalesChannel = new SalesChannel(SalesChannelName = 'SAP', Description = 'SAP');
        insert testSalesChannel; 
        
        Product2 testProduct = new Product2(Name = 'HiCal QL Pulv W/Flo Aid Bulk',
                                            Family = 'Lime', MaterialNumber__c = '000000000000010325', ProductCode = '10325');
        insert testProduct;
        
        Id standardPriceBook = Test.getStandardPricebookId();
        
        PricebookEntry testStdPricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPriceBook, Product2Id = testProduct.Id,
            UnitPrice = 10000, IsActive = true);
        insert testStdPricebookEntry;
        
        Pricebook2 testPriceBook = new Pricebook2 (Name = 'PB-TestAccount',  IsActive = true);
        insert testPriceBook;
        
        PricebookEntry testCustomPriceBookEntry = new PricebookEntry(
            Pricebook2Id = testPriceBook.Id, Product2Id = testProduct.Id,
            UnitPrice = 10000, IsActive = true);
        insert testCustomPriceBookEntry;
        
        ProductCatalog testProductCatalog = new ProductCatalog(Name='My Catalog');
        insert testProductCatalog;
        
        ProductCategory testProductCategory = new ProductCategory(Name='Lime Products', CatalogId = testProductCatalog.Id);
        insert testProductCategory;
        
        ProductCategoryProduct testProductCategoryProduct = new ProductCategoryProduct(ProductCategoryId = testProductCategory.Id, ProductId = testProduct.Id );
        insert testProductCategoryProduct;
        
        Account testAccount = new Account(Name='TestAccount',BillingStreet='Test Street', BillingCountry='United States', BillingPostalCode='44444', AccountExternalNumber__c = '0821313144',SPC_Email__c='testEmail121@gmail.com');
        insert testAccount;
        
        Contact testContact = new Contact(LastName='test',Email = 'test+1@gmail.com',AccountId = testAccount.Id);
        insert testContact;
        
        BuyerAccount testBuyerAccount = new BuyerAccount(name='TestAccount', BuyerId=testAccount.Id, IsActive=true);
        insert testBuyerAccount;
        
        BuyerGroup testBuyerGroup = new BuyerGroup(Name='BG-TestAccount');
        insert testBuyerGroup;
        
        BuyerGroupMember testBuyerGroupMember = new BuyerGroupMember(BuyerId=testBuyerAccount.BuyerId,BuyerGroupId=testBuyerGroup.Id);
        insert testBuyerGroupMember;        
        
        WebStore testWebStore = [SELECT Id FROM WebStore WHERE Name='Carmeuse Customer Portal'];
        
        WebStorePricebook testWebStorePricebook = new WebStorePricebook ( IsActive = true, Pricebook2Id = testPriceBook.Id, WebStoreId = testWebStore.Id );
        insert testWebStorePricebook; 
        
        CommerceEntitlementPolicy testCommerceEntitlementPolicy = new CommerceEntitlementPolicy(Name = 'Test Policy', IsActive = true, CanViewProduct = true);
        insert testCommerceEntitlementPolicy;
        
        CommerceEntitlementProduct testCommerceEntitlementProduct = new CommerceEntitlementProduct(PolicyId = testCommerceEntitlementPolicy.Id, ProductId = testProduct.Id);
        insert testCommerceEntitlementProduct;
        
        CommerceEntitlementBuyerGroup testCommerceEntitlementBuyerGroup = new CommerceEntitlementBuyerGroup(PolicyId = testCommerceEntitlementPolicy.Id, BuyerGroupId = testBuyerGroup.Id);
        insert testCommerceEntitlementBuyerGroup;
        
        WebStoreBuyerGroup testWebStoreBuyerGroup = new WebStoreBuyerGroup(BuyerGroupId=testBuyerGroup.Id, WebStoreId= testWebStore.Id);
        insert testWebStoreBuyerGroup;
        
        WebStoreNetwork community = [SELECT NetworkId FROM WebStoreNetwork WHERE WebStoreId = :testWebStore.Id];
        
        WebCart testWebCart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert testWebCart;
        
        CartDeliveryGroup testCartDeliveryGroup = new CartDeliveryGroup(CartId=testWebCart.Id, Name='Default Delivery');
        insert testCartDeliveryGroup;
        
        CartItem testCartItem = new CartItem(CartId=testWebCart.Id, Sku='SKU_Test1',TotalPrice=10.00, SalesPrice=10.00, Quantity=1.0, Type='Product', Name='HiCal QL Pulv W/Flo Aid Bulk', CartDeliveryGroupId=testCartDeliveryGroup.Id);
        insert testCartItem;
        
        CartCheckoutSession  testCartCheckoutSession = new CartCheckoutSession(WebCartId = testWebCart.Id, IsArchived = false, Name = testWebCart.Name, State = 'Order Confirmation' );
        insert testCartCheckoutSession;

        Profile testStandardUser = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        Id testCommunityProfile = [select id from profile where name='Customer Community Plus User'].id;
        
        Contact objcontact = new Contact(LastName ='TestContact',AccountId = testAccount.Id, Email = 'testContact@gmail.com');
        insert objcontact;
                
        Set<Id> setOrderIds = new Set<Id>();
        ConnectApi.CartItemCollection cartItemCollection = B2BCartController.getCartItems(community.NetworkId, testBuyerAccount.BuyerId, testWebCart.id,null,null );
        List<Order> lstOrder = new List<Order>();
        for(Integer iIndex = 0 ; iIndex <3; iIndex++){
            Order testOrder = new Order();
            testOrder.AccountId= testAccount.Id;  
            testOrder.SalesStoreId= testWebStore.Id; 
            testOrder.Status='Draft';
            testOrder.EffectiveDate=date.today();
            testOrder.External__c = true;
            testOrder.OrderedDate = Date.today();
            lstOrder.add(testOrder);
        }
        insert lstOrder;
        
        for(Integer iIndex = 0 ; iIndex < lstOrder.size(); iIndex++){
            setOrderIds.add(lstOrder[iIndex].Id);
        }
        
        OrderDeliveryMethod odm = [SELECT Id FROM OrderDeliveryMethod where Name = 'Default Delivery Method'];
        
        List<OrderDeliveryGroup> lstOrderDeliveryGroup = new List<OrderDeliveryGroup>();
        for(Integer iIndex = 0 ; iIndex < lstOrder.size(); iIndex++){
            OrderDeliveryGroup testOrderDeliveryGroup = new OrderDeliveryGroup();
            testOrderDeliveryGroup.OrderId=lstOrder[iIndex].Id;
            testOrderDeliveryGroup.OrderDeliveryMethodId=odm.Id; 
            testOrderDeliveryGroup.DeliverToName='The Shipping Address';
            testOrderDeliveryGroup.AccessCode__c = '123';
            testOrderDeliveryGroup.BOLNumber__c = '';
            testOrderDeliveryGroup.AccountExternalNumber__c = '0821313144';
            testOrderDeliveryGroup.MaterialNumber__c = '000000000000010325';
            testOrderDeliveryGroup.DesiredDeliveryDate = Date.today(); 
            testOrderDeliveryGroup.Quantity__c = 1;
            testOrderDeliveryGroup.PONumber__c = '123';
            testOrderDeliveryGroup.Description = '';
            testOrderDeliveryGroup.DeliveryInstructions = '';
            testOrderDeliveryGroup.ShipmentTonnage__c = 900;        
            testOrderDeliveryGroup.ShipmentStatus__c = 'Cancelled'; 
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
            testOrderDeliveryGroup.Canceled_By__c = UserInfo.getUserId();
            testOrderDeliveryGroup.Canceled_On__c = DateTime.now();
            lstOrderDeliveryGroup.add(testOrderDeliveryGroup);
        }
        insert lstOrderDeliveryGroup;
        
        List<OrderItem> lstOrderItem = new List<OrderItem>();
        for(Integer iIndex = 0 ; iIndex < lstOrder.size(); iIndex++){
            OrderItem testOrderItem = new OrderItem();
            testOrderItem.OrderId=lstOrder[iIndex].Id;
            testOrderItem.OrderDeliveryGroupId = lstOrderDeliveryGroup[iIndex].Id; 
            testOrderItem.Product2Id=testProduct.Id; 
            testOrderItem.Quantity=1;
            testOrderItem.ListPrice=999;
            testOrderItem.UnitPrice=999;
            testOrderItem.TotalLineAmount=999;
            testOrderItem.Type='Order Product';
            lstOrderItem.add(testOrderItem);
        }
        insert lstOrderItem;
        
        List<Order> lstOrderUpdate = new List<Order>();
        for(Integer iIndex = 0 ; iIndex < lstOrder.size(); iIndex++){
            Order testOrderUpdate = new Order();
            testOrderUpdate.Id = lstOrder[iIndex].Id ;
            testOrderUpdate.Status = 'Activated';
            lstOrderUpdate.add(testOrderUpdate);
        }
        update lstOrderUpdate;
        
        for(Integer iIndex = 0 ; iIndex < lstOrder.size(); iIndex++){
            ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
            osir.orderId = lstOrderUpdate[iIndex].Id;
            osir.orderLifeCycleType = 'UNMANAGED';
            ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        }
        
        List<OrderSummary> lstOrderSummary = [SELECT Id,AccountId,OwnerId,OriginalOrderId FROM OrderSummary WHERE OriginalOrderId IN : setOrderIds];
        
        Test.startTest();
        System.assertEquals(0, Limits.getEmailInvocations(),'Check no emails are send before cancel of Order');        
        OrgAllOrderCancelEmails.sendAllUserEmail(lstOrderSummary); 
        //OCC-007
        System.assertEquals(1, Limits.getEmailInvocations(),'Check no emails are send on Order because there is no user with email preferences expect System Admin');
       
        Account objAccountUpdate = new Account();
        objAccountUpdate.Order_Cancellation_Emails__c ='test@test.com,test@demo.com';
        objAccountUpdate.Id = testAccount.Id;
        update objAccountUpdate;
        
        User testUser = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = testCommunityProfile, country='United States',IsActive =true,
                                 ContactId = objContact.Id,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com',Email_Preferences__c='All Order Cancellation;All Order Submission;All Order Confirmation');
        
        insert testUser;
        
        System.assertEquals(1, Limits.getEmailInvocations(),'Check no emails are send before cancel of Order expect System Admin');        
        OrgAllOrderCancelEmails.sendAllUserEmail(lstOrderSummary);  
        //OCC-006
        System.assertEquals(2, Limits.getEmailInvocations(),'Check emails are send on cancel of Order');
        System.assertNotEquals(0, Limits.getEmailInvocations(),'Check emails are send on cancel of Order');
        
        for(OrderSummary objOrderSummary : lstOrderSummary){
            System.assertEquals(testAccount.Id, objOrderSummary.AccountId,'Check Order Summary is created for Test Account');
            System.assertEquals(true,setOrderIds.contains(objOrderSummary.OriginalOrderId),'Check Order Summary\'s Original Order is test order');
            System.assertNotEquals(NULL, objOrderSummary.AccountId,'Check Order Summary is created for Test Account');
            System.assertNotEquals(false,setOrderIds.contains(objOrderSummary.OriginalOrderId),'Check Order Summary\'s Original Order is test order');
        }
        
        for(OrderDeliveryGroup objOrderDeliveryGroup :[SELECT Id,ShipmentStatus__c,Canceled_By__c  FROM OrderDeliveryGroup WHERE OrderId IN : setOrderIds]){
            System.assertEquals('Cancelled',objOrderDeliveryGroup.ShipmentStatus__c,'Check Order Delivery Group Status is Cancelled');
            System.assertEquals(UserInfo.getUserId(), objOrderDeliveryGroup.Canceled_By__c,'Check Order Delivery Group is Canceled By test user');
            System.assertNotEquals('Submitted',objOrderDeliveryGroup.ShipmentStatus__c,'Check Order Delivery Group Status not other than Cancelled');
        }
        Test.stopTest();
    }
}