/**
* Class Name         : ev_AccountRestCalloutTest
* Developer          : D Sridhar           
* Created Date       : 15-05-2024
* @description       :  
* Last Modified Date : 
*/
@isTest
private class ev_AccountRestCalloutTest {
    /**
* @description Test Data Setup.
*/
    @testSetup
    static void setup() {
        TestDataFactory.createRecords('Account', 1, true, new Map<String, Object> {
            'Name'=>'Test' });
    }
    
    @isTest
    static void prepareSAPCallout1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account a = [SELECT Id FROM Account LIMIT 1];
        String parameters = JSON.serialize(new Map<String,Object>{ 'accountId'=>a?.Id });
        Test.startTest();
        ev_AccountRestCallout.prepareForCallout(parameters);
        Test.stopTest();
    }
}