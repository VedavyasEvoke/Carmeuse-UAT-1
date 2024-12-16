global class ev_MarketInfoFollowUp6monthsEmail implements Database.Batchable<sObject>{ 
global Database.QueryLocator start(Database.BatchableContext BC) {
      Date now = Date.today();
      //Date nowtoday=Date.today();
      //Date now = nowtoday.addMonths(+6);
       system.debug(now);
       DateTime sixMonthsAgo = now.addMonths(-6);
       DateTime Sixmonthnextday=sixMonthsAgo+1;
        system.debug(sixMonthsAgo);
        String query = 'select Id, Name, Owner.Email,Owner.Name,Region1__c  from Market_Info__c where Region1__c != \'North America\' and CreatedDate >=: sixMonthsAgo and CreatedDate <:Sixmonthnextday'
 ;
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Market_Info__c> scope) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        // loop through the scope
        for (Market_Info__c m : scope) {
               if(m.Owner.Email !=Null)
               {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSaveAsActivity(false);
                mail.setSubject('Reminder: Market Info Record ' + m.Name + ' Has Reached 6 Months Milestone');
                mail.setPlainTextBody('Hi ' + m.Owner.Name + ',\n\n' + 
                      'The MarketInfo named ' + m.Name + ' requires follow-up as it has completed 6 months duration.\n\n' + 
                      'Thank you.');
 
                mail.setToAddresses(new String[]{m.Owner.Email});
                emails.add(mail);
               }
       }
 
        // send the email 
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
 
    global void finish(Database.BatchableContext BC) {
        // Optional: Implement any post-processing logic here
    }
}