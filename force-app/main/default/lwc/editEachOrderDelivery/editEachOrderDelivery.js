import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Edit_Cart_Wait_Warning from '@salesforce/label/c.Edit_Cart_Wait_Warning';

export default class EditEachOrderDelivery extends LightningElement {

    @api eachDeliveryDateLineItemWrapper;
    @api index;
    @api isOwner;
    @api orgDetails;
    @api timeZone;
    @api locale;

    @api today

    get removeEditButton() {
        return (this.eachDeliveryDateLineItemWrapper.isOrderRequestedForCancellation ||
            this.eachDeliveryDateLineItemWrapper.shipmentStatus == 'Shipped' ||
            this.eachDeliveryDateLineItemWrapper.shipmentStatus == 'Cancelled' ||
            this.eachDeliveryDateLineItemWrapper.shipmentStatus == 'Cancelled By Carmeuse' ||
            this.eachDeliveryDateLineItemWrapper.shipmentStatus == 'Unfulfilled'||
            this.eachDeliveryDateLineItemWrapper.shipmentStatus == 'Cancellation Requested'||
            this.eachDeliveryDateLineItemWrapper.desiredDeliveryDate.split('T')[0] <= this.today);
    }
    
    handleEditModal(event) {
        this.dispatchEvent(new CustomEvent("showeditdatemodal", {
            detail: this.index
        }))
    }
    handleShowEditDeliveryModal(event) {
    
        if (this.eachDeliveryDateLineItemWrapper.accessCode === undefined) {
            this.showNotification(Edit_Cart_Wait_Warning, 'Warning');
        } else {
            this.dispatchEvent(new CustomEvent('showeditdeliverymodal', { detail: this.index }));
        }
    }

    showNotification(message, variant, title) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}