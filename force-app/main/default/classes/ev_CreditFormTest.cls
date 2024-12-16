@isTest
public class ev_CreditFormTest {
    @isTest
    static void sendFormTest(){
        List<Account>lstaccount=new List<Account>();
            Document doc = new Document(
            Name = 'Credit Form',
            Body = Blob.valueOf('This is a test document'),
            ContentType = 'application/pdf',
            FolderId = UserInfo.getUserId()
        );
        insert doc;
        Account account=new Account(Name='Test Account Record',Contact_Email__c='testing1@gmail.com');
        insert account;
        lstaccount.add(account);
        List<Id> ids=new List<Id>();
        ids.add(account.Id);
		
        Test.startTest(); 
        System.debug(ids);
        ev_CreditForm.sendForm(ids);
        System.debug(ids);
        Test.stopTest();
        account = [Select Contact_Email__c From Account where ID = :account.id];
        system.assertEquals('testing1@gmail.com', account.Contact_Email__c);
    }
}