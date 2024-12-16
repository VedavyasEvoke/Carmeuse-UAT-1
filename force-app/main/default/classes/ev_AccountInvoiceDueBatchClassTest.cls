@isTest
public class ev_AccountInvoiceDueBatchClassTest {
    @testSetup
    static void setupTestData() {
        // Create test Accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i, Overdue_Invoices__c = false));
        }
        insert accounts;
        Integer inv = 1;
        // Create test AccountInvoice__c records with Due_Date__c = today
        List<AccountInvoice__c> invoices = new List<AccountInvoice__c>();
        for (Account acc : accounts) {
            inv++;
            invoices.add(new AccountInvoice__c(AccountInvoiceRelation__c = acc.Id, Due_Date__c = Date.today(),InvoiceDate__c=Date.today(), Invoice_Number__c='123'+inv));
        }
        insert invoices;
    }
    
    @isTest
    static void testBatchExecution() {
        // Verify initial state
        List<Account> accounts = [SELECT Id, Overdue_Invoices__c FROM Account];
        for (Account acc : accounts) {
            System.assertEquals(false, acc.Overdue_Invoices__c, 'Initial Overdue_Invoices__c should be false');
        }
        
        // Execute the batch class
        Test.startTest();
        ev_AccountInvoiceDueBatchClass batch = new ev_AccountInvoiceDueBatchClass();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify that the Overdue_Invoices__c field is updated to true
        accounts = [SELECT Id, Overdue_Invoices__c FROM Account];
        for (Account acc : accounts) {
            System.assertEquals(true, acc.Overdue_Invoices__c, 'Overdue_Invoices__c should be updated to true');
        }
    }
}