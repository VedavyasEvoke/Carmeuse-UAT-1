import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import prepareSAPCallout from '@salesforce/apex/ev_SAPRestCallout.prepareSAPCallout';

export default class SendToSAP extends LightningElement {
    @track showSendBtn = true;
    _recordId;

    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        if (value) {
            this.sendRequestToSAP();
        }
    }

    closeQuickActionScreen() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleConfirmationCheckboxChange(event) {
        this.showSendBtn = !event.target.checked;
    }

    handleSend() {
        this.sendRequestToSAP();
    }

    sendRequestToSAP() {
        let parameterMap = JSON.stringify({ quoteId: this.recordId });
        prepareSAPCallout({ parameters: parameterMap }).then(result => {
            console.log('prepareSAPCallout result => ', result);
            if (result && result.externalSystem) {
                let externalSystem = result.externalSystem;
                this.closeQuickActionScreen();
                this.showToast({
                    title: 'Thank you for confirming.',
                    message: `Sending request to ${externalSystem} is in progress.`,
                    variant: 'success'
                });
            }
        }).catch(error => {
            console.log('prepareSAPCallout error => ', error);
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