trigger EV_updating_Pricing_Approval_Type_based_on_Volumes on SBQQ__Quote__c (after update)
{
SBQQ__Quote__c rec = [Select id,name,SBQQ__Account__r.Key_Account__c,SBQQ__Status__c from SBQQ__Quote__c  where id=:trigger.new];
if (rec.SBQQ__Status__c!= trigger.oldMap.get(rec.Id).SBQQ__Status__c)
{
if(rec.SBQQ__Status__c == 'In Review' && rec.Customer_Region__c !='North America')
{
system.debug('@@@@..........13...........'+rec.SBQQ__Status__c);
EV_updating_PAT_based_on_Volumes.shareRecordID(trigger.new, trigger.oldMap,rec.SBQQ__Account__r.Key_Account__c);
}
}/*
else if(rec.SBQQ__Status__c == 'In Review')
{
system.debug('@@@@..........6...........'+rec.SBQQ__Status__c);
EV_updating_PAT_based_on_Volumes.shareRecordID(trigger.new, trigger.oldMap,rec.SBQQ__Account__r.Key_Account__c);
}
 
             
if(trigger.isbefore && trigger.isUpdate)
        {
            
        } 
        
if(TriggerConfiguration.shouldRunTrigger()){
        System.debug('inside the Trigger');
        TriggerExecutionHandler.execute(new SBQQ_QuoteTriggerExecutor());
    }*/
    
    }