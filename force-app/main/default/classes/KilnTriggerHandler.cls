/*/*******************************************************************************************

* @Name         KilnTriggerHandler 

* @Author       Juli Kumari

* @Date         8/2/2024
* Test Class name : KilnTriggerHandlerTest

* @Description  :  
. KilnTriggerHandler is responsible for handling roll-up calculations and field updates for 
. the Competitor__c object, particularly for plants related to Kiln_Report__c records.
. This class contains methods to update plant fields based on related Kiln_Report__c records 
. and to maintain the total number of kilns for each plant.
*******************************************************************************************/

/* MODIFICATION LOG

* Version          Developer          Date               Description

*-------------------------------------------------------------------------------------------

* 61.0             Juli Kumari      10/18/2024          Initial Creation/Modification                                                    

*******************************************************************************************/



public class KilnTriggerHandler {
    /**
* This method calculates and updates the total Nominal Capacity and Estimated Production 
* for plant records based on their associated Kiln_Report__c records.
* 
* @param kilnReports - List of Kiln_Report__c records that have been created or updated.
*                      This method extracts plant IDs from these reports and updates the corresponding plant fields.
* @Author       Juli Kumari 
*/
    
    public static void updatePlantFields(List<Kiln_Report__c> kilnReports) {
        system.debug('kiln Report   '+kilnReports );
        // Collect the parent plant IDs from the kiln reports
        Set<Id> plantIds = new Set<Id>();
        List<Competitor__c> plantsToUpdate = new List<Competitor__c>();
        for (Kiln_Report__c kilnReport : kilnReports) {
            if (kilnReport.Plant__c != null && (kilnReport.Cap_t_y__c != null || kilnReport.Est_Prod_t_y__c !=null)) {
                plantIds.add(kilnReport.Plant__c);
            }
        }
        system.debug('palnt id  '+plantIds);
        if (plantIds.isEmpty()) {
            return;
        }
        
        // Query the related kiln reports and their parent plants
        List<Competitor__c> plants = [SELECT Id, RecordType.Name,
                                      (SELECT Cap_t_y__c,Nbr__c, 
                                       Est_Prod_t_y__c 
                                       FROM Kiln_Report__r 
                                       WHERE Active__c = TRUE)
                                      FROM Competitor__c 
                                      WHERE Id IN :plantIds AND RecordType.Name ='Plant' FOR UPDATE];
        
        
        system.debug('palnt records  '+plants);
        // Calculate the rollup values
        for (Competitor__c plant : plants) {
            Decimal totalNominalCapacity = 0;
            Decimal totalEstimatedProduction = 0;
            Decimal totalKilns = 0;
            system.debug('palnt records  '+plant.Kiln_Report__r);
            for (Kiln_Report__c kiln : plant.Kiln_Report__r) {
                totalNominalCapacity += kiln.Cap_t_y__c != null ? kiln.Cap_t_y__c : 0;
                totalEstimatedProduction += kiln.Est_Prod_t_y__c != null ? kiln.Est_Prod_t_y__c : 0;
                //totalKilns += kiln.Nbr__c != null ? kiln.Nbr__c : 0;
                system.debug('totalNominalCapacity  '+totalNominalCapacity);
                system.debug('totalEstimatedProduction  '+totalEstimatedProduction);
            }
            
            plant.Nominal_Capacity_t_y__c = totalNominalCapacity;
            plant.Estimated_Production_t_y__c = totalEstimatedProduction;
            //plant.Total_No_Kilns__c = totalKilns;
            plantsToUpdate.add(plant);
        }
        system.debug('plants to update  '+plantsToUpdate);
        // Update the plants with the new rollup values
        if (!plantsToUpdate.isEmpty()) {
            try {
                update plantsToUpdate;
            } catch (DmlException e) {
                if (e.getMessage().contains('UNABLE_TO_LOCK_ROW')) {
                    // Implement a retry mechanism with a short delay (e.g., 100ms) here
                    // Or handle the error appropriately based on your business logic
                }
                System.debug('Error updating plants: ' + e.getMessage());
            }
        }
    }
    
    /**
* This method updates the total number of kilns for plant records based on their associated
* Kiln_Report__c child records. It collects parent plant IDs from both new and old records 
* (for insert, update, and delete scenarios) and recalculates the kiln count.
* 
* @param newRecords - List of new or updated Kiln_Report__c records.
* @param oldRecordsMap - Map of old Kiln_Report__c records (for delete scenario) to update 
*                        the kiln count accordingly.
* @Author       Juli Kumari 
*/
    
    public static void updatePlantRecordCount(List<Kiln_Report__c> newRecords, Map<Id, Kiln_Report__c> oldRecordsMap) {
        Set<Id> parentIds = new Set<Id>();
        List<Competitor__c> recordsToUpdate = new List<Competitor__c>();
        
        // Collect parent IDs from new records
        for (Kiln_Report__c record : newRecords) {
            if (record.Plant__c != null) {
                parentIds.add(record.Plant__c);
            }
        }
        
        // Collect parent IDs from old records (for delete scenario)
        if (oldRecordsMap != null) {
            for (Kiln_Report__c oldRecord : oldRecordsMap.values()) {
                if (oldRecord.Plant__c != null) {
                    parentIds.add(oldRecord.Plant__c);
                }
            }
        }
        
        if (!parentIds.isEmpty()) {
            // Query parent records to get their current child record count
            List<Competitor__c> parentRecords = [SELECT Id,Total_No_Kilns__c, 
                                                 (SELECT Id,Active__c,Nbr__c FROM Kiln_Report__r 
                                                  WHERE Active__c = True AND Nbr__c !=null) 
                                                 FROM Competitor__c WHERE Id IN :parentIds FOR UPDATE];
            
            // Update the child record count for each parent
            for (Competitor__c parent : parentRecords) {
                // Initialize the count of kilns
                Decimal totalKilns = 0;
                
                // Check if there are any Kiln_Report__c records
                if (!parent.Kiln_Report__r.isEmpty()) {
                    for (Kiln_Report__c kilnReport : parent.Kiln_Report__r) {
                        // Sum up the Nbr__c values from each active Kiln_Report__c
                        totalKilns += kilnReport.Nbr__c != null ? kilnReport.Nbr__c : 0;
                    }
                }
                parent.Total_No_Kilns__c = totalKilns;
                recordsToUpdate.add(parent);
                System.debug('Total number of Kilns: ' + parent.Total_No_Kilns__c);
            }
            
            
            system.debug('parentRecords  ' +parentRecords);
            // Perform DML operation to save the updated parent records
            if (!recordsToUpdate.isEmpty()) {
                try {
                    update recordsToUpdate;
                } catch (DmlException e) {
                    System.debug('Error updating parent records: ' + e.getMessage());
                }
            }
        }
    }
    
}