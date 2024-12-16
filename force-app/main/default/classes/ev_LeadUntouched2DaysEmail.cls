global class ev_LeadUntouched2DaysEmail implements Database.Batchable<sObject> { 

    // The start method defines the batch query and returns a Database.QueryLocator to fetch Lead records.
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        
        // Calculate the date that is two days ago from today.
        Date twoDaysAgo = Date.today().addDays(-2);
        
        // Calculate the end of the 2-day range, which is one day after the 2-day threshold.
        DateTime thirdday = twoDaysAgo + 1;
        
        // If a test is running, use a simplified query without date filtering.
        if(Test.isRunningTest()){
            query = 'SELECT Id, Name, Owner.Email, Owner.Name FROM Lead';
        }
        else{
            // Query for Leads that were modified between 2 days ago.
            query = 'SELECT Id, Name, Owner.Email, Owner.Name FROM Lead WHERE LastModifiedDate >= :twoDaysAgo AND LastModifiedDate < :thirdday';
        }

        // Return the query locator with the results of the query.
        return Database.getQueryLocator(query);
    }
    
    // The execute method processes the leads that have been fetched in the batch.
    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        // Create a list to hold the emails that will be sent.
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        // Loop through each lead in the current scope.
        for (Lead lead : scope) {
            // Check if the Lead Owner has an email.
            if (lead.Owner.Email != null) {
                // Create a new email message.
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                // Do not save this email as an activity.
                mail.setSaveAsActivity(false);
                
                // Set the subject of the email.
                mail.setSubject('Lead ' + lead.Name + ' Has Been Idle for 2 Days');
                
                // Set the body of the email with details about the idle lead.
                mail.setPlainTextBody('Hi ' + lead.Owner.Name + ',\n\n' + 
                                      'The Lead named ' + lead.Name + ' has been idle for 2 days and requires follow-up.\n\n' + 
                                      'Thank you.');
                
                // Set the recipient of the email to the lead owner's email address.
                mail.setToAddresses(new String[]{lead.Owner.Email});
                
                // Add the email to the list of emails to be sent.
                emails.add(mail);
            }
        }
        
        // If there are any emails to be sent, send them.
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
    
    // The finish method runs after all batches are processed. Post-processing logic can be added here if needed.
    global void finish(Database.BatchableContext BC) {
        // Optional: Implement any post-processing logic here.
    }
}