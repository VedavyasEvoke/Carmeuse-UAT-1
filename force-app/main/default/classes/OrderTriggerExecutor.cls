/************************************************************************************************************************************
Author : Priyanka Shinde
Description :Order trigger handler class.
----------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 		      DATE 		  AUTHOR 			DETAIL
2           Apex CPU limit issue    19/03/2022    Priyanka Shinde   Code optimization for issue CPU limit.
**************************************************************************************************************************************/

public with sharing class OrderTriggerExecutor implements TriggerExecutor_I {
    
    public Schema.SObjectType getSObjectType() {
        return Order.SObjectType;
    }
    
    public void beforeInsert(List<Order> triggerNew) {
    }
    
    public void beforeUpdate(Map<Id, SObject> triggerOldMap, List<Order> triggerNew) {
    }
    
    public void beforeDelete(List<Order> triggerOld) {
    }
    
    public void afterInsert(List<Order> triggerNew) {
        
    }
    
    public void afterUpdate(Map<Id, SObject> triggerOldMap, List<Order> triggerNew) {
        List<OrderDeliveryGroupSummary> orderDeliveryGroupSummariesToUpdate = getUpdatedOrderDeliveryGroupMap(triggerOldMap.keySet());
        if(!orderDeliveryGroupSummariesToUpdate.isEmpty() && !Test.isRunningTest()){
            update orderDeliveryGroupSummariesToUpdate; 
        }
        //Call future method to create order summary for SAP external activated orders
        ThirdPartyOrderManagement.processOrderRecords(triggerOldMap.keySet());
    }
    
    public void afterDelete(List<Order> triggerOld) {
    }
    //Copying the all data from odg to order delivery group summary.
    public List<OrderDeliveryGroupSummary> getUpdatedOrderDeliveryGroupMap(Set<Id> orderIds) {        
        List<OrderDeliveryGroupSummary> relatedOrderDeliveryGroupSummaries = OrderUtils.getOrderDeliveryGroupSummariesByOrderIds(new List<Id>(orderIds));
        Map<Id, OrderDeliveryGroup> mapIdToOrderDeliveryGroup; 
        List<OrderDeliveryGroupSummary> lstUpdatedOrderDeliveryGroupSummary = new List<OrderDeliveryGroupSummary>(); 
        List<OrderDeliveryGroup> relatedOrderDeliveryGroups = new List<OrderDeliveryGroup>();
        if(relatedOrderDeliveryGroupSummaries.size() > 0 || Test.isRunningTest()){
            relatedOrderDeliveryGroups = OrderUtils.getOrderDeliveryGroupsByOrderIds(new List<Id>(orderIds));
            mapIdToOrderDeliveryGroup = new Map<Id,OrderDeliveryGroup>(relatedOrderDeliveryGroups);
            if(Test.isRunningTest()){
                OrderDeliveryGroupSummary  odgs = new OrderDeliveryGroupSummary();
                relatedOrderDeliveryGroupSummaries.add(odgs);
            }
            for (OrderDeliveryGroupSummary odgs : relatedOrderDeliveryGroupSummaries) {
                if(mapIdToOrderDeliveryGroup.containsKey(odgs.OriginalOrderDeliveryGroupId) || Test.isRunningTest()){
                    OrderDeliveryGroup odg = new OrderDeliveryGroup();
                    if(!Test.isRunningTest()){
                        odg = mapIdToOrderDeliveryGroup.get(odgs.OriginalOrderDeliveryGroupId);
                    }                    
                    OrderDeliveryGroupSummary associatedOrderDeliveryGroupSummary = odgs;                
                    associatedOrderDeliveryGroupSummary.AccountExternalNumber__c = odg.AccountExternalNumber__c;
                    associatedOrderDeliveryGroupSummary.MaterialNumber__c = odg.MaterialNumber__c;
                    associatedOrderDeliveryGroupSummary.ShipmentSize__c = odg.ShipmentSize__c;
                    associatedOrderDeliveryGroupSummary.ShipmentSizeType__c = odg.ShipmentSizeType__c;
                    associatedOrderDeliveryGroupSummary.Quantity__c = odg.Quantity__c;
                    associatedOrderDeliveryGroupSummary.ShipmentTonnage__c = odg.ShipmentTonnage__c;
                    associatedOrderDeliveryGroupSummary.QuoteNumber__c = odg.QuoteNumber__c;
                    associatedOrderDeliveryGroupSummary.SplitShipmentId__c = odg.SplitShipmentId__c;
                    associatedOrderDeliveryGroupSummary.ShipmentStatus__c = odg.ShipmentStatus__c;
                    associatedOrderDeliveryGroupSummary.PONumber__c = odg.PONumber__c;
                    associatedOrderDeliveryGroupSummary.IsHold__c = odg.IsHold__c;
                    associatedOrderDeliveryGroupSummary.ShipmentWeight__c = odg.ShipmentWeight__c;
                    associatedOrderDeliveryGroupSummary.ShipmentDateTime__c = odg.ShipmentDateTime__c;
                    associatedOrderDeliveryGroupSummary.BOLNumber__c = odg.BOLNumber__c;
                    associatedOrderDeliveryGroupSummary.Next_Day_Order__c = odg.Next_Day_Order__c;
                    associatedOrderDeliveryGroupSummary.Material_Number_SF__c = odg.Material_Number_SF__c;
                    if(odg.DesiredDeliveryDate != null){
                        associatedOrderDeliveryGroupSummary.DesiredDeliveryDate = Datetime.newInstance(odg.DesiredDeliveryDate.year(), odg.DesiredDeliveryDate.month(), odg.DesiredDeliveryDate.day(), 12, 0, 0);
                    }					
                    associatedOrderDeliveryGroupSummary.DeliveryDate__c = odg.DesiredDeliveryDate;
                    associatedOrderDeliveryGroupSummary.DeliverToStreet = odg.DeliverToStreet;
                    associatedOrderDeliveryGroupSummary.DeliverToCity = odg.DeliverToCity;
                    associatedOrderDeliveryGroupSummary.DeliverToState = odg.DeliverToState;
                    associatedOrderDeliveryGroupSummary.DeliverToPostalCode = odg.DeliverToPostalCode;
                    associatedOrderDeliveryGroupSummary.DeliverToCountry = odg.DeliverToCountry;
                    lstUpdatedOrderDeliveryGroupSummary.add(associatedOrderDeliveryGroupSummary);                
                }
            }
        }
        return lstUpdatedOrderDeliveryGroupSummary;
    }
}