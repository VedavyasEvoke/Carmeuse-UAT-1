/*---------------------------------------------------------------------------------------------------------------------------------------------
Author : Ravikant Vijapure.
Description : Creating the all required data for the test class.
-----------------------------------------------------------------------------------------------------------------------------------------------
VERSION    ISSUE NUMBER 	    DATE 		    AUTHOR 			 				DETAIL
1.0        CARMEUSE-163       08/02/2024    Ravikant Vijapure   Creating the all required data for the test class. It provides code reuseability.
1.1        CARMEUSE-188       05/12/2024    Ravinkant Vijapure     Added method for create order item for the orders.
-----------------------------------------------------------------------------------------------------------------------------------------------*/
@IsTest
public class TestDataFactory {
    
    public static SalesChannel createSalesChannel(){
        SalesChannel objSalesChannel = new SalesChannel();
        objSalesChannel.SalesChannelName = 'SAP';
        objSalesChannel.Description = 'SAP';
        
        Database.SaveResult result = Database.insert(objSalesChannel, false);
        return objSalesChannel;
    }
    
    public static WebStore createWebStore(){
        WebStore objStore = new WebStore();
        objStore.Name = 'Carmeuse Customer Portal';      
        Database.SaveResult result = Database.insert(objStore, false);        
        return objStore;
    }
    
    public static ProductCatalog createProductCatalog(){
        ProductCatalog objCatalog = new ProductCatalog();
        objCatalog.Name = 'Carmeuse Product Catalog';      
        Database.SaveResult result = Database.insert(objCatalog, false);        
        return objCatalog;
    }
    
    public static ProductCategory createProductCategory(Id catalogId){
        ProductCategory objCategory = new ProductCategory();
        objCategory.Name = 'My Products';      
        objCategory.CatalogId = catalogId;
        Database.SaveResult result = Database.insert(objCategory, false);        
        return objCategory;
    }

    public static OrderDeliveryMethod createOrderDeliveryMethod(){
        OrderDeliveryMethod objOrderDeliveryMethod = new OrderDeliveryMethod();
        objOrderDeliveryMethod.Name = 'Default Delivery Method'; 
        objOrderDeliveryMethod.IsActive = true; 
        Database.SaveResult result = Database.insert(objOrderDeliveryMethod, false);        
        return objOrderDeliveryMethod;
    }
    
    public static List<BuyerGroup> createBuyerGroup(List<Account> lstAccounts, Integer numberOfRecords){
        List<BuyerGroup> lstBuyerGroup = new List<BuyerGroup>();
        if (lstAccounts.isEmpty() || numberOfRecords <= 0) {
            return lstBuyerGroup;
        }
        
        for(Integer i=0; i<numberOfRecords; i++){
            BuyerGroup objBG = new BuyerGroup();
            objBG.Name = 'BG-'+lstAccounts[i].Name;
            objBG.Account__c = lstAccounts[i].Id;
            lstBuyerGroup.add(objBG);
        }          
        if(lstBuyerGroup.size() > 0){
            Database.SaveResult[] result = Database.insert(lstBuyerGroup, false);
        }
        return lstBuyerGroup;
    }
    
    public static BuyerGroupMember createBuyerGroupMember(Id buyerAccountId, Id buyerGroupId, Integer numberOfRecords){
        BuyerGroupMember objBGM = new BuyerGroupMember();
        objBGM.BuyerId = buyerAccountId;
        objBGM.BuyerGroupId = buyerGroupId;
        Database.SaveResult result = Database.insert(objBGM, false);        
        return objBGM;
    } 

    //Added old methods causing deployment, disscuss with evoke team
    public static Account createAccount(String name, Boolean pCommit) {
        return createAccount(null, name, pCommit);
    }
    public static Account createAccount(Id parentId, String name, Boolean pCommit) {
        String randomStr = '1' + getRandomString(8);
        Account newRecord = new Account(Name = name,        
                                        ShippingStreet = 'Test Street', ShippingCity = 'Cleveland', ShippingPostalCode = '44114', ShippingCountry = 'United States', AccountExternalNumber__c = '123');
        if (pCommit == true) {
            insert newRecord;
        }
        return newRecord;
    }
    public static String getRandomString(Integer pLength) {
        String oStr = EncodingUtil.convertToHex(Crypto.generateAesKey(192));
        return (pLength != null && oStr.length() > pLength) ? oStr.substring(0, pLength) : oStr;
    }
    
    public static String toLowerCase(String str) {
        return (str != null) ? str.toLowerCase() : str;
    }
    
    public static String getRandomUsername() {
        return getRandomString(8) + '@carmeuse.com.test';
    }
    
    public static List<Account> createAccounts(Integer numberOfRecords){
        List<Account> lstAccount = new List<Account>();
        
        if(numberOfRecords <= 0){
            return lstAccount;
        }
        for(Integer i=0; i<numberOfRecords; i++){
            Account objAccount = new Account();
            objAccount.Name = 'Test Account '+i;
            objAccount.BillingCountry = 'United States';
            objAccount.BillingPostalCode = '431013';
            objAccount.AccountExternalNumber__c = '000000775'+i;
            objAccount.SPC_Email__c = 'testSPC@gmail.com';
            objAccount.Order_Submission_Emails__c = 'testSubmimssion@gmail.com';
            objAccount.B2B_Customer__c = true;
            objAccount.B2B_Business_Sub_Unit__c = 'Milled Lime Stone (MLS)';
            lstAccount.add(objAccount);
        }
        
        if(lstAccount.size() > 0){
            Database.SaveResult[] result = Database.insert(lstAccount, false);
        }
        return lstAccount;
    }
    
    public static List<Contact> createContacts(List<Account> lstAccounts, Id profileId, Integer numberContactsPerAccount) {
        List<Contact> lstContact = new List<Contact>();
        if(lstAccounts.isEmpty() || numberContactsPerAccount <= 0){
            return lstContact;
        }
        for(Integer i = 0; i < lstAccounts.size() * numberContactsPerAccount; i++) {
            Integer accountIndex = i / numberContactsPerAccount;
            Integer recordIndex = i - (accountIndex * numberContactsPerAccount);
            
            Account acc = lstAccounts[accountIndex];
            Contact objContact = new Contact();
            objContact.FirstName = 'Test' + (recordIndex + 1);
            objContact.LastName = 'Contact' + (recordIndex + 1);           
            objContact.AccountId = acc.Id;
            objContact.Email = 'Test' + (recordIndex + 1) + '@gmail.com';
            objContact.MailingCity = 'Mexico';
            objContact.MailingCountry = 'United State';
            objContact.MailingPostalCode = '00231';
            objContact.MailingState = 'testafter';
            objContact.MailingStreet = 'testafter';
            objContact.Department = 'testafter';
            objContact.Title = 'testafter';
            objContact.MobilePhone ='123234';
            // objContact.Suffix ='Mr.';
            objContact.MiddleName ='testafter';
            objContact.Phone = '123678';
            if(profileId != Null){
                objContact.Profile__c =  'Level 4 – Access to Level 1, Level 2 & Delegated Admin';              
            }
            
            lstContact.add(objContact);
        }   
        if(lstContact.size() > 0){
            Database.SaveResult[] result = Database.insert(lstContact, false);
        }
        return lstContact;
    }
    
    public static List<User> createUser(Id profileId, Id roleId, List<Contact> lstContact, Integer numberOFRecords){
        Integer maxSize = 3;
        List<User> lstUsers = new List<User>();
        if(profileId == Null || lstContact.isEmpty() || numberOFRecords <= 0){
            return lstUsers;
        }
        for(Integer i=0; i<numberOfRecords; i++){
            User userObj = new User();
            userObj.firstName = 'Test';
            userObj.lastName = 'enz';
            userObj.alias = lstContact[i].firstName.substring(0, maxSize) + lstContact[i].lastName.substring(0, maxSize);
            userObj.Email = lstContact[i].Email;
            userObj.EmailEncodingKey = 'UTF-8';
            userObj.LanguageLocaleKey = 'en_US';
            userObj.LocaleSidKey = 'en_US';
            userObj.country = 'United States';
            userObj.profileid = profileId;
            userObj.ContactId = lstContact[i].Id;
            if(roleId != Null){
                userObj.UserRoleId  = roleId;
            }
            userObj.Email_Preferences__c = 'Order Submission; Order Confirmation; Order Cancellation; All Order Submission; All Order Confirmation; All Order Cancellation;';
            userObj.TimeZoneSidKey = 'America/Los_Angeles';
            userObj.UserName = lstContact[i].Email;
            userObj.IsActive = true;
            userObj.Show_Pop_Up__c = false;
            lstUsers.add(userObj);
        }
        if(lstUsers.size() > 0){
            Database.SaveResult[] result = Database.insert(lstUsers, false);
        }
        return lstUsers;
    }
    
    public static List<BuyerAccount> createBuyerAccount(List<Account> lstAccounts, Integer numberOfRecords){
        List<BuyerAccount> lstBuyerAccount = new List<BuyerAccount>();
        if (lstAccounts.isEmpty() || numberOfRecords <= 0) {
            return lstBuyerAccount;
        }
        
        for(Integer i=0; i<numberOfRecords; i++){
            BuyerAccount objBuyer = new BuyerAccount();
            objBuyer.Name = 'Test Buyer'+i;
            objBuyer.BuyerId = lstAccounts[i].Id;
            lstBuyerAccount.add(objBuyer);
        }          
        
        if(lstBuyerAccount.size() > 0){
            Database.SaveResult[] result = Database.insert(lstBuyerAccount, false);
        }
        return lstBuyerAccount;
    }
    
    public static List<AccountInvoice__c> createAccountInvoice(List<Account> lstAccounts, Integer numberInvoicePerAccount){
        List<AccountInvoice__c> lstAccountInvoice = new List<AccountInvoice__c>();
        if (lstAccounts.isEmpty() || numberInvoicePerAccount <= 0) {
            return lstAccountInvoice;
        }
        for(Integer i = 0; i < lstAccounts.size() * numberInvoicePerAccount; i++) {
            Integer accountIndex = i / numberInvoicePerAccount;
            Integer recordIndex = i - (accountIndex * numberInvoicePerAccount);
            Account acc = lstAccounts[accountIndex];
            AccountInvoice__c objAccountInvoice = new AccountInvoice__c();
            objAccountInvoice.AccountInvoiceRelation__c = acc.Id;
            objAccountInvoice.InvoiceDate__c = Date.Today();
            objAccountInvoice.Invoice_Number__c = '0'+i;
            objAccountInvoice.InvoiceExternalAccountNumber__c = lstAccounts[accountIndex].AccountExternalNumber__c;
            lstAccountInvoice.add(objAccountInvoice);
        }          
        
        if(lstAccountInvoice.size() > 0){
            Database.SaveResult[] result = Database.insert(lstAccountInvoice, false);
        }
        return lstAccountInvoice;
    }
    
    public static List<CommerceEntitlementPolicy> createEntitlmentPolicy(List<Account> lstAccounts, Integer numberOfRecords){
        List<CommerceEntitlementPolicy> lstEntitlementPolicyies = new List<CommerceEntitlementPolicy>();
        if (lstAccounts.isEmpty() || numberOfRecords <= 0) {
            return lstEntitlementPolicyies;
        }
        for(Integer i=0; i<numberOfRecords; i++){
            CommerceEntitlementPolicy objEP = new CommerceEntitlementPolicy();
            objEP.Name = 'EP-'+lstAccounts[i].Name;
            objEP.IsActive = true;
            objEP.CanViewProduct = true;
            objEP.Account__c = lstAccounts[i].Id;
            objEP.Description = 'Entitlement Policy for '+lstAccounts[i].Name;
            lstEntitlementPolicyies.add(objEP);
        }
        if(lstEntitlementPolicyies.size() > 0){
            Database.SaveResult[] result = Database.insert(lstEntitlementPolicyies, false);
        }
        return lstEntitlementPolicyies;
    }
    
    public static List<CommerceEntitlementBuyerGroup> createCommerceEntitlementBuyerGroup(List<CommerceEntitlementPolicy> lstEP, List<BuyerGroup> lstBuyerGroup, Integer numberOfRecords){
        List<CommerceEntitlementBuyerGroup> lstCommerceEPBG = new List<CommerceEntitlementBuyerGroup>();
        if (lstEP.isEmpty() || lstBuyerGroup.isEmpty() || numberOfRecords <= 0) {
            return lstCommerceEPBG;
        }
        for(Integer i=0; i<numberOfRecords; i++){
            CommerceEntitlementBuyerGroup objEPBG = new CommerceEntitlementBuyerGroup();
            objEPBG.PolicyId = lstEP[i].Id;
            objEPBG.BuyerGroupId = lstBuyerGroup[i].Id;
            lstCommerceEPBG.add(objEPBG);
        }  
        if(lstCommerceEPBG.size() > 0){
            Database.SaveResult[] result = Database.insert(lstCommerceEPBG, false);
        }
        return lstCommerceEPBG;
    }
    
    public static WebStoreBuyerGroup createWebStoreBuyerGroup( Id storeId, Id buyerGroupId, Integer numberOfRecords){
        
        if (storeId == NULL || buyerGroupId == NULL || numberOfRecords <= 0) {
            return NULL;
        }
        WebStoreBuyerGroup objWebStoreBG = new WebStoreBuyerGroup();
        objWebStoreBG.BuyerGroupId = buyerGroupId;
        objWebStoreBG.WebStoreId = storeId;
        Database.SaveResult result = Database.insert(objWebStoreBG, false);        
        return objWebStoreBG;
    }   
    
    public static List<WebCart> createWebCart(Id storeId, List<Account> lstAccount, Boolean isQuickSave, Integer numberOfRecords){
        List<WebCart> lstWebCart = new List<WebCart>();
        if (storeId == NULL || lstAccount.isEmpty() || numberOfRecords <= 0) {
            return lstWebCart;
        }
        for(Integer i=0; i<numberOfRecords; i++){
            WebCart objWebCart = new WebCart();
            objWebCart.Name = 'Cart';
            objWebCart.AccountId = lstAccount[i].Id;
            objWebCart.WebStoreId = storeId;
            objWebCart.Is_Quick_Save__c = isQuickSave;
            lstWebCart.add(objWebCart);
        }
        if(lstWebCart.size() > 0){
            Database.SaveResult[] result = Database.insert(lstWebCart, false);      
        }
        return lstWebCart;
    }   
    
    public static List<CartCheckoutSession> createCartCheckout(List<WebCart> lstCart, Integer numberOfRecords){
        List<CartCheckoutSession> lstCartCheckoutSession = new List<CartCheckoutSession>();
        if (lstCart.isEmpty() || numberOfRecords <= 0) {
            return lstCartCheckoutSession;
        }
        for(Integer i=0; i<numberOfRecords; i++){
            CartCheckoutSession objCartCheckout = new CartCheckoutSession();
            objCartCheckout.Name = lstCart[0].Name;
            objCartCheckout.WebCartId = lstCart[0].Id;
            objCartCheckout.State = 'Order Confirmation';
            objCartCheckout.IsArchived = false;
            lstCartCheckoutSession.add(objCartCheckout);
        }
        if(lstCartCheckoutSession.size() > 0){
            Database.SaveResult[] result = Database.insert(lstCartCheckoutSession, false);
        }     
        return lstCartCheckoutSession;
    }   
    
    public static List<ContactPointAddress> createContactPointAddress(List<Account> lstAccounts, Integer numberOfRecords){
        List<ContactPointAddress> lstContactPointAddress = new List<ContactPointAddress>();
        if(lstAccounts.isEmpty() || numberOfRecords <= 0){
            return lstContactPointAddress;
        }
        for(Integer i=0; i<numberOfRecords; i++){
            ContactPointAddress objBillingAddress = new ContactPointAddress();
            objBillingAddress.Name = 'Test';
            objBillingAddress.ParentId = lstAccounts[0].Id;
            objBillingAddress.AddressType = 'Billing';
            objBillingAddress.Street = 'High Street';
            objBillingAddress.City = 'Pune';
            objBillingAddress.State = 'Maharashtra';
            objBillingAddress.PostalCode = '410045';
            objBillingAddress.Country = 'India';
            objBillingAddress.IsDefault = true;
            lstContactPointAddress.add(objBillingAddress);
            
            //ContactPointAddress objShippingAddress = objBillingAddress.clone();
            //objShippingAddress.AddressType = 'Shipping';
            //lstContactPointAddress.add(objBillingAddress);
        }  
        if(lstContactPointAddress.size() > 0){
            Database.SaveResult[] result = Database.insert(lstContactPointAddress, false);
        }
        return lstContactPointAddress;
    }
    
    public static List<Pricebook2> createPricebook(List<Account> lstAccounts, Integer numberOfRecords){
        List<Pricebook2> lstPricebook2 = new List<Pricebook2>();
        if(lstAccounts.isEmpty() || numberOfRecords <= 0){
            return lstPricebook2;
        }
        for(Integer i=0; i<numberOfRecords; i++){
            Pricebook2 objPB = new Pricebook2();
            objPB.Name = 'PB - '+lstAccounts[i].Name;
            objPB.Description = lstAccounts[i].Name;
            objPB.PriceBookExternalId__c = lstAccounts[i].Name;
            objPB.IsActive = true;
            lstPricebook2.add(objPB);
        } 
        if(lstPricebook2.size() > 0){
            Database.SaveResult[] result = Database.insert(lstPricebook2, false);
        }
        return lstPricebook2;
    }
    
    public static List<BuyerGroupPricebook> createBuyerGroupPricebook(List<Pricebook2> lstPricebook, List<BuyerGroup> lstBuyerGroup, Integer numberOfRecords){
        List<BuyerGroupPricebook> lstBGPB = new List<BuyerGroupPricebook>();
        if(lstPricebook.isEmpty() || lstBuyerGroup.isEmpty() || numberOfRecords <= 0){
            return lstBGPB;
        }
        for(Integer i=0; i<numberOfRecords; i++){
            BuyerGroupPricebook objBGPB = new BuyerGroupPricebook();
            objBGPB.BuyerGroupId = lstBuyerGroup[i].Id;
            objBGPB.Pricebook2Id = lstPricebook[i].Id;
            objBGPB.IsActive = true;
            lstBGPB.add(objBGPB);
        } 
        if(lstBGPB.size() > 0){
            Database.SaveResult[] result = Database.insert(lstBGPB, false);
        }
        return lstBGPB;
    }
    
    public static List<WebStorePricebook> createWebStorePricebook(List<Pricebook2> lstPB, Id webStoreIds, Integer numberOfRecords){
        List<WebStorePricebook> lstWebStorePB = new List<WebStorePricebook>();
        if(lstPB.isEmpty() || webStoreIds == NULL ||  numberOfRecords <= 0 ){
            return lstWebStorePB;
        }
        for(Integer i=0; i<numberOfRecords; i++){
            WebStorePricebook objWebStorePB = new WebStorePricebook();
            objWebStorePB.WebStoreId = webStoreIds;
            objWebStorePB.IsActive = true;
            objWebStorePB.Pricebook2Id = lstPB[i].Id;
            lstWebStorePB.add(objWebStorePB);           
        }  
        if(lstWebStorePB.size() > 0){
            Database.SaveResult[] result = Database.insert(lstWebStorePB, false);
        }
        return lstWebStorePB;
    }

    public static List<PricebookEntry> createStandardPriceBookEntry(Id Pricebook2Id, List<Product2> lstProducts) {
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        if(Pricebook2Id==null || lstProducts.size() <= 0){
            return lstPricebookEntry;
        }
        //Integer entryPerPriceBook = lstProducts.size() / lstPricebook2.size();
        for (Integer i = 0; i < lstProducts.size(); i++) {
           // Integer priceBookIndex = i / numberEntriesPerPB;
           // Integer productIndex = (priceBookIndex * entryPerPriceBook) + (i - priceBookIndex * numberEntriesPerPB);
            String[] qouteNumber = lstProducts[i].StockKeepingUnit.split('-');
            
            PricebookEntry objEntry = new PricebookEntry();
            objEntry.Pricebook2Id = Pricebook2Id;
            objEntry.Product2Id = lstProducts[i].Id;
            objEntry.UnitPrice = 400;
            objEntry.Quote_Number__c = qouteNumber[3];
            objEntry.OriginationPlant__c = lstProducts[i].Plant_code__c;
            objEntry.ValidFrom__c = lstProducts[i].Valid_From__c;
            objEntry.ValidTo__c = lstProducts[i].Valid_To__c;
            objEntry.ShipmentSizeType__c = lstProducts[i].Ship__c;
            objEntry.Shipping_Condition__c = lstProducts[i].Shipping_Condition__c;
            objEntry.IsActive = true;
            objEntry.PO_Number__c = 'TEST-PO';
            
            lstPricebookEntry.add(objEntry);
        }   
        if(lstPricebookEntry.size() > 0){
            Database.SaveResult[] result = Database.insert(lstPricebookEntry, false);
        }
        return lstPricebookEntry;
    }
    public static List<PricebookEntry> createPriceBookEntry(List<Pricebook2> lstPricebook2, List<Product2> lstProducts, Integer numberEntriesPerPB) {
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        if(lstPricebook2.isEmpty() || numberEntriesPerPB <= 0){
            return lstPricebookEntry;
        }
        Integer entryPerPriceBook = lstProducts.size() / lstPricebook2.size();
        for (Integer i = 0; i < lstPricebook2.size() * numberEntriesPerPB; i++) {
            Integer priceBookIndex = i / numberEntriesPerPB;
            Integer productIndex = (priceBookIndex * entryPerPriceBook) + (i - priceBookIndex * numberEntriesPerPB);
            String[] qouteNumber = lstProducts[productIndex].StockKeepingUnit.split('-');
            
            PricebookEntry objEntry = new PricebookEntry();
            objEntry.Pricebook2Id = lstPricebook2[priceBookIndex].Id;
            objEntry.Product2Id = lstProducts[productIndex].Id;
            objEntry.UnitPrice = 333;
            objEntry.Quote_Number__c = qouteNumber[2];
            objEntry.OriginationPlant__c = lstProducts[productIndex].Plant_code__c;
            objEntry.ValidFrom__c = lstProducts[productIndex].Valid_From__c;
            objEntry.ValidTo__c = lstProducts[productIndex].Valid_To__c;
            objEntry.ShipmentSizeType__c = lstProducts[productIndex].Ship__c;
            objEntry.Shipping_Condition__c = lstProducts[productIndex].Shipping_Condition__c;
            objEntry.IsActive = true;
            objEntry.PO_Number__c = 'TEST-PO';
            
            lstPricebookEntry.add(objEntry);
        }   
        if(lstPricebookEntry.size() > 0){
            Database.SaveResult[] result = Database.insert(lstPricebookEntry, false);
        }
        return lstPricebookEntry;
    }
    
    public static List<Product2> createProduct(Integer SAP_Probability, Integer numberOfRecords){
        List<Product2> lstProduct = new List<Product2>();
        if(numberOfRecords <= 0){
            return lstProduct;
        }
        for(Integer i=0; i<numberOfRecords; i++){
            Product2 objProduct = new Product2();
            objProduct.Name = 'HiCal QL Pulv W/Flo Aid Bulk'+i;
            objProduct.StockKeepingUnit = '000000000000010325-0000001236-0000123456-00012'+i;
            objProduct.MaterialNumber__c = '000000000000010325-0000001236-0000123456-00012'+i;
            objProduct.MaterialDescription__c = 'HiCal QL Pulv W/Flo Aid Bulk'+i;
            objProduct.ProductCode = '10325';
            //objProduct.Ship__c = 'Dump Trailer';
            //objProduct.Shipping_Condition__c = 'Customer Pick up';
            objProduct.Plant_code__c = 'RV';
            objProduct.Valid_From__c = Date.Today();
            objProduct.Valid_To__c = Date.Today()+300;  
            objProduct.SAP_Probability__c = SAP_Probability;
            objProduct.Carrier__c = 'RV CARRIER LTD';
            objProduct.IsActive = true;
            lstProduct.add(objProduct);
        }          
        if(lstProduct.size() > 0){
            Database.SaveResult[] result = Database.insert(lstProduct, false);
        }
        return lstProduct;
    }
    
    public static List<CommerceEntitlementProduct> createCommerceEntitlementProduct(List<Product2> lstProduct, List<CommerceEntitlementPolicy> lstPolicies, Integer numberOfRecordsPerPolicy) {
        List<CommerceEntitlementProduct> lstEntitlmentProduct = new List<CommerceEntitlementProduct>();       
        if (lstProduct.isEmpty() || lstPolicies.isEmpty() || numberOfRecordsPerPolicy == null || numberOfRecordsPerPolicy <= 0) {
            return lstEntitlmentProduct;
        }
        
        Integer productsPerPolicy = lstProduct.size() / lstPolicies.size();
        for (Integer i = 0; i < lstPolicies.size() * numberOfRecordsPerPolicy; i++) {
            Integer policyIndex = i / numberOfRecordsPerPolicy;
            Integer productIndex = (policyIndex * productsPerPolicy) + (i - policyIndex * numberOfRecordsPerPolicy);
        
            CommerceEntitlementProduct objEntitlmentProduct = new CommerceEntitlementProduct();
            objEntitlmentProduct.PolicyId = lstPolicies[policyIndex].Id;
            objEntitlmentProduct.ProductId = lstProduct[productIndex].Id;
            lstEntitlmentProduct.add(objEntitlmentProduct);
        }
        if (!lstEntitlmentProduct.isEmpty()) {
            Database.SaveResult[] result = Database.insert(lstEntitlmentProduct, false);
        }
        return lstEntitlmentProduct;
    }
    
    
    
    public static List<CartItem> createCartItem(List<CartDeliveryGroup> lstCDG, Id cartId, Integer numberOfRecords){
        List<CartItem> lstCartItem = new List<CartItem>();
        if(lstCDG.isEmpty() || cartId == NULL || numberOfRecords <= 0 ){
            return lstCartItem;
        }
        
        for(Integer i=0; i<numberOfRecords; i++){
            CartItem objCartItem = new CartItem();
            objCartItem.Name = 'HiCal QL Pulv W/Flo Aid Bulk';
            objCartItem.CartId = cartId;
            objCartItem.Sku = '000000000000010325-0000001236-0000123456-00012'+i;
            objCartItem.TotalPrice = 10;
            objCartItem.SalesPrice = 10;
            objCartItem.Quantity = 1.0;
            objCartItem.CartDeliveryGroupId = lstCDG[i].Id;
            lstCartItem.add(objCartItem);           
        }          
        if(lstCartItem.size() > 0){
            Database.SaveResult[] result = Database.insert(lstCartItem, false);
        }
        return lstCartItem;
    }
    
    public static List<Order> createOrder(List<Account> lstAccounts, Id webStoreId, Integer numberOfOrdersPerAccount){
        List<Order> lstOrder = new List<Order>();
        if(lstAccounts.isEmpty() || webStoreId == NULL || numberOfOrdersPerAccount <= 0 ){
            return lstOrder;
        }
        
        for(Integer i = 0; i < lstAccounts.size() * numberOfOrdersPerAccount; i++) {
            Integer accountIndex = i / numberOfOrdersPerAccount;
            Integer recordIndex = i - (accountIndex * numberOfOrdersPerAccount);
            Account acc = lstAccounts[accountIndex];
            
            Order objOrder = new Order();
            objOrder.AccountId = acc.Id;
            objOrder.SalesStoreId = webStoreId;
            objOrder.Status = 'Draft';
            objOrder.EffectiveDate= Date.today();
            objOrder.External__c = true;
            objOrder.OrderedDate = Date.today();
            lstOrder.add(objOrder);           
        }          
        if(lstOrder.size() > 0){
            Database.SaveResult[] result = Database.insert(lstOrder, false);
        }
        return lstOrder;
    }
    
    //Creating an OrderSummary record is not allowed in the test class; if you need to create a record, then declare the test class as @IsTest(SeeAllData = true).
    public static List<OrderSummary> createOrderSummary(List<Order> lstOrders, Integer numberOfRecords){
        List<OrderSummary> lstOrderSummaries = new List<OrderSummary>();
        if(lstOrders.isEmpty() || numberOfRecords <= 0 ){
            return lstOrderSummaries;
        }
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
            osir.orderId = lstOrders[i].Id;
            osir.orderLifeCycleType = 'UNMANAGED';
            ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        }
        lstOrderSummaries = [SELECT Id FROM OrderSummary];
        if(lstOrderSummaries.size() > 0){
            Database.SaveResult[] result = Database.insert(lstOrderSummaries, false);
        }
        return lstOrderSummaries;
    }
    
    public static List<OrderDeliveryGroup> createOrderDeliveryGroup(List<Order> lstOrders, Id deliveryMethodId, Integer numberOfODGPerOrder){
        List<OrderDeliveryGroup> lstOrderDeliveryGroup = new List<OrderDeliveryGroup>();
        if(lstOrders.isEmpty() || deliveryMethodId == NULL || numberOfODGPerOrder <= 0 ){
            return lstOrderDeliveryGroup;
        }
        
        for(Integer i = 0; i < lstOrders.size() * numberOfODGPerOrder; i++) {
            Integer orderIndex = i / numberOfODGPerOrder;
            Integer recordIndex = i - (orderIndex * numberOfODGPerOrder);
            Order orderId = lstOrders[orderIndex];
            
            OrderDeliveryGroup objODG = new OrderDeliveryGroup();
            objODG.OrderId = orderId.Id;
            objODG.OrderDeliveryMethodId = deliveryMethodId;
            objODG.DeliverToName = 'The Shipping Address';
            objODG.AccessCode__c = '00003328'+i;
            objODG.BOLNumber__c = 'BOLTESTAPEX';
            objODG.AccountExternalNumber__c = '0000001236';
            objODG.MaterialNumber__c = '000000000000010325-0000001236-0000123456-00012'+i;
            objODG.Material_Number_SF__c = '000000000000010325-0000001236-0000123456-00012'+i;
            objODG.Material__c = '000000000000010325-0000001236-0000123456-00012'+i;
            objODG.DesiredDeliveryDate = Date.today(); 
            objODG.Quantity__c = 1;
            objODG.Delivery_Quantity__c = 1;
            //objODG.QuoteNumber__c = '0000123456';
            objODG.SplitShipmentId__c = '65464';
            objODG.PONumber__c = 'TEST-PO';
            objODG.Description = 'Test Order';
            objODG.DeliveryInstructions = 'Test Delivery';
            objODG.ShipmentTonnage__c = 28;        
            objODG.ShipmentStatus__c = 'Submitted'; 
            objODG.ShipmentWeight__c = '100';
            objODG.ShipmentSize__c = 25;
            objODG.ShipmentSizeType__c = 'Rail';
            objODG.ShipmentDateTime__c = Date.today(); 
            objODG.DeliverToName = 'Deliver to Test';
            objODG.DeliverToCity =  'Pune';
            objODG.DeliverToCountry = 'India';
            objODG.DeliverToState =  'Maharashtra';
            objODG.DeliverToStreet = 'High Street';
            objODG.DeliverToPostalCode =  '410045';
            lstOrderDeliveryGroup.add(objODG);           
        }          
        if(lstOrderDeliveryGroup.size() > 0){
            Database.SaveResult[] result = Database.insert(lstOrderDeliveryGroup, false);
        }
        return lstOrderDeliveryGroup;
    }
    
    public static List<CartDeliveryGroup> createCartDeliveryGroup(List<Product2> lstProduct, Id cartId, Id addressId, Integer numberOfRecords){
        List<CartDeliveryGroup> lstCartDeliveryGroup = new List<CartDeliveryGroup>();
        if(lstProduct.isEmpty() || cartId == NULL || addressId == NULL || numberOfRecords <= 0 ){
            return lstCartDeliveryGroup;
        }
        
        for(Integer i=0; i<numberOfRecords; i++){
            CartDeliveryGroup objCDG = new CartDeliveryGroup();
            objCDG.Name = 'Default Delivery';
            objCDG.CartId = cartId;
            objCDG.DesiredDeliveryDate = Date.today();
            objCDG.AccountExternalNumber__c = '0000001236';
            objCDG.MaterialNumber__c = '000000000000010325-0000001236-0000123456-00012'+i;
            objCDG.Shipment_Size__c=25;
            objCDG.ShipmentSizeType__c='Rail';
            objCDG.Quantity__c= 1;
            objCDG.ShipmentTonnage__c= 28;
            objCDG.Quote_Number__c='0000123456';
            objCDG.DeliveryText__c='Cart Delivary Text';
            objCDG.SplitShipmentId__c='65464';
            objCDG.PONumber__c='TEST-PO';
            objCDG.IsHold__c=false;
            objCDG.BillingAddress__c= addressId;
            objCDG.ShippingAddress__c= addressId;
            objCDG.Next_Day_Order__c=false;
            objCDG.Material_Number_SF__c='000000000000010325-0000001236-0000123456-00012'+i;
            objCDG.DeliveryText__c = 'Test Delivery';
            objCDG.BillingAddress__c = addressId;
            objCDG.ShippingAddress__c = addressId;
            lstCartDeliveryGroup.add(objCDG);           
        }          
        if(lstCartDeliveryGroup.size() > 0){
            Database.SaveResult[] result = Database.insert(lstCartDeliveryGroup, false);
        }
        return lstCartDeliveryGroup;
    }
    
    public static List<OrderItem> createOrderItem(List<OrderDeliveryGroup> lstODG, List<Order> lstOrders, List<Product2> lstProducts) {
        List<OrderItem> lstOrderItemToInsert = new List<OrderItem>();
        if (lstODG.isEmpty() || lstOrders.isEmpty() || lstProducts.isEmpty()) {
            return lstOrderItemToInsert;
        }

        Map<Id, List<OrderDeliveryGroup>> orderToODGMap = new Map<Id, List<OrderDeliveryGroup>>();
        for (OrderDeliveryGroup odg : lstODG) {
            if (!orderToODGMap.containsKey(odg.OrderId)) {
                orderToODGMap.put(odg.OrderId, new List<OrderDeliveryGroup>());
            }
            orderToODGMap.get(odg.OrderId).add(odg);
        }
    
        for (Order order : lstOrders) {
            List<OrderDeliveryGroup> relatedODGs = orderToODGMap.get(order.Id);
            if (relatedODGs == null || relatedODGs.isEmpty()) {
                continue;
            }
            for (OrderDeliveryGroup odg : relatedODGs) {
                OrderItem objOrderItem = new OrderItem();
                objOrderItem.OrderId = order.Id;
                objOrderItem.OrderDeliveryGroupId = odg.Id;
                objOrderItem.Product2Id = lstProducts[0].Id;
                objOrderItem.Quantity = 1;
                objOrderItem.ListPrice = 999;
                objOrderItem.UnitPrice = 999;
                objOrderItem.TotalLineAmount = 999;
                objOrderItem.Type = 'Order Product';
                lstOrderItemToInsert.add(objOrderItem);
            }
        }

        if (!lstOrderItemToInsert.isEmpty()) {
            Database.SaveResult[] result = Database.insert(lstOrderItemToInsert, false);
        }
        return lstOrderItemToInsert;
    }
    
    public static List<ExtendedEntitlement__c> createExtendedEntitlement(List<Account> lstAccounts, List<Product2> lstProduct, Integer numberOfExtendedsPerAccount) {
        List<ExtendedEntitlement__c> lstExtendedEntitlement = new List<ExtendedEntitlement__c>();       
        if (lstProduct.isEmpty() || lstAccounts.isEmpty() || numberOfExtendedsPerAccount == null || numberOfExtendedsPerAccount <= 0) {
            return lstExtendedEntitlement;
        }
        
        Integer extendedsPerAccount = lstProduct.size() / lstAccounts.size();
        for (Integer i = 0; i < lstAccounts.size() * numberOfExtendedsPerAccount; i++) {
            Integer accountIndex = i / numberOfExtendedsPerAccount;
            Integer productIndex = (accountIndex * extendedsPerAccount) + (i - accountIndex * numberOfExtendedsPerAccount);
            
             ExtendedEntitlement__c objEEP = new ExtendedEntitlement__c();
                
                objEEP.Price__c = 70.0;
                objEEP.Plant_Code__c = 'KL';
                objEEP.Selected__c = true;
                objEEP.MaterialNumber__c = lstProduct[productIndex].StockKeepingUnit;
                String[] SKU_Array = lstProduct[productIndex].StockKeepingUnit.split('-');
                if(SKU_Array.size() >= 3){
                    String externalShipTo = SKU_Array[1];
                    String quoteNumber = SKU_Array[2];
                    objEEp.AccountExternalNumber__c = externalShipTo;
                    objEEP.QuoteNumber__c = quoteNumber;
                    objEEP.AccountExtendedEntitlement__c=lstAccounts[accountIndex].Id;
                    objEEp.AccountNumber__c =externalShipTo.replaceFirst('^0+', '');
                }
                lstExtendedEntitlement.add(objEEp);
           
        }
        if (!lstExtendedEntitlement.isEmpty()) {
            Database.SaveResult[] result = Database.insert(lstExtendedEntitlement, false);
        }
        return lstExtendedEntitlement;
    }

    public static Ordering_Rule__c createOrderingRule(Integer ruleDays,String plantCode,String productCode,Boolean isWeekend){
        Ordering_Rule__c objOrderingRule = new Ordering_Rule__c();
        objOrderingRule.Ordering_Rule_Days__c = ruleDays;
        objOrderingRule.Plant_Code__c = plantCode;
        objOrderingRule.Product_Code__c = productCode;
        objOrderingRule.No_Weekend_Order__c = isWeekend;

        Database.SaveResult result = Database.insert(objOrderingRule, false);
        return objOrderingRule;
    }

    public static List<Ship_To_Override_Tonnage_Limits__c> createOverrideTonnageLimit(String Name,String shipTo,Integer numberOfRecords){
        List<Ship_To_Override_Tonnage_Limits__c> lstOverrideTonnageLimit = new List<Ship_To_Override_Tonnage_Limits__c>();
        for(Integer i = 0; i < numberOfRecords; i++){
            Ship_To_Override_Tonnage_Limits__c objTonnageLimit = new Ship_To_Override_Tonnage_Limits__c();
            objTonnageLimit.Name = Name + i;
            objTonnageLimit.Ship_To__c = shipTo + i;
            lstOverrideTonnageLimit.add(objTonnageLimit);
        }

        if (!lstOverrideTonnageLimit.isEmpty()) {
            Database.SaveResult[] result = Database.insert(lstOverrideTonnageLimit, false);
        }
        return lstOverrideTonnageLimit;
    }

    public static List<Ship_To_With_Gallon_Products__c> createShipToGallonProducts(String Name,String shipTo,Integer numberOfRecords){
        List<Ship_To_With_Gallon_Products__c> lstShipToGallonProducts = new List<Ship_To_With_Gallon_Products__c>();
        for(Integer i = 0; i < numberOfRecords; i++){
            Ship_To_With_Gallon_Products__c objShipToGallonProducts = new Ship_To_With_Gallon_Products__c();
            objShipToGallonProducts.Name = Name + i;
            objShipToGallonProducts.ShipTo__c = shipTo + i;
            lstShipToGallonProducts.add(objShipToGallonProducts);
        }
        
        if (!lstShipToGallonProducts.isEmpty()) {
            Database.SaveResult[] result = Database.insert(lstShipToGallonProducts, false);
        }
        return lstShipToGallonProducts;
    }

    // Remove the method after removing the dependencies in other classes.
    public static List<Account> createTestData(){
        TriggerConfiguration.setDoNotRunTrigger();
        List<Account> lstAccount = new List<Account>();
        List<BuyerAccount> lstBuyerAccount = new List<BuyerAccount>();
        List<BuyerGroup> lstBuyerGroup = new List<BuyerGroup>();
        List<BuyerGroupMember> lstBuyerGroupMember = new List<BuyerGroupMember>();
        List<CommerceEntitlementPolicy> lstCommerceEntitlementPolicy = new List<CommerceEntitlementPolicy>();
        List<CommerceEntitlementBuyerGroup> lstCommerceEntitlementBuyerGroup = new List<CommerceEntitlementBuyerGroup>();
        List<Pricebook2> lstPricebook2 = new List<Pricebook2>();
        List<BuyerGroupPricebook> lstBuyerGroupPricebook = new List<BuyerGroupPricebook>();
        
        for(Integer Index = 0 ; Index<5 ;Index++){
            Account objAccount = new Account();
            objAccount.Name = Index + '-Test Account';
            objAccount.AccountExternalNumber__c = '000000000'+Index;
            lstAccount.add(objAccount);
        }
        insert lstAccount;
        
        for(Integer Index = 0 ; Index<5 ;Index++){
            BuyerAccount objBuyerAccount = new BuyerAccount();
            objBuyerAccount.BuyerId = lstAccount[Index].Id;
            objBuyerAccount.CommerceType = 'Buyer';
            objBuyerAccount.IsActive = true;
            objBuyerAccount.Name = lstAccount[Index].Name;
            lstBuyerAccount.add(objBuyerAccount);
        }
        insert lstBuyerAccount;
        
        for(Integer Index = 0 ; Index<5 ;Index++){
            BuyerGroup objBuyerGroup = new BuyerGroup();
            objBuyerGroup.Name = 'BG-' + lstAccount[Index].Name;
            objBuyerGroup.Description = 'Buyer Group for ' + lstAccount[Index].Name;
            objBuyerGroup.OwnerId = UserInfo.getUserId();
            objBuyerGroup.Account__c = lstAccount[Index].Id;
            lstBuyerGroup.add(objBuyerGroup);
        }
        insert lstBuyerGroup;
        
        for(Integer Index = 0 ; Index<5 ;Index++){
            BuyerGroupMember objBuyerGroupMember = new BuyerGroupMember();
            objBuyerGroupMember.BuyerId = lstAccount[Index].Id;
            objBuyerGroupMember.BuyerGroupId = lstBuyerGroup[Index].Id; 
            lstBuyerGroupMember.add(objBuyerGroupMember);
        }
        insert lstBuyerGroupMember;
        
        for(Integer Index = 0 ; Index<5 ;Index++){
            CommerceEntitlementPolicy objEntitlementPolicy = new CommerceEntitlementPolicy();
            objEntitlementPolicy.Account__c = lstAccount[Index].Id;
            objEntitlementPolicy.IsActive = true;
            objEntitlementPolicy.CanViewProduct = true;
            objEntitlementPolicy.CanViewPrice = false;
            objEntitlementPolicy.Name = 'EP-' + lstAccount[Index].Name;
            objEntitlementPolicy.Description = 'Entitlement Policy for ' + lstAccount[Index].Name;
            lstCommerceEntitlementPolicy.add(objEntitlementPolicy);
        }
        insert lstCommerceEntitlementPolicy;
        
        for(Integer Index = 0 ; Index<5 ;Index++){
            CommerceEntitlementBuyerGroup objBuyerGroupEP = new CommerceEntitlementBuyerGroup();
            objBuyerGroupEP.BuyerGroupId = lstBuyerGroup[Index].Id;
            objBuyerGroupEP.PolicyId = lstCommerceEntitlementPolicy[Index].Id; 
            lstCommerceEntitlementBuyerGroup.add(objBuyerGroupEP);
        }
        insert lstCommerceEntitlementBuyerGroup;
        
        for(Integer Index = 0 ; Index<5 ;Index++){
            Pricebook2 objPricebook2 = new Pricebook2();
            objPricebook2.Name =  'PB-' + lstAccount[Index].Name;
            objPricebook2.IsActive = true;
            objPricebook2.Description = lstAccount[Index].Name;
            objPricebook2.Account__c = lstAccount[0].Id;
            lstPricebook2.add(objPricebook2);
        }
        insert lstPricebook2;
        
        for(Integer Index = 0 ; Index<5 ;Index++){
            BuyerGroupPricebook objBuyerGroupPB = new BuyerGroupPricebook();
            objBuyerGroupPB.BuyerGroupId = lstBuyerGroup[Index].Id;
            objBuyerGroupPB.IsActive = true;
            objBuyerGroupPB.Pricebook2Id = lstPricebook2[Index].Id;
            lstBuyerGroupPricebook.add(objBuyerGroupPB);
        }
        insert lstBuyerGroupPricebook;
        
        return lstAccount;
    }

    /**
    * @description Creates Records of any object.
    * @author D Sridhar (Evoke)
    * @param records List of records to be inserted. 
    * @param doInsert Boolean value to specify whether to insert or not.
    * @param attributes Map which contains record data to be inserted.
    * @return
    */
    public static List<SObject> createRecords(List<SObject> records, Boolean doInsert, Map<String, Object> attributes){
        try{
            Integer i = 0;
            if(attributes != null){
                for (Integer j =0; j < records.size(); j ++) {
                    SObject record = records[j];
                    for (String key : attributes.keySet()) {
                        Object value = attributes.get(key);
                        if (value instanceof List<Object>) {
                            Object obj = ((List<Object>) value).get(i);
                            if( obj instanceof SObject ){
                                Id sObjectId = ((SObject) obj).Id;
                                record.put( key,sObjectId );
                            }
                            else {
                                record.put(key,obj);
                            }
                        } else {
                            record.put(key, value);
                        }
                    }
                    i++;
                }
            }
            if (doInsert) {
                Savepoint sp = Database.setSavepoint();
                Database.SaveResult[] srList1 = Database.insert(records);
            }
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return records;
    }
    
    /**
    * @description Create records.
    * @author D Sridhar (Evoke)
    * @param numToInsert Number of records to be inserted.  
    * @param doInsert Boolean value which specifies whether to insert or not.
    * @param attributes Map which contains record data to be inserted.
    * @return
    */
    public static List<sObject> createRecords(String objectName, Integer numToInsert, Boolean doInsert, Map<String, Object> attributes) {
        List<sObject> recordsToInsert = new List<sObject>();
        for(Integer i=0; i< numToInsert; i++){
            sObject record = (sObject)Type.forName(objectName).newInstance();
            recordsToInsert.add(record);
        }
        return createRecords(recordsToInsert, doInsert, attributes);
    }
}