/*/*******************************************************************************************

* @Name         ev_CompetitorTriggerHandler 

* @Author       Purnachandar Padishala

* @Date         6/6/2024
** Test Class name : ev_CompetitorTriggerHandlerTest
* @Description  :  
. This class, `ev_CompetitorTriggerHandler`, is responsible for handling updates and rollups of fields
. such as Nominal Capacity, Estimated Production, and the total number of kilns in competitor records 
.(Company and Plant levels). It processes changes in related Plant records and rolls up the relevant 
.data to the Company level and further to the Group level.
*******************************************************************************************/

/* MODIFICATION LOG

* Version          Developer          Date               Description

*-------------------------------------------------------------------------------------------

* 59.0             Juli Kumari      10/16/2024          Initial Creation/Modification                                                    

*******************************************************************************************/



public with sharing class ev_CompetitorTriggerHandler {
    public static Boolean runOnce = true;
    
/**
* This method, `updateCompanyFields`, processes a list of Plant records and rolls up the fields 
* such as Nominal Capacity, Estimated Production, and total number of kilns to the Company level.
* 
* @param newPlantList - List of new Competitor__c records (Plant records).
* @param oldMap - A map of old Competitor__c records for comparison.
* @Author       Juli Kumari 
*/    
    private static set<Id> processedRecordIds = new set<Id>();
    public static void updateCompanyFields(list<Competitor__c> newPlantList, Map<id,Competitor__c> oldMap) {
        processedRecordIds.clear();
        system.debug('newPlantList   '+newPlantList.size());
        Set<Id> companyIds = new Set<Id>();
        list<Competitor__c> companyCompetitorListToUpdate = new list<Competitor__c>();
        map<id,list<Competitor__c>> companyIdWithListOfPlantMap = new map<id,list<Competitor__c>>();
        String plantRecordTypeId =  Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Plant').getRecordTypeId();
        // Collect  plants ids
        for(Competitor__c competitor : newPlantList) {
            system.debug('competitor   '+competitor);
            system.debug('competitor   '+competitor.Company__c);
            if (!processedRecordIds.contains(competitor.Id) 
                && competitor.Company__c != null && competitor.RecordTypeId == plantRecordTypeId
                && ((competitor.Nominal_Capacity_t_y__c != null  || competitor.Estimated_Production_t_y__c != null || competitor.Total_No_Kilns__c != null))) {
                    companyIds.add(competitor.Company__c);
                    processedRecordIds.add(competitor.Id);
                }
            system.debug('companyId  '+companyIds);
            system.debug('processedRecordIds  '+processedRecordIds);
        }
        
        
        for(Competitor__c plant :[SELECT Id, Nominal_Capacity_t_y__c, Estimated_Production_t_y__c,Total_No_Kilns__c,
                                  Company__c FROM Competitor__c 
                                  WHERE  Company__c IN :companyIds ]){ 
                                      system.debug('plant  '+plant);
                                      if(plant.Company__c != null){
                                          if (!companyIdWithListOfPlantMap.containsKey(plant.Company__c)) {
                                              companyIdWithListOfPlantMap.put(plant.Company__c, new List<Competitor__c>{plant});
                                              system.debug('companyIdWithListOfPlantMap36   '+companyIdWithListOfPlantMap);
                                          } else {
                                              companyIdWithListOfPlantMap.get(plant.Company__c).add(plant);
                                              system.debug('companyIdWithListOfPlantMap39   '+companyIdWithListOfPlantMap);
                                          }                         
                                      }
                                  }
        
        System.debug('companyIdWithListOfPlantMap: ' + companyIdWithListOfPlantMap); 
        System.debug('processedRecordIds: ' + processedRecordIds);
        
        for(Id compId : companyIdWithListOfPlantMap.Keyset()){
            System.debug('companyIdWithListOfPlantMap: ' + companyIdWithListOfPlantMap.get(compId));
            Decimal totalNominalCapacity = 0;
            Decimal totalEstimatedProduction = 0;
            Decimal totalNumberOfKilns = 0;
            Competitor__c companyRec = new Competitor__c();
            for(Competitor__c plantRec : companyIdWithListOfPlantMap.get(compId)){
                system.debug('plantRec54  '+plantRec);
                totalNominalCapacity += plantRec.Nominal_Capacity_t_y__c != null ? plantRec.Nominal_Capacity_t_y__c : 0;
                totalEstimatedProduction += plantRec.Estimated_Production_t_y__c != null ? plantRec.Estimated_Production_t_y__c : 0;
                totalNumberOfKilns += plantRec.Total_No_Kilns__c != null ? plantRec.Total_No_Kilns__c : 0;
            }
            system.debug('totalNumberOfKilns   '+totalNumberOfKilns);
            companyRec.Nominal_Capacity_t_y__c = totalNominalCapacity;
            companyRec.Estimated_Production_t_y__c = totalEstimatedProduction;
            companyRec.Total_No_Kilns__c = totalNumberOfKilns;
            companyRec.Id = compId;
            companyCompetitorListToUpdate.add(companyRec);
        }
        
        System.debug('companies to update: ' + companyCompetitorListToUpdate);
        System.debug('companies to update: ' + companyCompetitorListToUpdate.size());
        // Perform the update
        if (!companyCompetitorListToUpdate.isEmpty()) {
            try {
                update companyCompetitorListToUpdate;
                RollupCompanyToGroupFields(companyIds);
                System.debug('Update successful');
            } catch (DmlException e) {
                System.debug('Error updating companies: ' + e.getMessage());
            }
        }
    }
    
    /**
* @Author       Juli Kumari 
* This method, `RollupCompanyToGroupFields`, performs a rollup of fields such as Nominal Capacity,
* Estimated Production, and total number of kilns from Company to Group level.
* 
* @param companyIds - Set of company IDs whose related group records need to be updated.
*/
    
    public static void RollupCompanyToGroupFields(set<Id> companyIds) {
        
        list<Competitor__c> groupCompetitorListToUpdate = new list<Competitor__c>();
        map<id,list<Competitor__c>> groupIdWithListOfCompanyMap = new map<id,list<Competitor__c>>();
        String companyRecordTypeId =  Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        String groupRecordTypeId =  Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Group').getRecordTypeId();
        Set<Id> groupIds = new Set<Id>();
        for(Competitor__c company :[SELECT Id, Competitor__c 
                                    FROM Competitor__c 
                                    WHERE  Id  IN :companyIds AND Competitor__c != null
                                    AND recordTypeId =: companyRecordTypeId]){
                                        groupIds.add(company.Competitor__c); 
                                    }
        
        for(Competitor__c company :[SELECT Id, Nominal_Capacity_t_y__c, Estimated_Production_t_y__c,Total_No_Kilns__c, 
                                    Competitor__c FROM Competitor__c 
                                    WHERE  Competitor__c  IN :groupIds 
                                    AND recordTypeId =: companyRecordTypeId]){ 
                                        system.debug('company    '+company);
                                        if(company.Competitor__c != null){
                                            if (!groupIdWithListOfCompanyMap.containsKey(company.Competitor__c)) {
                                                groupIdWithListOfCompanyMap.put(company.Competitor__c, new List<Competitor__c>{company});
                                            } else {
                                                groupIdWithListOfCompanyMap.get(company.Competitor__c).add(company);
                                            }                         
                                        }
                                    }
        
        System.debug('groupIdWithListOfCompanyMap: ' + groupIdWithListOfCompanyMap); 
        
        for(Id compId : groupIdWithListOfCompanyMap.Keyset()){
            System.debug('groupIdWithListOfCompanyMap: ' + groupIdWithListOfCompanyMap.keyset());
            System.debug('groupIdWithListOfCompanyMap: ' + groupIdWithListOfCompanyMap.get(compId));
            Decimal totalNominalCapacity = 0;
            Decimal totalEstimatedProduction = 0;
            Decimal totalNumberOfKilns = 0;
            Competitor__c companyRec = new Competitor__c();
            for(Competitor__c plantRec : groupIdWithListOfCompanyMap.get(compId)){
                system.debug('plantRec119  '+plantRec);
                totalNominalCapacity += plantRec.Nominal_Capacity_t_y__c != null ? plantRec.Nominal_Capacity_t_y__c : 0;
                totalEstimatedProduction += plantRec.Estimated_Production_t_y__c != null ? plantRec.Estimated_Production_t_y__c : 0;
                totalNumberOfKilns += (plantRec.Total_No_Kilns__c != null) ? plantRec.Total_No_Kilns__c : 0;
            }
            system.debug('totalNumberOfKilns124  '+totalNumberOfKilns);
            companyRec.Nominal_Capacity_t_y__c = totalNominalCapacity;
            companyRec.Estimated_Production_t_y__c = totalEstimatedProduction;
            companyRec.Total_No_Kilns__c = totalNumberOfKilns;
            companyRec.Id = compId;
            groupCompetitorListToUpdate.add(companyRec);
        }
        
        System.debug('companies to update: ' + groupCompetitorListToUpdate);
        System.debug('companies to update: ' + groupCompetitorListToUpdate.size());
        // Perform the update
        if (!groupCompetitorListToUpdate.isEmpty()) {
            try {
                update groupCompetitorListToUpdate;
                System.debug('Update successful');
            } catch (DmlException e) {
                System.debug('Error updating companies: ' + e.getMessage());
            }
        }
    }
    
    
    /* ----------------------- write delete method for plant, company level ---------------------------*/
    /**
* @Author       Juli Kumari 
* This method, `afterPlantDelete`, handles the deletion of Plant records. It updates the corresponding
* Company records by recalculating the rolled-up fields.
* 
* @param deleteRecordList - List of Plant records that are being deleted.
*/
    
    public static void afterPlantDelete(List<Competitor__c> deleteRecordList) {
        system.debug('deleteRecordList   '+deleteRecordList);
        Set<Id> companyIds = new Set<Id>();
        Map<Id, List<Competitor__c>> companyToCompetitorsMap = new Map<Id, List<Competitor__c>>();
        List<Competitor__c> companyListToUpdate = new List<Competitor__c>();
        String plantRecordTypeId =  Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Plant').getRecordTypeId();
        // Collect Company and Group IDs to update
        for (Competitor__c comp : deleteRecordList) {
            if (comp.Company__c != null && comp.RecordTypeId == plantRecordTypeId) {
                companyIds.add(comp.Company__c);
                system.debug('companyIds   '+companyIds);
            }
            
        }
        
        for(Competitor__c plant :[SELECT Id, Nominal_Capacity_t_y__c,Total_No_Kilns__c, Estimated_Production_t_y__c,Competitor__c,
                                  Company__c FROM Competitor__c 
                                  WHERE  Company__c IN :companyIds]){
                                      
                                      system.debug('plant  '+plant);
                                      if(plant.Company__c != null){
                                          if (!companyToCompetitorsMap.containsKey(plant.Company__c)) {
                                              companyToCompetitorsMap.put(plant.Company__c, new List<Competitor__c>{plant});
                                          } else {
                                              companyToCompetitorsMap.get(plant.Company__c).add(plant);
                                          }                         
                                      }
                                      
                                  }
        for(Id compId : companyToCompetitorsMap.Keyset()){
            System.debug('companyToCompetitorsMap: ' + companyToCompetitorsMap.get(compId));
            //Decimal totalNumberOfKilns = 0;
            Decimal totalNominalCapacity = 0;
            Decimal totalEstimatedProduction = 0;
            Competitor__c companyRec = new Competitor__c();
            for(Competitor__c plantRec : companyToCompetitorsMap.get(compId)){
                totalNominalCapacity += plantRec.Nominal_Capacity_t_y__c != null ? plantRec.Nominal_Capacity_t_y__c : 0;
                totalEstimatedProduction += plantRec.Estimated_Production_t_y__c != null ? plantRec.Estimated_Production_t_y__c : 0;
                //totalNumberOfKilns += plantRec.Total_No_Kilns__c != null ? plantRec.Total_No_Kilns__c : 0;
                
            }
            
            companyRec.Nominal_Capacity_t_y__c = totalNominalCapacity;
            companyRec.Estimated_Production_t_y__c = totalEstimatedProduction;
            //companyRec.Total_No_Kilns__c = totalNumberOfKilns;
            companyRec.Id = compId;
            companyListToUpdate.add(companyRec);
        }
        system.debug('companyListToUpdate   '+companyListToUpdate);
        system.debug('companyListToUpdate   '+companyListToUpdate.size());
        
        
        system.debug('companyListToUpdate 240   '+companyListToUpdate);
        if(!companyListToUpdate.isEmpty()){
            system.debug('companyListToUpdate 240   '+companyListToUpdate);
            update companyListToUpdate;
            RollupCompanyToGroupFields(companyIds);
        }
        
        
    }
    
    /**
* @Author       Juli Kumari 
* This method, `afterCompanyDelete`, handles the deletion of Company records. It updates the corresponding
* Group records by recalculating the rolled-up fields.
* 
* @param deleteRecordList - List of Company records that are being deleted.
*/
    
    public static void afterCompanyDelete(List<Competitor__c> deleteRecordList) {
        system.debug('deleteRecordList   '+deleteRecordList);
        Set<Id> companyIds = new Set<Id>();
        Set<Id> groupIds = new Set<Id>();
        Map<Id, List<Competitor__c>> groupToCompetitorsMap = new Map<Id, List<Competitor__c>>();
        List<Competitor__c> groupListToUpdate = new List<Competitor__c>();
        String companyRecordTypeId =  Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        // Collect Company and Group IDs to update
        for (Competitor__c comp : deleteRecordList) {
            
            if (comp.Competitor__c != null && comp.RecordTypeId == companyRecordTypeId) {
                groupIds.add(comp.Competitor__c);
                system.debug('groupIds  '+groupIds);
            }
        }
        
        for(Competitor__c plant :[SELECT Id, Nominal_Capacity_t_y__c, Estimated_Production_t_y__c,Competitor__c,Total_No_Kilns__c,
                                  Company__c FROM Competitor__c 
                                  WHERE Competitor__c IN :groupIds]){
                                      
                                      system.debug('plant  '+plant);
                                      
                                      if (plant.Competitor__c != null) {
                                          if (!groupToCompetitorsMap.containsKey(plant.Competitor__c)) {
                                              groupToCompetitorsMap.put(plant.Competitor__c, new List<Competitor__c>());
                                          }
                                          groupToCompetitorsMap.get(plant.Competitor__c).add(plant);
                                      }
                                  }
        
        
        /*----- calculate group -------------------------------*/
        
        for(Id compId : groupToCompetitorsMap.Keyset()){
            System.debug('groupToCompetitorsMap: ' + groupToCompetitorsMap.get(compId));
            //Decimal totalNumberOfKilns = 0;
            Decimal totalNominalCapacity = 0;
            Decimal totalEstimatedProduction = 0;
            Competitor__c companyRec = new Competitor__c();
            for(Competitor__c plantRec : groupToCompetitorsMap.get(compId)){
                totalNominalCapacity += plantRec.Nominal_Capacity_t_y__c != null ? plantRec.Nominal_Capacity_t_y__c : 0;
                totalEstimatedProduction += plantRec.Estimated_Production_t_y__c != null ? plantRec.Estimated_Production_t_y__c : 0; 
                //totalNumberOfKilns += plantRec.Total_No_Kilns__c != null ? plantRec.Total_No_Kilns__c : 0; 
            }
            
            companyRec.Nominal_Capacity_t_y__c = totalNominalCapacity;
            companyRec.Estimated_Production_t_y__c = totalEstimatedProduction;
            //
            //companyRec.Total_No_Kilns__c = totalNumberOfKilns;
            companyRec.Id = compId;
            groupListToUpdate.add(companyRec);
        }
        system.debug('groupListToUpdate   '+groupListToUpdate);
        system.debug('groupListToUpdate   '+groupListToUpdate.size());
        
        
        system.debug('groupListToUpdate 240   '+groupListToUpdate);
        if(!groupListToUpdate.isEmpty()){
            system.debug('groupListToUpdate 240   '+groupListToUpdate);
            update groupListToUpdate;
        }
    }
    
}