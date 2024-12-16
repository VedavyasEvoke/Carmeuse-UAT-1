/**
* Class Name         : Ev_SAPRestCalloutTest
* Developer          : D Sridhar           
* Created Date       : 07-05-2024
* @description       : Test class for Ev_SAPRestCallout. 
* Last Modified Date : 
*/
@isTest
private class Ev_SAPRestCalloutTest {
    /**
* @description Test Data Setup.
*/
    @testSetup
    static void setup() {
        TestDataFactory.createRecords('Pricing_Category__c', 1, true, new Map<String, Object>{
            'Sales_Organization__c'=>'2201', 'Ranking__c'=>'1', 'Price_Category__c'=>'Product', 'Description__c'=>'Cust material price',
                'Plant_Region__c'=>'North America;Western Europe;Central Europe', 'Category_Type__c'=>'ZCPR' });
        TestDataFactory.createRecords('Pricing_Category__c', 1, true, new Map<String, Object>{
            'Sales_Organization__c'=>'2201', 'Ranking__c'=>'2', 'Price_Category__c'=>'Freight', 'Description__c'=>'Truck Freight / Ton',
                'Plant_Region__c'=>'North America', 'Category_Type__c'=>'ZF1' });
        TestDataFactory.createRecords('Pricing_Condition_Access__c', 1, true, new Map<String, Object>{
            'Princing_Condition__c'=>'ZCPR', 'Access_seq__c'=>'ZCUS', 'Option__c'=>'2', 'Option_Name__c'=>'Sales.Org/Dist.Channel/Ship.To/Material/Plant',
                'Option_Tech_no__c'=>'10', 'Table__c'=>'A921', 'Fields__c'=>'Sales.Org,Dist.Channel,Ship.To,Material,Plant', 'Region__c'=>'North America;Western Europe',
                'Option_Label__c'=>'Ship to Pricing' });
        TestDataFactory.createRecords('Pricing_Condition_Access__c', 1, true, new Map<String, Object>{
            'Princing_Condition__c'=>'ZCPR', 'Access_seq__c'=>'ZCUS', 'Option__c'=>'6', 'Option_Name__c'=>'Sales.Org/Dist.Channel/Sold.To/Material/Plant/IncoTerms',
                'Option_Tech_no__c'=>'22', 'Table__c'=>'A924', 'Fields__c'=>'Sales.Org,Dist.Channel,Sold.To,Material,Plant,IncoTerms', 'Region__c'=>'North America;Western Europe',
                'Option_Label__c'=>'Ship to Pricing' });
        TestDataFactory.createRecords('Pricing_Condition_Access__c', 1, true, new Map<String, Object>{
            'Princing_Condition__c'=>'ZF1', 'Access_seq__c'=>'ZINC', 'Option__c'=>'2', 'Option_Name__c'=>'Sales.Org/Dist.Channel/Inco.Terms/Ord.Reason/Plant/Material/Ship.Type/Ship.To',
                'Option_Tech_no__c'=>'10', 'Table__c'=>'A804', 'Fields__c'=>'Sales.Org,Dist.Channel,Inco.Terms,Plant,Material,Ship.Type,Ship.To', 
                'Region__c'=>'North America', 'Option_Label__c'=>'Ship to + Ship type' });
        TestDataFactory.createRecords('Pricing_Condition_Access__c', 1, true, new Map<String, Object>{
            'Princing_Condition__c'=>'ZF1', 'Access_seq__c'=>'ZINC', 'Option__c'=>'3', 'Option_Name__c'=>'Sales.Org/Dist.Channel/Inco.Terms/Plant/Material/Ship.To',
                'Option_Tech_no__c'=>'30', 'Table__c'=>'A856', 'Fields__c'=>'Sales.Org,Dist.Channel,Inco.Terms,Plant,Material,Ship.To', 
                'Region__c'=>'North America', 'Option_Label__c'=>'Ship to' });
        List<Product2> products = TestDataFactory.createRecords('Product2', 1, true, new Map<String, Object> {
            'Name'=>'HiCal Stone Pulv Very Fine 7/V Bulk', 'ProductCode'=>'000001', 'Plant__c'=>'US-RE;', 'Is_Offline__c'=>true });
        Id standardPriceBookId =  Test.getStandardPriceBookId();
        List<PricebookEntry> entries = TestDataFactory.createRecords('PricebookEntry', 1, true, new Map<String, Object> {
            'Product2Id'=>products[0].Id, 'Pricebook2Id'=>standardPriceBookId, 'UnitPrice'=>0, 'IsActive'=>true });
        List<SBQQ__Quote__c> quotes = TestDataFactory.createRecords('SBQQ__Quote__c', 1, true, new Map<String, Object>());
        List<SBQQ__QuoteLine__c> lines = TestDataFactory.createRecords('SBQQ__QuoteLine__c', 1, true, new Map<String, Object>{
            'SBQQ__Quote__c'=>quotes[0].Id, 'SBQQ__Product__c'=>products[0].Id, 'ZCPR__c'=>100, 'ZCPR_Option__c'=>'2' });
    }
    
    @isTest
    static void prepareSAPCallout1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<SBQQ__Quote__c> quotes = TestDataFactory.createRecords('SBQQ__Quote__c', 1, true, new Map<String, Object>());
        List<Product2> products = [SELECT Id FROM Product2 WHERE ProductCode = '000001' WITH SECURITY_ENFORCED];
        List<SBQQ__QuoteLine__c> lines = TestDataFactory.createRecords('SBQQ__QuoteLine__c', 1, true, new Map<String, Object>{
            'SBQQ__Quote__c'=>quotes[0].Id, 'SBQQ__Product__c'=>products[0].Id, 'ZCPR__c'=>100, 'ZCPR_Option__c'=>'6' });
        String parameters = JSON.serialize(new Map<String,Object>{ 'quoteId'=>quotes[0].Id });
        
        Test.startTest();
        ev_SAPRestCallout.prepareSAPCallout(parameters);
        Test.stopTest();
    }
    
    @isTest
    static void prepareSAPCallout2() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<SBQQ__Quote__c> quotes = TestDataFactory.createRecords('SBQQ__Quote__c', 1, true, new Map<String, Object>{
            'Business_Unit__c'=>'Carmeuse' });
        List<Product2> products = [SELECT Id FROM Product2 WHERE ProductCode = '000001'];
        List<SBQQ__QuoteLine__c> lines = TestDataFactory.createRecords('SBQQ__QuoteLine__c', 1, true, new Map<String, Object>{
            'SBQQ__Quote__c'=>quotes[0].Id, 'SBQQ__Product__c'=>products[0].Id, 'ZCPR__c'=>100, 'ZCPR_Option__c'=>'2', 'ZF1__c'=>100, 'ZF1_Option__c'=>'2' });
        String parameters = JSON.serialize(new Map<String,Object>{ 'quoteId'=>quotes[0].Id });
        
        Test.startTest();
        ev_SAPRestCallout.prepareSAPCallout(parameters);
        Test.stopTest();
    }
}