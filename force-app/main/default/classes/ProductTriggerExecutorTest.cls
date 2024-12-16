@isTest(SeeAllData=true)
public with sharing class ProductTriggerExecutorTest {
    @IsTest
    static void testProductAddedtoStandardPriceBook() {
        Test.startTest();    
        TriggerConfiguration.shouldRunTrigger();
        
        Product2 newProduct = new Product2(Name='Batch Test Product', StockKeepingUnit='000000000000010317-000TEST-000123456', Plant_code__c='BR', ProductCode='65221', IsActive=true);        
        insert newProduct;
        Test.stopTest();
        
        List<PriceBook2> standardPriceBook = [SELECT Id, Name FROM PriceBook2 WHERE Name='Standard Price Book' LIMIT 1];
        System.assertEquals(1, standardPriceBook.size(),'Standard Pricebook should get from Org');
        System.assertNotEquals(null, standardPriceBook.size());
        
        Id standardPriceBookId;
        if(standardPriceBook.size() > 0){
            standardPriceBookId = standardPriceBook[0].Id;
        }
        //PT-001
        List<ProductCategoryProduct> lstProductCategoryProduct = [SELECT Id, ProductId FROM ProductCategoryProduct WHERE ProductId =: newProduct.Id];
        System.assertEquals(1, lstProductCategoryProduct.size());
        System.assertNotEquals(null, lstProductCategoryProduct.size());
        
        for(ProductCategoryProduct pcpObj : lstProductCategoryProduct){
            System.assertEquals(newProduct.Id, pcpObj.ProductId,'Product should be assigned to Category');
            System.assertNotEquals(null, pcpObj.ProductId,'ProductId should not be null in Category');
        }
        
        List<PricebookEntry> pbEntryList = [SELECT  Pricebook2Id, Product2Id, UnitPrice, IsActive FROM PricebookEntry   WHERE Product2Id =: newProduct.Id];
        System.assertEquals(1, lstProductCategoryProduct.size());
        System.assertNotEquals(null, lstProductCategoryProduct.size());
        
        List<Image_Id__c> carmeueseLogoId = [SELECT Id, Name, Logo_Id__c FROM Image_Id__c  WHERE Name='Carmeuse Logo' LIMIT 1];
        Id imageContentId;
        if(carmeueseLogoId.size() > 0){
            imageContentId = carmeueseLogoId[0].Logo_Id__c;
        }
        
        List<ElectronicMediaGroup> lstElectronicMediaGroup = [SELECT Id, Name, Description FROM ElectronicMediaGroup WHERE Name LIKE 'Product List Image' LIMIT 1];
        Id listImageId;
        if(lstElectronicMediaGroup.size() > 0){
            listImageId = lstElectronicMediaGroup[0].Id;
        }
        //PT-002
        for(PricebookEntry pbEntryObj : pbEntryList){
            //Positive
            System.assertEquals(newProduct.Id, pbEntryObj.Product2Id,'Product Entry should be added in PricebookEntry');
            System.assertEquals(standardPriceBookId, pbEntryObj.Pricebook2Id,'Product should be assigned to Standard Price Book');
            System.assertEquals(930, pbEntryObj.UnitPrice,'UnitPrice in PriceBookEntry should be correct');
            System.assertEquals(true, pbEntryObj.IsActive,'PricebookEntry should be active');
            //Negative
            System.assertNotEquals(null,pbEntryObj.Product2Id,'Product Entry should not be null in PricebookEntry');
            System.assertNotEquals(null,pbEntryObj.Pricebook2Id,'Pricebook2Id in PricebookEntry should not be null');
            System.assertNotEquals(321,pbEntryObj.UnitPrice,'UnitPrice in PriceBookEntry should not be incorrect');
            System.assertNotEquals(false,pbEntryObj.IsActive,'PricebookEntry should not be deactive');
        }
        
        List<ProductMedia> lstProductMedia = [SELECT Id, productId, ElectronicMediaId, ElectronicMediaGroupId FROM ProductMedia WHERE productId =: newProduct.id AND ElectronicMediaGroupId  =: listImageId];
        // System.assertEquals(1,lstProductMedia.size());
        // System.assertNotEquals(null,lstProductMedia.size());
        
        for(ProductMedia prmObj : lstProductMedia){
            System.assertEquals(newProduct.Id, prmObj.ProductId);
            //PM-001 //Positive
            System.assertEquals(listImageId, prmObj.ElectronicMediaGroupId,'When Product is created,image should be added as a List image');
            System.assertEquals(imageContentId, prmObj.ElectronicMediaId,'List image should be added');
            //Negative
            System.assertNotEquals(null, prmObj.ProductId,'ProductId in ProductMedia should not be null');
            System.assertNotEquals(null, prmObj.ElectronicMediaGroupId,'When Product is created,image should not be added other than List image');
            System.assertNotEquals(null, prmObj.ElectronicMediaId,'List image should not null');
        }
        
        //Delete Scenario
        List<Product2> lstProduct2 = [SELECT Id, Name FROM Product2 WHERE Name='Batch Test Product'];
        Database.delete(lstProduct2); 
    }
    @isTest
    public static void testUpdateScenario(){
        TriggerConfiguration.setDoNotRunTrigger();
        
        Account testAccount = new Account(Name='TestAccount1',BillingStreet='Test Street', BillingCountry='United States', BillingPostalCode='44444', AccountExternalNumber__c = '000TEST');
        insert testAccount;        
        CommerceEntitlementPolicy testCommerceEntitlementPolicy = new CommerceEntitlementPolicy(Name = 'EP - TestAccount1', IsActive = true, CanViewProduct = true,Account__c=testAccount.Id);
        insert testCommerceEntitlementPolicy;
        Pricebook2 testPricebook2 = new Pricebook2 (Name = 'PB-TestAccount1',  IsActive = true);
        insert testPricebook2;
        
        List<Product2> lstProduct2 = new List<Product2>();
        for(Integer iIndex = 0 ;iIndex < 60 ;iIndex++){
            if(iIndex < 10){
                Product2 objProduct2 = new Product2();
                objProduct2.Name='Test Product';
                objProduct2.StockKeepingUnit='00000000000001031'+iIndex+'-000TEST-00011';
                objProduct2.Plant_code__c='BR';
                objProduct2.ProductCode='1031'+iIndex;
                objProduct2.IsActive=true;
                objProduct2.SAP_Probability__c = 99;
                lstProduct2.add(objProduct2);
            } if(iIndex >= 10 && iIndex < 20){
                Product2 objProduct2 = new Product2();
                objProduct2.Name='Test Product';
                objProduct2.StockKeepingUnit='00000000000001031'+iIndex+'-000TEST-00012';
                objProduct2.Plant_code__c='BR';
                objProduct2.ProductCode='1031'+iIndex;
                objProduct2.IsActive=true;
                objProduct2.SAP_Probability__c = 1;
                lstProduct2.add(objProduct2);
            }if(iIndex >= 20 && iIndex < 30){
                Product2 objProduct2 = new Product2();
                objProduct2.Name='Test Product';
                objProduct2.StockKeepingUnit='00000000000001031'+iIndex+'-000TEST-00013';
                objProduct2.Plant_code__c='BR';
                objProduct2.ProductCode='1031'+iIndex;
                objProduct2.IsActive=true;
                objProduct2.SAP_Probability__c = 22;
                lstProduct2.add(objProduct2);
            }if(iIndex >= 30 && iIndex < 40){
                Product2 objProduct2 = new Product2();
                objProduct2.Name='Test Product';
                objProduct2.StockKeepingUnit='00000000000001031'+iIndex+'-000TEST-00014';
                objProduct2.Plant_code__c='BR';
                objProduct2.ProductCode='1031'+iIndex;
                objProduct2.IsActive=true;
                objProduct2.SAP_Probability__c = 23;
                lstProduct2.add(objProduct2);
            } if(iIndex >= 40 && iIndex < 50){
                Product2 objProduct2 = new Product2();
                objProduct2.Name='Test Product';
                objProduct2.StockKeepingUnit='00000000000001031'+iIndex+'-000TEST-00015';
                objProduct2.Plant_code__c='TEST';
                objProduct2.ProductCode='1031'+iIndex;
                objProduct2.IsActive=true;
                objProduct2.SAP_Probability__c = 99;
                lstProduct2.add(objProduct2);
            }  if(iIndex >= 50 && iIndex < 60){
                Product2 objProduct2 = new Product2();
                objProduct2.Name='Test Product';
                objProduct2.StockKeepingUnit='00000000000001031'+iIndex+'-000TEST-00016';
                objProduct2.Plant_code__c='TEST';
                objProduct2.ProductCode='1031'+iIndex;
                objProduct2.IsActive=true;
                objProduct2.SAP_Probability__c = 1;
                lstProduct2.add(objProduct2);
            }             
        }
        insert lstProduct2;
        TriggerConfiguration.shouldRunTrigger();
        Id stdPricebookId = Test.getStandardPricebookId();
        
        List<PricebookEntry> lstStdPricebookEntry = new List<PricebookEntry>();
        List<PricebookEntry> lstPricebookEntry = new List<PricebookEntry>();
        List<CommerceEntitlementProduct> lstCommerceEntitlementProduct = new List<CommerceEntitlementProduct>();
        Set<Id> productIds = new Set<Id>();
        
        List<ExtendedEntitlement__c> lstExtendedEntitlementInsert = new List<ExtendedEntitlement__c>();
        
        for(Product2 objProduct2 : lstProduct2){
            PricebookEntry standardPrimaryPriceEntry = new PricebookEntry();
            standardPrimaryPriceEntry.Pricebook2Id = stdPricebookId;
            standardPrimaryPriceEntry.Product2Id = objProduct2.Id;
            standardPrimaryPriceEntry.UnitPrice = 10000;
            standardPrimaryPriceEntry.IsActive = true;
            standardPrimaryPriceEntry.Quote_Number__c = '1111';
            lstStdPricebookEntry.add(standardPrimaryPriceEntry);
            
            PricebookEntry priceEntry = new PricebookEntry();
            priceEntry.Pricebook2Id = testPricebook2.Id;
            priceEntry.Product2Id = objProduct2.Id;
            priceEntry.UnitPrice = 10000;
            priceEntry.IsActive = true;
            priceEntry.Quote_Number__c = '1234';
            priceEntry.OriginationPlant__c = objProduct2.Plant_code__c;
            lstPricebookEntry.add(priceEntry);
            
        }
        insert lstStdPricebookEntry;
        insert lstPricebookEntry;
        for(Integer iIndex = 0 ;iIndex <lstProduct2.size() ;iIndex++){ 
            if(lstProduct2[iIndex].SAP_Probability__c == 99){
                CommerceEntitlementProduct objCommerceEntitlementProduct = new CommerceEntitlementProduct();
                objCommerceEntitlementProduct.PolicyId = testCommerceEntitlementPolicy.Id;
                objCommerceEntitlementProduct.ProductId = lstProduct2[iIndex].Id;
                lstCommerceEntitlementProduct.add(objCommerceEntitlementProduct);              
            } else if(lstProduct2[iIndex].SAP_Probability__c == 1){
                ExtendedEntitlement__c objEEP = new ExtendedEntitlement__c();
                objEEP.QuoteNumber__c = '1234';
                objEEP.Price__c = 70.0;
                objEEP.Plant_Code__c = 'KL';
                objEEP.Selected__c = true;
                objEEP.MaterialNumber__c = lstProduct2[iIndex].StockKeepingUnit;
                String[] SKU_Array = lstProduct2[iIndex].StockKeepingUnit.split('-');
                if(SKU_Array.size() >= 3){
                    String externalShipTo = SKU_Array[1];
                    objEEp.AccountExternalNumber__c = externalShipTo;
                    objEEP.AccountExtendedEntitlement__c=testAccount.Id;
                    objEEp.AccountNumber__c =externalShipTo.replaceFirst('^0+', '');
                }
                lstExtendedEntitlementInsert.add(objEEp);
            }  
            productIds.add(lstProduct2[iIndex].Id);
        }
        insert lstCommerceEntitlementProduct; 
        insert lstExtendedEntitlementInsert;
        
        List<CommerceEntitlementProduct> lstCEP = [SELECT Id FROM CommerceEntitlementProduct WHERE ProductId IN : productIds];
        System.assertEquals(20, lstCEP.size(), 'Excepted valid CommerceEntitlementProduct created');
        
        List<ExtendedEntitlement__c> lstExtendedEntitlement = [SELECT Id FROM ExtendedEntitlement__c WHERE AccountExtendedEntitlement__c =: testAccount.Id];
        System.assertEquals(20, lstExtendedEntitlement.size(), 'Excepted valid ExtendedEntitlement created');
        
        // TriggerConfiguration.shouldRunTrigger();  
       TriggerConfiguration.doNotRunTrigger =   false;
        
        test.startTest();
        List<Product2> lstProduct2ToUpdate = [SELECT Id,SAP_Probability__c,StockKeepingUnit,Plant_code__c FROM Product2 WHERE Id IN : productIds];
        
        List<Product2> lstProductsRemoveFromEP = new List<Product2>();
        Set<Id> productsRemoveFromEP = new Set<Id>();
        
        List<Product2> lstProductsRemoveFromExtended = new List<Product2>();
        Set<Id> productsAssignToEP = new Set<Id>();
        
        Set<String> productsRemoveFromEPAddToExtended = new Set<String>();
        Set<String> productsRemoveFromExtendedAddedToEP = new Set<String>();
        Set<String> productsAddToExtendedAddedFromOther = new Set<String>();
        
        Set<Id> productsAssignToEPFromOther = new Set<Id>();
        List<Product2> lstProductsAddToEPFromOther = new List<Product2>();
        List<Product2> lstProductsAddToExtendedAddedFromOther  = new List<Product2>();
        
        List<Product2> lstProductRemoveFromEPOther = new List<Product2>();
        Set<Id> productRemoveFromEPOther = new Set<Id>();
        
        List<Product2> lstProductRemoveFromExtendedOther = new List<Product2>();
        Set<String> productRemoveFromExtendedOther = new Set<String>();
        
        for(Integer iIndex = 0 ;iIndex <lstProduct2ToUpdate.size() ;iIndex++){ 
            Product2 objProduct2 = lstProduct2ToUpdate[iIndex];
            if(lstProduct2ToUpdate[iIndex].SAP_Probability__c == 99 && lstProduct2ToUpdate[iIndex].Plant_code__c != 'TEST'){               
                objProduct2.SAP_Probability__c = 1;
                productsRemoveFromEP.add(objProduct2.Id);
                productsRemoveFromEPAddToExtended.add(objProduct2.StockKeepingUnit);
                lstProductsRemoveFromEP.add(objProduct2);
            }else if(lstProduct2ToUpdate[iIndex].SAP_Probability__c == 1 && lstProduct2ToUpdate[iIndex].Plant_code__c != 'TEST'){
                objProduct2.SAP_Probability__c = 99;
                productsAssignToEP.add(objProduct2.Id);                
                productsRemoveFromExtendedAddedToEP.add(objProduct2.StockKeepingUnit);
                lstProductsRemoveFromExtended.add(objProduct2);
            }else if(lstProduct2ToUpdate[iIndex].SAP_Probability__c == 22){
                objProduct2.SAP_Probability__c = 99;
                productsAssignToEPFromOther.add(objProduct2.Id);
                lstProductsAddToEPFromOther.add(objProduct2);           
            }else if(lstProduct2ToUpdate[iIndex].SAP_Probability__c == 23){
                objProduct2.SAP_Probability__c = 1;
                productsAddToExtendedAddedFromOther.add(objProduct2.StockKeepingUnit);
                lstProductsAddToExtendedAddedFromOther.add(objProduct2);
            }else if((lstProduct2ToUpdate[iIndex].SAP_Probability__c == 99 || lstProduct2ToUpdate[iIndex].SAP_Probability__c == 100)&& lstProduct2ToUpdate[iIndex].Plant_code__c == 'TEST'){
                objProduct2.SAP_Probability__c = 5;
                productRemoveFromEPOther.add(objProduct2.Id);
                lstProductRemoveFromEPOther.add(objProduct2);
            }else if((lstProduct2ToUpdate[iIndex].SAP_Probability__c == 1 || lstProduct2ToUpdate[iIndex].SAP_Probability__c == 100) && lstProduct2ToUpdate[iIndex].Plant_code__c == 'TEST'){
                objProduct2.SAP_Probability__c = 5;
                productRemoveFromExtendedOther.add(objProduct2.StockKeepingUnit);
                lstProductRemoveFromExtendedOther.add(objProduct2);
            }
            
        }
        update lstProductsRemoveFromEP;
        
        List<ExtendedEntitlement__c> lstProductExtended = [SELECT Id FROM ExtendedEntitlement__c WHERE MaterialNumber__c IN : productsRemoveFromExtendedAddedToEP];
        System.assertEquals(productsRemoveFromExtendedAddedToEP.size(), lstProductExtended.size(), 'To test product is added to extended policy if SAP probability is 99');
        
        update lstProductsRemoveFromExtended;
        
        List<CommerceEntitlementProduct> lstCommerceEntitlementProductInvalid = [SELECT Id FROM CommerceEntitlementProduct WHERE ProductId IN : productsAssignToEPFromOther];
        System.assertEquals(0, lstCommerceEntitlementProductInvalid.size(),'To test product with SAP probability other than 99 no product should assign to policy');
        
        update lstProductsAddToEPFromOther;
        
        List<ExtendedEntitlement__c> lstProductExtendedInvalid = [SELECT Id FROM ExtendedEntitlement__c WHERE MaterialNumber__c IN : productsAddToExtendedAddedFromOther];
        System.assertEquals(0, lstProductExtendedInvalid.size(), 'To test product with SAP probability other than 1 no product should assign to extended policy');
        
        update lstProductsAddToExtendedAddedFromOther;
        
        List<CommerceEntitlementProduct> lstCommerceEntitlementProductOther = [SELECT Id FROM CommerceEntitlementProduct WHERE ProductId IN : productRemoveFromEPOther];
        System.assertEquals(productRemoveFromEPOther.size(), lstCommerceEntitlementProductOther.size(),'To test product is added to extended policy if SAP probability is 99');
        
        update lstProductRemoveFromEPOther;
        
        List<ExtendedEntitlement__c> lstProductExtendedOther = [SELECT Id,Price__c,Plant_Code__c,MaterialNumber__c,AccountExtendedEntitlement__c,AccountExternalNumber__c,AccountNumber__c FROM ExtendedEntitlement__c WHERE MaterialNumber__c IN : productRemoveFromExtendedOther];
        System.assertEquals(productsAddToExtendedAddedFromOther.size(), lstProductExtendedOther.size(), 'To test product\'s with SAP probability 1 are assign to extended policy');
        
        update lstProductRemoveFromExtendedOther;
        test.stopTest();
        
        //P2EP-007
        List<CommerceEntitlementProduct> lstProductsRemovedFromEP = [SELECT Id FROM CommerceEntitlementProduct WHERE ProductId IN : productsRemoveFromEP];
        //Positive
        System.assertEquals(0, lstProductsRemovedFromEP.size(), 'To test if product\'s SAP probability change from 99 to 1 products get remove from Commerce Entitlement Policy');
        //Negative
        System.assertNotEquals(productsRemoveFromEP.size(), lstProductsRemovedFromEP.size(), 'To test if product\'s SAP probability change from 99 to 1 products have to remove from Commerce Entitlement Policy');
        
        //P2EP-007
        List<ExtendedEntitlement__c> lstProductsAddedToExtendedFromEP = [SELECT Id,AccountExtendedEntitlement__c,AccountExternalNumber__c,AccountNumber__c,MaterialNumber__c,Plant_Code__c,Price__c,QuoteNumber__c,Selected__c FROM ExtendedEntitlement__c WHERE MaterialNumber__c IN : productsRemoveFromEPAddToExtended];
        List<Product2> lstProducts = [SELECT Id,Plant_Code__c FROM Product2 WHERE StockKeepingUnit IN : productsRemoveFromEPAddToExtended];
        set<Id> setProductId = new set<Id>();
        for(Product2 productId : lstProducts){
            setProductId.add(productId.Id);
        }
        List<PricebookEntry> lstPriceBookEntryFrmProductId = [SELECT UnitPrice,Quote_Number__c FROM PricebookEntry WHERE Product2Id IN : setProductId AND Pricebook2Id =: testPricebook2.Id];
        //Positive
        System.assertEquals(lstProductsRemoveFromEP.size(), lstProductsAddedToExtendedFromEP.size(), 'To test if  product\'s SAP probability change from 99 to 1 products get remove from Commerce Entitlement Policy and get added to Extended Policy');
        //Negative
        System.assertNotEquals(0, lstProductsAddedToExtendedFromEP.size(), 'To test if  product\'s SAP probability change from 99 to 1 products get remove from Commerce Entitlement Policy and get added to Extended Policy');
        Integer index = 0;
        for(ExtendedEntitlement__c objExtendedPolicy : lstProductsAddedToExtendedFromEP){
            //Positive
            System.assertEquals(testAccount.Id, objExtendedPolicy.AccountExtendedEntitlement__c,'AccountExtendedEntitlement__c from Extended Policy should be equal to Account\'s Id');
            System.assertEquals(testAccount.AccountExternalNumber__c.replaceFirst('^0+', ''),objExtendedPolicy.AccountNumber__c,'AccountNumber__c from Extended Policy should be equal to Account\'s AccountExternalNumber__c');
            System.assertEquals(testAccount.AccountExternalNumber__c, objExtendedPolicy.AccountExternalNumber__c,'AccountExternalNumber__c from Extended Policy should be equal to Account\'s AccountExternalNumber__c');
            System.assertEquals(TRUE, productsRemoveFromEPAddToExtended.contains(objExtendedPolicy.MaterialNumber__c),'MaterialNumber__c from Extended Policy equal to Product\'s SKU');
            System.assertEquals(lstProducts[index].Plant_Code__c, objExtendedPolicy.Plant_Code__c,'Plant_Code__c from Extended Policy should be equal to Product\'s Plant code');
            System.assertEquals(lstPriceBookEntryFrmProductId[index].UnitPrice, objExtendedPolicy.Price__c,'Price__c from Extended Policy should be equal to Product\'s PriceBookEntry Unit Price');
            System.assertEquals(lstPriceBookEntryFrmProductId[index].Quote_Number__c, objExtendedPolicy.QuoteNumber__c,'QuoteNumber__c from Extended Policy should be equal to Product\'s PriceBookEntry QuoteNumber');
            //Negative
            System.assertNotEquals('oxgu44', objExtendedPolicy.AccountExtendedEntitlement__c,'AccountExtendedEntitlement__c from Extended Policy should not be other than Account\'s Id');
            System.assertNotEquals('3339940',objExtendedPolicy.AccountNumber__c,'AccountNumber__c from Extended Policy should not be other than Account\'s AccountExternalNumber__c');
            System.assertNotEquals('3339940', objExtendedPolicy.AccountExternalNumber__c,'AccountExternalNumber__c from Extended Policy should not be other than Account\'s AccountExternalNumber__c');
            System.assertNotEquals(False, productsRemoveFromEPAddToExtended.contains(objExtendedPolicy.MaterialNumber__c),'MaterialNumber__c from Extended Policy should not be other than Product\'s SKU');
            System.assertNotEquals('TYYEUU', objExtendedPolicy.Plant_Code__c,'Plant_Code__c from Extended Policy should not be other than Product\'s Plant code');
            System.assertNotEquals(33, objExtendedPolicy.Price__c,'Price__c from Extended Policy should not be other than Product\'s PriceBookEntry Unit Price');
            System.assertNotEquals('0000', objExtendedPolicy.QuoteNumber__c,'QuoteNumber__c from Extended Policy should not be other than Product\'s PriceBookEntry QuoteNumber');
            index++;
        }
        //P2EP-008
        List<CommerceEntitlementProduct> lstAddedToEP = [SELECT Id,PolicyId,ProductId FROM CommerceEntitlementProduct WHERE ProductId IN : productsAssignToEP];
        //Positive
        System.assertEquals(productsAssignToEP.size(), lstAddedToEP.size(), 'To test if  product\'s SAP probability change from 1 to 99 products get add to Commerce Entitlement Policy');
        //Negative
        System.assertNotEquals(0, lstAddedToEP.size(), 'To test if  product\'s SAP probability change from 1 to 99 products get add to Commerce Entitlement Policy');
        
        for(CommerceEntitlementProduct objEP : lstAddedToEP){
            //Positive
            System.assertEquals(testCommerceEntitlementPolicy.Id, objEP.PolicyId, 'CommerceEntitlementProduct\'s PolicyId should be equal to CommerceEntitlementPolicy\'s Id');
            System.assertEquals(True, productsAssignToEP.contains(objEP.ProductId) , 'CommerceEntitlementProduct\'s ProductId should be equal to Product\'s Id that are assign to EP');
            //Negative
            System.assertNotEquals('oio97d', objEP.PolicyId, 'CommerceEntitlementProduct\'s PolicyId should not be other than CommerceEntitlementPolicy\'s Id');
            System.assertNotEquals(False, productsAssignToEP.contains(objEP.ProductId) , 'CommerceEntitlementProduct\'s ProductId should be equal to Product\'s Id that are assign to EP');
        }
        
        //P2EP-008
        List<ExtendedEntitlement__c> lstProductsRemoveExtended = [SELECT Id FROM ExtendedEntitlement__c WHERE MaterialNumber__c IN : productsRemoveFromExtendedAddedToEP];
        //Positive
        System.assertEquals(0, lstProductsRemoveExtended.size(), 'To test if  product\'s SAP probability change from 1 to 99 products get remove from Extended Policy');
        //Negative
        System.assertNotEquals(productsRemoveFromExtendedAddedToEP.size(), lstProductsRemoveExtended.size(), 'To test if  product\'s SAP probability change from 1 to 99 products get remove from Extended Policy');
        
        
        //P2EP-005
        List<CommerceEntitlementProduct> lstAddedToEPFromOther = [SELECT Id,PolicyId,ProductId FROM CommerceEntitlementProduct WHERE ProductId IN : productsAssignToEPFromOther];
        System.assertEquals(productsAssignToEPFromOther.size(), lstAddedToEPFromOther.size(), 'To test if  product\'s SAP probability change from any value to 99 products gets add to Commerce Entitlement Policy');
        for(CommerceEntitlementProduct objEPOther : lstAddedToEPFromOther){
            //Positive
            System.assertEquals(testCommerceEntitlementPolicy.Id, objEPOther.PolicyId, 'CommerceEntitlementProduct\'s PolicyId should be equal to CommerceEntitlementPolicy\'s Id');
            System.assertEquals(True, productsAssignToEPFromOther.contains(objEPOther.ProductId) , 'CommerceEntitlementProduct\'s ProductId should be equal to Product\'s Id that are assign to EP');
            //Negative
            System.assertNotEquals('oio97d', objEPOther.PolicyId, 'CommerceEntitlementProduct\'s PolicyId should not be other than CommerceEntitlementPolicy\'s Id');
            System.assertNotEquals(False, productsAssignToEPFromOther.contains(objEPOther.ProductId) , 'CommerceEntitlementProduct\'s ProductId should be equal to Product\'s Id that are assign to EP');
        }
        
        //P2EP-006
        List<ExtendedEntitlement__c> lstProductAddedExtendedFromOther = [SELECT Id,QuoteNumber__c,Price__c,Plant_Code__c,AccountExtendedEntitlement__c,AccountNumber__c,MaterialNumber__c,AccountExternalNumber__c  FROM ExtendedEntitlement__c WHERE MaterialNumber__c IN : productsAddToExtendedAddedFromOther];
        List<Product2> lstProductsFrmOther = [SELECT Id,Plant_Code__c FROM Product2 WHERE StockKeepingUnit IN : productsAddToExtendedAddedFromOther];
        set<Id> setProductIdFrmOther = new set<Id>();
        for(Product2 productId : lstProductsFrmOther){
            setProductIdFrmOther.add(productId.Id);
        }
        List<PricebookEntry> lstPriceBookEntryFrmProductIdOther = [SELECT UnitPrice,Quote_Number__c FROM PricebookEntry WHERE Product2Id IN : setProductId AND Pricebook2Id =: testPricebook2.Id];
        //Positive
        System.assertEquals(productsAddToExtendedAddedFromOther.size(), lstProductAddedExtendedFromOther.size(), 'To test if  product\'s SAP probability change from any value to 1 products should get added to extended policy');
        //Negative
        System.assertNotEquals(0, lstProductAddedExtendedFromOther.size(), 'To test if  product\'s SAP probability change from any value to 1 products should get added to extended policy');
        
        for(ExtendedEntitlement__c objExtendedPolicy : lstProductAddedExtendedFromOther){
            Integer indexothr =0;
            //Positive
            System.assertEquals(testAccount.Id, objExtendedPolicy.AccountExtendedEntitlement__c,'AccountExtendedEntitlement__c from Extended Policy should be equal Account\'s Id');
            System.assertEquals(testAccount.AccountExternalNumber__c.replaceFirst('^0+', ''),objExtendedPolicy.AccountNumber__c,'AccountNumber__c from Extended Policy should be equal to Account\'s AccountExternalNumber__c');
            System.assertEquals(testAccount.AccountExternalNumber__c, objExtendedPolicy.AccountExternalNumber__c,'AccountNumber__c from Extended Policy should be equal Account\'s AccountExternalNumber__c');
            System.assertEquals(TRUE, productsAddToExtendedAddedFromOther.contains(objExtendedPolicy.MaterialNumber__c),'MaterialNumber__c from Extended Policy equal to Product\'s SKU');
            System.assertEquals(lstProductsFrmOther[indexothr].Plant_Code__c, objExtendedPolicy.Plant_Code__c,'Plant_Code__c from Extended Policy should be equal to Product\'s Plant code');
            System.assertEquals(lstPriceBookEntryFrmProductIdOther[indexothr].UnitPrice, objExtendedPolicy.Price__c,'Price__c from Extended Policy should be equal to Product\'s PriceBookEntry Unit Price');
            System.assertEquals(lstPriceBookEntryFrmProductIdOther[indexothr].Quote_Number__c, objExtendedPolicy.QuoteNumber__c,'QuoteNumber__c from Extended Policy should be equal to Product\'s PriceBookEntry QuoteNumber');
            //Negative
            System.assertNotEquals('oxgu44', objExtendedPolicy.AccountExtendedEntitlement__c,'AccountExtendedEntitlement__c from Extended Policy should not be other than Account\'s Id');
            System.assertNotEquals('3339940',objExtendedPolicy.AccountNumber__c,'AccountNumber__c from Extended Policy should not be other than Account\'s AccountExternalNumber__c');
            System.assertNotEquals('3339940', objExtendedPolicy.AccountExternalNumber__c,'AccountExternalNumber__c from Extended Policy should not be other than Account\'s AccountExternalNumber__c');
            System.assertNotEquals(False, productsAddToExtendedAddedFromOther.contains(objExtendedPolicy.MaterialNumber__c),'MaterialNumber__c from Extended Policy should not be other than Product\'s SKU');
            System.assertNotEquals('TYYEUU', objExtendedPolicy.Plant_Code__c,'Plant_Code__c from Extended Policy should not be other than Product\'s Plant code');
            System.assertNotEquals(33, objExtendedPolicy.Price__c,'Price__c from Extended Policy should not be other than Product\'s PriceBookEntry Unit Price');
            System.assertNotEquals('0000', objExtendedPolicy.QuoteNumber__c,'QuoteNumber__c from Extended Policy should not be other than Product\'s PriceBookEntry QuoteNumber');
            indexothr++;
        }
        List<CommerceEntitlementProduct> lstCommerceEntitlementProductOtherRemove = [SELECT Id FROM CommerceEntitlementProduct WHERE ProductId IN : productRemoveFromEPOther];
        System.assertEquals(0, lstCommerceEntitlementProductOtherRemove.size(),'To test if product\'s SAP probability change from 99 to any other  products get remove from Commerce Entitlement Policy');
        
        List<ExtendedEntitlement__c> lstProductExtendedOtherRemove = [SELECT Id FROM ExtendedEntitlement__c WHERE MaterialNumber__c IN : productRemoveFromExtendedOther];
        System.assertEquals(0, lstProductExtendedOtherRemove.size(), 'To test if product\'s SAP probability change from 1 to any other products get remove from extended policy');
        
    }
}