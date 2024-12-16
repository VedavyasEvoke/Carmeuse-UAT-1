/**
* Class Name         : Ev_VisitReportFormService
* Developer          : D Sridhar           
* Created Date       : 14-08-2024
* @description       : This class contains all the AuraEnabled methods of Ev_VisitReportForm LWC and uses its Service class for executing complex logic.
* Last Modified Date : 
*/
public with sharing class Ev_VisitReportFormController {
    static Ev_VisitReportFormService ev_VisitReportFormServiceInstance = Ev_VisitReportFormService.getInstance();
    
    /**
* @description
* @param wrapper
* @return
*/
    @AuraEnabled
    public static Id createVisitReportWithSiteVisits(VisitReportWrapper wrapper) {
        return ev_VisitReportFormServiceInstance.createVisitReportWithSiteVisits(wrapper);
    }
    
    /**
* @description
* @param wrapper
* @return
*/
    @AuraEnabled
    public static List<ContentDocumentLink> fetchAttachments(Id linkedEntityId) {
        return ev_VisitReportFormServiceInstance.fetchAttachments(linkedEntityId);
    }
    
    /**
* @description
* @param wrapper
* @return
*/
    @AuraEnabled
    public static List<Site_Visit_Assignee__c> fetchSiteVisitAssignees(Id visitReportId) {
        return ev_VisitReportFormServiceInstance.fetchSiteVisitAssignees(visitReportId);
    }
    
    /**
* @description Navigates from Pricing Condition Component Page to Quote Line Editor page.
* @return Returns the PageReference of the Quote Line Editor Page.
*/    
    public class VisitReportWrapper {
        @AuraEnabled public Visit_Report__c visitReport { get; set; }
        @AuraEnabled public List<Site_Visit_Assignee__c> siteVisitAssignees { get; set; }
        @AuraEnabled public List<String> files { get; set; }
        @AuraEnabled public List<Id> deletedFiles { get; set; }
    }
}