/*Author : Priyanka Shinde
Description :Assign Product to Entitlement Policy which are created today.
----------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 	  DATE 		    AUTHOR 			  DETAIL
1             -                -          Priyanka Shinde   Assign Product to Entitlement Policy which are created today.
**************************************************************************************************************************************/
public class BatchToAssignProductToEntitlementPolicy implements Database.Batchable<sObject>,Database.Stateful {
    public List<String> errorList;
    
    public BatchToAssignProductToEntitlementPolicy(){
        errorList = new List<String>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext batchContext) {    
        // Evoke added Additional pricebooks(Carmeuse and Carmeuse Systems) in below query just to exclude those products.
        return Database.getQueryLocator('SELECT Id, Pricebook2Id, Product2Id, CreatedDate,Product_SKU__c,UnitPrice,OriginationPlant__c,Product2.SAP_Probability__c,Product2.Plant_code__c,Quote_Number__c FROM PricebookEntry WHERE CreatedDate = TODAY AND Pricebook2.Name != \'Standard Price Book\' AND Pricebook2.Name != \'Carmeuse\' AND PriceBook2.Name != \'Carmeuse Systems\''); //also exclude pb name carmeuse and carmeuse systems
    }
    
    public void execute(Database.BatchableContext batchContext, List<PricebookEntry> lstPricebookEntry) {
        Set<Id> productsId = new Set<Id>();
        Map<String,String> mapShipToPlant = new Map<String,String>();
        Map<String,Id> mapShipToAccountId = new Map<String,Id>();
        Set<Id> accountIds = new Set<Id>();
        Map<String,List<Product2>> mapShipToWithProducts = new Map<String,List<Product2>>();
        Set<String> shipToSets = new Set<String>();
        List<Product2> lstProduct2 = new List<Product2>();
        Set<Id> productIdAssignToEP = new Set<Id>();
        Map<String,Id> mapShipToWithEP = new Map<String,Id>();
        List<CommerceEntitlementProduct> lstCommerceEntitlementProduct = new List<CommerceEntitlementProduct>();
        
        Map<String,List<PricebookEntry>> mapShipToWithPricebookEntry = new Map<String,List<PricebookEntry>>();
        List<PricebookEntry> lstPricebookEntries = new List<PricebookEntry>();
        List<ExtendedEntitlement__c> lstExtendedEntitlement = new List<ExtendedEntitlement__c>();
        
        for(PricebookEntry objPricebookEntry : lstPricebookEntry){
            productsId.add(objPricebookEntry.Product2Id);
            if(objPricebookEntry.Product_SKU__c != NULL){
                String[] SKU_Array = objPricebookEntry.Product_SKU__c.split('-');
                if(SKU_Array.size() >= 3){
                    String shipTo = SKU_Array[1];
                    shipToSets.add(shipTo);
                    lstPricebookEntries.add(objPricebookEntry);
                    if(mapShipToWithPricebookEntry.containsKey(shipTo)){
                        List<PricebookEntry> lstPricebookEntryMap = mapShipToWithPricebookEntry.get(shipTo);
                        lstPricebookEntryMap.add(objPricebookEntry);
                        mapShipToWithPricebookEntry.put(shipTo,lstPricebookEntryMap);                    
                    }else{
                        List<PricebookEntry> lstPricebookEntryMap = new  List<PricebookEntry>();
                        lstPricebookEntryMap.add(objPricebookEntry);
                        mapShipToWithPricebookEntry.put(shipTo,lstPricebookEntryMap);           
                    }                       
                }  
            }
        } 
        if(!shipToSets.isEmpty()){
            for(Account objAccount : [SELECT Id,AccountExternalNumber__c FROM Account WHERE AccountExternalNumber__c IN : shipToSets]){
                mapShipToAccountId.put(objAccount.AccountExternalNumber__c,objAccount.Id);
                accountIds.add(objAccount.Id);
            }
        }
        Set<String> extendedEntitlementProduct = new Set<String>();
        if(!accountIds.isEmpty()){
            for(CommerceEntitlementPolicy objCommerceEntitlementPolicy : [SELECT Id, Account__c,Account__r.AccountExternalNumber__c,(SELECT Id, ProductId, PolicyId FROM CommerceEntitlementProducts) FROM CommerceEntitlementPolicy WHERE Account__c IN :accountIds]){
                mapShipToWithEP.put(objCommerceEntitlementPolicy.Account__r.AccountExternalNumber__c,objCommerceEntitlementPolicy.Id);
                for(CommerceEntitlementProduct objEPProduct : objCommerceEntitlementPolicy.CommerceEntitlementProducts){
                    productIdAssignToEP.add(objEPProduct.ProductId);
                }
            }
            for(ExtendedEntitlement__c objExtended : [SELECT Id,AccountExtendedEntitlement__c,MaterialNumber__c FROM ExtendedEntitlement__c WHERE AccountExtendedEntitlement__c IN :accountIds]){
                extendedEntitlementProduct.add(objExtended.MaterialNumber__c);
            }
        }
        
        for (String shipTo : mapShipToWithPricebookEntry.keySet()) {
            List<PricebookEntry> lstProductToAssignEP = mapShipToWithPricebookEntry.get(shipTo);
            for(PricebookEntry objPricebookEntry : lstProductToAssignEP){
                if(objPricebookEntry.Product2.SAP_Probability__c == 99 && !productIdAssignToEP.contains(objPricebookEntry.Product2Id)){
                    CommerceEntitlementProduct obj = new CommerceEntitlementProduct();
                    obj.PolicyId = mapShipToWithEP.get(shipTo);
                    obj.ProductId = objPricebookEntry.Product2Id;
                    lstCommerceEntitlementProduct.add(obj);
                }else{
                    if(objPricebookEntry.Product2.SAP_Probability__c == 1 && !extendedEntitlementProduct.contains(objPricebookEntry.Product_SKU__c)){
                        ExtendedEntitlement__c objEEP = new ExtendedEntitlement__c();
                        objEEP.QuoteNumber__c = objPricebookEntry.Quote_Number__c;
                        objEEP.Price__c = objPricebookEntry.UnitPrice;
                        objEEP.Plant_Code__c = objPricebookEntry.OriginationPlant__c;
                        objEEP.MaterialNumber__c = objPricebookEntry.Product_SKU__c;
                        objEEP.AccountExtendedEntitlement__c = mapShipToAccountId.get(shipTo);
                        String[] SKU_Array = objPricebookEntry.Product_SKU__c.split('-');
                        if(SKU_Array.size() >= 3){
                            String externalShipTo = SKU_Array[1];
                            objEEp.AccountExternalNumber__c = externalShipTo;
                            objEEp.AccountNumber__c =externalShipTo.replaceFirst('^0+', '');
                        }
                        lstExtendedEntitlement.add(objEEp);
                    }
                }                
            }
        }
        if(!lstCommerceEntitlementProduct.isEmpty()){
            Database.SaveResult[] srList = Database.insert(lstCommerceEntitlementProduct,false);
            for ( Database.SaveResult sr : srList ){
                if ( !sr.isSuccess() ){         
                    for( Database.Error err : sr.getErrors() ){
                        String strError = 'CommerceEntitlementProduct Error : '+ err.getMessage() + err.getFields();
                        errorList.add(strError);	
                    }
                }
            }   
        }
        if(!lstExtendedEntitlement.isEmpty()){
            Database.SaveResult[] srList = Database.insert(lstExtendedEntitlement,false);
            for ( Database.SaveResult sr : srList ){
                if ( !sr.isSuccess() ){         
                    for( Database.Error err : sr.getErrors() ){
                        String strError = 'Extended Entitlement Policy Error : '+ err.getMessage() + err.getFields();
                        errorList.add(strError);	
                    }
                }
            }   
        }
    }
    public void finish(Database.BatchableContext batchContext){
        if( errorList.size() > 0 ){            
            for(String str : errorList) {
                system.debug(str);
            }            
        }     
        if(!Test.isRunningTest()){
            reRunBatch();
        }
    }
    
    public void reRunBatch(){
        BatchToAssignProductToEntitlementPolicy EPBatch = new BatchToAssignProductToEntitlementPolicy();
        System.scheduleBatch(EPBatch, 'Run Batch BatchToAssignProductToEntitlementPolicy after every 1 hour'+System.now(), 60);
        
        //BatchToRebuildIndex rebuildBatch = new BatchToRebuildIndex();
        //System.scheduleBatch(rebuildBatch, 'Run Batch BatchToRebuildIndex 5 minutes after BatchToAssignProductToEntitlementPolicy batch '+System.now(), 65);
        
    }
}