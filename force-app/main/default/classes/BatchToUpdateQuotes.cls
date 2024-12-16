/************************************************************************************************************************************
Author : Priyanka Shinde
Description :Order Delivery Group object's Quote Number filed should get updated for extended PriceBook Entry.
----------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 	  DATE 		   AUTHOR 			 DETAIL
1           CARMEUSE-19      20/04/2022    Priyanka Shinde   Order Delivery Group Quote Number should get updated for extended PriceBook Entry.
**************************************************************************************************************************************/

public class BatchToUpdateQuotes implements Database.Batchable<sObject>,Database.Stateful {
    public List<String> errorList;
    
    public BatchToUpdateQuotes(){
        errorList = new List<String>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext batchContext) {  
        if(Test.isRunningTest()){
            return Database.getQueryLocator('SELECT Id,QuoteNumber__c,PONumber__c,Order.AccountId,ShipmentStatus__c,DesiredDeliveryDate,MaterialNumber__c,(SELECT Product2Id,Product2.Name,Product2.ProductCode,Product2.Plant_code__c,Product2.Ship__c,Product2.Shipping_Condition__c,Product2.Carrier__c FROM OrderItems) FROM OrderDeliveryGroup WHERE ShipmentStatus__c = \'Submitted\' AND QuoteNumber__c = NULL LIMIT 100');
        }else{
            return Database.getQueryLocator('SELECT Id,QuoteNumber__c,PONumber__c,Order.AccountId,ShipmentStatus__c,DesiredDeliveryDate,MaterialNumber__c,(SELECT Product2Id,Product2.Name,Product2.ProductCode,Product2.Plant_code__c,Product2.Ship__c,Product2.Shipping_Condition__c,Product2.Carrier__c FROM OrderItems) FROM OrderDeliveryGroup WHERE ShipmentStatus__c = \'Submitted\' AND QuoteNumber__c = NULL');
        }
    }
    
    public void execute(Database.BatchableContext batchContext, List<OrderDeliveryGroup> lstOrderDeliveryGroup) {
        Map<Id,Id> mapAccountIdWithBuyerGroupId = new Map<Id,Id>();
        Map<Id,Set<Id>> mapBuyerGroupIdWithBuyerPriceBookId = new Map<Id,Set<Id>>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> buyerGroupMemberIds = new Set<Id>();
        Set<Id> pricebook2Ids = new Set<Id>();        
        Map<Id,List<PricebookEntry>> mapPriceBookIdWithPricebookEntry = new Map<Id,List<PricebookEntry>>();
        List<OrderDeliveryGroup> lstOrderDeliveryGroupUpdate = new List<OrderDeliveryGroup>();
        if(!lstOrderDeliveryGroup.isEmpty()){
            for( OrderDeliveryGroup objOrderDeliveryGroup : lstOrderDeliveryGroup ){
                if(objOrderDeliveryGroup.Order.AccountId != NULL){
                    accountIds.add(objOrderDeliveryGroup.Order.AccountId);                 
                }                  
            }
        }
        if(!accountIds.isEmpty()){
            for(BuyerGroupMember buyerGroupMemberObj :  [SELECT BuyerId,BuyerGroupId FROM BuyerGroupMember WHERE BuyerId IN :accountIds] ){
                mapAccountIdWithBuyerGroupId.put(buyerGroupMemberObj.BuyerId,buyerGroupMemberObj.BuyerGroupId);
                buyerGroupMemberIds.add(buyerGroupMemberObj.BuyerGroupId);
            }
        }
        if(!buyerGroupMemberIds.isEmpty()){
            for(BuyerGroupPricebook buyerGroupPricebookObj :  [SELECT BuyerGroupId,Pricebook2Id FROM BuyerGroupPricebook WHERE BuyerGroupId IN :buyerGroupMemberIds AND IsActive = TRUE] ){
                if(mapBuyerGroupIdWithBuyerPriceBookId.containsKey(buyerGroupPricebookObj.BuyerGroupId)){
                    Set<Id> setPricebook2Ids = mapBuyerGroupIdWithBuyerPriceBookId.get(buyerGroupPricebookObj.BuyerGroupId);
                    setPricebook2Ids.add(buyerGroupPricebookObj.Pricebook2Id);
                    mapBuyerGroupIdWithBuyerPriceBookId.put(buyerGroupPricebookObj.BuyerGroupId,setPricebook2Ids);                    
                }else{
                    Set<Id> setPricebook2Ids = new Set<Id>();
                    setPricebook2Ids.add(buyerGroupPricebookObj.Pricebook2Id);
                    mapBuyerGroupIdWithBuyerPriceBookId.put(buyerGroupPricebookObj.BuyerGroupId,setPricebook2Ids);                    
                }
                pricebook2Ids.add(buyerGroupPricebookObj.Pricebook2Id);
            }
        }
        if(!pricebook2Ids.isEmpty()){
            for(PricebookEntry objPricebookEntry :  [SELECT Id,Pricebook2Id,Product2Id,Quote_Number__c,ValidFrom__c, ValidTo__c,PO_Number__c,Product2.Name,Product2.ProductCode,Product_SKU__c,Product2.Plant_code__c,Product2.Ship__c,Product2.Shipping_Condition__c,Product2.Carrier__c FROM PricebookEntry WHERE Pricebook2Id IN :pricebook2Ids AND IsActive = TRUE] ){
                if(mapPriceBookIdWithPricebookEntry.containsKey(objPricebookEntry.Pricebook2Id)){
                    List<PricebookEntry> lstPricebookEntry = mapPriceBookIdWithPricebookEntry.get(objPricebookEntry.Pricebook2Id);
                    lstPricebookEntry.add(objPricebookEntry);
                    mapPriceBookIdWithPricebookEntry.put(objPricebookEntry.Pricebook2Id,lstPricebookEntry);
                }else{
                    List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
                    lstPricebookEntry.add(objPricebookEntry);
                    mapPriceBookIdWithPricebookEntry.put(objPricebookEntry.Pricebook2Id,lstPricebookEntry);
                }              
            }
        }
        if(!lstOrderDeliveryGroup.isEmpty()){
            for( OrderDeliveryGroup objOrderDeliveryGroup : lstOrderDeliveryGroup ){
                if(objOrderDeliveryGroup.Order.AccountId != NULL){
                    if(mapAccountIdWithBuyerGroupId.containsKey(objOrderDeliveryGroup.Order.AccountId)){
                        if(mapBuyerGroupIdWithBuyerPriceBookId.containsKey(mapAccountIdWithBuyerGroupId.get(objOrderDeliveryGroup.Order.AccountId))){
                            Set<Id> setPBIds = mapBuyerGroupIdWithBuyerPriceBookId.get(mapAccountIdWithBuyerGroupId.get(objOrderDeliveryGroup.Order.AccountId));
                            for(Id priceBookIds : setPBIds){
                                if(mapPriceBookIdWithPricebookEntry.containsKey(priceBookIds)){
                                    List<PricebookEntry> lstPricebookEntry = mapPriceBookIdWithPricebookEntry.get(priceBookIds);
                                    for (PricebookEntry entry : lstPricebookEntry) { 
                                        for(OrderItem objOrderItem : objOrderDeliveryGroup.OrderItems){
                                            if(entry.Product2Id == objOrderItem.Product2Id){      
                                                if(Date.valueOf(objOrderDeliveryGroup.DesiredDeliveryDate) <=  Date.valueOf(entry.ValidTo__c) &&  Date.valueOf(objOrderDeliveryGroup.DesiredDeliveryDate) >=  Date.valueOf(entry.ValidFrom__c)) {
                                                    objOrderDeliveryGroup.QuoteNumber__c = entry.Quote_Number__c;                                                 
                                                }
                                            }
                                            if(entry.Product2.Name == objOrderItem.Product2.Name && entry.Product2.ProductCode == objOrderItem.Product2.ProductCode && entry.Product2.Plant_code__c == objOrderItem.Product2.Plant_code__c && entry.Product2.Ship__c == objOrderItem.Product2.Ship__c && entry.Product2.Shipping_Condition__c == objOrderItem.Product2.Shipping_Condition__c && entry.Product2.Carrier__c == objOrderItem.Product2.Carrier__c){  
                                                if( Date.valueOf(objOrderDeliveryGroup.DesiredDeliveryDate) <=  Date.valueOf(entry.ValidTo__c) &&  Date.valueOf(objOrderDeliveryGroup.DesiredDeliveryDate) >=  Date.valueOf(entry.ValidFrom__c)) {
                                                    objOrderDeliveryGroup.QuoteNumber__c = entry.Quote_Number__c;
                                                    if(objOrderDeliveryGroup.MaterialNumber__c != entry.Product_SKU__c){
                                                        objOrderDeliveryGroup.MaterialNumber__c = entry.Product_SKU__c;
                                                    }
                                                    /*if(objOrderDeliveryGroup.PONumber__c != entry.PO_Number__c){
                                                        objOrderDeliveryGroup.PONumber__c = entry.PO_Number__c;
                                                    }*/
                                                }
                                            }                                          
                                        }                                   
                                    }
                                }     
                            }                                                
                            lstOrderDeliveryGroupUpdate.add(objOrderDeliveryGroup);                            
                        }  
                    }
                }                  
            }
        }
        if(!lstOrderDeliveryGroupUpdate.isEmpty()){
            Database.SaveResult[] srList = Database.update(lstOrderDeliveryGroupUpdate,false);
            for ( Database.SaveResult sr : srList ){
                if ( !sr.isSuccess() ){         
                    for( Database.Error err : sr.getErrors() ){
                        String strError = 'OrderDeliveryGroup Error : '+ err.getMessage() + err.getFields();
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
        BatchToUpdateQuotes batch = new BatchToUpdateQuotes();
   		System.scheduleBatch(batch, 'Run Batch BatchToUpdateQuotes after every 2 Hours'+System.now(), 15);
    }
}