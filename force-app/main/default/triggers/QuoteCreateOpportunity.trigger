trigger QuoteCreateOpportunity on SBQQ__Quote__c (before insert) {
        Set<Id> accountIds = new Set<Id>();
 
        for (SBQQ__Quote__c quote : Trigger.new) {
            if (quote.SBQQ__Opportunity2__c == null) {
                 if (quote.Sold_to__c != null) {
                    accountIds.add(quote.Sold_to__c);
                } else if (quote.Ship_to__c != null) {
                    accountIds.add(quote.Ship_to__c);
                }
            }
        }
 
        if (!accountIds.isEmpty()) {
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :accountIds]);
 
            for (SBQQ__Quote__c quote : Trigger.new) {
                if (quote.SBQQ__Opportunity2__c == null) {
                    // Determine which Account to use
                    Id accountIdToUse = quote.Sold_to__c != null ? quote.Sold_to__c : quote.Ship_to__c;
                    Account relatedAccount = accountMap.get(accountIdToUse);
 
                    // Create a new Opportunity
                    Opportunity newOpp = new Opportunity();
                    newOpp.AccountId = accountIdToUse;
                   newOpp.Name = relatedAccount != null ? relatedAccount.Name : 'New Opportunity';
                    newOpp.CloseDate = quote.Valid_From__c != null ? quote.Valid_From__c : Date.today();
                    newOpp.StageName = 'Qualification';  // Assign a default stage
                    //newopp.Legacy_Dummy_Quote_ID__c =quote.Legacy_Quote_Number__c;
                    insert newOpp;
                    System.debug('Inserted Opp'+newOpp.id); 
 
                    // Map the Opportunity to the Quote
                    quote.SBQQ__Opportunity2__c = newOpp.Id;
                }
            }
        }
    }