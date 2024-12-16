/**
* Class Name         : Ev_VisitReportPdfControllerTest
* Developer          : D Sridhar           
* Created Date       : 
* @description       : Test class for Ev_VisitReportPdfController 
* Last Modified Date : 
*/
@isTest
private class Ev_VisitReportPdfControllerTest {
    /**
* @description Test Data Setup.
*/
    @testSetup
    static void setup() {
        List<Account> accounts = TestDataFactory.createRecords('Account', 1, true, new Map<String, Object>{
            'Name' => 'Test Account'
        });
        TestDataFactory.createRecords('Visit_Report__c', 1, true, new Map<String, Object>{
            'Subject__c' => 'Test Subject', 'Account__c' => accounts[0].Id
        });
    }
    
    /**
* @description Testing if ContentDocumentLink is getting created or not.
*/
    @isTest
    static void testMethod1() {
        List<Visit_Report__c> visitReport = [SELECT Id, Name, CurrencyIsoCode,VisitReportName__c, CreatedDate, CreatedById,Contact__c, Priority__c, Status__c, Type__c, Due_Date__c, Description__c, Account__c, Account__r.Name, Assigned_To__c, Subject__c, Notify__c, Visit_Report_URL__c, Report_Subject__c, Next_steps_actions__c, Minutes__c, Opportunity__c 
                                             FROM Visit_Report__c LIMIT 1];
        Ev_VisitReportPdfController.Input input = new Ev_VisitReportPdfController.Input();
        input.visitReportId = visitReport[0].Id;
        input.visitReport = visitReport[0];
        List<Ev_VisitReportPdfController.Input> inputs = new List<Ev_VisitReportPdfController.Input>();
        inputs.add(input);
        
        Test.startTest();
        List<ContentDocumentLink> cdls = Ev_VisitReportPdfController.getVisitReportPdf(inputs);
        Test.stopTest();
        Assert.isNotNull(cdls);
    }
    
    /**
* @description Testing if ContentDocumentLink is getting created or not.
*/
    /* @isTest
    static void testMethod2() {
        List<Visit_Report__c> visitReport = [SELECT Id FROM Visit_Report__c LIMIT 1];
        Ev_VisitReportPdfController.Input input = new Ev_VisitReportPdfController.Input();
        input.visitReportId = visitReport[0].Id;
        input.visitReport = visitReport[0];
        List<Ev_VisitReportPdfController.Input> inputs = new List<Ev_VisitReportPdfController.Input>();
        inputs.add(input);
        
        Test.startTest();
        List<ContentDocumentLink> cdls = Ev_VisitReportPdfController.getVisitReportPdf(inputs);
        Test.stopTest();
        Assert.isNotNull(cdls);
    } */
    
    /**
* @description Testing if Visit Report Pdf is getting rendered or not.
*/
    /* @isTest
    static void testMethod2() {
        List<Visit_Report__c> visitReport = [SELECT Id FROM Visit_Report__c LIMIT 1];
        PageReference pageRef = Page.Ev_VisitReportPdf;
        pageRef.getParameters().put('visitReportId', visitReport[0].Id);
        Test.setCurrentPage(pageRef);
        Ev_VisitReportPdfController controller = new Ev_VisitReportPdfController();
        Assert.isNotNull(controller);
    } */
}