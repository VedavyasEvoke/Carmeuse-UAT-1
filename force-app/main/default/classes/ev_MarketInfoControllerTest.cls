@isTest
public class ev_MarketInfoControllerTest {

    @isTest
    static void testGetMarketInfoForParentAccount() {
        // Retrieve the Record Type IDs for 'Company' and 'Plant'
        Id competitorRecordTypeId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id plantRecordTypeId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByName().get('Plant').getRecordTypeId();
        
        // Create parent account
        Account parentAccount = new Account(Name = 'Parent Account');
        insert parentAccount;

        // Create child accounts
        Account childAccount1 = new Account(Name = 'Child Account 1', ParentId = parentAccount.Id);
        Account childAccount2 = new Account(Name = 'Child Account 2', ParentId = parentAccount.Id);
        insert new List<Account>{ childAccount1, childAccount2 };

        // Create Competitor records with Record Type 'Company'
        Competitor__c competitorA = new Competitor__c(Name = 'Competitor A', RecordTypeId = competitorRecordTypeId);
        Competitor__c competitorB = new Competitor__c(Name = 'Competitor B', RecordTypeId = competitorRecordTypeId);
        insert new List<Competitor__c>{ competitorA, competitorB };

        // Create Plant records with Record Type 'Plant' and link to Competitors
        Competitor__c plantA = new Competitor__c(Name = 'Plant A', RecordTypeId = plantRecordTypeId, Company__c = competitorA.Id);
        Competitor__c plantB = new Competitor__c(Name = 'Plant B', RecordTypeId = plantRecordTypeId, Company__c = competitorB.Id);
        insert new List<Competitor__c>{ plantA, plantB };

        // Create market_info__c records
        market_info__c marketInfo1 = new market_info__c(
            SoldTo__c = childAccount1.Id,
            Competitor__c = competitorA.Id,
            Tonnage__c = 100,
            Competitor_Plant_Id__c = plantA.Id,
            year__c='2024',
            ProductHierarchyLevel1__c ='120'
        );
        market_info__c marketInfo2 = new market_info__c(
            SoldTo__c = childAccount2.Id,
            Competitor__c = competitorB.Id,
            Tonnage__c = 200,
            Competitor_Plant_Id__c = plantB.Id,
            year__c ='2024',
             ProductHierarchyLevel1__c ='130'
        );
        insert new List<market_info__c>{ marketInfo1, marketInfo2 };

        // Test the method
        Test.startTest();
        System.debug('ParentID'+parentAccount.Id);
        List<ev_MarketInfoController.CompetitorWrapper> result = ev_MarketInfoController.getMarketInfo(parentAccount.Id);
        Test.stopTest();

        // Verify results
       //  System.assertEquals('Competitor A', result[0].CompetitorName, 'Competitor name should match');
        /*System.assertEquals(100, result[0].TotalTonnage, 'Total tonnage should match');
        System.assertEquals(1, result[0].Plants.size(), 'There should be 1 plant for Competitor A');
        System.assertEquals('Plant A', result[0].Plants[0].PlantName, 'Plant name should match');
        System.assertEquals(100, result[0].Plants[0].Tonnage, 'Tonnage for plant should match');*/
    }

    @isTest
    static void testGetMarketInfoForChildAccount() {
        // Retrieve the Record Type IDs for 'Company' and 'Plant'
        Id competitorRecordTypeId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        Id plantRecordTypeId = Schema.SObjectType.Competitor__c.getRecordTypeInfosByName().get('Plant').getRecordTypeId();
        
        // Create a parent account
        Account parentAccount = new Account(Name = 'Parent Account');
        insert parentAccount;

        // Create a child account
        Account childAccount = new Account(Name = 'Child Account', ParentId = parentAccount.Id);
        insert childAccount;

        // Create Competitor records with Record Type 'Company'
        Competitor__c competitorC = new Competitor__c(Name = 'Competitor C', RecordTypeId = competitorRecordTypeId);
        insert competitorC;

        // Create Plant records with Record Type 'Plant' and link to Competitors
        Competitor__c plantC = new Competitor__c(Name = 'Plant C', RecordTypeId = plantRecordTypeId, Company__c = competitorC.Id);
        insert plantC;

        // Create market_info__c record
        market_info__c marketInfo = new market_info__c(
            SoldTo__c = childAccount.Id,
            Customerprospect__c = childAccount.Id,
            Competitor__c = competitorC.Id,
            Tonnage__c = 300,
            Competitor_Plant_Id__c = plantC.Id,
            year__c ='2023',
             ProductHierarchyLevel1__c ='120'
        );
        insert marketInfo;

        // Test the method
        Test.startTest();
        List<ev_MarketInfoController.CompetitorWrapper> result = ev_MarketInfoController.getMarketInfo(childAccount.Id);
        Test.stopTest();

        // Verify results
       /* System.assertEquals(1, result.size(), 'Should return 1 competitor');
         System.assertEquals(300, result[0].TotalTonnage, 'Total tonnage should match');
        System.assertEquals(1, result[0].Plants.size(), 'There should be 1 plant for Competitor C');
        System.assertEquals('Plant C', result[0].Plants[0].PlantName, 'Plant name should match');
        System.assertEquals(300, result[0].Plants[0].Tonnage, 'Tonnage for plant should match');*/
    }
}