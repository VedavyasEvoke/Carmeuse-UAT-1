@isTest
public class ev_ShipToOppsClassTest {
    
    @testSetup
    static void setupTestData() {
        // Create a parent account
        Account parentAccount = new Account(Name = 'Parent Account');
        insert parentAccount;
        
        // Create child accounts with Account_Group__c = '2'
        Account childAccount1 = new Account(Name = 'Child Account 1', ParentId = parentAccount.Id, Account_Group__c = '2');
        Account childAccount2 = new Account(Name = 'Child Account 2', ParentId = parentAccount.Id, Account_Group__c = '2');
        insert new List<Account> {childAccount1, childAccount2};
        
        // Create opportunities for the child accounts
        Opportunity opp1 = new Opportunity(Name = 'Opportunity 1', AccountId = childAccount1.Id, CloseDate = Date.today().addDays(30), StageName = 'Prospecting', Amount = 1000);
        Opportunity opp2 = new Opportunity(Name = 'Opportunity 2', AccountId = childAccount2.Id, CloseDate = Date.today().addDays(60), StageName = 'Qualification', Amount = 2000);
        insert new List<Opportunity> {opp1, opp2};
    }
    
    @isTest
    static void testGetOpps() {
        // Retrieve the parent account ID
        Account parentAccount = [SELECT Id FROM Account WHERE Name = 'Parent Account' LIMIT 1];
        
        // Call the getOpps method
        List<Opportunity> opps = ev_ShipToOppsClass.getOpps(parentAccount.Id);
        
        // Verify the results
        System.assertEquals(2, opps.size(), 'The number of opportunities returned is not as expected');
         
    }
}