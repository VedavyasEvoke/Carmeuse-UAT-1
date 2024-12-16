/************************************************************************************************************************************
Author : Priyanka Shinde
Description :Test method to SchedulerToUpdateStatusToUnfulfilledTest class for updating Order Delivery Group Status
----------------------------------------------------------------------------------------------------------------------------------
VERSION 	ISSUE NUMBER 		DATE 		  AUTHOR 			DETAIL
1                           20/04/2022    Priyanka Shinde   Test method to SchedulerToUpdateStatusToUnfulfilledTest class for updating Order Delivery Group Status.
**************************************************************************************************************************************/

@isTest
public class SchedulerToUpdateStatusToUnfulfilledTest {
    static testMethod void testSchedulerToUpdateStatusToUnfulfilledMethod() {       
        Test.StartTest();
		SchedulerToUpdateStatusToUnfulfilled testsche = new SchedulerToUpdateStatusToUnfulfilled();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
    }
}