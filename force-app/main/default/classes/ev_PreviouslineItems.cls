public class ev_PreviouslineItems {
    @AuraEnabled(Cacheable = true)
    public static List<SBQQ__QuoteLine__c> retrieveWonQuoteLines(String recordId) {
        return retrieveQuoteLinesByStatus(recordId, 'Accepted');
    }
    
    @AuraEnabled(Cacheable = true)
    public static List<SBQQ__QuoteLine__c> retrieveLostQuoteLines(String recordId) {
        return retrieveQuoteLinesByStatus(recordId, 'Rejected');
    }
    
    private static List<SBQQ__QuoteLine__c> retrieveQuoteLinesByStatus(String recordId, String status) {
        System.debug('Starting retrieveQuoteLinesByStatus method');
        
        Set<Id> lstProdName = new Set<Id>(); 
        List<Id> lstQuoteID = new List<Id>();
        
        // Fetch the current Quote record
        SBQQ__Quote__c SQ = [SELECT Id, SBQQ__Account__c, SBQQ__Status__c, Customer_Region__c 
                             FROM SBQQ__Quote__c WHERE Id =: recordId];
        System.debug('Fetched Quote: ' + SQ);
        
        // Fetch product IDs from the current quote's lines
        List<SBQQ__QuoteLine__c> lstQuoteLine = [SELECT Id, SBQQ__Product__r.Id 
                                                 FROM SBQQ__QuoteLine__c 
                                                 WHERE SBQQ__Quote__c =: SQ.Id];
        for (SBQQ__QuoteLine__c QL : lstQuoteLine) {
            lstProdName.add(QL.SBQQ__Product__r.Id);
            System.debug('Added Product ID to lstProdName: ' + QL.SBQQ__Product__r.Id);
        }
        System.debug('All Product IDs in lstProdName: ' + lstProdName);
        
        // Fetch previous quotes based on the status for the same account
        List<SBQQ__Quote__c> Sqs = [SELECT Id 
                                    FROM SBQQ__Quote__c 
                                    WHERE SBQQ__Account__c =: SQ.SBQQ__Account__c 
                                    AND SBQQ__Status__c =: status 
                                    ORDER BY LastModifiedDate DESC];
        for (SBQQ__Quote__c quote : Sqs) {
            lstQuoteID.add(quote.Id);
            System.debug('Added Quote ID to lstQuoteID: ' + quote.Id);
        }
        System.debug('All Quote IDs in lstQuoteID: ' + lstQuoteID);
        
        List<SBQQ__QuoteLine__c> existingQuoteLines = new List<SBQQ__QuoteLine__c>();
        Map<String, Integer> productCodeCountMap = new Map<String, Integer>();
        
        List<SBQQ__QuoteLine__c> lstQuoteLines = [SELECT Id, Name, Plant__c, SBQQ__Product__r.Id, SBQQ__ProductCode__c,  
                                                  SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Quantity__c, List_Unit_Price__c,  
                                                  Freight_Price__c, Misc_Price__c, Total_Price_per_Ton__c, Commission__c,  
                                                  Fees_Price__c, PC_Discount__c, CurrencyIsoCode, Distance__c, Default_UOM__c, SBQQ__Quote__r.Customer_Region__c,  
                                                  ZCO2__c, Total_Price__c, Currency_Format__c, UOM_Distance__c, Surcharge__c, 
                                                  SBQQ__Quote__r.Valid_From__c,SBQQ__Quote__r.Valid_To__c, Qty_UOM__c, Dist_UOM__c 	
                                                  FROM SBQQ__QuoteLine__c  
                                                  WHERE SBQQ__Product__r.Id IN :lstProdName 
                                                  AND SBQQ__Quote__c IN :lstQuoteID  
                                                  ORDER BY SBQQ__ProductCode__c DESC, SBQQ__Quote__r.Valid_From__c DESC];
        System.debug('lstQuoteLines- ' + lstQuoteLines.size());
        
        for (SBQQ__QuoteLine__c ql : lstQuoteLines) {
            Integer currentCount = productCodeCountMap.get(ql.SBQQ__ProductCode__c);
            System.debug('Current Count: ' + currentCount);
            if (currentCount == null || currentCount < 3) {
                existingQuoteLines.add(ql);
                productCodeCountMap.put(ql.SBQQ__ProductCode__c, (currentCount == null ? 1 : currentCount + 1));
                System.debug('Added Quote Line: ' + ql.Id + ' for Product Code: ' + ql.SBQQ__ProductCode__c 
                             + ' (Total added for this product code: ' + productCodeCountMap.get(ql.SBQQ__ProductCode__c) + ')');
            } else {
                System.debug('Skipped Quote Line: ' + ql.Id + ' as 3 lines already added for Product Code: ' + ql.SBQQ__ProductCode__c);
            }
        }
        
        System.debug('Final existingQuoteLines count: ' + existingQuoteLines.size());
        return existingQuoteLines;
    }
}