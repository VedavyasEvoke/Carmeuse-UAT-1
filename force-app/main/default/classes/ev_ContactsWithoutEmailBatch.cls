global class ev_ContactsWithoutEmailBatch implements Database.Batchable<SObject>, Database.Stateful ,Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, OwnerId, Owner.Email, Owner.Name,Business_Unit__c  FROM Contact   WHERE Email = Null and  Business_Unit__c =\'Carmeuse Systems\' and  LastModifiedDate =LAST_N_DAYS:1 ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        // Group contacts by their owners
        Map<Id, List<Contact>> ownerContactsMap = new Map<Id, List<Contact>>();
        
        for (Contact contact : scope) {
            if (!ownerContactsMap.containsKey(contact.OwnerId)) {
                ownerContactsMap.put(contact.OwnerId, new List<Contact>());
            }
            ownerContactsMap.get(contact.OwnerId).add(contact);
        }
        
        // Send email to each owner
        for (Id ownerId : ownerContactsMap.keySet()) {
            List<Contact> ownerContacts = ownerContactsMap.get(ownerId);
            sendEmailToOwner(ownerId, ownerContacts);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Optionally add any finish logic
    }
    
    private void sendEmailToOwner(Id ownerId, List<Contact> contacts) {
        String ownerEmail;
        String ownerName;
        // Fetch the owner's email and name
        User owner = [SELECT Email, Name FROM User WHERE Id = :ownerId LIMIT 1];
        ownerEmail = owner.Email;
        ownerName = owner.Name;
        
        if (String.isNotBlank(ownerEmail)) {
            // Prepare the email body with HTML table
            String emailBody = '<p>Dear ' + ownerName + ',</p>' +
                '<p>Here is the list of Contacts that do not have an email address:</p>' +
                '<table border="1" style="border-collapse: collapse;">' +
                '<tr><th>Contact Name</th><th>Contact ID</th></tr>';
            
            for (Contact contact : contacts) {
                String contactLink = '<a href="' + System.Url.getOrgDomainUrl() + '/' + contact.Id + '">' + contact.Id + '</a>';
                
               
                emailBody += '<tr><td>' + contact.Name + '</td><td>' + contactLink + '</td></tr>';
            }
            
            emailBody += '</table>' +
                '<p> Thanks<br>  </p>';
            
            // Send the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { ownerEmail });
            email.setSubject('Contacts Without Email Addresses');
            email.setHtmlBody(emailBody);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
    global void execute(SchedulableContext sc) {
        // Schedule the batch to run daily 
        ev_ContactsWithoutEmailBatch batch = new ev_ContactsWithoutEmailBatch();
        Database.executeBatch(batch, 200); 
    }
    
}