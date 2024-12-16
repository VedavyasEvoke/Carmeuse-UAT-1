global class ev_LeadEmailScheduleClass implements Schedulable {
    global void execute(SchedulableContext SC){
        ev_LeadNextFollowUpDateEmail NextDayEmail=new ev_LeadNextFollowUpDateEmail();
        Database.executebatch(NextDayEmail);
        ev_LeadFollowUpEmail ThreeDaysAfterFollowUpEmail=new ev_LeadFollowUpEmail();
        Database.executebatch(ThreeDaysAfterFollowUpEmail);
        ev_LeadFollowUp30DaysEmail ThirtyDaysAfterFollowUpEmail=new ev_LeadFollowUp30DaysEmail();
        Database.executebatch(ThirtyDaysAfterFollowUpEmail);
        ev_LeadUntouched2DaysEmail TwoDaysAfterFollowUpEmail=new ev_LeadUntouched2DaysEmail();
        Database.executebatch(TwoDaysAfterFollowUpEmail);
    }
}