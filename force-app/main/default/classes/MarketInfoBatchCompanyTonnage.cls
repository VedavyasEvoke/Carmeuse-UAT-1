/* @Name         MarketInfoBatchCompanyTonnage 

* @Author       Juli Kumari

* @Date         11/19/2024
* Test Class name : MarketInfoBatchCompanyTonnageTest

  This batch class calculates and updates the total tonnage of Market_Info__c records 
 for companies in the Competitor__c object for a specific product hierarchy and year.*/

global class MarketInfoBatchCompanyTonnage implements Database.Batchable<SObject> {

    // The 'start' method initializes the batch job by querying Market_Info__c records 
    // for the previous year with a specific ProductHierarchyLevel1__c value.
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String previousYear = String.valueOf(Date.today().year() - 1);
        return Database.getQueryLocator([
            SELECT Id, ProductHierarchyLevel1__c, Competitor__c, Tonnage__c, Year__c 
            FROM Market_Info__c 
            WHERE Competitor__c != null AND Tonnage__c != null 
                  AND Year__c = :previousYear AND ProductHierarchyLevel1__c = '130'
        ]);
    }

    // The 'execute' method processes each batch of Market_Info__c records. It calculates
    // the total tonnage for related Competitor__c records and updates the Market_Info_identified__c field.
    global void execute(Database.BatchableContext bc, List<Market_Info__c> marketInfoList) {
        Set<Id> companyIds = new Set<Id>();
        for (Market_Info__c marketInfo : marketInfoList) {
            if (marketInfo.Competitor__c != null) {
                companyIds.add(marketInfo.Competitor__c);
            }
        }

        // Query related Competitor__c records with their associated Market_Info__c data.
        List<Competitor__c> companies = [
            SELECT Id, RecordType.Name,
                   (SELECT Tonnage__c FROM Market_Info1__r 
                    WHERE Year__c = :String.valueOf(Date.today().year() - 1) 
                          AND ProductHierarchyLevel1__c = '130')
            FROM Competitor__c 
            WHERE RecordType.Name = 'Company' AND Id IN :companyIds
        ];

        List<Competitor__c> companiesToUpdate = new List<Competitor__c>();

        // Calculate total tonnage for each company and prepare it for update.
        for (Competitor__c company : companies) {
            Decimal totalTonnage = 0; // Reset for each company
            for (Market_Info__c marketInfo : company.Market_Info1__r) {
                totalTonnage += marketInfo.Tonnage__c != null ? marketInfo.Tonnage__c : 0;
            }
            company.Market_Info_identified__c = totalTonnage;
            companiesToUpdate.add(company);
        }

        // Update the companies with the calculated total tonnage, handling errors gracefully.
        if (!companiesToUpdate.isEmpty()) {
            try {
                update companiesToUpdate;
            } catch (DmlException e) {
                System.debug('Error updating companies: ' + e.getMessage());
            }
        }
    }

    // The 'finish' method runs after all batches are processed, logging a message.
    global void finish(Database.BatchableContext bc) {
        System.debug('Batch processing finished.');
    }
}