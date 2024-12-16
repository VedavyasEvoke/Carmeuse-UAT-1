public with sharing class ev_MarketInfoController {
    @AuraEnabled(cacheable=true)
    public static List<CompetitorWrapper> getMarketInfo(String recordId) {
       
        System.debug ('Record ID: ' + recordId);
        
        Account currentAccount = [
            SELECT Id, ParentId, Account_Group__c
            FROM Account 
            WHERE Id = :recordId
            LIMIT 1
        ];
        
        System.debug(' Current Account  Id ' + currentAccount);

        List<market_info__c> marketinfolst;
        String lastYear = String.valueOf(System.today().year() - 1);
        
        // Check Sold to or Ship to Account
        if (currentAccount.ParentId == null || currentAccount.Account_Group__c == '1') {
            System.debug('  sold-to account');
            marketinfolst = [
                SELECT Competitor__r.Name, Tonnage__c, Competitor_Plant_Id__r.Name, Competitor_Plant_Id__r.Estimated_Production_t_y__c, ProductHierarchyLevel1__c
                FROM market_info__c
                WHERE SoldTo__c = :recordId AND Year__c = :lastYear AND (ProductHierarchyLevel1__c = '120' OR ProductHierarchyLevel1__c = '130')
            ];
        } else {
            System.debug('Ship to account');
            marketinfolst = [
                SELECT Competitor__r.Name, Tonnage__c, Competitor_Plant_Id__r.Name, Competitor_Plant_Id__r.Estimated_Production_t_y__c, ProductHierarchyLevel1__c
                FROM market_info__c
                WHERE Customerprospect__c = :recordId AND Year__c = :lastYear AND (ProductHierarchyLevel1__c = '120' OR ProductHierarchyLevel1__c = '130')
            ];
        }
        
        System.debug(' Lst Size: ' + marketinfolst.size());

        Map<String, CompetitorWrapper> competitorMap = new Map<String, CompetitorWrapper>();
        
        // Process each market_info__c record
        for (market_info__c info : marketinfolst) {
            String competitorName = info.Competitor__r.Name;
            String productLevel = info.ProductHierarchyLevel1__c;
            Decimal tonnage = info.Tonnage__c != null ? info.Tonnage__c : 0;
            String plantName = info.Competitor_Plant_Id__r.Name;
            Decimal estimatedProd = info.Competitor_Plant_Id__r.Estimated_Production_t_y__c != null ? info.Competitor_Plant_Id__r.Estimated_Production_t_y__c : 0;

            Decimal crudeTonnage = 0;
            Decimal burntTonnage = 0;

            // Tonnage based on Product Hierarchy
            if (productLevel == '120') {
                crudeTonnage = tonnage;
                System.debug(' Crude Tonnage  : ' + crudeTonnage + '   plant ' + plantName);
            } else if (productLevel == '130') {
                burntTonnage = tonnage;
                System.debug('  Burnt Tonnage  : ' + burntTonnage + '   plant ' + plantName);
            }

            System.debug(' Competitor: ' + competitorName);

            if (!competitorMap.containsKey(competitorName)) {
                System.debug(' CompetitorWrapper   ' + competitorName);
                competitorMap.put(competitorName, new CompetitorWrapper(competitorName));
            }
            
            CompetitorWrapper competitorWrapper = competitorMap.get(competitorName);
            competitorWrapper.TotalCrudeTonnage += crudeTonnage;
            competitorWrapper.TotalBurntTonnage += burntTonnage;
            
             
            
                 competitorWrapper.Plants.add(new PlantWrapper(plantName, crudeTonnage, burntTonnage, estimatedProd));
           
        }
        
        // Calculate grand totals for all competitors
        Decimal grandTotalCrudeTonnage = 0;
        Decimal grandTotalBurntTonnage = 0;

        for (CompetitorWrapper competitor : competitorMap.values()) {
            grandTotalCrudeTonnage += competitor.TotalCrudeTonnage;
            grandTotalBurntTonnage += competitor.TotalBurntTonnage;
        }

        System.debug('  Total Crude Tonnage: ' + grandTotalCrudeTonnage);
        System.debug(' Total Burnt Tonnage: ' + grandTotalBurntTonnage);

       
        return new List<CompetitorWrapper>(competitorMap.values());
    }
    
    // CompetitorWrapper for Company information
    public class CompetitorWrapper {
        @AuraEnabled
        public String CompetitorName { get; set; }
        @AuraEnabled
        public Decimal TotalCrudeTonnage { get; set; }
        @AuraEnabled
        public Decimal TotalBurntTonnage { get; set; }
        @AuraEnabled
        public List<PlantWrapper> Plants { get; set; }
        
        public CompetitorWrapper(String name) {
            this.CompetitorName = name;
            this.TotalCrudeTonnage = 0;
            this.TotalBurntTonnage = 0;
            this.Plants = new List<PlantWrapper>();
        }
    }
    
    // PlantWrapper for plant information
    public class PlantWrapper {
        @AuraEnabled
        public String PlantName { get; set; }
        @AuraEnabled
        public Decimal CrudeTonnage { get; set; }
        @AuraEnabled
        public Decimal BurntTonnage { get; set; }
        @AuraEnabled
        public Decimal EstimatedProduction { get; set; }
        @AuraEnabled
        public String FormattedCrudeTonnage { get; set; }
        @AuraEnabled
        public String FormattedBurntTonnage { get; set; }
        
        public PlantWrapper(String name, Decimal crudeTonnage, Decimal burntTonnage, Decimal estimatedProduction) {
            this.PlantName = name;
            this.CrudeTonnage = crudeTonnage;
            this.BurntTonnage = burntTonnage;
            this.EstimatedProduction = estimatedProduction;
            this.FormattedCrudeTonnage = formatNumberWithCommas(crudeTonnage);
            this.FormattedBurntTonnage = formatNumberWithCommas(burntTonnage);
        }

        public String formatNumberWithCommas(Decimal value) {
            if (value != null) {
                return String.valueOf(value.setScale(0)).replaceAll('(\\d)(?=(\\d{3})+(?!\\d))', '$1,');
            } else {
                return null;
            }
        }
    }
}