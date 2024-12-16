trigger ContactTrigger on Contact (before insert,after insert) {
	//add profile__c not null
	if(TriggerConfiguration.shouldRunTrigger()){  
    	TriggerExecutionHandler.execute(new ContactTriggerExecutor());
    }
}