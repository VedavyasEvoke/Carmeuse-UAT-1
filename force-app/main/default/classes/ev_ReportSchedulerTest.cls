@isTest
public class ev_ReportSchedulerTest {
    @isTest
    static void testExecute() {
        Test.startTest();
        
        // Create an instance of the Schedulable class
        ev_ReportScheduler scheduler = new ev_ReportScheduler();
        
        // Call the execute method with a mock SchedulableContext
        scheduler.execute(null);
        
        Test.stopTest();
        
    }
}