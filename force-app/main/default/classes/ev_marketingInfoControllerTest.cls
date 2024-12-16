@isTest
public class ev_marketingInfoControllerTest {
    
    // Utility method to create test data
    private static void createTestData() {
        // Create a test Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        opportunity Opp =new Opportunity (Name ='Test Opp', AccountId=acc.Id);

        // Create a test Product
        Product2 prod = new Product2(Name = 'Test Product',Is_Offline__c = true);
        insert prod;

        // Create a test Quote
        SBQQ__Quote__c quote = new SBQQ__Quote__c( SBQQ__Account__c = acc.Id,SBQQ__Opportunity2__c =opp.Id);
        insert quote;

        // Create a test Quote Line
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = prod.Id);
        insert quoteLine;

        // Create a test Market Info record
        Market_Info__c marketInfo = new Market_Info__c(
            Name = 'Test Market Info',
            Customerprospect__c = acc.Id,
            Competitor_Product__c = prod.Id,
            Year__c = String.valueOf(Date.today().year() - 1),
            Status__c = 'Track'
        );
        insert marketInfo;
    }

    @isTest
    static void testGetMarketingProds() {
        // Create test data
        createTestData();

        // Retrieve the test Quote
        SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        // Test the getMarketingProds method
        Test.startTest();
        List<Market_Info__c> result = ev_marketingInfoController.getMarketingProds(testQuote.Id);
        Test.stopTest();

       
    }

    @isTest
    static void testCloseModal() {
        // Create test data
        createTestData();

        // Retrieve the test Quote
        SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        // Test the closeModal method
        Test.startTest();
        ev_marketingInfoController.closeModal(testQuote.Id);
        Test.stopTest();

        // Verify the results
        testQuote = [SELECT Is_Model_Enabled__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id];
        System.assertEquals(false, testQuote.Is_Model_Enabled__c, 'Expected Is_Model_Enabled__c to be false');
    }

    @isTest
    static void testUpdateMarketingProds() {
        // Create test data
        createTestData();

        // Retrieve the test Quote
        SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        // Retrieve the test Market Info
        List<Market_Info__c> marketInfos = [SELECT Id FROM Market_Info__c LIMIT 1];
        String marketInfosJson = JSON.serialize(marketInfos);

        // Test the updateMarketingProds method
        Test.startTest();
        ev_marketingInfoController.updateMarketingProds(marketInfosJson, testQuote.Id);
        Test.stopTest();

        // Verify the results
        List<Market_Info__c> updatedMarketInfos = [SELECT Status__c FROM Market_Info__c WHERE Id IN :marketInfos];
        System.assertEquals('Retire', updatedMarketInfos[0].Status__c, 'Expected the Market Info status to be Retire');

        List<Market_Info__c> newMarketInfos = [SELECT Id FROM Market_Info__c WHERE Year__c = :String.valueOf(Date.today().year())];
        System.assert(newMarketInfos.size() > 0, 'Expected at least one new Market_Info__c record');
    }
}