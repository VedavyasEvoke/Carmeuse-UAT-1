@isTest
public class ev_CompetitorTriggerHandlerTest {
@isTest
    public static void updateCompanyFieldsTest(){
        
        Competitor__c company = new Competitor__c();
        company.Name = 'TestPlant';
        company.RecordTypeId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        company.Estimated_Production_t_y__c = 2000;
        company.Nominal_Capacity_t_y__c = 5000;
        insert company;

        
        
        String plantRecordTypeId =  Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Plant').getRecordTypeId();
        Competitor__c competitor = new Competitor__c();
        competitor.Name = 'TestPlant';
        competitor.RecordTypeId = plantRecordTypeId;
        competitor.Estimated_Production_t_y__c = 2000;
        competitor.Nominal_Capacity_t_y__c = 5000;
        competitor.Company__c = company.id;
        insert competitor;
        
        competitor.Estimated_Production_t_y__c = 2000;
        competitor.Nominal_Capacity_t_y__c = 5000;
        update competitor;
        
        Test.startTest();
        Delete competitor;
        Test.stopTest();
    }
    
    @isTest
    public static void updateGroupFieldsTest(){
        
        Competitor__c groupRecord = new Competitor__c();
        groupRecord.Name = 'TestComapny';
        groupRecord.RecordTypeId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Group').getRecordTypeId();
        groupRecord.Estimated_Production_t_y__c = 2000;
        groupRecord.Nominal_Capacity_t_y__c = 5000;
        insert groupRecord;

        
        
        String companyRecordTypeId =  Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        Competitor__c competitor = new Competitor__c();
        competitor.Name = 'TestCompany';
        competitor.RecordTypeId = companyRecordTypeId;
        competitor.Estimated_Production_t_y__c = 2000;
        competitor.Nominal_Capacity_t_y__c = 5000;
        competitor.Competitor__c = groupRecord.id;
        insert competitor;
        
        competitor.Estimated_Production_t_y__c = 2000;
        competitor.Nominal_Capacity_t_y__c = 5000;
        update competitor;
        
        Test.startTest();
        Delete competitor;
        Test.stopTest();
    }
    @testSetup
    static void setupTestData() {
        String plantRecordTypeId =  Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Plant').getRecordTypeId();
        String companyRecordTypeId =  Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        String groupRecordTypeId =  Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Group').getRecordTypeId();

    // Create Group Competitor
        Competitor__c groupRec = new Competitor__c(
            Name = 'Group Competitor',
            RecordTypeId = groupRecordTypeId
        );
        insert groupRec;
        
        // Create Company Competitor
        Competitor__c company = new Competitor__c(
            Name = 'Company Competitor',
            Competitor__c = groupRec.Id,
            RecordTypeId = companyRecordTypeId
        );
        insert company;
        
        // Create Plant Competitors
        Competitor__c plant1 = new Competitor__c(
            Name = 'Plant Competitor 1',
            Company__c = company.Id,
            Nominal_Capacity_t_y__c = 100,
            Estimated_Production_t_y__c = 150,
            RecordTypeId = plantRecordTypeId
        );
        insert plant1;
        
        Competitor__c plant2 = new Competitor__c(
            Name = 'Plant Competitor 2',
            Company__c = company.Id,
            Nominal_Capacity_t_y__c = 200,
            Estimated_Production_t_y__c = 250,
            RecordTypeId = plantRecordTypeId
        );
        insert plant2;
    }
    
    @isTest
    static void testUpdateCompanyFields() {
        // Retrieve the test data
        Competitor__c plant1 = [SELECT Id, Company__c FROM Competitor__c WHERE Name = 'Plant Competitor 1' LIMIT 1];
        Competitor__c plant2 = [SELECT Id, Company__c FROM Competitor__c WHERE Name = 'Plant Competitor 2' LIMIT 1];
        
        // Update one of the plants to trigger the updateCompanyFields method
        plant1.Nominal_Capacity_t_y__c = 150;
        update plant1;
        
        // Verify that the company fields are updated correctly
        Competitor__c company = [SELECT Nominal_Capacity_t_y__c, Estimated_Production_t_y__c FROM Competitor__c WHERE Id = :plant1.Company__c LIMIT 1];
        System.assertEquals(350, company.Nominal_Capacity_t_y__c, 'Total Nominal Capacity should be 350');
        System.assertEquals(400, company.Estimated_Production_t_y__c, 'Total Estimated Production should be 400');
    }
    
    @isTest
    static void testAfterPlantDelete() {
        // Retrieve the test data
        Competitor__c plant1 = [SELECT Id, Company__c FROM Competitor__c WHERE Name = 'Plant Competitor 1' LIMIT 1];
        
        // Delete a plant to trigger the afterPlantDelete method
        delete plant1;
        
        // Verify that the company fields are updated correctly
        Competitor__c company = [SELECT Nominal_Capacity_t_y__c, Estimated_Production_t_y__c FROM Competitor__c WHERE Id = :plant1.Company__c LIMIT 1];
        System.assertEquals(200, company.Nominal_Capacity_t_y__c, 'Total Nominal Capacity should be 200 after deletion');
        System.assertEquals(250, company.Estimated_Production_t_y__c, 'Total Estimated Production should be 250 after deletion');
    }
    
    @isTest
    static void testAfterCompanyDelete() {
        // Retrieve the test data
        Competitor__c company = [SELECT Id, Competitor__c FROM Competitor__c WHERE Name = 'Company Competitor' LIMIT 1];
        
        // Delete the company to trigger the afterCompanyDelete method
        delete company;
        
        // Verify that the group fields are updated correctly
        Competitor__c groupRec = [SELECT Nominal_Capacity_t_y__c, Estimated_Production_t_y__c FROM Competitor__c WHERE Id = :company.Competitor__c LIMIT 1];
        //System.assertEquals(0, groupRec.Nominal_Capacity_t_y__c, 'Total Nominal Capacity should be 0 after deletion');
        //System.assertEquals(0, groupRec.Estimated_Production_t_y__c, 'Total Estimated Production should be 0 after deletion');
    }
    
    
}