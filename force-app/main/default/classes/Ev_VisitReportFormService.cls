/**
* Class Name         : Ev_VisitReportFormService
* Developer          : D Sridhar           
* Created Date       : 14-08-2024
* @description       : This class is used for executing complex logic.
* Last Modified Date : 
*/
public with sharing class Ev_VisitReportFormService {
    static Ev_VisitReportFormService instance = null;   //Instance of this class
    static Ev_ContentDocumentLinkSelector ev_ContentDocumentLinkSelectorInstance = Ev_ContentDocumentLinkSelector.getInstance();
    static Ev_Site_Visit_AssigneeSelector ev_Site_Visit_AssigneeSelectorInstance = Ev_Site_Visit_AssigneeSelector.getInstance();
    
    /**
* @description Creates and returns the instance of this class
* @return Instance of this class
*/
    public static Ev_VisitReportFormService getInstance() {
        if(instance == null) {
            instance = new Ev_VisitReportFormService();
        }
        return instance;
    }
    
    /**
* @description Creates Visit Report Record along with the Site Visit Assignees and Content Document Link Records.
* @param wrapper containing all the required data
* @return Id of the created Visit Report record.
*/    
    public Id createVisitReportWithSiteVisits(Ev_VisitReportFormController.VisitReportWrapper wrapper) {
        System.debug(wrapper);
        Savepoint sp = Database.setSavepoint();
        
        try {
            /* Deleting Existing Site Visit Assignees. */
            if(wrapper.visitReport.Id != null) {
                List<Site_Visit_Assignee__c> existingSvas = fetchSiteVisitAssignees(wrapper.visitReport.Id);
                delete existingSvas;
            }
            
            /* Upserting the new/updated Visit Report record. */
            Visit_Report__c visitReport = wrapper.visitReport;
            upsert visitReport;
            
            /* Adding Site Visit Assignees to relatedRecords List to insert. */
            List<sObject> relatedRecords = new List<sObject>();
            if (wrapper.siteVisitAssignees != null && !wrapper.siteVisitAssignees.isEmpty()) {
                for (Site_Visit_Assignee__c siteVisitAssignee : wrapper.siteVisitAssignees) {
                    siteVisitAssignee.Site_Visit_Report__c = visitReport.Id;
                    relatedRecords.add(siteVisitAssignee);
                }
            }
              
            /* Adding ContentDocumentLink Records to relatedRecords List to insert. */
            if (wrapper.files != null && !wrapper.files.isEmpty()) {
                for (String cdlId : wrapper.files) {
                    relatedRecords.add(new ContentDocumentLink(ContentDocumentId = cdlId, LinkedEntityId = visitReport.Id));
                }
            }
            
            /* Upserting the relatedRecord List containing Site Visit Assignees and ContentDocumentLink Records. */
            if(relatedRecords != null && !relatedRecords.isEmpty()) {
                Database.upsert(relatedRecords, true);
            }
            
            /* Deleting the files which were removed on the UI i.e. LWC. */
            if(wrapper.deletedFiles != null && !wrapper.deletedFiles.isEmpty()) {
                Database.delete(wrapper.deletedFiles);
            }
            
            if(wrapper.visitReport.Notify__c == true) {
                update visitReport;
            }
            
            return visitReport.Id;
        } catch (Exception e) {
            Database.rollback(sp);
        }
        return null;
    }
    
    /**
* @description Fetches related ContentDocumentLink Records.
* @param Parent Id
* @return List of all the related ContentDocumentLink Records.
*/
    public List<ContentDocumentLink> fetchAttachments(Id linkedEntityId) {
        List<String> fields = new List<String>{'Id, ContentDocument.Id, ContentDocument.Title, ContentDocument.FileExtension'}; 
        String filter = 'LinkedEntityId = \'' + String.escapeSingleQuotes(linkedEntityId) + '\'';
        Map<String,Object> newParameterMap = new Map<String,Object>{'fields'=>fields, 'filter'=>filter};
        
        return ev_ContentDocumentLinkSelectorInstance.fetchRecords(newParameterMap);
    }

    /**
* @description Fetches related Site Visit Assignee Records.
* @param Visit Report Id
* @return List of all the related Site Visit Assignee Records.
*/
    public List<Site_Visit_Assignee__c> fetchSiteVisitAssignees(Id visitReportId) {
        List<String> fields = new List<String>{'Id', 'Assigned_To__c'}; 
        String filter = 'Site_Visit_Report__c = \'' + String.escapeSingleQuotes(visitReportId) + '\'';
        Map<String,Object> newParameterMap = new Map<String,Object>{'fields'=>fields, 'filter'=>filter};
        
        return ev_Site_Visit_AssigneeSelectorInstance.fetchRecords(newParameterMap);
    }
}