public class Ev_CICProductCompanyHandler {
    @InvocableMethod
    public static void createProductCompanies(List<Request> requests) {
        List<CIC_Product_Company__c> recordsToInsert = new List<CIC_Product_Company__c>();
        
        for (Request req : requests) {
            System.debug('Company IDS'+req.companyids);
            List<String> companyIdList = req.companyIds.split(';');
            system.debug('ist Com'+companyIdList);
            
            for (String companyId : companyIdList) {
                CIC_Product_Company__c newRecord = new CIC_Product_Company__c();
                newRecord.CIC_Products__c = req.productId;
                newRecord.Competitor__c = companyId;
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
        public String companyIds;  // Assume companyIds is a comma-separated string
    }
}