public with sharing class AccountTriggerExecutor implements TriggerExecutor_I {

	public Schema.SObjectType getSObjectType() {
		return Account.SObjectType;
	}

	public void beforeInsert(List<Account> triggerNew) {

	}

	public void beforeUpdate(Map<Id, SObject> triggerOldMap, List<Account> triggerNew) {
	}

	public void beforeDelete(List<Account> triggerOld) {
	}

	public void afterInsert(List<Account> triggerNew) {
        List<Account> accList = new List<Account>();
        
        //Evoke added Boolean for B2B customers and this field will be added to Bapi by viswa. Need to check on Update logic with Enzigma/Anjali
        for(Account acc : triggerNew) {
            if(acc.B2B_Customer__c){
                accList.add(acc);
            }
        }

        if(accList.size() > 0) {
            Database.executebatch(new AccountTriggerBatch(accList), 70);
        }
	}

    public void afterUpdate(Map<Id, SObject> triggerOldMap, List<Account> triggerNew) {    
        List<Account> accList = new List<Account>();
        
        for(Account acc : triggerNew) {
            Account oldAccount = (Account) triggerOldMap.get(acc.Id);
            if(acc.B2B_Customer__c == true  && oldAccount.B2B_Customer__c == false){
                accList.add(acc);
            }
        }
        
        if(accList.size() > 0) {
            Database.executebatch(new AccountTriggerBatch(accList), 70);
        }
    }

	public void afterDelete(List<Account> triggerOld) {

	}
}