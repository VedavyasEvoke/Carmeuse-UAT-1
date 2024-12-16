/***************************************************************************************************************************************************
# Class Name  = "ev_SFBhoomiService"
# Author      = Naganjaneya Lakshman
# Description = This class is to integrate between Salesforce and Bhoomi.

# Change Log :
============================================================================================================
Date                     Changed By                        Change Description
============================================================================================================
20/03/2024               Naganjaneya Lakshman              Original Version
**************************************************************************************************************************************************/

global class ev_SFBhoomiService {

    global SBQQ__Quote__c quo{get;set;}  
    global id quoId{get;set;}
    global ev_SFBhoomiService(ApexPages.StandardController controller) {
    quo =  (SBQQ__Quote__c) controller.getRecord();
    quoId = Quo.Id;
    }
        
   global static void sendQuotes() {  
		
        String quoteid = ApexPages.currentPage().getparameters().get('ID'); 
       //string quoteid;
       
        SBQQ__Quote__c Quo = [Select SBQQ__Account__r.Name, SBQQ__Account__r.AccountNumber, SBQQ__Account__r.Legal_Name__c, SBQQ__Account__r.ParentId, SBQQ__Account__r.Customer_Group_Code__c,
                              SBQQ__Account__r.MSD_ID__c, Id, MSD_Quote_Number__c, (select id, SBQQ__ProductCode__c, SBQQ__Quantity__c, MSD_Quote_Line_ID__c                                                   
                              From SBQQ__LineItems__r)
                              From SBQQ__Quote__c 
                              Where Id =: quoteid];
                              
        system.debug('SOQL JSON'+JSON.serialize(Quo));

        /*List<SBQQ__Quote__c> Quos = [Select SBQQ__Account__r.Name, SBQQ__Account__r.AccountNumber, SBQQ__Account__r.Legal_Name__c, SBQQ__Account__r.ParentId, SBQQ__Account__r.Customer_Group_Code__c,
                                SBQQ__Account__r.MSD_ID__c, Id, MSD_Quote_Number__c, (select id, SBQQ__ProductCode__c, SBQQ__Quantity__c, MSD_Quote_Line_ID__c                                                   
                                From SBQQ__LineItems__r)
                                From SBQQ__Quote__c 
                                Where Id =: quoteid];*/
       
        
        //String JsonString=JSON.serialize(Quo);
       	//system.debug('==jsonbody1=='+JsonString);
       
       Map<String, Object> parentToChildMap = new Map<String, Object>();
        
        // Populate the Customer object
        Map<String, Object> customerMap = new Map<String, Object>();
        customerMap.put('CustomerNumber', Quo.SBQQ__Account__r.AccountNumber);
        customerMap.put('Name', Quo.SBQQ__Account__r.Name);
        customerMap.put('Legal_Name', Quo.SBQQ__Account__r.Legal_Name__c);
        customerMap.put('ParentId', Quo.SBQQ__Account__r.ParentId);
        customerMap.put('Customer_Group', Quo.SBQQ__Account__r.Customer_Group_Code__c);
        customerMap.put('MSD_Customer_Id', Quo.SBQQ__Account__r.MSD_ID__c);
        
        // Populate the Quote object
        Map<String, Object> quoteMap = new Map<String, Object>();
        quoteMap.put('SF_Quote_Id', Quo.Id);
        quoteMap.put('MSD_Quote_ID', Quo.MSD_Quote_Number__c);
        
        // Populate the QuoteLines list
        List<Map<String, Object>> quoteLinesList = new List<Map<String, Object>>();
        for (SBQQ__QuoteLine__c line : Quo.SBQQ__LineItems__r) {
            Map<String, Object> quoteLineMap = new Map<String, Object>();
            quoteLineMap.put('SF_QuoteLine_Id', line.Id);
            quoteLineMap.put('SBQQ_ProductCode', line.SBQQ__ProductCode__c);
            quoteLineMap.put('SBQQ_Quantity', line.SBQQ__Quantity__c);
            quoteLineMap.put('MSD_QuoteLine_Id', line.MSD_Quote_Line_ID__c);
            quoteLinesList.add(quoteLineMap);
        }
        
        // Add the populated maps to parentToChildMap
        
        parentToChildMap.put('QuoteLines', quoteLinesList);
        parentToChildMap.put('Quote', quoteMap);
        parentToChildMap.put('Customer', customerMap);
        
        String jsonString = JSON.serializePretty(parentToChildMap);
        system.debug('Serialized JSON: ' + jsonString);

        /*
        // Serialize parent and child records into JSON format
        List<Map<String, Object>> serializedRecords = new List<Map<String, Object>>();
        for (SBQQ__Quote__c Quote : Quos) {
            Map<String, Object> parentMap = new Map<String, Object>();
            parentMap.put('ParentId', Quote.Id);
            parentMap.put('ParentName', Quote.MSD_Quote_Number__c);
            parentMap.put('CustomerNumber', Quote.SBQQ__Account__r.AccountNumber);
            parentMap.put('CustomerName', Quote.SBQQ__Account__r.Name);
            parentMap.put('CustomerLegalName', Quote.SBQQ__Account__r.Legal_Name__c);
            parentMap.put('CustomerParentId', Quote.SBQQ__Account__r.ParentId);
            parentMap.put('CustomerGroup', Quote.SBQQ__Account__r.Customer_Group_Code__c);
            parentMap.put('CustomerMSDId', Quote.SBQQ__Account__r.MSD_ID__c);

            List<Map<String, Object>> QuoLines = new List<Map<String, Object>>();
            for (SBQQ__QuoteLine__c QuoteLine : Quote.SBQQ__LineItems__r) {
                Map<String, Object> childMap = new Map<String, Object>();
                childMap.put('ChildId', QuoteLine.Id);
                childMap.put('ChildProductCode', QuoteLine.SBQQ__ProductCode__c);
                childMap.put('ChildQuantity', QuoteLine.SBQQ__Quantity__c);
                childMap.put('ChildQuoteLineID', QuoteLine.MSD_Quote_Line_ID__c);
                // Add more fields as needed

                QuoLines.add(childMap);
            }
            parentMap.put('QuoLines', QuoLines);
            serializedRecords.add(parentMap);
        }

        // Return the serialized JSON response
        // RestResponse res = RestContext.response;
        // res.addHeader('Content-Type', 'application/json');
        // res.responseBody = Blob.valueOf(JSON.serialize(serializedRecords));
        String jsonbody = JSON.serializePretty(serializedRecords);
        system.debug('==jsonbodymap=='+jsonbody);

       */
       //JSON.stringify(sortMyObj, Object.keys(sortMyObj).sort());

        /*ev_SFBhoomiWrapper w = new ev_SFBhoomiWrapper();

        ev_SFBhoomiWrapper.Customer wc = new ev_SFBhoomiWrapper.Customer();
        wc.CustomerNumber = Quo.SBQQ__Account__r.AccountNumber;
        wc.Name = Quo.SBQQ__Account__r.Name;
        wc.Legal_Name = Quo.SBQQ__Account__r.Legal_Name__c;
        wc.ParentId = Quo.SBQQ__Account__r.ParentId;
        wc.Customer_Group = Quo.SBQQ__Account__r.Customer_Group_Code__c;
       
        w.Customer = wc; 

        ev_SFBhoomiWrapper.Quote wq = new ev_SFBhoomiWrapper.Quote();
        wq.SF_Quote_Id = Quo.Id;
        wq.MSD_Quote_ID = Quo.MSD_Quote_Number__c;
       
       	w.Quote = wq;	

        List<ev_SFBhoomiWrapper.QuoteLines> wqlist=  new List<ev_SFBhoomiWrapper.QuoteLines>();
        for(SBQQ__QuoteLine__c ql:Quo.SBQQ__LineItems__r){
            ev_SFBhoomiWrapper.QuoteLines quoteline = new ev_SFBhoomiWrapper.QuoteLines();
            quoteline.SF_QuoteLine_Id = ql.id;
            quoteline.SBQQ_ProductCode = ql.SBQQ__ProductCode__c;
            quoteline.SBQQ_Quantity = ql.SBQQ__Quantity__c;
            quoteline.MSD_QuoteLine_Id = ql.MSD_Quote_Line_ID__c;
            wqlist.add(quoteline);
        }
		
        w.QuoteLines = wqlist;
       
        String jsonbody = JSON.serialize(w);
	    system.debug('==jsonbody=='+jsonbody);*/

		/*
        // Create an instance of ev_SFBhoomiWrapper
        ev_SFBhoomiWrapper wrapper = new ev_SFBhoomiWrapper();

        // Populate the Customer object
        wrapper.Customer = new ev_SFBhoomiWrapper.Customer();
        wrapper.Customer.CustomerNumber = Quo.SBQQ__Account__r.AccountNumber;
        wrapper.Customer.Name = Quo.SBQQ__Account__r.Name;
        wrapper.Customer.Legal_Name = Quo.SBQQ__Account__r.Legal_Name__c;
        wrapper.Customer.ParentId = Quo.SBQQ__Account__r.ParentId;
        wrapper.Customer.Customer_Group = Quo.SBQQ__Account__r.Customer_Group_Code__c;
        wrapper.Customer.MSD_Customer_Id = Quo.SBQQ__Account__r.MSD_ID__c;
        
        // Populate the Quote object
        wrapper.Quote = new ev_SFBhoomiWrapper.Quote();
        wrapper.Quote.SF_Quote_Id = Quo.Id;
        wrapper.Quote.MSD_Quote_ID = Quo.MSD_Quote_Number__c;
        
        // Populate the QuoteLines list
        wrapper.QuoteLines = new List<ev_SFBhoomiWrapper.QuoteLines>();
        for (SBQQ__QuoteLine__c line : Quo.SBQQ__LineItems__r) {
            ev_SFBhoomiWrapper.QuoteLines quoteLine = new ev_SFBhoomiWrapper.QuoteLines();
            quoteLine.SF_QuoteLine_Id = line.Id;
            quoteLine.SBQQ_ProductCode = line.SBQQ__ProductCode__c;
            quoteLine.SBQQ_Quantity = line.SBQQ__Quantity__c;
            quoteLine.MSD_QuoteLine_Id = line.MSD_Quote_Line_ID__c;
            wrapper.QuoteLines.add(quoteLine);
        }
        
        string JsonString1 = JSON.serializePretty(wrapper);
        system.debug('==jsonbody2=='+JsonString1); */

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setHeader('Accept', 'application/json');
        request.setBody(jsonString);
        request.setTimeout(120000);
		
		request.setEndpoint('callout:Quote_Credentials_Bhoomi');

		HttpResponse response = new HttpResponse();
        response = http.send(request);

		try {
            if(response.getStatusCode()==200){
                //update Quote and Quote line dynmaic ids in respective records and also account dynamic id using list
            	}
        	}
        catch (Exception e) {
            throw new AuraHandledException('Send SF Quote Details to Bhoomi: '+ e.getMessage());    
        }
        
        }
}