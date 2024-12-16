@isTest
private class ev_printsummaryplantkilncontrollertest {
    @isTest
    static void testConstructor() {
        // Create test data
        Competitor__c competitor = new Competitor__c(
            Plant_Name__c  = 'Test Competitor',
            RecordTypeId =  Schema.sObjectType.Competitor__c.getRecordTypeInfosByName().get('Plant').getRecordTypeId()
        );
        insert competitor;

        Kiln_Report__c kiln = new Kiln_Report__c(
            Kiln__c = 'Annular',
            Nbr__c = 1,
            Est_Prod_t_y__c = 100,
            Cap_t_y__c = 200,
            Cap_t_d__c = 300,
            Active__c = true,
            Plant__c = competitor.Id
        );
        insert kiln;

        // Set Page Reference
        PageReference pageRef = Page.ev_printsummaryplant;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('selectedPlant', competitor.Id);
        
        // Instantiate the controller
        Test.startTest();
        ev_printsummaryplantkilncontroller controller = new ev_printsummaryplantkilncontroller();
        Test.stopTest();

        // Verify that controller properties are populated correctly
        System.assertEquals(1, controller.plantlist.size(), 'Plant List should contain one item');
        System.assertEquals(1, controller.kilnlist.size(), 'Kiln List should contain one item');
    }

    @isTest
    static void testGetProductDetails() {
        // Create test data
        Competitor__c competitor = new Competitor__c(
             Plant_Name__c = 'Test Competitor',
             RecordTypeId =  Schema.sObjectType.Competitor__c.getRecordTypeInfosByName().get('Plant').getRecordTypeId()
        );
        insert competitor;

        // Call the static method
        Test.startTest();
        List<Competitor__c> result = ev_printsummaryplantkilncontroller.getProductDetails(competitor.Id);
        Test.stopTest();

        // Verify the result
        System.assertEquals(1, result.size(), 'Result should contain one item');    }

    @isTest
    static void testKilnsDetails() {
        // Create test data
        Competitor__c competitor = new Competitor__c(
             Plant_Name__c = 'Test Competitor',
             RecordTypeId =  Schema.sObjectType.Competitor__c.getRecordTypeInfosByName().get('Plant').getRecordTypeId()
        );
        insert competitor;

        Kiln_Report__c kiln = new Kiln_Report__c(
            Kiln__c = 'Mixed fired Shaft kiln',
            Nbr__c = 1,
            Est_Prod_t_y__c = 100,
            Cap_t_y__c = 200,
            Cap_t_d__c = 300,
            Active__c = true,
            Plant__c = competitor.Id
        );
        insert kiln;

        // Call the static method
        Test.startTest();
        List<Kiln_Report__c> result = ev_printsummaryplantkilncontroller.KilnsDetails(competitor.Id);
        Test.stopTest();

        // Verify the result
        System.assertEquals(1, result.size(), 'Result should contain one item');
    }
}