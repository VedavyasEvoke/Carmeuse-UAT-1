@isTest
public class ev_MarketInfoFollowUp6monthsEmail_Test {
  @isTest 
static void FollowUp6monthsMail() {
    // Create a test user as the account owner with an email
     Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User username = new User(Alias = 'testuser', Email='testuser@test.com', 
                          EmailEncodingKey='UTF-8', LastName='Test', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                          ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
                          UserName='testuserunique@test.com');
        insert username;
    // Create test data
    Market_Info__c m = new Market_Info__c();
    m.Name = 'Sept 9 test 1';
    m.Year__c = '2024';
    m.OwnerId=username.Id;
    
    insert m;

    // Set created date to 6 months ago
    Test.setCreatedDate(m.Id, Date.today().addMonths(-6));

    // Start the test
    Test.startTest();
 
    // Execute batch
    ev_MarketInfoFollowUp6monthsEmail batchJob = new ev_MarketInfoFollowUp6monthsEmail();
    Database.executeBatch(batchJob);

    Test.stopTest();

    // Verify if an email was sent
    //Integer emailCount = Limits.getEmailInvocations();
    //System.assertEquals(1, emailCount, 'An email should have been sent.');
}


    @isTest
    static void testFollwUp6MonthEmailSchedule(){ 
        Test.startTest();
        ev_MarketInfoFollowUpMailScheduleClass MarketInfoEmailSchedule=new ev_MarketInfoFollowUpMailScheduleClass();
        String sch ='0 48 * * * ?';
        Id JobId = System.schedule('Schedule to update Lead Daily Follow-up', sch,MarketInfoEmailSchedule);
        CronTrigger cronTrigger1 = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :JobId];
        System.assertEquals(sch, cronTrigger1.CronExpression);
        Test.stopTest();
        
    }
}