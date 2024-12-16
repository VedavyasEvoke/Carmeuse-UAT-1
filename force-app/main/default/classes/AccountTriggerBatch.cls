global class AccountTriggerBatch implements Database.Batchable<sObject> {
    global List<Account> accList = new List<Account>();

    global AccountTriggerBatch(List<Account> accList) {
        this.accList = accList;
    }

    global List<Account> start(Database.BatchableContext BC) {
        return accList; 
    }
     
    global void execute(Database.BatchableContext bc, List<Account> scope) {
        List<BuyerAccount> buyerAccounts = new List<BuyerAccount>();
        List<BuyerGroupMember> buyerGroupMembers = new List<BuyerGroupMember>();
        List<WebStoreBuyerGroup> storeBuyerGroups = new List<WebStoreBuyerGroup>();
        List<CommerceEntitlementBuyerGroup> bgEntitlementPolicies = new List<CommerceEntitlementBuyerGroup>();
        List<BuyerGroupPricebook> bgPriceBooks = new List<BuyerGroupPricebook>();

        List<WebStore> store = [SELECT Id, Name
                            FROM WebStore
                            WHERE Name = 'Carmeuse Customer Portal' LIMIT 1];
        Id storeId;

        if(store.size() > 0) {
            storeId = store[0].Id;
        }

        for(Account account : scope) {
            // Check if this is account has any child accounts
            List<Account> childAccounts = new List<Account>();
            childAccounts = [SELECT Id, ParentId
                            FROM Account
                            WHERE ParentId = :account.Id];

            if(!childAccounts.isEmpty()) {
                continue;
            }

            // Create Buyer Group
            BuyerGroup newBuyerGroup = new BuyerGroup();
            newBuyerGroup.Name = 'BG-' + account.Name;
            newBuyerGroup.Description = 'Buyer Group for ' + account.Name;
            newBuyerGroup.OwnerId = UserInfo.getUserId();
            newBuyerGroup.Account__c = account.Id;

            insert newBuyerGroup;
            // Enable Account as Buyer
            BuyerAccount newBuyerAccount = new BuyerAccount();
            newBuyerAccount.BuyerId = account.Id;
            newBuyerAccount.CommerceType = 'Buyer';
            newBuyerAccount.IsActive = true;
            newBuyerAccount.Name = account.Name;
            newBuyerAccount.OwnerId = UserInfo.getUserId();

            buyerAccounts.add(newBuyerAccount);
            // Assign Buyer Account to Buyer Group
            BuyerGroupMember newBuyerGroupMember = new BuyerGroupMember();
            newBuyerGroupMember.BuyerId = account.Id;
            newBuyerGroupMember.BuyerGroupId = newBuyerGroup.Id; 

            buyerGroupMembers.add(newBuyerGroupMember);
            // Assign Buyer Group to the store
            WebStoreBuyerGroup newStoreBuyerGroup = new WebStoreBuyerGroup();
            newStoreBuyerGroup.BuyerGroupId = newBuyerGroup.Id;
            newStoreBuyerGroup.WebStoreId = storeId;

            storeBuyerGroups.add(newStoreBuyerGroup);
            // Create Entitlement Policy
            CommerceEntitlementPolicy newEntitlementPolicy = new CommerceEntitlementPolicy();
            newEntitlementPolicy.Account__c = account.Id;
            newEntitlementPolicy.IsActive = true;
            newEntitlementPolicy.CanViewProduct = true;
            newEntitlementPolicy.CanViewPrice = false;
            newEntitlementPolicy.Name = 'EP-' + account.Name;
            newEntitlementPolicy.Description = 'Entitlement Policy for ' + account.Name;
            newEntitlementPolicy.OwnerId = UserInfo.getUserId();

            insert newEntitlementPolicy;
            // Assign Entitlement Policy to Buyer Group
            CommerceEntitlementBuyerGroup newBuyerGroupEP = new CommerceEntitlementBuyerGroup();
            newBuyerGroupEP.BuyerGroupId = newBuyerGroup.Id;
            newBuyerGroupEP.PolicyId = newEntitlementPolicy.Id; //List<sObject>

            bgEntitlementPolicies.add(newBuyerGroupEP);
            //Check to see if a Price Booke exists and if so assign to Buyer Group
            String searchText = account.Name;
            List<Pricebook2> accountPriceBook = [SELECT Id, Name, Description
                                          FROM Pricebook2
                                          WHERE Description LIKE :searchText];
                        
            if(accountPriceBook.size() > 0) {
                BuyerGroupPricebook newBuyerGroupPB = new BuyerGroupPricebook();
                for(Pricebook2 pb : accountPriceBook) {
                    if(pb.Description.contains(account.Name)) {
                        newBuyerGroupPB.BuyerGroupId = newBuyerGroup.Id;
                        newBuyerGroupPB.IsActive = true;
                        newBuyerGroupPB.Pricebook2Id = pb.Id;
                    }
                }
                bgPriceBooks.add(newBuyerGroupPB);
            }
        }

        if(!buyerAccounts.isEmpty()){
            insert buyerAccounts;
        }
        if(!buyerGroupMembers.isEmpty()){
            insert buyerGroupMembers;
        }
        if(!storeBuyerGroups.isEmpty()){
            insert storeBuyerGroups;
        }
        if(!bgEntitlementPolicies.isEmpty()){
            insert bgEntitlementPolicies;
        }
        if(!bgPriceBooks.isEmpty()){
            insert bgPriceBooks;
        }
    }   
     
    global void finish(Database.BatchableContext BC) {
        
    }
}