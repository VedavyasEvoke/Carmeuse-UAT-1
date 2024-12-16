public with sharing class ev_createOrderinMSD {
    private static Create_Order_in_MSD__mdt config;
       public static String getEnvironment() {
        return ((URL.getOrgDomainUrl().toExternalForm().contains('.sandbox.')) ? 'Sandbox' : 'Production');
    }
    static {
        String environment = getEnvironment();
        config = [SELECT API_URL__c, Client_ID__c, Client_Secret__c, Token_URL__c, Scope__c 
                  FROM Create_Order_in_MSD__mdt where Environment__c = : environment ];
    }

    @AuraEnabled
    public static void sendQuote(String quoteId) {
        System.debug('Starting sendQuote method...');

        if (String.isEmpty(quoteId)) {
            throw new CustomException('Quote ID cannot be null or empty.');
        }

        // Get the quote
        Sbqq__Quote__c quote = [SELECT Id, MSD_Quote_Number__c, Msd_Order_Created_Response__c 
                                 FROM Sbqq__Quote__c 
                                 WHERE Id = :quoteId LIMIT 1];
        
        if (quote == null) {
            throw new CustomException('No quote found for the given ID: ' + quoteId);
        }

        String quoteNumber = quote.MSD_Quote_Number__c;
        
        if (String.isEmpty(quoteNumber)) {
            throw new CustomException('MSD_Quote_Number__c cannot be null or empty.');
        }

        // Call the future method to process the quote asynchronously
        processQuoteAsync(quoteId, quoteNumber);
    }

    @future (callout=true)
    private static void processQuoteAsync(String quoteId, String quoteNumber) {
        System.debug('Starting processQuoteAsync method...');

        // Get access token
        String accessToken = getAccessToken();
        System.debug('Access Token Retrieved: ' + accessToken);

        // Set up the HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(config.API_URL__c);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setTimeout(120000);

        // Create the request body
        String body = JSON.serialize(new Map<String, String>{'quoteNo' => quoteNumber});
        req.setBody(body);
        
        System.debug('Request Endpoint: ' + req.getEndpoint());
        System.debug('Request Method: ' + req.getMethod());
        System.debug('Request Body: ' + body);

        // Send the request
        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('Response Status Code: ' + res.getStatusCode());
        System.debug('Response Body: ' + res.getBody());

        // Process response
        if (res.getStatusCode() == 200) {
            Sbqq__Quote__c quote = [SELECT Id, Msd_Order_Created_Response__c FROM Sbqq__Quote__c 
                                     WHERE Id = :quoteId LIMIT 1];
            if (quote != null) {
                quote.Msd_Order_Created_Response__c = res.getBody();
                update quote;
                System.debug('Quote successfully sent to Dynamics and updated.');
            }
        } else {
            throw new CustomException('Failed to send quote: ' + res.getBody());
        }
    }

  
    private static String getAccessToken() {
        System.debug('Starting getAccessToken method...');

        HttpRequest req = new HttpRequest();
        req.setEndpoint(config.Token_URL__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String body = 'grant_type=client_credentials' +
                      '&client_id=' + config.Client_ID__c +
                      '&client_secret=' + config.Client_Secret__c +
                      '&scope=' + config.Scope__c;
        req.setBody(body);

        System.debug('Access Token Request Body: ' + body);

        Http http = new Http();
        HttpResponse res = http.send(req);
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        System.debug('Access Token Response Status Code: ' + res.getStatusCode());
        System.debug('Access Token Response Body: ' + res.getBody());

        if (res.getStatusCode() != 200) {
            throw new CustomException('Failed to get access token: ' + response.get('error_description'));
        }

        return (String) response.get('access_token');
    }

    public class CustomException extends Exception {}
}