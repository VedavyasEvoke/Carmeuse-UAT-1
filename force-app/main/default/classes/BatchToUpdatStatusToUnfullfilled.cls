/************************************************************************************************************************************
Author : Priyanka Shinde
Description :Order Delivery Group status changed to Unfulfilled when Desired Delivery date is paased.
----------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 		        DATE 		  AUTHOR 			DETAIL
1           Update Order Delivery     20/04/2022    Priyanka Shinde   Order Delivery Group status changed to Unfulfilled when Desired Delivery date is paased.
Group Status
**************************************************************************************************************************************/

public class BatchToUpdatStatusToUnfullfilled implements Database.Batchable<sObject>,Database.Stateful {
    public List<String> errorList;
    
    public BatchToUpdatStatusToUnfullfilled(){
        errorList = new List<String>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        if(Test.isRunningTest()){
            return Database.getQueryLocator('SELECT Id,ShipmentStatus__c FROM OrderDeliveryGroup WHERE ShipmentStatus__c != \'Cancelled\' AND ShipmentStatus__c != \'Shipped\' AND ShipmentStatus__c != \'Pending\' AND ShipmentStatus__c != \'Received\' AND ShipmentStatus__c !=\'Unfulfilled\' AND ShipmentStatus__c !=\'Cancelled By Carmeuse\' AND ShipmentStatus__c != \'Cancellation Requested\' AND DesiredDeliveryDate < N_DAYS_AGO:3 LIMIT 100');
        }else{
            return Database.getQueryLocator('SELECT Id,ShipmentStatus__c FROM OrderDeliveryGroup WHERE ShipmentStatus__c != \'Cancelled\' AND ShipmentStatus__c != \'Shipped\' AND ShipmentStatus__c != \'Pending\' AND ShipmentStatus__c != \'Received\' AND ShipmentStatus__c !=\'Unfulfilled\' AND ShipmentStatus__c !=\'Cancelled By Carmeuse\' AND ShipmentStatus__c != \'Cancellation Requested\' AND DesiredDeliveryDate < N_DAYS_AGO:3');
        }
    }
    
    public void execute(Database.BatchableContext batchContext, List<OrderDeliveryGroup> lstOrderDeliveryGroup) {  
        if(!lstOrderDeliveryGroup.isEmpty()){
            for( OrderDeliveryGroup objOrderDeliveryGroup : lstOrderDeliveryGroup ){
                if(objOrderDeliveryGroup.ShipmentStatus__c != 'Unfulfilled'){
                    objOrderDeliveryGroup.ShipmentStatus__c = 'Unfulfilled';
                }                
            }
        }
        if(!lstOrderDeliveryGroup.isEmpty()){
            Database.SaveResult[] srList = Database.update(lstOrderDeliveryGroup,false);
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
    }
}