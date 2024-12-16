@isTest(SeeAllData=true) 
public class CreatePricingHistoryTest {
    @isTest
    static void testHandleBeforeUpdate() {
        // Create test Quote
        Account acc = new Account();
        acc.Name = 'test Account';
        //acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Carmeuse').getRecordTypeId();
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test Opportunity';
        opp.AccountId = acc.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Carmeuse').getRecordTypeId();
        insert opp;
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote.SBQQ__Status__c = 'Accepted';
        testQuote.SBQQ__Opportunity2__c = opp.Id; 
        insert testQuote;
        
        
        Product2 product = new Product2();
        product.Name = 'Disposal Bag';
        insert product;
        // Create old Quote Line with all required fields set
        SBQQ__QuoteLine__c oldQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            ZCPR__c = 100,
            Commission__c = 10,
            Misc_Price__c = 50,
            Product_Price__c = 150,
            SBQQ__Product__c = product.Id
        );
        insert oldQuoteLine;
        
        // Query quote lines
        List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id, ZCPR__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :testQuote.Id];
        
        // Create a separate list to store updated quote lines
        List<SBQQ__QuoteLine__c> updatedQuoteLines = new List<SBQQ__QuoteLine__c>();
        
        // Iterate and update the quote lines
        for(SBQQ__QuoteLine__c quoteLine : quoteLineList){
            quoteLine.ZCPR__c = 200;
            quoteLine.ZMF1__c = 10;
            quoteLine.Commission__c = 20;
            quoteLine.Misc_Price__c = 10;
            quoteLine.PC_Discount__c = 5;
            quoteLine.Fees_Price__c = 10;
            quoteLine.SBQQ__Quantity__c = 10;
            quoteLine.Freight_Price__c = 10;
            quoteLine.Surcharge__c = 10;
            quoteLine.Plant__c = 'US-BL';
            quoteLine.Default_UOM__c = 'TON';
            quoteLine.Brand_Text__c =  'Text Brand';
            quoteLine.Custom_Text__c = 'custom text';
            quoteLine.ZSRT__c = 10;
            quoteLine.Output_Text__c = 'Product Name';
            quoteLine.SE_Shipping_Type__c = '11'; 
            quoteLine.Estimated_Qty_Delivery__c = 4;
            quoteLine.Primary__c = true;
            quoteLine.ZCO2__c = 10;
            quoteLine.ZMF7__c = 10;
            quoteLine.ZF1__c = 10;
            quoteLine.ZF3__c = 10;
            quoteLine.ZF6__c = 10;
            quoteLine.ZF7__c = 10;
            quoteLine.ZLRT__c = 10;
            quoteLine.ZMFS__c = 10;
            quoteLine.ZRMI__c = 10;
            quoteLine.ZSRM__c = 10;
            quoteLine.ZSTF__c = 10;
            quoteLine.ZSTT__c = 10;
            quoteLine.ZVFS__c = 10;
            quoteLine.ZF2__c = 10;
            quoteLine.ZF9__c = 10;
            quoteLine.ZAST__c = 10;
            quoteLine.ZF31__c = 10;
            quoteLine.ZREB__c = 10;
            quoteLine.ZF4__c = 10;
            quoteLine.ZRC__c = 10;
            quoteLine.ZRLC__c = 10;
            quoteLine.ZSPA__c = 10;
            quoteLine.ZF16__c = 10;
            quoteLine.ZMIS__c = 10;
            quoteLine.ZSVF__c = 10;
            quoteLine.ZF11__c = 10;
            quoteLine.ZF22__c = 10;
            quoteLine.ZDFR__c = 10;
            quoteLine.ZAD__c = 10;
            quoteLine.ZADN__c = 10;
            quoteLine.ZDAJ__c = 10;
            quoteLine.ZDIS__c = 10;
            quoteLine.ZDPR__c = 10;
            quoteLine.ZPCT__c = 10;
            quoteLine.ZPRO__c = 10;
            quoteLine.ZPLT__c = 10;
            quoteLine.ZF01__c = 10;
            quoteLine.ZMF2__c = 10;
            quoteLine.ZCWE__c = 10;
            quoteLine.ZMF6__c = 10;
            quoteLine.ZCPF__c = 10;
            quoteLine.ZSFF__c = 10;
            quoteLine.ZF5__c = 10;
            quoteLine.ZCO3__c = 10;
            quoteLine.ZDIP__c = 10;
            quoteLine.ZECO__c = 10;
            quoteLine.Product_Price__c = 10;
            quoteLine.MIN_LOAD_SIZE__c = 10;
            updatedQuoteLines.add(quoteLine);
        }
        
        system.assert(updatedQuoteLines !=null);
        // Call method
        Test.startTest();
        update updatedQuoteLines; // Update the new list
        Test.stopTest();
        
        // Verify results...
        // Add assertions here to validate the changes
    }
}