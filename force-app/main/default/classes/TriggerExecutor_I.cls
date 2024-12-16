public interface TriggerExecutor_I {
	Schema.SObjectType getSObjectType();
	void beforeInsert(List<SObject> triggerNew);
	void beforeUpdate(Map<Id,SObject> triggerOldMap, List<SObject> triggerNew);
	void beforeDelete(List<SObject> triggerOld);
	void afterInsert(List<SObject> triggerNew);
	void afterUpdate(Map<Id,SObject> triggerOldMap, List<SObject> triggerNew);
	void afterDelete(List<SObject> triggerOld);
}