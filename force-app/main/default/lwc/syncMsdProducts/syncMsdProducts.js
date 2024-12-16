import { LightningElement } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import handleMsdProductsCallout from '@salesforce/apex/ev_SyncMsdProductsController.handleMsdProductsCallout';

export default class SyncMsdProducts extends LightningElement {
    connectedCallback() {
        this.makeMsdProductsCallout();
    }

    /* Displays toast message. */
    showToastMessage(toast) {
        this.dispatchEvent(new ShowToastEvent({
            title: toast.title,
            message: toast.message,
            variant: toast.variant,
        }));
    }

    closeQuickActionScreen() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    /* Calls apex which makes a callout to external system for syncing MSD Products. */
    makeMsdProductsCallout() {
        handleMsdProductsCallout({}).then(result => {
            this.closeQuickActionScreen();
            this.showToastMessage({
                title: 'Success',
                message: 'Sending request to sync MSD Products is in progress.',
                variant: 'success'
            });
        }).catch(error => {
            this.closeQuickActionScreen();
            this.showToastMessage({
                title: 'Could not send request to sync MSD Products.',
                message: 'Please contact your System Administrator.',
                variant: 'error'
            });
        })
    }
}