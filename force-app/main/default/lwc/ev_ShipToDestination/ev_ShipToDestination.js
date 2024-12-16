import { LightningElement,api, track } from 'lwc';
import { getRecord, createRecord, updateRecord, deleteRecord, getRecordUi, getFieldValue, getFieldDisplayValue, getRecordCreateDefaults, createRecordInputFilteredByEditedFields, generateRecordInputForCreate, generateRecordInputForUpdate } from 'lightning/uiRecordApi';
/* https://developer.salesforce.com/docs/platform/lwc/guide/reference-lightning-ui-api-record.html */
export default class Ev_ShipToDestination extends LightningElement {
    @api recordId;



}