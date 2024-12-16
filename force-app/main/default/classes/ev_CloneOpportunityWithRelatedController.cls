public class ev_CloneOpportunityWithRelatedController {

    // To get the Opp Name to update on the screen
    @AuraEnabled
    public static  List<String> getOpportunityName(String opportunityId) {

      List<String> opportunityDetails = new List<String>();
        
        for (Opportunity opp : [SELECT Id, Name, CurrencyIsoCode, Account.Name,Account.Customer_Region__c 
                                 FROM Opportunity 
                                 WHERE Id = :opportunityId AND Business_Unit__c = 'Carmeuse']) {
            opportunityDetails.add(opp.Account.Name);  
            opportunityDetails.add(opp.CurrencyIsoCode); 
           
        }
        
        return opportunityDetails;
    }
	
	
	// To clone the Opportunity with related Quote and Quote line Items
    @AuraEnabled
    public static String cloneOpportunityWithQuote(String oppId, String opportunityName,string newCurrency) {
        try{
        // Create Opportunity
        system.debug('Currency'+ newCurrency);
        List<Opportunity> OppList = new list<Opportunity>();
        for( Opportunity opp: [Select Id, IsDeleted, AccountId, RecordTypeId, IsPrivate, Name, 
                               Description, StageName, Amount, Probability, ExpectedRevenue, 
                               TotalOpportunityQuantity, CloseDate, Type, NextStep, LeadSource, 
                               IsClosed, IsWon, ForecastCategory, ForecastCategoryName, CurrencyIsoCode, CampaignId, HasOpportunityLineItem, Pricebook2Id,  CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, PushCount, LastStageChangeDate, FiscalQuarter, FiscalYear, Fiscal, ContactId, LastViewedDate, LastReferencedDate, SyncedQuoteId, ContractId, HasOpenActivity, HasOverdueTask, LastAmountChangedHistoryId, LastCloseDateChangedHistoryId, Budget_Confirmed__c, Discovery_Completed__c, ROI_Analysis_Completed__c, SBQQ__AmendedContract__c, Loss_Reason__c, SBQQ__Contracted__c, SBQQ__CreateContractedPrices__c, SBQQ__OrderGroupID__c, SBQQ__Ordered__c, SBQQ__PrimaryQuote__c, SBQQ__QuotePricebookId__c, SBQQ__Renewal__c, SBQQ__RenewedContract__c, sbaa__ApprovalStatus__c, sbaa__ApprovalStep__c, sbaa__Approver__c, sbaa__StepApproved__c, sbaa__SubmittedDate__c, sbaa__SubmittedUser__c, Business_Unit__c, Application_Action_Actual__c, Application_Person__c, Applications_Action_Requested__c, Applications_Review__c, B2B_Opp__c, Bid_Accuracy__c, Bid_Due_Date__c, Bill_To__c, Business_Type__c, Delivery_Date__c, Distributor__c, End_Customer__c, Equipment_Delivery_date__c, Equipment_comissioning_date__c, First_Year_Parts_Included__c, Get_Probability__c, Go_Probability__c, Lead_Notes__c, Margin__c, Market__c, Medium__c, Municipality__c, Notes__c, Opportunity_Type__c, Project_location__c, Plant_start_up_date__c, Product_Hierarchy_Level_1__c, Product_Hierarchy_Level_2__c, Project_Start_Date__c, Proposal_Number__c, Proposal_Stage__c, RFQ_Date__c, Reason_for_needing_the_part__c, Reason_for_no_bid__c, Reason_for_setting_Inactive__c, Reason_for_win_loss__c, STT_Project_Number__c, Scope_Description__c, Sold_to__c, Status_Log__c, Total_Lead_Time_Weeks__c, Warranty_End_Date__c, Warranty_Start_Date__c, Sub_Market__c, Sub_Type__c, Sub_Categories__c, Sales_Representative__c, Year__c, Primary_Contact__c, Campaign_Name__c, Status__c, Owner_Capital_Expenditure__c, Plant_Production__c, Current_Status__c, Sales_Action_Date__c, Overall_Probability__c, Forecast__c, Panic__c, Lead_Type__c, Created__c
                                FROM Opportunity 
                                WHERE Id = :oppId ]){


            Opportunity  oppObj =  opp.clone(false, true);
            oppObj.Name =  opportunityName;   
            oppObj.StageName = 'Qualification'; 
            oppObj.CurrencyIsoCode =  newCurrency;                    
            OppList.add(oppObj);
        }
		system.debug('OppList1==='+OppList);
        if(OppList.size() > 0){
            insert OppList;
            system.debug('OppList2===='+OppList);
        }
            
		//Get related sales competitors
		List<Sales_Competitor__c> SCListClone = new list<Sales_Competitor__c>();
		List<Sales_Competitor__c> SCList =[select Id,Opportunity__c, Amount__c, CO2Cost__c, CarmeuseProductText__c, CommisionUnitPrice__c, CompetitorPrice__c, CompetitorProduct_del__c, Competitor__c, ContractDuration__c, ContractType__c, CurrTonOrTo__c, DiscountUnitPrice__c, Distance__c, FOB__c, FeesUnitPrice__c, Freight_Unit_Price__c, FuelSurcharge__c, OtherCosts__c, PaymentTerms__c, Plant__c, Product_Hierarchy_Level_1__c, Product_Hierarchy_Level_2__c, Product__c, Status__c, Tons__c, TotalTon__c, UOM__c, Product_Name__c, Total_Price__c, Year__c, Address__c, City__c, State__c, Zipcode__c, Country__c, Legacy_Carmeuse_Product_Id__c, Legacy_Competitor_Id__c, Legacy_Plant_Id__c,  Legacy_Name__c, Market__c, Sub_Market__c, Created__c, Sales_Geocoding__Latitude__s, Sales_Geocoding__Longitude__s, Sales_Geocoding__c, Region__c,  Plant_Zipcode_Formula__c, Plant_City__c, Plant_Address__c, Plant_State__c, Account__c, Plant_Zipcode__c, Competitor_Zipcode__c, Plant_Country__c, Currency_Format__c, Lead__c,  Legacy_Competitor_Name__c, Legacy_Plant_Name__c, Legacy_Product_Name__c, Legacy_Product_Code__c,UOM_Distance__c  from Sales_Competitor__c where opportunity__r.Id=:oppId];
       	for( Sales_Competitor__c sc:SCList ){

            Sales_Competitor__c  SCObj =  sc.clone(false, true);
               SCObj.Opportunity__c = OppList[0].Id;            
            SCListClone.add(SCObj);
        }

        if(SCListClone.size() > 0){
            insert SCListClone;
        }	
            
            
            // Get related Quote and Quote line Items
        List<SBQQ__Quote__c> QuoteList = new list<SBQQ__Quote__c>();
		List<SBQQ__QuoteLine__c> QuoteLineList = new list<SBQQ__QuoteLine__c>();
		Map<String, String> QLBWithOption = new Map<String, String>();
        map<String, String> oldIdWithNewIdsMap = new map<String, String>();
		
		Map<Id,SBQQ__QuoteLine__c> BundleMap = new Map<Id,SBQQ__QuoteLine__c>();
		// Additonal__c,Quality_Certification_Free_text_area__c,Safety_Free_text_area__c,
          //  CO2_Contribution_Free_text_area__c,Energy_Surcharge_Free_text_area__c,
          // Transport_Terms_Free_text_area__c,OfferValidity__c,Area_Sales_Manager__c,Discount__c,Rebate__c,
          // Content_of_Text_Box_above_Pricing_Table__c, Content_of_Text_Box_under_Pricing_Table__c
        for( SBQQ__Quote__c quotee: [select Id, Ord_Reason__c, Name, CurrencyIsoCode, SBQQ__Account__c,Sales_Rep_Notes__c, SBQQ__BillingCity__c, SBQQ__BillingCountry__c, SBQQ__BillingFrequency__c, SBQQ__BillingName__c, SBQQ__BillingPostalCode__c, SBQQ__BillingState__c, SBQQ__BillingStreet__c, SBQQ__ConsumptionRateOverride__c, SBQQ__ContractingMethod__c, SBQQ__CustomerDiscount__c, SBQQ__DefaultTemplate__c, SBQQ__DeliveryMethod__c, SBQQ__DistributorDiscount__c, SBQQ__Distributor__c, SBQQ__DocumentStatus__c, SBQQ__EmailTemplateId__c, SBQQ__EndDate__c, SBQQ__FirstSegmentTermEndDate__c, SBQQ__GenerateContractedPrice__c, SBQQ__Introduction__c, SBQQ__Key__c, SBQQ__LastCalculatedOn__c, SBQQ__LastSavedOn__c, SBQQ__LineItemsGrouped__c, SBQQ__LineItemsPrinted__c, SBQQ__MarkupRate__c, SBQQ__MasterContract__c, SBQQ__MasterEvergreenContract__c, SBQQ__Notes__c, SBQQ__Opportunity2__c, SBQQ__OrderByQuoteLineGroup__c, SBQQ__OrderBy__c, SBQQ__OrderGroupID__c, SBQQ__Ordered__c, SBQQ__OriginalQuote__c, SBQQ__PaperSize__c, SBQQ__PartnerDiscount__c, SBQQ__Partner__c, SBQQ__PaymentTerms__c, SBQQ__PriceBook__c, SBQQ__PricebookId__c, SBQQ__PrimaryContact__c, SBQQ__Primary__c, SBQQ__ProrationDayOfMonth__c, SBQQ__QuoteLanguage__c, SBQQ__QuoteProcessId__c, SBQQ__QuoteTemplateId__c, SBQQ__RenewalTerm__c, SBQQ__RenewalUpliftRate__c, SBQQ__SalesRep__c, SBQQ__ShippingCity__c, SBQQ__ShippingCountry__c, SBQQ__ShippingName__c, SBQQ__ShippingPostalCode__c, SBQQ__ShippingState__c, SBQQ__ShippingStreet__c, SBQQ__Source__c, SBQQ__StartDate__c, SBQQ__Status__c, SBQQ__SubscriptionTerm__c, SBQQ__TargetCustomerAmount__c, SBQQ__Type__c, SBQQ__Unopened__c, SBQQ__WatermarkShown__c, SBQQ__LineItemCount__c, SBQQ__AdditionalDiscountAmount__c, SBQQ__AverageCustomerDiscount__c, SBQQ__AveragePartnerDiscount__c, SBQQ__DaysQuoteOpen__c, SBQQ__ExpirationDate__c, SBQQ__TotalCustomerDiscountAmount__c, SBQQ__Uncalculated__c, SBQQ__CustomerAmount__c, SBQQ__ListAmount__c, SBQQ__NetAmount__c, SBQQ__RegularAmount__c, Quote_Description__c, Pricing_date__c, Currency__c, Opportunity_Stage__c, Business_Unit__c, Opportunity_Type__c, Business_Type__c, Valid_From__c, Valid_To__c, Minimum_Tons_Load__c, Destination__c, Show_product_code__c, Show_Plant_Name__c, Show_Quantity__c, Show_Total_Price__c, Show_Final_Price__c, Show_VAT_Excl__c, Show_T_C__c, Guide_lines_for_contract_Haulers__c, UOM__c, CO2_Surcharge__c, Estimated_Total_Quantity__c, Show_STD_Text_Block_1__c, Show_Free_Text_Block_1__c, Transport__c, Free_Text_Box_above_Pricing_Table__c,Content_of_Text_Box_above_Pricing_Table__c, Content_of_Text_Box_under_Pricing_Table__c, Show_STD_Text_Box_3__c, Show_STD_text_Box_4__c, Safety_Data_Sheets_SDS_Link__c, Special_Conditions__c, Free_text_located_under_pricing_table__c, Free_text_box_located_above_signature__c, SE_Shipping_Condition__c, Freight_Request__c, Urgent__c, C3S_Description__c, Receiving_days_and_Hours__c, Address__c, SE_Shipping_Type__c, SE_Est_Total_Quantity__c, SE_Est_Quantity_Del__c, Description_Suply_Chain_Only__c, Primary_rate__c, Per_ton_or_Flat__c, Unloading_Time_silo_truck_hr__c, Unloading_time_Tip_truck__c, Waiting_hours__c, Rate__c, Carrier_Name__c, Min_Ton__c, Secondary_Rate__c, Secondary_Carrier_Name__c, Freight_Ready_Supply_Chain__c, Freight_Approved_Supply__c, Non_discharged_product__c, Emergency_deliveries__c, WE_deliveries_hr__c, WE_deliveries__c, Diesel_Clause__c, Email_orders__c, Energy_Surcharg__c, Tps_D_ch_Cit_hre__c, Tps_D_ch_Benne_hre__c, Hre_Attente_Chantier__c, Prod_Non_D_ch__c, Livr_Urgentes__c, Cde_week_end_hre__c, Cde_week_end__c, Email_Cdes__c, Transport_sacs_table_BE_BE__c, Transport_sacs_table_NL_NL__c, Transport_sacs_table_FR_FR__c, Transports_sacs_table_NL_BE__c, Surcharge_energie__c, Lostijd_silo_wagen_hr__c, Lostijd_kipwagen_hr__c, Wachturen__c, Niet_gelost_produkt__c, Noodleveringen__c, W_E_levering_hr__c, W_E_levering__c, Diesel_clausule__c, Email_bestellingen__c, Energie_toeslag__c, Contact_Phone__c, Contact_Email__c, Sales_Organization__c, Primary_Name__c, Last_Generated_Proposal__c, Special_Instructions__c, Incoterms1__c, Customer_Number__c, Created__c, Payment_Terms__c, Sold_to__c, Ship_to__c, Bill_To__c, Pay_To__c, Market_Value__c, Account_SAP_Id__c, Net_Total__c, EditLinesFieldSetName__c,  Market__c, Sub_Market__c, Billing_Schedule__c, Markup_Custom__c, Impurity__c, Length__c, Width__c, Height__c, Plant_Region__c, Boomi_Error_Code__c, Total_Price__c, Total_Units__c, Volume_Brunt__c, Volume_Crude__c, Lead_Time__c, Quote_Name__c, Win_Probability__c, Go_Probability__c,  Customer_Region__c, Content_of_Show_STD_Text_Block_1__c, Content_of_Show_Free_Text_Block_1__c, Content_of_Show_STD_Text_Box_3__c, Content_of_Show_STD_text_Box_4__c, Content_of_Transport__c, Content_of_Safety_Data_Sheets_SDS_Link__c, Content_of_Special_Conditions__c,  Content_of_Text_Box_above_Signature__c, Transport_Content__c, Show_Transport_on_Doc__c, Form_Header__c, Header_Note_1__c, Invoice_Note__c, Delivery_Instructions__c, Loading_Slip_Instructions__c, Carrier_Instructions__c, Flash_Text__c, Terms_and_Conditions__c, Internal_Text__c, Conversion_Rate__c, Show_Free_Text_Block_1_on_Doc__c, Show_Text_Box_above_Pricing_Table_on_Doc__c, Show_STD_Text_Box_3_on_Doc__c, Show_STD_text_Box_4_on_Doc__c, Show_Safety_Data_Sheets_SDS_Link__c, Show_Special_Conditions_on_Doc__c, Show_Text_Box_under_Pricing_Table_on_Doc__c, Show_Text_Box_above_Signature_on_Doc__c,  Ship_to_Location__c, CO2_French__c, CO2_Dutch__c, CO2_English__c, Table_Transport_bags_NL_NL__c, Table_Transport_bags_BE_BE__c, Table_Transport_bags_NL_BE__c, Table_Transport_bags_FR_FR__c, Tabel_Transport_zakgoed_BE_BE__c, Tabel_Transport_zakgoed_FR_FR__c, Tabel_Transport_zakgoed_NL_NL__c, Tabel_Transport_zakgoed_NL_BE__c,
            Variable_Fuel_Surcharge__c,Customer_Group__c,
              (select Id, Name, CurrencyIsoCode,SBQQ__Quote__c, Line_Type__c,SBQQ__AdditionalDiscountAmount__c, SBQQ__AdditionalQuantity__c, SBQQ__AllowAssetRefund__c, SBQQ__BatchQuantity__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c, SBQQ__BlockPrice__c, SBQQ__Bundle__c, SBQQ__BundledQuantity__c, SBQQ__Bundled__c, SBQQ__CarryoverLine__c, SBQQ__ChargeType__c, SBQQ__ComponentCost__c, SBQQ__ComponentDiscountedByPackage__c, SBQQ__ComponentListTotal__c, SBQQ__ComponentSubscriptionScope__c, SBQQ__ComponentTotal__c, SBQQ__ComponentUpliftedByPackage__c, SBQQ__CompoundDiscountRate__c, SBQQ__ConfigurationRequired__c, SBQQ__ContractedPrice__c, SBQQ__CostEditable__c, SBQQ__Cost__c, SBQQ__CustomerPrice__c, SBQQ__DefaultSubscriptionTerm__c, SBQQ__Description__c, SBQQ__Dimension__c, SBQQ__DiscountScheduleType__c, SBQQ__DiscountSchedule__c, SBQQ__DiscountTier__c, SBQQ__Discount__c, SBQQ__DistributorDiscount__c, SBQQ__DynamicOptionId__c, SBQQ__EarliestValidAmendmentStartDate__c, SBQQ__EndDate__c, SBQQ__Existing__c, SBQQ__Favorite__c, SBQQ__GenerateContractedPrice__c, SBQQ__GrossProfit__c, SBQQ__Group__c, SBQQ__Guidance__c, SBQQ__HasConsumptionSchedule__c, SBQQ__Hidden__c, SBQQ__Incomplete__c, SBQQ__ListPrice__c, SBQQ__MarkupAmount__c, SBQQ__MarkupRate__c, SBQQ__MaximumPrice__c, SBQQ__MinimumPrice__c, SBQQ__NetPrice__c, SBQQ__NonDiscountable__c, SBQQ__NonPartnerDiscountable__c, SBQQ__Number__c, SBQQ__OptionDiscountAmount__c, SBQQ__OptionDiscount__c, SBQQ__OptionLevel__c, SBQQ__OptionType__c, SBQQ__Optional__c, SBQQ__OriginalPrice__c, SBQQ__OriginalQuoteLineId__c, SBQQ__OriginalUnitCost__c, SBQQ__PackageProductCode__c, SBQQ__PackageProductDescription__c, SBQQ__PartnerDiscount__c, SBQQ__PartnerPrice__c, SBQQ__PreviousSegmentPrice__c, SBQQ__PreviousSegmentUplift__c, SBQQ__PriceEditable__c, SBQQ__PricebookEntryId__c, SBQQ__PricingMethodEditable__c, SBQQ__PricingMethod__c, SBQQ__PriorQuantity__c, SBQQ__ProductOption__c, SBQQ__ProductSubscriptionType__c, SBQQ__Product__c, SBQQ__ProrateMultiplier__c, SBQQ__ProratedListPrice__c, SBQQ__ProratedPrice__c, SBQQ__Quantity__c, SBQQ__RegularPrice__c, SBQQ__Renewal__c, SBQQ__RenewedAsset__c, SBQQ__RenewedSubscription__c, SBQQ__RequiredBy__c, SBQQ__SegmentIndex__c, SBQQ__SegmentKey__c, SBQQ__SegmentLabel__c, SBQQ__Source__c, SBQQ__SpecialPriceDescription__c, SBQQ__SpecialPriceType__c, SBQQ__SpecialPrice__c, SBQQ__StartDate__c, SBQQ__SubscribedAssetIds__c, SBQQ__SubscriptionBase__c, SBQQ__SubscriptionCategory__c, SBQQ__SubscriptionPercent__c, SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionScope__c, SBQQ__SubscriptionTargetPrice__c, SBQQ__SubscriptionTerm__c, SBQQ__TaxCode__c, SBQQ__Taxable__c, SBQQ__TermDiscountSchedule__c, SBQQ__TermDiscountTier__c, SBQQ__TermDiscount__c, SBQQ__UnitCost__c, SBQQ__UnproratedNetPrice__c, SBQQ__UpgradedAsset__c, SBQQ__UpgradedQuantity__c, SBQQ__UpgradedSubscription__c, SBQQ__UpliftAmount__c, SBQQ__Uplift__c, SBQQ__VolumeDiscount__c, SBQQ__AdditionalDiscount__c, SBQQ__ComponentVisibility__c, SBQQ__CustomerTotal__c, SBQQ__EffectiveEndDate__c, SBQQ__EffectiveQuantity__c, SBQQ__EffectiveStartDate__c, SBQQ__EffectiveSubscriptionTerm__c, SBQQ__ListTotal__c, SBQQ__Markup__c, SBQQ__NetTotal__c, SBQQ__PackageCost__c, SBQQ__PackageListTotal__c, SBQQ__PackageTotal__c, SBQQ__PartnerTotal__c, SBQQ__ProductCode__c, SBQQ__ProductFamily__c, SBQQ__ProductName__c, SBQQ__RegularTotal__c, SBQQ__SubscriptionType__c, SBQQ__TotalDiscountAmount__c, SBQQ__TotalDiscountRate__c, ZAD__c, ZADN__c, ZAST__c, ZCO2__c, ZCPF__c, ZCPR__c, ZCWE__c, ZDAJ__c, ZDFR__c, ZDIS__c, ZDPR__c, ZF01__c, ZF1__c, ZF11__c, ZF16__c, ZF2__c, ZF22__c, ZF3__c, ZF31__c, ZF4__c, ZF6__c, ZF7__c, ZF9__c, ZLRT__c, ZMF2__c, ZMF6__c, ZMF7__c, ZMFS__c, ZMIS__c, ZPCT__c, ZPLT__c, ZPRO__c, ZRC__c, ZREB__c, ZRLC__c, ZRMI__c, ZSFF__c, ZSFT__c, ZSPA__c, ZSRM__c, ZSRT__c, ZSTF__c, ZSTT__c, ZSVF__c, ZVFS__c, Basic_Text__c, Sales_Text__c, Output_description__c, Customer_Text__c, Brand_Text__c, Custom_description__c, Distance__c, Product_Price__c, UOM__c, PC_Discount__c, Fees_Price__c, Freight_Price__c, Misc_Price__c, Surcharge__c, Commission__c, Sylo_Type__c, Location_Code__c, Feed_Control_Device__c, Slaker_Type__c, Mix_Tank_Type__c, Plant__c, Sales_Organization__c, Product_Family__c, List_Unit_Price__c, Custom_Text__c, Total_Price__c, Default_UOM__c, Plant2__c, Length__c, Width__c, Height__c, Estimated_Qty_Delivery__c, Sub_Total__c, Primary__c, Picklist__c, Types_of_Systems__c, Other_Systems_Type__c, Other_Feed_Control_Device__c, System_Type__c, Cost_of_Goods__c, Dry_Feed_Rate__c, Wet_Storage__c,   Status_Code_of_QuoteLine__c, Error_description__c,   Dry_Storage__c, Category__c, ZAD_Option__c, ZADN_Option__c, ZAST_Option__c, ZCO2_Option__c, ZCPR_Option__c, ZF1_Option__c, ZF13_Option__c, ZF16_Option__c, ZF2_Option__c, ZF22_Option__c, ZF3_Option__c, ZMIS_Option__c, ZSRT_Option__c, ZSTF_Option__c, ZSTT_Option__c, ZSVF_Option__c, Freight_Per_Unit__c, Total_Freight__c, Conversion_Rate__c, test__c, Quote_Additional_Disc__c, Business_Unit__c, Pricing_Approved_Status__c, Mark_Up__c,Output_Text__c,ZF4_Option__c, ZSFT_Option__c, ZMF2_Option__c, ZREB_Option__c, ZSPA_Option__c, ZRMI_Option__c, ZDIS_Option__c, ZRLC_Option__c, ZMF7_Option__c, ZCWE_Option__c, ZPCT_Option__c, ZSRM_Option__c, ZCPF_Option__c, ZDPR_Option__c, ZF9_Option__c, ZPLT_Option__c, ZMF6_Option__c, ZPRO_Option__c, ZF11_Option__c, ZVFS_Option__c, ZLRT_Option__c, ZDAJ_Option__c, ZRC_Option__c, ZSFF_Option__c, ZF7_Option__c, ZF6_Option__c, ZF31_Option__c, ZDFR_Option__c, ZF01_Option__c, ZMFS_Option__c, Tax_Area_Code__c,EXCH_RATE_Updated__c,Mark_Up_Updated__c,Freight_Per_Unit_Updated__c,Cost_Of_Goods_Updated__c,COG_Currency__c
             ,Composition__c,Miles__c,Plant_Text__c,Product_Type__c,Requested_Delivery_Date__c,Requested_Delivery_Date1__c,Size__c,Unit_Price__c,ZF5__c,ZF5_Option__c,ZMF1__c,ZMF1_Option__c,Surcharge_variable__c,UOM_Distance__c,SE_Shipping_Type__c,MIN_LOAD_SIZE__c
              ,Destination__c,Shipping_Condition__c,Incoterms__c,Ship_To__c,Sold_to__c
             FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = : oppId AND SBQQ__Primary__c = TRUE]){

            SBQQ__Quote__c  quoteObj =  quotee.clone(false, true);     
            quoteObj.SBQQ__Opportunity2__c = OppList[0].Id;  
            quoteObj.SBQQ__Status__c = 'Draft';
            quoteObj.Cloned_From_Quote__c =quotee.Name;
            quoteObj.CurrencyIsoCode = newCurrency;
            QuoteList.add(quoteObj);
			
			for(SBQQ__QuoteLine__c QL : quotee.SBQQ__LineItems__r){
				SBQQ__QuoteLine__c  quoteLIneObj =  QL.clone(false, true);
                quoteLIneObj.CurrencyIsoCode =newCurrency;
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

        System.debug('OppList[0].Id ==>> '+OppList[0].Id);
        return OppList[0].Id;
    }
        catch (Exception e) {
         String errorMessage = 'An error occurred while cloning Opportunity with Related.';

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