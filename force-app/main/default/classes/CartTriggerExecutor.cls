/************************************************************************************************************************************
Author : Priyanka Shinde
Description :Cart trigger handler class.
----------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 		      DATE 		  AUTHOR 			DETAIL
2           Apex CPU limit issue    19/03/2022    Priyanka Shinde   Code optimization for issue CPU limit.
**************************************************************************************************************************************/

public with sharing class CartTriggerExecutor implements TriggerExecutor_I {
    
    public Schema.SObjectType getSObjectType() {
        return WebCart.SObjectType;
    }
    
    public void beforeInsert(List<WebCart> triggerNew) {
    }
    
    public void beforeUpdate(Map<Id, SObject> triggerOldMap, List<WebCart> triggerNew) {
    }
    
    public void beforeDelete(List<WebCart> triggerOld) {
    }
    
    public void afterInsert(List<WebCart> triggerNew) {
    }
    
    public void afterUpdate(Map<Id, SObject> triggerOldMap, List<WebCart> triggerNew) {
        List<OrderDeliveryGroup> updatelstOrderDeliveryGroup = getOrderAndCartDeliveryGroup(triggerOldMap.keySet());
        if(updatelstOrderDeliveryGroup.size() > 0){
            update updatelstOrderDeliveryGroup;
        }
    }
    
    public void afterDelete(List<WebCart> triggerOld) {
    }
    //This method is used to get Order Delivery Groups by passing cartId
    public List<OrderDeliveryGroup> getOrderAndCartDeliveryGroup(Set<Id> cartIds){
        List<OrderDeliveryGroup> updatedlstOfOrderDeliveryGroup = new List<OrderDeliveryGroup>();
        Map<Id, Id> orderIdToCartIdMap = new  Map<Id, Id>();
        List<CartDeliveryGroup> relatedCartDeliveryGroups = new List<CartDeliveryGroup>();
        List<OrderDeliveryGroup> relatedOrderDeliveryGroups = OrderUtils.getRelatedOrderDeliveryGroupsByCartIds(new List<Id>(cartIds));
        if(relatedOrderDeliveryGroups.size() > 0){
            orderIdToCartIdMap = OrderUtils.getOrderIdToCartIdMap(new List<Id>(cartIds));
            relatedCartDeliveryGroups = OrderUtils.getCartDeliveryGroupsByCartIds(new List<Id>(cartIds));
            Set<Id> cpaIds = new Set<Id>();	            
            for(CartDeliveryGroup cdg : relatedCartDeliveryGroups) {
                cpaIds.add((Id) cdg.BillingAddress__c);
                cpaIds.add((Id) cdg.ShippingAddress__c);
            }
            //check for cpaIds is empty
            Map<Id, ContactPointAddress> relevantAddresses = new Map<Id, ContactPointAddress>();
            if(!cpaIds.isEmpty()){
                relevantAddresses = new Map<Id, ContactPointAddress>([
                    SELECT Id, Address, City, State, Street, PostalCode, Country,Name
                    FROM ContactPointAddress
                    WHERE Id IN :cpaIds
                ]);
            }
           
            Set<Id> processedOrderDeliveryGroupIds = new Set<Id>();
            if(relatedCartDeliveryGroups.size() > 0 && relatedOrderDeliveryGroups.size() > 0){
                for(Integer i = 0; i< relatedCartDeliveryGroups.size() ; i++){
                    CartDeliveryGroup cdg = relatedCartDeliveryGroups[i];
                    for(Integer j = 0; j< relatedOrderDeliveryGroups.size() ; j++){
                        OrderDeliveryGroup odg = relatedOrderDeliveryGroups[j];
                        if((!processedOrderDeliveryGroupIds.contains(odg.Id)) && (odg.DesiredDeliveryDate == cdg.DesiredDeliveryDate)
                           && cdg.CartId == orderIdToCartIdMap.get(odg.OrderId)){
                               OrderDeliveryGroup associatedOrderDeliveryGroup = odg;
                               ContactPointAddress billingAddress = relevantAddresses.get(cdg.BillingAddress__c);
                               ContactPointAddress shippingAddress = relevantAddresses.get(cdg.ShippingAddress__c);
                               if(associatedOrderDeliveryGroup != NULL){
                                   processedOrderDeliveryGroupIds.add(odg.Id);
                                   associatedOrderDeliveryGroup.AccountExternalNumber__c = cdg.AccountExternalNumber__c;
                                   associatedOrderDeliveryGroup.MaterialNumber__c = cdg.MaterialNumber__c;
                                   associatedOrderDeliveryGroup.ShipmentSize__c = cdg.Shipment_Size__c;
                                   associatedOrderDeliveryGroup.ShipmentSizeType__c = cdg.ShipmentSizeType__c;
                                   associatedOrderDeliveryGroup.Quantity__c = cdg.Quantity__c;
                                   associatedOrderDeliveryGroup.ShipmentTonnage__c = cdg.ShipmentTonnage__c;
                                   associatedOrderDeliveryGroup.QuoteNumber__c = cdg.Quote_Number__c;
                                   associatedOrderDeliveryGroup.DeliveryInstructions = cdg.DeliveryText__c;
                                   associatedOrderDeliveryGroup.SplitShipmentId__c = cdg.SplitShipmentId__c;
                                   associatedOrderDeliveryGroup.PONumber__c = cdg.PONumber__c;
                                   associatedOrderDeliveryGroup.IsHold__c = cdg.IsHold__c;                        
                                   associatedOrderDeliveryGroup.DeliverToStreet = shippingAddress.Street;
                                   associatedOrderDeliveryGroup.DeliverToCity = shippingAddress.City;
                                   associatedOrderDeliveryGroup.DeliverToState = shippingAddress.State;
                                   associatedOrderDeliveryGroup.DeliverToPostalCode = shippingAddress.PostalCode;
                                   associatedOrderDeliveryGroup.DeliverToCountry = shippingAddress.Country;
                                   associatedOrderDeliveryGroup.DeliverToName = 'Deliver to ' + shippingAddress.Name;
                                   associatedOrderDeliveryGroup.ShipmentStatus__c = 'Submitted';
                                   associatedOrderDeliveryGroup.Next_Day_Order__c = cdg.Next_Day_Order__c;
                                   associatedOrderDeliveryGroup.Material_Number_SF__c = cdg.Material_Number_SF__c;
                                   updatedlstOfOrderDeliveryGroup.add(associatedOrderDeliveryGroup);                       
                               }
                               break;
                           }
                    }
                }
            }        
        }		
        return updatedlstOfOrderDeliveryGroup;
    }
}