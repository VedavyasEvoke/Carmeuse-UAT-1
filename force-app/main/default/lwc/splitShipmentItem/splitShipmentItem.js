import { api, LightningElement } from 'lwc';

export default class SplitShipmentItem extends LightningElement {
    @api
    cartItemOptions;

    @api index;

    PurchaseOrder = '';
    RequestedDate = '';
    RequestedTime = '';
    CartItemId;
    Quantity = 0;
    DeliveryInstructions = '';

    formChangedHandler(e) {
        this[e.target.name] = e.target.value;

        const form = {
            index: this.index,
            PurchaseOrder: this.PurchaseOrder,
            RequestedDate: this.RequestedDate,
            // RequestedTime: this.RequestedTime,
            CartItemId: this.CartItemId,
            Quantity: this.Quantity,
            DeliveryInstructions: this.DeliveryInstructions
        }

        this.dispatchEvent(new CustomEvent('formchanged', {
            detail: {
                ...form
            }
        }));
    }
}