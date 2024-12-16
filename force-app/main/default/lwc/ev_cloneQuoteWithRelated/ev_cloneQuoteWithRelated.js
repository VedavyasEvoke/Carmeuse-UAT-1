import { LightningElement, api } from 'lwc';
import cloneQuotewithQuotelines from '@salesforce/apex/ev_CloneQuoteWithRelatedController.cloneQuoteWithRelated';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';

export default class Ev_cloneQuoteWithRelated extends NavigationMixin(LightningElement) {
    @api recordId;

    async connectedCallback() {
        await this.sleep(30);
        this.cloneAction();
    }

    sleep(ms) {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }

    async cloneAction() {
        console.log('recordId--->>  ', this.recordId);

        try {
            const integrationResult = await cloneQuotewithQuotelines({ QuoteId: this.recordId });
            console.log('success!', integrationResult);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Quote with Related has been created',
                    variant: 'success'
                })
            );

             this.closeAction();
            // Generate the URL for the new record
            const url = await this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: integrationResult,
                    objectApiName: 'SBQQ__Quote__c',
                    actionName: 'view'
                }
            });

            // Open the new record in a new tab
            window.open(url, '_blank');
            //Close Current
            window.close(); 
         
             
        } catch (error) {
            console.error('Error during cloning: ', JSON.stringify(error));

            let errorMessage = 'An error occurred while cloning Quote with Related.';

            if (error.body && error.body.message) {
                errorMessage = error.body.message;
            } else if (error.message) {
                errorMessage = error.message;
            }

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: errorMessage,
                    variant: 'error'
                })
            );
        }
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}