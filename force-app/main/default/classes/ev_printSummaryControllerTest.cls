@isTest
private class ev_printSummaryControllerTest {
    static testMethod void testPrintSummaryController() {
        // Create test data
        Competitor__c testgroup = new Competitor__c(
            Name = 'Test Group',
            RecordTypeId = SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Group').getRecordTypeId(),
            Total_No_Kilns__c = 10,
            Nominal_Capacity_t_y__c = 1000,
            
            Estimated_Production_t_y__c = 750
        );
        insert testgroup;

        Competitor__c testcompany = new Competitor__c(
            Name = 'Test Company',
            RecordTypeId = SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Company').getRecordTypeId(),
            Competitor__c = testgroup.Id
        );
        insert testcompany;

        // Set up the page reference with parameters
        PageReference pageRef = Page.ev_printsummarygroup;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('selectedGroup', testgroup.Id);

        // Call the constructor of the controller
        Test.startTest();
        ev_printsummarycontroller controller = new ev_printsummarycontroller();
        Test.stopTest();

        // Verify the controller properties are set correctly
        Assert.AreEqual(testgroup.Name, controller.groupname);
        System.assertNotEquals(null, controller.plantlist);
        Assert.AreEqual(1, controller.plantlist.size());

        Competitor__c companyInList = controller.plantlist[0];
        Assert.AreEqual(testcompany.Id, companyInList.Id);

        Assert.AreEqual('10.00', controller.formattedtotalkilns);
        Assert.AreEqual('1,000.00', controller.formattednominalcapty);
         Assert.AreEqual('750.00', controller.formattedEstimatedProductionty);

        // Test the AuraEnabled method
        List<Competitor__c> companiesWithCompetitors = ev_printsummarycontroller.getCompaniesWithCompetitors(testgroup.Id);
        Assert.AreEqual(1, companiesWithCompetitors.size());
        Assert.AreEqual(testcompany.Name, companiesWithCompetitors[0].Name);

        // Test the getGroupDetails method
        Competitor__c groupdetails = ev_printsummarycontroller.getGroupDetails(testgroup.Id);
        Assert.AreEqual(testgroup.Name, groupdetails.Name);
        Assert.AreEqual(testgroup.Total_No_Kilns__c, groupdetails.Total_No_Kilns__c);
        Assert.AreEqual(testgroup.Nominal_Capacity_t_y__c, groupdetails.Nominal_Capacity_t_y__c);
        Assert.AreEqual(testgroup.Estimated_Production_t_y__c, groupdetails.Estimated_Production_t_y__c);
    }
}