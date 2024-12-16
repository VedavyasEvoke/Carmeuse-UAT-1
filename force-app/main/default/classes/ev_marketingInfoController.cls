public class ev_marketingInfoController {

   @AuraEnabled(cacheable=true)
    public static list<Market_Info__c> getMarketingProds(string qId){
        list<Product2> prodList=new list<Product2>();
        set<id> prodids=new set<id>();
        set<id> accIds=new set<id>();
         Integer year = Date.today().year() ;
        String currentYear = String.valueOf(year);
        List<SBQQ__QuoteLine__c> qlLlist=[SELECT Id,SBQQ__Quote__r.Ship_to__c,SBQQ__Product__c from SBQQ__QuoteLine__c where SBQQ__Quote__c=:qId];
        
        for(SBQQ__QuoteLine__c ql:qlLlist){
            prodids.add(ql.SBQQ__Product__c);
            accIds.add(ql.SBQQ__Quote__r.Ship_to__c);
        }
        system.debug('prodids=='+prodids);
         system.debug('accIds=='+accIds);
      // Id accId=[SELECT id,Ship_to__c from SBQQ__Quote__c where Id=:qId].Ship_to__c;
        list<Market_Info__c> lisMarktInfo=[select Id, OwnerId, Name, CurrencyIsoCode, Amount__c, Business_Unit__c, CO2Price__c, Comments__c, CompetitorProduct__c, Competitor_Plant_Id__c, Competitor__c, Country__c, CustomerprospectText__c, Customerprospect__c, End_Customer__c, Lime_Supplier_Plant__c, Lime_Supplier__c, Location__c, Market__c, OpptyCreated__c, ProductHierarchyLevel1__c, ProductHierarchyLevel2__c, ProductPrice__c, RawMaterialProduct__c, RawMaterialSupplier1__c, RawMaterialSupplierPlant1__c, RecordType__c, Region__c, SoldTo__c, StateOfShipTo__c, Status__c, SubMarket__c, Sub_Region__c, Tonnage__c, FreightPrice__c, UOM__c, Year__c, Zipcode__c, Competitor_Product__c, Region1__c, Country1__c, Account__c, Currency_Code__c, Lime_Supplier_Name__c, Lime_Supplier_Plant_Name__c, Market_Text__c, Opportunity__c, Sub_Market_Text__c from Market_Info__c
                                           where  Customerprospect__c IN:accIds AND Competitor_Product__c IN: prodids AND Year__c < 'currentYear' AND Status__c = 'Track'];
      	system.debug('lisMarktInfo=='+lisMarktInfo.size());
        return lisMarktInfo;
    }
    
     @AuraEnabled
        public static void closeModal(string qtid){
            SBQQ__Quote__c updateQuote=[SELECT id,Is_Model_Enabled__c from SBQQ__Quote__c where Id=:qtid];
            updateQuote.Is_Model_Enabled__c=false;
            update updateQuote;
        }
        @AuraEnabled
        public static void updateMarketingProds(string records,string qtid){

            SBQQ__Quote__c updateQuote=[SELECT id,Is_Model_Enabled__c from SBQQ__Quote__c where Id=:qtid];
            updateQuote.Is_Model_Enabled__c=false;
            update updateQuote;
            system.debug('save'+updateQuote);
            // list<Market_Info__c> maList=(list<Market_Info__c>)JSON.deserialize(records, <Market_Info__c>.class);
            List<Market_Info__c> maList = (List<Market_Info__c>) JSON.deserialize(records, List<Market_Info__c>.class);
                         system.debug('MiList=='+maList);

            list<Market_Info__c> updateMiList=new list<Market_Info__c>();
             list<Market_Info__c> insertMiList=new list<Market_Info__c>();
            for(Market_Info__c mi:maList){
                mi.Status__c='Retire';
                updateMiList.add(mi);


            }
            if(!updateMiList.isEmpty()){
                update updateMiList;
                system.debug('updateMiList=='+updateMiList);

            }
            
            for(Market_Info__c mi:maList){
                Integer year = Date.today().year() ;
        		String currentYear = String.valueOf(year);
               // Market_Info__c minfo=new Market_Info__c();
                Market_Info__c  M =  mi.clone(false, true);
				M.Year__c=currentYear;
                
               insertMiList.add(M);
                system.debug('minfo=='+M);


            }

            if(!insertMiList.isEmpty()){
                insert insertMiList;
                system.debug('insertMiList=='+insertMiList);

            }

        }

}