public class ev_CloneQuoteWithRelatedController {
    
    
    
    // To clone the  Quote and related Quote line Items
    @AuraEnabled
    public static String cloneQuoteWithRelated(String QuoteId) {
        try{
            
            
            
            // Get  Quote and related Quote line Items
            List<SBQQ__Quote__c> QuoteList = new list<SBQQ__Quote__c>();
            List<SBQQ__QuoteLine__c> QuoteLineList = new list<SBQQ__QuoteLine__c>();
            Map<String, String> QLBWithOption = new Map<String, String>();
            map<String, String> oldIdWithNewIdsMap = new map<String, String>();
            
            Map<Id,SBQQ__QuoteLine__c> BundleMap = new Map<Id,SBQQ__QuoteLine__c>();
            // Additonal__c,Quality_Certification_Free_text_area__c,Safety_Free_text_area__c,CO2_Contribution_Free_text_area__c,
            // Energy_Surcharge_Free_text_area__c,Transport_Terms_Free_text_area__c,OfferValidity__c,Area_Sales_Manager__c,
            // Discount__c,Rebate__c,
            //  Content_of_Text_Box_under_Pricing_Table__c,Content_of_Text_Box_above_Pricing_Table__c, 

            for( SBQQ__Quote__c quotee: [select Id,  Name, CurrencyIsoCode, SBQQ__Account__c, SBQQ__BillingCity__c, SBQQ__BillingCountry__c,Ord_Reason__c, SBQQ__BillingFrequency__c, SBQQ__BillingName__c, SBQQ__BillingPostalCode__c, SBQQ__BillingState__c, SBQQ__BillingStreet__c, SBQQ__ConsumptionRateOverride__c, SBQQ__ContractingMethod__c, SBQQ__CustomerDiscount__c, SBQQ__DefaultTemplate__c, SBQQ__DeliveryMethod__c, SBQQ__DistributorDiscount__c, SBQQ__Distributor__c, SBQQ__DocumentStatus__c, SBQQ__EmailTemplateId__c, SBQQ__EndDate__c, SBQQ__FirstSegmentTermEndDate__c, SBQQ__GenerateContractedPrice__c, SBQQ__Introduction__c, SBQQ__Key__c, SBQQ__LastCalculatedOn__c, SBQQ__LastSavedOn__c, SBQQ__LineItemsGrouped__c, SBQQ__LineItemsPrinted__c, SBQQ__MarkupRate__c, SBQQ__MasterContract__c, SBQQ__MasterEvergreenContract__c, SBQQ__Notes__c, SBQQ__Opportunity2__c, SBQQ__OrderByQuoteLineGroup__c, SBQQ__OrderBy__c, SBQQ__OrderGroupID__c, SBQQ__Ordered__c, SBQQ__OriginalQuote__c, SBQQ__PaperSize__c, SBQQ__PartnerDiscount__c, SBQQ__Partner__c, SBQQ__PaymentTerms__c, SBQQ__PriceBook__c, SBQQ__PricebookId__c, SBQQ__PrimaryContact__c, SBQQ__ProrationDayOfMonth__c, SBQQ__QuoteLanguage__c, SBQQ__QuoteProcessId__c, SBQQ__QuoteTemplateId__c, SBQQ__RenewalTerm__c, SBQQ__RenewalUpliftRate__c, SBQQ__SalesRep__c, SBQQ__ShippingCity__c, SBQQ__ShippingCountry__c, SBQQ__ShippingName__c, SBQQ__ShippingPostalCode__c, SBQQ__ShippingState__c, SBQQ__ShippingStreet__c, SBQQ__Source__c, SBQQ__StartDate__c, SBQQ__Status__c, SBQQ__SubscriptionTerm__c, SBQQ__TargetCustomerAmount__c, SBQQ__Type__c, SBQQ__Unopened__c, SBQQ__WatermarkShown__c, SBQQ__LineItemCount__c, SBQQ__AdditionalDiscountAmount__c, SBQQ__AverageCustomerDiscount__c, SBQQ__AveragePartnerDiscount__c, SBQQ__DaysQuoteOpen__c, SBQQ__ExpirationDate__c, SBQQ__TotalCustomerDiscountAmount__c, SBQQ__Uncalculated__c, SBQQ__CustomerAmount__c, SBQQ__ListAmount__c, SBQQ__NetAmount__c, SBQQ__RegularAmount__c, Quote_Description__c, Pricing_date__c, Currency__c, Opportunity_Stage__c, Business_Unit__c, Opportunity_Type__c, Business_Type__c, Valid_From__c, Valid_To__c, Minimum_Tons_Load__c, Destination__c, Show_product_code__c, Show_Plant_Name__c, Show_Quantity__c, Show_Total_Price__c, Show_Final_Price__c, Show_VAT_Excl__c, Show_T_C__c, Guide_lines_for_contract_Haulers__c, UOM__c, CO2_Surcharge__c, Estimated_Total_Quantity__c, Show_STD_Text_Block_1__c, Show_Free_Text_Block_1__c, Transport__c, Free_Text_Box_above_Pricing_Table__c, Show_STD_Text_Box_3__c, Show_STD_text_Box_4__c, Safety_Data_Sheets_SDS_Link__c, Special_Conditions__c, Free_text_located_under_pricing_table__c, Free_text_box_located_above_signature__c, SE_Shipping_Condition__c, Freight_Request__c, Urgent__c, C3S_Description__c, Receiving_days_and_Hours__c, Address__c, SE_Shipping_Type__c, SE_Est_Total_Quantity__c, SE_Est_Quantity_Del__c, Description_Suply_Chain_Only__c, Primary_rate__c, Per_ton_or_Flat__c, Unloading_Time_silo_truck_hr__c, Unloading_time_Tip_truck__c, Waiting_hours__c, Rate__c, Carrier_Name__c, Min_Ton__c, Secondary_Rate__c, Secondary_Carrier_Name__c, Freight_Ready_Supply_Chain__c, Freight_Approved_Supply__c, Non_discharged_product__c, Emergency_deliveries__c, WE_deliveries_hr__c, WE_deliveries__c, Diesel_Clause__c, Email_orders__c, Energy_Surcharg__c, Tps_D_ch_Cit_hre__c, Tps_D_ch_Benne_hre__c, Hre_Attente_Chantier__c, Prod_Non_D_ch__c, Livr_Urgentes__c, Cde_week_end_hre__c, Cde_week_end__c, Email_Cdes__c, Transport_sacs_table_BE_BE__c, Transport_sacs_table_NL_NL__c, Transport_sacs_table_FR_FR__c, Transports_sacs_table_NL_BE__c, Surcharge_energie__c, Lostijd_silo_wagen_hr__c, Lostijd_kipwagen_hr__c, Wachturen__c, Niet_gelost_produkt__c, Noodleveringen__c, W_E_levering_hr__c, W_E_levering__c, Diesel_clausule__c, Email_bestellingen__c, Energie_toeslag__c, Contact_Phone__c, Contact_Email__c, Sales_Organization__c, Primary_Name__c, Last_Generated_Proposal__c, Special_Instructions__c, Incoterms1__c, Customer_Number__c, Created__c, Payment_Terms__c, Sold_to__c, Ship_to__c, Bill_To__c, Pay_To__c, Market_Value__c, Account_SAP_Id__c, Net_Total__c, EditLinesFieldSetName__c,  Market__c, Sub_Market__c, Billing_Schedule__c, Markup_Custom__c, Impurity__c, Length__c, Width__c, Height__c, Plant_Region__c, Boomi_Error_Code__c, Total_Price__c, Total_Units__c, Volume_Brunt__c, Volume_Crude__c, Lead_Time__c, Quote_Name__c, Win_Probability__c, Go_Probability__c,  Customer_Region__c, Content_of_Show_STD_Text_Block_1__c, Content_of_Show_Free_Text_Block_1__c, Content_of_Show_STD_Text_Box_3__c, Content_of_Show_STD_text_Box_4__c, Content_of_Transport__c, Content_of_Safety_Data_Sheets_SDS_Link__c, Content_of_Special_Conditions__c, Content_of_Text_Box_above_Signature__c, Content_of_Text_Box_above_Pricing_Table__c, Content_of_Text_Box_under_Pricing_Table__c,  Transport_Content__c, Show_Transport_on_Doc__c, Form_Header__c, Header_Note_1__c, Invoice_Note__c, Delivery_Instructions__c, Loading_Slip_Instructions__c, Carrier_Instructions__c, Flash_Text__c, Terms_and_Conditions__c, Internal_Text__c, Conversion_Rate__c, Show_Free_Text_Block_1_on_Doc__c, Show_Text_Box_above_Pricing_Table_on_Doc__c, Show_STD_Text_Box_3_on_Doc__c, Show_STD_text_Box_4_on_Doc__c, Show_Safety_Data_Sheets_SDS_Link__c, Show_Special_Conditions_on_Doc__c, Show_Text_Box_under_Pricing_Table_on_Doc__c, Show_Text_Box_above_Signature_on_Doc__c,  Ship_to_Location__c, CO2_French__c, CO2_Dutch__c, CO2_English__c, Table_Transport_bags_NL_NL__c, Table_Transport_bags_BE_BE__c, Table_Transport_bags_NL_BE__c, Table_Transport_bags_FR_FR__c, Tabel_Transport_zakgoed_BE_BE__c, Tabel_Transport_zakgoed_FR_FR__c, Tabel_Transport_zakgoed_NL_NL__c, Tabel_Transport_zakgoed_NL_BE__c, VAT_Amount__c, Tax_Area_Code__c,
                                         Variable_Fuel_Surcharge__c,Customer_Group__c, 
                                         (select Id, Name, CurrencyIsoCode, SBQQ__Quote__c, Line_Type__c,SBQQ__AdditionalDiscountAmount__c, SBQQ__AdditionalQuantity__c,
                                          SBQQ__AllowAssetRefund__c, SBQQ__BatchQuantity__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c, SBQQ__BlockPrice__c,
                                          SBQQ__Bundle__c, SBQQ__BundledQuantity__c, SBQQ__Bundled__c, SBQQ__CarryoverLine__c, SBQQ__ChargeType__c, SBQQ__ComponentCost__c,
                                          SBQQ__ComponentDiscountedByPackage__c, SBQQ__ComponentListTotal__c, SBQQ__ComponentSubscriptionScope__c, SBQQ__ComponentTotal__c,
                                          SBQQ__ComponentUpliftedByPackage__c, SBQQ__CompoundDiscountRate__c, SBQQ__ConfigurationRequired__c, SBQQ__ContractedPrice__c, SBQQ__CostEditable__c,
                                          SBQQ__Cost__c, SBQQ__CustomerPrice__c, SBQQ__DefaultSubscriptionTerm__c, SBQQ__Description__c, SBQQ__Dimension__c, SBQQ__DiscountScheduleType__c, 
                                          SBQQ__DiscountSchedule__c, SBQQ__DiscountTier__c, SBQQ__Discount__c, SBQQ__DistributorDiscount__c, SBQQ__DynamicOptionId__c, SBQQ__EarliestValidAmendmentStartDate__c, SBQQ__EndDate__c,
                                          SBQQ__Existing__c, SBQQ__Favorite__c, SBQQ__GenerateContractedPrice__c, SBQQ__GrossProfit__c, SBQQ__Group__c, SBQQ__Guidance__c, SBQQ__HasConsumptionSchedule__c,
                                          SBQQ__Hidden__c, SBQQ__Incomplete__c, SBQQ__ListPrice__c, SBQQ__MarkupAmount__c, SBQQ__MarkupRate__c, SBQQ__MaximumPrice__c, SBQQ__MinimumPrice__c,
                                          SBQQ__NetPrice__c, SBQQ__NonDiscountable__c, SBQQ__NonPartnerDiscountable__c, SBQQ__Number__c, SBQQ__OptionDiscountAmount__c, SBQQ__OptionDiscount__c,
                                          SBQQ__OptionLevel__c, SBQQ__OptionType__c, SBQQ__Optional__c, SBQQ__OriginalPrice__c, SBQQ__OriginalQuoteLineId__c, SBQQ__OriginalUnitCost__c,
                                          SBQQ__PackageProductCode__c, SBQQ__PackageProductDescription__c, SBQQ__PartnerDiscount__c, SBQQ__PartnerPrice__c, SBQQ__PreviousSegmentPrice__c,
                                          SBQQ__PreviousSegmentUplift__c, SBQQ__PriceEditable__c, SBQQ__PricebookEntryId__c, SBQQ__PricingMethodEditable__c, SBQQ__PricingMethod__c, SBQQ__PriorQuantity__c,
                                          SBQQ__ProductOption__c, SBQQ__ProductSubscriptionType__c, SBQQ__Product__c, SBQQ__ProrateMultiplier__c, SBQQ__ProratedListPrice__c, SBQQ__ProratedPrice__c, SBQQ__Quantity__c,
                                          SBQQ__RegularPrice__c, SBQQ__Renewal__c, SBQQ__RenewedAsset__c, SBQQ__RenewedSubscription__c, SBQQ__RequiredBy__c, SBQQ__SegmentIndex__c, SBQQ__SegmentKey__c, SBQQ__SegmentLabel__c, SBQQ__Source__c,
                                          SBQQ__SpecialPriceDescription__c, SBQQ__SpecialPriceType__c, SBQQ__SpecialPrice__c, SBQQ__StartDate__c, SBQQ__SubscribedAssetIds__c, SBQQ__SubscriptionBase__c, SBQQ__SubscriptionCategory__c, SBQQ__SubscriptionPercent__c, SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionScope__c, SBQQ__SubscriptionTargetPrice__c, SBQQ__SubscriptionTerm__c, SBQQ__TaxCode__c, SBQQ__Taxable__c, SBQQ__TermDiscountSchedule__c, SBQQ__TermDiscountTier__c, SBQQ__TermDiscount__c, SBQQ__UnitCost__c, SBQQ__UnproratedNetPrice__c, SBQQ__UpgradedAsset__c, SBQQ__UpgradedQuantity__c, SBQQ__UpgradedSubscription__c, SBQQ__UpliftAmount__c, SBQQ__Uplift__c, SBQQ__VolumeDiscount__c, SBQQ__AdditionalDiscount__c, SBQQ__ComponentVisibility__c, SBQQ__CustomerTotal__c, SBQQ__EffectiveEndDate__c, SBQQ__EffectiveQuantity__c, SBQQ__EffectiveStartDate__c, SBQQ__EffectiveSubscriptionTerm__c, SBQQ__ListTotal__c, SBQQ__Markup__c, SBQQ__NetTotal__c, SBQQ__PackageCost__c, SBQQ__PackageListTotal__c, SBQQ__PackageTotal__c, SBQQ__PartnerTotal__c, SBQQ__ProductCode__c, SBQQ__ProductFamily__c, SBQQ__ProductName__c, SBQQ__RegularTotal__c, SBQQ__SubscriptionType__c, SBQQ__TotalDiscountAmount__c, SBQQ__TotalDiscountRate__c, ZAD__c, ZADN__c, ZAST__c, ZCO2__c, ZCPF__c, ZCPR__c, ZCWE__c, ZDAJ__c, ZDFR__c, ZDIS__c, ZDPR__c, ZF01__c, ZF1__c, ZF11__c, ZF16__c, ZF2__c, ZF22__c, ZF3__c, ZF31__c, ZF4__c, ZF6__c, ZF7__c, ZF9__c, ZLRT__c, ZMF2__c, ZMF6__c, ZMF7__c, ZMFS__c, ZMIS__c, ZPCT__c, ZPLT__c, ZPRO__c, ZRC__c, ZREB__c, ZRLC__c, ZRMI__c, ZSFF__c, ZSFT__c, ZSPA__c, ZSRM__c, ZSRT__c, ZSTF__c, ZSTT__c, ZSVF__c, ZVFS__c, Basic_Text__c, Sales_Text__c, Output_description__c, Customer_Text__c, Brand_Text__c, Custom_description__c, Distance__c, Product_Price__c, UOM__c, PC_Discount__c, Fees_Price__c, Freight_Price__c, Misc_Price__c, Surcharge__c, Commission__c, Sylo_Type__c, Location_Code__c, Feed_Control_Device__c, Slaker_Type__c, Mix_Tank_Type__c, Plant__c, Sales_Organization__c, Product_Family__c, List_Unit_Price__c, Custom_Text__c, Total_Price__c, Default_UOM__c, Plant2__c, Length__c, Width__c, Height__c, Estimated_Qty_Delivery__c, Sub_Total__c, Primary__c, Picklist__c, Types_of_Systems__c, Other_Systems_Type__c, Other_Feed_Control_Device__c, System_Type__c, Cost_of_Goods__c, Dry_Feed_Rate__c, Wet_Storage__c,   Status_Code_of_QuoteLine__c, Error_description__c,   Dry_Storage__c, Category__c, ZAD_Option__c, ZADN_Option__c, ZAST_Option__c, ZCO2_Option__c, ZCPR_Option__c, ZF1_Option__c, ZF13_Option__c, ZF16_Option__c, ZF2_Option__c, ZF22_Option__c, ZF3_Option__c, ZMIS_Option__c, ZSRT_Option__c, ZSTF_Option__c, ZSTT_Option__c, ZSVF_Option__c, Freight_Per_Unit__c, Total_Freight__c, Conversion_Rate__c, test__c, Quote_Additional_Disc__c, Business_Unit__c, Pricing_Approved_Status__c, Mark_Up__c, VAT_Percent__c, Output_Text__c, VAT_Amount__c, ZF4_Option__c, ZSFT_Option__c, ZMF2_Option__c, ZREB_Option__c, ZSPA_Option__c, ZRMI_Option__c, ZDIS_Option__c, ZRLC_Option__c, ZMF7_Option__c, ZCWE_Option__c, ZPCT_Option__c, ZSRM_Option__c, ZCPF_Option__c, ZDPR_Option__c, ZF9_Option__c, ZPLT_Option__c, ZMF6_Option__c, ZPRO_Option__c, ZF11_Option__c, ZVFS_Option__c, ZLRT_Option__c, ZDAJ_Option__c, ZRC_Option__c, ZSFF_Option__c, ZF7_Option__c, ZF6_Option__c, ZF31_Option__c, ZDFR_Option__c, ZF01_Option__c, ZMFS_Option__c, Tax_Area_Code__c
                                          ,Composition__c,Miles__c,Plant_Text__c,Product_Type__c,Requested_Delivery_Date__c,Requested_Delivery_Date1__c,Size__c,Unit_Price__c,ZF5__c,ZF5_Option__c,ZMF1__c,ZMF1_Option__c,EXCH_RATE_Updated__c,Mark_Up_Updated__c,Freight_Per_Unit_Updated__c,Cost_Of_Goods_Updated__c,COG_Currency__c,Surcharge_variable__c,UOM_Distance__c,SE_Shipping_Type__c,MIN_LOAD_SIZE__c
                                          ,Destination__c,Shipping_Condition__c,Incoterms__c,Ship_To__c,Sold_to__c
                                           FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c WHERE Id = : QuoteId  ]){
                                              
                                              SBQQ__Quote__c  quoteObj =  quotee.clone(false, true);     
                                              quoteObj.SBQQ__Opportunity2__c = quotee.SBQQ__Opportunity2__c;  
                                              quoteObj.SBQQ__Status__c = 'Draft';
                                              quoteObj.Cloned_From_Quote__c =quotee.Name;
                                              QuoteList.add(quoteObj);
                                              
                                              for(SBQQ__QuoteLine__c QL : quotee.SBQQ__LineItems__r){
                                                  SBQQ__QuoteLine__c  quoteLIneObj =  QL.clone(false, true); 
                                                  if(String.isBlank(QL.SBQQ__RequiredBy__c)){
                                                      BundleMap.put(QL.id,quoteLIneObj);
                                                  }else{
                                                      QuoteLineList.add(quoteLIneObj);
                                                  }
                                                  
                                              }
                                          }
            
            
            // Create Quote
            if(QuoteList.size() > 0){
                insert QuoteList;
                System.debug('QuoteList ==>> '+QuoteList);
                
            }
            
            // Create Bundle Quote Lines if Any
            if(!BundleMap.isEmpty()){
                for(SBQQ__QuoteLine__c q : BundleMap.values()){
                    q.SBQQ__Quote__c=QuoteList[0].Id;
                }
                insert BundleMap.values();
                for(String Key : BundleMap.Keyset()){  
                    QLBWithOption.put(Key, BundleMap.get(key).Id);  // Map to store Old Id and new Id of a bundle Quote Line.                     
                }
                System.debug('QLBWithOption ==>> '+QLBWithOption);
                
            }
            
            
            //Create a Quote Lines
            if(QuoteLineList.size() > 0){
                for(SBQQ__QuoteLine__c qtl : QuoteLineList){
                    qtl.SBQQ__Quote__c = QuoteList[0].Id;
                    if(qtl.SBQQ__RequiredBy__c != null &&  QLBWithOption.containsKey(qtl.SBQQ__RequiredBy__c)){
                        qtl.SBQQ__RequiredBy__c = QLBWithOption.get(qtl.SBQQ__RequiredBy__c);// Replace the old bundle Id to the Newly created bundle Id
                    }
                    System.debug('SBQQ__RequiredBy__c ==>> '+qtl.SBQQ__RequiredBy__c);
                }
                
                Insert QuoteLineList;
                System.debug('QuoteLineList ==>> '+QuoteLineList);
            }
            
            System.debug('QuoteList[0].Id ==>> '+QuoteList[0].Id);
            return QuoteList[0].Id;
        }
        catch (Exception e) {
            String errorMessage = 'An error occurred while cloning Quote with Related.';
            
            if (e.getMessage() != null) {
                errorMessage = ' Error Message: ' + e.getMessage();
            }
            
            if (e.getCause() != null && e.getCause().getMessage() != null) {
                errorMessage += ' Cause: ' + e.getCause().getMessage();
            }
            
            throw new AuraHandledException(errorMessage);
        }
    }
    
    
}