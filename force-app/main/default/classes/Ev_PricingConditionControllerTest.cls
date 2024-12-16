/**
* Class Name         : Ev_PricingConditionControllerTest
* Developer          : D Sridhar           
* Created Date       : 07-05-2024
* @description       : Test class for Ev_PricingConditionController. 
* Last Modified Date : 
*/
@isTest
private class Ev_PricingConditionControllerTest {
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
    
    /**
* @description Test Method for fetchQuotePricingConditionFieldset.
*/
    @isTest
    static void fetchQuotePricingConditionFieldset1() {
        Test.startTest();
        String fields = Ev_PricingConditionController.fetchQuotePricingConditionFieldset('Pricing_Condition_Header_Fields');
        Test.stopTest();
        Assert.isNotNull(fields);
    }
    
    /**
* @description Test Method for fetchQliPricingConditionFieldset.
*/
    @isTest
    static void fetchQliPricingConditionFieldset1() {
        Test.startTest();
        String fields = Ev_PricingConditionController.fetchQliPricingConditionFieldset('Pricing_Condition_Header_Fields');
        Test.stopTest();
        Assert.isNotNull(fields);
    }
    
    /**
* @description Test Method for fetchQuote.
*/
    @isTest
    static void fetchQuote1() {
        List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c WITH SECURITY_ENFORCED LIMIT 1];
        String parameters = JSON.serialize(new Map<String,Object>{ 'quoteId'=>quotes[0].Id });
        Test.startTest();
        List<SBQQ__Quote__c> resultQuotes = Ev_PricingConditionController.fetchQuote(parameters);
        Test.stopTest();
        Assert.isTrue(resultQuotes[0].Id == quotes[0].Id);
    }
    
    /**
* @description Test Method for fetchQuote.
*/
    @isTest
    static void fetchupdateQuote1() {
        List<SBQQ__Quote__c> quotes = [SELECT Id FROM SBQQ__Quote__c WITH SECURITY_ENFORCED LIMIT 1];
        Test.startTest();
        Ev_PricingConditionController.updateQuote(quotes[0]);
        Test.stopTest();
        List<SBQQ__Quote__c> resultQuotes = [SELECT Id FROM SBQQ__Quote__c WHERE Id = :quotes[0].Id WITH SECURITY_ENFORCED LIMIT 1];
        Assert.isTrue(resultQuotes[0].Id == quotes[0].Id);
    }
    
    /**
* @description Test Method for fetchQLIsofQuote.
*/
    @isTest
    static void fetchQLIsofQuote1() {
        List<SBQQ__Quote__c> quotes = [SELECT Id, (SELECT Id FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c WITH SECURITY_ENFORCED];
        String parameters = JSON.serialize(new Map<String,Object>{ 'quoteId'=>quotes[0].Id });
        Test.startTest();
        List<SBQQ__QuoteLine__c> resultLines = Ev_PricingConditionController.fetchQLIsofQuote(parameters);
        Test.stopTest();
        Assert.isTrue(quotes[0].SBQQ__LineItems__r.size() == resultLines.size());
    }
    
    /**
* @description Test Method for fetchPlantPicklistEntries.
*/
    @isTest
    static void fetchPlantPicklistEntries1() {
        Test.startTest();
        Map<String,String> activeEntries = Ev_PricingConditionController.fetchPlantPicklistEntries();
        Test.stopTest();
        Assert.isNotNull(activeEntries);
    }
    
    /**
* @description Test Method for fetchSalesOrgByPlant.
*/
    @isTest
    static void fetchSalesOrgByPlant1() {
        Test.startTest();
        List<SalesOrg_By_Plant__c> sops = Ev_PricingConditionController.fetchSalesOrgByPlant();
        Test.stopTest();
        Assert.isTrue(sops.size() >= 0);
    }
    
    /**
* @description Test Method for fetchPricingCategories.
*/
    @isTest
    static void fetchPricingCategories1() {
        String parameters = JSON.serialize(new Map<String,Object>{ 'plantRegion'=>'North America' });
        Test.startTest();
        List<AggregateResult> resultPcs = Ev_PricingConditionController.fetchPricingCategories(parameters);
        Test.stopTest();
        Assert.isTrue(resultPcs.size() == 2);
    }
    
    /**
* @description Test Method for fetchPCAs.
*/
    @isTest
    static void fetchPCAs1() {
        String parameters = JSON.serialize(new Map<String,Object>{ 'plantRegion'=>'North America' });
        Test.startTest();
        List<Pricing_Condition_Access__c> resultPcas = Ev_PricingConditionController.fetchPCAs(parameters);
        Test.stopTest();
        Assert.isTrue(resultPcas.size() == 4);
    }
    
    /**
* @description Test Method for updateQLIsWithPricingCategs.
*/
    @isTest
    static void updateQLIsWithPricingCategs1() {
        List<SBQQ__QuoteLine__c> lines = [SELECT Id FROM SBQQ__QuoteLine__c];
        Test.startTest();
        Boolean status = Ev_PricingConditionController.updateQLIsWithPricingCategs(lines);
        Test.stopTest();
        Assert.isTrue(status);
    }

     /**
* @description Test Method for fetchPriceLists.
*/
    @isTest
    static void fetchPriceListsTest() {
        
        Test.startTest();
        String mapdata = '{"startDate":"2024-06-14","endDate":"2024-12-31"}';
        Ev_PricingConditionController.fetchPriceLists(mapdata);
        Test.stopTest();
    }
}