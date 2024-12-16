/**
* Class Name         : ev_AddPlantToProducts
* Developer          : D Sridhar           
* Created Date       : 21-06-2024
* @description       : Test class for ev_AddPlantToProducts.
* Last Modified Date : 
*/
@isTest
private class ev_AddPlantToProductsTest {
    
    /**
* @description Queries for records to run in batches.
* @param BC Batch context
* @return returns the queried records
*/
    @testSetup
    static void setup() {
        TestDataFactory.createRecords('Product2', 1, true, new Map<String, Object> {
            'Name'=>'TestProduct1', 'ProductCode'=>'1', 'Plant__c'=>'US-RE;', 'Is_Offline__c'=>true });
        TestDataFactory.createRecords('Product2', 1, true, new Map<String, Object> {
            'Name'=>'TestProduct2', 'ProductCode'=>'2', 'Plant__c'=>'US-RE;', 'Is_Offline__c'=>true });
        
        List<String> plants = new List<String>{'BE-SE', 'BE-EN', 'BE-MO', 'NL-GO', 'NL-01', 'BE-01'};
        List<Products_By_Plant__c> pbps = new List<Products_By_Plant__c>();
        for(Integer i = 0; i < 6; i++) {
            pbps.add(new Products_By_Plant__c(Product_Code__c = String.valueOf(Math.mod(i,2) + 1), Plant_Code__c = plants[i]));
        }
        Database.insert(pbps);
    }
    
    /**
* @description Queries for records to run in batches.
* @param BC Batch context
* @return returns the queried records
*/
    @isTest
    static void testMethod1() {
        Test.startTest();
        ev_AddPlantToProducts ev_AddPlantToProductsInstance =  new ev_AddPlantToProducts();
		Database.executeBatch(ev_AddPlantToProductsInstance);
        Test.stopTest();
    }
}