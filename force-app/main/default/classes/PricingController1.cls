public class PricingController1 {
    public static List<SBQQ__QuoteLine__c> lstQuoteLine { get; set; }
    public static List<SBQQ__QuoteLine__C> lstpropose{get;set;}
    public static List<Sales_Competitor__c> lstSales{get;set;}

     
  @InvocableMethod      
 public static list<SBQQ__QuoteLine__c> retrivePreviousQuoteLine(List<Id> Ids)
 {  
     
     
     SBQQ__Quote__c SQ = [select id,SBQQ__Account__c,SBQQ__Status__c from SBQQ__Quote__c where id =:Ids[0]];
      
       lstQuoteLine =   [select SBQQ__ProductName__c,SBQQ__Quantity__c,List_Unit_Price__c,Freight_Price__c,
                                              Commission__c,Misc_Price__c,Surcharge__c,Fees_Price__c,   Total_Price__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =: SQ.Id];
     lstpropose= retrivepropose(Ids);
     lstSales = retriveCompetitor(Ids);
     
     return lstQuoteLine;
     
     
 }
    public static List<Sales_Competitor__c> retriveCompetitor(List<Id> Ids)
    {
        
           List<Id> lstProdName=new List<String>(); 
        SBQQ__Quote__c quoteInfo = [Select id,name,SBQQ__Account__c,SBQQ__Opportunity2__c from SBQQ__Quote__c where id =: Ids[0]];
        List<SBQQ__QuoteLine__c> lstQuoteLine =[select id,name,SBQQ__ProductCode__c,SBQQ__Product__r.id,SBQQ__ProductName__c,SBQQ__Discount__c,SBQQ__Cost__c,SBQQ__CustomerTotal__c,SBQQ__CustomerPrice__c,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteInfo.id];
        for(SBQQ__QuoteLine__c QL : lstQuoteLine)
        {
            lstProdName.add(QL.SBQQ__Product__r.id);
        }
       // List<Sales_Competitor__c> lstSalesCo
          lstSales=   [select Product_Name__c,Tons__c,Freight_Unit_Price__c,OtherCosts__c,FeesUnitPrice__c
,Total_Price__c from  Sales_Competitor__c where Opportunity__c=: quoteInfo.SBQQ__Opportunity2__c and Product__c IN: lstProdName];               
        return lstSales; 
    }
    public static list<SBQQ__QuoteLine__c> retrivepropose(List<Id> Ids)
    {
        SBQQ__Quote__c SQ = [select id,SBQQ__Account__c,SBQQ__Status__c from SBQQ__Quote__c where id =: Ids[0]];
      
       lstpropose =   [select SBQQ__ProductName__c,SBQQ__Quantity__c,List_Unit_Price__c,Freight_Price__c,
                                              Commission__c,Misc_Price__c,Surcharge__c,Fees_Price__c,   Total_Price__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =: Sq.Id]; 
        return lstpropose;
    }
}