public class CreatePricingHistory { 
    
    public static void handleAfterUpdate(Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap,
                                         Map<Id, SBQQ__QuoteLine__c> newQuoteLineMap) {
        
        Set<Id> quoteIds = new Set<Id>();
        List<Pricing_Condition_History__c> historyRecordsListCreate = new List<Pricing_Condition_History__c>();
        
        system.debug('oldmap values  ' +oldQuoteLineMap.values());
        system.debug('oldmap Ids  ' +oldQuoteLineMap.keySet());
        system.debug('newQuoteLineMap values  ' +oldQuoteLineMap.values());
        system.debug('newQuoteLineMap id  ' +oldQuoteLineMap.keySet());
        
        for(SBQQ__QuoteLine__c quoteLine : newQuoteLineMap.values()){
            if(quoteLine.SBQQ__Quote__c != null){
                quoteIds.add(quoteLine.SBQQ__Quote__c);
                system.debug('quote Ids  '+quoteIds);
            }
        }
        
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>(
            [SELECT Id, SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id IN :quoteIds]);
        system.debug('quoteMap   '+quoteMap.values());
        
        for (Id qliId : newQuoteLineMap.keySet()) {
            system.debug('newQuoteLineMap.keySet()  '+newQuoteLineMap.keySet());
            SBQQ__QuoteLine__c oldQuoteLine = oldQuoteLineMap.get(qliId);
            SBQQ__QuoteLine__c newQuoteLine = newQuoteLineMap.get(qliId);
            SBQQ__Quote__c relatedQuote = quoteMap.get(newQuoteLine.SBQQ__Quote__c);
            
            system.debug('relatedQuote   '+relatedQuote);
            system.debug('newQuoteLineMap.keySet()  '+newQuoteLine);
            system.debug('oldQuoteLineMap.keySet()  '+oldQuoteLine);
            system.debug('newQuoteLine.SBQQ__Quote__c   '+ newQuoteLine.SBQQ__Quote__c);
            system.debug('oldQuoteLine.Commission__c   '+ oldQuoteLine.Commission__c);
            
            // Check if quote status is marked as 'Won'
            if (relatedQuote != null && relatedQuote.SBQQ__Status__c == 'Accepted') {
                system.debug('???????????????????????    ');
                system.debug('newQuoteLine.SBQQ__Quote__r.SBQQ__Status__c    '  +newQuoteLine.SBQQ__Quote__r.SBQQ__Status__c);
                
                Boolean hasChanges = false;
                Pricing_Condition_History__c history = new Pricing_Condition_History__c();
                history.Quote_Line__c = newQuoteLine.Id;
                history.Quote__c = newQuoteLine.SBQQ__Quote__c;
                
                // Compare the old and new values for the fields you want to track
                if (oldQuoteLine.ZCPR__c != newQuoteLine.ZCPR__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZMF1__c != newQuoteLine.ZMF1__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.Commission__c != newQuoteLine.Commission__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.Misc_Price__c != newQuoteLine.Misc_Price__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.PC_Discount__c != newQuoteLine.PC_Discount__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.Fees_Price__c != newQuoteLine.Fees_Price__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.SBQQ__Quantity__c != newQuoteLine.SBQQ__Quantity__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.Freight_Price__c != newQuoteLine.Freight_Price__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.Surcharge__c != newQuoteLine.Surcharge__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.Plant__c != newQuoteLine.Plant__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.Default_UOM__c != newQuoteLine.Default_UOM__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.Brand_Text__c != newQuoteLine.Brand_Text__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.Custom_Text__c != newQuoteLine.Custom_Text__c) {
                    hasChanges = true;
                }
                
                if (oldQuoteLine.ZSRT__c != newQuoteLine.ZSRT__c) {
                    hasChanges = true;
                }
                
                if (oldQuoteLine.Output_Text__c != newQuoteLine.Output_Text__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.SE_Shipping_Type__c != newQuoteLine.SE_Shipping_Type__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.Estimated_Qty_Delivery__c != newQuoteLine.Estimated_Qty_Delivery__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.Primary__c != newQuoteLine.Primary__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZCO2__c != newQuoteLine.ZCO2__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZMF7__c != newQuoteLine.ZMF7__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZF1__c != newQuoteLine.ZF1__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZF3__c != newQuoteLine.ZF3__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZF6__c != newQuoteLine.ZF6__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZF7__c != newQuoteLine.ZF7__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZLRT__c != newQuoteLine.ZLRT__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZMFS__c != newQuoteLine.ZMFS__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZRMI__c != newQuoteLine.ZRMI__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZSRM__c != newQuoteLine.ZSRM__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZSTF__c != newQuoteLine.ZSTF__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZSTT__c != newQuoteLine.ZSTT__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZVFS__c != newQuoteLine.ZVFS__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZF2__c != newQuoteLine.ZF2__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZF9__c != newQuoteLine.ZF9__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZAST__c != newQuoteLine.ZAST__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZF31__c != newQuoteLine.ZF31__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZREB__c != newQuoteLine.ZREB__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZF4__c != newQuoteLine.ZF4__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZRC__c != newQuoteLine.ZRC__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZRLC__c != newQuoteLine.ZRLC__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZSPA__c != newQuoteLine.ZSPA__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZF16__c != newQuoteLine.ZF16__c) {
                    hasChanges = true;
                }
                
                if (oldQuoteLine.ZMIS__c != newQuoteLine.ZMIS__c) {
                    hasChanges = true;
                }
                
                if (oldQuoteLine.ZSVF__c != newQuoteLine.ZSVF__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZF11__c != newQuoteLine.ZF11__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZF22__c != newQuoteLine.ZF22__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZDFR__c != newQuoteLine.ZDFR__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZAD__c != newQuoteLine.ZAD__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZADN__c != newQuoteLine.ZADN__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZDAJ__c != newQuoteLine.ZDAJ__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZDIS__c != newQuoteLine.ZDIS__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZDPR__c != newQuoteLine.ZDPR__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZPCT__c != newQuoteLine.ZPCT__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZPRO__c != newQuoteLine.ZPRO__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZPLT__c != newQuoteLine.ZPLT__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZF01__c != newQuoteLine.ZF01__c) {
                    hasChanges = true;
                }
                
                if (oldQuoteLine.ZMF2__c != newQuoteLine.ZMF2__c) {
                    hasChanges = true;
                }
               
                if (oldQuoteLine.ZCWE__c != newQuoteLine.ZCWE__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZMF6__c != newQuoteLine.ZMF6__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZCPF__c != newQuoteLine.ZCPF__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZSFF__c != newQuoteLine.ZSFF__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZF5__c != newQuoteLine.ZF5__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZCO3__c != newQuoteLine.ZCO3__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZDIP__c != newQuoteLine.ZDIP__c) {
                    hasChanges = true;
                }
                if (oldQuoteLine.ZECO__c != newQuoteLine.ZECO__c) {
                    hasChanges = true;
                }  
                
                if (oldQuoteLine.Product_Price__c != newQuoteLine.Product_Price__c) {
                    hasChanges = true;
                }  
                if (oldQuoteLine.MIN_LOAD_SIZE__c != newQuoteLine.MIN_LOAD_SIZE__c) {
                    hasChanges = true;
                } 
                if(oldQuoteLine.Total_Price__c != newQuoteLine.Total_Price__c){
                     hasChanges = true;
                }
                if(oldQuoteLine.List_Unit_Price__c != newQuoteLine.List_Unit_Price__c){
                     hasChanges = true;
                }
                // Add history record to the list only if any field has changed
                     history.ZCPR__c = oldQuoteLine.ZCPR__c;
                     history.ZMF1__c = oldQuoteLine.ZMF1__c;
                     history.Commission__c = oldQuoteLine.Commission__c;
                     history.Misc_Price__c = oldQuoteLine.Misc_Price__c;
                     history.PC_Discount__c = oldQuoteLine.PC_Discount__c;
                     history.Fees_Price__c = oldQuoteLine.Fees_Price__c;
                     history.List_Unit_Price__c = oldQuoteLine.List_Unit_Price__c; 
                     history.SBQQ_Quantity__c = oldQuoteLine.SBQQ__Quantity__c;
                     history.Freight_Price__c = oldQuoteLine.Freight_Price__c;
                     history.Surcharge__c = oldQuoteLine.Surcharge__c;
                     history.Plant__c = oldQuoteLine.Plant__c;
                     history.Default_UOM__c = oldQuoteLine.Default_UOM__c;
                     history.Brand_Text__c = oldQuoteLine.Brand_Text__c;
                     history.Custom_Text__c = oldQuoteLine.Custom_Text__c;
                     history.ZSRT__c = oldQuoteLine.ZSRT__c;
                     history.Output_Text__c = oldQuoteLine.Output_Text__c;
                     history.SE_Shipping_Type__c = oldQuoteLine.SE_Shipping_Type__c;
                     history.Estimated_Qty_Delivery__c = oldQuoteLine.Estimated_Qty_Delivery__c;
                     history.Primary__c = oldQuoteLine.Primary__c;
                     history.ZCO2__c = oldQuoteLine.ZCO2__c;
                     history.ZMF7__c = oldQuoteLine.ZMF7__c;
                     history.ZF1__c = oldQuoteLine.ZF1__c;
                     history.ZF3__c = oldQuoteLine.ZF3__c;
                     history.ZF6__c = oldQuoteLine.ZF6__c;
                     history.ZF7__c = oldQuoteLine.ZF7__c;
                     history.ZLRT__c = oldQuoteLine.ZLRT__c;
                     history.ZMFS__c = oldQuoteLine.ZMFS__c;             
                     history.ZRMI__c = oldQuoteLine.ZRMI__c;
                     history.ZSRM__c = oldQuoteLine.ZSRM__c;
                     history.ZSTF__c = oldQuoteLine.ZSTF__c;
                     history.ZSTT__c = oldQuoteLine.ZSTT__c;
                     history.ZVFS__c = oldQuoteLine.ZVFS__c;
                     history.ZF2__c = oldQuoteLine.ZF2__c;
                     history.ZF9__c = oldQuoteLine.ZF9__c;
                     history.ZAST__c = oldQuoteLine.ZAST__c;
                     history.ZF31__c = oldQuoteLine.ZF31__c;
                     history.ZREB__c = oldQuoteLine.ZREB__c;
                     history.ZF4__c = oldQuoteLine.ZF4__c;
                     history.ZRC__c = oldQuoteLine.ZRC__c;
                     history.ZRLC__c = oldQuoteLine.ZRLC__c;
                     history.ZSPA__c = oldQuoteLine.ZSPA__c;
                     history.ZF16__c = oldQuoteLine.ZF16__c;
                     history.ZMIS__c = oldQuoteLine.ZMIS__c;
                     history.ZSVF__c = oldQuoteLine.ZSVF__c;
                     history.ZF11__c = oldQuoteLine.ZF11__c;
                     history.ZF22__c = oldQuoteLine.ZF22__c;
                     history.ZDFR__c = oldQuoteLine.ZDFR__c;
                     history.ZAD__c = oldQuoteLine.ZAD__c;
                     history.ZADN__c = oldQuoteLine.ZADN__c;
                     history.ZDAJ__c = oldQuoteLine.ZDAJ__c;
                     history.ZDIS__c = oldQuoteLine.ZDIS__c;
                     history.ZDPR__c = oldQuoteLine.ZDPR__c;
                     history.ZPCT__c = oldQuoteLine.ZPCT__c;
                     history.ZPRO__c = oldQuoteLine.ZPRO__c;
                     history.ZPLT__c = oldQuoteLine.ZPLT__c;
                     history.ZF01__c = oldQuoteLine.ZF01__c;
                     history.ZMF2__c = oldQuoteLine.ZMF2__c;
                     history.ZCWE__c = oldQuoteLine.ZCWE__c;
                     history.ZMF6__c = oldQuoteLine.ZMF6__c;
                     history.ZCPF__c = oldQuoteLine.ZCPF__c;
                     history.ZSFF__c = oldQuoteLine.ZSFF__c;
                     history.ZF5__c = oldQuoteLine.ZF5__c;
                     history.ZCO3__c = oldQuoteLine.ZCO3__c;
                     history.ZDIP__c = oldQuoteLine.ZDIP__c;
                     history.ZECO__c = oldQuoteLine.ZECO__c;
                     history.Product_Price__c = oldQuoteLine.Product_Price__c;
                     //history.Total_Price__c = oldQuoteLine.Total_Price__c;
                     history.MIN_LOAD_SIZE__c = oldQuoteLine.MIN_LOAD_SIZE__c;
                     history.Business_Unit__c = oldQuoteLine.Business_Unit__c;
                     
                if (hasChanges) {
                    historyRecordsListCreate.add(history);
                }
            }
        }
        system.debug('historyRecordsListCreate size   '+historyRecordsListCreate.size());
        // Insert the history records if any updates were found
        if (!historyRecordsListCreate.isEmpty()) {
            insert historyRecordsListCreate;
            system.debug('historyRecordsListCreate size   '+historyRecordsListCreate.size());
        }
    }
}