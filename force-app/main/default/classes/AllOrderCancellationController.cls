/************************************************************************************************************************************
Author : Priyanka Shinde
Description :AllOrderCancellationEmailComponent visualforce component controller apex class.
----------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 	  DATE 		   AUTHOR 			  DETAIL
1                           29/08/2022    Priyanka Shinde   AllOrderCancellationEmailComponent visualforce component controller apex class.
********************************************************************************************************************************/

public  class AllOrderCancellationController
{
    public Id osId {get;set;}
    //This method is used to get list of Order Delivery Group having ShipmentStatus equal to cancelled and Is_All_Cancelled__c field is equal to true.
    public List<OrderDeliveryGroup> getlstOrderDeliveryGroup()
    {
        List<OrderDeliveryGroup> lstOrderDeliveryGroup;
        lstOrderDeliveryGroup = [SELECT Id,QuoteNumber__c,AccountExternalNumber__c,PONumber__c,Cancel_Requested_By__r.Name,Cancel_Requested_On__c,OrderDeliveryGroupNumber,AccessCode__c,ShipmentTonnage__c,DesiredDeliveryDate FROM OrderDeliveryGroup WHERE OrderId = :osId AND ShipmentStatus__c = 'Cancelled' AND Is_All_Cancelled__c = TRUE ORDER BY DesiredDeliveryDate];
        return lstOrderDeliveryGroup;
    }
}