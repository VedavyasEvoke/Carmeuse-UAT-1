public class MessagingHelper {
    public static void CreateNewLeadRecord(String firstName, String lastName, String email, String title, String phone, String fax, 
                                           String rating, String industry, Decimal annualRevenue, String website, String company, String status, 
                                           String city, String state, String country, String postalCode) {
        // Check if a lead with the same email already exists
        List<Lead> existingLeads = [SELECT Id FROM Lead WHERE Email = :email LIMIT 1];
        // If a lead with the same email already exists, don't insert a new one
        if (!existingLeads.isEmpty()) {
            System.debug('Lead with the same email already exists. Email: ' + email);
            return;
        }
        // If no existing lead found, proceed to create a new lead record
        Lead ldRecord = new Lead();
        ldRecord.FirstName = firstName;
        ldRecord.LastName = lastName;
        ldRecord.Email = email;
        ldRecord.Title = title;
        ldRecord.Phone = phone;
        ldRecord.Fax = fax;
        ldRecord.Rating = rating;
        ldRecord.Industry = industry;
        ldRecord.AnnualRevenue = annualRevenue;
        ldRecord.Website = website;
        ldRecord.Company = company;
        ldRecord.Status = status;
        ldRecord.City = city;
        ldRecord.State = state;
        ldRecord.Country = country;
        ldRecord.PostalCode = postalCode;
        // Insert the lead record
        Insert ldRecord;
        System.debug('Lead Record has been Inserted Successfully. Record ID: ' + ldRecord.Id);
        // Send the Email Alert
        SendEmailAlert(ldRecord);
    }
 
    public static void SendEmailAlert(Lead ldRecord) {
        if (ldRecord.Id != null && ldRecord.Email != null) {
            // Create a new email message
            Messaging.SingleEmailMessage sEmail = new Messaging.SingleEmailMessage();
            sEmail.setToAddresses(new String[]{ldRecord.Email});
            sEmail.setSubject('Congratulations ' + ldRecord.FirstName + ' ' + ldRecord.LastName + '...!! Your Personal Loan Application Submitted.');
            sEmail.setPlainTextBody('Your email content goes here.'); // You can also use HTML content
 
            // Generate the PDF content dynamically
            String emailContent = 'Dear <b>'+ ldRecord.FirstName + ' '+ ldRecord.LastName+ '</b>,<br/><br/>'+
                    'Thanks for showing your interest in our Personal Loans Services. <br/><br/>'+
                    'We are pleased to inform you, that your Personal Loan Application has been submitted Successfully. <br/><br/>'+
                    'Here are your Application Details....: <br/><br/>'+
                    'Application Reference Number : '+ ldRecord.Id+
                    '<br/>Applicant Name ........: '+ ldRecord.FirstName + ' '+ ldRecord.LastName+
                    '<br/>Current Designation is....: '+ ldRecord.Title+
                    '<br/>Current Employer Name is.....: '+ ldRecord.Company +
                    '<br/>Current CTC is......: '+ ldRecord.AnnualRevenue +
                    '<br/>Applicant Rating is......: '+ ldRecord.Rating+
                    '<br/>Industry Name is........: '+ ldRecord.Industry+
                    '<br/>Applicant Contact Number is....: '+ ldRecord.Phone+
                    '<br/>Primary Email Address is.......: '+ ldRecord.Email+
                    '<br/>Applicant Fax Number is........: '+ ldRecord.Fax+
                    '<br/>Applicant Mailing Address is....: '+ ldRecord.City+ ','+ ldRecord.State+ ','+ ldRecord.Country+ '.PIN-'+ ldRecord.PostalCode+
                    '<br/><br/> Your Application has been send to the Loans Department. One of our Relationship Manager will contact you shortly.<br/><br/>'+
                    'Please Contact on the below address, if any queries. <br/><br/>'+
                    '<i>***This is a System-Generated Email. Please Do Not Reply.</i><br/><br/>'+
                    'Thanks & Regards, <br/> Personal Loans Department, <br/> ICICI Bank.';
 
            sEmail.setHtmlBody(emailContent);
 
            // Generate the PDF attachment dynamically
            Blob pdfBlob = Blob.toPdf(emailContent);
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(ldRecord.FirstName + ' '+ ldRecord.LastName+'.pdf');
            attachment.setContentType('application/pdf');
            attachment.setBody(pdfBlob);
 
            sEmail.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachment});
 
            // Send the email
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{sEmail});
        }
    }
}