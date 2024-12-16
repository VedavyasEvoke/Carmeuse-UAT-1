import { LightningElement, api } from 'lwc';
//import cancelOrder from '@salesforce/apex/CarmeuseCancelOrderContainer.cancelOrder';

export default class LwcPopup extends LightningElement {

    @api eventNameNo = 'exit'; 
    @api recordId;

    handleNo(){
        this.dispatchEvent(new CustomEvent(
            this.eventNameNo));
    }

    /**handleYes(){
        cancelOrder({recordId : this.recordId} )
            .then((result) => {

            })
            .then((error) => {

            })
    }**/
}