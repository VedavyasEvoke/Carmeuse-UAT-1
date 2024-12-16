trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    //pass boelan B2B Customer here
    if(TriggerConfiguration.shouldRunTrigger()){  
    	TriggerExecutionHandler.execute(new AccountTriggerExecutor());
    }
}