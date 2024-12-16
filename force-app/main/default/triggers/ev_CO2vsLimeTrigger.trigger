trigger ev_CO2vsLimeTrigger on CO2_VS_Lime__c (before insert, before update) {
    
        if (Trigger.isBefore) {

        if (Trigger.isInsert || Trigger.isUpdate) {

              ev_CO2vsLimeClass.CO2Calcutations( Trigger.new);

        }

}

}