/**
* Class Name         : ev_AddPlantToProducts
* Developer          : D Sridhar           
* Created Date       : 21-06-2024
* @description       : Batch apex to update plants in products.
* Last Modified Date : 
*/
global class ev_AddPlantToProducts implements Database.Batchable<sObject> {
    
    /**
* @description Queries for records to run in batches.
* @param BC Batch context
* @return returns the queried records
*/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        /* Collect the batches of records or objects to be passed to execute. */
        String query = 'SELECT Id, ProductCode, Plant__c FROM Product2 WHERE CreatedDate = TODAY';
        return Database.getQueryLocator(query);
    }
    
    /**
* @description Add Plant codes to Product.
* @param BC - Batch context
* @param scope - Records for the Batch
*/
    global void execute(Database.BatchableContext BC, List<Product2> scope) {
        Map<String, Product2> productMap = new Map<String, Product2>();
        for(Product2 product : scope) {
            if(String.isNotBlank(product.ProductCode)) {
                productMap.put(product.ProductCode, product);
            }
        }
        
        try {
            for(Products_By_Plant__c pbp : [SELECT Id, Product_Code__c, Plant_Code__c FROM Products_By_Plant__c WHERE Plant_Code__c != null AND Product_Code__c IN :productMap.keySet()]) {
                String plants = productMap.get(pbp.Product_Code__c)?.Plant__c ?? '';
                productMap.get(pbp.Product_Code__c).Plant__c = plants + pbp.Plant_Code__c + ';';
            }
            List<Product2> products = productMap.values();
            Database.update(products);
        } catch(Exception e) {
            System.debug(e);
        }
    }   
    
    /**
* @description Execute any post-processing operations.
* @param BC - Batch context
*/
    global void finish(Database.BatchableContext BC) {}
}