public with sharing class ProductTriggerExecutor implements TriggerExecutor_I {
    
    public Schema.SObjectType getSObjectType() {
        return Product2.SObjectType;
    }
    
    public void beforeInsert(List<Product2> triggerNew) {
    }
    
    public void beforeUpdate(Map<Id, SObject> triggerOldMap, List<Product2> triggerNew) {
    }
    
    public void beforeDelete(List<Product2> triggerOld) {
    }
    
    public void afterInsert(List<Product2> triggerNew) {
        List<Product2> productList = new List<Product2>();
        
        for(Product2 product : triggerNew) {
            // Evoke added a Is Offline boolean check so that this method will execute only for b2b Products.
            if(!product.Is_Offline__c) {
            	productList.add(product);
            }
        }
        
        if(productList.size() > 0) {
            Database.executebatch(new ProductTriggerBatch(productList));
        }
        
        //createProductsByPlant(new Map<Id,Product2>(), triggerNew);
    }
    
    public void afterUpdate(Map<Id,SObject> triggerOldMap, List<Product2> triggerNew) {
        Map<Id,Product2> oldMapProduct = new Map<Id,Product2>();
        for(Product2 objProduct : triggerNew) {
            if(!objProduct.Is_Offline__c && triggerOldMap.containsKey(objProduct.Id)){
                Product2 product = (Product2)triggerOldMap.get(objProduct.Id);
                if(objProduct.SAP_Probability__c != product.SAP_Probability__c){
                    oldMapProduct.put(objProduct.Id, product);
                }
            }
        }
        if(oldMapProduct.size() > 0) {
            Database.executebatch(new ProductTriggerBatchOnUpdate(oldMapProduct));
        }
        
        //createProductsByPlant(triggerOldMap, triggerNew);
    }
    
    public void afterDelete(List<Product2> triggerOld) {
        
    }
    
    /*public void createProductsByPlant(Map<Id, SObject> triggerOldMap, List<Product2> triggerNew) {
        List<Product2> filteredProducts = new List<Product2>();
        List<String> filters = new List<String>();
        for(Product2 product : triggerNew) {
            if(product.Plant__c != null && (!triggerOldMap.containsKey(product.Id) || product.Plant__c != (String)triggerOldMap.get(product.Id).get('Plant__c'))) {
                filteredProducts.add(product);
                filters.add(' Product_Code__c = \'' + product.ProductCode + '\' AND Plant_Code__c IN (\'' + product.Plant__c.replaceAll(';', '\', \'') + '\') ');
            }
        }
        
        Map<String, List<String>> productPlantMap = new Map<String, List<String>>();
        if(filters.size() > 0) {
            List<Products_By_Plant__c > pbps = Database.query('SELECT Id, Product_Code__c, Plant_Code__c FROM Products_By_Plant__c WHERE (' + String.join(filters, ') OR (') + ')');
            for(Products_By_Plant__c pbp : pbps) {
                List<String> plants = new List<String>();
                if(productPlantMap.containsKey(pbp.Product_Code__c)) {
                    plants = productPlantMap.get(pbp.Product_Code__c);
                }
                plants.add(pbp.Plant_Code__c);
                productPlantMap.put(pbp.Product_Code__c, plants);
            }
        }
        
        List<Products_By_Plant__c> newPbps = new List<Products_By_Plant__c>();
        for(Product2 product : filteredProducts) {
            List<String> plants = product.Plant__c.split(';');
            for(String plant : plants) {
                if(!(productPlantMap.containsKey(product.ProductCode) && productPlantMap.get(product.ProductCode).contains(plant))) {
                    Products_By_Plant__c pbp = new Products_By_Plant__c();
                    pbp.Product_Code__c = product.ProductCode;
                    pbp.Plant_Code__c = plant;
                    newPbps.add(pbp);
                }
            }
        }
        
        if(newPbps.size() > 0) {
            try {
                Database.insert(newPbps);
            } catch(Exception e) {
                
            }
        }
    }*/
}