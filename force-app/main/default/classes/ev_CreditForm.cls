public class ev_CreditForm {
    @InvocableVariable
    public List<Id> recordId;
    
    @InvocableMethod(Label='Send Email')
    public static List<Id> sendForm(List<ID> recordId){        
        //Document Get 
        Document document=[Select Id,Name,Body,ContentType from Document where Name='Credit Form'];
        Messaging.EmailFileAttachment eft1=new Messaging.EmailFileAttachment();
        eft1.setBody(document.Body);
        eft1.setFileName(document.Name);
        eft1.setContentType(document.ContentType);
        
        Messaging.EmailFileAttachment[] files=new Messaging.EmailFileAttachment[]{eft1};
            //Fetch the Account to whom we want to send the email
            List<Account> lstaccount=[Select Id,Name,Contact_Email__c from Account where Id=:recordId and Contact_Email__c !=null];
        List<Messaging.Email> emails=new List<Messaging.Email>();
        for(Account account:lstaccount){
            String[] toAddress=new String[]{account.Contact_Email__c};
                String body='Dear Customer,<br/><br/>';
            body=body+'<i>Please kindly fill the following details attached in the form</i>.<br/><br/>';
            //body=body+'<a href='{!Account.Id}'/>';
            body=body+'Thank You,<br/> Carmeuse Systems Team';
            Messaging.SingleEmailMessage msg=new Messaging.SingleEmailMessage();
            msg.setToAddresses(toAddress);
            msg.setSubject('Credit Authorization Form');
            msg.setHtmlBody(body);
            msg.setFileAttachments(files);
            msg.setSenderDisplayName('Credit Carmeuse Systems Team');
            emails.add(msg);
        }
        messaging.sendEmail(emails);
        return null;
    }
}