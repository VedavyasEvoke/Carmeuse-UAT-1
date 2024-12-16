global class ev_OverdueInvoices implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query all Accounts and related invoices
        return Database.getQueryLocator([
            SELECT Id, Credit_Limit__c, 
                   (SELECT Invoice_Amount__c 
                    FROM AccountInvoices__r 
                    WHERE Due_Date__c < TODAY AND Clearing_Date__c = NULL)
            FROM Account
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        // List to hold accounts
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Account acc : scope) {
            Decimal totalInvoiceAmount = 0;
            for (AccountInvoice__c invoice : acc.AccountInvoices__r) {
                totalInvoiceAmount += invoice.Invoice_Amount__c;
            }

            // Compare the total
            if (totalInvoiceAmount > acc.Credit_Limit__c) {
                acc.Overdue_Invoices__c = true;
                accountsToUpdate.add(acc);
            }
        }
        
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // Any after processing in future
    }
}