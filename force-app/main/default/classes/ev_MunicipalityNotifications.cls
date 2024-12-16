global class ev_MunicipalityNotifications implements Database.Batchable<sObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // query opps that owners will be notified
        String query = 'SELECT Id, Name, Bid_Due_Date__c, Municipality__c, OwnerId ' + 
               'FROM Opportunity ' + 
               'WHERE Municipality__c = \'Yes\' ' + 
               'AND Bid_Due_Date__c = NEXT_N_DAYS:120';
        
         
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        // Create a set to store the unique owners
        Set<Id> ownerIds = new Set<Id>();
        for (sObject record : scope) {
            Opportunity opp = (Opportunity)record;
            ownerIds.add(opp.OwnerId);
        }

        // Query User records to get email addresses
        Map<Id, User> ownerMap = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :ownerIds]);

        // List to hold all emails to be sent
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Opportunity opp : (List<Opportunity>)scope) {
            User owner = ownerMap.get(opp.OwnerId);
            if (owner != null && owner.Email != null) {
                // Construct the email
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //mail.setToAddresses(new String[]{owner.Email, 'matthew.glynn@carmeuse.com', 'dana.brooks@carmeuse.com'});
                mail.setToAddresses(new String[]{owner.email, 'skylerh@dextara.com'});
                mail.setSubject('Municipality Bid Due in 120 Days');
                mail.setPlainTextBody('The Municipal Opportunity ' + opp.Name + ' is due in the next 120 days. Please make appropriate preparations');
                
                // Add the email to the list
                emails.add(mail);
            }
        }

        // Send the emails
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Post-processing logic here
    }
}