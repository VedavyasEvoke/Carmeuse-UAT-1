public with sharing class SBQQ_QuoteTriggerExecutor implements TriggerExecutor_I {
    public Schema.SObjectType getSObjectType() {
        return SBQQ__Quote__c.SObjectType;
    }
    public void beforeInsert(List<SBQQ__Quote__c> triggerNew) {
    }
    public void beforeUpdate(Map<Id, SObject> triggerOldMap, List<SBQQ__Quote__c> triggerNew) {
    }
    public void beforeDelete(List<SBQQ__Quote__c> triggerOld) {
    }
    public void afterInsert(List<SBQQ__Quote__c> triggerNew) { 
        
    }
    public void afterUpdate(Map<Id,SObject> triggerOldMap, List<SBQQ__Quote__c> triggerNew) {
       
    }    
    public void afterDelete(List<SBQQ__Quote__c> triggerOld) {
    }
    
   
}