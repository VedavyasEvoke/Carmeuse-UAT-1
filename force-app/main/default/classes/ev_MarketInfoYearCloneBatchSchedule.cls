global class ev_MarketInfoYearCloneBatchSchedule implements Schedulable {
    // Schedule class used to schedule year end market info clone
    global void execute(SchedulableContext SC){
	 ev_MarketInfoYearCloneBatch MktInfo=new ev_MarketInfoYearCloneBatch();
        Database.executebatch(MktInfo);
    }
}