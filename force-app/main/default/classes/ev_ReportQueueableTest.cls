@isTest
public class ev_ReportQueueableTest {


    @isTest
    static void testExecute() {
        Test.startTest();
        
        // Create an instance of the Queueable class
        String reportDevName = 'Test_Report';
        ev_ReportQueueable queueable = new ev_ReportQueueable(reportDevName);
        
        // Enqueue the queueable job
        System.enqueueJob(queueable);
        
        Test.stopTest();

    }
}