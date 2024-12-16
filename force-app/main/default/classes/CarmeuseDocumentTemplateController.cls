/**
* Class Name         : CarmeuseDocumentTemplateController
* Developer          : D Sridhar           
* Created Date       :
* @description       : Controller class for CarmeuseDocumentTemplate VisualForce page.
* Last Modified Date : 
*/
public class CarmeuseDocumentTemplateController 
{
    public String quoteLanguage { get; set; }
    public string quoteId { get; set; }
    public string templateId { get; set; }
    public List<Column> columns { get; set; }
    public SBQQ__Quote__c quote { get; set; }
    public List<SBQQ__QuoteLine__c> lines { get; set; }
    public SBQQ__QuoteTemplate__c template { get; set; }
    //public Double totalFees { get; set; }
    
    //public Boolean showEnergySurcharge { get; set; }
    //public Boolean hideCurrency { get; set; }
    
    public Map<String, List<String>> flatFieldsMap { get; set; }
    public Map<String, String> languageKeyMap { get; set; }
    public Map<String, Map<String, String>> fieldRenderMap { get; set; }
    public Map<String, String> categPriceFieldsMap = new Map<String, String>{ 'Surcharges' => 'Surcharge__c', 'Freight' => 'Freight_Price__c', 'Fees' => 'Fees_Price__c' };
        public Map<String, Map<String, Category>> lineCategPricesMap { get; set; }
    public Map<String, Decimal> lineTotalPricesMap { get; set; }
    
    public Boolean getShowLines() 
    { 
        return (lines != null && lines.size() > 0);
    }
    
    public Boolean testCoverLines() 
    { 
       quoteId = ApexPages.CurrentPage().getparameters().get('qid');
        templateId = ApexPages.currentPage().getParameters().get('tid');
        
        this.prepareLanguageKeyMap();
        this.fieldRenderMap();
        this.fetchQuote();
        this.fetchTemplate();
        this.fetchPCAs();
        this.fetchLines();
        this.prepareColumns();
         return null;
    }
    
    public CarmeuseDocumentTemplateController()
    {
        quoteId = ApexPages.CurrentPage().getparameters().get('qid');
        templateId = ApexPages.currentPage().getParameters().get('tid');
        
        this.prepareLanguageKeyMap();
        this.fieldRenderMap();
        this.fetchQuote();
        this.fetchTemplate();
        this.fetchPCAs();
        this.fetchLines();
        this.prepareColumns();
    }
    
    public void prepareLanguageKeyMap() {
        languageKeyMap = new Map<String,String>{ 
            'Default' => UserInfo.getLanguage(), 
                'English'=> 'en_US', 
                'French' => 'fr', 
                'Czech' => 'cs', 
                'Dutch' => 'nl_NL', 
                'Hungarian' => 'hu', 
                'Romanian' => 'ro' 
                };
                    for(Schema.PicklistEntry entry: User.LanguageLocaleKey.getDescribe().getPicklistValues()) {
                        languageKeyMap.put(entry.getLabel(), entry.getValue());
                    }
    }
    
    public void fieldRenderMap() {
        /* Key - Field which has some value, Value - Quote Field which decides whether to show the value of the Field which is in Key or not */
        fieldRenderMap = new Map<String, Map<String, String>>{ 
            'line' => new Map<String, String>{ 'SBQQ__ProductCode__c' => 'Show_product_code__c', 'Net_Quantity__c' => 'Show_Quantity__c', 'Plant__c' => 'Show_Plant_Name__c', 'Quote_Document_Total_Price__c' => 'Show_Total_Price__c' },
                'quote' => new Map<String, String>{ 'Net_Total__c' => 'Show_Final_Price__c' } 
        };
            }
    
    public void fetchQuote() {
        quote = [SELECT Id, Net_Total__c, Energy_Surcharg__c, CurrencyIsoCode, SBQQ__QuoteLanguage__c, Show_product_code__c, Show_Quantity__c,
                 Show_Final_Price__c, Show_Plant_Name__c, Show_VAT_Excl__c, Show_Total_Price__c, Document_Destination__c, Show_Commission_Price__c, 
                 Show_Discount_Price__c, Show_Fees_Price__c, Show_Freight_Price__c, Show_Misc_Price__c, Show_Product_Price__c, Show_Surcharges_Price__c,
                 Incoterms1__c, Customer_Region__c,Show_Minimum_Tons_Load__c,IncotermsFormula__c,Show_Ship_To__c,ShowSurchargeVariable__c
                 FROM SBQQ__Quote__c 
                 WHERE Id = :quoteId];
        
        quoteLanguage = getQuoteLanguage(quote);
        
    }
    
    public String getQuoteLanguage(SBQQ__Quote__c quote) {
        String quoteLanguage;
        if(quote != null && String.isNotBlank(quote.SBQQ__QuoteLanguage__c) && languageKeyMap.get(quote.SBQQ__QuoteLanguage__c) != null) {
            quoteLanguage = languageKeyMap.get(quote.SBQQ__QuoteLanguage__c);
        } else {
            quoteLanguage = languageKeyMap.get('Default');
        }
        return quoteLanguage;
    }
    
    public void fetchTemplate() {
        template = [SELECT Id, Name, SBQQ__FontFamily__c, SBQQ__FontSize__c, SBQQ__ShadingColor__c 
                    FROM SBQQ__QuoteTemplate__c 
                    WHERE Id = :templateId];
        
        //List<String> showEnergySurchargeTemplates = new List<String>{ 'Carmeuse Document - English', 'Carmeuse Document - French' };
        //List<String> hideCurrencyTemplates = new List<String>{ 'Carmeuse Document - French' };
        //showEnergySurcharge = showEnergySurchargeTemplates.contains(template.Name);
        //hideCurrency = hideCurrencyTemplates.contains(template.Name);
    }
    
    public void fetchPCAs() {
        flatFieldsMap = new Map<String, List<String>>();
        for(AggregateResult ar : [SELECT Price_Category__c, Category_Type__c 
                                  FROM Pricing_Category__c 
                                  WHERE Category_Type__c != null AND Description__c LIKE '%flat%' AND Price_Category__c IN :categPriceFieldsMap.keySet()
                                  GROUP BY Price_Category__c, Category_Type__c]) {
                                      String priceCategory = (String)ar.get('Price_Category__c');
                                      List<String> flatFields = flatFieldsMap.get(priceCategory) ?? new List<String>();
                                      flatFields.add(ar.get('Category_Type__c') + '__c');
                                      flatFieldsMap.put(priceCategory, flatFields);
                                  }
    }
    
    public void fetchLines() {
        /* Getting all the Fields in QLI object */
        String qliFields = '';
        String shipToAccountFields = '';
        Map<String,Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap();
        for(String fieldName : fieldsMap.keySet()) {
            if(fieldsMap.get(fieldName).getDescribe().isAccessible()) {
                if(fieldName == 'Plant__c' || fieldName == 'SE_Shipping_Type__c') {
                    qliFields += 'toLabel(' + fieldName + '), ';
                } else {
                    qliFields += fieldName + ', ';
                }
            }
        }
        
        /* Querying QLIs */
        qliFields += ' SBQQ__Quote__r.Incoterms1__c,SBQQ__Quote__r.IncotermsFormula__c, SBQQ__Quote__r.Document_Destination__c,Ship_To__r.Name ';
        
        lines = Database.query('SELECT ' + qliFields +
                               + ' FROM SBQQ__QuoteLine__c WHERE Primary__c = true AND SBQQ__Quote__c = \'' + quoteId + '\'');
        
        reCalculateLines();
    }
    
    public void reCalculateLines() {
        lineCategPricesMap = new Map<String, Map<String, Category>>();
        for(SBQQ__QuoteLine__c line : lines) {
            /* Excluding Alabama SeverenceTax Price from Fees Price as it will be shown seperately. */
            if(line.ZAST__c != null) {
                line.Fees_Price__c -= line.ZAST__c;
            }
            
            /* Calculating Total Price of only Flat values for each category. */
            Map<String, Category> categPricesMap = getFlatCategsDetails(line);
            lineCategPricesMap.put(line.Id, categPricesMap);   //Checking for Flat values
        }
    }
    
    public Map<String, Category> getFlatCategsDetails(SBQQ__QuoteLine__c line) {
        Map<String, Category> categPricesMap = new Map<String, Category>();
        Decimal totalNonFlatPrice = line.Quote_Document_Total_Price__c;
        
        for(String priceCategory : flatFieldsMap.keySet()) {
            if(priceCategory != null) {
                Category categPriceMap = categPricesMap.get(priceCategory) 
                    ?? new Category(line.Default_UOM__c, 0, (Decimal)line.get(categPriceFieldsMap.get(priceCategory)));
                List<String> flatFields = flatFieldsMap.get(priceCategory);
                for(Integer i = 0; i < flatFields.size(); i++) {
                    System.debug(flatFields[i] + ', ' + line.get(flatFields[i]));
                    if(line.get(flatFields[i]) != null) {
                        Decimal flatPrice = categPriceMap.flatPrice + (Decimal)line.get(flatFields[i]);
                        system.debug('categPriceMap.nonFlatPrice==='+categPriceMap.nonFlatPrice);
                        Decimal nonFlatPrice;
                        if(categPriceMap.nonFlatPrice != null){
                        nonFlatPrice = categPriceMap.nonFlatPrice - (Decimal)line.get(flatFields[i]);
                        }
                        totalNonFlatPrice -= (Decimal)line.get(flatFields[i]);
                        categPriceMap = new Category('Delivery', flatPrice, nonFlatPrice);
                    }
                }
                System.debug(priceCategory + ', ' + categPriceMap);
                categPricesMap.put(priceCategory, categPriceMap);
            }
        }
        categPricesMap.put('totalPrice', new Category('Delivery', 0, totalNonFlatPrice));
        return categPricesMap;
    }
    
    public void prepareColumns() {
        List<String> hideCurrencyTemplates = new List<String>{ 'Carmeuse Document - French' };
            columns = new List<Column>();
        
        /* Columns for North America Customer Region. */
        if(quote.Customer_Region__c == 'North America') {
            columns.add(new Column(System.Label.get('', 'Product', quoteLanguage), 'SBQQ__ProductCode__c', (Boolean)quote.get(fieldRenderMap.get('line').get('SBQQ__ProductCode__c')), '10%'));
            columns.add(new Column(System.Label.get('', 'Plant', quoteLanguage), 'Plant__c', (Boolean)quote.get(fieldRenderMap.get('line').get('Plant__c')), '12%'));
            columns.add(new Column(System.Label.get('', 'Product_Description', quoteLanguage),'ProductDescription', true, '36%'));
            columns.add(new Column(System.Label.get('', 'Currency', quoteLanguage),'CurrencyIsoCode', !hideCurrencyTemplates.contains(template.Name), '10%'));
            columns.add(new Column(System.Label.get('', 'Quantity', quoteLanguage),'Net_Quantity__c', (Boolean)quote.get(fieldRenderMap.get('line').get('Net_Quantity__c')), '10%'));
            columns.add(new Column(System.Label.get('', 'Incoterms', quoteLanguage),'Incoterms', true, '10%'));
            columns.add(new Column(System.Label.get('', 'Destination', quoteLanguage),'Destination', String.isNotBlank(quote.Document_Destination__c), '12%'));
        }
        /* Columns for Other Customer Regions like Europe, Turkey, etc. */
        else {
            Boolean isFRorDutch = (quoteLanguage =='fr' || quoteLanguage =='nl_NL');
            columns.add(new Column(System.Label.get('', 'Product_Description', quoteLanguage), 'ProductDescription', (Boolean)quote.get(fieldRenderMap.get('line').get('SBQQ__ProductCode__c')), '15%'));
            columns.add(new Column(System.Label.get('', 'Plant', quoteLanguage), 'Plant__c', (Boolean)quote.get(fieldRenderMap.get('line').get('Plant__c')), '10%'));
            columns.add(new Column(System.Label.get('', 'Price_EUR', quoteLanguage),'Price', true, '41%'));
            //columns.add(new Column(System.Label.get('', 'Currency', quoteLanguage),'CurrencyIsoCode', !hideCurrencyTemplates.contains(template.Name), '10%'));
            columns.add(new Column(System.Label.get('', 'Quantity_tons', quoteLanguage),'Net_Quantity__c', (Boolean)quote.get(fieldRenderMap.get('line').get('Net_Quantity__c')), '10%'));
            columns.add(new Column(System.Label.get('', 'Incoterms', quoteLanguage),'Incoterms', true, '12%'));
            columns.add(new Column(System.Label.get('', 'Shipping_Type', quoteLanguage), isFRorDutch?'CWE_Translated_ShippingType__c':'SE_Shipping_Type__c', true, '12%'));
        }
    }
    
    public class Column {
        public String label { get; set; }
        public String name { get; set; }
        public Boolean show { get; set; }
        public String columnWidth { get; set; }
        public Column(String label, String name, Boolean show, String columnWidth) {
            this.label = label;
            this.name = name;
            this.show = show;
            this.columnWidth = columnWidth;
        }
    }
    
    public class Category {
        public String defaultUOM { get; set; }
        public Decimal flatPrice { get; set; }
        public Decimal nonFlatPrice { get; set; }
        public Category(String defaultUOM, Decimal flatPrice, Decimal nonFlatPrice) {
            this.defaultUOM = defaultUOM;
            this.flatPrice = flatPrice;
            this.nonFlatPrice = nonFlatPrice;
        }
    }
}