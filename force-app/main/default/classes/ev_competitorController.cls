public with sharing class ev_competitorController {
    // Declare public properties for storing data
    public List<Schema.Competitor__c> plantlist {get; set;}
    public String groupname {get;set;}
    public String countryname {get;set;}
    
    // Constructor method to initialize class variables
    public ev_competitorController() {
        // Retrieve parameters from the page reference
        String recid = ApexPages.currentPage().getParameters().get('selectedcompany');
        
        // Debug statement for debugging purposes
        System.debug('rec id from LWC==' + recid);
        
        // Query Competitor__c records based on selected company
        plantlist = [SELECT Id, Name, Aggre__c, Dolomite__c, Dolime__c, Hyd_Lime__c, Limestone__c, Quicklime__c, Nominal_Capacity_t_y__c, Estimated_Production_t_y__c 
                     FROM Competitor__c 
                     WHERE company__c = :recid];
        
        // Query and assign group name and country name based on selected company
        Competitor__c cmpdetails = [SELECT Competitor__c FROM Competitor__c WHERE Id = :recid];
        Competitor__c grpdetails = [SELECT Name, Country__c FROM Competitor__c WHERE Id = :cmpdetails.Competitor__c];
        
        // Debug statements for debugging purposes
        System.debug('company: ' + cmpdetails);
        System.debug('name: ' + grpdetails);
        
        // Assign group name and country name
        groupname = grpdetails.Name;
        countryname = grpdetails.Country__c;
        
        // Debug statement for debugging purposes
        System.debug('plantlist: ' + plantlist);
    }
    
    // Method to fetch competitor data based on company Id
    @AuraEnabled(cacheable=true)
    public static List<Competitor__c> getCompetitorData(Id cmpId) {
        // Query and return competitor data based on company Id
        return [SELECT Id, Name, Aggre__c, Dolomite__c, Dolime__c, Hyd_Lime__c, Limestone__c, Quicklime__c, Nominal_Capacity_t_y__c, Estimated_Production_t_y__c, Competitor__r.Name, Country__c 
                FROM Competitor__c 
                WHERE company__c = :cmpId];
    }
    
    // Method to fetch country data based on company Id
    @AuraEnabled(cacheable=true)
    public static Competitor__c getCountryData(Id cmpId) {
        // Query and return country data based on company Id
        Competitor__c cmpdetails = [SELECT Competitor__c FROM Competitor__c WHERE Id = :cmpId];
        return [SELECT Name, Country__c FROM Competitor__c WHERE Id = :cmpdetails.Competitor__c];
    }
}