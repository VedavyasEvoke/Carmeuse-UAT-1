import { LightningElement, api, track } from 'lwc';
import Rail_Order_Cancellation_Warning from '@salesforce/label/c.Rail_Order_Cancellation_Warning';
import Request_To_Cancel_Wait_Warning from '@salesforce/label/c.Request_To_Cancel_Wait_Warning';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class EachOrderSummeryTableRow extends LightningElement {

    @api eachDeliveryDateLineItemWrapper;
    @api productCode;
    @api index;
    @api shippingMode;
    @api isOwner;
    @api today;
    
    get removeCancelButton() {
        return (this.eachDeliveryDateLineItemWrapper.isOrderRequestedForCancellation ||
            this.eachDeliveryDateLineItemWrapper.shipmentStatus == 'Shipped' ||
            this.eachDeliveryDateLineItemWrapper.shipmentStatus == 'Cancelled' ||
            this.eachDeliveryDateLineItemWrapper.shipmentStatus == 'Cancelled By Carmeuse' ||
            this.eachDeliveryDateLineItemWrapper.shipmentStatus == 'Unfulfilled'||
            this.eachDeliveryDateLineItemWrapper.shipmentStatus == 'Cancellation Requested'||
            this.eachDeliveryDateLineItemWrapper.desiredDeliveryDate < this.today);
    }
  
    handleEditModal(event) {
        this.dispatchEvent(new CustomEvent("showeditmodal", {
            detail: this.index
        }))
    }

    handleShowConfirmationModal(event) {
        let railShipMode = ['95', '55', '98', '51', 'Rail', '54', '56', '52'];
        if (railShipMode.includes(this.shippingMode)) {
            const sameDayOrderWarning = new ShowToastEvent({
                message: Rail_Order_Cancellation_Warning,
                variant: 'warning',
                mode: 'sticky'
            });
            this.dispatchEvent(sameDayOrderWarning);
        } else if(this.eachDeliveryDateLineItemWrapper.shipmentStatus === 'Pending'){
            this.showNotification(Request_To_Cancel_Wait_Warning, 'Warning');
        } else{
            this.dispatchEvent(new CustomEvent('showconfirmationmodal', { detail: this.index }));
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