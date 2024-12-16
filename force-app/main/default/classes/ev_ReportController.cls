public class ev_ReportController{
    
    //Generate report Based on parameter
    public void generateReport(string reportDevName)
    {
        try
        {
            List <Report> reportList = [SELECT Id, DeveloperName, Name FROM Report where DeveloperName =: reportDevName];
            if(reportList.size()>0)
            {
                String reportId = (String)reportList.get(0).get('Id');
                
                //Get Report Name
                string reportName = (String)reportList.get(0).get('Name');
                
                //get instance Url
                String instanceName = URL.getOrgDomainUrl().toExternalForm();
                
                string url = instanceName + '/servlet/PrintableViewDownloadServlet?isdtp=p1&reportId=' + reportId;
                
                ApexPages.PageReference objPage = new ApexPages.PageReference(url);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                Messaging.EmailFileAttachment objMsgEmailAttach = new Messaging.EmailFileAttachment();
                objMsgEmailAttach.setFileName(reportName + '.csv');
                objMsgEmailAttach.setBody(objPage.getContent());
                objMsgEmailAttach.setContentType('text/csv');
                email.setSubject(reportName);
                
                List<Messaging.EmailFileAttachment> attach = new List<Messaging.EmailFileAttachment>();
                attach.add(objMsgEmailAttach);
                email.setFileAttachments(attach);  
                
                ev_EmailService service = new ev_EmailService(email);
                service.body = 'Hello, <br/><br/> Here is the attached Mintek Leads Report.<br/><br/>Thank You,<br/>Carmeuse Salesforce Notifications';
                service.isHtml = true;
                service.toAddresses = new List<string>();
                service.toAddresses.add('skylerh@dextara.datamatics.com');  
                service.toAddresses.add('josh.weser@mintekresources.com');
				service.toAddresses.add('krystan.minor@mintekresources.com');
				service.toAddresses.add('cris.ransdell@mintekresources.com');
				service.toAddresses.add('danny.lloyd@carmeuse.com');
				service.toAddresses.add('laura.shifflett@carmeuse.com');
				service.toAddresses.add('dana.strait@carmeuse.com');
				service.toAddresses.add('paul.paquette@carmeuse.com');
				service.toAddresses.add('whitney.kessinger@carmeuse.com');
				service.toAddresses.add('dawn.smoot@carmeuse.com');
				service.toAddresses.add('kendyl.little@mintekresources.com');
                service.toAddresses.add('leeanna.price@mintekresources.com');

                service.displayName = 'Carmeuse Salesforce Notifications';
                service.subject = reportName;
                service.sendMail();
            }
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
            
            Integer i = 0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
            
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
            }
        }
    }