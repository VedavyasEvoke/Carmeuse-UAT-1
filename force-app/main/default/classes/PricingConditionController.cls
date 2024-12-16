public class PricingConditionController {
    @AuraEnabled(cacheable=false)
    public static List<sObject> fetchProduct(String id) {
        return [SELECT Id, Name FROM Product2 WHERE Id = :String.escapeSingleQuotes(id) WITH SECURITY_ENFORCED];
    }
    
	@AuraEnabled(cacheable=false)
    public static PricingConWrapper getPricingCondition(List<SBQQ__ProductOption__c> listPO) {
        PricingConWrapper priceRW = new PricingConWrapper();
        list<String> products = new list<String>();
        list<String> freights = new list<String>();
        list<String> surcharges = new list<String>();
        list<String> fees = new list<String>();
        list<String> miscs = new list<String>();
        list<String> discounts = new list<String>();
        list<String> commissions = new list<String>();
        
        Map<Id,SBQQ__ProductOption__c> mapIds2PO = new Map<Id,SBQQ__ProductOption__c>();
        for(SBQQ__ProductOption__c po : listPO) {
            mapIds2PO.put(po.Id,po);
        }

        String SalesOrgName;
        for(SBQQ__ProductOption__c po : [SELECT Id, SBQQ__Feature__r.SBQQ__Category__c,
                                        Sales_Organization__c
                                        FROM SBQQ__ProductOption__c 
                                        WHERE Sales_Organization__c != null 
                                        AND Id IN :mapIds2PO.keySet() limit 1]) {
           if(po.Sales_Organization__c != null) {
               SalesOrgName =   po.Sales_Organization__c;  
           }  
        }

       

        for(Pricing_Category__c pricingCon : [ Select Id, Name,  Sales_Organization__c, Ranking__c, Price_Category__c,
                                                Description__c from Pricing_Category__c where 
                                                Sales_Organization__c= :SalesOrgName AND Price_Category__c != null
                                                order by Price_category__c]
                                                     ){
            if(pricingCon.Price_Category__c == 'Product'){
                products.add(pricingCon.Description__c);
            }else if(pricingCon.Price_Category__c == 'Freight'){
                freights.add(pricingCon.Description__c);
            }else if(pricingCon.Price_Category__c == 'Surcharges'){
                surcharges.add(pricingCon.Description__c);
            }else if(pricingCon.Price_Category__c == 'Fees'){
                fees.add(pricingCon.Description__c);
            }else if(pricingCon.Price_Category__c == 'Misc'){
                miscs.add(pricingCon.Description__c);
            }else if(pricingCon.Price_Category__c == 'Discount'){
                discounts.add(pricingCon.Description__c);
            }else if(pricingCon.Price_Category__c == 'Commission'){
                commissions.add(pricingCon.Description__c);
            }

        }
    
        priceRW.Products = products;
        priceRW.Freights = freights;
        priceRW.Surcharges = surcharges;
        priceRW.Fees = fees;
        priceRW.Miscs = miscs;
        priceRW.Discounts = discounts;
        priceRW.Commissions = commissions;
        return priceRW;
    }


    public class PricingConWrapper {

        @AuraEnabled
        public  list<String> Products {get;set;}

        @AuraEnabled
        public  list<String> Freights {get;set;}

        @AuraEnabled
        public  list<String> Surcharges {get;set;}

        @AuraEnabled
        public  list<String> Fees {get;set;}

        @AuraEnabled
        public  list<String> Miscs {get;set;}

        @AuraEnabled
        public  list<String> Discounts {get;set;}

        @AuraEnabled
        public  list<String> Commissions {get;set;}

    }
}