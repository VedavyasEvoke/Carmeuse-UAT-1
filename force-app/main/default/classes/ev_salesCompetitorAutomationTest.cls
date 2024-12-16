/***************************************************************************************************************************************************
# Class Name  = "ev_salesCompetitorAutomationTest"
# Author      = Naganjaneya Lakshman
# Description = Test class for 'ev_salesCompetitorAutomation' class.

# Change Log :
============================================================================================================
Date                     Changed By                        Change Description
============================================================================================================
07/05/2024                Naganjaneya Lakshman              Original Version
**************************************************************************************************************************************************/

@isTest
private class ev_salesCompetitorAutomationTest {

    // Test method for salesCompetitorAutomation
    @isTest
    static void testSalesCompetitorAutomation() {
        
        Test.startTest();
        // Create a test Account
        Account testAccount = new Account(
            Name='TestAccount',
            Account_Group__c = '1'
        );
		insert testAccount;
        
        // Create a test Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            Bid_Due_Date__c = System.today().addDays(45),
            Municipality__c = 'Yes',
            CloseDate = System.Today(),
            StageName = 'Qualification'
        );
        insert testOpp;
        
        // Products
        List<Product2> products = TestDataFactory.createRecords('Product2', 1, true, new Map<String, Object> {
            'Name'=>'HiCal Stone Pulv Very Fine 7/V Bulk', 'ProductCode'=>'000001', 'Plant__c'=>'US-RE;', 'Is_Offline__c'=>true,'Family'=>'130' });
        Id standardPriceBookId =  Test.getStandardPriceBookId();
        List<PricebookEntry> entries = TestDataFactory.createRecords('PricebookEntry', 1, true, new Map<String, Object> {
            'Product2Id'=>products[0].Id, 'Pricebook2Id'=>standardPriceBookId, 'UnitPrice'=>0, 'IsActive'=>true });
        
        // Create a test MarketInfo
        List<Market_Info__c> marketInfoList = new List<Market_Info__c>();
        
        Market_Info__c marketinfo = new Market_Info__c();
        marketinfo.Competitor_Product__c = products[0].id;
		marketinfo.SoldTo__c = testAccount.id;
        marketinfo.Year__c ='2024';
        marketInfoList.add(marketinfo);
        
        insert marketInfoList;
        
        // Create test data - SBQQ__Quote__c
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(SBQQ__Opportunity2__c = testOpp.id, Sold_to__c = testAccount.id);
        insert testQuote;

        // Create test data - SBQQ__QuoteLine__c
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id, SBQQ__Product__c = products[0].id);
        insert testQuoteLine;

        // Call the method to test
        ev_salesCompetitorAutomation compAutomation = new ev_salesCompetitorAutomation();
        compAutomation.salesCompetitorAutomation(new List<SBQQ__QuoteLine__c>{testQuoteLine});
        Test.stopTest();

        // Query Sales Competitor records to verify insertion
        List<Sales_Competitor__c> insertedCompetitors = [SELECT Id FROM Sales_Competitor__c WHERE Opportunity__c = :testQuote.SBQQ__Opportunity2__c];
    }

    // Test method for salesCompetitorDelete
    @isTest
    static void testSalesCompetitorDelete() {
        Test.startTest();
        
        Set<Id> productIdsToDelete = new Set<Id>();
        
        // Create a test Account
        Account testAccount = new Account(
            Name='TestAccount',
            Account_Group__c = '1'
        );
		insert testAccount;
        
        // Create a test Opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            Bid_Due_Date__c = System.today().addDays(45),
            Municipality__c = 'Yes',
            CloseDate = System.Today(),
            StageName = 'Qualification'
        );
        insert testOpp;
        
        // Products
        List<Product2> products = TestDataFactory.createRecords('Product2', 1, true, new Map<String, Object> {
            'Name'=>'HiCal Stone Pulv Very Fine 7/V Bulk', 'ProductCode'=>'000001', 'Plant__c'=>'US-RE;', 'Is_Offline__c'=>true,'Family'=>'130' });
        Id standardPriceBookId =  Test.getStandardPriceBookId();
        List<PricebookEntry> entries = TestDataFactory.createRecords('PricebookEntry', 1, true, new Map<String, Object> {
            'Product2Id'=>products[0].Id, 'Pricebook2Id'=>standardPriceBookId, 'UnitPrice'=>0, 'IsActive'=>true });
        
        // Create a test MarketInfo
        List<Market_Info__c> marketInfoList = new List<Market_Info__c>();
        
        Market_Info__c marketinfo = new Market_Info__c();
        marketinfo.Competitor_Product__c = products[0].id;
		marketinfo.SoldTo__c = testAccount.id;
        marketinfo.Year__c ='2024';
        marketInfoList.add(marketinfo);
        insert marketInfoList;
        
        // Create test data - SBQQ__Quote__c
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(SBQQ__Opportunity2__c = testOpp.Id, Sold_to__c = testAccount.Id);
        insert testQuote;

        // Create test data - SBQQ__QuoteLine__c
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id, SBQQ__Product__c = products[0].id);
        insert testQuoteLine;

        // Create test data - Sales Competitor record
        Sales_Competitor__c testCompetitor = new Sales_Competitor__c(Opportunity__c = testQuote.SBQQ__Opportunity2__c, Product__c = testQuoteLine.SBQQ__Product__c);
        insert testCompetitor;
        delete testQuoteLine;

        // Call the method to test
        ev_salesCompetitorAutomation compAutomation = new ev_salesCompetitorAutomation();
        compAutomation.salesCompetitorDelete(new List<SBQQ__QuoteLine__c>{testQuoteLine});
        Test.stopTest();

        // Query Sales Competitor records to verify deletion
        List<Sales_Competitor__c> deletedCompetitors = [SELECT Id FROM Sales_Competitor__c WHERE Opportunity__c = :testQuote.SBQQ__Opportunity2__c];
    }
}