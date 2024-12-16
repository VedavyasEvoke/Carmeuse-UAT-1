@isTest
public class ev_QuoteInfoTest {
    
     @testSetup
    static void setupTestData() {
        // Create Account
        Account account = new Account(Name = 'Test Account1', Business_Unit__c = 'Carmeuse');
        insert account;
         // Create Opportunity
        Opportunity opportunity = new Opportunity(
            Name = 'Test Opportunity',  AccountId = account.Id,
            CurrencyIsoCode = 'USD', StageName = 'Qualification',
            CloseDate = System.today() + 3
        );
        insert opportunity;

        // Create Product
        Product2 prodObjSample = new Product2(
            Name = 'TestProduct',
            ProductCode = 'xyz-1555',
            IsActive = true,
            Is_Offline__c = true,
            Family ='130'
        );
        insert prodObjSample;
                Sales_competitor__c sc =new Sales_competitor__c(Opportunity__c=opportunity.Id ,Product_2__c =prodObjSample.Id);

        // Create Quote
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            SBQQ__Account__c = account.Id,
            SBQQ__Opportunity2__c = opportunity.Id,
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__Primary__c = true,
            Customer_region__c ='Western Europe',
            Valid_from__c =System.today() + 5
            
        );
        insert quote;

        // Create Quote Line
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quote.Id,
            SBQQ__Product__c = prodObjSample.Id,
            SBQQ__Number__c = 1,
            SBQQ__Quantity__c = 1,
            SBQQ__Optional__c = false,
            Primary__c =true,
            Product_Family__c ='130'
        );
        insert quoteLine;

        // Create Sales Competitor
        Sales_Competitor__c competitor = new Sales_Competitor__c(
            Opportunity__c = opportunity.Id,
            Product__c = prodObjSample.Id
        );
        insert competitor;

        // Create previous Quote
        SBQQ__Quote__c previousQuote = new SBQQ__Quote__c(
            SBQQ__Account__c = account.Id,
            SBQQ__Opportunity2__c = opportunity.Id,
            SBQQ__Status__c = 'Draft',
            Pricing_Approval_Type__c='Pre-Approved',
              Customer_region__c ='North America',
            Valid_from__c =System.today() + 4
        );
        insert previousQuote;
       
        // Create previous Quote Line
        SBQQ__QuoteLine__c previousQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = previousQuote.Id,
            SBQQ__Product__c = prodObjSample.Id,
            SBQQ__Number__c = 1,
            SBQQ__Quantity__c = 1,
            SBQQ__Optional__c = false,
            Primary__c =true
        );
        insert previousQuoteLine;
        //update to won
        SBQQ__Quote__c updateQuote =new SBQQ__Quote__c(
        SBQQ__Status__c='Accepted',Incoterms1__c='CFR',
           Id =previousQuote.id,Valid_To__c = Date.today() , Valid_From__c = Date.today(),Pricing_Approved_Status__c='Approved'
            ,SE_Shipping_Type__c='10',Customer_region__c ='North America'
       );
        update updateQuote;
    }

    @isTest
    static void testRetriveCompetitorQuoteLine() {
        // Retrieve the test quote
        SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        // Call the retriveCompetitorQuoteLine method
           Map<String, Object> result = ev_QuoteInfo.retriveCompetitorQuoteLine(testQuote.Id);
        List<Sales_Competitor__c> quoteLines = (List<Sales_Competitor__c>) result.get('QuoteLines');
        System.assertNotEquals(0, quoteLines.size(), 'Competitors should be retrieved');
        
    }

    @isTest
    static void testRetrivePreviousQuoteLine() {
        // Retrieve the test quote
        SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        // Call the retrivePreviousQuoteLine method
        Map<String, Object> result = ev_QuoteInfo.retrivePreviousQuoteLine(testQuote.Id);

         
        List<SBQQ__QuoteLine__c> quoteLines = (List<SBQQ__QuoteLine__c>) result.get('QuoteLines');
     }

    @isTest
    static void testGetProposedData() {
        // Retrieve the test quote
        SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        // Call the getproposeddata method
        Map<String, Object> result = ev_QuoteInfo.getproposeddata(testQuote.Id);

        // Assert that the response contains the expected data
       // Assert.areEqual('Western Europe', result.get('CustomerRegion'), 'Customer Region should be Western Europe');
        List<SBQQ__QuoteLine__c> quoteLines = (List<SBQQ__QuoteLine__c>) result.get('QuoteLines');
        System.assertNotEquals(0, quoteLines.size(), 'QuoteLines should be retrieved');
    }
     @isTest
    static void retrivePreviousQuoteLineForNARegionTest() {
        // Retrieve a North America region quote
        SBQQ__Quote__c naQuote = [SELECT Id FROM SBQQ__Quote__c WHERE Customer_Region__c = 'North America' LIMIT 1];

        Test.startTest();
         Map<String, Object> result = ev_QuoteInfo.retrivePreviousQuoteLine(naQuote.Id);
         Test.stopTest();
                List<SBQQ__QuoteLine__c> quoteLines = (List<SBQQ__QuoteLine__c>) result.get('QuoteLines');

        // Assert that the previousQuoteLines list is not null
        Assert.areNotEqual(null, quoteLines, 'The result should not be null for North America region');

        
     }
}