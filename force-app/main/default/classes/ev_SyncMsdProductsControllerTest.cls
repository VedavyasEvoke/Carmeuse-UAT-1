/**
* Class Name         : Ev_SAPRestCalloutTest
* Developer          : D Sridhar           
* Created Date       : 07-05-2024
* @description       : Test class for Ev_SAPRestCallout. 
* Last Modified Date : 
*/
@isTest
private class ev_SyncMsdProductsControllerTest {
    
    /**
* @description Tests the callout
*/
    @isTest
    static void testMakeMsdProductsCallout() {
        // Mock the HTTP response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status": "success"}');
        response.setStatusCode(200);
        
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(response));
        
        Test.startTest();
        ev_SyncMsdProductsController.handleMsdProductsCallout();
        Test.stopTest();
    }
    
    /**
* @description Generates mock HttpResponse
*/
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse mockResponse;
        
        /**
* @description constructor
* @param response - contains the mock response
*/
        public MockHttpResponseGenerator(HttpResponse response) {
            this.mockResponse = response;
        }
        
        /**
* @description returns the mock response
* @return mock response
*/
        public HttpResponse respond(HttpRequest req) {
            return mockResponse;
        }
    }
}