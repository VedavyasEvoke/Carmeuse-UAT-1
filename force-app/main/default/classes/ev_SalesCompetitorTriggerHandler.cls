public class ev_SalesCompetitorTriggerHandler {
    public static void handleAfterInsertOrUpdate(List<Sales_Competitor__c> newCompetitors, Map<Id, Sales_Competitor__c> oldCompetitorsMap) {
        Set<Id> opportunityIds = new Set<Id>();
        
        // Collect Opportunity IDs from the trigger records
        for (Sales_Competitor__c competitor : newCompetitors) {
             System.debug('Lst Competitors'+newCompetitors.size());
            Boolean hasFieldChanged = false;
            
            // Check if this is an update operation
            if (oldCompetitorsMap != null) {
                Sales_Competitor__c oldCompetitor = oldCompetitorsMap.get(competitor.Id);
                if (oldCompetitor != null) {
                    System.debug('Lst Competitors'+newCompetitors.size());
                    hasFieldChanged = competitor.Plant__c != oldCompetitor.Plant__c ||
                        competitor.Competitor__c != oldCompetitor.Competitor__c ||
                        competitor.Product__c != oldCompetitor.Product__c;
                    System.debug('Flag Check '+hasFieldChanged);
                }
            }
            
            
            if (competitor.Opportunity__c != null && (oldCompetitorsMap == null || hasFieldChanged)) {
                opportunityIds.add(competitor.Opportunity__c);
            }
            System.debug('Oppty Id'+opportunityIds.size());
        }
        
        if (!opportunityIds.isEmpty()) {
            // get Opportunity and related Account 
            Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(
                [SELECT Id, AccountId,Business_Unit__c, Account.ParentId,Account.Account_Group__c ,Account.Parent.Account_Group__c,
                 Account.Customer_Region__c  FROM Opportunity WHERE Id IN :opportunityIds ]
            );
            
            // Collect Account IDs for the related Opportunities
            Set<Id> accountIds = new Set<Id>();
            for (Opportunity opp : opportunityMap.values()) {
                if (opp.AccountId != null && opp.Business_Unit__c == 'Carmeuse' &&
                    (opp.Account.Customer_region__c == 'Western Europe' ||
                     opp.Account.Customer_region__c == 'Eastern Europe' ||
                     opp.Account.Customer_region__c == 'Central Europe'||
                    opp.Account.Customer_region__c == 'Turkey')) {
                         accountIds.add(opp.AccountId);
                     }
            }
            System.debug('Accounts IDs'+accountIds);
            Integer currentYear = Date.today().year();
            String yearString = String.valueOf(currentYear);
            if (!accountIds.isEmpty()) {
                // get existing Market Info records for the Accounts
                Map<Id, List<Market_Info__c>> marketInfoMap = new Map<Id, List<Market_Info__c>>();
                for (Market_Info__c marketInfo : [
                    SELECT Id, SoldTo__c, Competitor_Product__c, Competitor__c, Competitor_Plant_Id__c,Tonnage__c,Year__c
                    FROM Market_Info__c
                    WHERE SoldTo__c IN :accountIds
                ]) {
                    if (!marketInfoMap.containsKey(marketInfo.SoldTo__c)) {
                        marketInfoMap.put(marketInfo.SoldTo__c, new List<Market_Info__c>());
                    }
                    marketInfoMap.get(marketInfo.SoldTo__c).add(marketInfo);
                }
                
                List<Market_Info__c> marketInfoRecordsToCreate = new List<Market_Info__c>();
                
                
                for (Sales_Competitor__c competitor : newCompetitors) {
                    if (competitor.Opportunity__c != null) {
                        Opportunity opp = opportunityMap.get(competitor.Opportunity__c);
                        if (opp != null && opp.AccountId != null) {
                            Boolean shouldCreateNewRecord = true;
                            
                            // Check if there is an existing Market Info record that matches the criteria
                            if (marketInfoMap.containsKey(opp.AccountId)) {
                                for (Market_Info__c existingMarketInfo : marketInfoMap.get(opp.AccountId)) {
                                    if (existingMarketInfo.Competitor_Product__c == competitor.Product__c &&
                                        existingMarketInfo.Competitor__c == competitor.Competitor__c &&
                                        existingMarketInfo.Competitor_Plant_Id__c == competitor.Plant__c &&
                                        existingMarketInfo.Year__c ==yearString) {
                                           
                                            Sales_Competitor__c sc =new Sales_Competitor__c();
                                             
                                            
                                            shouldCreateNewRecord = false; 
                                            
                                            break;
                                        }
                                }
                            }
                            
                            // Create a new Market Info record if no matching record exists
                            if (shouldCreateNewRecord) {
                                Market_Info__c newMarketInfo = new Market_Info__c(
                                     Name = competitor.Product_2__c + ' - ' + currentYear,
                                    //Competitor_Product__c = competitor.Product__c,
                                    Competitor__c = competitor.Competitor__c,
                                    Competitor_Plant_Id__c = competitor.Plant__c,
                                    UOM__c = competitor.UOM__c,
                                    Market__c =competitor.Market__c,
                                    SubMarket__c=competitor.Sub_Market__c,
                                    Tonnage__c =competitor.Tons__c,
                                    year__c =yearString
                                    
                                    
                                );
                                if (opp.Account.Account_Group__c == '1') {
                                    newMarketInfo.SoldTo__c = opp.AccountId;
                                    newMarketInfo.CustomerProspect__c = opp.AccountId;
                                } else if (opp.Account.Account_Group__c == '2') {
                                    newMarketInfo.CustomerProspect__c = opp.AccountId;
                                    if (opp.Account.Parent.Account_Group__c == '1') {
                                        newMarketInfo.SoldTo__c = opp.Account.ParentId;
                                        
                                    }
                                } else if(opp.Account.Account_Group__c ==null ){
                                    newMarketInfo.CustomerProspect__c=opp.AccountId;
                                }
                                else if(opp.Account.Account_Group__c ==null && opp.Account.Parent.Account_Group__c =='1'){
                                    newMarketInfo.SoldTo__c=opp.AccountId;
                                }
                                marketInfoRecordsToCreate.add(newMarketInfo);
                            }
                        }
                    }
                }
                
                // Insert MarketInfo records
                if (!marketInfoRecordsToCreate.isEmpty()) {
                    try {
                        insert marketInfoRecordsToCreate;
                        System.debug('Created Marketinforecs'+marketInfoRecordsToCreate);
                    } catch (DmlException e) {
                        System.debug('Error inserting Market Info records: ' + e.getMessage());
                    }
                }
            }
        }
    }

}