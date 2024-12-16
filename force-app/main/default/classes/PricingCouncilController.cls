public with sharing class PricingCouncilController
{
    public List<SBQQ__QuoteLine__c> quotes { get; set; }
    /*
     * To get Sales Competitor records, using Current SBQQ__Quote__c record id.
     * Comparing SBQQ__Quote__c.SBQQ__QuoteLine__c products with SBQQ__Quote__c.Sales_Competitor__c products.
     */
    
    @AuraEnabled(Cacheable = true)
    public static List<Sales_Competitor__c> retriveCompetitorQuoteLine(String recordIdAccount)
    {
        List<Id> lstProdName=new List<String>(); 
        SBQQ__Quote__c quoteInfo = [Select id,name,SBQQ__Account__c,SBQQ__Opportunity2__c from SBQQ__Quote__c where id =:recordIdAccount];
        List<SBQQ__QuoteLine__c> lstQuoteLine =[select id,name,SBQQ__ProductCode__c,SBQQ__Product__r.id,SBQQ__ProductName__c,SBQQ__Discount__c,SBQQ__Cost__c,SBQQ__CustomerTotal__c,SBQQ__CustomerPrice__c,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =: quoteInfo.id];
        for(SBQQ__QuoteLine__c QL : lstQuoteLine)
        {
            lstProdName.add(QL.SBQQ__Product__r.id);
        }
        List<Sales_Competitor__c> lstSalesCom = [Select id,name,Total_Price__c,CommisionUnitPrice__c,FeesUnitPrice__c,Freight_Unit_Price__c,Amount__c,FuelSurcharge__c,OtherCosts__c,Product_Name__c,Tons__c
,Opportunity__c from Sales_Competitor__c where Opportunity__c=: quoteInfo.SBQQ__Opportunity2__c and Product__c IN: lstProdName];               
        return lstSalesCom; 
    }
    
     /** To get SBQQ Quote Line records, using Current SBQQ__Quote__c record id, SBQQ__Quote__c Account record id.
     */ 
    public List<SBQQ__QuoteLine__c> lstQuoteLines { get; set; }

    // Constructor to initialize the properties
    public PricingCouncilController() {
        // Call the method to retrieve previous quote lines
        //lstQuoteLines = retrivePreviousQuoteLine();
    }
    @AuraEnabled(Cacheable = true)
    public static List<SBQQ__QuoteLine__c> retrivePreviousQuoteLine(String recordIdAccount)
    {
        List<Id> lstProdName=new List<String>(); 
        SBQQ__Quote__c SQ = [select id,SBQQ__Account__c,SBQQ__Status__c from SBQQ__Quote__c where id = :recordIdAccount];
        System.debug('@@@@@@@@....29......'+SQ);
        List<SBQQ__QuoteLine__c> lstQuoteLine =[select id,name,SBQQ__Product__r.id,SBQQ__ProductCode__c,SBQQ__Product__c,SBQQ__ProductName__c,SBQQ__Discount__c,SBQQ__Cost__c,SBQQ__CustomerTotal__c,SBQQ__CustomerPrice__c,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =: Sq.Id]; // and SBQQ__Product__r.id IN: lstProdName
        for(SBQQ__QuoteLine__c QL : lstQuoteLine)
        {
            lstProdName.add(QL.SBQQ__Product__r.id);
        } 
        System.debug('@@@@@@@@....35......'+lstProdName);
        SBQQ__Quote__c Sqs = [select id,lastModifiedDate,SBQQ__Account__c,SBQQ__Status__c from SBQQ__Quote__c where SBQQ__Account__c =: SQ.SBQQ__Account__c and SBQQ__Status__c =: 'Approved' ORDER BY lastModifiedDate DESC limit 1];
        System.debug('@@@@@@@@....37......'+Sqs);
        List<SBQQ__QuoteLine__c> lstQuoteLines =[select id,name, List_Unit_Price__c,SBQQ__ProductCode__c,SBQQ__ProductName__c,SBQQ__Quantity__c,SBQQ__ListPrice__c,Freight_Price__c,Commission__c,Misc_Price__c,Surcharge__c,Fees_Price__c,Estimated_Qty_Delivery__c,Total_Price__c,SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =: Sqs.Id and SBQQ__Product__r.id IN: lstProdName];
        System.debug('@@@@@@@@....39......'+lstQuoteLines);
        return lstQuoteLines;
    }
}