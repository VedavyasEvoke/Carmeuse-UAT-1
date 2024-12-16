global class ev_MarketInfoFollowUpMailScheduleClass implements Schedulable {
    global void execute(SchedulableContext SC){
        ev_MarketInfoFollowUp6monthsEmail FollowupMail=new ev_MarketInfoFollowUp6monthsEmail();
        Database.executebatch(FollowupMail); 
       
    }
}