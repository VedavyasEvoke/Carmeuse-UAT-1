/**
 * KilnTrigger is responsible for handling changes to Kiln_Report__c records and updating related plant fields accordingly.
 * It invokes the KilnTriggerHandler methods to perform roll-up calculations and field updates on the parent Competitor__c (Plant) records.
 * 
 * This trigger runs after insert, update, and delete events, ensuring that the related plant fields are updated whenever a kiln report changes.
 * Author : Purnachandar Padishala
 * Created Date :  8/2/2024
 */
/* MODIFICATION LOG

* Version          Developer          Date               Description

*-------------------------------------------------------------------------------------------

* 59.0             Juli Kumari      10/23/2024          Modification                                                    

*******************************************************************************************/

trigger KilnTrigger on Kiln_Report__c (after insert, after update, after delete) {
if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            KilnTriggerHandler.updatePlantFields(Trigger.new);
        }
    if (Trigger.isDelete) {
            KilnTriggerHandler.updatePlantFields(Trigger.old);
            KilnTriggerHandler.updatePlantRecordCount(Trigger.old, Trigger.oldMap);
        }
     if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            KilnTriggerHandler.updatePlantRecordCount(Trigger.new, Trigger.oldMap);
        }
    }
    }
}