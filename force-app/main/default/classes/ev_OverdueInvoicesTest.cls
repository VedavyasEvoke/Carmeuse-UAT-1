@isTest
Public class ev_OverdueInvoicesTest {
	@isTest static void testMethod1() {
        
        Account testAccount = new Account(Name='TestAccount',BillingStreet='Test Street', BillingCountry='United States', BillingPostalCode='44444', Sap_Id__c = '01567',B2B_Customer__c=false,Credit_Limit__c=50000);
		
        //Test.startTest();
        insert testAccount; // throw into start test stop test block
        // Test.stopTest();
        AccountInvoice__c a = new AccountInvoice__c();
        a.Invoice_Amount__c = 200;
        a.AccountInvoiceRelation__c = testAccount.Id;
        a.Due_Date__c = date.Today()-1;
        a.InvoiceDate__c = date.Today()-4;
        a.Invoice_Number__c = '12340000';
        a.Invoice_Amount__c = 100000;
                
        insert a;
        
        // Call the batch class
        Test.startTest();
        ev_OverdueInvoices ev = new ev_OverdueInvoices();
        Database.executeBatch(ev);
        Test.stopTest();
    
    }
}