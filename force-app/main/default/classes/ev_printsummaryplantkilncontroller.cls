/*********************************************************************************
Class Name: ev_printsummaryplantkilncontroller

Purpose:    1. This is the class to get the selected plant and related kiln report details

Please maintain only the last 5 history changes/modifications in the audit log

History of Changes:                
--------------------------------------------------------------------------------------------------------------------------
Date                                          Developer                               Comments
--------------------------------------------------------------------------------------------------------------------------
05-02-2024                                  Naganjaneya Lakshman                              Created
********************************************************************************/

public with sharing class ev_printsummaryplantkilncontroller {
    public list<Schema.Competitor__c> plantlist {get; set;}
    public list<Schema.Kiln_Report__c> kilnlist {get; set;}
    public string countryname {get;set;}
    public string groupname {get;set;}
    public string companyname {get;set;}

    public ev_printsummaryplantkilncontroller()
        {
           string recid=system.currentPageReference().getParameters().get('selectedPlant');
           system.debug('rec id form lwc=='+recid);
            plantlist= [SELECT id ,Name,Country__c,Group_Plants__c,Plant_Company_Name__c,Competitor__c,Competitor__r.Name,Company__r.Name,Aggre__c,Dolomite__c,Dolime__c,Hyd_Lime__c,Limestone__c,
            Total_Employees__c, Quicklime__c, Stone_Owner__c, Location_Quary__c, Geological_Comments__c, Milling__c, Milling_Info__c, Logistic_road__c, Logistic_train__c, 
            Logistic_ship__c, Storage__c, Environment__c, Comments__c, Annual_Extraction_t_y__c, Estimated_Production_t_y__c, Nominal_Capacity_t_y__c, 
            Number_of_Kilns__c, Hydration_Cap__c, PCC_quality_lime__c, Milk_of_lime__c, Putty_lime__c,Free_Capacity_t_y__c
           
                        FROM Competitor__c
            WHERE id =:recid   ORDER BY Name];
         
            Competitor__c cmp= [SELECT Name, Country__c, Group_Plants__c, Plant_Company_Name__c from Competitor__c where Id =:recid];
            countryname=cmp.Country__c;
            groupname=cmp.Group_Plants__c;
            companyname=cmp.Plant_Company_Name__c;
            system.debug('countryname' + countryname);

            kilnlist= [SELECT Id, Name, Kiln__c, Nbr__c, Est_Prod_t_y__c, Cap_t_y__c, Cap_t_d__c, Active__c, Fuel_1__c, 
            Fuel_2__c, Fuel_3__c, Lime_Type__c, Brand__c, Comment__c, Start_Up_Date__c, Renew_Date__c, Plant__c
            FROM Kiln_Report__c WHERE Plant__r.id = :recid  ORDER BY Name];
        }

    @AuraEnabled(cacheable=true)
    public static List<Competitor__c> getProductDetails(id plandId) {
        List<Competitor__c> lstcmp = [select id ,Name,Country__c,Group_Plants__c,Plant_Company_Name__c,Competitor__c,Competitor__r.Name,Company__r.Name,Aggre__c,Dolomite__c,Dolime__c,Hyd_Lime__c,Limestone__c,
        Total_Employees__c, Quicklime__c, Stone_Owner__c, Location_Quary__c, Geological_Comments__c, Milling__c, Milling_Info__c, Logistic_road__c, Logistic_train__c, 
        Logistic_ship__c, Storage__c, Environment__c, Comments__c, Annual_Extraction_t_y__c, Estimated_Production_t_y__c, Nominal_Capacity_t_y__c, 
        Number_of_Kilns__c, Hydration_Cap__c, PCC_quality_lime__c, Milk_of_lime__c, Putty_lime__c,Free_Capacity_t_y__c
        FROM Competitor__c 
        WHERE id = :plandId];
        
        system.debug(lstcmp);
        return lstcmp;
    }

    @AuraEnabled(cacheable=true)
    public static list<Kiln_Report__c> KilnsDetails(String plandId){
        system.debug('PlantId' + plandId);
        try {
            list<Kiln_Report__c> kRlist = new list<Kiln_Report__c>();
            kRlist = [SELECT Id, Name, Kiln__c, Nbr__c, Est_Prod_t_y__c, Cap_t_y__c, Cap_t_d__c, Active__c, Fuel_1__c, 
            Fuel_2__c, Fuel_3__c, Lime_Type__c, Brand__c, Comment__c, Start_Up_Date__c, Renew_Date__c, Plant__c
            FROM Kiln_Report__c 
            WHERE Plant__r.id = :plandId];
            return kRlist;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}