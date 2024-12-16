/***************************************************************************************************************************************************
# Class Name  = "ev_copySalesCompOnLeadToOpportunity"
# Author      = Naganjaneya Lakshman
# Description = This class is copy sales competitor record under lead to opportunity sales competitor record 
				when lead is converted.
# Change Log :
============================================================================================================
Date                     Changed By                        Change Description
============================================================================================================
07/06/2024                Naganjaneya Lakshman/Sameer             Original Version
**************************************************************************************************************************************************/

public class ev_copySalesCompOnLeadToOpportunity {

    public static void copySalesCompOnLeadToOpportunity(List<Lead> leads) {
        // Map to hold Lead Id to Opportunity Id
        Map<Id, Id> leadToOppMap = new Map<Id, Id>();
        
        for (Lead lead : leads) {
            // Check if the lead has been converted
            if (lead.IsConverted) {
                leadToOppMap.put(lead.Id, lead.ConvertedOpportunityId);
            }
        }
        
        if (!leadToOppMap.isEmpty()) {
            // Query Sales Competitor records related to the leads
            List<Sales_Competitor__c> salesCompetitors = [SELECT Id, Lead__c,Opportunity__c
                                                          //,Field1__c, Field2__c 
                                                          FROM Sales_Competitor__c 
                                                          WHERE Lead__c IN :leadToOppMap.keySet()];
            
            if (!salesCompetitors.isEmpty()) {
            for (Sales_Competitor__c sc : salesCompetitors) {
                sc.Opportunity__c = leadToOppMap.get(sc.Lead__c);
            }
            
            
                //Update Sales Competitor record with converted opportunity
                update salesCompetitors;
            }
        }
    }
}