@isTest
public class ev_QuoteSupplyChainControllerTest {
    @isTest
    static void testGetQuotes() {
        // Create a test record
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            Freight_Request__c = true,
            Urgent__c = true 
            
        );
        insert testQuote;
        
        // Calling the method getquotes 
        Test.startTest();
        List<SBQQ__Quote__c> resultQuotes = ev_QuoteSupplyChainController.getquotes(testQuote.Id);
        Test.stopTest();
        
        // Verify that the result is not null and contains the expected data
        Assert.areNotEqual(null, resultQuotes, 'Resulting list should not be null');
        Assert.areEqual(1, resultQuotes.size(), 'Resulting list should contain one record');
        
        SBQQ__Quote__c resultQuote = resultQuotes[0];
        
        
        
        
        
        Assert.areEqual(true, resultQuote.Urgent__c, 'Urgent field should be true');
        
        
    }   
    @isTest
    static void testSavesupplychains() {
        //   input quotes list
        List<SBQQ__Quote__c> validQuotes = new List<SBQQ__Quote__c>();
        // Create test data for   quotes
        SBQQ__Quote__c quote = new SBQQ__Quote__c(Urgent__c=true,Currency__c='USD',CurrencyIsoCode='USD');
        insert quote;
        validQuotes.add(quote);

        Test.startTest();
        ev_QuoteSupplyChainController.savesupplychains(validQuotes);
       
        ev_QuoteSupplyChainController.savesupplychainandSendEmail(validQuotes,'recid');

        Test.stopTest();

        
       Assert.areEqual(validQuotes, [SELECT Id, Urgent__c, Currency__c,CurrencyIsoCode FROM SBQQ__Quote__c WHERE Id IN :validQuotes]);

        
    }
    @isTest
    static void testGetPicklistValues() {
        // Calling method getPicklistValues
        Test.startTest();
        Map<String, List<Map<String, String>>> picklistValuesMap = ev_QuoteSupplyChainController.getPicklistValues();
        Test.stopTest();
        
        // Verify that the result is not null
        System.assertNotEquals(null, picklistValuesMap);
        
        // Verify values for 'SE_Shipping_Condition__c' field
        List<Map<String, String>> shippingConditionValues = picklistValuesMap.get('SE_Shipping_Condition__c');
        System.assertNotEquals(null, shippingConditionValues);
        
        // Verify values for 'SE_Shipping_Type__c' field
        List<Map<String, String>> shippingTypeValues = picklistValuesMap.get('SE_Shipping_Type__c');
        System.assertNotEquals(null, shippingTypeValues);
        
        // Verify values for 'Per_ton_or_Flat__c' field
        List<Map<String, String>> perTonOrFlatValues = picklistValuesMap.get('Per_ton_or_Flat__c');
        System.assertNotEquals(null, perTonOrFlatValues);
        
     
          // Verify values for 'Currency__c' field
        List<Map<String, String>> currencyValuesISO = picklistValuesMap.get('CurrencyIsoCode');
        System.assertNotEquals(null, currencyValuesISO);
        
    }
}