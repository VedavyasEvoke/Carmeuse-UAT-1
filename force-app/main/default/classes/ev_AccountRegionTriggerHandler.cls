public class ev_AccountRegionTriggerHandler {
    public static void handleCountryRegions(List<Account> accounts, Map<Id, Account> oldMap) {

        // Define sets for each region
        //Set<String> northAmericaStates = new Set<String>{'United States', 'Canada'};
        //Set<String> centralEuropeCountries = new Set<String>{'Austria', 'Belarus', 'Bosnia-Herzegovina', 'Croatia', 'Czech Republic', 'Hungary', 'Poland', 'Slovakia', 'Slovenia', 'Ukraine'};
        //Set<String> easternEuropeCountries = new Set<String>{'Albania', 'Bulgaria', 'Greece', 'Kosovo', 'Macedonia', 'Moldova', 'Montenegro', 'Serbia', 'Romania'};
        //Set<String> westernEuropeCountries = new Set<String>{'Belgium', 'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Ireland', 'Italy', 'Latvia', 'Lithuania', 'Luxembourg', 'Netherlands', 'Norway', 'Portugal', 'Spain', 'Sweden', 'Switzerland', 'United Kingdom'};
        Set<String> northAmericaStates = new Set<String>{'United States','US','USA', 'Canada', 'CA'};
        Set<String> centralEuropeCountries = new Set<String>{'Austria','AT', 'Belarus','BY', 'Bosnia-Herzegovina','BA', 'Croatia','HR', 'Czech Republic','CZ', 'Hungary','HU', 'Poland','PL', 'Slovakia','SK', 'Slovenia','SI', 'Ukraine','UA'};
        Set<String> easternEuropeCountries = new Set<String>{'Albania','AL', 'Bulgaria','BG', 'Greece','GR', 'Kosovo','XK', 'Macedonia','MK', 'Moldova','MD', 'Montenegro','ME', 'Serbia','RS', 'Romania','RO'};
        Set<String> westernEuropeCountries = new Set<String>{'Belgium','BE', 'Denmark','DK', 'Estonia','EE', 'Finland','FI', 'France','FR', 'Germany','DE', 'Ireland','IE', 'Italy','IT', 'Latvia','LV', 'Lithuania','LT', 'Luxembourg','LU', 'Netherlands','NL', 'Norway','NO', 'Portugal','PT', 'Spain','ES', 'Sweden','SE', 'Switzerland','CH', 'United Kingdom','GB','UK'};
        Set<String> turkeyCountries = new Set<String>{'Turkey','TR'};

        // Get Current user info and user Region
        User currentUser = [Select Id, Region__c from User where Id = :UserInfo.getUserId()];
        String currentUserRegion = currentUser.Region__c;
        
        for (Account acc : accounts) {
            Account oldAcc = (oldMap != null) ? oldMap.get(acc.Id) : null;
            
            // Check if ShippingCountry has changed and update region accordingly
            if (oldAcc == null || (acc.ShippingCountry != oldAcc.ShippingCountry && acc.ShippingCountry != null)) {
                if (northAmericaStates.contains(acc.ShippingCountry)) {
                    acc.Customer_Region__c = 'North America';
                    acc.CurrencyIsoCode = 'USD';
                } else if (centralEuropeCountries.contains(acc.ShippingCountry)) {
                    acc.Customer_Region__c = 'Central Europe';
                    acc.CurrencyIsoCode = 'EUR';
                } else if (easternEuropeCountries.contains(acc.ShippingCountry)) {
                    acc.Customer_Region__c = 'Eastern Europe';
                    acc.CurrencyIsoCode = 'EUR';
                } else if (westernEuropeCountries.contains(acc.ShippingCountry)) {
                    acc.Customer_Region__c = 'Western Europe';
                    acc.CurrencyIsoCode = 'EUR';
                } else if (turkeyCountries.contains(acc.ShippingCountry)) {
                    acc.Customer_Region__c = 'Turkey';
                    acc.CurrencyIsoCode = 'EUR';
                } else {
                    acc.Customer_Region__c = null;
                }
            }                
            // Check if BillingCountry has changed and update region accordingly
            if ( acc.Customer_Region__c == null && (oldAcc == null || (acc.BillingCountry != oldAcc.BillingCountry && acc.BillingCountry != null))) {
                if (northAmericaStates.contains(acc.BillingCountry)) {
                    acc.Customer_Region__c = 'North America';
                    acc.CurrencyIsoCode = 'USD';
                } else if (centralEuropeCountries.contains(acc.BillingCountry)) {
                    acc.Customer_Region__c = 'Central Europe';
                    acc.CurrencyIsoCode = 'EUR';
                } else if (easternEuropeCountries.contains(acc.BillingCountry)) {
                    acc.Customer_Region__c = 'Eastern Europe';
                    acc.CurrencyIsoCode = 'EUR';
                } else if (westernEuropeCountries.contains(acc.BillingCountry)) {
                    acc.Customer_Region__c = 'Western Europe';
                    acc.CurrencyIsoCode = 'EUR';
                } else if (turkeyCountries.contains(acc.BillingCountry)) {
                    acc.Customer_Region__c = 'Turkey';
                    acc.CurrencyIsoCode = 'EUR';
                } else {
                    acc.Customer_Region__c = null;
                }
            }
            // if Customer Region is null then need to get the customer region from the current user's region
            if (acc.Customer_Region__c == null && currentUserRegion != null && currentUserRegion.contains('Europe')) {
                acc.Customer_Region__c = currentUserRegion;
            }
               // Check if Customer Region contains 'Europe' and update Plant Region accordingly
            if (acc.Customer_Region__c != null && acc.Customer_Region__c.contains('Europe')) {
                acc.Plant_Region__c = 'Europe';
                acc.Business_Unit__c = 'Carmeuse';
            }     
        }
    }
}