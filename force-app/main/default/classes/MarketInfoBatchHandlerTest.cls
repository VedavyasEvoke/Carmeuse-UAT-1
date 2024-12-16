@isTest
public class MarketInfoBatchHandlerTest {

    @testSetup
    static void setupTestData() {
        // Create a RecordType for Competitor__c if it doesn't exist
        RecordType plantRecordType = [
            SELECT Id FROM RecordType WHERE SObjectType = 'Competitor__c' AND Name = 'Plant' LIMIT 1
        ];
        

        // Create Competitor__c records
        Competitor__c plant1 = new Competitor__c(Name = 'Plant 1', RecordTypeId = plantRecordType.Id);
        Competitor__c plant2 = new Competitor__c(Name = 'Plant 2', RecordTypeId = plantRecordType.Id);
        insert new List<Competitor__c>{plant1, plant2};

        // Create Market_Info__c records
        Integer previousYear = Date.today().year() - 1;
        insert new List<Market_Info__c>{
            new Market_Info__c(
                Competitor_Plant_Id__c = plant1.Id,
                Tonnage__c = 100,
                ProductHierarchyLevel1__c = '130',
                Year__c = String.valueOf(previousYear)
            ),
            new Market_Info__c(
                Competitor_Plant_Id__c = plant1.Id,
                Tonnage__c = 200,
                ProductHierarchyLevel1__c = '130',
                Year__c = String.valueOf(previousYear)
            ),
            new Market_Info__c(
                Competitor_Plant_Id__c = plant2.Id,
                Tonnage__c = 150,
                ProductHierarchyLevel1__c = '130',
                Year__c = String.valueOf(previousYear)
            )
        };
    }

    @isTest
    static void testMarketInfoBatchHandler() {
        // Start the test
        Test.startTest();

        // Execute the batch
        MarketInfoBatchHandler batch = new MarketInfoBatchHandler();
        ID batchJobId = Database.executeBatch(batch);

        // End the test
        Test.stopTest();

        // Verify the results
        List<Competitor__c> updatedPlants = [
            SELECT Id, Market_Info_identified__c
            FROM Competitor__c
            WHERE Market_Info_identified__c != null
        ];

        // Assertions
        System.assertEquals(2, updatedPlants.size(), 'Two plants should be updated');

        Map<Id, Decimal> expectedTonnages = new Map<Id, Decimal>{
            updatedPlants[0].Id => 300,
            updatedPlants[1].Id => 150
        };

        for (Competitor__c plant : updatedPlants) {
            System.assertEquals(
                expectedTonnages.get(plant.Id),
                plant.Market_Info_identified__c,
                'Market_Info_identified__c should be calculated correctly'
            );
        }
    }
}