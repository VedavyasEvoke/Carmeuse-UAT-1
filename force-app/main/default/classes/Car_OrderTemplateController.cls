public class Car_OrderTemplateController {
    
    public Id orderToDisplayId {get;set;}
    public String orderToDisplayLink {get;set;}
    public String orderNumber {get;set;}
    public String shippingAdress {get;set;}

    //This method is used to get OrderSummary
    public OrderSummary getorderdetails(){
        if(orderToDisplayId != null ){
            OrderSummary orderSummaryRecord = [Select Id, OriginalOrderId, Owner.Name, OrderedDate, OrderNumber,
                                                        OriginalOrder.ShippingStreet, OriginalOrder.ShippingCity,
                                                        OriginalOrder.ShippingCountry, OriginalOrder.ShippingPostalCode from OrderSummary 
                                                        Where Id = :orderToDisplayId];
            shippingAdress = orderSummaryRecord.OriginalOrder.ShippingStreet + ' ' + orderSummaryRecord.OriginalOrder.ShippingCity + 
                            ' ' + orderSummaryRecord.OriginalOrder.ShippingCountry + ' ' + orderSummaryRecord.OriginalOrder.ShippingPostalCode;
            return orderSummaryRecord;
        }
        return null;
    }

    // public String geturlinstance(){
    //     String instanceName = [select InstanceName from Organization limit 1].InstanceName;
    //     ID organisationID = UserInfo.getOrganizationId();
    //     Id documentID = '0153O000000Gj5b';
    //     String urlInstance = 'https://c.'+ instanceName + '.content.force.com/servlet/servlet.ImageServer?id=' + documentID + '&oid=' + organisationID ;
       
    //     return urlInstance;
    // }

    //This method is used to get url of logo in string format
    public String getStrLogoUrl(){
        list<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName = 'Carmeuse_Logo'];
		String strOrgId = UserInfo.getOrganizationId();
		String strLogoUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + 
            				'/servlet/servlet.ImageServer?id='+lstDocument[0].Id +
            				'&oid=' + strOrgId;
        return strLogoUrl;
    }
}