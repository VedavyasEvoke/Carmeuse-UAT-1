public with sharing class QuoteLineController {
    
    // Method to retrieve Quote Lines
    @AuraEnabled(cacheable=true)
    public static List<SBQQ__QuoteLine__c> getQuoteLines(Id quoteId) {
        return [SELECT Id, 
                       SBQQ__Quantity__c, 
                       Primary__c, 
                       Incoterms__c, 
                       Destination__c, 
                       SE_Shipping_Type__c, 
                       Ship_To__c, 
                       Ship_To__r.Name
                FROM SBQQ__QuoteLine__c
                WHERE SBQQ__Quote__c = :quoteId];
    }

    // Method to get Picklist Values for SE_Shipping_Type__c and Incoterms__c
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> getPicklistValues() {
        Map<String, List<String>> picklistValues = new Map<String, List<String>>();
        
        // Get picklist values for SE_Shipping_Type__c
        picklistValues.put('SE_Shipping_Type__c', new List<String>());
        Schema.DescribeFieldResult describeField = SBQQ__QuoteLine__c.SObjectType.getDescribe().fields.getMap().get('SE_Shipping_Type__c').getDescribe();
        for (Schema.PicklistEntry picklistEntry : describeField.getPicklistValues()) {
            picklistValues.get('SE_Shipping_Type__c').add(picklistEntry.getLabel());
        }
        
        // Get picklist values for Incoterms__c
        picklistValues.put('Incoterms__c', new List<String>());
        describeField = SBQQ__QuoteLine__c.SObjectType.getDescribe().fields.getMap().get('Incoterms__c').getDescribe();
        for (Schema.PicklistEntry picklistEntry : describeField.getPicklistValues()) {
            picklistValues.get('Incoterms__c').add(picklistEntry.getLabel());
        }

        return picklistValues;
    }
}