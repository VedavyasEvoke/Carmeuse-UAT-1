public with sharing class OrderDetailsUtility {
    @testVisible
    private static Boolean throwException = false;
    public static final String ORDER_STATUS_CREATED = 'Submitted';
    public static final String ORDER_STATUS_PENDING = 'Pending';
    public static final String ORDER_STATUS_RECEIVED = 'Confirmed';
    public static final String ORDER_STATUS_SHIPPED = 'Shipped';
    public static final String ORDER_STATUS_CANCELED = 'Cancelled';
    public static final String ORDER_STATUS_CONFIRMED = 'Order Confirmed';
    public static final String ORDER_STATUS_FULFILLED = 'Fulfilled';
    public static final String ORDER_STATUS_UNFULFILLED = 'Unfulfilled';
    public static final String ORDER_STATUS_CANCELLED_BY_CARMEUSE = 'Cancelled By Carmeuse';
    public static final String ORDER_STATUS_CHANGE_REQUESTED = 'Change Requested';
    public static final String ORDER_STATUS_CHANGE_CONFIRMED = 'Change Confirmed';
    public static final String ORDER_STATUS_CANCELLATION_REQUESTED = 'Cancellation Requested';
    
        // This method returns the all order delivery group summary releated order.
        @AuraEnabled
        public static List<OrderDeliveryGroupSummary> getAccessCodeOrPOAllSummaries(String accessCode,String poNumber,List<String> orderSummryId){
            try{
                if(Test.isRunningTest() && throwException==true){
                    Exception e;
                    throw e;
                }
                List<OrderDeliveryGroupSummary> lstAccessCodeOrPOAllSummaries= [SELECT Id, AccessCode__c,OrderSummaryId,PONumber__c FROM OrderDeliveryGroupSummary WHERE (AccessCode__c =: accessCode OR PONumber__c=: poNumber) AND OrderSummaryId IN: orderSummryId];
                if(!lstAccessCodeOrPOAllSummaries.isEmpty()){
                return lstAccessCodeOrPOAllSummaries;   
                }
                else {
                    return null;
                }       
               }catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        // This method updates odg status to changes request.
        @AuraEnabled
        public static Boolean updateOrderDeliveryDate(Id orderDeliveryGroupId, Id orderId, Date selectedDate) {
            Boolean isUpdate = false;
            try {  
                OrderDeliveryGroup odg = new OrderDeliveryGroup();
                odg.Id = orderDeliveryGroupId;
                odg.DesiredDeliveryDate = selectedDate;
                odg.ShipmentStatus__c = ORDER_STATUS_CHANGE_REQUESTED;
                odg.Change_Requested_By__c = UserInfo.getUserId();
                odg.Change_Requested_On__c = DateTime.now();
                update odg;
                isUpdate = true;
                
            } catch(DmlException e) {
                isUpdate = false;
            }
            return isUpdate;
        }

        // This method return all order summary related to account.
        @AuraEnabled(cacheable=true)
        public static List<OrderSummary> getOrderSummariesByAccountId(Id AccountId){
            try {
                if(Test.isRunningTest() && throwException==true){
                    Exception e;
                    throw e;
                }
                List<OrderSummary> lstOrderSummary = [SELECT Id,AccountId,OrderNumber,Status,OrderedDate FROM OrderSummary WHERE AccountId =: AccountId AND OrderedDate >= LAST_N_DAYS:150 ORDER BY OrderedDate DESC LIMIT 50000];
                return lstOrderSummary;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        // This method will return product validaities.
        @AuraEnabled(cacheable=true)
        public static List<Product2> getProdutDetails(String SKU) {
            try{
                if(Test.isRunningTest() && throwException==true){
                    Exception e;
                    throw e;
                }
                return [SELECT Id, Name,Valid_From__c, Valid_To__c FROM Product2 Where StockKeepingUnit =: SKU];
            } catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        }
}