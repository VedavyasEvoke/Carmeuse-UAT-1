@isTest
private class CompetitorTriggerHandlerTest {
    
    @isTest
    static void FreeCapacityUpdateTest1() {
        Competitor__c cic = new Competitor__c(
            Name = 'CIC',
            Nominal_Capacity_t_y__c = 10,
            Estimated_Production_t_y__c = 0
        );
        insert cic;
         
    }
    @isTest
    static void FreeCapacityUpdateTest2() {
        Competitor__c cic = new Competitor__c(
            Name = 'CIC',
            Nominal_Capacity_t_y__c = 10
        );
        insert cic;
        
    }
    @isTest
    static void FreeCapacityUpdateTest3() {
        Competitor__c cic = new Competitor__c(
            Name = 'CIC'            
        );
        insert cic;
        
    }
}