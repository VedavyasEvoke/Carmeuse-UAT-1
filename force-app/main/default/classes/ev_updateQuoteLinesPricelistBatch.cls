global class ev_updateQuoteLinesPricelistBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, CurrencyIsoCode, Amount__c, CnTy__c, Material_Name__c, Material__c, ' +
            'PL__c, Plnt__c, Unit__c, UoM__c, Valid_From__c, Valid_To__c, per__c, Sales_Org__c ' +
            'FROM Price_List__c WHERE CreatedDate = LAST_N_DAYS:30 ORDER BY CreatedDate DESC';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Price_List__c> priceListRecords) {
        Map<String, Price_List__c> priceListMap = new Map<String, Price_List__c>();
        
        
        for (Price_List__c priceList : priceListRecords) {
            String key = priceList.CnTy__c + priceList.PL__c + priceList.Plnt__c + priceList.Material__c + priceList.Sales_Org__c;
            if (!priceListMap.containsKey(key)) {
                priceListMap.put(key, priceList);
            }
        }

        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
  

        List<SBQQ__QuoteLine__c> quoteLines = [
            SELECT Id, SBQQ__Quote__r.Valid_From__c, SBQQ__Quote__r.Valid_To__c, 
                   SBQQ__Product__r.ProductCode, SBQQ__Quote__r.Sold_to__r.Price_List__c, 
                   SBQQ__Quote__r.Sold_to__r.Sales_Organization__c, Plant__c, ZCO2__c, ZCPR__c
            FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__r.Sold_to__r.Price_List__c != null 
                  AND SBQQ__Quote__c = : 'a17QJ000026kpO4YAI'
        ];

        for (SBQQ__QuoteLine__c quoteLine : quoteLines) {
            
     String co2Key = 'ZCO2' + quoteLine.SBQQ__Quote__r.Sold_to__r.Price_List__c + quoteLine.Plant__c + quoteLine.SBQQ__Product__r.ProductCode + quoteLine.SBQQ__Quote__r.Sold_to__r.Sales_Organization__c;
     String ZsftKey = 'ZSFT' + quoteLine.SBQQ__Quote__r.Sold_to__r.Price_List__c + quoteLine.Plant__c + quoteLine.SBQQ__Product__r.ProductCode + quoteLine.SBQQ__Quote__r.Sold_to__r.Sales_Organization__c;
     String ZCPRKey = 'ZCPR' + quoteLine.SBQQ__Quote__r.Sold_to__r.Price_List__c + quoteLine.Plant__c + quoteLine.SBQQ__Product__r.ProductCode + quoteLine.SBQQ__Quote__r.Sold_to__r.Sales_Organization__c;
     
            Price_List__c pCo2 = priceListMap.get(co2Key);
            Price_List__c pzsft = priceListMap.get(ZsftKey);
            Price_List__c pzcpr = priceListMap.get(ZCPRKey);

            if (pCo2 != null && (
                (quoteLine.SBQQ__Quote__r.Valid_From__c <= pCo2.Valid_From__c && quoteLine.SBQQ__Quote__r.Valid_To__c >= pCo2.Valid_To__c) ||
                (quoteLine.SBQQ__Quote__r.Valid_From__c >= pCo2.Valid_From__c && quoteLine.SBQQ__Quote__r.Valid_From__c <= pCo2.Valid_To__c) ||
                (quoteLine.SBQQ__Quote__r.Valid_To__c >= pCo2.Valid_From__c && quoteLine.SBQQ__Quote__r.Valid_To__c <= pCo2.Valid_To__c)
            )) {
                if (quoteLine.ZCO2__c != pCo2.Amount__c) {
                    quoteLine.ZCO2__c = pCo2.Amount__c;
                    quoteLinesToUpdate.add(quoteLine);
                   
                }
            }
             if (pzsft != null && (
                (quoteLine.SBQQ__Quote__r.Valid_From__c <= pzsft.Valid_From__c && quoteLine.SBQQ__Quote__r.Valid_To__c >= pzsft.Valid_To__c) ||
                (quoteLine.SBQQ__Quote__r.Valid_From__c >= pzsft.Valid_From__c && quoteLine.SBQQ__Quote__r.Valid_From__c <= pzsft.Valid_To__c) ||
                (quoteLine.SBQQ__Quote__r.Valid_To__c >= pzsft.Valid_From__c && quoteLine.SBQQ__Quote__r.Valid_To__c <= pzsft.Valid_To__c)
            )) {
                if (quoteLine.ZSFT__c != pzsft.Amount__c) {
                    quoteLine.ZSFT__c = pzsft.Amount__c;
                    quoteLinesToUpdate.add(quoteLine);
                   
                }
            }
             if (pzcpr != null && (
                (quoteLine.SBQQ__Quote__r.Valid_From__c <= pzcpr.Valid_From__c && quoteLine.SBQQ__Quote__r.Valid_To__c >= pzcpr.Valid_To__c) ||
                (quoteLine.SBQQ__Quote__r.Valid_From__c >= pzcpr.Valid_From__c && quoteLine.SBQQ__Quote__r.Valid_From__c <= pzcpr.Valid_To__c) ||
                (quoteLine.SBQQ__Quote__r.Valid_To__c >= pzcpr.Valid_From__c && quoteLine.SBQQ__Quote__r.Valid_To__c <= pzcpr.Valid_To__c)
            )) {
                if (quoteLine.ZCO2__c != pzcpr.Amount__c) {
                    quoteLine.ZCO2__c = pzcpr.Amount__c;
                    quoteLinesToUpdate.add(quoteLine);
                   
                }
            }
        }

        if (!quoteLinesToUpdate.isEmpty()) {
            Update quoteLinesToUpdate;
        } else {
            System.debug('No QuoteLines to update');
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}