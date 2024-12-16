@isTest
public class ev_TonnagePerCustControllerTest {
    @isTest
    static void testGetTonnageInfo() {
        // Setup test data
        // Create Parent Account
        Account parentAccount = new Account(Name = 'Parent Account');
        insert parentAccount;

        // Create Child Account
        Account childAccount = new Account(Name = 'Child Account', ParentId = parentAccount.Id);
        insert childAccount;

        // Create Products
        Product2 product1 = new Product2(Name = 'Product 1', IsActive = true,Is_Offline__c = true, Family = 'Sales Organization');
        Product2 product2 = new Product2(Name = 'Product 2', IsActive = true ,Is_Offline__c = true, Family = 'Sales Organization');
        insert new List<Product2>{product1, product2};

        // Create Quotes for the parent account
        SBQQ__Quote__c parentQuote = new SBQQ__Quote__c(
            SBQQ__Account__c = parentAccount.Id,
            SBQQ__Status__c = 'Draft',
             Incoterms1__c  = 'CFR'
        );
        insert parentQuote;
      parentQuote.SBQQ__Status__c = 'Accepted';
         
        update parentQuote;
 

        // Create Quote Lines for the parent quote
        SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = parentQuote.Id,
            SBQQ__Product__c = product1.Id,
            SBQQ__Quantity__c = 100
        );
        SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = parentQuote.Id,
            SBQQ__Product__c = product2.Id,
            SBQQ__Quantity__c = 150
        );
        insert new List<SBQQ__QuoteLine__c>{quoteLine1, quoteLine2};

        // Create Quotes for the child account
        SBQQ__Quote__c childQuote = new SBQQ__Quote__c(
            SBQQ__Account__c = childAccount.Id,
            SBQQ__Status__c = 'Draft',
             Incoterms1__c  = 'CFR'
        );
        insert childQuote;
          childQuote.SBQQ__Status__c = 'Accepted';
         
        update childQuote;

        // Create Quote Lines for the child quote
        SBQQ__QuoteLine__c childQuoteLine1 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = childQuote.Id,
            SBQQ__Product__c = product1.Id,
            SBQQ__Quantity__c = 200
        );
        insert childQuoteLine1;

        Test.startTest();

        // Test with the parent account
        List<ev_TonnagePerCustController.ParentAccountWrapper> result = ev_TonnagePerCustController.getTonnageInfo(parentAccount.Id);

        // Assertions
        System.assertEquals(1, result.size(), 'There should be one ParentAccountWrapper.');
        ev_TonnagePerCustController.ParentAccountWrapper parentWrapper = result[0];
        System.assertEquals('Parent Account', parentWrapper.ParentAccountName, 'Parent account name should match.');
        System.assertEquals(250, parentWrapper.ParentAccountQuantity, 'Parent account quantity should be 250.');
        System.assertEquals(450, parentWrapper.TotalQuantityIncludingChildren, 'Total quantity including children should be 450.');
        System.assertEquals(1, parentWrapper.ChildAccounts.size(), 'There should be one child account wrapper.');
        ev_TonnagePerCustController.AccountWrapper childWrapper = parentWrapper.ChildAccounts[0];
        System.assertEquals('Child Account', childWrapper.AccountName, 'Child account name should match.');
        System.assertEquals(200, childWrapper.TotalQuantity, 'Child account quantity should be 200.');

        Test.stopTest();
    }


}