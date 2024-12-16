@isTest
public class ev_createOrderinMSD_Test {

    // Mock class to simulate HTTP responses for token request
    private class TokenHttpCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            // Create a new HTTP response for token retrieval
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token": "mockAccessToken"}');  
            return res;
        }
    }

     
    private class OrderHttpCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"orderId": "mockOrderId", "status": "success"}');  
            return res;
        }
    }

    @isTest
    static void testSendQuote_Success() {
       
        Test.setMock(HttpCalloutMock.class, new TokenHttpCalloutMock());
           Test.setMock(HttpCalloutMock.class, new OrderHttpCalloutMock());

       
        Sbqq__Quote__c quote = new Sbqq__Quote__c(
            MSD_Quote_Number__c = '12345'
        );
        insert quote;
 
        Test.startTest();
        ev_createOrderinMSD.sendQuote(quote.Id);
        Test.stopTest();

        
        quote = [SELECT Msd_Order_Created_Response__c FROM Sbqq__Quote__c WHERE Id = :quote.Id];
        System.assertNotEquals(null, quote.Msd_Order_Created_Response__c, 'The response should not be null after sending the quote.');
    }

    @isTest
    static void testSendQuote_QuoteIdIsEmpty() {
        Test.startTest();
        try {
            ev_createOrderinMSD.sendQuote('');
            System.assert(false, 'Expected CustomException was not thrown.');
        } catch (ev_createOrderinMSD.CustomException e) {
            System.assertEquals('Quote ID cannot be null or empty.', e.getMessage());
        }
        Test.stopTest();
    }

 

    @isTest
    static void testSendQuote_EmptyMSDQuoteNumber() {
        Sbqq__Quote__c quote = new Sbqq__Quote__c(
            MSD_Quote_Number__c = null
        );
        insert quote;

        Test.startTest();
        try {
            ev_createOrderinMSD.sendQuote(quote.Id);
            System.assert(false, 'Expected CustomException was not thrown.');
        } catch (ev_createOrderinMSD.CustomException e) {
            System.assertEquals('MSD_Quote_Number__c cannot be null or empty.', e.getMessage());
        }
        Test.stopTest();
    }
}