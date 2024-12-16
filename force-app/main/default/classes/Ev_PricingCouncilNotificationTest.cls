/**
* Class Name         : Ev_PricingCouncilNotificationTest
* Developer          : D Sridhar           
* Created Date       : 08-05-2024
* @description       : Test class for Ev_PricingCouncilNotification.
* Last Modified Date : 
*/
@isTest
public class Ev_PricingCouncilNotificationTest {
/**
* @description Test Data Setup.
*/ 
    @testsetup
    static void setup(){ 
        TestDataFactory.createRecords('SBQQ__Quote__c', 1, true, new Map<String, Object>());
    }
/**
* @description check if email is sent to the owner of the respective quote.
*/ 
    @isTest
    static void sendNotificationTest(){
        List<Ev_PricingCouncilNotification.PricingWrapper> wrapperList=new List<Ev_PricingCouncilNotification.PricingWrapper>();
        Ev_PricingCouncilNotification.PricingWrapper wrapper= new Ev_PricingCouncilNotification.PricingWrapper();
        List<SBQQ__Quote__c> quote=[SELECT Id,OwnerId FROM SBQQ__Quote__c WITH SECURITY_ENFORCED];
        wrapper.message='Message';
        wrapper.quote = quote[0];
        wrapper.subject ='Subject';
        wrapperList.add(wrapper);
        Test.startTest();
        Ev_PricingCouncilNotification.sendNotification(wrapperList);
        Test.stopTest();
    }

}