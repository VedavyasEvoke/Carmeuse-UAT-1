public class Ev_PricingCouncilNotification  {
    //public List<SBQQ__Quote__c> quotes;
    
   // public Ev_PricingCouncilNotification(List<SBQQ__Quote__c> quotes) {
     //   this.quotes = quotes;
   // }
    public class PricingWrapper{
        @InvocableVariable
        public SBQQ__Quote__c quote;
        
        @InvocableVariable
        public string message;
        
        @InvocableVariable
        public string subject;
    }
    
    @InvocableMethod(label='pricingNotification')
    public static void sendNotification(List<PricingWrapper> wrapper) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        //for(SBQQ__Quote__c quote: wrapper[0].quotes) {  
            emails.add(getEmailMessage(wrapper[0].quote,wrapper[0].message,wrapper[0].subject));
        //}
        Messaging.sendEmail(emails);        
    }
    
    public static Messaging.SingleEmailMessage getEmailMessage(SBQQ__Quote__c quote,String message,String subject) {    
        PageReference pdf = Page.Ev_PricingCouncilAttachment;   //mail_pdf is the name of vf page
        pdf.getParameters().put('qid', quote.Id);
        Blob body;                
        try {
            body = pdf.getContentAsPDF();
        } catch(Exception e) {
            body = Blob.valueOf('---No File---');
        }
        
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setContentType('application/pdf');
        attachment.setFileName('PricingCouncil.pdf');
        attachment.setInline(false);
        attachment.Body = body;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setTargetObjectId(quote.OwnerId);
        mail.setSubject(subject);
        mail.setHtmlBody(message);
        mail.setSaveAsActivity(false); 
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        return mail;
    }
}