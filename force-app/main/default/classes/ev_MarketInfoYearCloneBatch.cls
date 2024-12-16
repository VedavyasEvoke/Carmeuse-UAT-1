//This Batch class is used clone the current year records to next year on year end.

global class ev_MarketInfoYearCloneBatch implements Database.Batchable<sObject>{
	global Database.QueryLocator start(Database.BatchableContext BC) {
        Integer year = Date.today().year() ;
        String currentYear = String.valueOf(year);
        //Query all market info records of current year with status track
             String query='select Id, OwnerId, Name, CurrencyIsoCode, Amount__c, Business_Unit__c, CO2Price__c, Comments__c, CompetitorProduct__c, Competitor_Plant_Id__c, Competitor__c, Country__c, CustomerprospectText__c, Customerprospect__c, End_Customer__c, Lime_Supplier_Plant__c, Lime_Supplier__c, Location__c, Market__c, OpptyCreated__c, ProductHierarchyLevel1__c, ProductHierarchyLevel2__c, ProductPrice__c, RawMaterialProduct__c, RawMaterialSupplier1__c, RawMaterialSupplierPlant1__c, RecordType__c, Region__c, SoldTo__c, StateOfShipTo__c, Status__c, SubMarket__c, Sub_Region__c, Tonnage__c, FreightPrice__c, UOM__c, Year__c, Zipcode__c, Competitor_Product__c, Region1__c, Country1__c, Account__c, Currency_Code__c, Lime_Supplier_Name__c, Lime_Supplier_Plant_Name__c, Market_Text__c, Opportunity__c, Sub_Market_Text__c from Market_Info__c WHERE Year__c!= \'currentYear\' AND Status__c=\'Track\''; //and ID=\'a2DQJ0000098zNh2AI\'
        return Database.getQueryLocator(query);
    }
   
    
    
    global void execute(Database.BatchableContext BC, List<Market_Info__c > scope) {
        //loop the batch scope and Clone the new market info records with next year and retire old Market info records 
        List<Market_Info__c> MIList = new List<Market_Info__c>();
        for (Market_Info__c  MI : scope) {
           MI.Status__c = 'Retire';
            Market_Info__c  M =  MI.clone(false, true);
            M.Year__c =  String.valueOf(Integer.valueOf(MI.Year__c)+1 ); 
            MIList.add(M);
        }
        
         if(MIList.size() > 0){
            insert MIList;
        }
        
		 if(scope.size() > 0){
            Update scope;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // Optional: Implement any post-processing logic here in the future if needed
    }
}