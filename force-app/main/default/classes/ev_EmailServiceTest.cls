@isTest
public class ev_EmailServiceTest {
    @isTest
    static void testSendMail() {
        Test.startTest();
        
        // Create a mock email message
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Test Subject');
        email.setToAddresses(new List<String>{'test@example.com'});
        email.setSenderDisplayName('Test Sender');
        
        // Create an instance of ev_EmailService
        ev_EmailService emailService = new ev_EmailService(email);
        emailService.body = 'Test email body';
        emailService.isHtml = true;
        emailService.toAddresses = new List<String>{'test@example.com'};
        emailService.subject = 'Test Subject';
        emailService.displayName = 'Test Sender';
        
        // Send the email without attachments
        emailService.sendMail();
        
        // Send the email with attachments
        emailService.isAttachment = true;
        emailService.attachFiles = new Map<String, String>{'TestAttachment' => 'TestAttachmentBody'};
        emailService.sendMail();
        
        Test.stopTest();
        
    }
}