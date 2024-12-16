public with sharing class ev_TonnagePerCustController {
    @AuraEnabled(cacheable=true)
    public static List<ParentAccountWrapper> getTonnageInfo(String recordId) {
        System.debug('Record ID: ' + recordId);

        // Query the current account
        Account currentAccount = [
            SELECT Id, Name, ParentId
            FROM Account
            WHERE Id = :recordId
            LIMIT 1
        ];
        System.debug('Current Account: ' + currentAccount);

        List<AggregateResult> aggregateResults;
        Set<Id> accountIds = new Set<Id>();
        Id parentAccountId;
        Boolean isParentAccount = (currentAccount.ParentId == null);

        if (isParentAccount) {
            // Current account is a parent account
            parentAccountId = currentAccount.Id;
        } else {
            // Current account is a child account
            parentAccountId = currentAccount.ParentId;
        }

        // Aggregate the quantities from the quotes
        aggregateResults = [
            SELECT SBQQ__Account__c, SUM(Total_Units__c) totalQuantity
            FROM SBQQ__Quote__c
            WHERE SBQQ__Status__c = 'Accepted'
            AND (SBQQ__Account__r.ParentId = :parentAccountId OR SBQQ__Account__c = :parentAccountId)
            GROUP BY SBQQ__Account__c
        ];
        System.debug('Aggregate Results: ' + aggregateResults);

        for (AggregateResult ar : aggregateResults) {
            accountIds.add((Id)ar.get('SBQQ__Account__c'));
        }
        System.debug('Collected Account IDs: ' + accountIds);

        // Query for all relevant accounts (parent + child accounts)
        Map<Id, Account> accountMap = new Map<Id, Account>([
            SELECT Id, Name, ParentId
            FROM Account
            WHERE Id IN :accountIds OR Id = :parentAccountId
        ]);
        System.debug('Queried Accounts: ' + accountMap);

        List<AccountWrapper> accountWrappers = new List<AccountWrapper>();

        // Initialize quantities
        Decimal parentAccountQuantity = 0;
        Decimal totalQuantityIncludingChildren = 0;

        for (AggregateResult ar : aggregateResults) {
            Id accountId = (Id)ar.get('SBQQ__Account__c');
            Decimal totalQuantity = (Decimal)ar.get('totalQuantity');

            // Default totalQuantity to 0 if null
            if (totalQuantity == null) {
                totalQuantity = 0;
            }

            Account account = accountMap.get(accountId);

            if (account != null) {
                // Add to the child account wrappers if the account is not the parent
                if (accountId != parentAccountId) {
                    accountWrappers.add(new AccountWrapper(account.Name, totalQuantity));
                    System.debug('Added Account Wrapper: ' + account.Name + ', Total Quantity: ' + totalQuantity);
                }

                // Add to the total quantity including children
                totalQuantityIncludingChildren += totalQuantity;

                // If it's the parent account, set the parent account quantity
                if (accountId == parentAccountId) {
                    parentAccountQuantity = (totalQuantity == null) ? 0 : totalQuantity;
                }
            }
        }

        // If the parent account had no direct won quotes, but child accounts do, the parent quantity is still 0
        if (parentAccountQuantity == 0 && !accountWrappers.isEmpty()) {
            parentAccountQuantity = 0;
        }

        System.debug('Parent Account Quantity: ' + parentAccountQuantity);
        System.debug('Total Quantity Including Children: ' + totalQuantityIncludingChildren);

        // Create the ParentAccountWrapper
        Account parentAccount = accountMap.get(parentAccountId);
        if (parentAccount == null) {
            System.debug('Parent account not found in accountMap for ID: ' + parentAccountId);
            return new List<ParentAccountWrapper>(); // Return empty list if parent account not found
        }

        ParentAccountWrapper parentWrapper = new ParentAccountWrapper(parentAccount.Name, parentAccountQuantity, totalQuantityIncludingChildren, accountWrappers);
        System.debug('Parent Account Wrapper: ' + parentWrapper);

        return new List<ParentAccountWrapper>{parentWrapper};
    }

    public class ParentAccountWrapper {
        @AuraEnabled
        public String ParentAccountName { get; set; }
        @AuraEnabled
        public Decimal ParentAccountQuantity { get; set; } // Quantity for the parent account itself
        @AuraEnabled
        public Decimal TotalQuantityIncludingChildren { get; set; } // Parent + Child quantities
        @AuraEnabled
        public List<AccountWrapper> ChildAccounts { get; set; }

        public ParentAccountWrapper(String parentName, Decimal parentAccountQuantity, Decimal totalQuantityIncludingChildren, List<AccountWrapper> childAccounts) {
            this.ParentAccountName = parentName;
            this.ParentAccountQuantity = parentAccountQuantity;
            this.TotalQuantityIncludingChildren = totalQuantityIncludingChildren;
            this.ChildAccounts = childAccounts;
        }
    }

    public class AccountWrapper {
        @AuraEnabled
        public String AccountName { get; set; }
        @AuraEnabled
        public Decimal TotalQuantity { get; set; }

        public AccountWrapper(String name, Decimal totalQuantity) {
            this.AccountName = name;
            this.TotalQuantity = totalQuantity;
        }
    }
}