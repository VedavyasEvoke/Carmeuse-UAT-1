//This Batch class is used Create market info records based on carmeuse sale from Previous year Invoice records.
global class ev_CICMarketInforCarmeuseSaleBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Integer year = Date.today().year() - 1 ;
      //   List<String> accountInvoiceRelationIds = new List<String>{'001Qt00000bmpQUIAY','001Qt00000bmpQTIAY','001Qt00000bmoLGIAY'};
        String query ;
        if (Test.isRunningTest()) {
        query = 'SELECT id, name, Product__c, Product__r.Family, InvoiceDate__c, Invoice_Date__c, SalesInvoiceQuantity__c, SAP_ID__c, AccountInvoiceRelation__c, ' +
                'AccountInvoiceRelation__r.Name, AccountInvoiceRelation__r.Customer_Region__c, AccountInvoiceRelation__r.Account_Group__c, AccountInvoiceRelation__r.ParentId ' +
                'FROM AccountInvoice__c ' +
                'WHERE SAP_ID__c != \'\' ' +
                'AND (Product__r.Family = \'130\' OR Product__r.Family = \'120\') ' +
                'AND CALENDAR_YEAR(InvoiceDate__c) = :year';
        } else {
        query = 'SELECT id, name, Product__c, Product__r.Family, InvoiceDate__c, Invoice_Date__c, SalesInvoiceQuantity__c, SAP_ID__c, AccountInvoiceRelation__c, ' +
                'AccountInvoiceRelation__r.Name, AccountInvoiceRelation__r.Customer_Region__c, AccountInvoiceRelation__r.Account_Group__c, AccountInvoiceRelation__r.ParentId ' +
                'FROM AccountInvoice__c ' +
                'WHERE SAP_ID__c != \'\' ' +
                'AND (Product__r.Family = \'130\' OR Product__r.Family = \'120\') ' +
                'AND CALENDAR_YEAR(InvoiceDate__c) = :year';
        }
         return Database.getQueryLocator(query);
    }
  global void execute(Database.BatchableContext BC, List<AccountInvoice__c> scope) {
        //loop the batch scope and Clone the new market info records with next year and retire old Market info records 
        Integer year = Date.today().year() - 1 ;
        String PreviousYear = String.valueOf(year);
        String EU_RT = Schema.SObjectType.Market_Info__c.getRecordTypeInfosByName().get('MarketInfo EU').getRecordTypeId();
        String NA_RT = Schema.SObjectType.Market_Info__c.getRecordTypeInfosByName().get('MarketInfo NA').getRecordTypeId();
        Competitor__c CIC = [select ID from Competitor__c where Name ='Carmeuse' and Recordtype.Name='Company' Limit 1];
        List<AccountInvoice__c> AIList = new List<AccountInvoice__c>();
        Map<String,List<AccountInvoice__c>> AIMap = new Map<String,List<AccountInvoice__c>>();
        for (AccountInvoice__c  AI : scope) {
            String AccKey= AI.AccountInvoiceRelation__c+AI.Product__r.Family;
            if (!AIMap.containsKey(AccKey)) {
                
                AIMap.put(AccKey, new List<AccountInvoice__c>{AI});
            } else {
                AIMap.get(AccKey).add(AI);
            }
        }
        
        List<Market_Info__c> MList = new List<Market_Info__c>();
        for (String key : AIMap.keySet()) {
            // The "key" variable is also available inside the loop
            List<AccountInvoice__c> AccInvoices = AIMap.get(key);
            Market_Info__c m = new Market_Info__c();
            Decimal qty = 0;
            String shipToId;
            String soldToId;
            String Name ;
            String Ph1;
            String region = AccInvoices[0].AccountInvoiceRelation__r.Customer_Region__c; 
            String recordTypeId;
            if (region == 'North America') {
                recordTypeId = NA_RT;  // Use NA RecordTypeId
            } else {
                recordTypeId = EU_RT;  // Use EU RecordTypeId
            }
            for(AccountInvoice__c A : AccInvoices){
                Qty = A.SalesInvoiceQuantity__c + Qty;
                Name = A.AccountInvoiceRelation__r.Name +' - '+PreviousYear;
                shipToId = A.AccountInvoiceRelation__c;
                Ph1 = A.Product__r.Family;
                system.debug('SalesInvoiceQuantity__c===='+A.SalesInvoiceQuantity__c);
                if(A.AccountInvoiceRelation__r.Account_Group__c == '2'){
                    soldToId = A.AccountInvoiceRelation__r.parentId;
                }
                else {
                    soldToId = A.AccountInvoiceRelation__c;
                }
            }
            
            m.Customerprospect__c = shipToId;
            m.SoldTo__c = soldToId;
            m.Tonnage__c = qty;
            m.Competitor__c = CIC.Id;
            m.Year__c =PreviousYear;
            m.name = Name;
            m.ProductHierarchyLevel1__c = Ph1;
            
            m.RecordTypeId = recordTypeId;
            MList.add(m);
            Qty = 0;
            SoldToId = '';
        }
        
        if(MList.size() > 0){
            insert MList;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // Optional: Implement any post-processing logic here in the future if needed
    }
    
    
}