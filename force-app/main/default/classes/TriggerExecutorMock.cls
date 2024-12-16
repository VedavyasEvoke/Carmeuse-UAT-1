@isTest
public class TriggerExecutorMock implements TriggerExecutor_I {
	public Set<String> triggersCalled;
	public String sObjectName;

	public TriggerExecutorMock() {
		triggersCalled = new Set<String>();
	}

	public Schema.SObjectType getSObjectType() {
		return Schema.getGlobalDescribe().get(sObjectName);
	}
	public void beforeInsert(List<SObject> triggerNew) {
		triggersCalled.add('beforeInsert');
	}
	public void beforeUpdate(Map<Id,SObject> triggerOldMap, List<SObject> triggerNew) {
		triggersCalled.add('beforeUpdate');
	}
	public void beforeDelete(List<SObject> triggerOld) {
		triggersCalled.add('beforeDelete');
	}
	public void afterInsert(List<SObject> triggerNew) {
		triggersCalled.add('afterInsert');
	}
	public void afterUpdate(Map<Id,SObject> triggerOldMap, List<SObject> triggerNew) {
		triggersCalled.add('afterUpdate');
	}
	public void afterDelete(List<SObject> triggerOld) {
		triggersCalled.add('afterDelete');
	}
}