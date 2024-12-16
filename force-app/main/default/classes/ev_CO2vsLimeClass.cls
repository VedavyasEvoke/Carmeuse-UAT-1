public class ev_CO2vsLimeClass {
    public static void CO2Calcutations(List<CO2_VS_Lime__c> CLimeList ){
        system.debug(CLimeList);
	Set<ID> PlantId = new Set<ID>();
    Set<ID> CO2Id = new Set<ID>();
	Map<Id, List<Kiln_Report__c>> KilnMap= new Map<Id, List<Kiln_Report__c>>();
    Map<Id, List<CO2_VS_Lime__c>> CO2Map= new Map<Id, List<CO2_VS_Lime__c>>();
	List<Kiln_Report__c> FinalList = new List<Kiln_Report__c>();
// get all Fuels and its values 
Map<String, Decimal> FuelMap = new Map<String, Decimal>();
for(CIC_Fuel_CO2__c F : [Select id,CIC_FUE_Fuel__c,CIC_FUE_TCO2GJ__c from CIC_Fuel_CO2__c]){
    FuelMap.put(F.CIC_FUE_Fuel__c, F.CIC_FUE_TCO2GJ__c);
}

// get all lime types and its values
Map<String, Decimal> ProdMap = new Map<String, Decimal>();
for(CIC_Products_CO2__c P: [select id,CIC_BUR_LimeType__c,CIC_BUR_CO2Process__c from CIC_Products_CO2__c]){
    ProdMap.put(P.CIC_BUR_LimeType__c, P.CIC_BUR_CO2Process__c);
}

For(CO2_VS_Lime__c C : CLimeList){
	 PlantId.add(C.plant__c);
    // CO2Id.add(C.Id);
}

// Get all Kilns related to CO2vsLime records based on Plant.
List<Kiln_Report__c> Klist =[select id,plant__c,plant__r.Estimated_Production_t_y__c,Cap_t_y__c,Est_Prod_t_y__c,Lime_Type__c,Fuel_1__c,Fuel_2__c,Fuel_3__c,Active__c from Kiln_Report__c where plant__c=:PlantId AND Active__c = true];

for(Kiln_Report__c K : Klist){
	if(KilnMap.containsKey(K.plant__c) && KilnMap.get(K.plant__c) != null) {
        List<Kiln_Report__c> lst_terr = KilnMap.get(K.plant__c);
        lst_terr.add(K);
        KilnMap.put(K.plant__c,lst_terr); 
    }   
    else {
        KilnMap.put(K.plant__c, new List<Kiln_Report__c> {K});
    }
}
        
// Get all CO2vsLime records based on Plant.
List<CO2_VS_Lime__c> CO2list =[select id,plant__c,Year__c,Lime_Calculated_by_CO2_Allowance__c from CO2_VS_Lime__c where plant__c=:PlantId Order By plant__c desc,Year__c desc];

for(CO2_VS_Lime__c C : CO2list){
	if(CO2Map.containsKey(C.plant__c) && CO2Map.get(C.plant__c) != null) {
        List<CO2_VS_Lime__c> lst_terr = CO2Map.get(C.plant__c);
        lst_terr.add(C);
        CO2Map.put(C.plant__c,lst_terr); 
    }   
    else {
        CO2Map.put(C.plant__c, new List<CO2_VS_Lime__c> {C});
    }
}

for(CO2_VS_Lime__c C : CLimeList){
	
	List<Kiln_Report__c> KL = KilnMap.get(C.Plant__c);
    List<CO2_VS_Lime__c> CL = CO2Map.get(C.Plant__c);
    if(CL!= null && !CL.isEmpty()){
    //if(CL.size()>0){
        if(C.Year__c >= CL[0].Year__c){
	if(KL != null && !CL.isEmpty()){
		Decimal Sum1 = 0;
		Decimal Sum2 = 0;
		
		for(Kiln_Report__c K : KL){
			Decimal CO2Combution;
			if(k.Fuel_1__c != null && K.Fuel_2__c == null && K.Fuel_3__c == null){
				CO2Combution = FuelMap.get(K.Fuel_1__c)/1;
			}
			if(k.Fuel_1__c != null && K.Fuel_2__c != null && K.Fuel_3__c == null){
				CO2Combution = (FuelMap.get(K.Fuel_1__c)+FuelMap.get(K.Fuel_2__c))/2;
			}
			if(k.Fuel_1__c != null && K.Fuel_2__c != null && K.Fuel_3__c != null){
				CO2Combution = (FuelMap.get(K.Fuel_1__c)+FuelMap.get(K.Fuel_2__c)+FuelMap.get(K.Fuel_3__c))/3;
			}
            if(k.Fuel_1__c != null && K.Fuel_2__c == null && K.Fuel_3__c != null){
				CO2Combution = (FuelMap.get(K.Fuel_1__c)+FuelMap.get(K.Fuel_3__c))/2;
			}
            if(k.Fuel_1__c == null && K.Fuel_2__c != null && K.Fuel_3__c != null){
				CO2Combution = (FuelMap.get(K.Fuel_2__c)+FuelMap.get(K.Fuel_3__c))/2;
			}
            if(k.Fuel_1__c == null && K.Fuel_2__c == null && K.Fuel_3__c != null){
				CO2Combution = FuelMap.get(K.Fuel_3__c)/1;
			}
            if(k.Fuel_1__c == null && K.Fuel_2__c != null && K.Fuel_3__c == null){
				CO2Combution = FuelMap.get(K.Fuel_2__c)/1;
			}
			
			Decimal CO2Process = ProdMap.get(K.Lime_Type__c);
			Decimal CO2Total = CO2Combution+CO2Process;
			
			Sum1 = Sum1+ CO2Total*K.Cap_t_y__c;
			Sum2 = Sum2 + K.Cap_t_y__c;
		}
		
		Decimal Efactor = Sum1/Sum2;
		C.Lime_Calculated_by_CO2_Allowance__c = Math.round(C.CO2_Allowances__c/Efactor);
		C.Lime_Estimated_by_CO2_Emission__c = Math.round(C.CO2_Emissions__c/Efactor);
        
        List<Kiln_Report__c> KilnUpdate = getupdatedKilns(C,KL);
        FinalList.addAll(KilnUpdate);
        
	}
           
    }
//}
}
     Else {
                if(KL != null && !KL.isEmpty()){
		Decimal Sum1 = 0;
		Decimal Sum2 = 0;
		
		for(Kiln_Report__c K : KL){
			Decimal CO2Combution;
			if(k.Fuel_1__c != null && K.Fuel_2__c == null && K.Fuel_3__c == null){
				CO2Combution = FuelMap.get(K.Fuel_1__c)/1;
			}
			if(k.Fuel_1__c != null && K.Fuel_2__c != null && K.Fuel_3__c == null){
				CO2Combution = (FuelMap.get(K.Fuel_1__c)+FuelMap.get(K.Fuel_2__c))/2;
			}
			if(k.Fuel_1__c != null && K.Fuel_2__c != null && K.Fuel_3__c != null){
				CO2Combution = (FuelMap.get(K.Fuel_1__c)+FuelMap.get(K.Fuel_2__c)+FuelMap.get(K.Fuel_3__c))/3;
			}
			
			Decimal CO2Process = ProdMap.get(K.Lime_Type__c);
			Decimal CO2Total = CO2Combution+CO2Process;
			
			Sum1 = Sum1+ CO2Total*K.Cap_t_y__c;
			Sum2 = Sum2 + K.Cap_t_y__c;
		}
		
		Decimal Efactor = Sum1/Sum2;
		C.Lime_Calculated_by_CO2_Allowance__c = Math.round(C.CO2_Allowances__c/Efactor);
		C.Lime_Estimated_by_CO2_Emission__c = Math.round(C.CO2_Emissions__c/Efactor);
        
        List<Kiln_Report__c> KilnUpdate = getupdatedKilns(C,KL);
        FinalList.addAll(KilnUpdate);
	}
            }
}
        if(FinalList != null && !FinalList.isEmpty()){
        update FinalList;
        }
    }
    
public static List<Kiln_Report__c> getupdatedKilns(CO2_VS_Lime__c C,List<Kiln_Report__c> KLlist ){
    system.debug('KLlist1 =='+ KLlist);
	List<Kiln_Report__c> KL = new List<Kiln_Report__c>();
    Decimal CO2Diff;// = C.Lime_Estimated_by_CO2_Emission__c - KLlist[0].plant__r.Estimated_Production_t_y__c;
    for(Kiln_Report__c K : KLlist){
        Decimal CapLeft;
        if(CO2Diff == null){
        CO2Diff =  C.Lime_Estimated_by_CO2_Emission__c - K.plant__r.Estimated_Production_t_y__c;
        }
        CapLeft = K.Cap_t_y__c - K.Est_Prod_t_y__c;
        system.debug('CapLeft +1==='+CapLeft);
        if(CapLeft <= CO2Diff && CO2Diff > 0){
            K.Est_Prod_t_y__c = K.Est_Prod_t_y__c+CapLeft;
            CO2Diff = CO2Diff - CapLeft;
            system.debug('CO2Diff +1==='+CO2Diff);
        } else if(CapLeft > CO2Diff && CO2Diff > 0 ){
            system.debug('CO2Diff=== +2'+CO2Diff);
            K.Est_Prod_t_y__c = K.Est_Prod_t_y__c+CO2Diff;
             CO2Diff = 0;
        } else if(CO2Diff < 0){
            system.debug('CO2Diff==='+CO2Diff);
            system.debug('CO2DiffKlist==='+CO2Diff/KLlist.size());
            K.Est_Prod_t_y__c = K.Est_Prod_t_y__c + (CO2Diff/KLlist.size());
             system.debug('K.Est_Prod_t_y__c==='+K.Est_Prod_t_y__c);
        }
        
    }
    system.debug('KLlist2 =='+ KLlist);
    return KLlist;
}    
}