public class ev_ReportScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        String reportDevName = 'Mintek_leads_Data'; 
        System.enqueueJob(new ev_ReportQueueable(reportDevName));
    }
}