@isTest
private class ev_AccountRegionTriggerHandlerTest {

    @isTest static void testHandleCountryRegions() {
        // Create test accounts
        Account accUS = new Account(Name='Test Account US', ShippingCountry='United States', BillingCountry='United States');
        Account accGermany = new Account(Name='Test Account Germany', ShippingCountry='Germany', BillingCountry='Germany');
        Account accTurkey = new Account(Name='Test Account Turkey', ShippingCountry='Turkey', BillingCountry='Turkey');        
        Account accBrazil = new Account(Name='Test Account Brazil', ShippingCountry='Brazil', BillingCountry='Brazil'); // Not in any defined region set

        // Insert accounts to trigger 'before insert' logic
        insert new List<Account>{accUS, accGermany, accBrazil,accTurkey};

        // Verify regions are set correctly
        List<Account> insertedAccounts = [SELECT Name, Customer_Region__c FROM Account WHERE Id IN :new List<Id>{accUS.Id, accGermany.Id, accBrazil.Id}];


        // Update accounts to trigger 'before update' logic
        accUS.ShippingCountry = 'Canada'; // North America
        accGermany.BillingCountry = 'Poland'; // Central Europe
        update new List<Account>{accUS, accGermany};

    }
}