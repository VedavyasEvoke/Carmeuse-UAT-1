import { LightningElement, api, track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';


export default class Ev_Language extends LightningElement {

    @api recordId;
    @api objectApiName;
    @track quoteLanguage;

    languageChange(event) {

        console.log('Inside languageChange method');

        this.quoteLanguage = event.detail.value;

        const fields = ({
            Id: this.recordId,
            SBQQ__QuoteLanguage__c: this.quoteLanguage
        })
        console.log(fields);
        const recordInput = { fields };
        console.log(recordInput);

       updateRecord(recordInput).then(result => {
                console.log('Updated');
                console.log(result);
            })
            .catch(error => {
                console.log('Error updating record:', error);
                refreshApex();
            });
    }
}
















//     @api recordId; // Record ID passed dynamically
//     showSuccessMessage = false;
//     showErrorMessage = false;
//     errorMessage = '';

//     handleFieldChange() {
//         // Automatically triggers record update because of `lightning-record-edit-form`
//         this.template.querySelector('lightning-record-edit-form').submit();
//     }

//     handleSuccess() {
//         this.showSuccessMessage = true;
//         this.showErrorMessage = false;

//         // Clear success message after 3 seconds
//         setTimeout(() => {
//             this.showSuccessMessage = false;
//         }, 3000);
//     }

//    handleError(event) {
//     this.showErrorMessage = true;
//     this.showSuccessMessage = false;

//     // Log the full error details for debugging
//     console.error('Error Details:', event.detail);

//     // Display a user-friendly message
//     this.errorMessage = event.detail.message || 'An unknown error occurred. Please check the debug logs.';
// }