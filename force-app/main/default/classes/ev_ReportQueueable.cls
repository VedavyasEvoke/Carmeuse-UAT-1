public class ev_ReportQueueable implements Queueable, Database.AllowsCallouts {
    private String reportDevName;

    public ev_ReportQueueable(String reportDevName) {
        this.reportDevName = reportDevName;
    }

    public void execute(QueueableContext context) {
        ev_ReportController reportController = new ev_ReportController();
        reportController.generateReport(reportDevName);
    }
}