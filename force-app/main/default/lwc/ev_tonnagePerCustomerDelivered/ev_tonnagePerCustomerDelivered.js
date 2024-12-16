import { LightningElement, api, wire, track } from 'lwc';
import getTonnageInfo from '@salesforce/apex/ev_TonnagePerCustController.getTonnageInfo';

export default class ev_tonnagePerCustomerDelivered extends LightningElement {
    @api recordId;
    @track parentAccount = {};
    @track error;

    @wire(getTonnageInfo, { recordId: '$recordId' })
    wiredTonnageInfo({ error, data }) {
        if (data) {
            if (data.length > 0) {
                this.parentAccount = data[0];
                console.log('Parent Account:', this.parentAccount);
            } else {
                this.parentAccount = {};
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.parentAccount = {};
        }
    }

    
}