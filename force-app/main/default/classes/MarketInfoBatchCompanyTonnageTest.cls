@isTest
public class MarketInfoBatchCompanyTonnageTest {

    @testSetup
    static void setupTestData() {
        // Create a RecordType for Competitor__c if it doesn't exist
        RecordType companyRecordType = [
            SELECT Id FROM RecordType WHERE SObjectType = 'Competitor__c' AND Name = 'Company' LIMIT 1
        ];
        

        // Create Competitor__c records
        Competitor__c company1 = new Competitor__c(Name = 'Company 1', RecordTypeId = companyRecordType.Id);
        Competitor__c company2 = new Competitor__c(Name = 'Company 2', RecordTypeId = companyRecordType.Id);
        insert new List<Competitor__c>{company1, company2};

        // Create Market_Info__c records
        Integer previousYear = Date.today().year() - 1;
        insert new List<Market_Info__c>{
            new Market_Info__c(
                Competitor__c = company1.Id,
                Tonnage__c = 150,
                ProductHierarchyLevel1__c = '130',
                Year__c = String.valueOf(previousYear)
            ),
            new Market_Info__c(
                Competitor__c = company1.Id,
                Tonnage__c = 250,
                ProductHierarchyLevel1__c = '130',
                Year__c = String.valueOf(previousYear)
            ),
            new Market_Info__c(
                Competitor__c = company2.Id,
                Tonnage__c = 300,
                ProductHierarchyLevel1__c = '130',
                Year__c = String.valueOf(previousYear)
            )
        };
    }

    @isTest
    static void testBatchExecution() {
        // Start the test
        Test.startTest();

        // Execute the batch
        MarketInfoBatchCompanyTonnage batch = new MarketInfoBatchCompanyTonnage();
        ID batchJobId = Database.executeBatch(batch);

        // End the test
        Test.stopTest();

        // Verify the results
        List<Competitor__c> updatedCompanies = [
            SELECT Id, Market_Info_identified__c
            FROM Competitor__c
            WHERE Market_Info_identified__c != null
        ];

        // Assertions
        System.assertEquals(2, updatedCompanies.size(), 'Two companies should be updated');

        Map<Id, Decimal> expectedTonnages = new Map<Id, Decimal>{
            updatedCompanies[0].Id => 400,
            updatedCompanies[1].Id => 300
        };

        for (Competitor__c company : updatedCompanies) {
            System.assertEquals(
                expectedTonnages.get(company.Id),
                company.Market_Info_identified__c,
                'Market_Info_identified__c should be calculated correctly'
            );
        }
    }
}