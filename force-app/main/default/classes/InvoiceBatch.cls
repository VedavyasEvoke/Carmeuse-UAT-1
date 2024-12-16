public class InvoiceBatch implements Database.Batchable<SObject>, Database.stateful {
    public String resultString = '';
	public List<Account> lstInvoiceAccount;
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, Name, Invoice_Number__c, AccountInvoiceRelation__c, InvoiceExternalAccountNumber__c, InvoiceDate__c FROM AccountInvoice__c WHERE AccountInvoiceRelation__r.B2B_Customer__c = true AND CreatedDate = LAST_N_MONTHS:6 LIMIT 49999');
    }

    public void execute(Database.BatchableContext BCAcc, List<AccountInvoice__c> scope) {
		lstInvoiceAccount = [SELECT Id, Account_Invoice_Data__c FROM Account WHERE Name ='Account Invoice' LIMIT 1];
        Set<Id> invoiceIds = new Set<Id>();
        for (AccountInvoice__c invoice : scope) {
            invoiceIds.add(invoice.Id);
        }

        List<ContentDocumentLink> linkedDocuments = [SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :invoiceIds];
        
        Set<Id> linkedInvoiceIds = new Set<Id>();
        for (ContentDocumentLink docLink : linkedDocuments) {
            linkedInvoiceIds.add(docLink.LinkedEntityId);
        }

        List<AccountInvoice__c> unlinkedInvoices = new List<AccountInvoice__c>();
        for (AccountInvoice__c invoice : scope) {
            if (!linkedInvoiceIds.contains(invoice.Id)) {
                unlinkedInvoices.add(invoice);
            }
        }

        if (resultString == '') {
            resultString = 'Id,Name,Invoice_Number,Invoice_Account,Invoice_External_Account,Invoice_Date\n';
        }

        for (AccountInvoice__c invoice : unlinkedInvoices) {
            resultString += invoice.Id + ',' + invoice.Name + ',' + invoice.Invoice_Number__c + ',' + invoice.AccountInvoiceRelation__c + ',' + invoice.InvoiceExternalAccountNumber__c + ',' + invoice.InvoiceDate__c + '\n';
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('FINAL resultString----->' + resultString.length());
    }
}