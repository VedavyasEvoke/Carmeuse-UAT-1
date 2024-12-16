@isTest
public  class BatchToAssignProductToEPTest {
    @TestSetup
    public static void demoData(){
        TriggerConfiguration.doNotRunTrigger = true;

        Account testAccount = new Account(Name='TestAccount',BillingStreet='Test Street', BillingCountry='United States', BillingPostalCode='44444', AccountExternalNumber__c = '000123');
        insert testAccount;
        
        List<Product2> lstProduct = new List<Product2>{
            new Product2(Name = 'HiCal QL Pulv W/Flo Aid Bulk1',
                         Family = 'Lime', MaterialNumber__c = '000000000000010325-000123-00012348', StockKeepingUnit = '000000000000010325-000123-00012348', SAP_Probability__c=99, ProductCode = '10325'),
                new Product2(Name = 'HiCal QL Pulv W/Flo Aid Bulk2',
                             Family = 'Lime', MaterialNumber__c = '000000000000010325-000123-00012349', StockKeepingUnit = '000000000000010325-000123-00012349', SAP_Probability__c=1, ProductCode = '10325'),
                new Product2(Name = 'HiCal QL Pulv W/Flo Aid Bulk3',
                             Family = 'Lime', MaterialNumber__c = '000000000000010325-000123-00012346', StockKeepingUnit = '000000000000010325-000123-00012346', SAP_Probability__c=99, ProductCode = '10325'),
                new Product2(Name = 'HiCal QL Pulv W/Flo Aid Bulk4',
                             Family = 'Lime', MaterialNumber__c = '000000000000010325-000123-00012342', StockKeepingUnit = '000000000000010325-000123-00012342', SAP_Probability__c=23, ProductCode = '10325'),
                new Product2(Name = 'HiCal QL Pulv W/Flo Aid Bulk4',
                             Family = 'Lime', MaterialNumber__c = '000000000000010325-000123-00012350', StockKeepingUnit = '000000000000010325-000123-00012350', SAP_Probability__c=1, ProductCode = '10326')
                };
                    insert lstProduct;
        
        Id stdPricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrimaryPriceEntry = new PricebookEntry(
            Pricebook2Id = stdPricebookId, Product2Id = lstProduct[0].Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrimaryPriceEntry; 
        
        PricebookEntry standardPriceBackupEntry = new PricebookEntry(
            Pricebook2Id = stdPricebookId, Product2Id = lstProduct[1].Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPriceBackupEntry; 
        
        PricebookEntry standardPriceEntry = new PricebookEntry(
            Pricebook2Id = stdPricebookId, Product2Id = lstProduct[2].Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPriceEntry; 
        
        PricebookEntry standardBookEntry = new PricebookEntry(
            Pricebook2Id = stdPricebookId, Product2Id = lstProduct[3].Id,
            UnitPrice = 10000, IsActive = true);
        insert standardBookEntry; 
        
        PricebookEntry standardPriceBookEntry = new PricebookEntry(
            Pricebook2Id = stdPricebookId, Product2Id = lstProduct[4].Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPriceBookEntry; 
        
        Pricebook2 customPriceBook = new Pricebook2 (Name = 'PB-TestAccount',  IsActive = true);
        insert customPriceBook;
        
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        PricebookEntry customPriceBookEntry = new PricebookEntry(
            Pricebook2Id = customPriceBook.Id, Product2Id = lstProduct[0].Id,
            UnitPrice = 500, IsActive = true );
        lstPricebookEntry.add(customPriceBookEntry);        
        
        PricebookEntry customPriceBookBackupEntry = new PricebookEntry(
            Pricebook2Id = customPriceBook.Id, Product2Id = lstProduct[1].Id,
            UnitPrice = 500, IsActive = true );
        lstPricebookEntry.add(customPriceBookBackupEntry); 
        
        PricebookEntry customPriceBookAssignedEntry = new PricebookEntry(
            Pricebook2Id = customPriceBook.Id, Product2Id = lstProduct[2].Id,
            UnitPrice = 500, IsActive = true );
        lstPricebookEntry.add(customPriceBookAssignedEntry); 
        
        PricebookEntry customPriceBooksAssignedEntry = new PricebookEntry(
            Pricebook2Id = customPriceBook.Id, Product2Id = lstProduct[3].Id,
            UnitPrice = 500, IsActive = true );
        lstPricebookEntry.add(customPriceBooksAssignedEntry); 
        
        PricebookEntry customBookAssignedEntry = new PricebookEntry(
            Pricebook2Id = customPriceBook.Id, Product2Id = lstProduct[4].Id,
            UnitPrice = 500, IsActive = true );
        lstPricebookEntry.add(customBookAssignedEntry); 
        insert lstPricebookEntry;
        
        CommerceEntitlementPolicy testEP = new CommerceEntitlementPolicy(Name = 'Test Policy', IsActive = true, CanViewProduct = true,Account__c=testAccount.Id);
        insert testEP;
        
        CommerceEntitlementProduct epProduct = new CommerceEntitlementProduct(PolicyId = testEP.Id, ProductId = lstProduct[0].Id);
        insert epProduct;
        
        ExtendedEntitlement__c objExtendedEntitlement = new ExtendedEntitlement__c(AccountExtendedEntitlement__c = testAccount.Id,MaterialNumber__c = '0009-008-007');
        insert objExtendedEntitlement;
    }
    
    @isTest
    public static void verifyBatchToAddProductToEP(){
        List<PricebookEntry> lstStdPricebookEntry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE UnitPrice =10000];
        System.assertEquals(5, lstStdPricebookEntry.size());
        System.assertnotEquals(null, lstStdPricebookEntry.size());
        
        List<PricebookEntry> lstCustomPricebookEntry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE UnitPrice =500];
        System.assertEquals(5, lstCustomPricebookEntry.size());
        System.assertnotEquals(null, lstCustomPricebookEntry.size());
        
        Test.startTest();        
        BatchToAssignProductToEntitlementPolicy objBatchToAssignProduct = new BatchToAssignProductToEntitlementPolicy();
        DataBase.executeBatch(objBatchToAssignProduct);            
        Test.stopTest(); 
        
        List<Product2> lstProduct = [SELECT Id, Name, MaterialNumber__c FROM Product2];
        System.assertEquals(5,lstProduct.size());
        System.assertNotEquals(null,lstProduct.size());
        
        List<Account> lstAccount = [SELECT Id, Name FROM Account WHERE Name='TestAccount'];
        System.assertEquals(1,lstAccount.size());
        System.assertNotEquals(null,lstProduct.size());
        
        List<CommerceEntitlementPolicy> lstEP = [SELECT Id FROM CommerceEntitlementPolicy];
        List<ExtendedEntitlement__c> lstExtendedEntitlement = [SELECT Id, MaterialNumber__c, Plant_Code__c, AccountNumber__c FROM ExtendedEntitlement__c WHERE AccountExtendedEntitlement__c IN : lstAccount];
        List<CommerceEntitlementProduct> lstCommerceEntitlementProduct = [SELECT id,ProductId FROM CommerceEntitlementProduct WHERE PolicyId IN : lstEP]; 
        
        Set<Id> productIds = new Set<Id>();
        for(CommerceEntitlementProduct assignProductObj : lstCommerceEntitlementProduct){
            productIds.add(assignProductObj.ProductId);
        }
        //P2EP - 001
        System.assertEquals(2,productIds.size());
        System.assertNotEquals(1,productIds.size());
        System.assertEquals(true,productIds.contains(lstProduct[0].Id));
        System.assertEquals(true,productIds.contains(lstProduct[2].Id));
        //P2EP - 002
        System.assertEquals(false,productIds.contains(lstProduct[3].Id));
        System.assertNotEquals(null,productIds.contains(lstProduct[0].Id));
        
        Set<String> materialNumber = new Set<String>();
        for(ExtendedEntitlement__c assignExtendedProduct : lstExtendedEntitlement){     
            materialNumber.add(assignExtendedProduct.MaterialNumber__c);
        }
        
        //P2EP - 003
        System.assertEquals(3, materialNumber.size());
        System.assertNotEquals(null, materialNumber.size());
        System.assertEquals(true, materialNumber.contains(lstProduct[1].MaterialNumber__c));
        System.assertEquals(true, materialNumber.contains(lstProduct[4].MaterialNumber__c));
        
        //P2EP - 004 
        System.assertEquals(false, materialNumber.contains(lstProduct[3].MaterialNumber__c));
        System.assertEquals(3,lstExtendedEntitlement.size());
        System.assertNotEquals(null,lstExtendedEntitlement.size());     
    }
    @isTest
    public static void verifyProductUpdateNotAssignedToEP(){
        List<Product2> lstProduct = [SELECT Id, Name, SAP_Probability__c, CreatedDate FROM Product2 WHERE SAP_Probability__c=23];
        lstProduct[0].SAP_Probability__c = 99;
        
        update lstProduct;
        Test.startTest();        
        BatchToAssignProductToEntitlementPolicy objBatchToAssignProduct = new BatchToAssignProductToEntitlementPolicy();
        DataBase.executeBatch(objBatchToAssignProduct);            
        Test.stopTest(); 
        List<CommerceEntitlementPolicy> lstEP = [SELECT Id, Name FROM CommerceEntitlementPolicy];
        List<CommerceEntitlementProduct> lstCommerceEntitlementProduct = [SELECT id,ProductId FROM CommerceEntitlementProduct WHERE PolicyId IN : lstEP]; 
        Set<Id> productIds = new Set<Id>();
        for(CommerceEntitlementProduct assignProductObj : lstCommerceEntitlementProduct){
            productIds.add(assignProductObj.ProductId);
        }
        //P2EP - 005
        System.assertEquals(3,productIds.size());
        System.assertNotEquals(0,productIds.size());
    }
    @isTest
    public static void verifyProductUpdateNotAssignedToEEP(){
        List<Product2> lstProduct = [SELECT Id, Name, SAP_Probability__c FROM Product2 WHERE SAP_Probability__c=99];
        lstProduct[0].SAP_Probability__c = 1;
        update lstProduct;
        Test.startTest();        
        BatchToAssignProductToEntitlementPolicy objBatchToAssignProduct = new BatchToAssignProductToEntitlementPolicy();
        DataBase.executeBatch(objBatchToAssignProduct);            
        Test.stopTest(); 
        List<CommerceEntitlementPolicy> lstEP = [SELECT Id FROM CommerceEntitlementPolicy];
        List<ExtendedEntitlement__c> lstExtendedEntitlement = [SELECT Id,MaterialNumber__c FROM ExtendedEntitlement__c];
        List<CommerceEntitlementProduct> lstCommerceEntitlementProduct = [SELECT id,ProductId FROM CommerceEntitlementProduct WHERE PolicyId IN : lstEP]; 
        
        Set<String> materialNumber = new Set<String>();
        for(ExtendedEntitlement__c assignExtendedProduct : lstExtendedEntitlement){     
            materialNumber.add(assignExtendedProduct.MaterialNumber__c);
        }
        //P2EP - 003
        System.assertEquals(4, materialNumber.size());
        System.assertNotEquals(null, materialNumber.size());       
    }
    
    
    @isTest
    public static void testFinish() {      
        BatchToAssignProductToEntitlementPolicy batch = new BatchToAssignProductToEntitlementPolicy();
        batch.errorList.add('Test error message');
        Test.startTest();
        batch.finish(null);
        Test.stopTest();    
    }
    
    @isTest
    public static void testReRunBatch(){
        BatchToAssignProductToEntitlementPolicy batch = new BatchToAssignProductToEntitlementPolicy();
        batch.reRunBatch();
    }
}