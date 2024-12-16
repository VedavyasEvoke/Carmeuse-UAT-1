@isTest
private class ev_DocumentControllerTest {

    @isTest static void testGetAllAttachments() {
        // Test data setup
        Competitor__c competitor = new Competitor__c();
        insert competitor;
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = '/TestDocument.pdf',
            IsMajorVersion = true,
            Document_Type__c = 'Press release',
            VersionData = Blob.valueOf('Test Document Content')
        );
        insert cv;
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId,
            LinkedEntityId = competitor.Id,
            Visibility = 'AllUsers',
            ShareType = 'V'
        );
        insert cdl;

        Test.startTest();
        // Call the method to test
        ev_DocumentController.updateDocumentCustomField(cdl.ContentDocumentId, 'Press release');
        List<ContentVersion> attachments = ev_DocumentController.getAllAttachments(competitor.Id, 'Test');
        List<ContentVersion> attachmentsCompany = ev_DocumentController.getAllAttachmentsCompany(competitor.Id, 'Test');
        List<ContentVersion> attachmentsOnLoad = ev_DocumentController.getAllAttachmentsOnLoad(competitor.Id);
        List<ContentVersion> attachmentsOnLoadCompany = ev_DocumentController.getAllAttachmentsCompanyOnLoad(competitor.Id);
        Test.stopTest();
        
        system.assert(cdl.ContentDocumentId != null);

    }

    @isTest static void testDeleteSelectedfilePositive() {
        // Test data setup      
        List<ContentVersion> attachments = new List<ContentVersion>(); // Pass appropriate attachments
        ContentVersion cv = new ContentVersion();
        	cv.Title = 'Test Document';
            cv.PathOnClient = '/TestDocument.pdf';
            cv.IsMajorVersion = true;
            cv.Document_Type__c = 'Press release';
            cv.VersionData = Blob.valueOf('Test Document Content');
            attachments.add(cv);
        insert attachments;

        Test.startTest();       
        ev_DocumentController.deleteSelectedfile(cv.Id, attachments);
        Test.stopTest();

    }
  
}