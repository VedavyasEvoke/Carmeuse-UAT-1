import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['SBQQ__Quote__c.Customer_Region__c'];

export default class Ev_pricingCouncil extends LightningElement {
    @api recordId;

    @track isNorthAmerica = false;
    @track isEurope = false;
    @track isOther = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredQuote({ error, data }) {
        if (data) {
            this.determineRegion(data.fields.Customer_Region__c.value);
        } else if (error) {
            this.isOther = true; // Default to "Other" in case of error
        }
    }

    /* Determines the Customer Region and sets the flags accordingly */
    determineRegion(customerRegion) {
        if (!customerRegion) {
            // Handle the case when Customer_Region__c is null or undefined
            this.isOther = true;
            return;
        }

        switch(customerRegion) {
            case 'North America':
                this.isNorthAmerica = true;
                this.isEurope=false;
                break;
            case 'Western Europe':
            case 'Central Europe':
            case 'Eastern Europe':
            case 'Turkey':
                this.isEurope = true;
                this.isNorthAmerica =false;
                break;
            default:
                this.isOther = true;
        }
    }
}