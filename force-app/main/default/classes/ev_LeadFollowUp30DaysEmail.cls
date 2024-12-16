global class ev_LeadFollowUp30DaysEmail implements Database.Batchable<sObject> {
//initial batch query for records to enter the process
    global Database.QueryLocator start(Database.BatchableContext BC) {
             String query='SELECT Id, Name, Status, LastModifiedDate FROM Lead WHERE Status!= \'New\' and LastModifiedDate =LAST_N_DAYS:30';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        // Query the lead specialist, currently it is going to be Mackenzie putting my name for test purposes
        String Username=Label.Lead_Follow_Up_UserName;
        User leadSpecialist = [SELECT Id, Email FROM User WHERE FirstName =:Username LIMIT 1];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        //loop the batch scope and set the email details
        for (Lead lead : scope) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(leadSpecialist.Id);
            mail.setSaveAsActivity(false);
            mail.setSubject('Lead' + ' ' + Lead.Name + ' ' + 'Has Been In The'+ ' ' + +lead.Status+ ' ' +' Status For 30 Days');
            mail.setPlainTextBody('The Lead named ' + lead.Name + ' requires follow-up after sitting in the'+ ' ' + +lead.Status+ ' ' +'status for 30 days.');
            emails.add(mail);
        }
        
        //send the email to the lead specialist
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // Optional: Implement any post-processing logic here in the future if needed
    }
}