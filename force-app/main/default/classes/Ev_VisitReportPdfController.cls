/**
* Class Name         : Ev_VisitReportPdfController
* Developer          : D Sridhar           
* Created Date       :
* @description       : Controller class for Ev_VisitReportPdf VisualForce page.
* Last Modified Date : 
*/
public class Ev_VisitReportPdfController {
    //public String visitReportId {get; set;}
    //public List<Field> visitReportFields {get; set;}
    //public Visit_Report__c visitReport {get; set;}
    
    /**
* @description Fetches Visit Report fields.
*/
    public static Map<String, Object> fetchVisitReportFields() {
        List<Field> visitReportFields = new List<Field>();
        Map<String,Set<String>> parentFieldsMap = new Map<String,Set<String>>();
        Map<String,Schema.SObjectField> allFields = Schema.getGlobalDescribe().get('Visit_Report__c').getDescribe().fields.getMap();
        
        for(Schema.FieldSetMember fieldset : SObjectType.Visit_Report__c.fieldSets.getMap().get('Email_Notification_Fields').getFields()) {
            String fieldName = fieldset.getFieldPath();
            String parentObjectName;
            if(allFields.get(fieldName)?.getDescribe().getType() == Schema.DisplayType.Reference) {
                parentObjectName = allFields.get(fieldName)?.getDescribe().getReferenceTo()[0]?.getDescribe().getName();
                fieldName = (fieldName.endsWith('__c') 
                             ? fieldName.replaceAll('__c', '__r') 
                             : (fieldName.endsWith('Id')
                                ? fieldName.substring(0, fieldName.lastIndexOf('Id')) 
                                : fieldName)) + '.Name';
                System.debug('parentObjectName => ' + parentObjectName);
            }
            
            if(fieldName.contains('.')) {
                parentObjectName = parentObjectName ?? String.valueOf(fieldset.getSObjectField().getDescribe().getSObjectType());
                String parentFieldName = fieldName.split('\\.')[1];
                String lookupFieldName = fieldName.split('\\.')[0];
                lookupFieldName = lookupFieldName.endsWith('__r') 
                    ? lookupFieldName.replaceAll('__r', '__c') 
                    : (lookupFieldName + 'Id');
                        visitReportFields.add(new Field(fieldset.getLabel(), fieldName, lookupFieldName, parentObjectName, parentFieldName));
                
                Set<String> fields = parentFieldsMap.get(parentObjectName) ?? new Set<String>();
                fields.add(parentFieldName);
                parentFieldsMap.put(parentObjectName, fields);
            } else {
                visitReportFields.add(new Field(fieldset.getLabel(), fieldName));
            }
        }
        
        return new Map<String, Object>{'visitReportFields' => visitReportFields, 'parentFieldsMap' => parentFieldsMap};
            }
    
    /**
* @description Generates Pdf Content.
* @param visitReport - Visit_Report__c record
* @param visitReportFields - Visit_Report__c Fields that should be displayed in the pdf
* @return Pdf Content
*/
    public static String generatePdfContent(Visit_Report__c visitReport, List<Field> visitReportFields, Map<Id,sObject> parentRecordMap) {
        String pdfContent = '<html><body>';
        pdfContent += '<div width="100%"><div>';
        pdfContent += '<table width="100%" cellpadding="5" style="page-break-inside: auto;">';
        pdfContent += '<tr><td style="font-family: sans-serif; font-size: 18px; font-weight: bold; color: #0a487b;">CARMEUSE</td></tr>';
        pdfContent += '<tr><td bgcolor="#0a487b"><div style="font-family: sans-serif; font-size: 18px; font-weight: bold; color: white;">';
        pdfContent += '<font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Visit Report Form</font></div></td></tr></table></div>';
        pdfContent += '<div>';
        
        for(Field field : visitReportFields) {
            pdfContent += '<div style="font-family: sans-serif; font-weight: bold; font-size: 12px; color: #444444;">' + field.label + '</div>';
            
            if(field.lookupFieldName != null) {
                System.debug(parentRecordMap.get((String)visitReport.get(field.lookupFieldName)));
                System.debug(parentRecordMap.get((String)visitReport.get(field.lookupFieldName))?.get(field.parentFieldName));
                pdfContent += '<div style="font-family: sans-serif; font-size: 12px;">' + (parentRecordMap.get((String)visitReport.get(field.lookupFieldName))?.get(field.parentFieldName) ?? '') + '</div><br>';
            } else {
                pdfContent += '<div style="font-family: sans-serif; font-size: 12px;">' + (visitReport.get(field.name) ?? '') + '</div><br>';
            }
        }
        pdfContent += '</div>';
        
        pdfContent += '<div style="font-family: sans-serif; font-weight: bold; font-size: 12px; color: #444444;">Site Visit Assignees</div>';
        List<String> assigneeNames = new List<String>();
        for(Site_Visit_Assignee__c assignee : [SELECT Id, Assigned_To__r.Name FROM Site_Visit_Assignee__c WHERE Site_Visit_Report__c = :visitReport.Id]) {
            assigneeNames.add(assignee.Assigned_To__r.Name);
        }
        pdfContent += '<div style="font-family: sans-serif; font-size: 12px;">' + String.join(assigneeNames, ', ') + '</div>';
        
        return pdfContent + '</div></body></html>';
    }
    
    /**
* @description Gets the VisualForce content as Pdf and stores it in Visit Report Record's Attachment Related List.
* @return List<ContentDocumentLink> List of ContentDocumentLink Records created
*/
    @InvocableMethod(label='Get Visit Report Pdf' description='Returns the ContentDocumentId of Visit Report Pdf')
    public static List<ContentDocumentLink> getVisitReportPdf(List<Input> inputs) {
        List<ContentVersion> cvs = new List<ContentVersion>();
        List<ContentDocument> cds = new List<ContentDocument>();
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
        
        Map<String,Object> fetchVisitReportFieldsOp = fetchVisitReportFields();
        List<Field> visitReportFields = (List<Field>)fetchVisitReportFieldsOp.get('visitReportFields');
        Map<String,Set<String>> parentFieldsMap = (Map<String,Set<String>>)fetchVisitReportFieldsOp.get('parentFieldsMap');
        Map<Id,sObject> parentRecordMap = new Map<Id,sObject>();
        Map<String,Set<String>> parentIdsMap = new Map<String,Set<String>>();
        
        System.debug(visitReportFields);
        for(Input input : inputs) {
            for(Field field : visitReportFields) {
                if(field.lookupFieldName != null && String.isNotBlank((String)input.visitReport.get(field.lookupFieldName))) {
                    Set<String> ids = parentIdsMap.get(field.parentObjectName) ?? new Set<String>();
                    ids.add((String)input.visitReport.get(field.lookupFieldName));
                    parentIdsMap.put(field.parentObjectName, ids);
                }
            }
        }
        
        for(String objectName : parentFieldsMap.keySet()) {
            if(parentIdsMap.get(objectName) != null && !parentIdsMap.get(objectName).isEmpty()) {
                parentRecordMap.putAll(
                    new Map<Id,sObject>(Database.query('SELECT ' + String.join(parentFieldsMap.get(objectName), ', ') + ' FROM ' + objectName + ' WHERE Id IN (\'' + String.join(parentIdsMap.get(objectName), '\', \'') + '\')'))
                );
            }
        }
        
        for(Input input : inputs) {
            Blob visitReportPdf;
            try {
                String pdfContent = generatePdfContent(input.visitReport, visitReportFields, parentRecordMap);
                System.debug(pdfContent);
                visitReportPdf = Blob.toPdf(pdfContent);
            } catch (Exception e) {
                visitReportPdf = Blob.valueOf(e.getMessage());
            }
            
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.VersionData = visitReportPdf;
            contentVersion.Title = ''+inputs[0].visitReport.get('VisitReportName__c');//'VisitReportPdfFor' + input.visitReportId; 
            contentVersion.ContentLocation= 's';
            contentVersion.PathOnClient=inputs[0].visitReport.get('VisitReportName__c')+'.pdf';//'VisitReportPdfFor' + input.visitReportId + '.pdf';
            cvs.add(contentVersion);
        }
        Database.insert(cvs);
        
        Map<Id,ContentVersion> cvsMap = new Map<Id,ContentVersion>(cvs);
        Set<Id> cvIds = cvsMap.keySet();
        cvs = [SELECT Id, Title, PathOnClient, ContentDocumentId FROM ContentVersion WHERE Id IN :cvIds WITH SECURITY_ENFORCED];
        for(Integer i = 0; i < cvs.size(); i++) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cvs[i].ContentDocumentId;
            cdl.LinkedEntityId = inputs[i].visitReportId;
            cdls.add(cdl);
        }
        Database.insert(cdls);
        return cdls;
    }
    
    
    /**
* @description Default Controller
*/
    /* public Ev_VisitReportPdfController() {
visitReportId = ApexPages.CurrentPage().getparameters().get('visitReportId');

this.fetchVisitReport();
} */
    
    
    /**
* @description Fetches Visit Report record
*/
    /* public void fetchVisitReport() {
visitReportFields = new List<Field>();
try {
List<String> visitReportFieldNames = new List<String>();
for(Schema.FieldSetMember fieldset : SObjectType.Visit_Report__c.fieldSets.getMap().get('Email_Notification_Fields').getFields()) {
visitReportFields.add(new Field(fieldset.getLabel(), fieldset.getFieldPath()));
visitReportFieldNames.add(fieldset.getFieldPath());
}
String query = 'SELECT ' + String.join(visitReportFieldNames, ', ') + ' FROM Visit_Report__c WHERE Id = \'' + visitReportId + '\'';
visitReport = Database.query(query);
} catch (Exception e) {
throw new AuraHandledException(e.getMessage());
}
} */
    
    
    /**
* @description Gets the VisualForce content as Pdf and stores it in Visit Report Record's Attachment Related List.
* @return List<ContentDocumentLink> List of ContentDocumentLink Records created
*/
    /* @InvocableMethod(label='Get Visit Report Pdf' description='Returns the ContentDocumentId of Visit Report Pdf')
public static List<ContentDocumentLink> getVisitReportPdf(List<Input> inputs) {
List<ContentVersion> cvs = new List<ContentVersion>();
List<ContentDocument> cds = new List<ContentDocument>();
List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();

for(Input input : inputs) {
PageReference visitReportPage = Page.Ev_VisitReportPdf;
visitReportPage.getParameters().put('visitReportId', input.visitReportId);

Blob visitReportPdf;
try {
visitReportPdf = visitReportPage.getContentAsPDF();
} catch (Exception e) {
visitReportPdf = Blob.valueOf(e.getMessage());
}

ContentVersion contentVersion = new ContentVersion();
contentVersion.VersionData = visitReportPdf;
contentVersion.Title = 'VisitReportPdfFor' + input.visitReportId; 
contentVersion.ContentLocation= 's';
contentVersion.PathOnClient='VisitReportPdfFor' + input.visitReportId + '.pdf';
cvs.add(contentVersion);
}
Database.insert(cvs);

Map<Id,ContentVersion> cvsMap = new Map<Id,ContentVersion>(cvs);
Set<Id> cvIds = cvsMap.keySet();
cvs = [SELECT Id, Title, PathOnClient, ContentDocumentId FROM ContentVersion WHERE Id IN :cvIds WITH SECURITY_ENFORCED];
for(Integer i = 0; i < cvs.size(); i++) {
ContentDocumentLink cdl = new ContentDocumentLink();
cdl.ContentDocumentId = cvs[i].ContentDocumentId;
cdl.LinkedEntityId = inputs[i].visitReportId;
cdls.add(cdl);
}
Database.insert(cdls);
return cdls;
} */
    
    /**
* @description
*/
    public class Input {
        @InvocableVariable
        public Id visitReportId;
        @InvocableVariable
        public Visit_Report__c visitReport;
    }
    
    /**
* @description
*/    
    public class Field {
        public String label { get; set; }
        public String name { get; set; }
        public String lookUpFieldName { get; set; }
        public String parentObjectName { get; set; }
        public String parentFieldName { get; set; }
        public Field(String label, String name) {
            this.label = label;
            this.name = name;
        }
        public Field(String label, String name, String lookUpFieldName, String parentObjectName, String parentFieldName) {
            this.label = label;
            this.name = name;
            this.lookUpFieldName = lookUpFieldName;
            this.parentObjectName = parentObjectName;
            this.parentFieldName = parentFieldName;
        }
    }
}