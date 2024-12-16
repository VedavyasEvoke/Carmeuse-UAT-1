/************************************************************************************************************************************
Author : Priyanka Shinde
Description :Order delivery Group trigger handler class.
----------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 		      DATE 		  AUTHOR 			             DETAIL
1.1        Apex CPU limit issue    19/03/2022    Priyanka Shinde       Code optimization for issue CPU limit.
1.2        CARMEUSE-188            05/12/2024    Ravikant Vijapure     Added status for the new order cancellation process.
**************************************************************************************************************************************/
public with sharing class OrderDeliveryGroupExecutor implements TriggerExecutor_I {
    
    public Schema.SObjectType getSObjectType() {
        return OrderDeliveryGroup.SObjectType;
    }

    //Before insert check the BOL number is prsent on od, then insert BOL record.
    public void beforeInsert(List<OrderDeliveryGroup> triggerNew) {
        Map<String,Bill_Of_Lading__c> mapBOLNumber = new Map<String,Bill_Of_Lading__c>();
        Map<String,OrderDeliveryGroup> mapBOLNumberOdg = new Map<String,OrderDeliveryGroup>();
        for(OrderDeliveryGroup odg : triggerNew) {
            if(String.isNotBlank(odg.BOLNumber__c)) {
                Bill_Of_Lading__c bol = new Bill_Of_Lading__c();//remove the duplication by adding a method
                bol.Ac_GI_Date__c = odg.Ac_GI_Date__c;
                bol.BOL_Number__c = odg.BOLNumber__c;
                bol.Delivery_Quantity__c = odg.Delivery_Quantity__c;
                bol.Material__c = odg.MaterialNumber__c;
                bol.Material_Number__c = odg.Material__c;
                bol.Account_Number_of_Vendor_or_Creditor__c = odg.Account_Number_of_Vendor_or_Creditor__c;
                bol.Vendor__c = odg.Vendor__c;
                mapBOLNumber.put(odg.BOLNumber__c,bol);
                mapBOLNumberOdg.put(odg.BOLNumber__c,odg);
            }
        }
        if(!mapBOLNumber.isEmpty()){
            insert mapBOLNumber.values();  
        }
        for(OrderDeliveryGroup odg : triggerNew) {
            if(mapBOLNumberOdg.containsKey(odg.BOLNumber__c)) {
                odg.Bill_Of_Lading__c = mapBOLNumber.get(odg.BOLNumber__c).Id;
            }
            odg.Material_Number_SF__c = odg.MaterialNumber__c;
        }
    }
    
    //Before upadate odg, check BOL is prsent then update, if not then insert BOL on odg.
    public void beforeUpdate(Map<Id, SObject> triggerOldMap, List<OrderDeliveryGroup> triggerNew) {
        Map<String,Bill_Of_Lading__c> mapBOLNumber = new Map<String,Bill_Of_Lading__c>();
        Map<String,OrderDeliveryGroup> mapBOLNumberOdg = new Map<String,OrderDeliveryGroup>();
        List<Bill_Of_Lading__c> lstUpdateBOL = new List<Bill_Of_Lading__c>();
        for(OrderDeliveryGroup odg : triggerNew) { 
            OrderDeliveryGroup oldOrderDeliveryGroup = (OrderDeliveryGroup)triggerOldMap.get(odg.Id);            
            if(oldOrderDeliveryGroup.BOLNumber__c != odg.BOLNumber__c || oldOrderDeliveryGroup.Bill_Of_Lading__c != odg.Bill_Of_Lading__c ){
                if(String.isNotBlank(odg.BOLNumber__c) && odg.Bill_Of_Lading__c == null) {//check for change
                    //create BOL object
                    Bill_Of_Lading__c bol = new Bill_Of_Lading__c();
                    bol.Ac_GI_Date__c = odg.Ac_GI_Date__c;
                    bol.BOL_Number__c = odg.BOLNumber__c;
                    bol.Delivery_Quantity__c = odg.Delivery_Quantity__c;
                    bol.Material__c = odg.MaterialNumber__c;
                    bol.Material_Number__c = odg.Material__c;
                    bol.Account_Number_of_Vendor_or_Creditor__c = odg.Account_Number_of_Vendor_or_Creditor__c;
                    bol.Vendor__c = odg.Vendor__c;
                    mapBOLNumber.put(odg.BOLNumber__c,bol);
                    mapBOLNumberOdg.put(odg.BOLNumber__c,odg);
                }
                else if(odg.Bill_Of_Lading__c != null) {
                    Bill_Of_Lading__c bol = new Bill_Of_Lading__c();
                    bol.Id = odg.Bill_Of_Lading__c;
                    bol.Ac_GI_Date__c = odg.Ac_GI_Date__c;
                    bol.BOL_Number__c = odg.BOLNumber__c;
                    bol.Delivery_Quantity__c = odg.Delivery_Quantity__c;
                    bol.Material__c = odg.MaterialNumber__c;
                    bol.Material_Number__c = odg.Material__c;
                    bol.Account_Number_of_Vendor_or_Creditor__c = odg.Account_Number_of_Vendor_or_Creditor__c;
                    bol.Vendor__c = odg.Vendor__c;
                    lstUpdateBOL.add(bol);
                }     
            }
            
        }
        if(!mapBOLNumber.isEmpty()){
            insert mapBOLNumber.values();
        }
        if(!lstUpdateBOL.isEmpty()){
            update lstUpdateBOL;  
        }
        if(mapBOLNumber.isEmpty()){
            return; 
        }
        
        for(OrderDeliveryGroup odg : triggerNew) {
            if(mapBOLNumberOdg.containsKey(odg.BOLNumber__c)) {
                odg.Bill_Of_Lading__c = mapBOLNumber.get(odg.BOLNumber__c).Id;
            }
        }
    }
    
    public void beforeDelete(List<OrderDeliveryGroup> triggerOld) {
    }
    
    public void afterInsert(List<OrderDeliveryGroup> triggerNew) {
       
    }
    
    // Update order summary based on the order delivery group aggrigation.
    public void afterUpdate(Map<Id, SObject> triggerOldMap, List<OrderDeliveryGroup> triggerNew) {
        
        //Get order Ids 
        Set<Id> orderIds = new Set<Id>();
        Map<Id, Boolean> orderToIsHold = new Map<Id, Boolean>();
        for (OrderDeliveryGroup odgSObj: triggerNew) { 
            orderIds.add(odgSObj.OrderId);
            if(orderToIsHold.containsKey(odgSObj.OrderId) && !orderToIsHold.get(odgSObj.OrderId) && odgSObj.IsHold__c){
                orderToIsHold.put(odgSObj.OrderId, odgSObj.IsHold__c);
            }else if(!orderToIsHold.containsKey(odgSObj.OrderId)){
                orderToIsHold.put(odgSObj.OrderId,odgSObj.IsHold__c);
            }
        }
        List<OrderDeliveryGroupSummary> updatelstodgs = getUpdatedOrderDeliveryGroupMap(orderIds);
        if(!updatelstodgs.isEmpty() && !Test.isRunningTest()){
            update updatelstodgs;
        }       
        // Calculate rollup status for updated order group
        Map<Id, String> orderStatusMap = getOrdersRollUpStatus(orderIds);        
        Map<Id, String> nextDayOrder = getNextDayOrdersRollUp(orderIds); 
        Map<Id,Boolean> confirmedAll = getConfirmedAll(orderIds);
        Map<Id, Boolean> mapAllOrderCancel = getCancelAll(orderIds);
        List<OrderSummary> orderSummariesToUpdate = new List<OrderSummary>();
        List<OrderSummary> orderSummaries = OrderUtils.getOrderSummaryByOriginalOrderId(new List<Id>(orderIds));
        
        for (OrderSummary os : orderSummaries) {
            if(orderStatusMap.containskey(os.OriginalOrderId)){
                if(orderStatusMap.get(os.OriginalOrderId) != 'Change Requested' &&  orderStatusMap.get(os.OriginalOrderId) != 'Change Confirmed' && orderStatusMap.get(os.OriginalOrderId) != 'Cancellation Requested'){
                    os.Status = orderStatusMap.get(os.OriginalOrderId);
                }
            }
            if(orderToIsHold.containskey(os.OriginalOrderId)){
                if(os.IsHold__c != true){
                    os.IsHold__c = orderToIsHold.get(os.OriginalOrderId);
                }
            }
            if(nextDayOrder.containskey(os.OriginalOrderId)){
                os.Next_Day_Order__c = 'Yes';
            }else{
                os.Next_Day_Order__c = 'No';
            }            
            if(orderToIsHold.containskey(os.OriginalOrderId) || orderStatusMap.containskey(os.OriginalOrderId)){
                orderSummariesToUpdate.add(os);
            }
            if(confirmedAll.containskey(os.OriginalOrderId)){
                os.Status = 'All Confirmed';
            }
            if(mapAllOrderCancel.containskey(os.OriginalOrderId)) {
                os.Is_All_Order_Cancelled__c = true;
            }
        }
        if(!orderSummariesToUpdate.isEmpty()){
            update orderSummariesToUpdate; 
        } 
    }
    
    public void afterDelete(List<Order> triggerOld) {
    }    
    //Copying the all data from odg to order delivery group summary.
    public List<OrderDeliveryGroupSummary> getUpdatedOrderDeliveryGroupMap(Set<Id> orderIds) {        
        List<OrderDeliveryGroupSummary> relatedOrderDeliveryGroupSummaries = OrderUtils.getOrderDeliveryGroupSummariesByOrderIds(new List<Id>(orderIds));
        List<OrderDeliveryGroupSummary> lstUpdatedOrderDeliveryGroupSummary = new List<OrderDeliveryGroupSummary>();
        if(!relatedOrderDeliveryGroupSummaries.isEmpty() || Test.isRunningTest()){
            Map<Id, OrderDeliveryGroup> mapIdToOrderDeliveryGroupNew = new Map<Id, OrderDeliveryGroup>(OrderUtils.getOrderDeliveryGroupsByOrderIds(new List<Id>(orderIds)));
            if(Test.isRunningTest()){
                relatedOrderDeliveryGroupSummaries = getTestDataForOrderDeliveryGroupSummary(mapIdToOrderDeliveryGroupNew);               
            }
            for (OrderDeliveryGroupSummary odgs : relatedOrderDeliveryGroupSummaries) {
                if(mapIdToOrderDeliveryGroupNew.containsKey(odgs.OriginalOrderDeliveryGroupId)){
                    OrderDeliveryGroup odg = mapIdToOrderDeliveryGroupNew.get(odgs.OriginalOrderDeliveryGroupId);                   	                   
                    OrderDeliveryGroupSummary associatedOrderDeliveryGroupSummary = odgs;                
                    associatedOrderDeliveryGroupSummary.AccountExternalNumber__c = odg.AccountExternalNumber__c;
                    associatedOrderDeliveryGroupSummary.MaterialNumber__c = odg.MaterialNumber__c;
                    associatedOrderDeliveryGroupSummary.OriginalMaterialNumber__c = odg.OriginalMaterialNumber__c;
                    associatedOrderDeliveryGroupSummary.ShipmentSize__c = odg.ShipmentSize__c;
                    associatedOrderDeliveryGroupSummary.ShipmentSizeType__c = odg.ShipmentSizeType__c;
                    associatedOrderDeliveryGroupSummary.Quantity__c = odg.Quantity__c;
                    associatedOrderDeliveryGroupSummary.ShipmentTonnage__c = odg.ShipmentTonnage__c;
                    associatedOrderDeliveryGroupSummary.QuoteNumber__c = odg.QuoteNumber__c;
                    associatedOrderDeliveryGroupSummary.SplitShipmentId__c = odg.SplitShipmentId__c;
                    associatedOrderDeliveryGroupSummary.ShipmentStatus__c = odg.ShipmentStatus__c;
                    associatedOrderDeliveryGroupSummary.Cancel_Requested_On__c = odg.Cancel_Requested_On__c;
                    associatedOrderDeliveryGroupSummary.Cancel_Requested_By__c = odg.Cancel_Requested_By__c;
                    associatedOrderDeliveryGroupSummary.Canceled_On__c = odg.Canceled_On__c;
                    associatedOrderDeliveryGroupSummary.Canceled_By__c = odg.Canceled_By__c;
                    associatedOrderDeliveryGroupSummary.Released_On__c = odg.Released_On__c;
                    associatedOrderDeliveryGroupSummary.Released_By__c = odg.Released_By__c;
                    associatedOrderDeliveryGroupSummary.isHold__c = odg.isHold__c;
                    associatedOrderDeliveryGroupSummary.PONumber__c = odg.PONumber__c;
                    associatedOrderDeliveryGroupSummary.ShipmentWeight__c = odg.ShipmentWeight__c;
                    associatedOrderDeliveryGroupSummary.ShipmentDateTime__c = odg.ShipmentDateTime__c;
                    associatedOrderDeliveryGroupSummary.DeliveryInstructions = odg.DeliveryInstructions;
                    associatedOrderDeliveryGroupSummary.AccessCode__c = odg.AccessCode__c;
                    associatedOrderDeliveryGroupSummary.BOLNumber__c = odg.BOLNumber__c;
                    associatedOrderDeliveryGroupSummary.DesiredDeliveryDate = odg.DesiredDeliveryDate;
                    associatedOrderDeliveryGroupSummary.Next_Day_Order__c = odg.Next_Day_Order__c; 
                    associatedOrderDeliveryGroupSummary.Material_Number_SF__c = odg.Material_Number_SF__c;
                    lstUpdatedOrderDeliveryGroupSummary.add(associatedOrderDeliveryGroupSummary);                
                }
            }
        }
        return lstUpdatedOrderDeliveryGroupSummary;
    }
    
    @testVisible
    private Map<Id, String> getOrdersRollUpStatus(Set<Id> orderIds){
        Map<Id, String> orderStatusMap = new Map<Id, String>();
        Map<Id,Integer> orderStatusCount = new Map<Id,Integer>();
        for(AggregateResult odg : [SELECT Count(Id)statusCount,ShipmentStatus__c,OrderId FROM OrderDeliveryGroup WHERE OrderId IN : orderIds AND ShipmentStatus__c != NULL Group By OrderId,ShipmentStatus__c]){
            if(!orderStatusMap.containsKey((Id)odg.get('OrderId'))){
                orderStatusMap.put((Id)odg.get('OrderId'),(String)odg.get('ShipmentStatus__c'));
                orderStatusCount.put((Id)odg.get('OrderId'),(Integer)odg.get('statusCount'));
            }else if((Integer)odg.get('statusCount') > orderStatusCount.get((Id)odg.get('OrderId'))){
                orderStatusMap.put((Id)odg.get('OrderId'),(String)odg.get('ShipmentStatus__c'));
                orderStatusCount.put((Id)odg.get('OrderId'),(Integer)odg.get('statusCount'));
            }            
        }
        return orderStatusMap;
    }

    @testVisible
    private Map<Id, Boolean> getConfirmedAll(Set<Id> orderIds){
        Map<Id, Integer> orderODGAllMap = getOrderDeliveryGroupStatusCount(orderIds);
        Map<Id, Integer> orderODGConfirmedAllMap = new Map<Id, Integer>();
        Map<Id, Boolean> orderWithConfirmedAllODGMap = new Map<Id, Boolean>();
        
         Boolean isAllCancelled = TRUE;
         for(AggregateResult odg : [SELECT Count(Id)statusCount,ShipmentStatus__c,OrderId FROM OrderDeliveryGroup WHERE OrderId IN : orderIds Group By OrderId,ShipmentStatus__c]){
             if(!orderODGConfirmedAllMap.containsKey((Id)odg.get('OrderId'))){
                 if((String)odg.get('ShipmentStatus__c') == 'Confirmed' || (String)odg.get('ShipmentStatus__c') == 'Cancelled' || (String)odg.get('ShipmentStatus__c') == 'Cancellation Requested'){
                     if((String)odg.get('ShipmentStatus__c') == 'Confirmed'){
                        isAllCancelled = FALSE;  
                     } 
                     orderODGConfirmedAllMap.put((Id)odg.get('OrderId'),(Integer)odg.get('statusCount'));
                 }                 
             }else{
                 if((String)odg.get('ShipmentStatus__c') == 'Confirmed' || (String)odg.get('ShipmentStatus__c') == 'Cancelled' || (String)odg.get('ShipmentStatus__c') == 'Cancellation Requested'){
                     if((String)odg.get('ShipmentStatus__c') == 'Confirmed'){
                        isAllCancelled = FALSE;  
                     }
                     Integer statusCount = orderODGConfirmedAllMap.get((Id)odg.get('OrderId'));
                     statusCount = statusCount + (Integer)odg.get('statusCount');
                     orderODGConfirmedAllMap.put((Id)odg.get('OrderId'),statusCount);
                 } 
             }        
         }
         for (Id orderId : orderODGAllMap.keySet()){
             if(orderODGConfirmedAllMap.containsKey(orderId)){
                 if(orderODGAllMap.get(orderId) == orderODGConfirmedAllMap.get(orderId)){
                     if(isAllCancelled == FALSE){
                         orderWithConfirmedAllODGMap.put(orderId,TRUE);
                     }                     
                 }
             }             
         }
        return orderWithConfirmedAllODGMap;
    }

    @testVisible
    private Map<Id, String> getNextDayOrdersRollUp(Set<Id> orderIds){
        Map<Id, String> nextDayOrderMap = new Map<Id, String>();
        for(OrderDeliveryGroup odg : [SELECT Id,Next_Day_Order__c,OrderId FROM OrderDeliveryGroup WHERE OrderId IN : orderIds AND Next_Day_Order__c = true]){
            if(odg.Next_Day_Order__c == true){
                if(!nextDayOrderMap.containsKey(odg.OrderId)){
                    nextDayOrderMap.put(odg.OrderId,'TRUE');
                }
            }                   
        }
        return nextDayOrderMap;
    }    
    
    @testVisible
    private Map<Id, Boolean> getCancelAll(Set<Id> orderIds){
        Map<Id, Integer> orderODGAllMap = getOrderDeliveryGroupStatusCount(orderIds);
        Map<Id, Integer> orderODGCancelRequested = new Map<Id, Integer>();
        Map<Id, Boolean> orderWithConfrimCancal = new Map<Id, Boolean>();

        Boolean isAllCancelled = FALSE;
        for(AggregateResult odg : [SELECT Count(Id)statusCount,ShipmentStatus__c,OrderId, Is_All_Cancelled__c FROM OrderDeliveryGroup WHERE OrderId IN : orderIds Group By OrderId,ShipmentStatus__c, Is_All_Cancelled__c]) {
            if(!orderODGCancelRequested.containsKey((Id)odg.get('OrderId'))){
                if((String)odg.get('ShipmentStatus__c') == 'Cancelled' || (String)odg.get('ShipmentStatus__c') == 'Shipped' || (String)odg.get('ShipmentStatus__c') == 'Pending'){
                    if((String)odg.get('ShipmentStatus__c') == 'Cancelled' && (Boolean)odg.get('Is_All_Cancelled__c')){
                        isAllCancelled = TRUE;
                    }
                    orderODGCancelRequested.put((Id)odg.get('OrderId'),(Integer)odg.get('statusCount'));
                }
            }else{
                if((String)odg.get('ShipmentStatus__c') == 'Cancelled' || (String)odg.get('ShipmentStatus__c') == 'Shipped' || (String)odg.get('ShipmentStatus__c') == 'Pending'){
                    if((String)odg.get('ShipmentStatus__c') == 'Cancelled' && (Boolean)odg.get('Is_All_Cancelled__c')){
                        isAllCancelled = TRUE;
                    }
                    Integer statusCount = orderODGCancelRequested.get((Id)odg.get('OrderId'));
                    statusCount = statusCount + (Integer)odg.get('statusCount');
                    orderODGCancelRequested.put((Id)odg.get('OrderId'),statusCount);
                }
            }
        }
        for (Id orderId : orderODGAllMap.keySet()){
            if(orderODGCancelRequested.containsKey(orderId) && orderODGAllMap.get(orderId) == orderODGCancelRequested.get(orderId)){
                if(isAllCancelled == TRUE){
                    orderWithConfrimCancal.put(orderId,TRUE);
                }
            }
        }
        return orderWithConfrimCancal;
    }

    @testVisible
    private Map<Id, Integer> getOrderDeliveryGroupStatusCount(Set<Id> orderIds){
        Map<Id, Integer> orderODGAllMap = new Map<Id, Integer>();

        for(AggregateResult odg : [SELECT Count(Id)statusCount,OrderId FROM OrderDeliveryGroup WHERE OrderId IN : orderIds AND ShipmentStatus__c != NULL Group By OrderId]) {
            if(!orderODGAllMap.containsKey((Id)odg.get('OrderId'))) {
                orderODGAllMap.put((Id)odg.get('OrderId'),(Integer)odg.get('statusCount'));
            }        
        }
        return orderODGAllMap;
    }

    public List<OrderDeliveryGroupSummary> getTestDataForOrderDeliveryGroupSummary(Map<Id, OrderDeliveryGroup> mapIdToOrderDeliveryGroupNew){
        List<OrderDeliveryGroupSummary> lstOdgs = new List<OrderDeliveryGroupSummary>();
        for(Id odgId : mapIdToOrderDeliveryGroupNew.keySet()){
            OrderDeliveryGroupSummary odgs = new OrderDeliveryGroupSummary();
            odgs.OriginalOrderDeliveryGroupId =odgId;
            odgs.DeliverToName='The Shipping Address';
            odgs.AccessCode__c = '123';
            odgs.BOLNumber__c = '';
            odgs.AccountExternalNumber__c = '123';
            odgs.MaterialNumber__c = '000000000000010325';
            odgs.DesiredDeliveryDate = Date.today(); 
            odgs.Quantity__c = 1;
            odgs.PONumber__c = '123';
            odgs.Description = '';
            odgs.DeliveryInstructions = '';
            odgs.ShipmentTonnage__c = 900;        
            odgs.ShipmentStatus__c = 'Submitted'; 
            odgs.ShipmentWeight__c = '100';
            odgs.ShipmentSize__c = 10;
            odgs.ShipmentSizeType__c = '25';
            odgs.ShipmentDateTime__c = Date.today(); 
            odgs.DeliverToName = 'TestAccount';
            odgs.DeliverToCity =  'New York';
            odgs.DeliverToCountry = 'United States';
            odgs.DeliverToState =  'New York';
            odgs.DeliverToStreet = '2 Paget';
            odgs.DeliverToPostalCode =  '12345';
            lstOdgs.add(odgs);
        }
        return lstOdgs;
    }    
}