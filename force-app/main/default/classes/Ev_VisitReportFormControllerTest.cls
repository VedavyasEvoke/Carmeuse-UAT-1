/**
* Class Name         : Ev_VisitReportFormControllerTest
* Developer          : D Sridhar           
* Created Date       : 07-05-2024
* @description       : Test class for Ev_VisitReportFormController 
* Last Modified Date : 
*/
@isTest
private class Ev_VisitReportFormControllerTest {
    /**
* @description Test Data Setup.
*/
    @testSetup
    static void setup() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User user = new User(Alias = uid, Email= uid + '@testdomain.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = profile.Id, 
                             TimeZoneSidKey='America/New_York', UserName= uid + '@testdomain.com');
        insert user;
        
        List<Account> accounts = TestDataFactory.createRecords('Account', 1, true, new Map<String, Object>{
            'Name' => 'Test Account'
        });
        List<Visit_Report__c> vrs = TestDataFactory.createRecords('Visit_Report__c', 1, true, new Map<String, Object>{
            'Subject__c' => 'Test Subject', 'Account__c' => accounts[0].Id
        });
        List<Site_Visit_Assignee__c> svas = TestDataFactory.createRecords('Site_Visit_Assignee__c', 1, true, new Map<String, Object>{
            'SIte_Visit_Report__c' => vrs[0].Id, 'Assigned_To__c' => user.Id
        });
    }
    
    /**
* @description Testing createVisitReportWithSiteVisits method.
*/
    @isTest
    static void testCreateVisitReportWithSiteVisits1() {
        User user = [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        Visit_Report__c visitReport = new Visit_Report__c();
        visitReport.Subject__c = 'Test';
        visitReport.Account__c = a.Id;
        
        Site_Visit_Assignee__c sva = new Site_Visit_Assignee__c();
        sva.Assigned_To__c =user.Id;
        
        List<Site_Visit_Assignee__c> svas = new List<Site_Visit_Assignee__c>{sva};
        Ev_VisitReportFormController.VisitReportWrapper wrapper = new Ev_VisitReportFormController.VisitReportWrapper();
        wrapper.visitReport = visitReport;
        wrapper.siteVisitAssignees = svas;
        
        Test.startTest();
        Id visitReportId = Ev_VisitReportFormController.createVisitReportWithSiteVisits(wrapper);
        Test.stopTest();
        Assert.isNotNull(visitReportId);
    }
    
    /**
* @description Testing createVisitReportWithSiteVisits method.
*/
    @isTest
    static void testCreateVisitReportWithSiteVisits2() {
        User user = [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        Visit_Report__c visitReport = [SELECT Id FROM Visit_Report__c LIMIT 1];
        
        Site_Visit_Assignee__c sva = new Site_Visit_Assignee__c();
        sva.Assigned_To__c =user.Id;
        
        List<Site_Visit_Assignee__c> svas = new List<Site_Visit_Assignee__c>{sva};
        Ev_VisitReportFormController.VisitReportWrapper wrapper = new Ev_VisitReportFormController.VisitReportWrapper();
        wrapper.visitReport = visitReport;
        wrapper.siteVisitAssignees = svas;
        
        Test.startTest();
        Id visitReportId = Ev_VisitReportFormController.createVisitReportWithSiteVisits(wrapper);
        Test.stopTest();
       // Assert.isNotNull(visitReportId);
    }
    
    /**
* @description Testing createVisitReportWithSiteVisits method.
*/
    @isTest
    static void testCreateVisitReportWithSiteVisits3() {
        User user = [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        Visit_Report__c visitReport = new Visit_Report__c();
        
        Site_Visit_Assignee__c sva = new Site_Visit_Assignee__c();
        
        List<Site_Visit_Assignee__c> svas = new List<Site_Visit_Assignee__c>{sva};
        Ev_VisitReportFormController.VisitReportWrapper wrapper = new Ev_VisitReportFormController.VisitReportWrapper();
        wrapper.visitReport = visitReport;
        wrapper.siteVisitAssignees = svas;
        
        Test.startTest();
        Id visitReportId = Ev_VisitReportFormController.createVisitReportWithSiteVisits(wrapper);
        Test.stopTest();
        Assert.isNull(visitReportId);
    }
    
    /**
* @description Testing fetchAttachments method.
*/
    @isTest
    static void testFetchAttachments1() {
        List<Visit_Report__c> visitReport = [SELECT Id FROM Visit_Report__c LIMIT 1];
        
        Test.startTest();
        List<ContentDocumentLink> cdls = Ev_VisitReportFormController.fetchAttachments(visitReport[0].Id);
        Test.stopTest();
        Assert.isNotNull(cdls);
    }
    
    /**
* @description Testing fetchSiteVisitAssignees method.
*/
    @isTest
    static void testFetchSiteVisitAssignees1() {
        List<Visit_Report__c> visitReport = [SELECT Id FROM Visit_Report__c LIMIT 1];
        
        Test.startTest();
        List<Site_Visit_Assignee__c> svas = Ev_VisitReportFormController.fetchSiteVisitAssignees(visitReport[0].Id);
        Test.stopTest();
        Assert.isNotNull(svas);
    }
}