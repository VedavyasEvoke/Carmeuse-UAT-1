import { LightningElement, api, wire } from 'lwc';
import getQuoteLines from '@salesforce/apex/QuoteLineController.getQuoteLines';
import getPicklistValues from '@salesforce/apex/QuoteLineController.getPicklistValues';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class QuoteLineDataTable extends LightningElement {
    @api quoteId; // The quoteId passed from the parent component

    // Table columns definition
    columns = [
        { label: 'Quantity', fieldName: 'SBQQ__Quantity__c', editable: true },
        { label: 'Primary', fieldName: 'Primary__c', editable: true },
        { 
            label: 'Incoterms', 
            fieldName: 'Incoterms__c', 
            type: 'picklist', 
            editable: true, 
            typeAttributes: { 
                placeholder: 'Select...', 
                options: [], 
                value: { fieldName: 'Incoterms__c' } 
            }
        },
        { 
            label: 'SE Shipping Type', 
            fieldName: 'SE_Shipping_Type__c', 
            type: 'picklist', 
            editable: true, 
            typeAttributes: { 
                placeholder: 'Select...', 
                options: [], 
                value: { fieldName: 'SE_Shipping_Type__c' } 
            }
        },
        { label: 'Destination', fieldName: 'Destination__c', editable: true },
        { label: 'Ship To', fieldName: 'Ship_To__r.Name' }
    ];

    // Data and picklist values initialization
    quoteLines = [];
    picklistValues = { SE_Shipping_Type__c: [], Incoterms__c: [] };

    // Fetch picklist values from Apex
    @wire(getPicklistValues)
    wiredPicklistValues({ data, error }) {
        if (data) {
            this.picklistValues = data;
            this.updatePicklistOptions();
        } else if (error) {
            this.showErrorToast(error);
        }
    }

    // Fetch Quote Line data
    @wire(getQuoteLines, { quoteId: '$quoteId' })
    wiredQuoteLines({ data, error }) {
        if (data) {
            this.quoteLines = data.map(row => ({
                ...row,
                SE_Shipping_Type__c: row.SE_Shipping_Type__c || '',
                Incoterms__c: row.Incoterms__c || ''
            }));
        } else if (error) {
            this.showErrorToast(error);
        }
    }

    // Update picklist options in columns dynamically
    updatePicklistOptions() {
        this.columns = this.columns.map(col => {
            if (col.type === 'picklist') {
                if (col.fieldName === 'SE_Shipping_Type__c') {
                    col.typeAttributes.options = this.picklistValues.SE_Shipping_Type__c.map(value => ({ label: value, value }));
                }
                if (col.fieldName === 'Incoterms__c') {
                    col.typeAttributes.options = this.picklistValues.Incoterms__c.map(value => ({ label: value, value }));
                }
            }
            return col;
        });
    }

    // Handle saving the edited data
    handleSave(event) {
        const draftValues = event.detail.draftValues;
        console.log('Draft Values:', draftValues);
        // Save the draft values to Salesforce via Apex or other means
        this.showSuccessToast('Records saved successfully');
    }

    // Show error toast message
    showErrorToast(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error'
            })
        );
    }

    // Show success toast message
    showSuccessToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: message,
                variant: 'success'
            })
        );
    }
}