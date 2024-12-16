/**
 * Created by kdreyer on 2/16/21.
 */

import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class B2BLineItem extends NavigationMixin(LightningElement) {
    @api item;
    @api currencyCode;

    handleProductDetailNavigation(evt) {
        evt.preventDefault();
        const productId = evt.target.dataset.productid;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: productId,
                actionName: 'view'
            }
        });
    }

}