/***************************************************************************************************************************************************
# Class Name  = ev_SAPRestCallout
# Author      = Sridhar Dumpala
# Description = This class is to integrate between Salesforce and Bhoomi for SAP Integration.

# Change Log :
============================================================================================================
Date                Changed By               Change                    Description
============================================================================================================
10/04/2024          Sridhar Dumpala          Original Version          
***************************************************************************************************************************************************/

public class ev_SAPRestCallout {
    static Ev_SBQQ_QuoteSelector ev_SBQQ_QuoteSelectorInstance = new Ev_SBQQ_QuoteSelector();
    
    /*
    * @description Prepares the Data Wrapper will later be used to send to Body while making a request to SAP
    */
    @AuraEnabled
    public static ResultWrapper prepareSAPCallout(String parameters) {
        Map<String,Object> parameterMap = (Map<String,Object>)JSON.deserializeUntyped(parameters);
        String quoteId = (String)parameterMap.get('quoteId');
        
        System.debug('quoteId==>'+quoteId);
        /* Constructing a data wrapper which will be sent in Body */
        Map<String, Object> dataWrapper = ev_RestWrapper.constructWrapper(quoteId);   //'a17QJ00000eKJq3YAG'
        String jsonBody = JSON.serializePretty(dataWrapper);
        System.debug('request==>'+jsonBody);
        
        List<String> fields = new List<String>{'Id', 'Business_Unit__c', 'SAP_ID__c', 'MSD_ID__c'};
        String filter = ' Id = \'' + String.escapeSingleQuotes(quoteId) + '\' '; 
        Map<String, Object> newParameterMap = new Map<String, Object>{'fields'=>fields, 'filter'=>filter};
        List<SBQQ__Quote__c> quotes = ev_SBQQ_QuoteSelectorInstance.getRecords(newParameterMap);
        
        ResultWrapper result = new ResultWrapper();
        if(quotes.size() == 1) {
            if(quotes[0].Business_Unit__c == 'Carmeuse') {
        		makeSAPCallout(jsonBody);
                result.externalSystem = 'SAP';
            } else {
        		makeMSDCallout(jsonBody);
                result.externalSystem = 'Dynamics';
            }
        }
        return result;
    }
    
    /*
    * @description Returns if the current Org is a Sandbox or Production Org
    * @return String
    */
    public static String getEnvironment() {
        return ((URL.getOrgDomainUrl().toExternalForm().contains('.sandbox.')) ? 'Sandbox' : 'Production');
    }
    
    /*
    * @description Sends a request to SAP
    */
    @future(callout=true)
    public static void makeSAPCallout(String body) {
        String environment = getEnvironment();
        Callout_Configuration__mdt cc = Callout_Configuration__mdt.getInstance('SAP_' + environment);
        
        /* Constructing a request to make a callout to SAP */
        HttpRequest request = new HttpRequest();
        request.setEndpoint(cc.Endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        //request.setHeader('Accept', 'application/json');
        request.setHeader('Ocp-Apim-Subscription-Key', cc.Access_Key__c);
        request.setBody(body);//.escapeHtml4()
        System.debug('body : ' + body);
        request.setTimeout(120000);
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        try {
        	response = http.send(request);
            System.debug('statuscode==> '+response.getStatusCode());
            if(response.getStatusCode() == 200) {
            	//Update Quote and Quote line dynamic Ids in respective records and also account dynamic id using list
        	}
        } catch (Exception e) {    
            System.debug('Exception==> '+e);       
        	throw new AuraHandledException('Send SF Quote Details to Bhoomi resulted in an error: '+ e.getMessage());    
        }
    }
    
    /*
    * @description Sends a request to Dynamics
    */
    @future(callout=true)
    public static void makeMSDCallout(String body) {
        String environment = getEnvironment();
        Callout_Configuration__mdt cc = Callout_Configuration__mdt.getInstance('MSD_' + environment);
        
        /* Constructing a request to make a callout to SAP */
        HttpRequest request = new HttpRequest();
        request.setEndpoint(cc.Endpoint__c);
        System.debug('cc.Endpoint__c : ' + cc.Endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        //request.setHeader('Accept', 'application/json');
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
    
    public class ResultWrapper {
        @AuraEnabled
        public String externalSystem;
    }
}