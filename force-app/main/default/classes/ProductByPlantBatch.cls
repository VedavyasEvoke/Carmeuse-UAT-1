global class ProductByPlantBatch implements Database.Batchable<sObject>{
   global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Name, Product_Code__c, Plant_Code__c, Status_Code__c, Code__c, Company_Code__c,'
            			+'Customer_Code__c, Ship_Point__c from Products_By_Plant__c ';
        return Database.getQueryLocator(query);
    }  
   global void execute(Database.BatchableContext BC, List<Products_By_Plant__c> scope)
    {
        List<String> productCodes = new List<String>();
        for(Products_By_Plant__c pbp : scope) {
            productCodes.add(pbp.Product_Code__c);
        }
        
        Map<String, List<String>> productPlantMap = new Map<String, List<String>>();
        Map<String, Product2> productCodeMap = new Map<String, Product2>();
        List<Product2> products = Database.query('SELECT Id, ProductCode, Plant__c FROM Product2 WHERE ProductCode IN (\'' + String.join(productCodes,'\',\'') + '\')');
        for(Product2 product : products) {
            productCodeMap.put(product.ProductCode, product);
            if(product.Plant__c!=null){
                for(String plant : product.Plant__c.split(';')) {
                List<String> plants = new List<String>();
                if(productPlantMap.containsKey(product.ProductCode)) {
                    plants = productPlantMap.get(product.ProductCode);
                }
                plants.add(plant);
                productPlantMap.put(product.ProductCode, plants);
            }
            }
        }
        List<Product2> upsertProducts = new List<Product2>();
        for(Products_By_Plant__c pbp : scope) {
            if(!productPlantMap.containsKey(pbp.Product_Code__c)) {
                Product2 product = new Product2();
            	product.Name = pbp.Product_Code__c;
            	product.ProductCode = pbp.Product_Code__c;
            	product.Plant__c = pbp.Plant_Code__c + ';';
                product.Is_Offline__c = true;
            	upsertProducts.add(product);
            } else if(!productPlantMap.get(pbp.Product_Code__c).contains(pbp.Plant_Code__c)) {
                System.debug(productCodeMap.get(pbp.Product_Code__c));
                Product2 product = productCodeMap.get(pbp.Product_Code__c);
                List<String> plants = product.Plant__c !=null ? product.Plant__c.split(';'): new List<String>();
                plants.add(pbp.Plant_Code__c);
                product.Plant__c = String.join(plants, ';');
            	upsertProducts.add(product);
            }
        }
        
        if(upsertProducts.size() > 0) {
            try {
                Database.upsert(upsertProducts);
            } catch(Exception e) {
                
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}