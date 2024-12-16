public class ev_ShipToOppsClass {
      @AuraEnabled(Cacheable = true)
    public static List<Opportunity> getOpps(String Id){
        System.debug('Id===='+Id);
        List<Account>  ShiptoAccs = [select id from account where parentId=:ID AND Account_Group__c ='2'];
        set<Id> accId = new set<Id>();
        for(Account a : ShiptoAccs){
            accId.add(a.Id);
        }
        
      return [SELECT Id, Name,CloseDate,stageName,amount__c FROM Opportunity where accountId =: accId ORDER BY Name];
    }
}