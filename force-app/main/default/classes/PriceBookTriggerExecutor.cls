public with sharing class PriceBookTriggerExecutor implements TriggerExecutor_I {

	public Schema.SObjectType getSObjectType() {
		return Pricebook2.SObjectType;
	}

	public void beforeInsert(List<Pricebook2> triggerNew) {
	}

	public void beforeUpdate(Map<Id, SObject> triggerOldMap, List<Pricebook2> triggerNew) {
	}

	public void beforeDelete(List<Pricebook2> triggerOld) {
	}

	public void afterInsert(List<Pricebook2> triggerNew) {
		List<Pricebook2> priceBookList = new List<Pricebook2>();
        
        for(Pricebook2 priceBook : triggerNew) {
            priceBookList.add(priceBook);
        }

        if(priceBookList.size() > 0) {
            Database.executebatch(new PriceBookTriggerBatch(priceBookList));
        }
	}

	public void afterUpdate(Map<Id, SObject> triggerOldMap, List<Pricebook2> triggerNew) {
		
	}

	public void afterDelete(List<Pricebook2> triggerOld) {

	}
}