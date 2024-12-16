public class Ev_PricingCouncilAttachmentController {
    public String quoteId {get; set;}
    public List<Column> proposedLinesColumns {get; set;}
    public List<Column> competitorLinesColumns {get; set;}
    public String existingLinesCurrency {get; set;}
    public String proposedLinesCurrency {get; set;}
    public String competitorLinesCurrency {get; set;}
    public List<SBQQ__QuoteLine__c> existingLines {get; set;}
    public List<SBQQ__QuoteLine__c> proposedLines {get; set;}
    public List<Sales_Competitor__c> competitorLines {get; set;}
    
    public Ev_PricingCouncilAttachmentController() {
        quoteId = ApexPages.CurrentPage().getparameters().get('qid');
        System.debug('quoteId==>'+quoteId);
       // if(quoteId == null){
        	//quoteId = 'a17QJ00000qJA6QYAW';
        //}
        this.preparePropLinesCols();
        this.prepareCompLinesCols();
        this.getExistingLineItems();
        this.getProposedLineItems();
        this.getCompetitorLineItems();
    }
    
    public void preparePropLinesCols() {
        proposedLinesColumns = new List<Column>();
        proposedLinesColumns.add(new Column('Product Name', 'SBQQ__ProductName__c'));
        proposedLinesColumns.add(new Column('Quantity', 'SBQQ__Quantity__c'));
        proposedLinesColumns.add(new Column('List Unit Price', 'List_Unit_Price__c'));
        proposedLinesColumns.add(new Column('Freight Price', 'Freight_Price__c'));
        proposedLinesColumns.add(new Column('Commission', 'Commission__c'));
        proposedLinesColumns.add(new Column('Misc Price', 'Misc_Price__c'));
        proposedLinesColumns.add(new Column('Surcharge', 'Surcharge__c'));
        proposedLinesColumns.add(new Column('Fees Price', 'Fees_Price__c'));
        proposedLinesColumns.add(new Column('Total Price', 'Total_Price__c'));
    }
    
    public void prepareCompLinesCols() {
        competitorLinesColumns = new List<Column>();
        competitorLinesColumns.add(new Column('Product Name', 'Product_Name__c'));
        competitorLinesColumns.add(new Column('Quantity', 'Tons__c'));
        competitorLinesColumns.add(new Column('List Unit Price', 'Amount__c'));
        competitorLinesColumns.add(new Column('Freight Price', 'Freight_Unit_Price__c'));
        competitorLinesColumns.add(new Column('Commission', 'CommisionUnitPrice__c'));
        competitorLinesColumns.add(new Column('Misc Price', 'OtherCosts__c'));
        competitorLinesColumns.add(new Column('Surcharge', 'FuelSurcharge__c'));
        competitorLinesColumns.add(new Column('Fees Price', 'FeesUnitPrice__c'));
        competitorLinesColumns.add(new Column('Total Price', 'Total_Price__c'));
    }
    
    public void getExistingLineItems() {
        existingLines = ev_QuoteInfo.retrivePreviousQuoteLine(quoteId);
        System.debug('existingLines==> '+existingLines);
        if(existingLines != null && !existingLines.isEmpty()) {
            existingLinesCurrency = existingLines[0]?.SBQQ__Quote__r?.CurrencyIsoCode;
        }
    }
    
    public void getProposedLineItems() {
        proposedLines = [SELECT Id, SBQQ__ProductName__c, SBQQ__Quantity__c, List_Unit_Price__c, Freight_Price__c,
                         Commission__c, Misc_Price__c, Surcharge__c, Fees_Price__c, Total_Price__c,
                         SBQQ__Quote__r.CurrencyIsoCode
                         FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId WITH SECURITY_ENFORCED];
        if(proposedLines != null && !proposedLines.isEmpty()) {
            proposedLinesCurrency = proposedLines[0]?.SBQQ__Quote__r?.CurrencyIsoCode;
        }
    }
    
    public void getCompetitorLineItems() {
        competitorLines = ev_QuoteInfo.retriveCompetitorQuoteLine(quoteId);
        if(competitorLines != null && !competitorLines.isEmpty()) {
        	competitorLinesCurrency = competitorLines[0]?.CurrencyIsoCode;
        }
    }
    
    
    
    public class Column {
        public String label {get; set;}
        public String name {get; set;}
        public Column(String label, String name) {
            this.label = label;
            this.name = name;
        }
    }
}