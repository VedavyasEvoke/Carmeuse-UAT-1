import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendQuote from '@salesforce/apex/ev_createOrderinMSD.sendQuote';

export default class Ev_OrderCreateInMSD extends LightningElement {
    @track error;
    @track success;
    _recordId;

    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        if (value) {
            setTimeout(() => this.handleSendQuote(), 50);
            console.log('recordId:', this.recordId);
        }
    }

    handleSendQuote() {
        console.log('recordId:', this.recordId);
        if (!this.recordId) {
            this.error = 'No record ID found.';
            this.showToast('Error', this.error, 'error');
            return;
        }

        sendQuote({ quoteId: this.recordId })
            .then(result => {
                this.success = 'Order created successfully in Dynamics!';
                this.showToast('Success', this.success, 'success');
                this.closeQuickActionScreen();
                this.error = undefined;
            })
            .catch(error => {
                this.error = error.body.message || 'An error occurred.';
                this.showToast('Error', this.error, 'error');
                this.success = undefined;
            });
    }

    closeQuickActionScreen() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}