public class EV_updating_PAT_based_on_Volumes
{  
    public static void shareRecordID(List<SBQQ__Quote__c> newList, Map<Id,SBQQ__Quote__c> oldMap, boolean keyAccount)
    {  
        SYstem.debug(keyAccount);
        SYstem.debug(newList);
        for(SBQQ__Quote__c sQuote: newList)
        {  
            if(sQuote.Volume_Brunt__c != oldMap.get(sQuote.Id).Volume_Brunt__c)
            {  
                System.debug('@@@@....10....'+sQuote.Volume_Brunt__c);
                if(sQuote.Volume_Brunt__c < 500)
                {
                    sQuote.Pricing_Approval_Type__c = 'Pre-Approved';
                }
                else If(sQuote.Volume_Brunt__c > 1000) // || keyAccount == true
                {
                    sQuote.Pricing_Approval_Type__c = 'Pricing Council';
                }
                else If(sQuote.Volume_Brunt__c > 500 || sQuote.Volume_Crude__c < 1000)
                {
                    sQuote.Pricing_Approval_Type__c = 'Area Pricing Council';
                }
                
            } 
            else if(sQuote.Volume_Crude__c!= oldMap.get(sQuote.Id).Volume_Crude__c)
            {  
                if(sQuote.Volume_Crude__c < 5000)
                {
                    sQuote.Pricing_Approval_Type__c = 'Pre-Approved';
                }
                else If(sQuote.Volume_Crude__c > 10000) //  || keyAccount == true
                {
                    sQuote.Pricing_Approval_Type__c = 'Pricing Council';
                }
                else If((sQuote.Volume_Crude__c > 5000 || sQuote.Volume_Crude__c < 10000))
                {
                    sQuote.Pricing_Approval_Type__c = 'Area Pricing Council';
                }
          }
          else if(sQuote.Volume_Brunt__c < 500)
                {
                    sQuote.Pricing_Approval_Type__c = 'Pre-Approved';
                }
                else If(sQuote.Volume_Brunt__c > 1000) // || keyAccount == true
                {
                    sQuote.Pricing_Approval_Type__c = 'Pricing Council';
                }
                else If(sQuote.Volume_Brunt__c > 500 || sQuote.Volume_Crude__c < 1000)
                {
                    sQuote.Pricing_Approval_Type__c = 'Area Pricing Council';
                }
                else if(sQuote.Volume_Crude__c < 5000)
                {
                    sQuote.Pricing_Approval_Type__c = 'Pre-Approved';
                }
                else If(sQuote.Volume_Crude__c > 10000) //  || keyAccount == true
                {
                    sQuote.Pricing_Approval_Type__c = 'Pricing Council';
                }
                else If((sQuote.Volume_Crude__c > 5000 || sQuote.Volume_Crude__c < 10000))
                {
                    sQuote.Pricing_Approval_Type__c = 'Area Pricing Council';
                }
        }  
    }  
}