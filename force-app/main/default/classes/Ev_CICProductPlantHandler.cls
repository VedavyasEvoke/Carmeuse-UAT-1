public class Ev_CICProductPlantHandler {
    @InvocableMethod
    public static void createProductplants(List<Request> requests) {
        List<CIC_Productplant__c> recordsToInsert = new List<CIC_Productplant__c>();
        
        for (Request req : requests) {
            System.debug('Product Company IDS'+req.companyProductIds);
            List<String> ProductcompanyIdList = req.companyProductIds.split(';');
            system.debug('ist Com'+ProductcompanyIdList);
            
            for (String companyId : ProductcompanyIdList) {
                CIC_Productplant__c  newRecord = new CIC_Productplant__c ();
                newRecord.Product_Company__c = req.productId;
                newRecord.Plant__c = companyId;
                recordsToInsert.add(newRecord);
            }
        }
        
        if (!recordsToInsert.isEmpty()) {
            insert recordsToInsert;
            System.debug('Created Recs'+recordsToInsert);
        }
    }

    public class Request {
        @InvocableVariable
        public String productId;
        @InvocableVariable
        public String companyProductIds;  // Assume companyIds is a comma-separated string
    }
}