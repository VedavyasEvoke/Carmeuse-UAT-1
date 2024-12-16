public class PicklistDataExporter {

    public static void exportPicklistsToCSV(String objectName) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        String csvContent = 'Field API Name, Field Label, Picklist Type, Picklist Value, Picklist Label\n';
        
        // Retrieve the object type from global describe
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        if (objType == null) {
            System.debug('Object not found: ' + objectName);
            return;
        }
        
        // Describe the object
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        
        // Iterate through fields and check for picklist fields
        for (Schema.SObjectField field : describeResult.fields.getMap().values()) {
            Schema.DescribeFieldResult fieldResult = field.getDescribe();
            
            if (fieldResult.getType() == Schema.DisplayType.PICKLIST || fieldResult.getType() == Schema.DisplayType.MULTIPICKLIST) {
                List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
                
                // Debugging: Log field information
                System.debug('Field: ' + fieldResult.getName() + ', Label: ' + fieldResult.getLabel() + ', Type: ' + fieldResult.getType());
                
                // Add field label name and picklist type to the CSV content
                String fieldLabel = fieldResult.getLabel();
                String picklistType = fieldResult.getType() == Schema.DisplayType.MULTIPICKLIST ? 'Multi-Select' : 'Single-Select';
                
                Boolean fieldAddedToCSV = false;
                
                for (Schema.PicklistEntry entry : picklistEntries) {
                    // Debugging: Log picklist entry information
                    System.debug('Picklist Entry: ' + entry.getValue() + ', Label: ' + entry.getLabel() + ', Active: ' + entry.isActive());
                    
                    // Filter out inactive and empty picklist values
                    if (entry.isActive() && !String.isBlank(entry.getLabel())) {
                        csvContent += fieldResult.getName() + ', ' + fieldLabel + ', ' + picklistType + ', ' + entry.getValue() + ', ' + entry.getLabel() + '\n';
                        fieldAddedToCSV = true;
                    }
                }
                
                // If no active and non-empty picklist entries were found, add the field with empty values
                if (!fieldAddedToCSV) {
                    csvContent += fieldResult.getName() + ', ' + fieldLabel + ', ' + picklistType + ', , \n';
                }
            }
        }
        
        // Debugging: Log final CSV content
        System.debug('CSV Content:\n' + csvContent);
        
        // Create the ContentVersion for the CSV file
        if (!String.isBlank(csvContent)) {
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = objectName + '_PicklistData';
            contentVersion.PathOnClient = objectName + '_PicklistData.csv';
            contentVersion.VersionData = Blob.valueOf(csvContent);
            contentVersion.ContentLocation = 'S';
            contentVersions.add(contentVersion);
            
            try {
                insert contentVersions;
            } catch (Exception e) {
                System.debug('Error inserting content versions: ' + e.getMessage());
            }
        }
    }
}