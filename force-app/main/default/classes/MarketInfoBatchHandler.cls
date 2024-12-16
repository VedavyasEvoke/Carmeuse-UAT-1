/**
 * @Name         MarketInfoBatchHandler 

* @Author       Juli Kumari

* @Date          11/13/2024
* Test Class name : MarketInfoBatchHandlerTest

 * The MarketInfoBatchHandler class implements the Database.Batchable interface
 * to process and update Market_Info__c and Competitor__c records in batches.
 *
 * This batch job aggregates tonnage values from Market_Info__c records
 * for each Competitor__c record of type "Plant" and updates the roll-up field
 * Market_Info_identified__c on those records.
 *
 * Key Features:
 * - Filters and processes Market_Info__c records with non-null Competitor_Plant_Id__c and Tonnage__c.
 * - Aggregates and rolls up data for the previous year based on specific criteria.
 * - Updates Competitor__c records with the calculated roll-up values.
 */
global class MarketInfoBatchHandler implements Database.Batchable<SObject> {

    /**
     * The start method collects Market_Info__c records to be processed.
     *
     * @param bc The batch context instance.
     * @return A QueryLocator containing Market_Info__c records with populated
     *         Competitor_Plant_Id__c and Tonnage__c fields.
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query the Market_Info__c records that have both Competitor_Plant_Id__c and Tonnage__c populated
        String previousYear = String.valueOf(Date.today().year() - 1);
        return Database.getQueryLocator([
            SELECT Id, Competitor_Plant_Id__c, Tonnage__c, Competitor__c
            FROM Market_Info__c
            WHERE Competitor_Plant_Id__c != null AND Tonnage__c != null AND Year__c =:previousYear AND  ProductHierarchyLevel1__c = '130'
        ]);
    }

    /**
     * The execute method processes each batch of Market_Info__c records and performs roll-up calculations.
     *
     * @param bc The batch context instance.
     * @param marketInfoList The list of Market_Info__c records in the current batch.
     */
    global void execute(Database.BatchableContext bc, List<Market_Info__c> marketInfoList) {
        system.debug('marketInfoList  ' + marketInfoList);

        // Collect the parent plant IDs from the Market_Info__c records
        //String previousYear = String.valueOf(Date.today().year() - 1);
        //system.debug('previousYear   ' + previousYear);
        Set<Id> plantIds = new Set<Id>();
        List<Competitor__c> plantsToUpdate = new List<Competitor__c>();

        for (Market_Info__c marketInfo : marketInfoList) {
            if (marketInfo.Competitor_Plant_Id__c != null) {
                plantIds.add(marketInfo.Competitor_Plant_Id__c);
                system.debug('plantIds   ' + plantIds);
            }
        }

        // Query the related Competitor__c records and their Market_Info__r related records
        List<Competitor__c> plants = [
            SELECT Id, RecordType.Name,
                   (SELECT Tonnage__c, ProductHierarchyLevel1__c, Year__c
                    FROM Market_Info__r 
                    WHERE ProductHierarchyLevel1__c = '130' AND Year__c = :String.valueOf(Date.today().year() - 1))
            FROM Competitor__c 
            WHERE Id IN :plantIds AND RecordType.Name = 'Plant'
        ];
        system.debug('plants  ' + plants);

        // Calculate the rollup values
        for (Competitor__c plant : plants) {
            Decimal totalTonnage = 0;

            for (Market_Info__c marketInfo : plant.Market_Info__r) {
                totalTonnage += marketInfo.Tonnage__c != null ? marketInfo.Tonnage__c : 0;
            }

            plant.Market_Info_identified__c = totalTonnage;
            plantsToUpdate.add(plant);
            system.debug('plantsToUpdate   ' + plantsToUpdate);
        }
        system.debug('plantsToUpdate size  ' + plantsToUpdate.size());

        // Update the plants with the new rollup values
        if (!plantsToUpdate.isEmpty()) {
            try {
                update plantsToUpdate;
            } catch (DmlException e) {
                System.debug('Error updating plants: ' + e.getMessage());
            }
        }
    }

    /**
     * The finish method is called after all batches are processed.
     *
     * @param bc The batch context instance.
     */
    global void finish(Database.BatchableContext bc) {
        System.debug('Batch processing of MarketInfoBatchHandler finished.');
    }
}