/***************************************************************************************************************************************************
# Class Name  = "ev_salesCompetitorAutomation"
# Author      = Naganjaneya Lakshman
# Description = This class is for automation on sales competitor based on quote line product exists as a 
                market info record under Ship To Account.

# Change Log :
============================================================================================================
Date                     Changed By                        Change Description
============================================================================================================
08/04/2024                Naganjaneya Lakshman              Original Version
**************************************************************************************************************************************************/
public with sharing class ev_salesCompetitorAutomation {

    public void salesCompetitorAutomation(List<SBQQ__QuoteLine__c> qlList) {
        // Collect the necessary IDs from the quote lines
        Set<Id> qid = new Set<Id>();
        Set<Id> qlproductid = new Set<Id>();
    
        for (SBQQ__QuoteLine__c quoteLine : qlList) {            
            qid.add(quoteLine.SBQQ__Quote__c);
            qlproductid.add(quoteLine.SBQQ__Product__c);
        }
    
        // Query for the quotes
        List<SBQQ__Quote__c> quoteRecords = [SELECT Id, SBQQ__Opportunity2__c, Ship_to__c FROM SBQQ__Quote__c WHERE Id IN :qid];
        
        // Create maps to store quote-related information
        Map<Id, Id> qidoppid = new Map<Id, Id>();
       Set<Id> shiptoid = new Set<Id>();
        
        Set<Id> oppid = new Set<Id>();
    
        for (SBQQ__Quote__c quote : quoteRecords) {
            qidoppid.put(quote.Id, quote.SBQQ__Opportunity2__c);
            shiptoid.add(quote.Ship_to__c);
            oppid.add(quote.SBQQ__Opportunity2__c);
            system.debug('shiptoid==='+shiptoid);
        }
    
        // Query for the existing Sales_Competitor__c records
        List<Sales_Competitor__c> salesCompetitorsRecords = [
            SELECT Id, Name, Plant__c, Competitor__c, Product__c, Opportunity__c
            FROM Sales_Competitor__c
            WHERE Product__c IN :qlproductid AND Opportunity__c IN :oppid
        ];
    
        // Create a set of existing product-opportunity pairs to avoid duplicates
        Set<String> existingProductOpportunityPairs = new Set<String>();
        for (Sales_Competitor__c sc : salesCompetitorsRecords) {
            existingProductOpportunityPairs.add(sc.Product__c + '-' + sc.Opportunity__c);
        }
    
        // Query for the Market_Info__c records
        List<Market_Info__c> marketInfoRecords = new List<Market_Info__c>();
        if(!shiptoid.isEmpty()){
            system.debug('shiptoid'+ shiptoid);
        marketInfoRecords = [
            SELECT Id, Competitor_Plant_Id__c, Competitor__c, Competitor_Product__c, Competitor__r.Name,
            ProductPrice__c, FreightPrice__c, CO2Price__c, CurrencyIsoCode, Tonnage__c
            FROM Market_Info__c
            WHERE Customerprospect__c IN :shiptoid AND Competitor_Product__c IN :qlproductid
        ]; 
            system.debug('marketInfoRecords==='+marketInfoRecords);
        }
    
        // Map Market_Info__c records by Competitor_Product__c
        Map<Id, List<Market_Info__c>> marketInfoMap = new Map<Id, List<Market_Info__c>>();
        for (Market_Info__c info : marketInfoRecords) {
            if (!marketInfoMap.containsKey(info.Competitor_Product__c)) {
                marketInfoMap.put(info.Competitor_Product__c, new List<Market_Info__c>());
            }
            marketInfoMap.get(info.Competitor_Product__c).add(info);
        }
    
        // Create Sales_Competitor__c records if SBQQ__QuoteLine__c's SBQQ__Product__c matches Competitor_Product__c
        List<Sales_Competitor__c> salesCompetitorsToInsert = new List<Sales_Competitor__c>();
    
        for (SBQQ__QuoteLine__c lineItem : qlList) {
            Id productId = lineItem.SBQQ__Product__c;
            Id opportunityId = qidoppid.get(lineItem.SBQQ__Quote__c);
            
            if (opportunityId != null && marketInfoMap.containsKey(productId)) {
                String productOpportunityKey = productId + '-' + opportunityId;
                
                if (!existingProductOpportunityPairs.contains(productOpportunityKey)) {
                    for (Market_Info__c marketInfo : marketInfoMap.get(productId)) {
                        Sales_Competitor__c salesComp = new Sales_Competitor__c();
                        salesComp.Plant__c = marketInfo.Competitor_Plant_Id__c;
                        salesComp.Competitor__c = marketInfo.Competitor__c;
                        salesComp.Product__c = marketInfo.Competitor_Product__c;
                        salesComp.Opportunity__c = opportunityId;
                        salesComp.Tons__c = marketInfo.Tonnage__c;
                        //Pricing Fields
                        salesComp.FOB__c = marketInfo.ProductPrice__c;
                        salesComp.Freight_Unit_Price__c = marketInfo.FreightPrice__c;
                        salesComp.CO2Cost__c = marketInfo.CO2Price__c;
                        salesComp.CurrencyIsoCode = marketInfo.CurrencyIsoCode;
                        //salesComp.FuelSurcharge__c = marketInfo.;
                        //salesComp.FeesUnitPrice__c = marketInfo.;
                        //salesComp.OtherCosts__c = marketInfo.;
                        //salesComp.DiscountUnitPrice__c = marketInfo.;
                        //salesComp.CommisionUnitPrice__c = marketInfo.;
    
                        salesCompetitorsToInsert.add(salesComp);
                    }
                }
            }
        }
    
        // Insert Sales_Competitor__c records
        if (!salesCompetitorsToInsert.isEmpty()) {
            //insert salesCompetitorsToInsert;
        }
    }

    //Delete logic of SalesCompetitor records
    public void salesCompetitorDelete(List<SBQQ__QuoteLine__c> qlDeleteList) {

        Set<Id> productIdsToDelete = new Set<Id>();
        Set<Id> quoteIdsToUpdate = new Set<Id>();
        list<id> oppIdsToUpdate =  new list<id>();

        for (SBQQ__QuoteLine__c deletedQuoteLine : qlDeleteList) {
            if (deletedQuoteLine.SBQQ__Product__c != null) {
                productIdsToDelete.add(deletedQuoteLine.SBQQ__Product__c);
                quoteIdsToUpdate.add(deletedQuoteLine.SBQQ__Quote__c);
            }
        }

        list<SBQQ__Quote__c> quoteRecords = [select id, SBQQ__Opportunity2__c, Ship_to__c from SBQQ__Quote__c where id IN :quoteIdsToUpdate];

        for(SBQQ__Quote__c q:quoteRecords){
            oppIdsToUpdate.add(q.SBQQ__Opportunity2__c);
        }

        // Query for other Quote Line records with the same Product
        Map<Id, List<SBQQ__QuoteLine__c>> quoteLineItemsByProduct = new Map<Id, List<SBQQ__QuoteLine__c>>();
        for (SBQQ__QuoteLine__c qli : [SELECT Id, SBQQ__Product__c, SBQQ__Quote__r.SBQQ__Opportunity2__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.SBQQ__Opportunity2__c IN :oppIdsToUpdate AND SBQQ__Product__c IN :productIdsToDelete]) {
            if (!quoteLineItemsByProduct.containsKey(qli.SBQQ__Product__c)) {
                quoteLineItemsByProduct.put(qli.SBQQ__Product__c, new List<SBQQ__QuoteLine__c>());
            }
            quoteLineItemsByProduct.get(qli.SBQQ__Product__c).add(qli);
            system.debug('quoteLineItemsByProduct=>' + quoteLineItemsByProduct);
        }


        List<Sales_Competitor__c> competitorsToDelete = new List<Sales_Competitor__c>();

        for (Id productId : productIdsToDelete) {
            if (!quoteLineItemsByProduct.containsKey(productId)) {
                // If no other Quote Line records exist with the same Product, add Sales Competitor record to delete list
                competitorsToDelete.addAll([SELECT Id FROM Sales_Competitor__c WHERE Product__c = :productId]);
                system.debug('competitorsToDelete=>' + competitorsToDelete);
            }
        }

    // Delete Sales Competitor records
   // delete competitorsToDelete;
    
    }

}