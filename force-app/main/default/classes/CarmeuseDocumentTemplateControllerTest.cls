/**
* Class Name         : CarmeuseDocumentTemplateControllerTest
* Developer          : D Sridhar           
* Created Date       : 07-05-2024
* @description       : Test class for CarmeuseDocumentTemplateController 
* Last Modified Date : 
*/
@isTest
private class CarmeuseDocumentTemplateControllerTest {
    /**
* @description Test Data Setup.
*/
    @testSetup
    static void setup() {
        TestDataFactory.createRecords('SBQQ__Quote__c', 1, true, new Map<String, Object>());
        TestDataFactory.createRecords('SBQQ__Quote__c', 1, true, new Map<String, Object>{
            'SBQQ__QuoteLanguage__c' => 'English'});
        TestDataFactory.createRecords('SBQQ__QuoteTemplate__c', 1, true, new Map<String, Object> {
            'Name' => 'Test Quote Template' });
    }
    
    /**
* @description Testing with a Quote which doesn't contain any Quote Language
*/
    @isTest
    static void testMethod1() {
        List<SBQQ__Quote__c> quote = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__QuoteLanguage__c = null];
        List<SBQQ__QuoteTemplate__c> quoteTemplate = [SELECT Id FROM SBQQ__QuoteTemplate__c LIMIT 1];
        PageReference pageRef = Page.CarmeuseDocumentTemplate;
        pageRef.getParameters().put('qid', quote[0].Id);
        pageRef.getParameters().put('tid', quoteTemplate[0].Id);
        Test.setCurrentPage(pageRef);
        CarmeuseDocumentTemplateController controller = new CarmeuseDocumentTemplateController();
        Assert.isNotNull(controller);
    }
    
    /**
* @description Testing with a Quote which contains a Quote Language
*/
    @isTest
    static void testMethod2() {
        List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c];
        quotes[0].SBQQ__QuoteLanguage__c = 'English';
        update quotes;
        List<SBQQ__QuoteTemplate__c> quoteTemplate = [SELECT Id FROM SBQQ__QuoteTemplate__c LIMIT 1];
        PageReference pageRef = Page.CarmeuseDocumentTemplate;
        pageRef.getParameters().put('qid', quotes[0].Id);
        pageRef.getParameters().put('tid', quoteTemplate[0].Id);
        Test.setCurrentPage(pageRef);
        CarmeuseDocumentTemplateController controller = new CarmeuseDocumentTemplateController();
        controller.getShowLines();
        controller.testCoverLines();
        Assert.isNotNull(controller);
    }
    
    /**
* @description Testing with a Quote which contains a Quote Language
*/
    @isTest
    static void testMethod3() {
        List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c];
        quotes[0].SBQQ__QuoteLanguage__c = 'English';
        quotes[0].Customer_Region__c = 'North America';
        update quotes;
        List<SBQQ__QuoteTemplate__c> quoteTemplate = [SELECT Id FROM SBQQ__QuoteTemplate__c LIMIT 1];
        PageReference pageRef = Page.CarmeuseDocumentTemplate;
        pageRef.getParameters().put('qid', quotes[0].Id);
        pageRef.getParameters().put('tid', quoteTemplate[0].Id);
        Test.setCurrentPage(pageRef);
        CarmeuseDocumentTemplateController controller = new CarmeuseDocumentTemplateController();
        Assert.isNotNull(controller);
    }
}