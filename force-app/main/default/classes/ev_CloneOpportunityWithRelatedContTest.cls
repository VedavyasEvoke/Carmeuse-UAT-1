/***************************************************************************************************************************************************
# Class Name  = "ev_CloneOpportunityWithRelatedContTest"
# Author      = Naganjaneya Lakshman
# Description = Test class for 'ev_CloneOpportunityWithRelatedController' class.
# Change Log :
============================================================================================================
Date                     Changed By                        Change Description
============================================================================================================
10/05/2024                Naganjaneya Lakshman              Original Version
**************************************************************************************************************************************************/

@isTest
private class ev_CloneOpportunityWithRelatedContTest {
    
    @isTest
    static void testGetOpportunityName() {
        // Test data setup
        Opportunity testOpp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = System.Today());
        insert testOpp;
        
        // Call the method being tested
        Test.startTest();
        List<String>  opportunityName = ev_CloneOpportunityWithRelatedController.getOpportunityName(testOpp.Id);
		Test.stopTest();        
    }
    
    /*@isTest
    static void testCloneOpportunityWithQuoteForBundle() {
        // Test data setup
        Opportunity testOpp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = System.Today(), CurrencyIsoCode ='USD');
        insert testOpp;
        String oppId = testOpp.Id;
        String opportunityName = 'Cloned Opportunity';
        String currencycode ='Usd'; 
        
        // Quote
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(SBQQ__Opportunity2__c = testOpp.Id, SBQQ__Primary__c = TRUE);
        insert testQuote;
        
        // Product
        List<Product2> products = TestDataFactory.createRecords('Product2', 1, true, new Map<String, Object> {
            'Name'=>'HiCal Stone Pulv Very Fine 7/V Bulk', 'ProductCode'=>'000001', 'Plant__c'=>'US-RE;', 'Is_Offline__c'=>true });
        Id standardPriceBookId =  Test.getStandardPriceBookId();
        List<PricebookEntry> entries = TestDataFactory.createRecords('PricebookEntry', 1, true, new Map<String, Object> {
            'Product2Id'=>products[0].Id, 'Pricebook2Id'=>standardPriceBookId, 'UnitPrice'=>0, 'IsActive'=>true });
        
        // Quote Line
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id, SBQQ__Product__c = products[0].id);
        insert testQuoteLine;
        
        // Call the method being tested
        Test.startTest();
        String clonedOppId = ev_CloneOpportunityWithRelatedController.cloneOpportunityWithQuote(oppId, opportunityName,currencycode);
        Test.stopTest();
    }
    
    @isTest
    static void testCloneOpportunityWithQuoteForQuoteLine() {
        // Test data setup
        Opportunity testOpp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = System.Today(),CurrencyIsoCode ='USD');
        insert testOpp;
        String oppId = testOpp.Id;
        
        // Quote
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(SBQQ__Opportunity2__c = testOpp.Id, SBQQ__Primary__c = TRUE);
        insert testQuote;
        string quoteid = null;

        // Product
        List<Product2> products = TestDataFactory.createRecords('Product2', 1, true, new Map<String, Object> {
            'Name'=>'HiCal Stone Pulv Very Fine 7/V Bulk', 'ProductCode'=>'000001', 'Plant__c'=>'US-RE;', 'Is_Offline__c'=>true });
        Id standardPriceBookId =  Test.getStandardPriceBookId();
        List<PricebookEntry> entries = TestDataFactory.createRecords('PricebookEntry', 1, true, new Map<String, Object> {
            'Product2Id'=>products[0].Id, 'Pricebook2Id'=>standardPriceBookId, 'UnitPrice'=>0, 'IsActive'=>true });
        // Quote Line
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id, SBQQ__Product__c = products[0].id);
        insert testQuoteLine;
        
        String oppty = null;
        String opportunityName = 'Cloned Opportunity';
        String Curencycode ='USD';
        
        // Call the method being tested
         try {
            Test.startTest();
            String clonedQuoteId = ev_CloneOpportunityWithRelatedController.cloneOpportunityWithQuote(oppty, opportunityName,Curencycode);
            Test.stopTest();
            System.assertNotEquals(null, clonedQuoteId, 'Cloned Quote ID should not be null');
        } catch (Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
         }
    }*/
     @isTest
    static void testcloneOpportunityWithQuote(){
        //Opportunity
        Opportunity opportunitytest=new Opportunity(Name='Test record', StageName = 'Prospecting', CloseDate = System.Today(),CurrencyIsoCode ='USD');
        insert opportunitytest;
        //Sales Competitor
        Sales_Competitor__c sctest=new Sales_Competitor__c(Opportunity__c=opportunitytest.Id);
        insert sctest;
         // Quote
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(SBQQ__Opportunity2__c = opportunitytest.Id, SBQQ__Primary__c = TRUE);
        insert testQuote;
        //string quoteid = null;

        // Product
        List<Product2> products = TestDataFactory.createRecords('Product2', 1, true, new Map<String, Object> {
            'Name'=>'HiCal Stone Pulv Very Fine 7/V Bulk', 'ProductCode'=>'000001', 'Plant__c'=>'US-RE;', 'Is_Offline__c'=>true });
        Id standardPriceBookId =  Test.getStandardPriceBookId();
        List<PricebookEntry> entries = TestDataFactory.createRecords('PricebookEntry', 1, true, new Map<String, Object> {
            'Product2Id'=>products[0].Id, 'Pricebook2Id'=>standardPriceBookId, 'UnitPrice'=>0, 'IsActive'=>true });
        // Quote Line
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = testQuote.Id, SBQQ__Product__c = products[0].id);
        insert testQuoteLine;
        
        String oppty = null;
        String opportunityName = 'Cloned Opportunity';
        String Curencycode ='USD';
        Test.StartTest();
        ev_CloneOpportunityWithRelatedController.cloneOpportunityWithQuote(opportunitytest.Id,opportunityName,Curencycode);
        Test.StopTest();
    }
    
}