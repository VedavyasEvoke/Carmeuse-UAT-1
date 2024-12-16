import { LightningElement, track, api, wire } from 'lwc';
import { addItemToCart } from 'commerce/cartApi';



export default class CustomCart extends LightningElement {
    @api recordId;
    @api effectiveAccountId;
    searchKey = '';
    quntity = 1;


    handleKeyChange(event) {
        this.searchKey = event.target.value;
    }

    handleClick(){
        addItemToCart({ searchKey,quntity})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Item Added To Cart',
                    variant: 'success'
                })
            );
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

}