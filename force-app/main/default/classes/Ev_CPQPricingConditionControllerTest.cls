/**
* Class Name         : Ev_CPQPricingConditionControllerTest
* Developer          : D Sridhar           
* Created Date       : 07-05-2024
* @description       : Test class for Ev_CPQPricingConditionController.
* Last Modified Date : 
*/
@isTest
private class Ev_CPQPricingConditionControllerTest {
    /**
* @description Test Data Setup.
*/
    @testSetup
    static void setup() {
        TestDataFactory.createRecords('SBQQ__Quote__c', 1, true, new Map<String, Object>());
    }
    
    /**
* @description Checks if the Navigation is happening to Quote Line Editor page.
*/
    @isTest
    static void navigateToUrlTestMethod1() {
        List<SBQQ__Quote__c> quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PageReference pageRef = Page.CarmeuseDocumentTemplate;
        pageRef.getParameters().put('Id', quote[0].Id);
        Test.setCurrentPage(pageRef);
        ev_CPQPricingConditionController controller = new ev_CPQPricingConditionController();
        String qliUrl = controller.navigateToUrl().getUrl();
        Assert.isTrue(qliUrl.contains('/apex/sbqq__sb'));
    }
}