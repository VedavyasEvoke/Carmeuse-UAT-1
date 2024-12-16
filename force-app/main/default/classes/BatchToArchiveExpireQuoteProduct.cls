/************************************************************************************************************************************
Author : Priyanka Shinde
Description :Archive Product after quote is expire
----------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 		        DATE 		  AUTHOR 			DETAIL
-                                        -        Priyanka Shinde   Archive Product after quote is expire.
**************************************************************************************************************************************/
public class BatchToArchiveExpireQuoteProduct implements Database.Batchable<sObject>,Database.Stateful {
    public List<String> errorList;
    
    public BatchToArchiveExpireQuoteProduct(){
        errorList = new List<String>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext batchContext) {      
        return Database.getQueryLocator('SELECT Id, StockKeepingUnit, Valid_To__c, Valid_From__c FROM Product2 WHERE Valid_To__c < LAST_N_DAYS:30');
    }
    
    public void execute(Database.BatchableContext batchContext, List<Product2> lstProduct2) {
        Set<Id> productIds = new Set<Id>();
        List<CommerceEntitlementProduct> lstCommerceEntitlementProduct = new List<CommerceEntitlementProduct>();
        List<Product2> lstInactiveProduct2 = new List<Product2>();
        
        if(!lstProduct2.isEmpty()){
            for( Product2 objProduct2 : lstProduct2 ){
                if(objProduct2.Id != NULL){
                    productIds.add(objProduct2.Id);                 
                }                  
            }
        }
        if(!productIds.isEmpty()){
            for(CommerceEntitlementProduct objCEP : [SELECT Id, Name, PolicyId FROM CommerceEntitlementProduct WHERE ProductId IN : productIds]){
                lstCommerceEntitlementProduct.add(objCEP);
            }
            for(Product2 objProduct2 : [SELECT  Id,IsActive,Archive__c,StockKeepingUnit  FROM Product2 WHERE Id IN : productIds]){
                objProduct2.IsActive = false;
                objProduct2.Archive__c = true;
                objProduct2.StockKeepingUnit = NULL;
                lstInactiveProduct2.add(objProduct2);
            }
        }
         if(!lstCommerceEntitlementProduct.isEmpty()){
             delete lstCommerceEntitlementProduct;
         }
          if(!lstInactiveProduct2.isEmpty()){
             update lstInactiveProduct2;
         }
    } 
    
    public void finish(Database.BatchableContext batchContext){
        if( errorList.size() > 0 ){            
            for(String str : errorList) {
                system.debug(str);
            }            
        }
       
    }
}