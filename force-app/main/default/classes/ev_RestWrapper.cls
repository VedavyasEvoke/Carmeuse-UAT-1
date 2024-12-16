/***************************************************************************************************************************************************
# Class Name  = ev_RestWrapper
# Author      = Sridhar Dumpala
# Description = This class is to integrate between Salesforce and Bhoomi for SAP Integration.

# Change Log :
============================================================================================================
Date                Changed By               Change                    Description
============================================================================================================
04/01/2024          Sridhar Dumpala          Original Version          
***************************************************************************************************************************************************/

public class ev_RestWrapper {
    /*
* @description Constructs the wrapper
*/
    public static Map<String, Object> constructWrapper(Id quoteId) {
        Map<String, String> categoryFlatMap = new Map<String, String>{'ZF1' => 'ZF7', 'ZSTT' => 'ZSTF', 'ZADN' => 'ZAD'};   //This variable is related to North America Region only.
            Map<String, String> pcaQliFieldsMap = new Map<String, String>{'Sales.Org'=>'Sales_Organization__c', 'Plant'=>'Plant__c', 'Material'=>'SBQQ__ProductCode__c',
                'Inco.Terms'=>'Incoterms__c', 'Ship.Type'=>'SE_Shipping_Type__c', 'Ord.Reason'=>'001', 'Price list' => 'AS',
                'Cust.grp1' => 'SBQQ__Quote__r.Customer_Group__c'};
                    
                    String quoteFields = '';
        Map<String,Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('SBQQ__Quote__c').getDescribe().fields.getMap();
        List<String> NA_ShipType_Vals = new List<String> {'95','96','97','98','99'};
        for(String fieldName : fieldsMap.keySet()) {
            if(fieldsMap.get(fieldName).getDescribe().isAccessible()) {
                quoteFields += fieldName + ', ';
            }
        }
        quoteFields += ' Sold_to__r.SAP_ID__c,Sold_to__r.Price_List__c, Ship_to__r.SAP_ID__c, Ship_to__r.AccountNumber,Ship_to__r.ShippingCountry, Sold_to__r.AccountNumber, SBQQ__Account__r.Account_Group__c, '
            + 'SBQQ__Account__r.Name, SBQQ__Account__r.AccountNumber, SBQQ__Account__r.Legal_Name__c, SBQQ__Account__r.ParentId, SBQQ__Account__r.Price_List__c, '
            + 'SBQQ__Account__r.Customer_Group_Code__c, SBQQ__Account__r.SAP_ID__c, SBQQ__Account__r.MSD_ID__c, SBQQ__Account__r.Id, '
            + 'SBQQ__Account__r.BillingPostalCode, SBQQ__Account__r.BillingState, SBQQ__Account__r.BillingCountry, SBQQ__Account__r.BillingCity,SBQQ__Account__r.BillingStreet,SBQQ__Account__r.MSD_Customer_Number__c ';
        
        String qliFields = '';
        fieldsMap = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap();
        for(String fieldName : fieldsMap.keySet()) {
            if(fieldsMap.get(fieldName).getDescribe().isAccessible()) {
                qliFields += fieldName + ', ';
            }
        }
        qliFields += ' SBQQ__Quote__r.Incoterms1__c, SBQQ__Quote__r.SE_Shipping_Type__c, SBQQ__Quote__r.Customer_Group__c, Ship_To__r.Name ,Ship_To__r.SAP_ID__c';
        SBQQ__Quote__c quote = Database.query('SELECT ' + quoteFields 
                                              + ', (SELECT ' + qliFields + ' FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c WHERE Id = \''
                                              + quoteId + '\'');
        
        /* Constructing a Map for Pricing_Condition_Access__c */
        Map<String, Map<String, Pricing_Condition_Access__c>> pcaMap = new Map<String, Map<String, Pricing_Condition_Access__c>>();
        for(Pricing_Condition_Access__c pac : [SELECT Princing_Condition__c, Access_seq__c, Option__c, Option_Name__c, Option_Tech_no__c, Table__c, Fields__c,
                                               Is_Flat_Fee__c FROM Pricing_Condition_Access__c 
                                               WHERE Princing_Condition__c != null AND Option__c != null AND Princing_Condition__c NOT IN ('ZF01')]) {
                                                   Map<String, Pricing_Condition_Access__c> pcPcaMap = (pcaMap.containsKey(pac.Princing_Condition__c))
                                                       ? pcaMap.get(pac.Princing_Condition__c)
                                                       : new Map<String, Pricing_Condition_Access__c>();
                                                   pcPcaMap.put(pac.Option__c, pac);
                                                   pcaMap.put(pac.Princing_Condition__c, pcPcaMap);
                                               }
        
        /* Constructing a Map for Pricing_Category__c */
        Map<String, Pricing_Category__c> pcMap = new Map<String, Pricing_Category__c>();
        for(Pricing_Category__c pc : [SELECT Category_Type__c, Description__c, Price_Category__c FROM Pricing_Category__c WHERE Category_Type__c != null]){
            //pcMap.put(pc.Description__c, pc);
            pcMap.put(pc.Category_Type__c, pc);   
        }
        
        /* Fetching Price Lists */
        List<Price_List__c> priceLists = [SELECT Id, CnTy__c, PL__c, Plnt__c, Material__c, UoM__c, Valid_To__c 
                                          FROM Price_List__c WHERE CnTy__c IN ('ZCO2', 'ZSFT','ZCPR') 
                                          WITH SECURITY_ENFORCED];
        
        /* Populate the Customer object */
        Map<String, Object> customerMap = new Map<String, Object>();
        customerMap.put('Address line1', quote.SBQQ__Account__r.BillingStreet);
        customerMap.put('city', quote.SBQQ__Account__r.BillingCity);
        customerMap.put('country', quote.SBQQ__Account__r.BillingCountry);
        customerMap.put('state', quote.SBQQ__Account__r.BillingState);
        customerMap.put('postalcode', quote.SBQQ__Account__r.BillingPostalCode);
        customerMap.put('Customer_SF_ID', quote.SBQQ__Account__r.Id);
        customerMap.put('MSD Customer Number', quote.SBQQ__Account__r.MSD_Customer_Number__c);
        customerMap.put('MSD ID', quote.SBQQ__Account__r.MSD_ID__c);
        customerMap.put('SAP ID', quote.SBQQ__Account__r.SAP_ID__c);
        customerMap.put('ParentId', quote.SBQQ__Account__r.ParentId);
        customerMap.put('Legal_Name__c', quote.SBQQ__Account__r.Legal_Name__c);
        customerMap.put('Name', quote.SBQQ__Account__r.Name);
        //customerMap.put('CustomerNumber', quote.SBQQ__Account__r.AccountNumber);
        //customerMap.put('Customer_Group__c', quote.SBQQ__Account__r.Customer_Group_Code__c);
        
        /* Populate the Quote object */
        Map<String, Object> quoteMap = new Map<String, Object>();
        if(quote.Customer_Region__c != 'North America'){
        //quoteMap.put('PRICE_LIST',quote.SBQQ__Account__r.Price_List__c);
        	quoteMap.put('PRICE_LIST',quote.Sold_to__r.Price_List__c);
        }
        quoteMap.put('INTERNAL_TEXT',quote.Internal_Text__c);
        quoteMap.put('TERMS_TEXT',quote.Terms_and_Conditions__c);
        quoteMap.put('FLASH_TEXT',quote.Flash_Text__c);
        quoteMap.put('CARRIER_TEXT',quote.Carrier_Instructions__c);
        quoteMap.put('LOADING_TEXT',quote.Loading_Slip_Instructions__c);
        quoteMap.put('DELIVERY_TEXT',quote.Delivery_Instructions__c);
        quoteMap.put('INVOICE_NOTE',quote.Invoice_Note__c);
        quoteMap.put('HEADER_NOTE',quote.Header_Note_1__c);
        quoteMap.put('FORM_HEAD_TEXT',quote.Form_Header__c);
        if(quote.Customer_Region__c != 'North America'){
            quoteMap.put('Region','EU');
        	quoteMap.put('DISCOUNT_TEXT', quote.Discount_Rebate_Text__c);        
        }
        quoteMap.put('CUST_GROUP', quote.Customer_Group__c);
        //quoteMap.put('VariableFuelSurcharge', quote.Variable_Fuel_Surcharge__c?'01':'02');
        quoteMap.put('Requested Delivery Date', quote.Requested_Delivery_Date__c);
        quoteMap.put('Shipping Method', quote.Shipping_Method__c);
        quoteMap.put('Shipping Agent', quote.Shipping_Agent__c);
        quoteMap.put('SalesPerson', quote.SalesPerson__c);
        //quoteMap.put('Ord.Reason', quote.Ord_Reason__c ==null ? '001' : quote.Ord_Reason__c);
        quoteMap.put('Ord.Reason',  quote.Ord_Reason__c);
        if(quote.Customer_Region__c == 'Eastern Europe'){
            quoteMap.put('PURCH_NO_C', quote.PO_Number__c == null ? '.' : quote.PO_Number__c);
        }else{
        quoteMap.put('PURCH_NO_C', quote.PO_Number__c);
        }
        quoteMap.put('SALES_GRP', quote.SBQQ__Account__r.Account_Group__c);
        quoteMap.put('SHIPTO', quote.Ship_to__r.SAP_ID__c);
        quoteMap.put('SOLDTO', quote.Sold_to__r.SAP_ID__c);
        quoteMap.put('Business Type', quote.Business_Type__c);
        quoteMap.put('Destination', quote.Destination__c);//Ship_to__r.ShippingCountry);//Destination__c);
        quoteMap.put('Incoterms', quote.Incoterms1__c);
        quoteMap.put('FuelSurchargeType', quote.Variable_Fuel_Surcharge__c?'01':'02');
        quoteMap.put('ShippingCondition', quote.SE_Shipping_Condition__c);
        quoteMap.put('BillingSchedule', quote.Billing_Schedule__c);
        quoteMap.put('EquipmentShipType', quote.SE_Shipping_Type__c);
        quoteMap.put('ValidTo', quote.Valid_To__c);
        quoteMap.put('ValidFrom', quote.Valid_From__c);
        if(quote.Business_Unit__c == 'Carmeuse'){
            quoteMap.put('PaymentTerms', quote.Payment_Terms__c);  
        }else{
            quoteMap.put('PaymentTerms', quote.Payment_terms_STT__c); //Payment_Terms__c - SAP
        }
        quoteMap.put('Currency', quote.CurrencyIsoCode);//standard currencyiso code
        quoteMap.put('Pricing_Date', quote.Valid_From__c);//quote.Pricing_date__c);
        quoteMap.put('MSD_Quote_Number', quote.MSD_Quote_Number__c);
        quoteMap.put('MSD_Quote_ID', quote.MSD_ID__c);
        quoteMap.put('SAP_Quote_ID', quote.SAP_Quote_ID__c);
        quoteMap.put('SF_Quote_Id', quote.Id);
        //quoteMap.put('SalesOrganization', quote.Sales_Organization__c);
        
        
        /* Populate the QuoteLines list and Pricing Conditions list under Quotelines */
        List<Map<String, Object>> qliList = new List<Map<String, Object>>();
        Map<String,Schema.SObjectField> qliFieldsMap = Schema.SBQQ__QuoteLine__c.SObjectType.getDescribe().fields.getMap();
        
        /* Iterating through all the QLIs of the Quote */
        for (SBQQ__QuoteLine__c qli : quote.SBQQ__LineItems__r) {
            List<Map<String, Object>> pcList = new List<Map<String, Object>>();
            Map<String, Object> qliRecordMap = qli.getPopulatedFieldsAsMap();
            
            /* Iterating through all the fields of a QLI */
            for(String fieldName : qliRecordMap.keySet()) {
                System.debug('fieldName => ' + fieldName);
                String condition = (qliFieldsMap.get(fieldName) != null) ? pcMap.get(fieldName.replaceAll('__c',''))?.Category_Type__c : null;
                System.debug('condition=>'+condition);
                System.debug('pcaMap.containsKey(condition)=>'+pcaMap.containsKey(condition));
                System.debug(pcMap.get(fieldName.replaceAll('__c',''))?.Price_Category__c);
                /* Checking if the field belongs to Pricing_Condition_Access__c */
                if(String.isNotBlank(condition) && pcaMap.containsKey(condition) && (qli.Incoterms__c != 'EXW' || pcMap.get(fieldName.replaceAll('__c',''))?.Price_Category__c != 'Freight')) {
                    String option = (qliRecordMap.containsKey(condition + '_Option__c')) ? (String)qliRecordMap.get(condition + '_Option__c') : null;
                    Pricing_Condition_Access__c pca = (pcaMap.containsKey(condition) && pcaMap.get(condition).containsKey(option))
                        ? pcaMap.get(condition).get(option)
                        : null;
                    
                    System.debug(condition + ': ' + option + pca);
                    /* Checking if any of the Pricing_Condition_Access__c is matched */
                    Date validToDate = calculateValidToDate(quote, qli, condition, pcMap.get(condition).Price_Category__c, priceLists);
                    
                    if(pca != null && validToDate != null) {
                        Map<String, Object> pcKeyValueMap = new Map<String, Object>();
                        if(!pca.Is_Flat_Fee__c) {
                            pcKeyValueMap.put('KMEIN', qliRecordMap.get('Default_UOM__c'));
                            pcKeyValueMap.put('KPEIN','1');
                        }
                        pcKeyValueMap.put('KONWA', qliRecordMap.get('CurrencyIsoCode'));
                        pcKeyValueMap.put('KBETR', qliRecordMap.get(condition + '__c'));
                        Date validFromDate = calculateValidFromDate(quote);
                        pcKeyValueMap.put('ValidTo', validToDate);
                        pcKeyValueMap.put('ValidFrom', validFromDate);
                        if(String.isNotBlank(pca.Fields__c) && pca.Fields__c.split(',').contains('Ship.To')) {
                            pcKeyValueMap.put('PARVW', 'WE');
                            if(quote.Customer_Region__c != 'North America'){
                            pcKeyValueMap.put('KUNNR', qli.Ship_To__r.SAP_ID__c);
                            }else{
                             pcKeyValueMap.put('KUNNR', quote.Ship_to__r.SAP_ID__c);   
                            }
                        } else {
                            pcKeyValueMap.put('PARVW', 'AG');
                            pcKeyValueMap.put('KUNNR', quote.Sold_to__r.SAP_ID__c);
                        }
                        pcKeyValueMap.put('Dist.Channel', 10);
                        if(String.isNotBlank(pca.Fields__c)) {
                            for(String pcaQliField : pca.Fields__c.split(',')) {
                                if(pcaQliFieldsMap.containsKey(pcaQliField)) {
                                    if(pcaQliFieldsMap.get(pcaQliField).contains('.')) {
                                        List<String> fields = pcaQliFieldsMap.get(pcaQliField).split('\\.');
                                        sObject parentMap = (qliRecordMap.get(fields[0]) != null)
                                            ? qli.getSobject(fields[0])
                                            : null;
                                        if(pcaQliField == 'Inco.Terms') {
                                            pcKeyValueMap.put('Incoterms', parentMap.get(fields[1]));
                                        }else
                                            pcKeyValueMap.put(pcaQliField, parentMap.get(fields[1]));
                                    } else if(pcaQliFieldsMap.get(pcaQliField).equals('Plant__c')) {
                                        String qliField = pcaQliFieldsMap.get(pcaQliField);
                                        
                                        String plantName = (qliRecordMap.get(qliField) != null && ((String)qliRecordMap.get(qliField)).contains('-')) 
                                            ? ((String)qliRecordMap.get(qliField)).remove('-')
                                            : (String)qliRecordMap.get(qliField);
                                        if(quote.Customer_Region__c == 'North America'){
                                            plantName = (qliRecordMap.get(qliField) != null && ((String)qliRecordMap.get(qliField)).contains('-')) 
                                                ? ((String)qliRecordMap.get(qliField)).split('-')[1] 
                                                : (String)qliRecordMap.get(qliField);
                                        }
                                        pcKeyValueMap.put(pcaQliField, plantName);
                                    } else if(pcaQliField == 'Inco.Terms') {
                                        String qliField = pcaQliFieldsMap.get(pcaQliField);
                                        pcKeyValueMap.put('Incoterms', qliRecordMap.get(qliField));
                                    }  else if(pcaQliField == 'Ord.Reason') {
                                        pcKeyValueMap.put(pcaQliField,quote.Ord_Reason__c);// pcaQliFieldsMap.get(pcaQliField));
                                    } else if(pcaQliField == 'Price list'){
                                        pcKeyValueMap.put('Pricelist', 'AS');//'AS');
                                    }else {
                                        String qliField = pcaQliFieldsMap.get(pcaQliField);
                                        pcKeyValueMap.put(pcaQliField, qliRecordMap.get(qliField));
                                    }
                                }
                            }
                        }
                        pcKeyValueMap.put('Table', pca.Table__c);
                        pcKeyValueMap.put('Option Tech no', pca.Option_Tech_no__c);
                        pcKeyValueMap.put('Option', pca.Option__c);
                        pcKeyValueMap.put('Access seq', pca.Access_seq__c);
                        pcKeyValueMap.put('Pricing Condition', pca.Princing_Condition__c);
                        pcKeyValueMap.put('PricingConditionId', qliRecordMap.get('Id') + '-' + pca.Princing_Condition__c);
                        System.debug('pcKeyValueMap'+pcKeyValueMap);
                        System.debug('pca.Princing_Condition__c'+pca.Princing_Condition__c);
                        System.debug('pcKeyValueMap'+quote.Customer_Region__c);
                        if(quote.Customer_Region__c != 'North America' || (quote.Customer_Region__c == 'North America'  
                                        && (!NA_ShipType_Vals.contains(qli.SE_Shipping_Type__c) || pca.Princing_Condition__c == 'ZCPR')) ){
                        pcList.add(pcKeyValueMap);
                        
                        /* Adding the related Flat Pricing Category if region is North America. */
                        if(quote.Customer_Region__c == 'North America' && categoryFlatMap.containsKey(pca.Princing_Condition__c) 
                           && qliRecordMap.get('MIN_LOAD_SIZE__c') != null && ((Decimal)qliRecordMap.get('MIN_LOAD_SIZE__c')) > 0) {
                            Map<String, Object> flatPcKeyValueMap = pcKeyValueMap.clone();
                            flatPcKeyValueMap.put('Pricing Condition', categoryFlatMap.get(pca.Princing_Condition__c));   //Assigning the Flat Pricing Category
                            flatPcKeyValueMap.put('PricingConditionId', qliRecordMap.get('Id') + '-' + categoryFlatMap.get(pca.Princing_Condition__c));   //Assigning Id for this Flat Pricing Category
                            flatPcKeyValueMap.put('KBETR', (Decimal)pcKeyValueMap.get('KBETR') * (Decimal)(qliRecordMap.get('MIN_LOAD_SIZE__c') ?? 1));   //Assigning the Price for this Flat Pricing Category
                            pcList.add(flatPcKeyValueMap);
                        }
                                        }
                        
                    }
                }
            }
            
            String qliBasicText = (qli.Output_Text__c == 'Brand Text') ? qli.Brand_Text__c
                : ((qli.Output_Text__c == 'Custom Text') ? qli.Custom_Text__c
                   : ((qli.Output_Text__c == 'Customer Text') ? qli.Customer_Text__c
                      : ((qli.Output_Text__c == 'Sales Text') ? qli.Sales_Text__c : qli.SBQQ__ProductName__c)));
                          /* Populate the QuoteLines list */
                          Map<String, Object> qliMap = new Map<String, Object>();
            qliMap.put('PricingConditions', pcList);
            if(quote.Customer_Region__c == 'North America'){
            qliMap.put('SHIPTO', quote.Ship_to__r.SAP_ID__c);
            }else{
            qliMap.put('SHIPTO',qli.Ship_To__r.SAP_ID__c);
            }
            qliMap.put('Destination',qli.Destination__c);
            qliMap.put('ShippingCondition',qli.Shipping_Condition__c);
            qliMap.put('Incoterms', qli.Incoterms__c);
            qliMap.put('SHIP_POINT',getShipPointValue(qli.SBQQ__ProductCode__c,qli.Plant__c));
            if(quote.Customer_Region__c == 'North America') {
                qliMap.put('MIN_LOAD_SIZE', qli.MIN_LOAD_SIZE__c);
            }
            qliMap.put('ShipType', qli.SE_Shipping_Type__c);
            if(quote.Business_Unit__c == 'Carmeuse'){   //SAP
                qliMap.put('Primary', (qli.Primary__c ? 99: 100));
            }
            qliMap.put('LineType', qli.Line_Type__c);
            // qliMap.put('Requested Delivery Date', qli.Requested_Delivery_Date__c );
            // qliMap.put('TotalPrice', qli.Total_Price__c );
            if(quote.Business_Unit__c == 'Carmeuse'){   //SAP
                qliMap.put('UnitPrice', qli.List_Unit_Price__c);
            } else {                                      //MSD
                qliMap.put('UnitPrice', qli.Unit_Price__c);
            }
            qliMap.put('Discount', qli.SBQQ__Discount__c );
            //qliMap.put('TotalFreight', qli.Total_Freight__c );
            qliMap.put('Probability', (qli.Primary__c ? 99: 100));
            qliMap.put('UOM', qli.Default_UOM__c );
            qliMap.put('BasicText', qliBasicText);
            String plantName = (String.isNotBlank(qli.Plant__c) && qli.Plant__c.contains('-')) 
                ?qli.Plant__c.remove('-')
                :qli.Plant__c ;
            if(quote.Customer_Region__c == 'North America'){
                plantName = (String.isNotBlank(qli.Plant__c) && qli.Plant__c.contains('-')) 
                    ?qli.Plant__c.split('-')[1]
                    :qli.Plant__c ;
            }
            
            //String plantName = (String.isNotBlank(qli.Plant__c) && qli.Plant__c.contains('-')) ?qli.Plant__c.split('-')[1]:qli.Plant__c ;
            qliMap.put('Plant', plantName);
            qliMap.put('MSD_QuoteLine_Id', qli.MSD_Quote_Line_ID__c);
            qliMap.put('SAP_QuoteLine_Id', qli.SAP_Quote_Line_ID__c);
            qliMap.put('SBQQ_Quantity', qli.SBQQ__Quantity__c);
            qliMap.put('SBQQ__ProductCode', qli.SBQQ__ProductCode__c);
            System.debug('salesOrg==>'+quote.Sales_Organization__c+' '+quote.Customer_Region__c);
            if(quote.Customer_Region__c != 'North America'){
                    qliMap.put('SalesOrganization', quote.Sales_Organization__c);
                }else{
                    qliMap.put('SalesOrganization', qli.Sales_Organization__c);
                }
            qliMap.put('SF_QuoteLine_Id', qli.Id);
            qliList.add(qliMap);
        }
        
        /* Add the populated maps/lists to parentToChildMap */
        Map<String, Object> parentToChildMap = new Map<String, Object>();
        parentToChildMap.put('QuoteLines', qliList);
        parentToChildMap.put('Quote', quoteMap);
        parentToChildMap.put('Customer', customerMap);
        System.debug('Serialized JSON ==> ' + parentToChildMap);
        return parentToChildMap;
    }
    
    public static Date calculateValidFromDate(SBQQ__Quote__c quote) {
        Date dt = quote.Valid_From__c;
        if(quote.Customer_Region__c == 'Western Europe') {
            dt = quote.Valid_From__c.toStartOfMonth();
        }
        return dt;
    }
    
    public static Date calculateValidToDate(SBQQ__Quote__c quote, SBQQ__QuoteLine__c qli, String condition, String conditionType, List<Price_List__c> priceLists) {
        Date dt = quote.Valid_To__c;
        if(quote.Customer_Region__c == 'Western Europe') {
            if(condition == 'ZSFT' || condition == 'ZCO2' || condition == 'ZCPR') {
                for(Integer i = 0; i < priceLists.size(); i++) {
                    if(priceLists[i].PL__c == quote.Sold_to__r.Price_List__c && priceLists[i].CnTy__c == condition && priceLists[i].Plnt__c == qli.Plant__c && priceLists[i].Material__c == qli.SBQQ__ProductCode__c) {
                        dt = null; break;
                    }
                }
            } else if(conditionType == 'Freight') {
                dt = quote.Valid_From__c;
                Integer month = dt.month();
                Integer quaterMonth = (Math.mod(month, 3) == 0) ? month : (month + 3 - Math.mod(month, 3));
                    Integer year = dt.year();
                Integer days = Date.daysInMonth(year, quaterMonth);
                dt = Date.valueOf(year+'-'+quaterMonth+'-'+days);//Date.parse(quaterMonth + '/' + days + '/' + year);
            }
        }
        return dt;
    }
    
    public static String getShipPointValue(String productcode,String plant){
        String shipPoint = '';
        List<Products_By_Plant__c> productList = [SELECT id,Ship_Point__c FROM Products_By_Plant__c 
                                                  WHERE Product_Code__c=:productcode and Plant_Code__c =:plant];
        if(productList != null && productList.size() >0 && productList[0].Ship_Point__c != ''){
        	shipPoint = productList[0].Ship_Point__c;
        }
        return shipPoint;
    }
}