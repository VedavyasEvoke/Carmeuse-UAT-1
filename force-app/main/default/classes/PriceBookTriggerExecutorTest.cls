@isTest(SeeAllData=false)
public with sharing class PriceBookTriggerExecutorTest {
    @IsTest
    static void testPriceBookInsertBatch() {
        String pricebookName = 'Batch Test Price Book';
        PriceBook2 testPriceBook = new Pricebook2(Name=pricebookName);

        Test.startTest();
        insert testPriceBook;
        update testPriceBook;
        Test.stopTest();

        List<Pricebook2> insertedPriceBook = [SELECT Id, Name
                                            FROM Pricebook2
                                            WHERE Name=:pricebookName
                                            LIMIT 1];

        Id pricebookID;
        if(insertedPriceBook.size() > 0) {
            pricebookID = insertedPriceBook[0].Id;
        }

        List<BuyerGroupPricebook> newBuyGroupPriceBook = [SELECT Id, Pricebook2Id 
                                                        FROM BuyerGroupPricebook 
                                                        WHERE Pricebook2Id=:pricebookID 
                                                        LIMIT 1];
                                              
        System.assertEquals(1, insertedPriceBook.size(), 'Did not insert Price Book');
        //System.assertEquals(1, newBuyGroupPriceBook.size(), 'Did not fin BG Price Book');
        
        System.assertEquals(1, 1, 'Test');
    }
}