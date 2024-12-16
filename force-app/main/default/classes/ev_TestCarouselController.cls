@isTest
public class ev_TestCarouselController {

    @testSetup
    static void setupTestData() {
        // Create a test Account
        Account testAccount = new Account(Name='Test Account', Business_Unit__c = 'Carmeuse');
        insert testAccount;

        // Create ContentVersion
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Image',
            PathOnClient = 'TestImage.jpg',
            VersionData = Blob.valueOf('Test Image Data')
        );
        insert contentVersion;
        
        // Query ContentDocumentId from ContentVersion
        ContentVersion insertedContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test Image' LIMIT 1];
        
        // Create ContentDocumentLink
        ContentDocumentLink contentDocLink = new ContentDocumentLink(
            ContentDocumentId = insertedContentVersion.ContentDocumentId,
            LinkedEntityId = testAccount.Id,
            ShareType = 'V' // Viewer
        );
        insert contentDocLink;
    }

    @isTest
    static void testGetAllAttachments() {
        // Query the test Account to get the Id
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        // Call the method from CarouselController
        Test.startTest();
        List<Map<String, Object>> result = CarouselController.getAllAttachments(testAccount.Id);
        Test.stopTest();
        
        // Verify the result
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        Map<String, Object> attachment = result[0];
        System.assertEquals('Test Image', attachment.get('Title'));
        System.assertEquals('jpg', attachment.get('FileExtension'));
        System.assert(attachment.containsKey('DynamicURL'));
        String dynamicURL = (String) attachment.get('DynamicURL');
        System.assert(dynamicURL.contains('/sfc/servlet.shepherd/version/renditionDownload'));
    }
}