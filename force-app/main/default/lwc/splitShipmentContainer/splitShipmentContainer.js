import { LightningElement, api, track } from 'lwc';
import communityId from '@salesforce/community/Id';
import getCartItems from '@salesforce/apex/B2BCartController.getCartItems';
//import processShipments from '@salesforce/apex/B2BSplitShipment.processShipments';
import splitShipments from '@salesforce/apex/B2BSplitShipment.splitShipments';
import isCarrierUser  from '@salesforce/customPermission/Carrier_User_Only';
export default class SplitShipmentContainer extends LightningElement {
    @api recordId; // cart id

    loading = false;
    cartItemOptions = [];
    cartItems = [];
    numberOfShipments = 1;
    shipments = [];

    //Automatically sets the effectiveAccountId to User context when null
    effectiveAccountId = null;
    pageParam = null;
    sortParam = null;
    currencyCode;
    @track showNote = false;

    connectedCallback() {
        this.showNote = isCarrierUser;
        this.getCartItems();
    }

    getCartItems() {
        getCartItems({
            communityId: communityId,
            effectiveAccountId: this.effectiveAccountId,
            activeCartOrId: this.recordId,
            pageParam: this.pageParam,
            sortParam: this.sortParamb2bCartLineItems
        })
            .then(({ cartItems, cartSummary }) => {
                this.cartItems = cartItems;
                this.currencyCode = cartSummary.currencyIsoCode;
                this.cartId = cartSummary.cartId;

                this.cartItemOptions = cartItems.map(({ cartItem }) => {
                    return {
                        value: cartItem.cartItemId,
                        label: cartItem.name
                    }
                })
            })
            .catch((error) => {
                console.log(error);
                this.cartItems = undefined;
            });
    }

    handleSubmit() {
        this.loading = true;
        console.log(this.shipments);
        // processShipments({
        //     cartId: this.recordId,
        //     effectiveAccount: this.effectiveAccountId,
        //     shipments: JSON.stringify(this.shipments)
        //     });
        this.loading = false;
    }

    createShipments(event) {
        this.shipments = [];
        for (let i = 0; i < this.numberOfShipments; i++) {
            this.shipments.push({
                index: i,
                PurchaseOrder: '',
                RequestedDate: '',
                RequestedTime: '',
                CartItemId: '',
                Quantity: 0,
                DeliveryInstructions: ''
            });
        }
    }

    /*createShipments(event) {
        this.shipments = [];
        for (let i = 0; i < this.numberOfShipments; i++) {
            this.shipments.push({
                index: i,
                PurchaseOrder: '',
                RequestedDate: '',
                RequestedTime: '',
                CartItemId: '',
                Quantity: 0,
                DeliveryInstructions: ''
            });
        }
    }*/

    handleNumberOfShipmentsChanged(e) {
        this.numberOfShipments = e.target.value;
    }

    shipmentChangedHandler(e) {
        console.log('recieved shipment changed')
        console.log(e.detail)

        const changedShipment = this.shipments.find(ship => ship.index === e.detail.index);

        changedShipment.PurchaseOrder = e.detail.PurchaseOrder;
        changedShipment.RequestedDate = e.detail.RequestedDate;
        changedShipment.RequestedTime = e.detail.RequestedTime;
        changedShipment.CartItemId = e.detail.CartItemId;
        changedShipment.Quantity = e.detail.Quantity;
        changedShipment.DeliveryInstructions = e.detail.DeliveryInstructions;

        console.log(this.changedShipment)
        console.log(this.shipments);
    }
}