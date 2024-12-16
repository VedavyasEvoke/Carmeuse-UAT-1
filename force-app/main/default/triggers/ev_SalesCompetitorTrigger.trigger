trigger ev_SalesCompetitorTrigger on Sales_Competitor__c (after insert, after update) {
    if (Trigger.isInsert) {
        ev_SalesCompetitorTriggerHandler.handleAfterInsertOrUpdate(Trigger.new, null);
    } else if (Trigger.isUpdate) {
        ev_SalesCompetitorTriggerHandler.handleAfterInsertOrUpdate(Trigger.new, Trigger.oldMap);
    }
}