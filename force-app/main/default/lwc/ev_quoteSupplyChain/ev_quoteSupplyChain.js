import { LightningElement ,wire,api} from 'lwc';
import Carmeuse_Logo from '@salesforce/resourceUrl/Carmeuse_Logo';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import getQuotes from "@salesforce/apex/ev_QuoteSupplyChainController.getquotes";
import savequotes from "@salesforce/apex/ev_QuoteSupplyChainController.savesupplychains";
import savesupplychainandSendEmail from "@salesforce/apex/ev_QuoteSupplyChainController.savesupplychainandSendEmail";

import getPicklistValues from "@salesforce/apex/ev_QuoteSupplyChainController.getPicklistValues";
import UserId from "@salesforce/user/Id";



export default class Ev_quoteSupplyChain extends LightningElement {
    @api recordId;
    quotes;
    UserId=UserId;


     logo=Carmeuse_Logo;
@wire(getPicklistValues)
   picklistValuesMap;

get shippingConditionOptions() {
    return this.picklistValuesMap.data ? this.picklistValuesMap.data.SE_Shipping_Condition__c : [];
}

get shippingTypeOptions() {
    return this.picklistValuesMap.data ? this.picklistValuesMap.data.SE_Shipping_Type__c : [];
}

get perTonOrFlatOptions() {
    return this.picklistValuesMap.data ? this.picklistValuesMap.data.Per_ton_or_Flat__c : [];
}
get currencyOptions() {
    return this.picklistValuesMap.data ? this.picklistValuesMap.data.CurrencyIsoCode : [];
}
    
  @wire(getQuotes, { recordId: '$recordId' })
    wiredQuotes(result) {
        if (result.data) {
            console.log('Quotes data from Apex:', result.data);

        } else if (result.error) {
            console.error('Error fetching quotes from Apex:', result.error);
        }
        // Assign result to quotes property
        this.quotes = result;
    }
 
   
    handleOnChange(e){
        const field = e.currentTarget.dataset.field;
        const recordId = e.currentTarget.dataset.id;
        const value = e.detail.value;
        const check = e.target.checked;

        this.quotes.data = this.quotes.data.map(item => {
            if(item.Id !== recordId) return item;
            if(e.target.type == 'checkbox') return {...item, [field]: check}

            return {...item, [field]: value}
        })
    }

    handleSave(){
        savequotes({inputqts: this.quotes.data})
        .then(() => {
            this.showMessage('Success', 'Quote has been updated!', 'success');
            if(!this.UserId){
            window.location.href = '/apex/ev_QuoteSupplyChainThankyouPage';
            }
            refreshApex(this.quotes)
        })
        .catch(error => {
            this.showMessage('Error', error.body.message, 'error');
        });
    }
    handleSaveandSendemail(){
         savesupplychainandSendEmail({inputqts: this.quotes.data , recid :this.recordId})
        .then(() => {
            this.showMessage('Success', 'Quotes has been updated & Email Sent!', 'success');
            
            refreshApex(this.quotes)
        })
        .catch(error => {
            this.showMessage('Error', error.body.message, 'error');
        });
    }
  

    showMessage(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            }),
        );
    }
}