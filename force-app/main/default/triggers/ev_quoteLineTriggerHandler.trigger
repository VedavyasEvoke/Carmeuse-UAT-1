/***************************************************************************************************************************************************
# Class Name  = "ev_quoteLineTriggerHandler"
# Author      = Naganjaneya Lakshman
# Description = This is the trigger for quote line object.

# Change Log :
============================================================================================================
Date                     Changed By                        Change Description
============================================================================================================
08/04/2024               Naganjaneya Lakshman              Original Version
**************************************************************************************************************************************************/

trigger ev_quoteLineTriggerHandler on SBQQ__QuoteLine__c (before insert, after delete, after update, before update) {
    if(trigger.isInsert && trigger.isBefore) {
        ev_salesCompetitorAutomation salesCom = new ev_salesCompetitorAutomation();
        salesCom.salesCompetitorAutomation(trigger.new);
    }

    /*if(trigger.isDelete && trigger.isAfter) {
        ev_salesCompetitorAutomation salesCom = new ev_salesCompetitorAutomation();
        salesCom.salesCompetitorDelete(trigger.old);
    }*/
    if (Trigger.isBefore && Trigger.isUpdate) {
        system.debug('count CreatePricingHistory');
        CreatePricingHistory.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }
}