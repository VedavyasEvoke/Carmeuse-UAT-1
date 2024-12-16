@IsTest
public class Ev_CICProductCompanyHandlerTest {
    
    @IsTest
    static void testCreateProductCompanies() {
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
        
        // Create Product records
        CIC_Products__c productA = new CIC_Products__c(Name = 'Product A', Competitor__c =competitorA.Id );
        insert productA;
        
        CIC_Products__c productB = new CIC_Products__c(Name = 'Product B',Competitor__c=competitorB.Id  );
        insert productB;
        
        // Prepare request with test data
        Ev_CICProductCompanyHandler.Request request = new Ev_CICProductCompanyHandler.Request();
        request.productId = productA.Id;
        request.companyIds = competitorA.Id + ';' + competitorB.Id;
        
        // Call the method
        Test.startTest();
        Ev_CICProductCompanyHandler.createProductCompanies(new List<Ev_CICProductCompanyHandler.Request>{ request });
        Test.stopTest();
        
        // Verify that the records were created
        List<CIC_Product_Company__c> createdRecords = [SELECT CIC_Products__c, Competitor__c 
                                                       FROM CIC_Product_Company__c 
                                                       WHERE CIC_Products__c = :productA.Id];
        
        System.assertEquals(2, createdRecords.size(), 'Two records should have been created.');
        System.assertEquals(competitorA.Id, createdRecords[0].Competitor__c, 'First competitor should match.');
        System.assertEquals(competitorB.Id, createdRecords[1].Competitor__c, 'Second competitor should match.');
    }
      @IsTest
    static void testCreateProductPlants() {
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
        Competitor__c plantB = new Competitor__c(Name = 'Plant B', RecordTypeId = plantRecordTypeId, Company__c = competitorB.Id);
        insert new List<Competitor__c>{ plantA, plantB };
        
        // Create Product records
        CIC_Products__c productA = new CIC_Products__c(Name = 'Product A', Competitor__c = competitorA.Id);
        insert productA;
        
        CIC_Products__c productB = new CIC_Products__c(Name = 'Product B', Competitor__c = competitorB.Id);
        insert productB;
        
        // Create Product_Company records
        CIC_Product_Company__c productCompanyA = new CIC_Product_Company__c(CIC_Products__c = productA.Id, Competitor__c = competitorA.Id);
        CIC_Product_Company__c productCompanyB = new CIC_Product_Company__c(CIC_Products__c = productA.Id, Competitor__c = competitorB.Id);
        insert new List<CIC_Product_Company__c>{ productCompanyA, productCompanyB };
        
        // Prepare request with test data
        Ev_CICProductPlantHandler.Request request = new Ev_CICProductPlantHandler.Request();
        request.productId = productCompanyA.Id;
        request.companyProductIds = plantA.Id + ';' + plantB.Id;
        
        // Call the method
        Test.startTest();
        Ev_CICProductPlantHandler.createProductplants(new List<Ev_CICProductPlantHandler.Request>{ request });
        Test.stopTest();
        
        // Verify that the records were created
        List<CIC_Productplant__c> createdRecords = [SELECT Product_Company__c, Plant__c 
                                                    FROM CIC_Productplant__c 
                                                    WHERE Product_Company__c = :productCompanyA.Id];
        
        System.assertEquals(2, createdRecords.size(), 'Two records should have been created.');
        System.assertEquals(plantA.Id, createdRecords[0].Plant__c, 'First plant should match.');
        System.assertEquals(plantB.Id, createdRecords[1].Plant__c, 'Second plant should match.');
    }
    
  
}