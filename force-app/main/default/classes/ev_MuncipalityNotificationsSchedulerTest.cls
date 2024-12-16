@isTest
public class ev_MuncipalityNotificationsSchedulerTest {
    @isTest
    static void testScheduler() {
        // Create an instance of the scheduler class
        ev_MunicipalityNotificationsScheduler scheduler = new ev_MunicipalityNotificationsScheduler();

        // Schedule the job
        String cronExp = '0 0 12 * * ?'; // This cron expression schedules the job to run at 12 PM every day
        String jobId = System.schedule('Test ev_MunicipalityNotificationsScheduler Job', cronExp, scheduler);

        // Verify the job was scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                          FROM CronTrigger WHERE Id = :jobId];

    }
}