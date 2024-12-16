@isTest
public class ev_copySalesCompOnLeadToOpportunityTest {
    
    @testSetup
    static void setup() {
        
        Lead lead = new Lead(FirstName = 'Test', LastName = 'Lead', Company = 'Test Company', Status = 'Qualified');
        insert lead;
        
        // Convert the lead
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.Id);
        
        // Create an Account to be linked to the converted lead
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        lc.setAccountId(acc.Id);
        
        // Create a Contact to be linked to the converted lead
        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;
        lc.setContactId(con.Id);
        
        // Create an Opportunity to be linked to the converted lead
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today().addDays(30));
        insert opp;
        lc.setOpportunityId(opp.Id);
        
        // Set the converted status
        lc.setConvertedStatus(lead.Status);
        
        // Convert the lead
        Database.convertLead(lc);
        
        // Query the converted lead
        lead = [SELECT Id, IsConverted, ConvertedOpportunityId FROM Lead WHERE Id = :lead.Id LIMIT 1];
        
        // Create Sales Competitor records linked to the lead
        Sales_Competitor__c sc1 = new Sales_Competitor__c(Lead__c = lead.Id);
        insert sc1;
    }

    @isTest
    static void testCopySalesCompOnLeadToOpportunity() {
        // Retrieve the setup data
        Lead lead = [SELECT Id, IsConverted, ConvertedOpportunityId FROM Lead LIMIT 1];
        
        // Create a list of leads to pass to the method
        List<Lead> leads = new List<Lead>{ lead };
        
        // Call the method
        Test.startTest();
        ev_copySalesCompOnLeadToOpportunity.copySalesCompOnLeadToOpportunity(leads);
        Test.stopTest();
        
        // Query the Sales Competitor records to verify the Opportunity__c field is updated
        List<Sales_Competitor__c> salesCompetitors = [SELECT Id, Lead__c, Opportunity__c FROM Sales_Competitor__c WHERE Lead__c = :lead.Id];
        
        // Verify the Sales Competitor record has been updated with the converted Opportunity Id
        for (Sales_Competitor__c sc : salesCompetitors) {
            System.assertEquals(lead.ConvertedOpportunityId, sc.Opportunity__c);
        }
    }
    
   
}