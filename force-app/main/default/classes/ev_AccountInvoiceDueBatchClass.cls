// From Account : Overdue_Invoices__c should be marked as true 
// if from the child object : AccountInvoice__c Field : Due_Date__c = today

// get all the  AccountInvoice__c with field AccountInvoiceRelation__c and related Account where  Due_Date__c = today and AccountInvoiceRelation__c != null and AccountInvoiceRelation__r.Overdue_Invoices__c = false

// now make the list to set by collecting AccountInvoiceRelation__c ids which will be the account ids where we need to set Overdue_Invoices__c = true


public class ev_AccountInvoiceDueBatchClass implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([Select Id,AccountInvoiceRelation__c from AccountInvoice__c where Due_Date__c = today and  AccountInvoiceRelation__c != null and AccountInvoiceRelation__r.Overdue_Invoices__c = false
                                        ]);
    }
    
    public void execute(Database.BatchableContext context, List<SObject> scope) {
        // now make the list to set by collecting AccountInvoiceRelation__c ids which will be the account ids where we need to set Overdue_Invoices__c = true
        
        Set<Id> accountIdsToUpdate = new Set<Id>();
        for (AccountInvoice__c invoice : (List<AccountInvoice__c>) scope) {
            accountIdsToUpdate.add(invoice.AccountInvoiceRelation__c);
        }
        // Update Accounts
        if (!accountIdsToUpdate.isEmpty()) {
            List<Account> accountsToUpdate = [SELECT Id, Overdue_Invoices__c FROM Account WHERE Id IN :accountIdsToUpdate];
            for (Account acc : accountsToUpdate) {
                acc.Overdue_Invoices__c = true;
            }
            update accountsToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext context) {
        // Perform any finalization tasks
    }
}