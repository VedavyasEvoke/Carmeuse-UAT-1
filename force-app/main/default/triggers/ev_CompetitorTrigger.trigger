/**
 * ev_CompetitorTrigger is responsible for handling actions after the Competitor__c object 
 * records are inserted, updated, or deleted. It delegates processing to the 
 * ev_CompetitorTriggerHandler class to perform necessary field updates.
 * 
 * - After Update: Updates company-related fields using the updateCompanyFields method.
 * - After Delete: Executes methods to handle plant and company deletions.
 * 
 * This trigger ensures that whenever records in the Competitor__c object (which includes 
 * Plant and Company records) are modified or deleted, related calculations and updates 
 * are handled.
 * Author : Purnachandar Padishala
 * Created date : 6/6/2024
 */
/* MODIFICATION LOG

* Version          Developer          Date               Description

*-------------------------------------------------------------------------------------------

* 59.0             Juli Kumari      10/23/2024          Modification                                                    

*******************************************************************************************/
trigger ev_CompetitorTrigger on Competitor__c (after insert, after update,after delete) {
    
    if(trigger.isbefore && (trigger.isinsert || trigger.isupdate))
    {
       // ev_CompetitorTriggerHandler.FreeCapacityUpdate(Trigger.new); 
       
    }
    if(trigger.isAfter && trigger.isupdate)
    {  
        // execute updateCompanyFields method to update company fields
       ev_CompetitorTriggerHandler.updateCompanyFields(trigger.new, trigger.oldMap);
       
    }
    if(trigger.isAfter && trigger.isDelete){
        ev_CompetitorTriggerHandler.afterPlantDelete(trigger.old);
        ev_CompetitorTriggerHandler.afterCompanyDelete(trigger.old);
    }
     
    
}