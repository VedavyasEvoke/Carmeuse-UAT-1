public class ev_redirecttoAddProducts {
    @InvocableMethod
    public static List<String> constructAddProductsURL(List<Id> quoteIds ){ 
        
        // CONSTRUCT URL FOR CPQ CART
       
        String sfdcBaseURL = URL.getOrgDomainURL().toExternalForm();
        String targetURL = sfdcBaseURL.replace('-c', '-sbqq') + '/apex/sbqq__sb?id=' + quoteIds[0];
        
        // Return the URL as a single-item list
        List<String> urlList = new List<String>();
        urlList.add(targetURL);
        system.debug('Url'+urlList);
        return urlList;
    }
}