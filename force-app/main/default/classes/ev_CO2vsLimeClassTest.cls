/**
* @File Name : ev_CO2vsLimeClassTest.cls
* @Description : Test class for ev_CO2vsLimeClass
* @Author :Sameer
* @Last Modified By :
* @Last Modified On : August 27, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | August 27, 2024 |   | Initial Version
**/
@isTest
Public class ev_CO2vsLimeClassTest {
	@isTest
	static void TestMethod1(){
		Competitor__c c = new Competitor__c();
		C.Name = 'Hermalle';
        C.RecordTypeId = Schema.sObjectType.Competitor__c.getRecordTypeInfosByName().get('Plant').getRecordTypeId();
		Insert C;
        
        List<CIC_Fuel_CO2__c> Flist = new List<CIC_Fuel_CO2__c>();
        CIC_Fuel_CO2__c F = new CIC_Fuel_CO2__c();
        F.CIC_FUE_Fuel__c = 'Lignite';
        F.CIC_FUE_TCO2GJ__c = 0.1;
        Insert F;
        
        CIC_Fuel_CO2__c F2 = new CIC_Fuel_CO2__c();
        F2.CIC_FUE_Fuel__c = 'Alternative fuels';
        F2.CIC_FUE_TCO2GJ__c = 0.075;
        Insert F2;
        
        CIC_Products_CO2__c P = new CIC_Products_CO2__c();
        P.CIC_BUR_LimeType__c = 'Both';
        P.CIC_BUR_CO2Process__c = 0.81;
        Insert P;
        

		Kiln_Report__c K = new Kiln_Report__c();
		K.Plant__c = C.Id;
		K.Kiln__c ='Regenerative 3 shafts';
		K.Active__c = True;
		K.Est_Prod_t_y__c = 100000;
		K.Cap_t_y__c = 350000;
		K.Fuel_1__c = 'Lignite';
		K.Fuel_2__c = 'Alternative fuels';
		//K.Fuel_3__c = 'COAL';
		K.Lime_Type__c = 'Both';
		Insert K;

		Integer year = Date.today().year() ;
        
		CO2_VS_Lime__c Co = new CO2_VS_Lime__c();
		Co.Plant__c = C.Id;
		Co.Year__c = String.valueOf(year);
		Co.CO2_Emissions__c = 534993;
		Co.CO2_Allowances__c = 435295;
		Insert Co;
		List<CO2_VS_Lime__c> CoList = new List<CO2_VS_Lime__c>();
		CoList.add(Co);

		// Test the ev_CO2vsLimeClass method
        Test.startTest();
        ev_CO2vsLimeClass.CO2Calcutations(CoList);
        Test.stopTest();

	}
}