@isTest
public class ev_CICMarketInforCarmeuseSaleBatchTest {
    
    @isTest
    public static void testBatchExecution() {
        Account accountNA = new Account(Name = 'North America Account', Customer_Region__c = 'North America');
        Account accountEU = new Account(Name = 'EU Account', Customer_Region__c = 'Western Europe');
        insert new List<Account>{accountNA, accountEU};
            
            Product2 product130 = new Product2(Name = 'Product 130', Family = '130', IsActive = true,Is_Offline__c = true);
        Product2 product120 = new Product2(Name = 'Product 120', Family = '120',IsActive = true,Is_Offline__c = true);
        insert new List<Product2>{product130, product120};
            
            // Create Competitor (Carmeuse)
            Competitor__c competitor = new Competitor__c(Name = 'Carmeuse', RecordTypeId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByName().get('Company').getRecordTypeId());
        insert competitor;
        
        // Create AccountInvoice__c records and link them directly to Account
        AccountInvoice__c aiNA = new AccountInvoice__c(
            Product__c = product130.Id,
            AccountInvoiceRelation__c = accountNA.Id,
            SalesInvoiceQuantity__c = 100,
            SAP_ID__c = '00SAP123-NA',  // Modified for uniqueness
            InvoiceDate__c = System.today().addYears(-1),
            Invoice_Number__c = '00123456-NA'  // Modified for uniqueness
        );
        
        AccountInvoice__c aiEU = new AccountInvoice__c(
            Product__c = product120.Id,
            AccountInvoiceRelation__c = accountEU.Id,
            SalesInvoiceQuantity__c = 200,
            SAP_ID__c = 'SAP00124-EU',  // Modified for uniqueness
            InvoiceDate__c = System.today().addYears(-1),
            Invoice_Number__c = '00123456-EU'  // Modified for uniqueness
        );
        
        insert new List<AccountInvoice__c>{aiNA, aiEU};
            Test.startTest();
        ev_CICMarketInforCarmeuseSaleBatch batch = new ev_CICMarketInforCarmeuseSaleBatch();
        Database.executeBatch(batch, 2);  
        
        Test.stopTest();
        
        List<Market_Info__c> marketInfoList = [SELECT Id, Customerprospect__c, SoldTo__c, Tonnage__c, Competitor__c, Year__c, Name, ProductHierarchyLevel1__c, RecordTypeId 
                                               FROM Market_Info__c];
        
        System.assertEquals(2, marketInfoList.size(), 'Expected 2 Market_Info records to be created');
        Market_Info__c marketInfoNA = marketInfoList[0];
        System.assertEquals(marketInfoNA.Tonnage__c, 100, 'Tonnage for North America should be 100');
        Market_Info__c marketInfoEU = marketInfoList[1];
        System.assertEquals(marketInfoEU.RecordTypeId, Schema.SObjectType.Market_Info__c.getRecordTypeInfosByName().get('MarketInfo EU').getRecordTypeId(), 'Record Type for EU should be MarketInfo EU');
        System.assertEquals(marketInfoEU.Customerprospect__c, accountEU.Id, 'ShipToId (Customerprospect) should match the EU Account');
        System.assertEquals(marketInfoEU.Tonnage__c, 200, 'Tonnage for EU should be 200');
    }
    
    @isTest
    public static void testEmptyBatch() {
        Test.startTest();
        ev_CICMarketInforCarmeuseSaleBatch batch = new ev_CICMarketInforCarmeuseSaleBatch();
        Database.executeBatch(batch, 2); // Execute with no records to check for handling empty data
        Test.stopTest();
        
    }
    
}