@isTest
public class ev_KilnsReportControllerTest {
    
    @isTest
    static void testConstructor() {
        // Create test records
        Id groupRecId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Group').getRecordTypeId();
        Id plantRecId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Plant').getRecordTypeId();
        Id companyRecId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        
        // Create a Competitor__c record for the group
        Competitor__c groupc = new Competitor__c(Name = 'Test Group', RecordTypeId = groupRecId);
        insert groupc;
        
        // Create Competitor__c records for plants and companies
        Competitor__c company = new Competitor__c(Name = 'Test Company', RecordTypeId = companyRecId,Competitor__c = groupc.Id);
        insert company;
        
        Competitor__c merchantPlant = new Competitor__c(
            Name = 'Merchant Plant 1',
            RecordTypeId = plantRecId,
            Type_of_Plant__c = 'Merchant',
            Company__c = company.Id,
           
            Nominal_Capacity_t_y__c = 1000,
            Estimated_Production_t_y__c = 1500
        );
        insert merchantPlant;
        
        Competitor__c captivePlant = new Competitor__c(
            Name = 'Captive Plant 1',
            RecordTypeId = plantRecId,
            Type_of_Plant__c = 'Captive',
            Company__c = company.Id,
             Nominal_Capacity_t_y__c = 1200,
            Estimated_Production_t_y__c = 1600
        );
        insert captivePlant;
       
        // Create an instance of the controller with the group ID
         // Call the method to be tested
        Test.startTest();
        System.currentPageReference().getParameters().put('SelectedGroup', groupc.Id );
        ev_KilnsReportController controller = new ev_KilnsReportController();
          List<ev_KilnsReportController.CompanyCompetitorCaptiveWrapper> result = ev_KilnsReportController.getCompaniesWithCompetitorsCaptive(groupc.Id);
            Competitor__c results = ev_KilnsReportController.getGroupDetails(groupc.id);
        Test.stopTest();
        
        // Verify the results
        System.assertNotEquals(null, controller.wrapperMerchantList, 'The wrapperMerchantList should not be null');
        System.assertEquals(1, controller.wrapperMerchantList.size(), 'The wrapperMerchantList should have 1 item');
        System.assertEquals('Test Company', controller.wrapperMerchantList[0].companyName, 'The company name should be Test Company');
        System.assertEquals(1000, controller.wrapperMerchantList[0].totalNominalCapacity, 'The totalNominalCapacity should be 1000');
        System.assertEquals(1500, controller.wrapperMerchantList[0].totalEstimatedProduction, 'The totalEstimatedProduction should be 1500');
        
        System.assertNotEquals(null, controller.wrapperCaptiveList, 'The wrapperCaptiveList should not be null');
        System.assertEquals(1, controller.wrapperCaptiveList.size(), 'The wrapperCaptiveList should have 1 item');
        System.assertEquals('Test Company', controller.wrapperCaptiveList[0].companyName, 'The company name should be Test Company');
        System.assertEquals(1200, controller.wrapperCaptiveList[0].totalNominalCapacity, 'The totalNominalCapacity should be 1200');
        System.assertEquals(1600, controller.wrapperCaptiveList[0].totalEstimatedProduction, 'The totalEstimatedProduction should be 1600');
        
        System.assertEquals(2200, controller.getTotalNomProdTpy(), 'The total nominal capacity should be 2200');
        System.assertEquals(3100, controller.getTotalEstimProdTpy(), 'The total estimated production should be 3100');
    }
    
    @isTest
    static void testGetCompaniesWithCompetitorsMerchant() {
        // Create test records
        Id groupRecId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Group').getRecordTypeId();
        Id plantRecId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Plant').getRecordTypeId();
        Id companyRecId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        
        Competitor__c groupg = new Competitor__c(Name = 'Test Group', RecordTypeId = groupRecId);
        insert groupg;
        
        Competitor__c company = new Competitor__c(Name = 'Test Company', RecordTypeId = companyRecId,Competitor__c=groupg.Id);
        insert company;
        
        Competitor__c merchantPlant = new Competitor__c(
            Name = 'Merchant Plant 1',
            RecordTypeId = plantRecId,
            Type_of_Plant__c = 'Merchant',
            Company__c = company.Id,
             Nominal_Capacity_t_y__c = 1000,
            Estimated_Production_t_y__c = 1500
        );
        insert merchantPlant;
        
        // Call the static method
        Test.startTest();
        List<ev_KilnsReportController.CompanyCompetitorMerchantWrapper> result = ev_KilnsReportController.getCompaniesWithCompetitorsMerchant(groupg.Id);
        
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'The result should not be null');
        System.assertEquals(1, result.size(), 'The result should have 1 item');
        System.assertEquals('Test Company', result[0].companyName, 'The company name should be Test Company');
       
    }
    
    @isTest
    static void testGetCompaniesWithCompetitorsCaptive() {
        // Create test records
        Id groupRecId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Group').getRecordTypeId();
        Id plantRecId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Plant').getRecordTypeId();
        Id companyRecId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId();
        
        Competitor__c groupf = new Competitor__c(Name = 'Test Group', RecordTypeId = groupRecId);
        insert groupf;
        
        Competitor__c company = new Competitor__c(Name = 'Test Company', RecordTypeId = companyRecId,Competitor__c =groupf.Id);
        insert company;
        
        Competitor__c captivePlant = new Competitor__c(
            Name = 'Captive Plant 1',
            RecordTypeId = plantRecId,
            Type_of_Plant__c = 'Captive',
            Company__c = company.Id,
            Nominal_Capacity_t_y__c = 1200,
            Estimated_Production_t_y__c = 1600
        );
        insert captivePlant;
        
        // Call the static method
        Test.startTest();
        List<ev_KilnsReportController.CompanyCompetitorCaptiveWrapper> result = ev_KilnsReportController.getCompaniesWithCompetitorsCaptive(groupf.Id);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'The result should not be null');
        System.assertEquals(1, result.size(), 'The result should have 1 item');
        System.assertEquals('Test Company', result[0].companyName, 'The company name should be Test Company');
       
    }
}