trigger Contract_Review_FormTrigger on Contract_Review_Form__c (before insert, after insert, before update, after update, before delete, after undelete) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            Contract_Review_FormTriggerHandler.afterInsert(Trigger.new);
        }
        if(Trigger.isUpdate) {
            Contract_Review_FormTriggerHandler.afterUpdate(Trigger.new);
        }
    }
}