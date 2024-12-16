/*********************************************************************************
Class Name: ev_KilnsReportController

Purpose:    1. This is the class to get the selected group's plants and related kiln reports based on the company

Please maintain only the last 5 history changes/modifications in the audit log

History of Changes:                
--------------------------------------------------------------------------------------------------------------------------
Date                                          Developer                               Comments
--------------------------------------------------------------------------------------------------------------------------
16-04-2024                                  Naganjaneya Lakshman                              Created
********************************************************************************/

public class ev_KilnsReportController { 
    //start of new changes
    public list<Schema.Competitor__c> Klintlist {get; set;}
    public list<Schema.Competitor__c> Klintlist1 {get; set;}
    public List<CompanyCompetitorMerchantVFWrapper> wrapperMerchantList { get; set; }
    public List<CompanyCompetitorMerchantVFWrapper> wrapperCaptiveList { get; set; }
    public Decimal totalNominalCapacityMerchant { get; set; }
    public Decimal totalEstimatedProductionMerchant { get; set; }
    public Decimal totalNominalCapacityCaptive { get; set; }
    public Decimal totalEstimatedProductionCaptive { get; set; }
    public String groupname { get; set; }
    public ev_KilnsReportController()
    {
        totalNominalCapacityMerchant = 0;
        totalEstimatedProductionMerchant = 0;
        totalNominalCapacityCaptive = 0;
        totalEstimatedProductionCaptive = 0;
        string curgrpid=system.currentPageReference().getParameters().get('selectedGroup');
        system.debug('curgrpid=>' + curgrpid);
        
       // String grpid = String.valueOf(curgrpid).substring(0, 15);
       // System.debug('grpid=>'+ grpid);
        
        Id groupRecId=SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Group').getRecordTypeId();
        Id companyRecId=SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        Id plantRecId=SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Plant').getRecordTypeId();
        
        system.debug('rec id form lwc=='+curgrpid);
        Competitor__c cmp= [SELECT Name from Competitor__c where Id =:curgrpid];
        groupname=cmp.Name;
        //   Klintlist=[Select Id,Company__r.Name, Limestone__c,Dolomite__c, Filler__c, Quicklime__c, Dolime__c, Blends__c,Lime_Cap_tpy__c,Nominal_Capacity_t_y__c,Estimated_Production_t_y__c,Lime_Est_tpy__c, Hydrated_Lime__c,Hydration_Cap__c,Name,
        //                          (Select Id,Plant__c,Active__c, Nbr__c, Lime_Type__c,Fuel_1__c, Fuel_2__c, Fuel_3__c from Kiln_Report__r) from Competitor__c where Competitor__c=:grpid];
        //     system.debug(Klintlist);
        
        Klintlist = [SELECT Id, Name, Type_of_Plant__c, Company__r.Name, Company__r.Competitor__r.Name, Group_Plants__c, Country__c, Limestone__c, Dolomite__c, Filler__c, Quicklime__c, Dolime__c, Blends__c, Lime_Cap_tpy__c, Nominal_Capacity_t_y__c, Estimated_Production_t_y__c, Lime_Est_tpy__c, Hydrated_Lime__c, Hydration_Cap__c,
                     (SELECT Id, Name, Plant__c, Active__c, Nbr__c, Lime_Type__c, Fuel_1__c, Fuel_2__c, Fuel_3__c FROM Kiln_Report__r) FROM Competitor__c WHERE RecordTypeId = :plantRecId AND PlantGroup_Id__c = : curgrpid AND Type_of_Plant__c = 'Merchant' ORDER BY Company__r.Name];
        
        system.debug(Klintlist);
        
        wrapperMerchantList = new List<CompanyCompetitorMerchantVFWrapper>();
        //List<CompanyCompetitorMerchantVFWrapper> wrapperMerchantList = new List<CompanyCompetitorMerchantVFWrapper>();
        List<Competitor__c> PL = new List<Competitor__c>();
        List<String> companyNames = new List<String>();
        List<Competitor__c> competitors = new List<Competitor__c>();
        
        for(Integer i=0;i<=Klintlist.size()-1;i++){
            for(Integer j=0;j<=Klintlist.size()-1;j++){
                If(Klintlist[i].Company__r.Name == Klintlist[j].Company__r.Name && !companyNames.contains(Klintlist[i].Company__r.Name)){
                    //Competitor__c c =new Competitor__c();
                    //c=Klintlist[j];  
                    PL.add(Klintlist[j]);
                    system.debug('PL' + PL);
                } 
            }
            If(!companyNames.contains(Klintlist[i].Company__r.Name)){
                companyNames.add(Klintlist[i].Company__r.Name);
                CompanyCompetitorMerchantVFWrapper wrapper = new CompanyCompetitorMerchantVFWrapper();
                
                Wrapper.companyName = Klintlist[i].Company__r.Name;
                Wrapper.groupName = Klintlist[i].Group_Plants__c;
                Wrapper.countryName = Klintlist[i].Country__c;
                
                integer companyNominalCapacity = 0;
                integer companyEstimatedProduction = 0;
                
                
                for (Competitor__c plant : PL) {
                    companyNominalCapacity += plant.Nominal_Capacity_t_y__c != null ? integer.valueof(plant.Nominal_Capacity_t_y__c) : 0;
                    companyEstimatedProduction += plant.Estimated_Production_t_y__c != null ? integer.valueof(plant.Estimated_Production_t_y__c) : 0;
                }
                
                // Set totals in the wrapper
                wrapper.totalNominalCapacity = companyNominalCapacity;
                wrapper.totalEstimatedProduction = companyEstimatedProduction;
                
                // Add to the global totals
                totalNominalCapacityMerchant += companyNominalCapacity;
                totalEstimatedProductionMerchant += companyEstimatedProduction;
                wrapper.competitor.addAll(PL);
                wrapperMerchantList.add(wrapper);
                PL.clear();
            }
        }
        
        system.debug('wrapperMerchantList=>' + wrapperMerchantList);
        
        Klintlist1 = [SELECT Id, Name, Type_of_Plant__c, Company__r.Name, Company__r.Competitor__r.Name, Group_Plants__c, Country__c, Limestone__c, Dolomite__c, Filler__c, Quicklime__c, Dolime__c, Blends__c, Lime_Cap_tpy__c, Nominal_Capacity_t_y__c, Estimated_Production_t_y__c, Lime_Est_tpy__c, Hydrated_Lime__c, Hydration_Cap__c,
                      (SELECT Id, Name, Plant__c, Active__c, Nbr__c, Lime_Type__c, Fuel_1__c, Fuel_2__c, Fuel_3__c FROM Kiln_Report__r) FROM Competitor__c WHERE RecordTypeId = :plantRecId AND PlantGroup_Id__c = : curgrpid AND Type_of_Plant__c='Captive' ORDER BY Company__r.Name];
        
        system.debug(Klintlist1);
        
        wrapperCaptiveList = new List<CompanyCompetitorMerchantVFWrapper>();
        //List<CompanyCompetitorMerchantVFWrapper> wrapperCaptiveList = new List<CompanyCompetitorMerchantVFWrapper>();
        List<Competitor__c> PL1 = new List<Competitor__c>();
        List<String> companyNames1 = new List<String>();
        List<Competitor__c> competitors1 = new List<Competitor__c>();
        for(Integer i=0;i<=Klintlist1.size()-1;i++){
            for(Integer j=0;j<=Klintlist1.size()-1;j++){
                If(Klintlist1[i].Company__r.Name == Klintlist1[j].Company__r.Name && !companyNames1.contains(Klintlist1[i].Company__r.Name)){
                    //Competitor__c c =new Competitor__c();
                    //c=Klintlist1[j];  
                    PL1.add(Klintlist1[j]);
                    system.debug('PL1' + PL1);
                } 
            }
            If(!companyNames1.contains(Klintlist1[i].Company__r.Name)){
                companyNames1.add(Klintlist1[i].Company__r.Name);
                CompanyCompetitorMerchantVFWrapper wrapper = new CompanyCompetitorMerchantVFWrapper();
                Wrapper.companyName = Klintlist1[i].Company__r.Name;
                Wrapper.groupName = Klintlist1[i].Group_Plants__c;
                Wrapper.countryName = Klintlist1[i].Country__c;
                decimal companyNominalCapacity = 0;
                decimal companyEstimatedProduction = 0;
                
                for (Competitor__c plant : PL1) {
                    companyNominalCapacity += plant.Nominal_Capacity_t_y__c != null ?  plant.Nominal_Capacity_t_y__c  : 0;
                    companyEstimatedProduction += plant.Estimated_Production_t_y__c != null ?  plant.Estimated_Production_t_y__c  : 0;
                }
                
                // Set totals in the wrapper
                wrapper.totalNominalCapacity = companyNominalCapacity;
                wrapper.totalEstimatedProduction = companyEstimatedProduction;
                
                // Add to the global totals
                totalNominalCapacityCaptive += companyNominalCapacity;
                totalEstimatedProductionCaptive += companyEstimatedProduction;
                
                wrapper.competitor.addAll(PL1);
                wrapperCaptiveList.add(wrapper);
                PL1.clear();
            }
        }
        
        system.debug('wrapperCaptiveList=>' + wrapperCaptiveList);
        
    }
    
    public class CompanyCompetitorMerchantVFWrapper {
        public String companyName { get; set; }
        public String groupName { get; set; }
        public String countryName { get; set; }
        public List<Competitor__c> competitor { get; set; }
        public Decimal totalEstimatedProduction { get; set; }
        public Decimal totalNominalCapacity { get; set; }
        
        
        public CompanyCompetitorMerchantVFWrapper() {
            competitor = new List<Competitor__c>();
            totalEstimatedProduction = 0;
            totalNominalCapacity = 0;
        }
    }
    
    public class CompanyCompetitorCaptiveVFWrapper {
        public String companyName { get; set; }
        public String groupName { get; set; }
        public String countryName { get; set; }
        public Decimal totalEstimatedProduction { get; set; }
        public Decimal totalNominalCapacity { get; set; }
        
        
        public List<Competitor__c> competitor { get; set; }
        
        public CompanyCompetitorCaptiveVFWrapper() {
            competitor = new List<Competitor__c>();
            totalEstimatedProduction = 0;
            totalNominalCapacity = 0;
        }
    }
     public Decimal getTotalEstimProdTpy() {
        return totalEstimatedProductionMerchant + totalEstimatedProductionCaptive;
    }

    // Getter for total nominal capacity
    public Decimal getTotalNomProdTpy() {
        return totalNominalCapacityMerchant + totalNominalCapacityCaptive;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CompanyCompetitorMerchantWrapper> getCompaniesWithCompetitorsMerchant(String selectedGroup) {
        System.debug('Group Id: ' + selectedGroup);
        System.debug('getCompaniesWithCompetitorsMerchant');
        
        Id plantRecId = SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Plant').getRecordTypeId();
        System.debug('plantRecId: ' + plantRecId);
        
        List<Competitor__c> plantkilngrouplist = [SELECT Id, Name, Type_of_Plant__c, Company__r.Name, Company__r.Competitor__r.Name, Group_Plants__c, Country__c, Limestone__c, Dolomite__c, Filler__c, Quicklime__c, Dolime__c, Blends__c, Lime_Cap_tpy__c, Nominal_Capacity_t_y__c, Estimated_Production_t_y__c, Lime_Est_tpy__c, Hydrated_Lime__c, Hydration_Cap__c,
                                                  (SELECT Id, Name, Plant__c, Active__c, Nbr__c, Lime_Type__c, Fuel_1__c, Fuel_2__c, Fuel_3__c FROM Kiln_Report__r) FROM Competitor__c WHERE RecordTypeId = :plantRecId AND PlantGroup_Id__c = :selectedGroup AND Type_of_Plant__c = 'Merchant' ORDER BY Company__r.Name];
        
        System.debug('plantkilngrouplist: ' + plantkilngrouplist);
        
        List<CompanyCompetitorMerchantWrapper> wrapperList = new List<CompanyCompetitorMerchantWrapper>();
        
        // Map to store company name as key and list of competitors as value
        Map<String, List<Competitor__c>> companyCompetitorMap = new Map<String, List<Competitor__c>>();
        
        // Initialize total variables
        Decimal totalEstimatedProduction = 0;
        Decimal totalNominalCapacity = 0;
        
        // Loop through the plantkilngrouplist and group by Company
        for (Competitor__c plantRecord : plantkilngrouplist) {
            String companyName = plantRecord.Company__r.Name;
            
            // If the company is already in the map, add the plant to its list
            if (companyCompetitorMap.containsKey(companyName)) {
                companyCompetitorMap.get(companyName).add(plantRecord);
            } else {
                // If the company is not in the map, create a new entry
                companyCompetitorMap.put(companyName, new List<Competitor__c>{plantRecord});
            }
        }
        
        // Process each company
        for (String companyName : companyCompetitorMap.keySet()) {
            CompanyCompetitorMerchantWrapper wrapper = new CompanyCompetitorMerchantWrapper();
            wrapper.companyName = companyName;
            
            // Get the list of competitors/plants for the current company
            List<Competitor__c> competitorslst = companyCompetitorMap.get(companyName);
            
            // Initialize totals for the company
            Decimal totalEstimatedProductionForCompany = 0;
            Decimal totalNominalCapacityForCompany = 0;
            
            for (Competitor__c competitor : competitorslst) {
                totalNominalCapacityForCompany += (competitor.Estimated_Production_t_y__c != null ? competitor.Estimated_Production_t_y__c : 0);
                totalEstimatedProductionForCompany += (competitor.Nominal_Capacity_t_y__c != null ? competitor.Nominal_Capacity_t_y__c : 0);
                wrapper.groupName = competitor.Group_Plants__c;
                wrapper.countryName = competitor.Country__c;
            }
            
            // Add the competitors to the wrapper
            wrapper.competitor.addAll(competitorslst);
            
            // Assign the computed totals to the wrapper
            wrapper.overallTotalEstimProdTpy = totalEstimatedProductionForCompany;
            wrapper.overallTotalNomCapTpy = totalNominalCapacityForCompany;
            
            // Add the wrapper to the list
            wrapperList.add(wrapper);
            
            // Accumulate the total values for all companies
            totalEstimatedProduction += totalEstimatedProductionForCompany;
            totalNominalCapacity += totalNominalCapacityForCompany;
            
            System.debug('Total Estimated Production for company ' + companyName + ': ' + wrapper.overallTotalEstimProdTpy);
            System.debug('Total Nominal Capacity for company ' + companyName + ': ' + wrapper.overallTotalNomCapTpy);
        }
        
        // Debug logs for overall totals
        System.debug('Total Estimated Production across all companies: ' + totalEstimatedProduction);
        System.debug('Total Nominal Capacity across all companies: ' + totalNominalCapacity);
        
        System.debug('Final Wrapper List Size: ' + wrapperList.size());
        
        return wrapperList;
    }
    
    
    
    // Wrapper class to hold company name, competitor details, and kiln reports
    public class CompanyCompetitorMerchantWrapper {
        @AuraEnabled public String companyName;
        @AuraEnabled public String groupName;
        @AuraEnabled public String countryName;
        @AuraEnabled public List<Competitor__c> competitor;
        @AuraEnabled public Decimal overallTotalEstimProdTpy; 
        @AuraEnabled public Decimal overallTotalNomCapTpy;  
        //@AuraEnabled public List<Kiln_Report__c> kilnReports;
        public CompanyCompetitorMerchantWrapper(){
            competitor = new List<Competitor__c>();
            overallTotalEstimProdTpy = 0; 
            overallTotalNomCapTpy = 0; 
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CompanyCompetitorCaptiveWrapper> getCompaniesWithCompetitorsCaptive(String selectedGroup) {
        System.debug('Group Id: ' + selectedGroup);
        
        Id plantRecId = SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Plant').getRecordTypeId();
        System.debug('plantRecId: ' + plantRecId);
        
        List<Competitor__c> plantkilngrouplist = [SELECT Id, Name, Type_of_Plant__c, Company__r.Name, Company__r.Competitor__r.Name, Group_Plants__c, Country__c, Limestone__c, Dolomite__c, Filler__c, Quicklime__c, Dolime__c, Blends__c, Lime_Cap_tpy__c, Nominal_Capacity_t_y__c, Estimated_Production_t_y__c, Lime_Est_tpy__c, Hydrated_Lime__c, Hydration_Cap__c,
                                                  (SELECT Id, Name, Plant__c, Active__c, Nbr__c, Lime_Type__c, Fuel_1__c, Fuel_2__c, Fuel_3__c FROM Kiln_Report__r) FROM Competitor__c WHERE RecordTypeId = :plantRecId AND PlantGroup_Id__c = :selectedGroup AND Type_of_Plant__c='Captive' ORDER BY Company__r.Name];
        
        System.debug('plantkilngrouplist: ' + plantkilngrouplist);
        
        List<CompanyCompetitorCaptiveWrapper> wrapperList = new List<CompanyCompetitorCaptiveWrapper>();
        Map<String, List<Competitor__c>> companyCompetitorMap = new Map<String, List<Competitor__c>>();
        
        // Initialize total variables
        Decimal totalEstimatedProduction = 0;
        Decimal totalNominalCapacity = 0;
        
        // Loop through the plantkilngrouplist and group by Company
        for (Competitor__c plantRecord : plantkilngrouplist) {
            String companyName = plantRecord.Company__r.Name;
            
            if (companyCompetitorMap.containsKey(companyName)) {
                companyCompetitorMap.get(companyName).add(plantRecord);
            } else {
                companyCompetitorMap.put(companyName, new List<Competitor__c>{plantRecord});
            }
        }
        
        // Process each company
        for (String companyName : companyCompetitorMap.keySet()) {
            CompanyCompetitorCaptiveWrapper wrapper = new CompanyCompetitorCaptiveWrapper();
            wrapper.companyName = companyName;
            
            List<Competitor__c> competitorslst = companyCompetitorMap.get(companyName);
            
            Decimal totalEstimatedProductionForCompany = 0;
            Decimal totalNominalCapacityForCompany = 0;
            
            for (Competitor__c competitor : competitorslst) {
                totalNominalCapacityForCompany += (competitor.Estimated_Production_t_y__c != null ? competitor.Estimated_Production_t_y__c : 0);
                totalEstimatedProductionForCompany += (competitor.Nominal_Capacity_t_y__c != null ? competitor.Nominal_Capacity_t_y__c : 0);
                wrapper.groupName = competitor.Group_Plants__c;
                wrapper.countryName = competitor.Country__c;
            }
            
            wrapper.competitor.addAll(competitorslst);
            wrapper.overallTotalEstimProdTpy = totalEstimatedProductionForCompany;
            wrapper.overallTotalNomCapTpy = totalNominalCapacityForCompany;
            
            wrapperList.add(wrapper);
            
            totalEstimatedProduction += totalEstimatedProductionForCompany;
            totalNominalCapacity += totalNominalCapacityForCompany;
            
            System.debug('Total Estimated Production for company ' + companyName + ': ' + wrapper.overallTotalEstimProdTpy);
            System.debug('Total Nominal Capacity for company ' + companyName + ': ' + wrapper.overallTotalNomCapTpy);
        }
        
        System.debug('Total Estimated Production across all companies: ' + totalEstimatedProduction);
        System.debug('Total Nominal Capacity across all companies: ' + totalNominalCapacity);
        
        System.debug('Final Wrapper List Size: ' + wrapperList.size());
        
        return wrapperList;
    }
    
    // Wrapper class to hold company name, competitor details, and kiln reports
    public class CompanyCompetitorCaptiveWrapper {
        @AuraEnabled public String companyName;
        @AuraEnabled public String groupName;
        @AuraEnabled public String countryName;
        @AuraEnabled public List<Competitor__c> competitor;
        @AuraEnabled public Decimal totalEstimProdTpy; // Total Estim. Prod tpy for Captive
        @AuraEnabled public Decimal totalNomCapTpy; // Total Nom. Cap tpy for Captive
        @AuraEnabled public Decimal overallTotalEstimProdTpy; 
        @AuraEnabled public Decimal overallTotalNomCapTpy; 
        //@AuraEnabled public List<Kiln_Report__c> kilnReports;
        public CompanyCompetitorCaptiveWrapper(){
            competitor = new List<Competitor__c>();
            totalEstimProdTpy = 0;
            totalNomCapTpy = 0;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Competitor__c getGroupDetails(Id groupId) {
        return [SELECT Name from Competitor__c where Id =:groupId];
    }
}