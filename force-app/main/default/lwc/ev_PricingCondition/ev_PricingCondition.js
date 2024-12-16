import { LightningElement, api, track } from 'lwc';
import fetchQuote from '@salesforce/apex/ev_PricingConditionController.fetchQuote';

/**
* Class Name         : Ev_PricingCondition
* Developer          : D Sridhar           
* Created Date       : 13-03-2024
* @description       : This JS handles all the logic of this component
* Last Modified Date : 13-03-2024
*/
export default class Ev_PricingCondition extends LightningElement {
    @api recordId;
    @api navigateToUrlFromVf;

    @track isNorthAmerica = false;
    @track isOther = false;

    quote;

    connectedCallback() {
        let _parameters = JSON.stringify({ quoteId: this.recordId });
        fetchQuote({ parameters: _parameters }).then(result => {
            this.quote = JSON.parse(JSON.stringify(result));
            this.determineRegion();
        }).catch(error => { });
    }

    /* Determines the Customer Region and renders their component respectively */
    determineRegion() {
        switch(this.quote[0]?.Customer_Region__c) {
            case 'North America': this.isNorthAmerica = true; break;
            default: this.isOther = true;
        }
    }
}