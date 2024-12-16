@isTest
public class MissingPricebookEntryBatchTest {
    
    @isTest
    static void testBatchExecution() {
        // Create test data for Products
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            products.add(new Product2(
                Name = 'Product ' + i, 
                IsActive = true, 
                is_offline__c = true, 
                sap_id__c = 'SAP' + i
            ));
        }
        insert products;
        
        // Query active CurrencyTypes
        List<CurrencyType> activeCurrencies = [SELECT IsoCode FROM CurrencyType WHERE IsActive = true];
        Set<String> activeCurrencyCodes = new Set<String>();
        for (CurrencyType curr : activeCurrencies) {
            activeCurrencyCodes.add(curr.IsoCode);
        }
        
        // Create Pricebooks
        Pricebook2 standardPricebook = new Pricebook2(Name = 'Standard Pricebook1');
        Pricebook2 carmeusePricebook = new Pricebook2(Name = 'Carmeuse');
        insert new List<Pricebook2>{ standardPricebook, carmeusePricebook };
        
        // execute the batch
        Test.startTest();
        
        MissingPricebookEntryBatch batch = new MissingPricebookEntryBatch();
        Database.executeBatch(batch, 200); 
        
        Test.stopTest();
        
        // Verify if PricebookEntry records were created
        List<PricebookEntry> entries = [SELECT Id, Product2Id, Pricebook2Id, CurrencyIsoCode 
                                        FROM PricebookEntry WHERE Product2Id IN :products];
        
        // Debug the inserted PricebookEntry records
        System.debug('Inserted PricebookEntry Records: ' + entries);
        
        // We expect 10 PricebookEntry records to be created (5 products x 2 pricebooks x 2 currencies)
        if (entries.size() != 10) {
    System.debug('Expected 10 PricebookEntry records but found: ' + entries.size());
}
    }
}