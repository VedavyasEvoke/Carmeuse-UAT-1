global class ev_LeadNextFollowUpDateEmail implements Database.Batchable<sObject>{
//initial batch query for records to enter the process
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query='Select Id,Name,Status,Next_Followup_Date__c,LastModifiedDate from Lead WHERE Next_Followup_Date__c = Tomorrow';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        // Query the lead specialist, currently it is going to be Whitney putting my name for test purposes
        String FirstName=Label.Lead_Follow_Up_3_Days_After;
        User leadSpecialist = [SELECT Id, Email FROM User WHERE FirstName =:FirstName LIMIT 1];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        //loop the batch scope and set the email details
        for (Lead lead : scope) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(leadSpecialist.Id);
            mail.setSaveAsActivity(false);
            mail.setSubject('Lead' + ' ' + Lead.Name + ' ' + 'Has Been In The Follow-Up on Next Day');
            mail.setPlainTextBody('The Lead named ' + lead.Name + ' requires follow-up tomorrow.');
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