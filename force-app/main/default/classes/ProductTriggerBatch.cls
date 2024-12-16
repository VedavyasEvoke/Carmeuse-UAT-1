global class ProductTriggerBatch implements Database.Batchable<sObject> {
    global List<Product2> productList = new List<Product2>();

    global ProductTriggerBatch(List<Product2> productList) {
        this.productList = productList;
    }

    global List<Product2> start(Database.BatchableContext BC) {
        return productList; 
    }
     
    global void execute(Database.BatchableContext bc, List<Product2> scope) {
        List<ProductCategoryProduct> newProducts = new List<ProductCategoryProduct>();
        List<PricebookEntry> newStandardPBEntries = new List<PricebookEntry>();
        List<ProductMedia> lstProductMedia = new List<ProductMedia>();

        List<ProductCategory> productsCategory = [SELECT Id, Name
                                            FROM ProductCategory
                                            WHERE Name='My Products' LIMIT 1];

        List<PriceBook2> standardPriceBook = [SELECT Id, Name
                                            FROM PriceBook2
                                            WHERE Name='Standard Price Book' LIMIT 1];

        List<ElectronicMediaGroup> lstElectronicMedia = [SELECT id, Name
                                            FROM ElectronicMediaGroup 
                                            WHERE Name Like 'Product List Image' LIMIT 1];

        List<Image_Id__c> carmeueseLogoId = [SELECT Id, Name, Logo_Id__c
                                            FROM Image_Id__c 
                                            WHERE Name='Carmeuse Logo' LIMIT 1];
        

        Id categoryId;
        if(productsCategory.size() > 0) {
            categoryId = productsCategory[0].Id;
        }

        Id priceBookId;
        if(standardPriceBook.size() > 0) {
            priceBookId = standardPriceBook[0].Id;
        }

        Id productListImageId;
        if(lstElectronicMedia.size() > 0) {
            productListImageId = lstElectronicMedia[0].Id;
        }

        Id logoId;
        if(carmeueseLogoId.size() > 0){
            logoId = carmeueseLogoId[0].Logo_Id__c;
        }
        
        for(Product2 product : scope) {
            // Assign product to catagory.
            ProductCategoryProduct pcp = new ProductCategoryProduct();
            pcp.ProductId = product.Id;
            pcp.ProductCategoryId = categoryId;

            newProducts.add(pcp);

            // Create the entry of the product in Standard Price Book with unit price.
            if(!product.Non_B2B_Product__c){
                PricebookEntry pbEntry = new PricebookEntry();
                pbEntry.Pricebook2Id = priceBookId;
                pbEntry.Product2Id = product.Id;
                pbEntry.IsActive = true;
                pbEntry.UnitPrice = 930;
                
                newStandardPBEntries.add(pbEntry);
            }

            // Add list page image to the product.
            if(!Test.isRunningTest()){
                ProductMedia pmObj = new ProductMedia ();
                pmObj.productId = product.id;
                pmObj.ElectronicMediaId   = logoId;
                pmObj.ElectronicMediaGroupId = productListImageId;
                lstProductMedia.add(pmObj);
            }
        }

        if (!newProducts.isEmpty()) {
            insert newProducts;
        }
        if (!newStandardPBEntries.isEmpty()) {
            insert newStandardPBEntries;
        }
        if (!lstProductMedia.isEmpty()) {
            insert lstProductMedia;
        }        
    }   
     
    global void finish(Database.BatchableContext BC) {
    }
}