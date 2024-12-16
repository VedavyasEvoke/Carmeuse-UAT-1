@isTest
public class ev_SalesCompetitorTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        // Create Accounts
        Account parentAccount = new Account(
            Name = 'Parent Account',
            Account_Group__c = '1',
            Business_unit__c='Carmeuse',
            Customer_region__c = 'Western Europe'
        );
        insert parentAccount;
         update parentAccount;
        
        Account childAccount1 = new Account(
            Name = 'Child Account 1',
            ParentId = parentAccount.Id,
            Account_Group__c = '2',
            Customer_region__c = 'Central Europe',
            Business_unit__c='Carmeuse'
        );
        insert childAccount1;
        Update childAccount1;
        Account childAccount2 = new Account(
            Name = 'Child Account 2',
            ParentId = parentAccount.Id,
            Account_Group__c = null,
            Customer_region__c = 'Western Europe',
            Business_unit__c='Carmeuse'
        );
        insert childAccount2;
         Update childAccount2;
        
        // Create Opportunities
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            AccountId = childAccount1.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Business_Unit__c = 'Carmeuse'
        );
        insert opp1;
        System.debug('Inserted opp'+opp1.Name);
        
        Opportunity opp2 = new Opportunity(
            Name = 'Opportunity 2',
            AccountId = childAccount2.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Business_Unit__c = 'Carmeuse'
        );
        insert opp2;
        
        // Retrieve the Record Type IDs for 'Company' and 'Plant'
        Id competitorRecordTypeId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id plantRecordTypeId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByName().get('Plant').getRecordTypeId();
        
        // Create Competitor records with Record Type 'Company'
        Competitor__c competitorA = new Competitor__c(Name = 'Competitor A', RecordTypeId = competitorRecordTypeId);
        insert competitorA;
        
        Competitor__c competitorB = new Competitor__c(Name = 'Competitor B', RecordTypeId = competitorRecordTypeId);
        insert competitorB;
        
        // Create Plant records with Record Type 'Plant' and link to Competitors
        Competitor__c plantA = new Competitor__c(Name = 'Plant A', RecordTypeId = plantRecordTypeId, Company__c = competitorA.Id);
        insert plantA;
        
        Competitor__c plantB = new Competitor__c(Name = 'Plant B', RecordTypeId = plantRecordTypeId, Company__c = competitorB.Id);
        insert plantB;
        
        Product2 productA = new Product2(Name = 'Product A', Is_Offline__c = true, Family = 'Sales Organization');
        insert productA;
        
        Product2 productB = new Product2(Name = 'Product B', Is_Offline__c = true, Family = 'Sales Organization');
        insert productB;
    }
    
    @isTest
    static void testHandleAfterInsert() {
        // Retrieve setup data
        List<Opportunity> opptlist = [SELECT Id,Name, AccountId, Business_Unit__c, Account.Account_Group__c, Account.Customer_region__c FROM Opportunity ];
        Opportunity oppt1= opptlist[0];
        Opportunity  oppt2= opptlist[1];
        System.debug('Opp1'+oppt1.Name);
        System.debug('Opp2'+oppt2.Name);
        Competitor__c competitorA = [SELECT Id FROM Competitor__c WHERE Name = 'Competitor A' LIMIT 1];
        Competitor__c plantA = [SELECT Id FROM Competitor__c WHERE Name = 'Plant A' LIMIT 1];
        Product2 productA = [SELECT Id FROM Product2 WHERE Name = 'Product A' LIMIT 1];
        
        // Insert new Sales Competitor records
        List<Sales_Competitor__c> newCompetitors = new List<Sales_Competitor__c>();
        newCompetitors.add(new Sales_Competitor__c(
            Opportunity__c = oppt1.Id,
            Plant__c = plantA.Id,
            Competitor__c = competitorA.Id,
            Product__c = productA.Id,
            UOM__c = 'Ton'
         ));
         newCompetitors.add(new Sales_Competitor__c(
            Opportunity__c = oppt2.Id,
            Plant__c = plantA.Id,
            Competitor__c = competitorA.Id,
            Product__c = productA.Id,
            UOM__c = 'Ton'
             
        ));
        
        Test.startTest();
        insert newCompetitors;
        ev_SalesCompetitorTriggerHandler.handleAfterInsertOrUpdate(newCompetitors, null);
        Test.stopTest();
        
        // Verify Market Info records were created
        List<Market_Info__c> marketInfoRecords = [SELECT Id, Name, SoldTo__c, Competitor_Product__c, Competitor__c,Competitor_Product__r.Name, Competitor_Plant_Id__c FROM Market_Info__c  ];
 

    }
    
    @isTest
    static void testHandleAfterUpdate() {
        // Retrieve setup data
        Opportunity opp1 = [SELECT Id, AccountId, Business_Unit__c, Account.Account_Group__c, Account.Customer_region__c FROM Opportunity LIMIT 1];
        Competitor__c competitorA = [SELECT Id FROM Competitor__c WHERE Name = 'Competitor A' LIMIT 1];
        Competitor__c competitorB = [SELECT Id FROM Competitor__c WHERE Name = 'Competitor B' LIMIT 1];
        Competitor__c plantA = [SELECT Id FROM Competitor__c WHERE Name = 'Plant A' LIMIT 1];
        Competitor__c plantB = [SELECT Id FROM Competitor__c WHERE Name = 'Plant B' LIMIT 1];
        Product2 productA = [SELECT Id FROM Product2 WHERE Name = 'Product A' LIMIT 1];
        Product2 productB = [SELECT Id FROM Product2 WHERE Name = 'Product B' LIMIT 1];
        
        // Insert initial Sales Competitor records
        Sales_Competitor__c initialCompetitor = new Sales_Competitor__c(
            Opportunity__c = opp1.Id,
            Plant__c = plantA.Id,
            Competitor__c = competitorA.Id,
            Product__c = productA.Id,
            UOM__c = 'Ton'
        );
        insert initialCompetitor;
        
        // Update the Sales Competitor record
        Sales_Competitor__c updatedCompetitor = [SELECT Id, Opportunity__c, Product_2__c,Plant__c, Competitor__c,Product_Name__c,Year__c,Sub_Market__c,Market__c, Product__c, UOM__c,Tons__c FROM Sales_Competitor__c WHERE Id = :initialCompetitor.Id LIMIT 1];
        updatedCompetitor.Plant__c = plantB.Id;
        updatedCompetitor.Competitor__c = competitorB.Id;
        updatedCompetitor.Product__c = productB.Id;
        updatedCompetitor.UOM__c = 'TO';
        
         
        Map<Id, Sales_Competitor__c> oldCompetitorsMap = new Map<Id, Sales_Competitor__c>();
        oldCompetitorsMap.put(initialCompetitor.Id, initialCompetitor);
        
        Test.startTest();
        update updatedCompetitor;
        ev_SalesCompetitorTriggerHandler.handleAfterInsertOrUpdate(new List<Sales_Competitor__c>{ updatedCompetitor }, oldCompetitorsMap);
        Test.stopTest();
        
        
        List<Market_Info__c> marketInfoRecords = [SELECT Id, Name, SoldTo__c, Competitor_Product__c, Competitor__c, Competitor_Plant_Id__c FROM Market_Info__c];
        System.assertEquals(3, marketInfoRecords.size(), '3 Market Info records should be present after update');
    }
        @isTest
    static void testHandleAfterInsertWithDuplicateMarketInfo() {
        // Retrieve setup data
        Opportunity opp1 = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Competitor__c competitorA = [SELECT Id FROM Competitor__c WHERE Name = 'Competitor A' LIMIT 1];
        Competitor__c plantA = [SELECT Id FROM Competitor__c WHERE Name = 'Plant A' LIMIT 1];
        Product2 productA = [SELECT Id FROM Product2 WHERE Name = 'Product A' LIMIT 1];
        
        // Create an existing Market Info record that matches the criteria
        Market_Info__c existingMarketInfo = new Market_Info__c(
            Name = 'Existing Market Info',
            Competitor_Product__c = productA.Id,
            Competitor__c = competitorA.Id,
            Competitor_Plant_Id__c = plantA.Id,
            SoldTo__c = opp1.AccountId,
            Year__c = '2024'
        );
        insert existingMarketInfo;
        
        // Create Sales Competitor records that should trigger the addError
        Sales_Competitor__c competitor = new Sales_Competitor__c(
            Opportunity__c = opp1.Id,
            Plant__c = plantA.Id,
            Competitor__c = competitorA.Id,
            Product__c = productA.Id,
            UOM__c = 'Ton'
        );
        
        Test.startTest();
        try {
            insert competitor; // This should trigger the addError
            
        } catch (DmlException e) {
            // Verify that the DmlException is thrown, which is expected
            System.debug('Expected exception: ' + e.getMessage());
        }
        Test.stopTest();
        
    }

}