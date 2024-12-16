/***************************************************************************************************************************************************
# Class Name  = ev_SyncMsdProductsController
# Author      = Sridhar Dumpala
# Description = This class is to integrate and sync MSD Products.

# Change Log :
============================================================================================================
Date                Changed By               Change                    Description
============================================================================================================
19/06/2024          Sridhar Dumpala          Original Version          
***************************************************************************************************************************************************/
public with sharing class ev_SyncMsdProductsController {
    /*
* @description Returns if the current Org is a Sandbox or Production Org.
* @return String
*/
    public static String getEnvironment() {
        return ((URL.getOrgDomainUrl().toExternalForm().contains('.sandbox.')) ? 'Sandbox' : 'Production');
    }
    
    /*
* @description Handles request to MSD for syncing Products
*/
    @AuraEnabled
    public static void handleMsdProductsCallout() {
        makeMsdProductsCallout();
    }
    
    /*
* @description Sends a request to MSD for syncing Products.
*/
    @future(callout = true)
    public static void makeMsdProductsCallout() {
        String environment = getEnvironment();
        Callout_Configuration__mdt cc = Callout_Configuration__mdt.getInstance('Sync_Msd_Products_Sandbox');
        
        /* Constructing a request to make a callout to SAP */
        HttpRequest request = new HttpRequest();
        request.setEndpoint(cc.Endpoint__c);
        request.setMethod('GET');
        request.setHeader('Ocp-Apim-Subscription-Key', cc.Access_Key__c);
        Http http = new Http();
        try {
        	HttpResponse response = http.send(request);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}