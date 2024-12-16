/**
* Class Name         : Ev_PricingConditionService
* Developer          : D Sridhar           
* Created Date       : 13-03-2024
* @description       : This class is used for executing complex logic
* Last Modified Date : 13-03-2024
*/
public with sharing class ev_PricingConditionService {
    static ev_PricingConditionService instance = null;   //Instance of this class
    static ev_SBQQ_QuoteSelector ev_SBQQ_QuoteSelectorInstance = ev_SBQQ_QuoteSelector.getInstance();
    static ev_SBQQ_QuoteLineSelector ev_SBQQ_QuoteLineSelectorInstance = ev_SBQQ_QuoteLineSelector.getInstance();
    static ev_SalesOrg_By_PlantSelector ev_SalesOrg_By_PlantSelectorInstance = ev_SalesOrg_By_PlantSelector.getInstance();
    static ev_Pricing_CategorySelector ev_Pricing_CategorySelectorInstance = ev_Pricing_CategorySelector.getInstance();
    static ev_Pricing_Condition_AccessSelector ev_Pricing_Condition_AccessSelectorInstance = ev_Pricing_Condition_AccessSelector.getInstance();
    static ev_Price_ListSelector ev_Price_ListSelectorInstance = ev_Price_ListSelector.getInstance();
    
    /**
* @description Creates and returns the instance of this class
* @return Instance of this class
*/
    public static ev_PricingConditionService getInstance() {
        if(instance == null) {
            instance = new ev_PricingConditionService();
        }
        return instance;
    }
    
    /**
* @description Fetches all the fields from Pricing_Condition_Header_Fields fieldset of Quote
* @return Stringified JSON of the fieldset
*/
    public String fetchQuotePricingConditionFieldset(String fieldSetName) {
        List<Map<String ,String>> listOfFieldSet  = new  List<Map<String ,String>>();
        Map<String,Schema.SObjectField> quoteFields = Schema.getGlobalDescribe().get('SBQQ__Quote__c').getDescribe().fields.getMap();
        try {
            for(Schema.FieldSetMember fieldset : SObjectType.SBQQ__Quote__c.fieldSets.getMap().get(fieldSetName).getFields()) {
                Map<String ,String> lableAPIMap = new Map<String ,String>();
                String label = fieldset.getLabel();
                if(((String)fieldset.getFieldPath()).contains('.')) {
                    SYstem.debug(((String)fieldset.getFieldPath()).contains('.'));
                    SYstem.debug(((String)fieldset.getFieldPath()).split('\\.'));
                    String parentField = ((String)fieldset.getFieldPath()).split('\\.')[0];
                    if(parentField.endsWithIgnoreCase('__r')) {
                        parentField = parentField.substring(0, parentField.length() - 1) + 'c';
                    }
                    label = quoteFields.get(parentField).getDescribe().getLabel();
                }
                lableAPIMap.put('label', label);
                lableAPIMap.put('name', fieldset.getFieldPath());
                listOfFieldSet.add(lableAPIMap);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(listOfFieldSet);
    }
    
    /**
* @description Fetches all the fields from Pricing_Condition_Header_Fields fieldset of Quote
* @return Stringified JSON of the fieldset
*/
    public String fetchQliPricingConditionFieldset(String fieldSetName) {
        List<Map<String ,String>> listOfFieldSet  = new  List<Map<String ,String>>();
        Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap();
        try {
            for(Schema.FieldSetMember fieldset : SObjectType.SBQQ__QuoteLine__c.fieldSets.getMap().get(fieldSetName).getFields()) {
                Map<String ,String> lableAPIMap = new Map<String ,String>();
                String label = fieldset.getLabel();
                if(((String)fieldset.getFieldPath()).contains('.')) {
                    String parentField = ((String)fieldset.getFieldPath()).split('\\.')[0];
                    if(parentField.endsWithIgnoreCase('__r')) {
                        parentField = parentField.substring(0, parentField.length() - 1) + 'c';
                    }
                    label = fields.get(parentField).getDescribe().getLabel();
                }
                lableAPIMap.put('label', label);
                lableAPIMap.put('name', fieldset.getFieldPath());
                listOfFieldSet.add(lableAPIMap);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return JSON.serialize(listOfFieldSet);
    }
    
    /**
* @description Fetches a list of records w.r.t fields, filter, child queries, etc.
* @param parameterMap JSON string containing all parameters like fields, filter, child queries, etc.
* @return List of SBQQ__Quote__c records
*/
    public List<SBQQ__Quote__c> fetchQuote(String parameters) {
        Map<String,Object> parameterMap = (Map<String,Object>)JSON.deserializeUntyped(parameters);
        List<String> fields = new List<String>();
        Map<String,Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('SBQQ__Quote__c').getDescribe().fields.getMap();
        for(String fieldName : fieldsMap.keySet()) {
            if(fieldsMap.get(fieldName).getDescribe().isAccessible()) {
                fields.add(fieldName);
            }
        }
        String filter = 'Id = \'' + String.escapeSingleQuotes((String)parameterMap.get('quoteId')) + '\'';
        
        Map<String,Object> newParameterMap = new Map<String,Object>{'fields'=>fields, 'filter'=>filter};
            return ev_SBQQ_QuoteSelectorInstance.getRecords(newParameterMap);
    }
    
    /**
* @description Fetches a list of records w.r.t fields, filter, child queries, etc.
* @param parameterMap JSON string containing all parameters like fields, filter, child queries, etc.
* @return List of SBQQ__QuoteLine__c records
*/
    public List<SBQQ__QuoteLine__c> fetchQLIsofQuote(String parameters) {
        Map<String,Object> parameterMap = (Map<String,Object>)JSON.deserializeUntyped(parameters);
        
        List<String> fields = new List<String>();
        Map<String,Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap();
        for(String fieldName : fieldsMap.keySet()) {
            if(fieldsMap.get(fieldName).getDescribe().isAccessible()) {
                fields.add(fieldName);
            }
        }
        fields.addAll(new List<String>{ 'SBQQ__Quote__r.Name', 'SBQQ__Quote__r.Customer_Region__c', 'SBQQ__Quote__r.Ord_Reason__c', 'SBQQ__Product__r.Name', 'SBQQ__Product__r.Plant__c'
            , 'SBQQ__Quote__r.SBQQ__Account__r.Price_List__c', 'SBQQ__Quote__r.Sold_to__r.Price_List__c'});
        /*List<String> fields = new List<String>{ 'Id', 'Name', 'SBQQ__Quote__c', 'SBQQ__ProductCode__c', 'SBQQ__Quantity__c', 'SBQQ__RequiredBy__c',
'SBQQ__Number__c', 'SBQQ__ListPrice__c', 'SBQQ__Description__c', 'Sales_Organization__c', 'CurrencyIsoCode', 'Estimated_Qty_Delivery__c', 'Sub_Total__c',
'Plant__c', 'List_Unit_Price__c', 'Freight_Price__c', 'Misc_Price__c', 'PC_Discount__c', 'Commission__c', 'Surcharge__c', 'Fees_Price__c',
'Total_Price__c', 'Cust_material_price__c', 'Material_Flat_Rate__c', 'Customer_Rebates__c', 'Disc_Pay_In_Adv__c', 'Disc_Contract_Qty__c', 'Disc_Promotion__c', 
'Disc_Pay_In_Adv_Qty__c', 'Logistics_Srv_Ton__c', 'Pallet_Charges__c', 'Harbor_Maintenance__c', 'WEU_Commission__c', 'Rockwell_Commission__c',
'RL_Commission_Basis__c', 'Bagged_Freight__c', 'Truck_Freight_Ton__c', 'Vessel_Freight_Ton__c', 'Barge_Freight_Ton__c', 'Rail_Freight_Ton__c', 
'Misc_Freight_Flat__c', 'Extra_freight_rebill__c', 'Truck_Freight_Flat__c', 'CO2_Surcharge__c', 'Misc_Fuel_Surcharge__c', 'Misc_Surcharge_Ton__c',
'Alabama_SeveranceTax__c', 'Fuel_SurCh_Rail_MB__c', 'Fuel_SurCh_Rail_Mile__c', 'Fuel_SurCh_Rail_Ton__c', 'Fuel_SurChTruck_Flat__c', 'Fuel_SurChTruck_Ton__c', 
'Var_F_Surch_Truck__c', 'FuelSurCh_Vessel_Ton__c', 'Admin_Flat_Fee__c', 'Admin_Fee_Ton__c', 'Handling_Flat_Fee__c', 'Terminal_Fee_Ton__c', 'Truck_Fr_Flat_Fee__c',
'Rail_Fr_Flat_Fee__c', 'Service_Fee_Flat__c', 'Service_Fee_Quantity__c', 'Dry_Feed_Rate__c', 'Feed_Control_Device__c', 
'ZSVF_Option__c', 'ZSTT_Option__c', 'ZSTF_Option__c', 'ZSRT_Option__c', 'ZMIS_Option__c', 'ZF3_Option__c', 'ZF22_Option__c', 'ZF2_Option__c', 'ZF16_Option__c', 
'ZF13_Option__c', 'ZF1_Option__c', 'ZCPR_Option__c', 'ZCO2_Option__c', 'ZAST_Option__c', 'ZADN_Option__c', 'ZAD_Option__c',
'SBQQ__Quote__r.Name', 'SBQQ__Quote__r.Customer_Region__c', 'SBQQ__Product__r.Name', 'SBQQ__Product__r.Plant__c' }; */
        String filter = 'SBQQ__Quote__c = \'' + String.escapeSingleQuotes((String)parameterMap.get('quoteId')) + '\'';
        Map<String,Object> newParameterMap = new Map<String,Object>{'fields'=>fields, 'filter'=>filter};
            
            Map<Id,SBQQ__QuoteLine__c> recordsMap = ev_SBQQ_QuoteLineSelectorInstance.fetchQLIs(newParameterMap);
        if(recordsMap != null) {
            return recordsMap.values();
        }
        return null;
    }
    
    /**
* @description Prepares a map of Plant Picklist Value and its Label.
* @return Map of Plant Picklist Value and its Label
*/
    public Map<String,String> fetchPlantPicklistEntries() {
        Map<String,String> activeEntries = new Map<String,String>();
        for (Schema.PicklistEntry entry : SBQQ__QuoteLine__c.Plant__c.getDescribe().getPickListValues()) {
            SYstem.debug(entry);
            if (entry.isActive()) {
                activeEntries.put(entry.getValue(), entry.getLabel());
            }
        }
        return activeEntries;
    }
    
    /**
* @description Fetches a list of records w.r.t fields, filter, child queries, etc.
* @param parameterMap JSON string containing all parameters like fields, filter, child queries, etc.
* @return List of SalesOrg_By_Plant__c records
*/
    public List<SalesOrg_By_Plant__c> fetchSalesOrgByPlant() {
        List<String> fields = new List<String>{'SalesOrgCode__c', 'PlantCode__c'};
            Map<String,Object> newParameterMap = new Map<String,Object>{'fields'=>fields};
                
                Map<Id,SalesOrg_By_Plant__c> recordsMap = ev_SalesOrg_By_PlantSelectorInstance.fetchQLIs(newParameterMap);
        if(recordsMap != null) {
            return recordsMap.values();
        }
        return null;
    }
    
    /**
* @description Fetches a list of records w.r.t fields, filter, child queries, etc.
* @param parameterMap JSON string containing all parameters like fields, filter, child queries, etc.
* @return List of Pricing_Category__c records grouped by some parameters
*/
    public List<AggregateResult> fetchPricingCategories(String parameters, Boolean isAggregateQuery) {
        Map<String,Object> parameterMap = (Map<String,Object>)JSON.deserializeUntyped(parameters);
        String plantRegion = (String)parameterMap.get('plantRegion');
        /* List<String> salesOrgs = (List<String>)JSON.deserialize(JSON.serialize(parameterMap.get('salesOrgs')), List<String>.class);

List<String> fields = new List<String>{'Sales_Organization__c', 'Price_Category__c', 'Description__c'};
String filter = 'Sales_Organization__c IN (\'' + String.join(salesOrgs, '\',\'') + '\') AND Price_Category__c != null AND Description__c != null'; */
        List<String> fields = new List<String>{'Price_Category__c', 'Description__c', 'Category_Type__c'};
            String filter = ' Plant_Region__c INCLUDES (\'' + plantRegion + ';\') AND Price_Category__c != null AND Description__c != null GROUP BY Price_Category__c, Category_Type__c, Description__c';
        Map<String,Object> newParameterMap = new Map<String,Object>{'fields'=>fields, 'filter'=>filter};
            
            /* Map<Id,Pricing_Category__c> recordsMap = ev_Pricing_CategorySelectorInstance.fetchPricingCategories(newParameterMap, true);
if(recordsMap != null) {
return recordsMap.values();
}
return null; */
            return ev_Pricing_CategorySelectorInstance.fetchPricingCategories(newParameterMap, true);
    }
    
    /**
* @description Fetches a list of records w.r.t fields, filter, child queries, etc.
* @param parameterMap JSON string containing all parameters like fields, filter, child queries, etc.
* @return List of Pricing_Condition_Access__c records
*/
    public List<Pricing_Condition_Access__c> fetchPCAs(String parameters) {
        Map<String,Object> parameterMap = (Map<String,Object>)JSON.deserializeUntyped(parameters);
        String plantRegion = (String)parameterMap.get('plantRegion');
        
        List<String> fields = new List<String>{'Princing_Condition__c', 'Option__c', 'Option_Name__c','Option_Label__c', 'Default_Option_for_Regions__c'};
            String filter = ' Region__c INCLUDES (\'' + plantRegion + ';\')';
        String orderby = ' ORDER BY Princing_Condition__c, Option__c ';
        Map<String,Object> newParameterMap = new Map<String,Object>{'fields'=>fields, 'filter'=>filter, 'orderby'=>orderby};
            Map<Id,Pricing_Condition_Access__c> recordsMap = ev_Pricing_Condition_AccessSelectorInstance.fetchPCAs(newParameterMap);
        if(recordsMap != null) {
            return recordsMap.values();
        }
        return null; 
    }
    
    /**
* @description Updates SBQQ__Quote__c record.
* @param quote SBQQ__Quote__c record which is to be updated.
* @return Status of the DML Operation
*/
    public Boolean updateQuote(SBQQ__Quote__c quote) {
        if(quote != null) {
            try {
                Database.update(new List<SBQQ__Quote__c>{quote});
                return true;
            } catch(Exception e) {
                throw new AuraHandledException(e.getMessage());   //Throws an exception
            }
        }
        return false;
    }
    
    /**
* @description Updates SBQQ__QuoteLine__c records with Pricing Category information and prices.
* @param qlis List of SBQQ__QuoteLine__c records with updated Pricing Category information and prices
* @return Status of the DML Operation
*/
    public Boolean updateQLIsWithPricingCategs(List<SBQQ__QuoteLine__c> qlis) {
        if(qlis != null && !qlis.isEmpty()) {
            try {
                Database.update(qlis);
                return true;
            } catch(Exception e) {
                throw new AuraHandledException(e.getMessage());   //Throws an exception
            }
        }
        return false;
    }
    
    /**
* @description Fetches a list of records w.r.t fields, filter, child queries, etc.
* @param parameterMap JSON string containing all parameters like fields, filter, child queries, etc.
* @return List of Price_List__c records
*/
    public List<Price_List__c> fetchPriceLists(String parameters) {
        Map<String,Object> parameterMap = (Map<String,Object>)JSON.deserializeUntyped(parameters);
        String startDate = (String)parameterMap.get('startDate');
        String endDate = (String)parameterMap.get('endDate');
        
        List<String> fields = new List<String>{'CnTy__c', 'PL__c', 'Plnt__c', 'Material__c', 'Material_Name__c', 'Amount__c', 'Unit__c', 'per__c', 'UoM__c'};
        List<String> filters = new List<String>();
        if(startDate != null) {
            filters.add(' Valid_From__c <= ' + startDate);
            filters.add(' Valid_To__c >= ' + startDate);
        }
       /* if(endDate != null) {
            filters.add(' Valid_To__c >= ' + endDate);
        }*/
        System.debug('filter==>'+filters);
       // Map<String,Object> newParameterMap = new Map<String,Object>{ 'fields'=>fields, 'filter'=>null };   
        Map<String,Object> newParameterMap = new Map<String,Object>{ 'fields'=>fields, 'filter'=>String.join(filters, ' AND ') };
        return ev_Price_ListSelectorInstance.fetchRecords(newParameterMap);
    }
}