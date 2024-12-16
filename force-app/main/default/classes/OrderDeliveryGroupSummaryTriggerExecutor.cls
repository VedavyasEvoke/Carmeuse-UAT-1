public with sharing class OrderDeliveryGroupSummaryTriggerExecutor implements TriggerExecutor_I {

	public Schema.SObjectType getSObjectType() {
		return Order.SObjectType;
	}

	public void beforeInsert(List<Order> triggerNew) {
	}

	public void beforeUpdate(Map<Id, SObject> triggerOldMap, List<Order> triggerNew) {
	}

	public void beforeDelete(List<Order> triggerOld) {
	}

	public void afterInsert(List<Order> triggerNew) {
	}

	public void afterUpdate(Map<Id, SObject> triggerOldMap, List<Order> triggerNew) {
		System.debug('---- Order delivery group summaries to update ----');
	}

	public void afterDelete(List<Order> triggerOld) {
	}
}