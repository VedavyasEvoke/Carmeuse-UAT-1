global without sharing class ev_QuoteSupplyChainController {
    @AuraEnabled(cacheable=true)
    /**
     * Retrieves supply chain quotes based on the provided record ID.
     * @param recordId The ID of the record.
     * @return List of supply chain quotes.
     */
    global static List<SBQQ__Quote__c> getquotes(string recordId){
        List<SBQQ__Quote__c> supplychainquote= [SELECT 
                                                Id, Freight_Request__c, Urgent__c, Freight_Ready_Supply_Chain__c, Freight_Approved_Supply__c, SE_Shipping_Condition__c,
                                                C3S_Description__c,Address__c,Receiving_days_and_Hours__c,SE_Shipping_Type__c,SE_Est_Total_Quantity__c,
                                                SE_Est_Quantity_Del__c,Valid_From__c, Valid_To__c, Description_Suply_Chain_Only__c, Primary_rate__c, Per_ton_or_Flat__c,
                                                Rate__c,Currency__c,CurrencyIsoCode, Carrier_Name__c, Min_Ton__c, Secondary_Rate__c, Secondary_Carrier_Name__c FROM   Sbqq__Quote__c
                                                where id=:recordId LIMIT 1]; 
        return supplychainquote;
    }
        /**
     * Saves supply chain quotes.
     * @param inputqts List of supply chain quotes to be saved.
     */
    @AuraEnabled
    global static void savesupplychains(List<SBQQ__Quote__c> inputqts) {
        try {
            if (inputqts != null && !inputqts.isEmpty()) {
                update inputqts;
            } else {
                throw new AuraHandledException('Input quotes list is null or empty.');
            }
        } catch (Exception e) {
            
            System.debug('Error in savesupplychains: ' + e.getMessage());
            throw new AuraHandledException('Error saving supply chains: ' + e.getMessage());
        }
    }
     /**
     * Saves supply chain quotes and sends email notifications to out side Salesforce Users.
     * @param inputqts List of supply chain quotes to be saved.
     * @param recid Record ID.
     */
    @AuraEnabled
    global static void savesupplychainandSendEmail(List<SBQQ__Quote__c> inputqts, string recid) {
        try {
            if (inputqts != null && !inputqts.isEmpty()) {
                update inputqts;
            } else {
                throw new AuraHandledException('Input quotes list is null or empty.');
            }
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            List<String> address = new List<String>{'vnallabothula@evoketechnologies.com','ssyed@evoketechnologies.com'};
                String baseURL = System.Label.Quote_Supply_Chain_URL;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Carmeuse Supply Chain Quote');
            mail.setPlainTextBody('Please Review and Submit the Supply Chain Details\n\n' + 
                      baseURL+ recid);

           // mail.setplaintextbody('https://carmeuse--crmuatfull.sandbox.my.salesforce-sites.com/supplychain?id='+recid);
            mail.setToAddresses(address);
            emailList.add(mail);
            System.debug('Mail'+emailList);
            
            if(!emailList.isEmpty()){
                Messaging.sendEmail(emailList);
            }	   
        } catch (Exception e) {
            
            System.debug('Error in savesupplychains: ' + e.getMessage());
            throw new AuraHandledException('Error saving supply chains: ' + e.getMessage());
        }
    }
     /**
     * Retrieves picklist values for certain fields.
     * @return Map of picklist field API names and their corresponding picklist values.
     */
    
    @AuraEnabled(cacheable=true)
    global static Map<String, List<Map<String, String>>> getPicklistValues() {
        Map<String, List<Map<String, String>>> picklistValuesMap = new Map<String, List<Map<String, String>>>();
        
        picklistValuesMap.put('SE_Shipping_Condition__c', getPicklistValuesForField('SBQQ__Quote__c', 'SE_Shipping_Condition__c'));
        picklistValuesMap.put('SE_Shipping_Type__c', getPicklistValuesForField('SBQQ__Quote__c', 'SE_Shipping_Type__c'));
        picklistValuesMap.put('Per_ton_or_Flat__c', getPicklistValuesForField('SBQQ__Quote__c', 'Per_ton_or_Flat__c'));
        picklistValuesMap.put('CurrencyIsoCode', getPicklistValuesForField('SBQQ__Quote__c', 'CurrencyIsoCode'));
        
        
        return picklistValuesMap;
    }
      /**
     * Retrieves picklist values for a specific field.
     * @param objectApiName API name of the object.
     * @param fieldApiName API name of the field.
     * @return List of picklist values as maps containing label and value.
     */
    global static List<Map<String, String>> getPicklistValuesForField(String objectApiName, String fieldApiName) {
        List<Schema.PicklistEntry> entries = Schema.getGlobalDescribe()
            .get(objectApiName)
            .getDescribe()
            .fields
            .getMap()
            .get(fieldApiName)
            .getDescribe()
            .getPicklistValues();
        
        List<Map<String, String>> values = new List<Map<String, String>>();
        
        for (Schema.PicklistEntry entry : entries) {
            Map<String, String> valueMap = new Map<String, String>();
            valueMap.put('label', entry.getLabel());
            valueMap.put('value', entry.getValue());
            values.add(valueMap);
        }
        
        return values;
    }
}