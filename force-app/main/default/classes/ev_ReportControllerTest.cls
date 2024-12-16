@isTest(seeAllData='true')
public class ev_ReportControllerTest {

    @isTest
    static void testGenerateReport() {
        // Create a mock report list to simulate the SOQL query result
        List <Report> reportList1 = [SELECT Id, DeveloperName FROM Report where DeveloperName = 'Mintek_leads_Data'];  

        // Mock the system method to return the expected value
        String instanceName = 'https://test.salesforce.com';
        Blob mockContent = Blob.valueOf('Mock content');

        // Create an instance of ev_ReportController
        ev_ReportController reportController = new ev_ReportController();

        // Use a test page reference to simulate URL behavior
        PageReference mockPageRef = new PageReference(instanceName);
        mockPageRef.setRedirect(false);

        // Use the real email service for simplicity in this example
        Messaging.SingleEmailMessage emailMock = new Messaging.SingleEmailMessage();
        emailMock.setSubject('Test Report 1');
        emailMock.setToAddresses(new List<String>{'skylerh@dextara.com', 'skylerhawkins42@yahoo.com'});
        emailMock.setSenderDisplayName('Carmeuse Salesforce Notifications');
        emailMock.setHtmlBody('Hello, <br/><br/> Here is the attached Mintek Leads Report.<br/><br/>Thank You,<br/>Carmeuse Salesforce Notifications');
        
        // Mock attachment
        Messaging.EmailFileAttachment attachmentMock = new Messaging.EmailFileAttachment();
        attachmentMock.setFileName('Test Report 1.csv');
        attachmentMock.setBody(mockContent);
        attachmentMock.setContentType('text/csv');
        emailMock.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachmentMock});

        // Call the generateReport method with a valid developer name
        Test.startTest();
        reportController.generateReport('Mintek_leads_Data');
        Test.stopTest();
        
    }
}