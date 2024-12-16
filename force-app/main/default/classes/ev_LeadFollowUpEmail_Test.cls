@isTest
public class ev_LeadFollowUpEmail_Test {
    @isTest 
    Static void followUpEmailTest(){
        Lead l=new Lead();
            l.FirstName='Test';
            l.LastName='Record';
            l.Email='text@text.com';
            l.Company='Testing Batch Apex';
            l.Status='New';
            insert l;
        Date threeDays =Date.newinstance(2024, 2, 10);
        //Test.setLastModifiedDate(l.Id,threeDays);
        
        Test.startTest();
        ev_LeadFollowUpEmail fde=new ev_LeadFollowUpEmail();
        Database.executebatch(fde);
         Test.stopTest();
    }
    @isTest
    static void testfollowuptomorrow(){
        Lead l=new Lead();
            l.FirstName='Test';
            l.LastName='Record';
            l.Email='text@text.com';
            l.Company='Testing Batch Apex';
            l.Status='New';
        l.Next_Followup_Date__c=System.Today()+1;
            insert l;
        Test.startTest();
        ev_LeadNextFollowUpDateEmail fde=new ev_LeadNextFollowUpDateEmail();
        Database.executebatch(fde);
         Test.stopTest();
    }
    @isTest
    static void testfollowupmonth(){
        Lead l=new Lead();
            l.FirstName='Test';
            l.LastName='Record';
            l.Email='text@text.com';
            l.Company='Testing Batch Apex';
            l.Status='retired';
        l.Next_Followup_Date__c=System.Today()+1;
            insert l;
        Test.startTest();
        ev_LeadFollowUp30DaysEmail lead30Days=new ev_LeadFollowUp30DaysEmail();
        Database.executebatch(lead30Days);
         Test.stopTest();
    }
    @isTest
    Static void followUpEmailTestuntouchedlead(){
        User testUser = new User(
            LastName='Testing1',
            Username = 'test236789@example.com', // Unique email
            Email = 'test6@example.com',
            Alias = 'tuser6',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            UserRoleId = null, // Optional
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            FederationIdentifier = 'testuser6@example.com'
        );
        insert testUser;
		Lead l=new Lead();
            l.FirstName='Test';
            l.LastName='Record';
            l.Email='text@text.com';
            l.Company='Testing Batch Apex';
            l.OwnerId=testUser.id;
        	l.Next_Followup_Date__c=System.Today()+1;
            insert l;
        ev_LeadUntouched2DaysEmail twodaysemailafter=new ev_LeadUntouched2DaysEmail();
       Test.startTest();
        Database.executebatch(twodaysemailafter);
        Test.stopTest();
    }
    @isTest
    static void testEmailSchedule(){ 
        Test.startTest();
        ev_LeadEmailScheduleClass leadEmailSchedule=
            new ev_LeadEmailScheduleClass();
        String sch ='0 48 * * * ?';
        Id JobId = System.schedule('Schedule to update Lead Daily Follow-up', sch,leadEmailSchedule);
        CronTrigger cronTrigger1 =
            [SELECT 
             Id,
             CronExpression,
             TimesTriggered,
             NextFireTime
             FROM 
             CronTrigger WHERE 
             Id = :JobId
            ];
        System.assertEquals(sch, cronTrigger1.CronExpression);
        Test.stopTest();
    }
}