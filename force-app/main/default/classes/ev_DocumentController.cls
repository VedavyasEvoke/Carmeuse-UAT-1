/*********************************************************************************
Class Name: ev_DocumentController

Purpose:    1. This is the class to get the notes and attachments associated group, company and plant

Please maintain only the last 5 history changes/modifications in the audit log

History of Changes:                
--------------------------------------------------------------------------------------------------------------------------
Date                                          Developer                               Comments
--------------------------------------------------------------------------------------------------------------------------
24-01-2024                                    Naganjaneya Lakshman                              Created
********************************************************************************/

public with sharing class ev_DocumentController {    
    
    //Get Attachments at Group Level
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getAllAttachments(String recordId, string doctype) {
        set<id> cids = new set<id>();
        system.debug('doctype'+ doctype);
        cids = new Map<Id,Competitor__c>([SELECT id, Name, Competitor__r.Name FROM Competitor__c where Competitor__r.id =: recordId OR id =: recordId]).keyset();
        system.debug('cids=>' + cids);
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :Cids];
        system.debug('files=>' + files);
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        List<ContentVersion> docs = new List<ContentVersion>();
        docs = [SELECT ContentDocumentId, FileExtension, Title, Document_Type__c, CreatedDate, CreatedDateValue__c, ContentUrl 
                FROM ContentVersion WHERE ContentDocumentId IN : fileIDs AND Document_Type__c =: doctype];
        System.debug('docs===>' + docs);
        return docs;
    }
    
    //Get Attachments at Group Level On Load
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getAllAttachmentsOnLoad(String recordId) {
        set<id> cids = new set<id>();
        cids = new Map<Id,Competitor__c>([SELECT id, Name, Competitor__r.Name FROM Competitor__c where Competitor__r.id =: recordId OR id =: recordId]).keyset();
        system.debug('cids=>' + cids);
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :Cids];
        system.debug('files=>' + files);
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        List<ContentVersion> docs = new List<ContentVersion>();
        docs = [SELECT ContentDocumentId, FileExtension, Title, Document_Type__c, CreatedDate, CreatedDateValue__c, ContentUrl 
                FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
        System.debug('docs===>' + docs);
        return docs;
    }
    
    //Get Attachments at Company Level
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getAllAttachmentsCompany(String recordId, string doctype) {
        set<id> cids = new set<id>();
        cids = new Map<Id,Competitor__c>([SELECT id, Name, Competitor__r.Name FROM Competitor__c where id =: recordId]).keyset();
        system.debug('cids=>' + cids);
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :Cids];
        system.debug('files=>' + files);
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        List<ContentVersion> docs = new List<ContentVersion>();
        docs = [SELECT ContentDocumentId, FileExtension, Title, Document_Type__c, CreatedDate, CreatedDateValue__c, ContentUrl 
                FROM ContentVersion WHERE ContentDocumentId IN : fileIDs AND Document_Type__c =: doctype];        
        System.debug('docs===>' + docs);
        return docs;
    }
    
    //Get Attachments at Company Level On Load
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getAllAttachmentsCompanyOnLoad(String recordId) {
        set<id> cids = new set<id>();
        cids = new Map<Id,Competitor__c>([SELECT id, Name, Competitor__r.Name FROM Competitor__c where id =: recordId]).keyset();
        system.debug('cids=>' + cids);
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :Cids];
        system.debug('files=>' + files);
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        List<ContentVersion> docs = new List<ContentVersion>();
        docs = [SELECT ContentDocumentId, FileExtension, Title, Document_Type__c, CreatedDate, CreatedDateValue__c, ContentUrl 
                FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
        System.debug('docs===>' + docs);
        return docs;
    }
    
    //File Delete
    @AuraEnabled
    public static List<ContentVersion> deleteSelectedfile(String docIds, List<ContentVersion> attachments){
        system.debug('docIds=>' + docIds);
        Set<Id> docid = new set<id> ();
        list<ContentVersion> cvlist= [SELECT ContentDocumentId FROM ContentVersion WHERE Id=:docIds];
        for(ContentVersion cv : cvlist){
            system.debug('Cv=>'+ cv.ContentDocumentId);
            docid.add(cv.ContentDocumentId);
        }
        delete [SELECT Id FROM ContentDocument WHERE Id=:docId];
        for (Integer i = (attachments.size()-1) ; i>= 0 ; i--)
        {
            ContentVersion s = attachments[i];
            if(s.id == docIds){
                attachments.remove(i);
            }
        }
        return attachments;
    }
    
    //File Upload
    @AuraEnabled
    public static void updateDocumentCustomField(Id documentId, String customFieldValue) {
        // Replace Document__c with your custom object name and CustomField__c with your field API name
        system.debug('documentId  '+documentId);
        system.debug('customFieldValue   '+customFieldValue);
        
        ContentVersion document = [SELECT Id, Document_Type__c FROM ContentVersion WHERE ContentDocumentId = :documentId LIMIT 1];
        system.debug('id  '+document.id);
        ContentVersion cnvesion = new ContentVersion();
        cnvesion.Id = document.id;
        cnvesion.Document_Type__c = customFieldValue;
        update cnvesion;
        
        
        system.debug('document '+document);
    }

}