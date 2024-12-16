public with sharing class ev_printsummarycontroller {
    // Declare public properties for storing data
    public List<Schema.Competitor__c> plantlist {get; set;}
    public String groupname {get;set;}
    Public String formattedtotalkilns {get;set;}
    Public String formattednominalcapty {get;set;}
    Public String formattedFreeCapacityty {get;set;}
    Public String formattedEstimatedProductionty {get;set;}
    


    
    // Constructor method to initialize class variables
    public ev_printsummarycontroller() {
        // Retrieve parameters from the page reference
        String recid = ApexPages.currentPage().getParameters().get('selectedGroup');
        
        // Debug statement for debugging purposes
        System.debug('rec id from LWC==' + recid);
        
        // Query Competitor__c records along with related Competitor__r records
        plantlist = [SELECT Id, Name, RecordType.Name,
                    (SELECT Id, Name, Activity__c, Annual_Extraction_t_y__c, Quicklime__c, Dolime__c, Hydrated_Lime__c, Hyd_Cap_T_y__c, Lime_Cap_tpy__c, Lime_Est_tpy__c, Hydrated_Limecap_t_y__c, Estimated_Production_t_y__c, Nominal_Capacity_t_y__c
                     FROM Competitor__r)
                    FROM Competitor__c
                    WHERE RecordType.Name = 'Company' and Competitor__c = :recid ORDER BY Name];
        
        // Query and assign group name 
        Competitor__c cmp = [SELECT Name,Total_No_Kilns__c,Nominal_Capacity_t_y__c,Estimated_Production_t_y__c,Free_Capacity_t_y__c FROM Competitor__c WHERE Id = :recid];
       
        groupname = cmp.Name;
        decimal totalkilns =cmp.Total_No_Kilns__c;
       decimal nominalcapty =cmp.Nominal_Capacity_t_y__c;
      decimal FreeCapacityty =cmp.Free_Capacity_t_y__c;
       decimal EstimatedProductionty =cmp.Estimated_Production_t_y__c;
        formattedEstimatedProductionty =formatNumberWithCommas(EstimatedProductionty);
        formattedFreeCapacityty =formatNumberWithCommas(FreeCapacityty);
        formattednominalcapty =formatNumberWithCommas(nominalcapty);
        formattedtotalkilns =formatNumberWithCommas(totalkilns);
        
        // Debug statement for debugging purposes
        System.debug('plantlist: ' + plantlist);
    }
    
    // Method to fetch companies with their competitors
    @AuraEnabled(cacheable=true)
    public static List<Competitor__c> getCompaniesWithCompetitors(String selectedGroup) {
        // Query Competitor__c records along with related Competitor__r records based on selectedGroup
        return [SELECT Id, Name, RecordType.Name,
                (SELECT Id, Name, Activity__c, Annual_Extraction_t_y__c, Quicklime__c, Dolime__c, Hydrated_Lime__c, Hyd_Cap_T_y__c, Estimated_Production_t_y__c, Nominal_Capacity_t_y__c, Lime_Cap_tpy__c, Lime_Est_tpy__c, Hydrated_Limecap_t_y__c
                 FROM Competitor__r)
                FROM Competitor__c
                WHERE RecordType.Name = 'Company' and Competitor__c = :selectedGroup ORDER BY Name];
    }
    
    // Method to fetch group details based on groupId
    @AuraEnabled(cacheable=true)
    public static Competitor__c getGroupDetails(Id groupId) {
        // Query and return Competitor__c details based on groupId ,
        return [SELECT Name,Estimated_Production_t_y__c, Nominal_Capacity_t_y__c, Total_No_Kilns__c, Free_Capacity_t_y__c FROM Competitor__c WHERE Id = :groupId];
    }
    public String formatNumberWithCommas(Decimal value) {
        if(value!=null){
    return String.valueOf(value.setScale(2)).replaceAll('(\\d)(?=(\\d{3})+(?!\\d))', '$1,');
        }
        else return null;
}


}