@isTest
private class ev_MunicipalityNotificationsTest {

    @isTest static void testMunicipalityNotifications() {
        // Set up test data
        // Create a test user to own the Opportunity
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', 
                          LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                          ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standarduserbluetestragoon@testorg.com');
        insert u;

        // Create a test Opportunity that meets the criteria
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            Bid_Due_Date__c = System.today().addDays(45),
            Municipality__c = 'Yes',
            CloseDate = System.Today(),
            StageName = 'Qualification',
            OwnerId = u.Id
        );
        insert testOpp;

        // Call the batch class
        Test.startTest();
        ev_MunicipalityNotifications batchClass = new ev_MunicipalityNotifications();
        Id batchId = Database.executeBatch(batchClass);
        Test.stopTest();
    }
}