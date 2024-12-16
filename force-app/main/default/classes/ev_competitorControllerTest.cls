@isTest
private class ev_competitorControllerTest {

    static testMethod void testCompetitorController() {
        
        Competitor__c testCompany = new Competitor__c
            (RecordTypeId = SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId());
        // Create test data
        Competitor__c testgroup = new Competitor__c(
            //Name = 'Test Group',
            
            RecordTypeId = SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Group').getRecordTypeId()
            
            // Add other required fields for Competitor__c object
        );
         insert testgroup;
        Competitor__c testCompetitor = new Competitor__c(
            //Name = 'Test Competitor',
            Aggre__c = true,
            Dolomite__c = TRUE,
            Dolime__c = TRUE,
            Hyd_Lime__c = TRUE,
            Limestone__c = TRUE,
            Quicklime__c = TRUE,
            Estimated_Production_t_y__c = 300,
            Nominal_Capacity_t_y__c = 300,
            Competitor__c= testgroup.Id
        );
        insert testCompetitor;
		Competitor__c testplant = new Competitor__c(
            //Name = 'Test Plant',
            Aggre__c = true,
            Dolomite__c = TRUE,
            Dolime__c = TRUE,
            Hyd_Lime__c = TRUE,
            Limestone__c = TRUE,
            Quicklime__c = TRUE,
            Estimated_Production_t_y__c = 300,
            Company__c = testCompany.id
        );
        insert testplant;
        // Set up the page reference with parameters
        PageReference pageRef = Page.ev_printsummarycompany;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('selectedcompany', testCompetitor.Id);

        // Call the constructor of the controller
        Test.startTest();
        ev_competitorController controller = new ev_competitorController();
        Test.stopTest();


        // Test the AuraEnabled method
        List<Competitor__c> competitorData = ev_competitorController.getCompetitorData(testCompetitor.Id);

        
     Competitor__c companyData = ev_competitorController.getCountryData(testCompetitor.Id);
    }
}