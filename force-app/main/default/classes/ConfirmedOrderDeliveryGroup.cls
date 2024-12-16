/************************************************************************************************************************************
Author : Priyanka Shinde
Description :OrderSummaryEmailTemplate visualforce component controller apex class.
----------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 	  DATE 		   AUTHOR 			  DETAIL
1.0.1       CARMEUSE-159      14/07/2022    Ravikant Vijapure   OrderSummaryEmailTemplate visualforce component controller apex class.
********************************************************************************************************************************/

public  class ConfirmedOrderDeliveryGroup
{
    public Id osId {get;set;}
    public List<OrderItem> getlstOrderItems()
    {
        List<OrderItem> lstOrderItems;
        lstOrderItems = [SELECT Id, OrderId, OrderDeliveryGroup.OrderDeliveryGroupNumber, OrderDeliveryGroup.AccessCode__c, OrderDeliveryGroup.ShipmentTonnage__c, Product2.Name, OrderDeliveryGroup.DesiredDeliveryDate, OrderDeliveryGroup.PONumber__c FROM OrderItem WHERE OrderId=: osId AND OrderDeliveryGroup.ShipmentStatus__c ='Confirmed' AND OrderDeliveryGroup.AccessCode__c != NULL Order By Product2.Name, OrderDeliveryGroup.DesiredDeliveryDate];
        return lstOrderItems;
    }
}