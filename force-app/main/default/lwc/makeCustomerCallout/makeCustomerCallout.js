import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import prepareForCallout from '@salesforce/apex/ev_AccountRestCallout.prepareForCallout';

export default class MakeCustomerCallout extends LightningElement {
    @track showSendBtn = true;
    _recordId;

    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        if(value) {
            this.sendRequest();
        }
    }

    closeQuickActionScreen() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleConfirmationCheckboxChange(event) {
        this.showSendBtn = !event.target.checked;
    }
    
    handleSend() {
        this.sendRequest();
    }

    sendRequest() {
        let parameterMap = JSON.stringify({ accountId: this.recordId });
        prepareForCallout({ parameters: parameterMap }).then(result => {
            console.log('prepareForCallout result => ', result);
            this.closeQuickActionScreen();
            this.showToast({
                title: 'Thank you for confirming.',
                message: 'Sending request is in progress.',
                variant: 'success'
            });
        }).catch(error => {
            console.log('prepareForCallout error => ', error);
            this.closeQuickActionScreen();
            this.showToast({
                title: 'Some error has occured',
                message: error,
                variant: 'error'
            });
        })
    }

    showToast(toastMessage) {
        this.dispatchEvent(new ShowToastEvent(toastMessage));
    }
}