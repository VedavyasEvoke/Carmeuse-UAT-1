import { LightningElement,track } from 'lwc';
import getAccountNotPlacedOrder from '@salesforce/apex/AccountUtils.getAccountNotPlacedOrder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UserCustomReport extends LightningElement {
    @track isUserDetailsButton = false;
    connectedCallback(){
    }
    async getAccountNotPlacedOrder(){
        const userToaster = new ShowToastEvent({
            title: 'Users Details Not Placed Order Yet!',
            message : 'Wait File Is Getting Prepare For Download',
            variant: 'warning',
            mode: 'dismissible'
        });
        this.dispatchEvent(userToaster);
        this.isUserDetailsButton = true;
        this.lstUserDetails = await getAccountNotPlacedOrder(); 
        this.isUserDetailsButton = false;       
        console.log('this.lstUserDetails -->'+this.lstUserDetails)
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(this.lstUserDetails);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = 'Account Details Not Placed Order.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

}