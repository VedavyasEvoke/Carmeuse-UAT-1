@isTest
public class ev_MarketInfoYearCloneBatchTest {

    @testSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create test products
        Product2 testProduct1 = new Product2(Name = 'Test Product 1',Is_Offline__c = true);
        Product2 testProduct2 = new Product2(Name = 'Test Product 2',Is_Offline__c = true);
        insert new List<Product2>{ testProduct1, testProduct2 };

        // Get the current year
        Integer currentYear = Date.today().year();
        String currentYearStr = String.valueOf(currentYear);

        // Create test market info records for the current year with status 'Track'
        Market_Info__c testMarketInfo1 = new Market_Info__c(
            Customerprospect__c = testAccount.Id,
            Competitor_Product__c = testProduct1.Id,
            Year__c = currentYearStr,
            Status__c = 'Track'
        );

        Market_Info__c testMarketInfo2 = new Market_Info__c(
            Customerprospect__c = testAccount.Id,
            Competitor_Product__c = testProduct2.Id,
            Year__c = currentYearStr,
            Status__c = 'Track'
        );

        insert new List<Market_Info__c>{ testMarketInfo1, testMarketInfo2 };
    }

    @isTest
    static void testBatch() {
        // Get the current year and next year strings
        Integer currentYear = Date.today().year();
        String currentYearStr = String.valueOf(currentYear);
        String nextYearStr = String.valueOf(currentYear + 1);

        // Run the batch job
        Test.startTest();
        ev_MarketInfoYearCloneBatch batchJob = new ev_MarketInfoYearCloneBatch();
        Database.executeBatch(batchJob);
        Test.stopTest();

        // Verify that the current year's records have been retired
        List<Market_Info__c> retiredRecords = [SELECT Id, Status__c, Year__c FROM Market_Info__c WHERE Year__c = :currentYearStr AND Status__c = 'Retire'];
        System.assertEquals(2, retiredRecords.size(), 'There should be 2 retired records for the current year');

        // Verify that the new records for the next year have been created
        List<Market_Info__c> newRecords = [SELECT Id, Year__c FROM Market_Info__c WHERE Year__c = :nextYearStr];
        System.assertEquals(2, newRecords.size(), 'There should be 2 new records for the next year');

        // Verify that the new records have the correct year
        for (Market_Info__c mi : newRecords) {
            System.assertEquals(nextYearStr, mi.Year__c, 'The new records should have the correct year');
        }
    }
   @isTest
    static void testEmailSchedule(){ 
        Test.startTest();
        ev_MarketInfoYearCloneBatchSchedule marketinfosch=new ev_MarketInfoYearCloneBatchSchedule();
        String sch ='0 48 * * * ?';
        Id JobId = System.schedule('Schedule Marketinfo Batch Yearly', sch,marketinfosch);
        CronTrigger cronTrigger1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :JobId];
        System.assertEquals(sch, cronTrigger1.CronExpression);
        Test.stopTest();
    
    }

}