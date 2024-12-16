import { LightningElement, api } from 'lwc';
import communityUrl from '@salesforce/community/basePath';
import { NavigationMixin } from 'lightning/navigation';
import deleteCartRecord from "@salesforce/apex/B2BCartController.deleteCartRecord";
import isCartQuickSave from "@salesforce/apex/OrderUtils.isCartQuickSave";
import LightningConfirm from "lightning/confirm"
export default class ClearCart extends NavigationMixin(LightningElement) {
    @api recordId;
    isQuickSaveCart;

    connectedCallback() {
        this.checkCartIsQuickSave();
    }    
    async deleteCart() {
        if(this.isQuickSaveCart){
            let isConfirm  = await LightningConfirm.open({
                message: "Are you sure you want to clear your Cart? This will remove any saved order details.",
                theme:"warning",
                label:"Warning"
            });
            //let isConfirm = confirm('Are you sure you want to clear your Cart? This will remove any saved order details.');
            if(isConfirm === true){
                this.clearCart();
            }else{
                this.isQuickSaveCart = true;
            }
        }else if(this.isQuickSaveCart === false){
          this.clearCart();
        }else if(this.isQuickSaveCart === undefined){
            this.checkCartIsQuickSave();
        }
    }

    checkCartIsQuickSave() {
        isCartQuickSave({
            cartId: this.recordId
        }).then(response => {
            this.isQuickSaveCart = response;
        }).catch(error => {
            console.warn(error);
        });
    }

    clearCart(){
        deleteCartRecord({
            cartId: this.recordId
        }).then(response => {
            //location.reload();
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'home'
                },
            });
        }).catch(error => {
            console.warn(error);
        });
    }
   
}