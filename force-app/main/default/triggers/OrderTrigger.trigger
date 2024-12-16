trigger OrderTrigger on Order (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	//if msd id is null
	TriggerExecutionHandler.execute(new OrderTriggerExecutor());
}