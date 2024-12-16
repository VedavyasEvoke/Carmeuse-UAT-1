public without sharing class OrderUtils {
	//This method return orderId.
	public static Id getOrderIdByCartId(Id cartId) {
		return [
				SELECT OrderId
				FROM CartCheckoutSession
				WHERE WebCartId = :cartId
				AND IsArchived = false
		].OrderId;
	}
	//This method return orderId.
	public static List<Id> getOrderIdsByCartIds(List<Id> cartIds) {
		List<CartCheckoutSession> sessions = [
				SELECT OrderId
				FROM CartCheckoutSession
				WHERE WebCartId IN :cartIds
				AND IsArchived = false
		];
		List<Id> orderIds = new List<Id>();
		for (CartCheckoutSession session : sessions) {
			orderIds.add(session.OrderId);
		}
		return orderIds;
	}

	public static Map<Id, OrderDeliveryGroupSummary> getOrderDeliveryGroupSummaryMapByOrderDeliveryGroupId(List<OrderDeliveryGroupSummary> odgs) {
		Map<Id, OrderDeliveryGroupSummary> orderDeliveryGroupSummaryMapByOrderDeliveryGroupId = new Map<Id, OrderDeliveryGroupSummary>();

		for (OrderDeliveryGroupSummary ogds : odgs) {
			orderDeliveryGroupSummaryMapByOrderDeliveryGroupId.put(ogds.OriginalOrderDeliveryGroupId, ogds);
		}

		return orderDeliveryGroupSummaryMapByOrderDeliveryGroupId;
	}
	// Return map of order id and cart id
	public static Map<Id, Id> getOrderIdToCartIdMap(List<Id> cartIds) {
		List<CartCheckoutSession> sessions = [
				SELECT OrderId, WebCartId
				FROM CartCheckoutSession
				WHERE WebCartId IN :cartIds
				AND IsArchived = false
		];

		Map<Id, Id> orderIdsToCartIds = new Map<Id, Id>();
		for (CartCheckoutSession session : sessions) {
			orderIdsToCartIds.put(session.OrderId, session.WebCartId);
		}

		return orderIdsToCartIds;
	}
	// Returns all standard fields of order delivery groups. 
	public static List<OrderDeliveryGroup> getRelatedOrderDeliveryGroupsByCartId(Id cartId) {
		Id orderId = getOrderIdByCartId(cartId);

		return [
				SELECT FIELDS(STANDARD)
				FROM OrderDeliveryGroup
				WHERE OrderId = :orderId
		];
	}
	// Returns all standard fields of order delivery groups, ordered by desired delivery date. 
	public static List<OrderDeliveryGroup> getRelatedOrderDeliveryGroupsByCartIds(List<Id> cartIds) {
		List<Id> orderIds = getOrderIdsByCartIds(cartIds);
		return [
				SELECT FIELDS(STANDARD)
				FROM OrderDeliveryGroup
				WHERE OrderId IN :orderIds ORDER BY DesiredDeliveryDate ASC
		];
	}
	// Returns all standard fields of order delivery group summary. 
	public static List<OrderDeliveryGroupSummary> getRelatedOrderDeliveryGroupSummariesByCartId(Id cartId) {
		Id orderId = getOrderIdByCartId(cartId);

		return [
				SELECT FIELDS(STANDARD), OriginalOrderDeliveryGroup.OrderId
				FROM OrderDeliveryGroupSummary
				WHERE OrderSummary.OriginalOrderId = :orderId
		];
	}
	// Returns all standard fields of order delivery group summaries, ordered by desired delivery date. 
	public static List<OrderDeliveryGroupSummary> getOrderDeliveryGroupSummariesByOrderIds(List<Id> orderIds) {
		return [
				SELECT FIELDS(STANDARD), OriginalOrderDeliveryGroup.OrderId
				FROM OrderDeliveryGroupSummary
				WHERE OrderSummary.OriginalOrderId IN :orderIds ORDER BY DesiredDeliveryDate ASC
		];
	}
	// Returns order delivery groups, ordered by desired delivery date. 
	public static List<OrderDeliveryGroup> getOrderDeliveryGroupsByOrderIds(List<Id> orderIds) {
		return [
				SELECT DesiredDeliveryDate,DeliveryInstructions,DeliverToStreet,DeliverToCity,DeliverToState,DeliverToPostalCode,DeliverToCountry,AccountExternalNumber__c, MaterialNumber__c, ShipmentSize__c, ShipmentStatus__c,
				ShipmentSizeType__c, Quantity__c, ShipmentTonnage__c, QuoteNumber__c, SplitShipmentId__c, PONumber__c,
						IsHold__c, OriginalMaterialNumber__c, AccessCode__c,ShipmentWeight__c,ShipmentDateTime__c,BOLNumber__c,
            			Cancel_Requested_On__c,Cancel_Requested_By__c,Canceled_On__c,Canceled_By__c,Released_On__c,Released_By__c,Next_Day_Order__c,Material_Number_SF__c
				FROM OrderDeliveryGroup
				WHERE OrderId IN :orderIds ORDER BY DesiredDeliveryDate ASC
		];
	}
	// Returns all standard fields of order delivery group summary.
	public static List<OrderDeliveryGroupSummary> getRelatedOrderDeliveryGroupSummariesByCartIds(List<Id> cartIds) {
		List<Id> orderIds = getOrderIdsByCartIds(cartIds);

		return [
				SELECT FIELDS(STANDARD), OriginalOrderDeliveryGroup.OrderId
				FROM OrderDeliveryGroupSummary
				WHERE OrderSummary.OriginalOrderId IN :orderIds
		];
	}
	// This method returns list of cart delivery group. 
	public static List<CartDeliveryGroup> getCartDeliveryGroupsByCartId(Id cartId) {
		return [
				SELECT FIELDS(STANDARD), MaterialNumber__c, AccountExternalNumber__c,
						ShipmentSizeType__c, Shipment_Size__c, ShipmentTonnage__c,
						Quantity__c, Quote_Number__c, SplitShipmentId__c, PONumber__c,
						IsHold__c, DeliveryText__c, BillingAddress__c, ShippingAddress__c
				FROM CartDeliveryGroup
				WHERE CartId = :cartId
				LIMIT 1
		];
	}
	// Returns cart delivery groups, ordered by desired delivery date. 
	public static List<CartDeliveryGroup> getCartDeliveryGroupsByCartIds(List<Id> cartIds) {
		return [
            SELECT MaterialNumber__c,AccountExternalNumber__c,ShipmentSizeType__c,Shipment_Size__c,ShipmentTonnage__c,
            Quantity__c, Quote_Number__c,SplitShipmentId__c,PONumber__c,IsHold__c,DeliveryText__c,BillingAddress__c,
            ShippingAddress__c,Next_Day_Order__c,Id,IsDeleted,Name,CreatedDate,CreatedById,LastModifiedDate,LastModifiedById,SystemModstamp,
            CartId,DeliveryMethodId,DesiredDeliveryDate,ShippingInstructions,DeliverToName,DeliverToStreet,DeliverToCity,
            DeliverToState,DeliverToPostalCode,DeliverToCountry,DeliverToLatitude,DeliverToLongitude,DeliverToGeocodeAccuracy,DeliverToAddress,Material_Number_SF__c FROM CartDeliveryGroup
            WHERE CartId IN :cartIds ORDER BY DesiredDeliveryDate ASC
		];
	}
	// Returns list of all cart item related to cart.
	public static List<CartItem> getCartItemsByCartId(Id cartId) {
		return [
				SELECT FIELDS(STANDARD)
				FROM CartItem
				WHERE CartId = :cartId
		];
	}
	// This method returns list of product. 
	public static List<Product2> getProductsByIds(List<Id> productIds) {
		return [
				SELECT FIELDS(STANDARD), MaterialNumber__c, Shipping_Condition__c
				FROM Product2
				WHERE Id IN :productIds
		];
	}
	// Returns list of price book entries.
	public static List<PricebookEntry> getPricebookEntriesByProductIdsAndAccount(set<Id> productIds, set<Id> pricebookIds) {
		
		
		return [
				SELECT FIELDS(STANDARD), Quote_Number__c, ValidFrom__c, ValidTo__c
				FROM PricebookEntry
				WHERE Product2Id IN :productIds
				AND Pricebook2Id IN :pricebookIds
				AND IsActive = TRUE
		];
	}

	// Returns set of prie book ids related to account.
	public static set<Id> getPricebookIds(Id  accountId) {

		set<Id> buyerGroupIds = new set<Id>();
	
		for(BuyerGroupMember rec :  [SELECT BuyerGroupId FROM BuyerGroupMember WHERE BuyerId = :accountId] ){
			buyerGroupIds.add(rec.BuyerGroupId);
		}

		List <BuyerGroupPricebook>  buyerPriceBooks = [SELECT Pricebook2Id FROM BuyerGroupPricebook WHERE BuyerGroupId IN :buyerGroupIds AND IsActive = TRUE];

		set<Id> pricebookIds  = new set<Id>();
		for(BuyerGroupPricebook rec :  buyerPriceBooks ){
			pricebookIds.add(rec.Pricebook2Id);
		}
				
		return pricebookIds;
	}

	// This method returns the contact data.
	public static Contact getLoggedInCommunityUserContact() {


		Id contactId = [
				SELECT Id, ContactId
				FROM User
				WHERE Id = :UserInfo.getUserId()
				LIMIT 1
		].ContactId;

		return [
				SELECT FIELDS(STANDARD), Account.AccountExternalNumber__c, Account.IsHold__c,
					Account.Default_Delivery_Text__c, Account.Default_Load_Volume__c, 
					Account.DefaultPONumber__c, Account.Default_Shipment_Type__c, Account.Name
				FROM Contact
				WHERE Id = :contactId
		];

	}
	// Returns account releated to the cart.
	public static Account getEffectiveAccount(Id cartId) {


		Id accountId = [
				SELECT AccountId
				FROM WebCart
				WHERE Id = :cartId
				LIMIT 1
		].AccountId;

		return [
				SELECT Id, AccountExternalNumber__c,IsHold__c,
					Default_Delivery_Text__c, Default_Load_Volume__c, 
					DefaultPONumber__c, Default_Shipment_Type__c, Name
				FROM Account
				WHERE Id = :accountId
		];

	}

	// This method returns the list of orders related to the account.
	public static List<Order> getOrdersByAccountId(Id accountId) {
		return [
				SELECT Id, OrderNumber, Account.Name, Status, OrderedDate
				FROM Order
				WHERE AccountId = :accountId
		];
	}
	// This method returns list of order summary related to order.
	public static List<OrderSummary> getOrderSummaryById(Id orderId ) {
		return [
				SELECT AccountId, Account.Name, BillingAddress,BillingCity,BillingCountry,BillingEmailAddress,
				BillingPostalCode,BillingState,BillingStreet, Description,GrandTotalAmount,
				Id,OrderedDate,OrderNumber,OriginalOrderId,PoNumber,Status,TotalAmount,IsHold__c,OwnerId,Account.AccountExternalNumber__c
				FROM OrderSummary
				where Id = :orderId				
				order by OrderedDate DESC
		];
	}
	// Returns list of order with activated status.
	public static List<Order> getExternalActivatedOrders(Set<Id> orderIds) {
		return [
			SELECT Id, External__c
			FROM Order
			where Id IN :orderIds
			AND External__c = true
			AND Status = 'Activated'
		];
	}
	// This method returns list of order summary.
	public static List<OrderSummary> getOrderSummaryByOriginalOrderId(List<Id> originalOrderIds ) {
		return [
				SELECT AccountId, Account.Name, BillingAddress,BillingCity,BillingCountry,BillingEmailAddress,
				BillingPostalCode,BillingState,BillingStreet, Description,GrandTotalAmount,
				Id,OrderedDate,OrderNumber,OriginalOrderId,PoNumber,Status,TotalAmount,IsHold__c 
				FROM OrderSummary
				where OriginalOrderId IN :originalOrderIds				
				order by OrderedDate DESC
		];
	}
	// Returns list of order item summary.
	public static List<OrderItemSummary> getOrderItemSummaryByOrderSummaryId(Id orderSummaryId ) {
		return [
			SELECT Id,Name,OrderDeliveryGroupSummaryId,OrderSummaryId,OriginalOrderItemId,Product2Id,Product2.Name,
			Product2.MaterialNumber__c,
			ProductCode,Quantity,Status,StockKeepingUnit,TotalLineAmount 
			FROM OrderItemSummary
			Where OrderSummaryId = :orderSummaryId
		];
	}
	// This method returns list of order delivery group summary.
	public static List<OrderDeliveryGroupSummary> getOrderDeliveryGroupSummaryByOrderSummaryId(Id orderSummaryId ) {
		return [
			SELECT AccountExternalNumber__c,BOLNumber__c,DeliverToAddress,DeliverToCity,DeliverToCountry,DeliverToName,DeliverToPostalCode,AccessCode__c,
			DeliverToState,DeliverToStreet,DeliveryInstructions,Description,DesiredDeliveryDate,Id,MaterialNumber__c,OriginalMaterialNumber__c,
			OrderDeliveryGroupSummaryNumber,OrderDeliveryMethodId,OrderSummaryId,OriginalOrderDeliveryGroupId,PONumber__c,Quantity__c,
			QuoteNumber__c,ShipmentDateTime__c,ShipmentSizeType__c,Shipment_Size_Type_Label__c,ShipmentSize__c,ShipmentTonnage__c,ShipmentWeight__c,ShipmentStatus__c,
			Cancel_Requested_On__c, Cancel_Requested_By__r.FirstName, Canceled_On__c, Canceled_By__r.FirstName, IsHold__c, Released_On__c, Released_By__r.FirstName,Material_Number_SF__c
			FROM OrderDeliveryGroupSummary
			Where OrderSummaryId = :orderSummaryId
			order by MaterialNumber__c, DesiredDeliveryDate 
		];
	}

	// This method returns list of order.
	public static List<Order> getOrderById(Id orderId ) {
		return [
				SELECT AccountId, Account.Name, BillingAddress,BillingCity,BillingCountry,BillingEmailAddress,
				BillingPostalCode,BillingState,BillingStreet, Description,GrandTotalAmount,
				Id,OrderedDate,OrderNumber,PoNumber,Status,TotalAmount
				FROM Order
				where Id = :orderId				
				order by OrderedDate DESC
		];
	}
	// This method return the list of order item.
	public static List<OrderItem> getOrderItemByOrderId(Id orderId ) {
		return [
			SELECT Id,OrderDeliveryGroupId,OrderId,Product2Id,Product2.Name,
			Product2.MaterialNumber__c,
			Product2.ProductCode,Quantity,TotalLineAmount 
			FROM OrderItem
			Where OrderId = :orderId
		];
	}
	// Returns list of order delivery groups.
	public static List<OrderDeliveryGroup> getOrderDeliveryGroupByOrderId(Id orderId ) {
		return [
			SELECT AccountExternalNumber__c,BOLNumber__c,DeliverToAddress,DeliverToCity,DeliverToCountry,DeliverToName,DeliverToPostalCode,AccessCode__c,
			DeliverToState,DeliverToStreet,DeliveryInstructions,Description,DesiredDeliveryDate,Id,MaterialNumber__c,OriginalMaterialNumber__c,
			OrderDeliveryGroupNumber,OrderDeliveryMethodId,OrderId,PONumber__c,Quantity__c,
			QuoteNumber__c,ShipmentDateTime__c,ShipmentSizeType__c,ShipmentSize__c,ShipmentTonnage__c,ShipmentWeight__c,ShipmentStatus__c,
			Cancel_Requested_On__c, Cancel_Requested_By__r.FirstName, Canceled_On__c, Canceled_By__r.FirstName, IsHold__c, Released_On__c, Released_By__r.FirstName
			FROM OrderDeliveryGroup
			Where OrderId = :orderId
			order by MaterialNumber__c, DesiredDeliveryDate 
		];
	}
	// It is used to show the survey after placing three orders, it reutrns integer.
	@AuraEnabled
	public static Integer shouldUserSeeSurveyPopup(String accountId) {		
        Integer remainder = 1;
        Integer numOrders = [SELECT Count() FROM Order WHERE AccountId =: accountId];
		if(numOrders > 0){
			remainder = math.mod(numOrders, 3);
		}else{
			remainder = 1;
		}
		return remainder;
	}
	// This method returns SurveyInvitation link.
	@AuraEnabled
	public static String getSurveyInvitationLink(){
		String link = '';
		List<Survey> lstSurvey = [SELECT Id FROM Survey WHERE Name = 'MyCarmeuse experience protal' LIMIT 1];
		Id surveyId = lstSurvey[0].Id;
		List<SurveyInvitation> lstSurveyInvitation = [SELECT id,Name,InvitationLink,SurveyId from SurveyInvitation WHERE SurveyId =: surveyId];
		link = lstSurveyInvitation[0].InvitationLink;
		return link;
	}
	// This method returns list product.
	@AuraEnabled(cacheable=true)
    public static List<Product2> getProductById(String productId) {
        return [SELECT Id, Shipping_Condition_Label__c, Shipment_Size_Type_Label__c, Ship__c,MaterialNumber__c,Shipping_Condition__c,Name,ProductCode,Plant_code__c,Valid_From__c,Valid_To__c,Carrier__c
				FROM Product2
				WHERE Id=:productId LIMIT 1];
    }
	// Return list of cart items related to cart.
	public static List<CartItem> getCartItemsByCartIdQuickSave(Id cartId) {
		return [
				SELECT List_Of_Line_Items__c
				FROM CartItem
				WHERE CartId = :cartId
		];
	}
	// This method returns list of price book entry.
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getPriceBookEntry(String cardId) { 
        Id accountId;
        List<Account> lstAccount = new List<Account>();
        List<WebCart> WebCart = [SELECT Id,AccountId FROM WebCart WHERE Id=:cardId LIMIT 1];
        if(WebCart.size() > 0){
            accountId = WebCart[0].AccountId;
        }
  		set<Id> pricebookIds = OrderUtils.getPricebookIds(accountId);
        List<PricebookEntry> pricebookEntries = [SELECT Id, Quote_Number__c, ValidFrom__c, ValidTo__c,Product2Id FROM PricebookEntry WHERE Pricebook2Id IN :pricebookIds AND IsActive = TRUE];
        return pricebookEntries;
    }     
	// This  method  returs account and product related data.
    @AuraEnabled
    public static Map<String,List<sObject>> getAccountAndProductData(String cardId) { 
        Map<String,List<sObject>> requiredData = new Map<String,List<sObject>>();
		String accountId;
        List<Account> lstAccount = new List<Account>();
        List<WebCart> WebCart = [SELECT Id,AccountId FROM WebCart WHERE Id=:cardId LIMIT 1];
        if(WebCart.size() > 0){
            accountId = WebCart[0].AccountId;
        }
        lstAccount = [SELECT IsHold__c,AccountExternalNumber__c,Name, Business_Unit__c, B2B_Business_Sub_Unit__c FROM Account WHERE Id=: accountId LIMIT 1 ];
		requiredData.put('Account',lstAccount);
        List<Product2> lstProduct2 = new List<Product2>();
        Set<Id> pdoductIds = new Set<Id>();
        List<CartItem> lstCartItem = [SELECT Id,Product2Id FROM CartItem WHERE CartId=:cardId];
        if(lstCartItem.size() > 0){
             for (CartItem item : lstCartItem) {
                 pdoductIds.add(item.Product2Id);
             }
        }
        lstProduct2 = [SELECT Id, Shipping_Condition_Label__c, Shipment_Size_Type_Label__c,Ship__c,MaterialNumber__c,Shipping_Condition__c,Name
				FROM Product2
				WHERE Id IN : pdoductIds];  
        requiredData.put('Product',lstProduct2);
        return requiredData;
    }
	// Returns the default delivery cart, order delivery and contact point addresess.
    @AuraEnabled(cacheable=true)
    public static Map<String,Id> getDefaultId(String cardId) { 
        String accountId;
        Map<String,Id> mapOfDefaultData = new Map<String,Id>();
        CartDeliveryGroup defaultCartDeliveryGroup = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cardId
                                                      LIMIT 1
                                                     ];
        if(defaultCartDeliveryGroup != NULL){
            mapOfDefaultData.put('CartDeliveryGroup',defaultCartDeliveryGroup.Id);
        }
        OrderDeliveryMethod defaultDeliveryMethod = [SELECT Id FROM OrderDeliveryMethod WHERE IsActive = true LIMIT 1];
        if(defaultDeliveryMethod != NULL){
            mapOfDefaultData.put('OrderDeliveryMethod',defaultDeliveryMethod.Id);
        }
        List<Account> lstAccount = new List<Account>();
        List<WebCart> WebCart = [SELECT Id,AccountId FROM WebCart WHERE Id=:cardId LIMIT 1];
        if(WebCart.size() > 0){
            accountId = WebCart[0].AccountId;
        }
        List<ContactPointAddress> relatedAddresses = [
            SELECT Id, Address, AddressType
            FROM ContactPointAddress
            WHERE ParentId = :accountId
            AND IsDefault = true
        ];
        for (ContactPointAddress add : relatedAddresses) {
            if(add.AddressType == 'Billing') {
                mapOfDefaultData.put('Billing',add.Id);
            }
            else if (add.AddressType == 'Shipping') {
                mapOfDefaultData.put('Shipping',add.Id);
            }
        }
        return mapOfDefaultData;
    } 
	// This method return timezone of organization.
	@AuraEnabled(cacheable=true)
    public static Map<String,String> OrganizationDetail() { 
        Map<String,String> mapOfOrgDetails = new Map<String,String>();
        Organization org = [SELECT Id, TimeZoneSidKey,DefaultLocaleSidKey FROM Organization];
        if(org != NULL){
            mapOfOrgDetails.put('TimeZoneSidKey',org.TimeZoneSidKey);
        }       
        return mapOfOrgDetails;
    } 
    // This methods return the cart is quick saved or not.
    @AuraEnabled
    public static Boolean isCartQuickSave(Id cartId){
            Boolean isQuickSave = false;
            try {
                if(cartId != null) {
                        WebCart cart = [SELECT Id,Is_Quick_Save__c FROM WebCart WHERE Id = :cartId LIMIT 1];
                        isQuickSave = cart.Is_Quick_Save__c;
                }                
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
            return isQuickSave;
    }   
    
	// Returns list of order summary.
    @AuraEnabled
    public static List<OrderSummary> getOrderDetailsById(Id orderId ) {
        return [
            SELECT  Id,Owner.Name,Account.Name,OrderNumber,OrderedDate,Status,OriginalOrderId
            FROM OrderSummary
            WHERE Id = :orderId
        ];
    }
    // This method is used to show the cancel button by checking the shipment status.
    @AuraEnabled
    public static boolean cancelAllButton(Id orderId){
        boolean status = false;
        for(OrderDeliveryGroupSummary ODGObj : [SELECT Id, ShipmentStatus__c, OrderSummaryId FROM OrderDeliveryGroupSummary WHERE OrderSummaryId =: orderId]){
            if(ODGObj.ShipmentStatus__c == 'Pending' || ODGObj.ShipmentStatus__c == 'Shipped' || ODGObj.ShipmentStatus__c == 'Submitted' ||  ODGObj.ShipmentStatus__c == 'Confirmed'){
                status = true;
            }
        }
        return status;
    }
    //Returns list of order delivery groups related to order.
    @AuraEnabled
    public static List<OrderDeliveryGroup> getOrderDeliveryGroupByOrderIdLWC(Id orderId){
        OrderSummary objOrderSummary = [SELECT Id,OriginalOrderId FROM OrderSummary WHERE Id = :orderId LIMIT 1];
        List<OrderDeliveryGroup> lstOrderDeliveryGroup = new List<OrderDeliveryGroup>();
        if(objOrderSummary.OriginalOrderId != NULL){
             lstOrderDeliveryGroup = OrderUtils.getOrderDeliveryGroupByOrderId(objOrderSummary.OriginalOrderId);
        }       
        return lstOrderDeliveryGroup;
    }
   // Returns the product assigned to entitlment policy.		
   @AuraEnabled
    public static Map<String,Integer> getProductsAssignToEP(String accountName){
        try {           
            Set<Id> setEPIds = new Set<Id>();
            List<CommerceEntitlementProduct> lstEPPP = new List<CommerceEntitlementProduct>();
            Map<String,Integer> productCodeWithCounts = new Map<String,Integer>();
            if(accountName != NULL){
                for(CommerceEntitlementPolicy objEP : [SELECT Id, Name, IsActive, Account__c FROM CommerceEntitlementPolicy WHERE Account__c =: accountName]){
                    setEPIds.add(objEP.Id);
                }
            }
            if(!setEPIds.isEmpty()){
                for(CommerceEntitlementProduct objEPProduct : [SELECT Id, Name, PolicyId, ProductId,Product.ProductCode,Product.Plant_code__c FROM CommerceEntitlementProduct WHERE PolicyId IN : setEPIds]){
                    String productCodePlantCode = objEPProduct.Product.ProductCode + objEPProduct.Product.Plant_code__c;
                    if(productCodeWithCounts.containsKey(productCodePlantCode)){
                        Integer count = productCodeWithCounts.get(productCodePlantCode);
                        count = count + 1;
                        productCodeWithCounts.put(productCodePlantCode,count);
                    }else{
                        productCodeWithCounts.put(productCodePlantCode, 1);
                    }
                }
            }
            return productCodeWithCounts;            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }   
	// Check which pemrmission assigned to the user.
	@AuraEnabled
    public static Boolean getPermissionAssignedToUser(Id userId){
        Boolean showNotification = false;   
        try {
            if(userId != null) {
                PermissionSetAssignment lstPermissionSetAssignment = [SELECT  AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Carrier_field_visibility_for_Milled_Lime_Stone_customers' AND AssigneeId  =: userId];
                if(lstPermissionSetAssignment != null){
                    showNotification = true;
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return showNotification;
    }
}