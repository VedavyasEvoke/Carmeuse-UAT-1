/***************************************************************************************************************************************************
# Class Name  = "ev_leadConversionTrigger"
# Author      = Naganjaneya Lakshman
# Description = This is the trigger for lead.

# Change Log :
============================================================================================================
Date                     Changed By                        Change Description
============================================================================================================
08/04/2024               Naganjaneya Lakshman/Sameer             Original Version
**************************************************************************************************************************************************/

trigger ev_leadConversionTrigger on Lead (after update,before insert, before update) {
    
    
    /*if (Trigger.isBefore && Trigger.isInsert ) {
        // Pass a clone of Trigger.new to avoid modifying it directly
        LeadAssignmentHandler.assignLeadToActiveAssignmentRule(Trigger.new);
        LeadAssignmentHandler.assignLeadToActiveAssignmentRule(Trigger.new);
    }*/
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        ev_copySalesCompOnLeadToOpportunity.copySalesCompOnLeadToOpportunity(Trigger.new);
        
        
    }
    
}