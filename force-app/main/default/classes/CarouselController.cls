public with sharing class CarouselController {

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getAllAttachments(String recordId) {
        // Query ContentDocumentLink
        List<ContentDocumentLink> files = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :recordId
        ];
        
        List<Id> fileIDs = new List<Id>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        
        // Query ContentVersion for file details
        List<ContentVersion> docs = [
            SELECT Id, ContentDocumentId, Title, VersionData, PathOnClient, FileExtension
            FROM ContentVersion
            WHERE ContentDocumentId IN :fileIDs AND IsLatest = true
            AND FileExtension IN ('jpg', 'jpeg', 'png', 'gif', 'bmp')
        ];
        
        List<Map<String, Object>> attachmentsWithPreviewURLs = new List<Map<String, Object>>();
        
        for (ContentVersion doc : docs) {
            Map<String, Object> docInfo = new Map<String, Object>();
            docInfo.put('Title', doc.Title);
            docInfo.put('FileExtension', doc.FileExtension);
            // Construct the relative URL
            String relativeURL = '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_' + doc.FileExtension + '&versionId=' + doc.Id;
            docInfo.put('DynamicURL', relativeURL);
            
            attachmentsWithPreviewURLs.add(docInfo);
        }
        
        return attachmentsWithPreviewURLs;
    }
}