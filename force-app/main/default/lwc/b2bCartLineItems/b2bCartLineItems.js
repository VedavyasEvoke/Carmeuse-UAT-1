/**
 * Created by kdreyer on 2/16/21.
 */

import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { resolve } from 'c/b2bCMSResourceResolver';
import communityId from '@salesforce/community/Id';
import getCartItems from '@salesforce/apex/B2BCartController.getCartItems';

export default class B2bCartLineItems extends NavigationMixin(LightningElement) {
	@api recordId;

	//Automatically sets the effectiveAccountId to User context when null
	effectiveAccountId = null;

	items = [];

	currencyCode;

	_connectedResolver;

    _canResolveUrls = new Promise((resolved) => {
        this._connectedResolver = resolved;
    });

    connectedCallback() {
        this._connectedResolver();
        this.getCartItems();
    }

    disconnectedCallback() {
            // We've been disconnected, so reset our Promise that reflects this state.
            this._canResolveUrls = new Promise((resolved) => {
                this._connectedResolver = resolved;
            });
     }

     pageParam = null;
     sortParam = null;

    getCartItems() {
        getCartItems({
            communityId: communityId,
            effectiveAccountId: this.effectiveAccountId,
            activeCartOrId: this.recordId,
            pageParam: this.pageParam,
            sortParam: this.sortParamb2bCartLineItems
        })
            .then((result) => {
                this._providedItems = result.cartItems;
                this.currencyCode = result.cartSummary.currencyIsoCode;
            })
            .catch((error) => {
                console.log(error);
                this.cartItems = undefined;
            });
    }

	//Set to true after generatedUrls promise is completed
    renderChildren = false;

    set _providedItems(items) {
            const generatedUrls = [];
            this.items = (items || []).map((item) => {
                const newItem = {};
                this.cleanItem(newItem, item);

                // Set default value for productUrl
                newItem.productUrl = '';
                // Get URL of the product image.
                newItem.displayUrl = resolve(
                    item.cartItem.productDetails.thumbnailImage.url
                );

	            // Set the alternative text of the image(if provided).
	            // If not, set it as the productName
                newItem.productImageAlternativeText =
                    item.cartItem.productDetails.thumbnailImage.alternateText || '';

                // Get URL for the product, which is asynchronous and can only happen after the component is connected to the DOM (NavigationMixin dependency).
                const urlGenerated = this._canResolveUrls
                    .then(() =>
                        this[NavigationMixin.GenerateUrl]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: newItem.productId,
                                objectApiName: 'Product2',
                                actionName: 'view'
                            }
                        })
                    )
                    .then((url) => {
                        newItem.productUrl = url;
                    });
                generatedUrls.push(urlGenerated);

                return newItem;
            });

            // When we've generated all our navigation item URLs, update the list once more.
            Promise.all(generatedUrls).then(() => {
                this.items = Array.from(this.items);
                this.renderChildren = true;
            });
        }

	//Assigns item values to new object to have consistent field names for b2bLineItem
    cleanItem(newItem, item) {
        newItem.id = item.cartItem.cartItemId;
        newItem.productId = item.cartItem.productDetails.productId;
        newItem.productName = item.cartItem.productDetails.name;
        newItem.sku = item.cartItem.productDetails.sku;
        newItem.listPrice = item.cartItem.listPrice;
        newItem.quantity = item.cartItem.quantity;
        newItem.totalPrice = item.cartItem.totalPrice;
        newItem.unitPrice = item.cartItem.unitAdjustedPrice;
        //newItem.size = item.cartItem.productDetails.variationAttributes.Size__c.value;
        return newItem;
    }
}