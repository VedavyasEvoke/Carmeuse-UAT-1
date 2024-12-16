global class ProductTriggerBatchOnUpdate implements Database.Batchable<sObject>,Database.Stateful {
    public List<String> errorList;
    Map<Id,Product2> mapProduct = new Map<Id,Product2>();
    public ProductTriggerBatchOnUpdate(Map<Id,Product2> oldMapProduct){
        errorList = new List<String>();
        mapProduct = oldMapProduct;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return DataBase.getQueryLocator([SELECT Id, StockKeepingUnit, SAP_Probability__c, Name, ProductCode, Plant_code__c FROM Product2 WHERE Id IN : mapProduct.keySet()]);
    }
    global void execute(Database.BatchableContext BC,List<Product2> lstProduct) {
        Set<Id> productAssignToExtended = new Set<Id>();
        Set<Id> productAssignToEP = new Set<Id>();
        Set<Id> productRemoveFromExtended = new Set<Id>();
        Set<Id> productRemoveFromEP = new Set<Id>();
        Set<Id> productAssignToEPVerify = new Set<Id>();
        
        Set<String> shipToSets = new Set<String>();
        Set<Id> setOfAccountId = new Set<Id>();
        
        Map<Id, Id> mapOfAccountWithEp = new Map<Id, Id>();
        Map<String,Id> mapofShipToWithEP = new Map<String,Id>();
        Set<String> extendedEntitlementProduct = new Set<String>();
        Set<Id> productIdAleradyAssignToEP = new Set<Id>();
        
        Set<String> setOfProductSKU = new Set<String>(); 
        Map<String, Id> mapShipToAccountId = new Map<String, Id>();
        
        Map<String,List<Product2>> mapShipToWithProduct2 = new Map<String,List<Product2>>();
        List<CommerceEntitlementProduct> lstCommerceEntitlementProductInsert = new List<CommerceEntitlementProduct>();
        List<ExtendedEntitlement__c> lstExtendedEntitlementInsert = new List<ExtendedEntitlement__c>();
        List<String> lstRemoveSKUFromExtended = new List<String>();
        
        
        for(Product2 objProduct : lstProduct){
            if(mapProduct.containsKey(objProduct.Id)){               
                Product2 product = mapProduct.get(objProduct.Id);
                if(product.SAP_Probability__c == 99 && objProduct.SAP_Probability__c == 1){
                    productRemoveFromEP.add(objProduct.Id);
                    productAssignToExtended.add(objProduct.Id);
                }
                if(product.SAP_Probability__c == 1 && objProduct.SAP_Probability__c == 99){
                    productRemoveFromExtended.add(objProduct.Id);
                    lstRemoveSKUFromExtended.add(objProduct.StockKeepingUnit);
                    productAssignToEP.add(objProduct.Id);
                }
                if((product.SAP_Probability__c == 99 || product.SAP_Probability__c == 100) && objProduct.SAP_Probability__c == 5){
                    productRemoveFromEP.add(objProduct.Id);
                }
                if((product.SAP_Probability__c == 1 || product.SAP_Probability__c == 100) && objProduct.SAP_Probability__c == 5){
                    productRemoveFromExtended.add(objProduct.Id);
                    lstRemoveSKUFromExtended.add(objProduct.StockKeepingUnit);
                }
                if(product.SAP_Probability__c != 1 && objProduct.SAP_Probability__c == 99){
                    productAssignToEP.add(objProduct.Id);
                }
                if(product.SAP_Probability__c != 99 && objProduct.SAP_Probability__c == 1){
                    productAssignToExtended.add(objProduct.Id);
                }
            }
        }
        /**Product Assign To Pricebook*/
        if(!productAssignToEP.isEmpty()){
            for(PricebookEntry objPBE : [Select Id,Quote_Number__c,UnitPrice,OriginationPlant__c,Product_SKU__c,Product2Id from PricebookEntry WHERE Product2Id  IN : productAssignToEP AND Pricebook2.Name !='Standard Price book']){
                if(objPBE.Product2Id != NULL){
                    productAssignToEPVerify.add(objPBE.Product2Id);
                }                 
            }
        }
        
        Map<Id,String> mapProductAssignToEPWithShipTo = new Map<Id,String>();
        if(!productAssignToExtended.isEmpty() || !productAssignToEPVerify.isEmpty() || !productRemoveFromExtended.isEmpty() || !productRemoveFromEP.isEmpty()){
            for(Product2 objProduct : [SELECT Id, StockKeepingUnit FROM Product2 WHERE Id IN : productAssignToExtended OR Id IN : productAssignToEPVerify OR Id IN : productRemoveFromExtended OR Id IN : productRemoveFromEP]){
                setOfProductSKU.add(objProduct.StockKeepingUnit);
                String[] SKU_Array = objProduct.StockKeepingUnit.split('-');
                if(SKU_Array.size() >= 3){
                    String shipTo = SKU_Array[1];
                    shipToSets.add(shipTo);
                    if(mapShipToWithProduct2.containsKey(shipTo)){
                        List<Product2> lstProduct2Map = mapShipToWithProduct2.get(shipTo);
                        lstProduct2Map.add(objProduct);
                        mapShipToWithProduct2.put(shipTo,lstProduct2Map);                    
                    }else{
                        List<Product2> lstProduct2Map = new  List<Product2>();
                        lstProduct2Map.add(objProduct);
                        mapShipToWithProduct2.put(shipTo,lstProduct2Map);           
                    } 
                    if(productAssignToEPVerify.contains(objProduct.Id)){
                        mapProductAssignToEPWithShipTo.put(objProduct.Id,shipTo);
                    }
                    
                }           
            }
        }
        
        if(!shipToSets.isEmpty()){
            for(Account objAccount : [SELECT Id, AccountExternalNumber__c FROM Account WHERE AccountExternalNumber__c IN : shipToSets]){
                mapShipToAccountId.put(objAccount.AccountExternalNumber__c,objAccount.Id);
                setOfAccountId.add(objAccount.Id);
            }
        }
        if(!setOfAccountId.isEmpty()){
            for(CommerceEntitlementPolicy objCommerceEntitlementPolicy : [SELECT Id, Account__c,Account__r.AccountExternalNumber__c,(SELECT Id, ProductId, PolicyId FROM CommerceEntitlementProducts) FROM CommerceEntitlementPolicy WHERE Account__c IN : setOfAccountId]){
                mapOfAccountWithEp.put(objCommerceEntitlementPolicy.Account__c,objCommerceEntitlementPolicy.Id);
                mapofShipToWithEP.put(objCommerceEntitlementPolicy.Account__r.AccountExternalNumber__c,objCommerceEntitlementPolicy.Id);
                for(CommerceEntitlementProduct objEPProduct : objCommerceEntitlementPolicy.CommerceEntitlementProducts){
                    productIdAleradyAssignToEP.add(objEPProduct.ProductId);
                }
            }
            for(ExtendedEntitlement__c objExtended : [SELECT Id,AccountExtendedEntitlement__c,MaterialNumber__c FROM ExtendedEntitlement__c WHERE AccountExtendedEntitlement__c IN : setOfAccountId]){
                extendedEntitlementProduct.add(objExtended.MaterialNumber__c);
            }
        }
        
        //***********ASSIGN PRODUCT TO ENTITLEMENT POLICY************
        if(!productAssignToEPVerify.isEmpty()){
            for (Id productId : productAssignToEPVerify) {
                if(!productIdAleradyAssignToEP.contains(productId)){
                    if(mapProductAssignToEPWithShipTo.containsKey(productId) && mapofShipToWithEP.containsKey(mapProductAssignToEPWithShipTo.get(productId))){
                        CommerceEntitlementProduct obj = new CommerceEntitlementProduct();
                        obj.PolicyId = mapofShipToWithEP.get(mapProductAssignToEPWithShipTo.get(productId));
                        obj.ProductId = productId;
                        lstCommerceEntitlementProductInsert.add(obj);
                    }
                }
            }
        }
        if(!lstCommerceEntitlementProductInsert.isEmpty()){
            Database.SaveResult[] saveRsltInsert = Database.insert(lstCommerceEntitlementProductInsert,false);
            for ( Database.SaveResult sr : saveRsltInsert ){
                if ( !sr.isSuccess() ){         
                    for( Database.Error err : sr.getErrors() ){
                        String strError = 'CommerceEntitlementProduct Error : '+ err.getMessage() + err.getFields();
                        errorList.add(strError);	
                    }
                }
            }  
        }
        
        //***************DELETE PRODUCT FORM ENTITELMENT POLICY**************************
        List<CommerceEntitlementProduct> lstCommerceEntitlementProductDelete = [SELECT Id FROM CommerceEntitlementProduct WHERE ProductID IN : productRemoveFromEP];
        if(!lstCommerceEntitlementProductDelete.isEmpty()){
            Database.DeleteResult[] saveRsltDelete = Database.Delete(lstCommerceEntitlementProductDelete,false);
            for( Database.DeleteResult sr : saveRsltDelete ){
                if ( !sr.isSuccess() ){         
                    for( Database.Error err : sr.getErrors() ){
                        String strError = 'CommerceEntitlementProduct Error : '+ err.getMessage() + err.getFields();
                        errorList.add(strError);	
                    }
                }    
            } 
        }
        
        //***************ADD PRODUCT TO EXTENDED ENTITELMENT POLICY**************************
        List<PricebookEntry> lstPriceBookEntry = [Select Id,Quote_Number__c,UnitPrice,OriginationPlant__c,Product_SKU__c from PricebookEntry WHERE Product2Id  IN : productAssignToExtended AND Pricebook2.Name !='Standard Price book'];
        if(!lstPriceBookEntry.isEmpty()){
            for(PricebookEntry objPricebookEntry : lstPriceBookEntry){
                if(!extendedEntitlementProduct.contains(objPricebookEntry.Product_SKU__c)){
                    ExtendedEntitlement__c objEEP = new ExtendedEntitlement__c();
                    objEEP.QuoteNumber__c = objPricebookEntry.Quote_Number__c;
                    objEEP.Price__c = objPricebookEntry.UnitPrice;
                    objEEP.Plant_Code__c = objPricebookEntry.OriginationPlant__c;
                    objEEP.MaterialNumber__c = objPricebookEntry.Product_SKU__c;
                    objEEP.Selected__c = true;
                    String[] SKU_Array = objPricebookEntry.Product_SKU__c.split('-');
                    if(SKU_Array.size() >= 3){
                        String externalShipTo = SKU_Array[1];
                        objEEp.AccountExternalNumber__c = externalShipTo;
                        objEEP.AccountExtendedEntitlement__c=mapShipToAccountId.get(externalShipTo);
                        objEEp.AccountNumber__c =externalShipTo.replaceFirst('^0+', '');
                    }
                    lstExtendedEntitlementInsert.add(objEEp);
                }
            }
            if(!lstExtendedEntitlementInsert.isEmpty()){
                Database.SaveResult[] saveRsltInsert = Database.insert(lstExtendedEntitlementInsert,false);
                for ( Database.SaveResult sr : saveRsltInsert ){
                    if ( !sr.isSuccess() ){         
                        for( Database.Error err : sr.getErrors() ){
                            String strError = 'ExtendedEntitlement Insert Error : '+ err.getMessage() + err.getFields();
                            errorList.add(strError);	
                        }
                    }
                }  
            }
        }
        
        //***************DELETE PRODUCT TO EXTENDED ENTITELMENT POLICY**************************
        if(!lstRemoveSKUFromExtended.isEmpty()){
            List<ExtendedEntitlement__c> lstExtendedEntitlementDelete = [SELECT Id FROM ExtendedEntitlement__c WHERE MaterialNumber__c IN : lstRemoveSKUFromExtended];
            if(!lstExtendedEntitlementDelete.isEmpty()){
                Database.DeleteResult[] saveRsltDelete = Database.Delete(lstExtendedEntitlementDelete,false);
                for( Database.DeleteResult sr : saveRsltDelete ){
                    if ( !sr.isSuccess() ){         
                        for( Database.Error err : sr.getErrors() ){
                            String strError = 'ExtendedEntitlement Delete Error : '+ err.getMessage() + err.getFields();
                            errorList.add(strError);	
                        }
                    }    
                } 
            }
        }   
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}