@isTest
public class BatchToRemoveExpiredProductTest {
    @testSetup
    public static void testDataRemoveExpiredProduct(){
        TriggerConfiguration.setDoNotRunTrigger();
        List<Account> lstAccount = TestDataFactory.createTestData();
        List<CommerceEntitlementPolicy> lstCommerceEntitlementPolicy = [SELECT Id,Name FROM CommerceEntitlementPolicy WHERE Account__c IN:lstAccount];
        List<Pricebook2> lstPricebook = [SELECT Id FROM Pricebook2 WHERE Account__c IN:lstAccount];
        
        Integer days = -60;
        Integer daysto = -30;
        List<Product2> lstProduct = new List<Product2>();
        for(Integer Index=1;Index<=6;index++){
            Product2 objProduct2 = new Product2();
            if(Index<3){
                objProduct2.Name = 'HiCal QL Pulv W/Flo Aid Bulk';
                objProduct2.SAP_Probability__c = 99;
            }
            else if(Index>=3 && Index<=4){
                objProduct2.Name = 'Rice Aid Blend';
                objProduct2.SAP_Probability__c = 99;
            }
            else if(Index == 5){
                objProduct2.Name = 'Washed Gravel';
                objProduct2.SAP_Probability__c = 99;
            }
            else{
                objProduct2.Name = 'Washed Gravel';
                objProduct2.SAP_Probability__c = 100;
            }
            objProduct2.Family = 'Lime';
            objProduct2.MaterialNumber__c = '000000000000010325-000000000'+Index+'-00012348';
            objProduct2.StockKeepingUnit = '000000000000010325-000000000'+Index+'-00012348';
            objProduct2.ProductCode = '10325';
            objProduct2.Plant_Code__c = 'BL';
            objProduct2.Shipping_Condition__c='CP';
            objProduct2.Ship__c = '99';
            objProduct2.Valid_From__c = Date.today().addDays(days);
            objProduct2.Valid_To__c = Date.today().addDays(daysto);
            lstProduct.add(objProduct2);
            days += 31;
            daysto += 30;
        }
        insert lstProduct;
        
        Id stdPricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> lstStdPricebookEntry = new List<PricebookEntry>();
        for(Product2 objProduct2 : lstProduct){
            PricebookEntry objStdPricebook2= new PricebookEntry();
            objStdPricebook2.Pricebook2Id = stdPricebookId;
            objStdPricebook2.Product2Id = objProduct2.Id;
            objStdPricebook2.UnitPrice = 999;
            objStdPricebook2.IsActive = true;
            lstStdPricebookEntry.add(objStdPricebook2);
        }
        insert lstStdPricebookEntry;
        
        List<CommerceEntitlementProduct> lstCommerceEntitlementProduct = new List<CommerceEntitlementProduct>();
        List<Product2> lstProductHiCalWashed = [SELECT Id,SAP_Probability__c FROM Product2 WHERE SAP_Probability__c = 99 AND (Name = 'HiCal QL Pulv W/Flo Aid Bulk' OR Name = 'Washed Gravel' )];
        List<Product2> lstProductRice = [SELECT Id,SAP_Probability__c FROM Product2 WHERE Name = 'Rice Aid Blend'];
        List<Product2> lstProductWashed = [SELECT Id,SAP_Probability__c FROM Product2 WHERE Name = 'Washed Gravel' AND SAP_Probability__c = 100];
        List<PricebookEntry> lstCustomPricebookEntry = new List<PricebookEntry>();
        
        for(Product2 objProduct2 : lstProductHiCalWashed){
            CommerceEntitlementProduct objCommerceEntitlementProduct = new CommerceEntitlementProduct();
            objCommerceEntitlementProduct.PolicyId = lstCommerceEntitlementPolicy[0].Id;
            objCommerceEntitlementProduct.ProductId = objProduct2.Id;
            lstCommerceEntitlementProduct.add(objCommerceEntitlementProduct);  
            
            PricebookEntry objCustomPricebook2= new PricebookEntry();
            objCustomPricebook2.IsActive = true;
            objCustomPricebook2.Pricebook2Id = lstPricebook[0].Id;
            objCustomPricebook2.Product2Id = objProduct2.Id;
            objCustomPricebook2.UnitPrice = 555;
            lstCustomPricebookEntry.add(objCustomPricebook2);
        }
        
        for(Product2 objProduct2 : lstProductRice){
            CommerceEntitlementProduct objCommerceEntitlementProduct = new CommerceEntitlementProduct();
            objCommerceEntitlementProduct.PolicyId = lstCommerceEntitlementPolicy[1].Id;
            objCommerceEntitlementProduct.ProductId = objProduct2.Id;
            lstCommerceEntitlementProduct.add(objCommerceEntitlementProduct);  
            
            PricebookEntry objCustomPricebook2= new PricebookEntry();
            objCustomPricebook2.IsActive = true;
            objCustomPricebook2.Pricebook2Id = lstPricebook[1].Id;
            objCustomPricebook2.Product2Id = objProduct2.Id;
            objCustomPricebook2.UnitPrice = 555;
            lstCustomPricebookEntry.add(objCustomPricebook2);
        }
        
        for(Product2 objProduct2 : lstProductWashed){
            PricebookEntry objCustomPricebook2= new PricebookEntry();
            objCustomPricebook2.IsActive = true;
            objCustomPricebook2.Pricebook2Id = lstPricebook[0].Id;
            objCustomPricebook2.Product2Id = objProduct2.Id;
            objCustomPricebook2.UnitPrice = 555;
            lstCustomPricebookEntry.add(objCustomPricebook2);
        }
        
        insert lstCommerceEntitlementProduct;
        insert lstCustomPricebookEntry;
        List<PricebookEntry> lstDemo = [Select Id, Name, Pricebook2.Description From PricebookEntry];
        
    }
    @isTest
    public static void verifyRemoveExpiredProduct(){
        Product2 lstProductOne = [SELECT Id,SAP_Probability__c FROM Product2 WHERE StockKeepingUnit = '000000000000010325-0000000001-00012348'];
        System.assertEquals(99 , lstProductOne.SAP_Probability__c);
        
        Product2 lstProductTwo = [SELECT Id,SAP_Probability__c FROM Product2 WHERE StockKeepingUnit = '000000000000010325-0000000002-00012348'];
        System.assertEquals(99 , lstProductTwo.SAP_Probability__c);
        
        Product2 lstProductThree = [SELECT Id,SAP_Probability__c FROM Product2 WHERE StockKeepingUnit = '000000000000010325-0000000003-00012348'];
        System.assertEquals(99 , lstProductThree.SAP_Probability__c);
        
        Product2 lstProductFour = [SELECT Id,SAP_Probability__c FROM Product2 WHERE StockKeepingUnit = '000000000000010325-0000000004-00012348'];
        System.assertEquals(99 , lstProductFour.SAP_Probability__c);
        
        Product2 lstProductFive = [SELECT Id,SAP_Probability__c FROM Product2 WHERE StockKeepingUnit = '000000000000010325-0000000005-00012348'];
        System.assertEquals(99 , lstProductFive.SAP_Probability__c);
        
        Product2 lstProductSix = [SELECT Id,SAP_Probability__c FROM Product2 WHERE StockKeepingUnit = '000000000000010325-0000000006-00012348'];
        System.assertEquals(100 , lstProductSix.SAP_Probability__c);
        
        Test.startTest();  
        BatchToRemoveExpiredProduct batch = new BatchToRemoveExpiredProduct();
        Database.executeBatch(batch);
        Test.stopTest(); 
        
        Product2 lstProductOneAfterBatch = [SELECT Id,SAP_Probability__c FROM Product2 WHERE StockKeepingUnit = '000000000000010325-0000000001-00012348'];
        System.assertEquals(5 , lstProductOneAfterBatch.SAP_Probability__c);
        
        Product2 lstProductTwoAfterBatch = [SELECT Id,SAP_Probability__c FROM Product2 WHERE StockKeepingUnit = '000000000000010325-0000000002-00012348'];
        System.assertEquals(99 , lstProductTwoAfterBatch.SAP_Probability__c);
        
        Product2 lstProductThreeAfterBatch = [SELECT Id,SAP_Probability__c FROM Product2 WHERE StockKeepingUnit = '000000000000010325-0000000003-00012348'];
        System.assertEquals(5 , lstProductThreeAfterBatch.SAP_Probability__c);
        
        Product2 lstProductFourAfterBatch = [SELECT Id,SAP_Probability__c FROM Product2 WHERE StockKeepingUnit = '000000000000010325-0000000004-00012348'];
        System.assertEquals(99 , lstProductFourAfterBatch.SAP_Probability__c);
        
        Product2 lstProductFiveAfterBatch = [SELECT Id,SAP_Probability__c FROM Product2 WHERE StockKeepingUnit = '000000000000010325-0000000005-00012348'];
        System.assertEquals(5 , lstProductFiveAfterBatch.SAP_Probability__c);
        
        Product2 lstProductSixAfterBatch = [SELECT Id,SAP_Probability__c FROM Product2 WHERE StockKeepingUnit = '000000000000010325-0000000006-00012348'];
        System.assertEquals(99 , lstProductSixAfterBatch.SAP_Probability__c);      
    }
}