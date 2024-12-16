trigger PriceBookTrigger on Pricebook2 (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    //add pb name != Carmeuse && Carmeuse Systems
    if(TriggerConfiguration.shouldRunTrigger()){  
    	TriggerExecutionHandler.execute(new PriceBookTriggerExecutor());
    }
}