/************************************************************************************************************************************
Author : Priyanka Shinde
Description :Scheduler To Schedule the BatchToUpdatStatusToUnfullfilled
----------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 		        DATE 		  AUTHOR 			DETAIL
1                                     20/04/2022    Priyanka Shinde   Scheduler To Schedule the BatchToUpdatStatusToUnfullfilled.
**************************************************************************************************************************************/

public class SchedulerToUpdateStatusToUnfulfilled implements Schedulable {
    public void execute(SchedulableContext SC) {
        BatchToUpdatStatusToUnfullfilled objBatch = new BatchToUpdatStatusToUnfullfilled(); 
        if(!Test.isRunningTest()){
            Database.executebatch(objBatch,100);
        }
    }
}