public class BatchToRemoveExpiredProduct implements Database.Batchable < sObject >, Database.Stateful {
    private List<Product2> lstProductsToUpdate = new List<Product2>();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Name, PolicyId, Policy.Account__r.Name, ProductId, Product.Name, Product.ProductCode, Product.Plant_Code__c, Product.Shipping_Condition__c, Product.Ship__c, Product.Valid_To__c, Product.Valid_From__c, Product.SAP_Probability__c FROM CommerceEntitlementProduct]);
    }
    //This batch is used to remove products that are expired
    public void execute(Database.BatchableContext bc, List<CommerceEntitlementProduct> lstCommerceEntitlementProduct) {
        Map<Id, List<CommerceEntitlementProduct>> mapOfEPAndExpiredProduct = new Map<Id, List<CommerceEntitlementProduct>>();
        Set<Id> setUniqueProduct = new Set<Id>();
        Set<Id> setOfDuplicateProduct = new Set<Id>();
        List<Product2> lstProductToRemove = new List<Product2>();
        List<Product2> lstProductToAssign = new List<Product2>();
        Map<String, List<CommerceEntitlementProduct>> mapOfAccountNameAndProduct = new Map<String, List<CommerceEntitlementProduct>>();
        
        for (CommerceEntitlementProduct obj: lstCommerceEntitlementProduct) {
            List<CommerceEntitlementProduct> listExpiredProduct =  mapOfEPAndExpiredProduct.containsKey(obj.PolicyId) ? mapOfEPAndExpiredProduct.get(obj.PolicyId) : new List<CommerceEntitlementProduct>();
            listExpiredProduct.add(obj);
            mapOfEPAndExpiredProduct.put(obj.PolicyId, listExpiredProduct);
        }
        
        for(CommerceEntitlementProduct objComparePolicyProduct : lstCommerceEntitlementProduct ){
            setUniqueProduct.add(objComparePolicyProduct.ProductId);        
            for (CommerceEntitlementProduct objExpiredPolicyProduct: mapOfEPAndExpiredProduct.get(objComparePolicyProduct.PolicyId)) {      
                if (objExpiredPolicyProduct.ProductId != objComparePolicyProduct.ProductId && 
                    objExpiredPolicyProduct.Product.Name == objComparePolicyProduct.Product.Name && 
                    objExpiredPolicyProduct.Product.ProductCode == objComparePolicyProduct.Product.ProductCode && 
                    objExpiredPolicyProduct.Product.Plant_Code__c == objComparePolicyProduct.Product.Plant_Code__c &&
                    objExpiredPolicyProduct.Product.Shipping_Condition__c == objComparePolicyProduct.Product.Shipping_Condition__c && 
                    objExpiredPolicyProduct.Product.Ship__c == objComparePolicyProduct.Product.Ship__c && 
                    objExpiredPolicyProduct.Product.Valid_To__c < objComparePolicyProduct.Product.Valid_From__c) {
                        
                        setOfDuplicateProduct.add(objComparePolicyProduct.ProductId); 
                        setOfDuplicateProduct.add(objExpiredPolicyProduct.ProductId); 
                        
                        if(!lstProductToRemove.contains(objExpiredPolicyProduct.Product)){
                            objExpiredPolicyProduct.Product.SAP_Probability__c = 5;
                            lstProductToRemove.add(objExpiredPolicyProduct.Product);
                        }
                    } 
            }
        }
        setUniqueProduct.removeAll(setOfDuplicateProduct);  
        
        for(CommerceEntitlementProduct objProduct : [SELECT Id, PolicyId, Policy.Account__r.Name, ProductId, Product.Name, Product.ProductCode, Product.Plant_Code__c, Product.Shipping_Condition__c, Product.Ship__c, Product.Valid_To__c, Product.Valid_From__c, Product.SAP_Probability__c FROM CommerceEntitlementProduct WHERE ProductId IN : setUniqueProduct]){
            String accountName = objProduct.Policy.Account__r.Name;
            if (!mapOfAccountNameAndProduct.containsKey(accountName)) {     
                mapOfAccountNameAndProduct.put(accountName, new List<CommerceEntitlementProduct>());
            }  
            mapOfAccountNameAndProduct.get(accountName).add(objProduct);
        }
        
        for(PricebookEntry objPricebookEntry : [SELECT Id, Product2Id, Pricebook2.Description, Product2.Name, Product2.ProductCode, Product2.Plant_Code__c, Product2.Shipping_Condition__c, Product2.Ship__c, Product2.Valid_To__c, Product2.Valid_From__c, Product2.SAP_Probability__c  FROM PricebookEntry WHERE Pricebook2.Description IN : mapOfAccountNameAndProduct.KeySet() AND Pricebook2.Name !='Standard Price book']){
            for(CommerceEntitlementProduct objExpiredProduct : mapOfAccountNameAndProduct.get(objPricebookEntry.Pricebook2.Description)){
                
                if(objExpiredProduct.ProductId != objPricebookEntry.Product2Id && 
                   objExpiredProduct.Product.Name == objPricebookEntry.Product2.Name &&
                   objExpiredProduct.Product.ProductCode == objPricebookEntry.Product2.ProductCode && 
                   objExpiredProduct.Product.Plant_Code__c == objPricebookEntry.Product2.Plant_Code__c &&
                   objExpiredProduct.Product.Shipping_Condition__c == objPricebookEntry.Product2.Shipping_Condition__c && 
                   objExpiredProduct.Product.Ship__c == objPricebookEntry.Product2.Ship__c && 
                   objExpiredProduct.Product.Valid_To__c < objPricebookEntry.Product2.Valid_From__c ){
                       
                       Product2 objAssignProduct = new Product2();
                       objAssignProduct.Id = objPricebookEntry.Product2Id;
                       objAssignProduct.SAP_Probability__c = 99;
                       
                       if(!lstProductToAssign.contains(objAssignProduct)){
                           lstProductToAssign.add(objAssignProduct);
                       }
                       if(!lstProductToRemove.contains(objExpiredProduct.Product)){
                           objExpiredProduct.Product.SAP_Probability__c = 5;
                           lstProductToRemove.add(objExpiredProduct.Product);
                       }
                   }
            }
        }
        this.lstProductsToUpdate.addAll(lstProductToAssign);
        this.lstProductsToUpdate.addAll(lstProductToRemove);
    }
    public void finish(Database.BatchableContext batchContext) { 
        if(!this.lstProductsToUpdate.isEmpty()){
            Database.SaveResult[] srList = Database.update(this.lstProductsToUpdate,false);
            for ( Database.SaveResult sr : srList ){
                if ( !sr.isSuccess() ){         
                    for( Database.Error err : sr.getErrors() ){
                        System.debug('Save Result: '+ err.getMessage() + err.getFields());
                    }
                }
            }   
        }
    }
}