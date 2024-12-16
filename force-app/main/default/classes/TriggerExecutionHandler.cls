public with sharing class TriggerExecutionHandler {
	@TestVisible
	private static TriggerExecutor_I mockExecutor;
	@TestVisible
	private static Set<Schema.SObjectType> disableSObjectTriggers = new Set<Schema.SObjectType>();

	public static void bypassTrigger(Schema.SObjectType sObjectType) {
		disableSObjectTriggers.add(sObjectType);
	}

	public static void clearBypass(Schema.SObjectType sObjectType) {
		disableSObjectTriggers.remove(sObjectType);
	}

	public static void clearAllBypasses() {
		disableSObjectTriggers.clear();
	}

	public static void execute(TriggerExecutor_I executor) {
		if (mockExecutor != null) {
			executor = mockExecutor;
		}
		if (runTrigger(executor.getSObjectType())) {
			if (Trigger.isBefore) {
				if (Trigger.isDelete) {
					executor.beforeDelete(Trigger.old);
				}
				else if (Trigger.isInsert) {
					executor.beforeInsert(Trigger.new);
				}
				else if (Trigger.isUpdate) {
					executor.beforeUpdate(Trigger.oldMap, Trigger.new);
				}
			} else if (Trigger.isAfter) {
				if (Trigger.isDelete) {
					executor.afterDelete(Trigger.old);
				}
				else if (Trigger.isInsert) {
					executor.afterInsert(Trigger.new);
				}
				else if (Trigger.isUpdate) {
					executor.afterUpdate(Trigger.oldMap, Trigger.new);
				}
			}
		}
	}

	private static Boolean runTrigger(Schema.SObjectType sObjectType) {
//		Boolean disableAllTriggers = Automation_Switch__c.getInstance().Disable_Triggers__c;
//		return !disableAllTriggers && !disableSObjectTriggers.contains(sObjectType);
		return true;
	}
}