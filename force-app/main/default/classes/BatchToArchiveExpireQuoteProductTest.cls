/************************************************************************************************************************************
Author : Priyanka Shinde
Description :Test method for Batch to Archive Product after quote is expire
----------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 	  DATE 		   AUTHOR 			 DETAIL
1                                                     Test method for Batch to Archive Product after quote is expire.
**************************************************************************************************************************************/

@isTest	
public class BatchToArchiveExpireQuoteProductTest {
    @IsTest
    static void verifyBatchToUpdateQuotes(){   
        TriggerConfiguration.setDoNotRunTrigger(); 
        List<Product2> lstProduct2 = new List<Product2>();
        Product2 testProduct_1 = new Product2(Name = 'HiCal QL Pulv W/Flo Aid Bulk',
                                              Family = 'Lime', MaterialNumber__c = '000000000000010325', ProductCode = '10325',Valid_From__c=Date.today()-50,Valid_To__c=Date.today()-35);
        lstProduct2.add(testProduct_1);
        
        Product2 testProduct_2 = new Product2(Name = 'HiCal QL Bulk',
                                              Family = 'Lime', MaterialNumber__c = '000000000000010324', ProductCode = '10324',Valid_From__c=Date.today()-50,Valid_To__c=Date.today()-35);
        lstProduct2.add(testProduct_2);        
        insert lstProduct2;
        
        CommerceEntitlementPolicy cep = new CommerceEntitlementPolicy(Name = 'Test Policy', IsActive = true, CanViewProduct = true);
        insert cep;        
        CommerceEntitlementProduct ceprd = new CommerceEntitlementProduct(PolicyId = cep.Id, ProductId = lstProduct2[0].Id);
        insert ceprd;
        
        Test.startTest();
        
        BatchToArchiveExpireQuoteProduct objBatchToArchiveQuote = new BatchToArchiveExpireQuoteProduct();
        DataBase.executeBatch(objBatchToArchiveQuote);
        
        Test.stopTest(); 
    }
    @IsTest
    static void verifyBatchToUpdateQuotesNegative(){   
        TriggerConfiguration.setDoNotRunTrigger();    
        Test.startTest();        
        BatchToArchiveExpireQuoteProduct objBatchToArchiveQuote = new BatchToArchiveExpireQuoteProduct();
        objBatchToArchiveQuote.errorList.add('ERROR');
        DataBase.executeBatch(objBatchToArchiveQuote);        
        Test.stopTest(); 
    }
}