/**
 * @description       : 
 * @author            : ppadishala@evoketechnologies.com
 * @group             : 
 * @last modified on  : 12-13-2024
 * @last modified by  : ppadishala@evoketechnologies.com
**/
public with sharing class FieldSetUtil {

    /**
     * Method to fetch field properties from a FieldSet
     * 
     * @param sObjectName Name of the SObject
     * @param fieldSetName Name of the FieldSet
     * @return List of Field Properties as Map<String, Object>
     */
    public static List<Map<String, Object>> getFieldSetProperties(String sObjectName, String fieldSetName) {
        // Create a list to store field properties
        List<Map<String, Object>> fieldPropertiesList = new List<Map<String, Object>>();

        try {
            // Get the FieldSet based on SObject name and FieldSet name
            Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
            System.debug('globalDescribeMap: ' + globalDescribeMap);
            Schema.SObjectType sObjectType = globalDescribeMap.get(sObjectName);
            if (sObjectType == null) {
                throw new IllegalArgumentException('SObject ' + sObjectName + ' does not exist.');
            }

            Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
            Map<String, Schema.FieldSet> fieldSets = describeResult.fieldSets.getMap();
            Schema.FieldSet fieldSet = fieldSets.get(fieldSetName);

            if (fieldSet == null) {
                throw new IllegalArgumentException('FieldSet ' + fieldSetName + ' does not exist on SObject ' + sObjectName);
            }

            // Iterate through the fields in the FieldSet
            Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
            for (Schema.FieldSetMember field : fieldSet.getFields()) {
                Map<String, Object> fieldProps = new Map<String, Object>();

                // Use the field describe from the SObjectField
                Schema.SObjectField sObjectField = fieldMap.get(field.getFieldPath());
                if (sObjectField != null) {
                    Schema.DescribeFieldResult fieldDescribe = sObjectField.getDescribe();

                    fieldProps.put('label', fieldDescribe.getLabel());
                    fieldProps.put('name', fieldDescribe.getName());
                    fieldProps.put('type', fieldDescribe.getType());
                    fieldProps.put('length', fieldDescribe.getLength());
                    fieldProps.put('isCalculated', fieldDescribe.isCalculated());
                    fieldProps.put('isNillable', fieldDescribe.isNillable());
                    fieldProps.put('isCreateable', fieldDescribe.isCreateable());
                    fieldProps.put('isUpdateable', fieldDescribe.isUpdateable());
                    fieldProps.put('isCustom', fieldDescribe.isCustom());

                    // Add the field properties to the list
                    fieldPropertiesList.add(fieldProps);
                }
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new IllegalArgumentException('Failed to retrieve FieldSet properties. ' + e.getMessage());
        }

        return fieldPropertiesList;
    }
}