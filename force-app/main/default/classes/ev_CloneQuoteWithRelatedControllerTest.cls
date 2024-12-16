@isTest
private class ev_CloneQuoteWithRelatedControllerTest {
    @isTest
    static void testCloneQuotewithrelatedItems() {
        // Test data setup
        Opportunity testOpp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = System.Today());
        insert testOpp;
        String oppId = testOpp.Id;
        String opportunityName = 'Cloned Opportunity';
        
        // Quote
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(SBQQ__Opportunity2__c = testOpp.Id, SBQQ__Primary__c = TRUE);
        insert testQuote;
        string quoteid = testQuote.Id;
        
        
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
         try {
            Test.startTest();
            String clonedQuoteId = ev_CloneQuoteWithRelatedController.cloneQuoteWithRelated(quoteid);
            Test.stopTest();
            System.assertNotEquals(null, clonedQuoteId, 'Cloned Quote ID should not be null');
        } catch (Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
            System.assert(false, 'Exception should not have been thrown: ' + e.getMessage());
        }
    }
     @isTest
    static void testcatchCloneQuotewithrelatedItems() {
        // Test data setup
        Opportunity testOpp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = System.Today());
        insert testOpp;
        String oppId = testOpp.Id;
        String opportunityName = 'Cloned Opportunity';
        
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
        
        // Call the method being tested
         try {
            Test.startTest();
            String clonedQuoteId = ev_CloneQuoteWithRelatedController.cloneQuoteWithRelated(quoteid);
            Test.stopTest();
            System.assertNotEquals(null, clonedQuoteId, 'Cloned Quote ID should not be null');
        } catch (Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());
         }
    }
    
    
    

        }