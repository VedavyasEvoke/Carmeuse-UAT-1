@isTest
public class Test_XfilesProcessFiles {
    @testSetup static void setup(){

        XFILES__Cloud_Storage_Provider__c csp = new XFILES__Cloud_Storage_Provider__c();
        csp.Name = 'X Files Sandbox';
        csp.XFILES__Provider_Type__c = 'SharePoint';
        csp.XFILES__Service_Endpoint_URL__c='https://google.com';
        csp.XFILES__Username__c = XFILES.XfileCryptoController.encrypt('3lYQMA57G9cm8SXhnBWRFr7iOpo42svbXNJi2FaQmtHXgL51bsbdeitqlhJuTIYLgKBsq96haxGbHIUXYNh++A==');
        csp.XFILES__Password__c = XFILES.XfileCryptoController.encrypt('F2FYAFyXfdSa4perZImf51gVO9KmrOYDI8S9EGCV5dy/tJpnUtybb2VCTYaFv4STOcqF6r8NipNe/aZuCzlR9g==');
        csp.XFILES__GDrive_Root_Folder_Id__c='01MPO6BI6YNBG2IC4G4FDYJRLZ7MMWRIMQ';
        csp.XFILES__Root_Folder_Name__c='XfilesPro Sandbox';
        csp.XFILES__API_Auth_Token__c= XFILES.XfileCryptoController.encrypt('Jv7GusQcrCaOcaRoro/3Cy91ZvwfpcQ/bozeQ5aU+PG3GG0oZAZZBBCpn81+WkJMcSEvyrV6CnGDajmrzh6bN5HJ5OPyR+3erVm62Og6FTmWafcmQ3HnU5F0zQ2wCQIh');
        insert csp;
        
        XFILES__Xfile_Manage_Folder_Hierarchy__c xmfh = new XFILES__Xfile_Manage_Folder_Hierarchy__c();
        xmfh.Name = 'SBQQ__Quote__c';
        xmfh.XFILES__Folder_Id__c = '01MPO6BI55TQHPEVZ2SZH34BCEF3HSTI6Z';
        xmfh.XFILES__Provider_Id__c = csp.Id;
        xmfh.XFILES__Provider_Name__c = csp.Name;
        xmfh.XFILES__Provider_Type__c = 'SharePoint';
        xmfh.XFILES__Is_Active__c = true;
        insert xmfh;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
		quote.SBQQ__ShippingState__c='test';      
        insert quote;
        
                                                                          
        XFILES__xFiles_Custom_Setting__c cs = new XFILES__xFiles_Custom_Setting__c();
        cs.XFILES__Send_Email_Error_Notification__c = true;
        insert cs;                                                                   
    }
         
    static testMethod void testMethodProcessContentDocument(){
        SBQQ__Quote__c qut = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        ContentVersion contentversion = new ContentVersion();
        contentversion.versionData = Blob.valueOf('a'.repeat(5242880));
        contentversion.title = 'File Title';
        contentversion.pathOnClient ='image.png';
        Insert contentversion;
        Id ids = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:
                  contentversion.Id FOR UPDATE].ContentDocumentId;
        ContentDocumentLink cdls = new ContentDocumentLink();
        cdls.LinkedEntityId = qut.Id;
        cdls.ContentDocumentId = ids;
        cdls.ShareType = 'v';
        system.assert(qut.id != null);
        
        Test.setMock(HttpCalloutMock.class, new Test_XfilesProcessFiles.Mock());
        //Test.setMock(HttpCalloutMock.class, new XFILES.Test_MockHttpGetAccessToken('accTokUsingRefToken'));
        Test.StartTest();
        Insert cdls;
        Test.StopTest();
    }
    
    //Mock to handle success request
    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            //To get accesstoken
            res.setBody('{"access_token": "ya29.GlsOBCiWsj-tEtxGuIj_SgmdXPbiWXFEdN14mlBfBzn0z-g8byo4oOVAzfw47A7IfGJxZksmC0ZepP_0eqUDv6Nyn1mGnrKhinqtbfpMz9h6s3t0fmRQhqst84L6","expires_in": 3600,"refresh_token": "1/W80y6DVHSzhqbht-RpQgbd8_0hWJPBZ-e2X5sD3plgh8CAFP7QuWDzA7IXxqmi8z","token_type": "Bearer"},responseFrom=GoogleDrive,status=OK,statusCode=200');               
            res.setStatusCode(200); 
            res.setStatus('OK');
            return res;
        }
    }
}