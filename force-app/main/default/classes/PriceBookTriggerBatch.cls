global class PriceBookTriggerBatch implements Database.Batchable<sObject> {
    global List<Pricebook2> pbList = new List<Pricebook2>();

    global PriceBookTriggerBatch(List<Pricebook2> pbList) {
        this.pbList = pbList;
    }

    global List<Pricebook2> start(Database.BatchableContext BC) {
        
        return pbList; 
    }
     
    global void execute(Database.BatchableContext bc, List<Pricebook2> scope) {
		List<BuyerGroupPricebook> newBuyerGroupPriceBooks = new List<BuyerGroupPricebook>();

        
        // Assign price book to buyer group.
        for(Pricebook2 priceBook : scope) {
			String pbAccountName = priceBook.Description;
			String searchText = 'BG-' + pbAccountName;
			List<BuyerGroup> accountBuyerGroup = [SELECT Id, Name
                                            FROM BuyerGroup
                                            WHERE Name LIKE :searchText
                                            LIMIT 1];

			for(BuyerGroup bg : accountBuyerGroup) {
				BuyerGroupPricebook newBuyerGroupPB = new BuyerGroupPricebook();
				newBuyerGroupPB.BuyerGroupId = bg.Id;
				newBuyerGroupPB.IsActive = true;
				newBuyerGroupPB.Pricebook2Id = priceBook.Id;

				newBuyerGroupPriceBooks.add(newBuyerGroupPB);
			}
        }

		insert newBuyerGroupPriceBooks;
    }   
     
    global void finish(Database.BatchableContext BC) {
        
    }
}