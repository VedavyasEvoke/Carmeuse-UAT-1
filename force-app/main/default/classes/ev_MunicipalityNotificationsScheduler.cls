global class ev_MunicipalityNotificationsScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        ev_MunicipalityNotifications batchJob = new ev_MunicipalityNotifications();
        Database.executeBatch(batchJob);
    }
}