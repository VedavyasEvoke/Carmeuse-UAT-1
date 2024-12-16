trigger Products_By_PlantTrigger on Products_By_Plant__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(TriggerConfiguration.shouldRunTrigger()){
        TriggerExecutionHandler.execute(new Products_By_PlantTriggerExecutor());
    }
}