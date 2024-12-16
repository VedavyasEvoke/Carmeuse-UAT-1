/*----------------------------------------------------------------------
Name:       ThirdPartyOrderManagement.cls
Purpose:    Class for order management for the orders created by SAP System
------------------------------History----------------------------------
Version     Author          Date                    Detail Description 
-------     -------         --------------          ------------------
1.0         Devang          24-April-2021           Initial Development 
----------------------------------------------------------------------*/
global class ThirdPartyOrderManagement {
    
    @future
    public static void processOrderRecords(Set<Id> orderIds) {
        //Get SAP Channel Id
        Id channelId = null;
        SalesChannel sc = [SELECT Id, SalesChannelName FROM SalesChannel WHERE SalesChannelName = 'SAP' limit 1];
        if(sc != null){
            channelId = sc.Id;
        }

            //Filter only ordeer with External__c is set to true - orders comming from SAP system.
        List<Order> orderList =  OrderUtils.getExternalActivatedOrders(orderIds);
        List<Id> externalOrderIds = new List<Id>();
        if(orderList != null && orderList.size() > 0){
            for(Order o : orderList){
                externalOrderIds.add(o.Id);
            }            
        }

        //only continue if any external order present
        if(externalOrderIds != null && externalOrderIds.size() > 0){
            //Get OrderSummaryByOriginalOrderId
            List<OrderSummary> orderSummaryList =  OrderUtils.getOrderSummaryByOriginalOrderId(externalOrderIds);

            //Here we can process the order records        
            Set<Id> orderSummariesIds = new Set<Id>();
            
            for(Id oId : externalOrderIds){
                //order summary present - don't create
               
                if(isOrderSummaryPresent(orderSummaryList, oId)){
                    continue;
                }
                // create order summary
                
                ConnectApi.OrderSummaryInputRepresentation osir = new ConnectApi.OrderSummaryInputRepresentation();
                osir.orderId = oId;
                osir.orderLifeCycleType = 'UNMANAGED';
                ConnectApi.OrderSummaryOutputRepresentation osor = ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
                orderSummariesIds.add(osor.orderSummaryId);
            }

            Long millisecondsToWait = 35000; // vary this depending on your "sleep" needs
            pauseBeforeNextAction(millisecondsToWait);

            //Set Sales Channel as SAP
            List<OrderSummary> orderSummariesToUpdate = new List<OrderSummary>();
            for(Id osId : orderSummariesIds){
                OrderSummary os = new OrderSummary();
                os.Id = osId;
                os.SalesChannelId = channelId;
                orderSummariesToUpdate.add(os);
            }

            if(orderSummariesToUpdate != null && orderSummariesToUpdate.size() > 0){
                
                update orderSummariesToUpdate;
            }        
        }
    }

    private static Boolean isOrderSummaryPresent(List<OrderSummary> orderSummaryList, Id oId){
        Boolean isPresent = false;
        for(OrderSummary os : orderSummaryList){
            if(os.OriginalOrderId == oId){
                isPresent = true;
                break;
            }
        }
        return isPresent;
    }

    private static void pauseBeforeNextAction(Long millisecondsToWait){
        // 15 second "pause" to allow testing of code
        Long startTime = DateTime.now().getTime();
        Long finalTime = DateTime.now().getTime();        
        while (finalTime - startTime < millisecondsToWait) {
            finalTime = DateTime.now().getTime();
        }
    }

}