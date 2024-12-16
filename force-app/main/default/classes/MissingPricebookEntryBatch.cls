public class MissingPricebookEntryBatch implements Database.Batchable<SObject>, Database.Stateful {
    private Set<String> activeCurrencyCodes = new Set<String>();
    private Set<Id> pricebookIds = new Set<Id>();
    private Id standardPricebookId;
    private Id carmeusePricebookId;
    private Set<Id> failedProductIds = new Set<Id>();
    
    // Constructor to initialize active currencies and pricebook IDs
    public MissingPricebookEntryBatch() {
        // Query all active currencies in bulk
        List<CurrencyType> activeCurrencies = [SELECT IsoCode FROM CurrencyType WHERE IsActive = true];
        for (CurrencyType currencyC : activeCurrencies) {
            activeCurrencyCodes.add(currencyC.IsoCode);
        }
        
        // Query pricebook IDs in bulk, include IsStandard field in the query
        Pricebook2[] pricebooks = [SELECT Id, Name, IsStandard FROM Pricebook2 WHERE IsStandard = true OR Name = 'Carmeuse'];
        for (Pricebook2 pb : pricebooks) {
            if (pb.IsStandard) {
                standardPricebookId = pb.Id;
            }
            if (pb.Name == 'Carmeuse') {
                carmeusePricebookId = pb.Id;
            }
        }
        
        // Add the pricebook IDs to the set
        pricebookIds.add(standardPricebookId);
        pricebookIds.add(carmeusePricebookId);
    }  
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query for products that meet the conditions in bulk
        String query = 'SELECT Id, Name FROM Product2 WHERE is_offline__c = true AND IsActive = true AND sap_id__c != null';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Product2> scope) {
        List<PricebookEntry> pricebookEntriesToInsert = new List<PricebookEntry>();
        Set<Id> productsToCheck = new Set<Id>();
        
        // Collect all product IDs for query and processing
        for (Product2 product : scope) {
            productsToCheck.add(product.Id);
        }
        
        // Bulk query existing PricebookEntries for all products in scope for both pricebooks and currencies
        Map<String, List<PricebookEntry>> existingEntriesMap = new Map<String, List<PricebookEntry>>();
        for (String currencyCode : activeCurrencyCodes) {
            List<PricebookEntry> existingEntries = [
                SELECT CurrencyIsoCode, Pricebook2Id, Product2Id 
                FROM PricebookEntry 
                WHERE Product2Id IN :productsToCheck 
                AND CurrencyIsoCode = :currencyCode 
                AND Pricebook2Id IN :pricebookIds
            ];
            
            for (PricebookEntry entry : existingEntries) {
                String key = entry.Product2Id + '-' + entry.CurrencyIsoCode;
                if (!existingEntriesMap.containsKey(key)) {
                    existingEntriesMap.put(key, new List<PricebookEntry>());
                }
                existingEntriesMap.get(key).add(entry);
            }
        }
        
        // Iterate over the products and currencies to check for missing entries
        for (Product2 product : scope) {
            for (String currencyCode : activeCurrencyCodes) {
                String key = product.Id + '-' + currencyCode;
                List<PricebookEntry> existingEntries = existingEntriesMap.get(key);
                
                if (existingEntries == null) {
                    existingEntries = new List<PricebookEntry>();
                }
                
                Set<Id> existingPricebooksForCurrency = new Set<Id>();
                for (PricebookEntry entry : existingEntries) {
                    existingPricebooksForCurrency.add(entry.Pricebook2Id);
                }
                
                // Check for missing entries and add them to the list
                if (!existingPricebooksForCurrency.contains(standardPricebookId)) {
                    pricebookEntriesToInsert.add(new PricebookEntry(
                        Pricebook2Id = standardPricebookId,
                        Product2Id = product.Id,
                        CurrencyIsoCode = currencyCode,
                        IsActive = true,
                        UnitPrice = 0
                    ));
                }
                if (!existingPricebooksForCurrency.contains(carmeusePricebookId)) {
                    pricebookEntriesToInsert.add(new PricebookEntry(
                        Pricebook2Id = carmeusePricebookId,
                        Product2Id = product.Id,
                        CurrencyIsoCode = currencyCode,
                        IsActive = true,
                        UnitPrice = 0
                    ));
                }
            }
        }
        
        // Insert the missing pricebook entries in bulk to stay within governor limits
        if (!pricebookEntriesToInsert.isEmpty()) {
            try {
                insert pricebookEntriesToInsert;
            } catch (DmlException e) {
                // Track failed products in case of an error
                for (Product2 product : scope) {
                    failedProductIds.add(product.Id);
                }
                System.debug('Error inserting PricebookEntry records: ' + e.getMessage());
            }
        }
    }
    
    // Finish method
    public void finish(Database.BatchableContext BC) {
        if (!failedProductIds.isEmpty()) {
            System.debug('Products with failed PricebookEntry insertions: ' + failedProductIds);
        } else {
            System.debug('All PricebookEntry records were inserted successfully.');
        }
    }
}