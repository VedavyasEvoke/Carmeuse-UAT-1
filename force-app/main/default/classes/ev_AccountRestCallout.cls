/**
* Class Name         : ev_AccountRestCallout
* Developer          : D Sridhar           
* Created Date       : 15-05-2024
* @description       :  
* Last Modified Date : 
*/
public with sharing class ev_AccountRestCallout {
    /*
    * @description Prepares the Data Wrapper will later be used to send to Body while making a callout
    */
    @AuraEnabled
    public static void prepareForCallout(String parameters) {
        Map<String,Object> parameterMap = (Map<String,Object>)JSON.deserializeUntyped(parameters);
        String accountId = (String)parameterMap.get('accountId');
        
        /* Constructing a data wrapper which will be sent in Body */
        Map<String, Object> dataWrapper = ev_AccountRestCallout.constructWrapper(accountId);
        String jsonBody = JSON.serializePretty(dataWrapper);
        makeMSDCallout(jsonBody);
    }
    
    public static Map<String, Object> constructWrapper(String accountId) {
        Account a = Database.query('SELECT Name, Country_code__c,Tax_Liable__c, Legal_Name__c, ParentId, SAP_ID__c, MSD_ID__c, BillingAddress, BillingCity, BillingCountry, BillingState,BillingStreet, BillingPostalCode,MSD_Customer_Number__c '
                                   + ' FROM Account WHERE Id = \''
                                   + accountId + '\'');
        Map<String, Object> customerMap = new Map<String, Object>();
        customerMap.put('Tax Liable', a.Tax_Liable__c);
        customerMap.put('Address line1',a.BillingStreet);// a.BillingCity + ', ' + a.BillingState + ', ' + a.BillingCountry + ', ' + a.BillingPostalCode);
        customerMap.put('city', a.BillingCity);
        String country = a.Country_code__c ; // added Country_code__c in the place of BillingCountry
        
        customerMap.put('country', a.Country_code__c ); // added Country_code__c in the place of BillingCountry
        customerMap.put('state', a.BillingState);
        customerMap.put('postalcode', a.BillingPostalCode);
        customerMap.put('Customer_SF_ID', a.Id);
        customerMap.put('MSD ID', a.MSD_ID__c);
        customerMap.put('MSD Customer Number', a.MSD_Customer_Number__c);
        customerMap.put('SAP ID', a.SAP_ID__c);
        customerMap.put('ParentId', a.ParentId);
        customerMap.put('Legal_Name__c', a.Legal_Name__c);
        customerMap.put('Name', a.Name);
        
        return customerMap;
    }

    private String getCountryCode(String BillingCountry){ 
        String country =BillingCountry; 
        return country;
    }
    
    /*
    * @description Returns if the current Org is a Sandbox or Production Org
    * @return String
    */
    public static String getEnvironment() {
        return ((URL.getOrgDomainUrl().toExternalForm().contains('.sandbox.')) ? 'Sandbox' : 'Production');
    }
    
    @future(callout=true)
    public static void makeMSDCallout(String body) {
        String environment = getEnvironment();
        Callout_Configuration__mdt cc = Callout_Configuration__mdt.getInstance('Customer_MSD_' + environment);
        
        /* Constructing a request to make a callout to SAP */
        HttpRequest request = new HttpRequest();
        request.setEndpoint(cc.Endpoint__c);
        System.debug('cc.Endpoint__c : ' + cc.Endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setHeader('Ocp-Apim-Subscription-Key', cc.Access_Key__c);
        request.setBody(body);
        System.debug('body : ' + body);
        request.setTimeout(120000);
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        try {
            response = http.send(request);
            if(response.getStatusCode() == 200) {
                //Update Quote and Quote line dynamic Ids in respective records and also account dynamic id using list
            }
        } catch (Exception e) {           
            throw new AuraHandledException('Send SF Quote Details to Bhoomi resulted in an error: '+ e.getMessage());    
        }
    }
}