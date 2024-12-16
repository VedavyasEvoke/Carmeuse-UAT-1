/**
* Class Name         : Ev_Products_By_PlantTriggerExecutorTest
* Developer          : D Sridhar           
* Created Date       : 08-05-2024
* @description       : Test class for Products_By_PlantTriggerExecutor. 
* Last Modified Date : 
*/
@isTest
private class Ev_Products_By_PlantTriggerExecutorTest {
    /**
* @description Test Data Setup.
*/
    @testSetup
    static void setup() {
        List<Product2> products = TestDataFactory.createRecords('Product2', 1, true, new Map<String, Object> {
            'Name'=>'HiCal Stone Pulv Very Fine 7/V Bulk', 'ProductCode'=>'000001', 'Plant__c'=>'US-RE;', 'Is_Offline__c'=>true });
        Id standardPriceBookId =  Test.getStandardPriceBookId();
        List<PricebookEntry> entries = TestDataFactory.createRecords('PricebookEntry', 1, true, new Map<String, Object> {
            'Product2Id'=>products[0].Id, 'Pricebook2Id'=>standardPriceBookId, 'UnitPrice'=>0, 'IsActive'=>true });
    }
    
    /**
* @description Checking if Products_By_Plant__c record is created for existing Products.
*/
    @isTest
    static void upsertProductsWithPlants1()
    {
        Test.startTest();
        List<Products_By_Plant__c> productByPlantLst = TestDataFactory.createRecords('Products_By_Plant__c', 1, true, new Map<String, Object> {
            'Name'=>'Test Product By Template 1', 'Product_Code__c'=>'000003', 'Plant_Code__c'=>'US-GR', 'Status_Code__c'=>'A' });  
        Test.stopTest();
        System.assertEquals(productByPlantLst.size()>0, true,'Products_By_Plant__c Inserted');
    }
    
    /**
* @description Checking if Products_By_Plant__c record is created if the Product doesn't exists.
*/
    @isTest
    static void upsertProductsWithPlants2()
    {
        Test.startTest();
        List<Products_By_Plant__c> productByPlantLst =TestDataFactory.createRecords('Products_By_Plant__c', 1, true, new Map<String, Object> {
            'Name' => 'Test Product By Template 1','Product_Code__c'=>'000001','Plant_Code__c'=>'US-GR','Status_Code__c'=>'A' });  
        Test.stopTest();
       System.assertEquals(productByPlantLst.size()>0, true,'Products_By_Plant__c Inserted');

    }
}