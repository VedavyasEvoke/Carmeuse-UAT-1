import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchApproverRecords from '@salesforce/apex/Ev_ContractReviewApprovalsController.fetchApproverRecords';

export default class Ev_ContractReviewApprovals extends LightningElement {
    @api recordId;
    @track approvers;
    columns = [
        { label: 'Role', fieldName: 'Role_Name__c' },
        { label: 'User', fieldName: 'user' },
        { label: 'Date/Time', fieldName: 'dateTime' },
        { label: 'Approved', fieldName: 'isApproved', type: 'Checkbox' }
    ];

    connectedCallback() {
        this.getApproverRecords();
    }

    /* Calling Apex method with parameters   */
    getApproverRecords() {
        let _parameters = JSON.stringify({
            recordId: this.recordId
        });
        fetchApproverRecords({ parameters: _parameters }).then(result => {
            this.prepareApproversData(result);
        }).catch(error => {
            this.showToast({
                title: 'Some error has occured',
                message: 'Please contact your administrator.',
                variant: 'error'
            });
        });
    }

    /* Passing result to the fieldname */
    prepareApproversData(result) {
        if (result) {
            let approversData = JSON.parse(JSON.stringify(result));
            approversData.forEach(record => {
                record.user = record.First_Name__c + ' ' + record.Last_Name__c;
                record.dateTime = this.convertDateTime(record.CreatedDate);
            });
            this.approvers = approversData;
        }
    }

    /* Converting date/time to MM/DD/YYYY format*/
    convertDateTime(fullDate) {
        let dateTime = fullDate.split('T');
        let date = dateTime[0].split('-');
        let time = dateTime[1].split('.');
        return (date[1] + '/' + date[2] + '/' + date[0] + ' ' + time[0]);
    }

    /* Showing toast message if any error occured*/
    showToast(toast) {
        const event = new ShowToastEvent({
            title: toast.title,
            message: toast.message,
            variant: toast.variant
        });
        this.dispatchEvent(event);
    }
}