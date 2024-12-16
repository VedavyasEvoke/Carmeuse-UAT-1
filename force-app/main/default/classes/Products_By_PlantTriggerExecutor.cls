public class Products_By_PlantTriggerExecutor implements TriggerExecutor_I {
    public Schema.SObjectType getSObjectType() {
        return Products_By_Plant__c.SObjectType;
    }
    
    public void beforeInsert(List<Products_By_Plant__c> triggerNew) {
    }
    
    public void beforeUpdate(Map<Id, SObject> triggerOldMap, List<Products_By_Plant__c> triggerNew) {
    }
    
    public void beforeDelete(List<Products_By_Plant__c> triggerOld) {
    }
    
    public void afterInsert(List<Products_By_Plant__c> triggerNew) {
        upsertProductsWithPlants(triggerNew);
    }
    
    public void afterUpdate(Map<Id, SObject> triggerOldMap, List<Products_By_Plant__c> triggerNew) {
    }
    
    public void afterDelete(List<Products_By_Plant__c> triggerOld) {
    }
    
    public void upsertProductsWithPlants(List<Products_By_Plant__c> triggerNew) {
        List<String> productCodes = new List<String>();
        for(Products_By_Plant__c pbp : triggerNew) {
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
        for(Products_By_Plant__c pbp : triggerNew) {
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
}