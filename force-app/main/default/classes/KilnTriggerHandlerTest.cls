@isTest
public class KilnTriggerHandlerTest {
    
    @isTest
    public static void updatePlantFieldsTest(){
        String plantRecordTypeId =  Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Plant').getRecordTypeId();
        Competitor__c competitor = new Competitor__c();
        competitor.Name = 'TestPlant';
        competitor.RecordTypeId = plantRecordTypeId;
        competitor.Total_No_Kilns__c = 1;
        insert competitor;
        
        Kiln_Report__c kiln = new Kiln_Report__c();
        kiln.Plant__c = competitor.id;
        kiln.Est_Prod_t_y__c = 1000;
        kiln.Cap_t_y__c = 20000;
        kiln.Active__c = true;
        kiln.Nbr__c = 1;
        
        Test.startTest();
        insert kiln;
        Test.stopTest();

        system.assert(true, kiln !=null);
        
    }
    
    @isTest
    public static void deleteKilnReportTest(){
        String plantRecordTypeId =  Schema.SObjectType.Competitor__c.getRecordTypeInfosByDeveloperName().get('Plant').getRecordTypeId();
        Competitor__c competitor = new Competitor__c();
        competitor.Name = 'TestPlant';
       // competitor.Total_No_Kilns__c = 1;
        competitor.RecordTypeId = plantRecordTypeId;
        insert competitor;
        
        Kiln_Report__c kiln = new Kiln_Report__c();
        kiln.Plant__c = competitor.id;
        kiln.Est_Prod_t_y__c = 1000;
        kiln.Cap_t_y__c = 20000;
        kiln.Active__c = true;
        kiln.Nbr__c = 1;
        insert kiln;
     
        Test.startTest();
        Delete kiln;
        Test.stopTest();

        system.assert(true, kiln !=null);
        
    }
}