public class BatchToRebuildIndex  implements Database.Batchable<sObject>, Schedulable {
    public Database.QueryLocator start(Database.BatchableContext batchContext){
        return DataBase.getQueryLocator('SELECT Id,Name FROM WebStore WHERE Name =\'Carmeuse Customer Portal\'');
    }
    public void execute(SchedulableContext SC){
        BatchToRebuildIndex objRebuild =  new BatchToRebuildIndex();
        Database.executeBatch(objRebuild);
    }
    public void execute(Database.BatchableContext batchContext, List<WebStore> lstWebStore){
        //This batch is used to rebuild the search index
        Id storeId;
        if(lstWebStore.size() > 0){
            storeId = lstWebStore[0].Id;
        }
        ConnectApi.CommerceSearchIndex rebuildDemo = ConnectApi.CommerceSearchSettings.createCommerceSearchIndex(storeId);
    }
    
    public void finish(Database.BatchableContext batchContext){
        
    }
}