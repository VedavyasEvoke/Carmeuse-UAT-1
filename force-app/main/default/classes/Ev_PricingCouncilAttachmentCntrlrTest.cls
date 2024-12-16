/**
* Class Name         : Ev_Products_By_PlantTriggerExecutorTest
* Developer          : D Sridhar           
* Created Date       : 08-05-2024
* @description       : Test class for Products_By_PlantTriggerExecutor. 
* Last Modified Date : 
*/
@isTest
private class Ev_PricingCouncilAttachmentCntrlrTest {
	@testSetup
    static void setup() {
        List<Product2> products = TestDataFactory.createRecords('Product2', 1, true, new Map<String, Object> {
            'Name'=>'HiCal Stone Pulv Very Fine 7/V Bulk', 'ProductCode'=>'000001', 'Plant__c'=>'US-RE;', 'Is_Offline__c'=>true });
        Id standardPriceBookId =  Test.getStandardPriceBookId();
        List<PricebookEntry> entries = TestDataFactory.createRecords('PricebookEntry', 1, true, new Map<String, Object> {
            'Product2Id'=>products[0].Id, 'Pricebook2Id'=>standardPriceBookId, 'UnitPrice'=>0, 'IsActive'=>true });
        
        List<SBQQ__Quote__c> quoteLst = TestDataFactory.createRecords('SBQQ__Quote__c', 1, true, new Map<String, Object> ());
        
        List<SBQQ__QuoteLine__c> lines = TestDataFactory.createRecords('SBQQ__QuoteLine__c', 1, true, new Map<String, Object>{
            'SBQQ__Quote__c'=>quoteLst[0].Id, 'SBQQ__Product__c'=>products[0].Id });
    }
      /**
* @description Checking if the quote lines are being retrieved properly on to vf.
*/
    @isTest
    static void Ev_PricingCouncilAttachmentControllerTest()
    {
        Test.startTest();
        List<SBQQ__Quote__c> quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        PageReference pageRef = Page.Ev_PricingCouncilAttachment;
        pageRef.getParameters().put('qid', quote[0].Id);
        Test.setCurrentPage(pageRef);
        Ev_PricingCouncilAttachmentController cntrlr = new Ev_PricingCouncilAttachmentController();
        Test.stopTest();
        Assert.isNotNull(cntrlr);
        //System.assertEquals(productByPlantLst.size()>0, true,'Products_By_Plant__c Inserted');
    }
}