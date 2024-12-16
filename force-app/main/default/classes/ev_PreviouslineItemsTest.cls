@isTest
public class ev_PreviouslineItemsTest {
    @testSetup
    static void setupTestData() {
        // Create Account
        Account account = new Account(Name = 'Test Account1', Business_Unit__c = 'Carmeuse');
        insert account;
        
        // Create Product
        Product2 prodObjSample = new Product2(
            Name = 'TestProduct',
            ProductCode = 'xyz-1555',
            IsActive = true,
            Is_Offline__c = true,
            Family = 'Sales Organization'
        );
        insert prodObjSample;
        
        // Create Primary Quote
        SBQQ__Quote__c primaryQuote = new SBQQ__Quote__c(
            SBQQ__Account__c = account.Id,
            SBQQ__Status__c = 'Draft',
            SBQQ__Opportunity2__c = null,
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Primary__c = true,
            Incoterms1__c  = 'CIF'
        );
        insert primaryQuote;
        
        // Update Primary Quote
        primaryQuote.SBQQ__Status__c = 'Accepted';
         
        update primaryQuote;
        
        // Create Quote Line for Primary Quote
        SBQQ__QuoteLine__c primaryQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = primaryQuote.Id,
            SBQQ__Product__c = prodObjSample.Id,
            SBQQ__Quantity__c = 10,
            SBQQ__Optional__c = false
        );
        insert primaryQuoteLine;
        
        // Create Previous Won Quote
        SBQQ__Quote__c previousQuoteWon = new SBQQ__Quote__c(
            SBQQ__Account__c = account.Id,
            SBQQ__Status__c = 'Draft',
            SBQQ__Opportunity2__c = null,
            SBQQ__SubscriptionTerm__c = 12,
            Incoterms1__c  = 'CFR'
        );
        insert previousQuoteWon;
        
        // Update Previous Won Quote
        previousQuoteWon.SBQQ__Status__c = 'Accepted';
        previousQuoteWon.Incoterms1__c = 'CFR';
        update previousQuoteWon;
        
        // Create Quote Line for Previous Won Quote
        SBQQ__QuoteLine__c previousQuoteLineWon = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = previousQuoteWon.Id,
            SBQQ__Product__c = prodObjSample.Id,
            SBQQ__Quantity__c = 5,
            SBQQ__Optional__c = false
        );
        insert previousQuoteLineWon;
        
        // Create Previous Lost Quote
        SBQQ__Quote__c previousQuoteLost = new SBQQ__Quote__c(
            SBQQ__Account__c = account.Id,
            SBQQ__Status__c = 'Rejected',
            SBQQ__Opportunity2__c = null,
            SBQQ__SubscriptionTerm__c = 12,
            Incoterms1__c  = 'CFR'
        );
        insert previousQuoteLost;
        
        // Create Quote Line for Previous Lost Quote
        SBQQ__QuoteLine__c previousQuoteLineLost = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = previousQuoteLost.Id,
            SBQQ__Product__c = prodObjSample.Id,
            SBQQ__Quantity__c = 7,
            SBQQ__Optional__c = false
        );
        insert previousQuoteLineLost;
    }
    
    @isTest
    static void testRetrieveWonQuoteLines() {
        // Retrieve the primary quote
        SBQQ__Quote__c primaryQuote = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Accepted' LIMIT 1];
        System.assertNotEquals(null, primaryQuote, 'Primary quote should be created');
        
        Test.startTest();
        List<SBQQ__QuoteLine__c> wonQuoteLines = ev_PreviouslineItems.retrieveWonQuoteLines(primaryQuote.Id);
        Test.stopTest();
        
         
        System.assertNotEquals(null, wonQuoteLines, 'The result should not be null');
         System.assertEquals(10, wonQuoteLines[0].SBQQ__Quantity__c, 'The quantity of the won quote line should be 10');
    }
    
    @isTest
    static void testRetrieveLostQuoteLines() {
        // Retrieve the primary quote
        SBQQ__Quote__c primaryQuote = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Primary__c = true LIMIT 1];
        System.assertNotEquals(null, primaryQuote, 'Primary quote should be created');
        
        Test.startTest();
        List<SBQQ__QuoteLine__c> lostQuoteLines = ev_PreviouslineItems.retrieveLostQuoteLines(primaryQuote.Id);
        Test.stopTest();
        
        // Check if the returned lines match the expected lines
        System.assertNotEquals(null, lostQuoteLines, 'The result should not be null');
        System.assertEquals(1, lostQuoteLines.size(), 'Expected 1 lost SBQQ__QuoteLine__c record');
        System.assertEquals(7, lostQuoteLines[0].SBQQ__Quantity__c, 'The quantity of the lost quote line should be 7');
    }
}