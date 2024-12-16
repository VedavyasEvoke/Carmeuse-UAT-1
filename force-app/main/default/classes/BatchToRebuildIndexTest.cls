@isTest(SeeAllData=true)
public class BatchToRebuildIndexTest {
    @isTest 
    public static void verifyRebuildIndex(){
        
        WebStore store = new WebStore(Name = 'Carmeuse Customer Portal');
        insert store;
        
        Test.startTest();
        // Schedule the batch
        BatchToRebuildIndex batchJob = new BatchToRebuildIndex();
        String schedulableId = System.schedule('Test Batch Job', '0 30 * * * ?', batchJob);
        Test.stopTest();
        
        List<WebStore> lstWebStore = [SELECT Id, Name FROM WebStore WHERE Name='Carmeuse Customer Portal'];
        //Verify that the execute method was called and the search index was rebuilt
        // List<ConnectApi.CommerceSearchIndex> indexes = [SELECT Id FROM ConnectApi.CommerceSearchIndex];
        // System.assertEquals(1, indexes.size());
        // System.assertEquals(webStore.Id, indexes[0].Id);
    }
    
}