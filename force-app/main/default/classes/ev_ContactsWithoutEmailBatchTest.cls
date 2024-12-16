@isTest
private class ev_ContactsWithoutEmailBatchTest {
    
    @isTest static void testBatchExecution() {
        // Insert Contact 
        List<Contact> testContacts = new List<Contact>();
        for(Integer i = 0; i < 100; i++) {
            testContacts.add(new Contact(
                FirstName = 'Test' + i,
                LastName = 'Contact' + i,
              Business_Unit__c = 'Carmeuse Systems'
            ));
        }
        insert testContacts;
        
        // Set up batch job
        Test.startTest();
        ev_ContactsWithoutEmailBatch batchJob = new ev_ContactsWithoutEmailBatch();
        Database.executeBatch(batchJob);
        Test.stopTest();
        
        // Verify  batch job processed all test contacts
        List<Contact> processedContacts = [SELECT Id FROM Contact WHERE Email = null AND Business_Unit__c = 'Carmeuse Systems'];
        System.assertEquals(100, processedContacts.size());
    }
     @isTest static void testSchedulableExecution() {
        Test.startTest();
        // Schedule the batch job
        String jobId = System.schedule('Test Contact Batch Job', '0 0 0 * * ?', new ev_ContactsWithoutEmailBatch());
        Test.stopTest();
        
        // Verify that the job ID is not null, indicating successful scheduling
        Assert.areNotEqual(null, jobId);
    }
}