public without sharing class B2BSplitShipment {

    //This method is used to get deafault values of line items after quick save 
    @AuraEnabled
    public static String getSplitShipmentDefaults(Id cartId){
        try {
            List<SplitShipmentDefaultsQuickSave> lstCartItems = B2BSplitShipment.getSplitShipmentQuickSave(cartId);
            if(lstCartItems.size() > 0){
                return JSON.serialize(lstCartItems);
            }
            else{
                SplitShipmentDefaults defaults = new SplitShipmentDefaults();
                Account effectiveAccount = OrderUtils.getEffectiveAccount(cartId);
                defaults.defaultDeliveryText = effectiveAccount.Default_Delivery_Text__c;
                defaults.defaultLoadVolume = effectiveAccount.Default_Load_Volume__c;
                defaults.defaultPoNumber = effectiveAccount.DefaultPONumber__c;
                defaults.defaultShipmentType = effectiveAccount.Default_Shipment_Type__c;
                
                return JSON.serialize(defaults);
            }
        } catch (Exception e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

   //This method is used to split the shipments 
    @AuraEnabled
    public static void splitShipments(Map<Id, List<CartDeliveryGroup>> productIdToNewDeliveryGroups,Id cartId){
        Map<Id,Id> productIdWithCartItemId = new Map<Id,Id>();
        List<CartItem> lstexistingCartItems = new List<CartItem>(OrderUtils.getCartItemsByCartId(cartId));
        Map<Id, CartItem> existingCartItemsMap = new Map<Id, CartItem>(lstexistingCartItems);    
        for(CartItem item : lstexistingCartItems){
            productIdWithCartItemId.put(item.Product2Id,item.Id);
        }
        Set<Id> productIds = new Set<Id>();
        productIds = productIdToNewDeliveryGroups.keySet(); 
        Map<Id, Product2> productMap = new Map<Id, Product2>(
            OrderUtils.getProductsByIds(
                new List<Id>(productIds)
            )
        );
        List<CartDeliveryGroup> lstCartDeliveryRecords = new List<CartDeliveryGroup>();
        for(Id productId : productIds){
            lstCartDeliveryRecords.addAll(productIdToNewDeliveryGroups.get(productId));
        }
        if(lstCartDeliveryRecords.size() > 0){
            upsert lstCartDeliveryRecords;
        }
        List<CartItem> cartItemsToInsert = new List<CartItem>();
        for(Id productId : productIds){
            CartItem existingCartItem = existingCartItemsMap.get(productIdWithCartItemId.get(productId));
            List<CartDeliveryGroup> deliveryGroups = productIdToNewDeliveryGroups.get(productId);
            if(deliveryGroups != NULL){
                for (CartDeliveryGroup deliveryGroup : deliveryGroups) {
                    CartItem newCartItem = new CartItem();
                    newCartItem.Name = productMap.get(productId).Name;
                    newCartItem.Sku = productMap.get(productId).StockKeepingUnit;
                    newCartItem.Product2Id = productId;
                    newCartItem.Type = 'Product';
                    newCartItem.CartId = cartId;
                    newCartItem.CartDeliveryGroupId = deliveryGroup.Id;
                    newCartItem.Quantity = deliveryGroup.Quantity__c;
                    newCartItem.TotalListPrice = 0;
                    newCartItem.UnitAdjustmentAmount = 0;
                    newCartItem.TotalLineAmount = existingCartItem.SalesPrice;
                    newCartItem.TotalPrice = existingCartItem.SalesPrice;
                    newCartItem.SalesPrice = existingCartItem.SalesPrice;
                    newCartItem.UnitAdjustedPrice = existingCartItem.SalesPrice;
                    cartItemsToInsert.add(newCartItem);
                }
            }
        }
        delete lstexistingCartItems;
        insert cartItemsToInsert; 
        
    }
    //This method is used to save a list of line items in JSON format 
    @AuraEnabled
    public static void quickSaveSplitShipments(Id cartId, String payload) {
        try {
            Map<Id, CartItem> existingCartItemsMap = new Map<Id, CartItem>(OrderUtils.getCartItemsByCartId(cartId));
            String formattedPayload = payload;
            for (Id cartItemId : existingCartItemsMap.keySet()) {
                String idString = '"' + String.valueOf(cartItemId) + '":';
                formattedPayload = formattedPayload.replace(idString, '');
            }
            String payloadReplaced = formattedPayload;
          //  String payloadReplaced = formattedPayload.replace('"Product"', '"CartItemId"');
            formattedPayload = '[' + payloadReplaced.substring(1, payloadReplaced.length() - 1) + ']';
            
            List<ProductDetailQuickSave> parsedProductDetails =
                (List<ProductDetailQuickSave>) JSON.deserialize(formattedPayload,
                                                                List<ProductDetailQuickSave>.class);
            List<CartItem> lstCartItem = new List<CartItem>();
            List<ProductDetailQuickSave> details = parsedProductDetails;
            for (ProductDetailQuickSave detail : details) {
                CartItem objCartItem = new CartItem();
                CartItem existingCartItem = existingCartItemsMap.get(detail.ProductDetail.Product);
                if(existingCartItemsMap.containskey(detail.ProductDetail.Product)){
                    objCartItem.Id = detail.ProductDetail.Product;
                }
                objCartItem.List_Of_Line_Items__c = JSON.serialize(detail);
                lstCartItem.add(objCartItem);
            }
            upsert lstCartItem;	
            WebCart objCart = new WebCart();
            objCart.Id = cartId;
            objCart.Is_Quick_Save__c = true;
            update objCart;   
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }	
    }
    
    /** Get List of Line Item from Cart Item Stored in JSON*/
    @AuraEnabled
    public static List<SplitShipmentDefaultsQuickSave> getSplitShipmentQuickSave(Id cartId) {
        try {
            List<SplitShipmentDefaultsQuickSave> lstCartQuickSave = new List<SplitShipmentDefaultsQuickSave>();
            List<CartItem> existingCartItems =OrderUtils.getCartItemsByCartIdQuickSave(cartId);
            for(CartItem objCartItem : existingCartItems){
                SplitShipmentDefaultsQuickSave objQuickSave = new SplitShipmentDefaultsQuickSave();
                if(objCartItem.List_of_Line_Items__c != NULL){
                    objQuickSave.listofLineItems = objCartItem.List_of_Line_Items__c;
                    lstCartQuickSave.add(objQuickSave);
                }
            }			
            return lstCartQuickSave;
        } catch (Exception e) {
            System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }	
    }
    
    public class SplitShipmentDefaults {
        public String defaultPoNumber { get; set; }
        public String defaultDeliveryText { get; set; }
        public Decimal defaultLoadVolume { get; set; }
        public String defaultShipmentType { get; set; }
    }
    
    // old
    
    public class shipmentData {
        public List<shipmentDataLine> shipmentDataLine;
    }
    
    public class shipmentDataLine {
        public String index;
        public String PurchaseOrder;
        public String RequestedDate;
        public String CartItemId;
        public String Quantity;
        public String DeliveryInstructions;
    }
    
    /* Quick Save */
    public class QuickSaveProductDetails {
        public String Product { get; set; }
        public String CartItemId { get; set; }
        public Datetime startDate { get; set; }
        public Datetime endDate { get; set; }
        public String unitOfMeasure { get; set; }
        public Decimal shippingMode { get; set; }
        public Decimal loadVolume { get; set; }
        public Decimal quantity { get; set; }
        public String poNumber { get; set; }
        public String DeliveryText { get; set; }
        public String shippingType {get; set; }
        public String shippingCondition {get; set;}
        public Boolean isFile { get; set; }
        public String plantCode {get; set;}
        public String productCode {get; set;}
        public Datetime validFrom {get; set;}
        public Datetime validTo {get; set;}       
    }    
    
    public class ProductDetailQuickSave {
        List<QuickSaveShipmentLineItem> listOfLineItem { get; set; }
        public QuickSaveProductDetails ProductDetail { get; set; }
    }
    public class QuickSaveShipmentLineItem {
        public String Product { get; set; }
        public String CartItemId { get; set; }
        public String deliveryDate { get; set; }
        public String deliveryDay { get; set; }
        public Decimal Quantity { get; set; }
        public Decimal Tonnage { get; set; }
        public String DeliveryText { get; set; }
        public String PoNumber { get; set; }
        public Integer index { get; set; }
    }
    public class SplitShipmentDefaultsQuickSave {
        public String listofLineItems { get; set; }		
    }
}