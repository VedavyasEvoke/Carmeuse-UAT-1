public with sharing class ev_QuoteInfo
{
    /*
* To get Sales Competitor records, using Current SBQQ__Quote__c record id.
* Comparing SBQQ__Quote__c.SBQQ__QuoteLine__c products with SBQQ__Quote__c.Sales_Competitor__c products.
*/
    @AuraEnabled(Cacheable = true)
    public static Map<String, Object> retriveCompetitorQuoteLine(String recordIdAccount)
    {
        List<Id> lstProdName=new List<String>();
         Map<String, Object> responseMap = new Map<String, Object>();
        
        SBQQ__Quote__c quoteInfo =  [Select id,name,SBQQ__Account__c,CurrencyIsoCode,SBQQ__Opportunity2__c,
             Variable_Fuel_Surcharge__c,Customer_Region__c from SBQQ__Quote__c 
               where id =:recordIdAccount];
           responseMap.put('CustomerRegion', quoteInfo.Customer_Region__c);
        
        List<SBQQ__QuoteLine__c> lstQuoteLine =[select id,name,SBQQ__ProductCode__c,SBQQ__Product__r.id,SBQQ__ProductName__c,SBQQ__Discount__c,
                                                SBQQ__Cost__c,SBQQ__CustomerTotal__c,Total_Price_per_Ton__c,UOM_Distance__c,SBQQ__CustomerPrice__c,SBQQ__Quote__c from SBQQ__QuoteLine__c 
                                                where SBQQ__Quote__c =: quoteInfo.id];
        for(SBQQ__QuoteLine__c QL : lstQuoteLine) 
        {
            lstProdName.add(QL.SBQQ__Product__r.id);
        }
        List<Sales_Competitor__c> lstSalesCom = [select id,Legacy_Competitor_Name__c,Legacy_Plant_Name__c,Legacy_Product_Name__c,Legacy_Product_Code__c,Competitor__r.Name,Plant__r.Name,Product__r.Name,Tons__c,FOB__c,Freight_Unit_Price__c,
                                                 FuelSurcharge__c,OtherCosts__c,CommisionUnitPrice__c,FeesUnitPrice__c,DiscountUnitPrice__c,CurrencyIsoCode,Distance__c,Product_2__c,
                                                 UOM__c,CO2Cost__c,Total_Price__c,Opportunity__c, Currency_Format__c,UOM_Distance__c,Total_Price_per_Ton__c,Qty_UOM__c, Dist_UOM__c
                                                 from Sales_Competitor__c where 
                                                 Opportunity__c=: quoteInfo.SBQQ__Opportunity2__c ];//and Product__c IN: lstProdName AND Plant__c !=''    
        System.debug('listCompiter'+lstSalesCom); 
         responseMap.put('QuoteLines', lstSalesCom);
        return responseMap; 
    }
    
    /*
* To get SBQQ Quote Line records, using Current SBQQ__Quote__c record id, SBQQ__Quote__c Account record id.
*/ 
    @AuraEnabled(Cacheable = true)
    public static Map<String, Object> retrivePreviousQuoteLine(String recordIdAccount)
    {
        Set<Id> lstProdName = new Set<Id>(); 
        List<Id> lstQuoteID = new List<Id>();
         Map<String, Object> responseMap = new Map<String, Object>();
        
        
        SBQQ__Quote__c SQ = [select id,SBQQ__Account__c,SBQQ__Status__c,Customer_Region__c,Valid_from__c ,CreatedDate,Variable_Fuel_Surcharge__c  from SBQQ__Quote__c where id =:recordIdAccount];
        String quoteCustomerregion =SQ.Customer_Region__c;
          responseMap.put('CustomerRegion', SQ.Customer_Region__c);
        
        List<SBQQ__QuoteLine__c> lstQuoteLine = [select id,name,SBQQ__Product__r.name,SBQQ__ProductCode__c,SBQQ__Product__c,SBQQ__ProductName__c,
                                                 SBQQ__Discount__c,SBQQ__Cost__c,Total_Price_per_Ton__c,SBQQ__CustomerTotal__c,UOM_Distance__c,SBQQ__CustomerPrice__c,SBQQ__Quote__c from SBQQ__QuoteLine__c 
                                                 where SBQQ__Quote__c =: SQ.Id];
        for(SBQQ__QuoteLine__c QL : lstQuoteLine)
        {
            lstProdName.add(QL.SBQQ__Product__r.id);
            system.debug('lstProdName=='+lstProdName);
        }
        
        List<SBQQ__Quote__c> Sqs = [select id,lastModifiedDate,SBQQ__Account__c,SBQQ__Status__c from SBQQ__Quote__c 
                                    where SBQQ__Account__c =: SQ.SBQQ__Account__c and id !=:SQ.Id and Valid_From__c < :SQ.Valid_from__c AND CreatedDate <= :SQ.CreatedDate ORDER BY lastModifiedDate DESC];
        for(SBQQ__Quote__c quote : Sqs)
        {
            lstQuoteID.add(quote.ID);
            system.debug('lstQuoteID===='+lstQuoteID);
        } 
        /* Date today = Date.today();
Date oneyearago = today.addYears(-1);*/
        
        //prevent potential duplicates using set instead of list for future
        Set<String> seenQuoteLineIds = new Set<String>();
        Set<string> DraftQuoteLineIds =new Set<string>();
        
        List<SBQQ__QuoteLine__c> uniqueQuoteLines = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> lstQuoteLines = new  List<SBQQ__QuoteLine__c>();
        if (quoteCustomerregion == 'North America'){
            System.debug('In NA Query');
            lstQuoteLines = [SELECT Id, Name, Plant__c, SBQQ__Product__r.Id, SBQQ__ProductCode__c, 
                             SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Quantity__c, List_Unit_Price__c,
                             Freight_Price__c, Misc_Price__c, Total_Price_per_Ton__c, Commission__c,
                             Fees_Price__c, PC_Discount__c, CurrencyIsoCode, Distance__c, Default_UOM__c, 
                             SBQQ__Quote__r.Customer_Region__c, ZCO2__c, Total_Price__c, Currency_Format__c, 
                             UOM_Distance__c, Surcharge__c, SBQQ__Quote__r.Valid_From__c, Qty_UOM__c,Payment_Terms__c, 
                             Dist_UOM__c, SBQQ__Quote__r.SBQQ__Status__c, Surcharge_variable__c,SBQQ__Quote__r.Variable_Fuel_Surcharge__c  ,ZSFT__c,ZCO3__c
                             FROM SBQQ__QuoteLine__c 
                             WHERE SBQQ__Product__r.Id IN :lstProdName 
                             AND SBQQ__Quote__c IN :lstQuoteID   
                             ORDER BY SBQQ__ProductCode__c DESC, SBQQ__Quote__r.Valid_From__c DESC];
            System.debug('In NA Query LST'+lstQuoteLines);
            
        }
        
        //  'AND SBQQ__Quote__r.Valid_From__c >= :oneYearAgo ' +
        if (quoteCustomerregion == 'Western Europe' || quoteCustomerregion == 'Central Europe' || quoteCustomerregion == 'Eastern Europe' || quoteCustomerregion == 'Turkey') {
            System.debug('In EU Query');
            lstQuoteLines = [SELECT Id, Name, Plant__c, SBQQ__Product__r.Id, SBQQ__ProductCode__c, 
                             SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Quantity__c, List_Unit_Price__c,
                             Freight_Price__c, Misc_Price__c, Total_Price_per_Ton__c, Commission__c,
                             Fees_Price__c, PC_Discount__c, CurrencyIsoCode, Distance__c, Default_UOM__c, 
                             SBQQ__Quote__r.Customer_Region__c, ZCO2__c, Total_Price__c, Currency_Format__c, 
                             UOM_Distance__c, Surcharge__c, SBQQ__Quote__r.Valid_From__c, Qty_UOM__c, Payment_Terms__c,
                             Dist_UOM__c, SBQQ__Quote__r.SBQQ__Status__c, Surcharge_variable__c ,SBQQ__Quote__r.Variable_Fuel_Surcharge__c,ZSFT__c,ZCO3__c
                             FROM SBQQ__QuoteLine__c 
                             WHERE SBQQ__Product__r.Id IN :lstProdName 
                             AND SBQQ__Quote__c IN :lstQuoteID 
                             ORDER BY SBQQ__ProductCode__c DESC, SBQQ__Quote__r.Valid_From__c DESC];
            
            System.debug('In EU Query'+lstQuoteLines);
        }
        
        
        
        
        
        
        for (SBQQ__QuoteLine__c ql : lstQuoteLines) {
            String uniqueKey = ql.SBQQ__ProductCode__c + '-' + ql.Plant__c;
            
            if (!seenQuoteLineIds.contains(uniqueKey) && ql.SBQQ__Quote__r.Sbqq__Status__c == 'Accepted' && !DraftQuoteLineIds.contains(uniqueKey)) {
                seenQuoteLineIds.add(uniqueKey);
                uniqueQuoteLines.add(ql);
                System.debug('Added in Won'+uniqueQuoteLines);
            }
            if(!DraftQuoteLineIds.contains(uniqueKey) && ql.SBQQ__Quote__r.Sbqq__Status__c != 'Accepted'){
                DraftQuoteLineIds.add(uniqueKey);
                System.debug('Added in Draft'+DraftQuoteLineIds);
                
            }
        }
        System.debug('uniqueQuoteLines'+uniqueQuoteLines.size());
        
        responseMap.put('QuoteLines', uniqueQuoteLines);
        System.debug('uniqueQuoteLines'+responseMap);
        
        
        return responseMap;
    }
    
    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> getproposeddata(String quoteId) {
        
            Map<String, Object> responseMap = new Map<String, Object>();

         
            // Query the quote record
            SBQQ__Quote__c quote = [SELECT Id, 
                                    Variable_Fuel_Surcharge__c, 
                                    Customer_Region__c 
                                    FROM SBQQ__Quote__c 
                                    WHERE Id = :quoteId LIMIT 1];
                responseMap.put('CustomerRegion', quote.Customer_Region__c);

            
            // Query related quote lines
           List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, Plant__c, SBQQ__ProductName__c, 
                                                   SBQQ__Quantity__c, List_Unit_Price__c, Freight_Price__c, 
                                                   Surcharge__c, Misc_Price__c, Fees_Price__c, CurrencyIsoCode,Commission__c, 
                                                   Distance__c, Default_UOM__c, ZCO2__c, Total_Price__c ,PC_Discount__c,
                                                   Currency_Format__c, UOM_Distance__c, Qty_UOM__c, 
                                                   Dist_UOM__c, Total_Price_per_Ton__c, Surcharge_variable__c ,
                                                   SBQQ__Quote__r.Variable_Fuel_Surcharge__c,Payment_Terms__c,ZSFT__c,ZCO3__c
                                                   FROM SBQQ__QuoteLine__c 
                                                   WHERE SBQQ__Quote__c = :quoteId];
          responseMap.put('QuoteLines', quoteLines);
            System.debug('QLI lines'+responseMap);
            
            
          
        return responseMap;
    }
    
    
}