/**
 * Created by kdreyer on 2/16/21.
 */

import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';
import communityId from '@salesforce/community/Id';
// import getProducts from '@salesforce/apex/B2BSplitShipment.getProducts';
import getCartItems from '@salesforce/apex/B2BCartController.getCartItems';


export default class B2BSplitShipment extends NavigationMixin(LightningElement) {
    @api recordId;
    //console.log(recordId);
    @api records = [];
    @api loading = false;
    cartProducts = [];
    @track numberShipments;
    shipmentCount = [];
    shipmentData = [];

    //Automatically sets the effectiveAccountId to User context when null
    effectiveAccountId = null;

    pageParam = null;
    sortParam = null;
    currencyCode;

    connectedCallback(){
        this.getCartItems();
        //this.loadData();
    }

    getCartItems() {
        getCartItems({
            communityId: communityId,
            effectiveAccountId: this.effectiveAccountId,
            activeCartOrId: this.recordId,
            pageParam: this.pageParam,
            sortParam: this.sortParamb2bCartLineItems
        })
            .then((result) => {
                console.log(result);
                this._providedItems = result.cartItems;
                this.currencyCode = result.cartSummary.currencyIsoCode;
                this.cartId = result.cartSummary.cartId;
                //this.products[0] = result.cartItems[0].cartItem.name;
                console.log(result.cartItems.length);
                for (let i = 0; i < result.cartItems.length; i++){
                    this.cartProducts.push ({}) ;
                    this.cartProducts[i].value = result.cartItems[i].cartItem.cartItemId;
                    this.cartProducts[i].label = result.cartItems[i].cartItem.name;
                }
                console.log(this.cartProducts);
                this.cartProducts = JSON.parse(JSON.stringify(this.cartProducts));
                console.log(this.cartProducts);
            })
            .catch((error) => {
                console.log(error);
                this.cartItems = undefined;
            });
    }

    populateForm(event){
        //take the event.value and put it in the number of Shipments variable
        //use track property on an array, then generate element in array for # of shipments
        //put them all in the array at the same time (set temp array equal to array to track change once)
        //have html for loop through the array
    }

    loadData(){
        // this.loading = true;
        // getProducts(recordId)
        // .then(result => {
        //     this.loading = false;
        //     console.log(result);
        //     //this.products = result;
        // })
        // .catch(error => {console.log(error)})
    }

    keyIndex = 0;
    @track itemList = [
        {
            id: 0
        }
    ];

    addRow() {
        ++this.keyIndex;
        var newItem = [{ id: this.keyIndex }];
        this.itemList = this.itemList.concat(newItem);
    }

    removeRow(event) {
        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }
    handleSubmit() {
        this.loading = true;
    }

    onChange(event){
        console.log('firing');
        console.log(event.target.name);
        console.log(event.target.value);
        console.log(event);
        this.shipmentCount[id][event.target.name] = event.target.value;
        console.log(this.shipmentCount[id][event.target.name]);
    }

    shipChange(event){
        this.numberShipments = event.target.value;
    }

    createShipments(event){
        for (let i=0; i < this.numberShipments; i++){
            this.shipmentCount.push ({});
            this.shipmentCount[i].number = i;
            this.shipmentCount[i].PurchaseOrder = '';
            this.shipmentCount[i].RequestedDate = '';
            this.shipmentCount[i].RequestedTime = '';
            this.shipmentCount[i].Product = '';
            this.shipmentCount[i].Quantity = '';
            this.shipmentCount[i].DeliveryInstructions = '';
        }
        this.shipmentCount = JSON.parse(JSON.stringify(this.shipmentCount));
    }

}