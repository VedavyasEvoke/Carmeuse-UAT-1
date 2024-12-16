import { LightningElement, api, track } from 'lwc'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProdutDetails from '@salesforce/apex/OrderDetailsUtility.getProdutDetails';
import Edit_Cart_Quote_Validation from '@salesforce/label/c.Edit_Cart_Quote_Validation';
import Edit_Cart_Select_Product from '@salesforce/label/c.Edit_Cart_Select_Product';



export default class CarmeuseEditEachDelivery extends LightningElement {

    @api index;
    @api eachDeliveryDateWrapper;
    @api orgDetails;
    @api timeZone;
    @api locale;

    @track today;
    @track maxDate;
    @track selectedDate;
    @track isLoading = false;
    @track previousDeliveryDate;
    @track validUpTo;
    @track validFrom;

    connectedCallback() {
        this.previousDeliveryDate = (this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList[this.index].desiredDeliveryDate).split('T')[0];
        this.getProdutDetails();
    }
    

    async getProdutDetails() {
        await getProdutDetails({ SKU: this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList[this.index].stockKeepingUnit })
            .then((result) => {
                let startDate = new Date(result[0].Valid_From__c);
                let expireDate = new Date(result[0].Valid_To__c);
                this.validFrom = startDate.getFullYear() + '-' + (startDate.getMonth() + 1).toString().padStart(2, '0') + '-' + startDate.getDate().toString().padStart(2, '0');
                this.validUpTo = expireDate.getFullYear() + '-' + (expireDate.getMonth() + 1).toString().padStart(2, '0') + '-' + expireDate.getDate().toString().padStart(2, '0');
                this.setDateValidation();
            }).catch(error => {
                console.log('Error getProdutDetails' + JSON.stringify(error));
            });
    }
    
    handleConfirmClick(event) {
        if (this.selectedDate !== undefined) {
            if (this.today <= this.selectedDate && this.selectedDate <= this.maxDate) {
                this.isLoading = true;
                this.dispatchEvent(new CustomEvent('handleconfirmation', { detail: true }));
            }
        } else {
            this.showNotification(Edit_Cart_Select_Product, 'Warning');
        }
    }

    handleCancelClick(event) {
        this.dispatchEvent(new CustomEvent('handlecancel', { detail: false }));
    }

    handleChange(event) {
        this.selectedDate = event.detail.value;
        this.dispatchEvent(new CustomEvent('getselectnewdate', { detail: this.selectedDate }));
    }
    setDateValidation() {
        let dateTime = new Date().toLocaleString(this.locale, { timeZone: this.timeZone });
        let today = new Date(dateTime);
        today.setDate(today.getDate() + 1);
        this.today = today.getFullYear() + '-' + (today.getMonth() + 1).toString().padStart(2, '0') + '-' + today.getDate().toString().padStart(2, '0');

        let maxDate = new Date(dateTime);
        let validData = new Date(this.validUpTo);
        maxDate.setDate(today.getDate() + 90);

        this.todayError = 'Date must be ' + new Date(this.today).toDateString() + ' or later.';
        if(this.today < this.validFrom){
            this.today = this.validFrom;
            this.todayError = Edit_Cart_Quote_Validation;
        } else {
            this.todayError = 'Date must be ' + new Date(this.today).toDateString() + ' or later.';
        }
        if (validData <= maxDate) {
            this.maxDate = this.validUpTo;
            this.maxDateError = Edit_Cart_Quote_Validation;
        } else {
            this.maxDate = maxDate.getFullYear() + '-' + (maxDate.getMonth() + 1).toString().padStart(2, '0') + '-' + maxDate.getDate().toString().padStart(2, '0');
            this.maxDateError = 'Date must be ' + new Date(this.maxDate).toDateString() + ' or earlier.';
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