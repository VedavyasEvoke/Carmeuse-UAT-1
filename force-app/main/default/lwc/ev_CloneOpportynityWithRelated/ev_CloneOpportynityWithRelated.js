import { LightningElement, api,track,wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import CURRENCY_FIELD from '@salesforce/schema/Opportunity.CurrencyIsoCode';
import getOpportunityName from '@salesforce/apex/ev_CloneOpportunityWithRelatedController.getOpportunityName';
import cloneOpportunityWithQuote from '@salesforce/apex/ev_CloneOpportunityWithRelatedController.cloneOpportunityWithQuote';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
export default class Ev_CloneOpportynityWithRelated extends NavigationMixin(LightningElement) {
 @api recordId;
    isExecuting = true; 
    updatedOpportunityName;
    updatedcurrency;
    OppName;
    @track currencyISOCode;
    @track currencyOptions = [];
     
      @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    opportunityObjectInfo;

     
    @wire(getPicklistValues, { recordTypeId: '$opportunityObjectInfo.data.defaultRecordTypeId', fieldApiName: CURRENCY_FIELD })
    currencyPicklistValues({ error, data }) {
        if (data) {
            this.currencyOptions = data.values;
        } else if (error) {
            
            console.error('Error fetching currency picklist values', error);
        }
    }
    async  connectedCallback() {
        await this.sleep(100);
        this.getOldOpportunityName();
    }

    sleep(ms) {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }

    getOldOpportunityName() {
        console.log('recordId--->>  ',this.recordId);
        getOpportunityName({
            opportunityId: this.recordId 
        }).then(result => {
                if (result.length > 0) {
                    this.opportunityName = result[0];
                    this.currencyISOCode =result[1];
                    this.updatedcurrency =result[1];
                   console.log('result--->>  ',result[0]);
                console.log('Region result--->>  ',result[3]);

                  // this.template.querySelector('lightning-input').value = result;
                   //this.OppName = result;

                }
            })
            .catch(error => {
                console.log('error: ' + JSON.stringify(error));
            })
            .finally(() => { });
    }

    nameChange(event){
        console.log('OpportunityName change--->>  ');
        if(event.target.name=='OpportunityName'){
            this.updatedOpportunityName= event.target.value;
        }
            
    }
     currencyChange(event){
        console.log('Currency change--->>  ');
        if(event.target.name === 'CurrencyIsoCode'){
            this.updatedcurrency= event.target.value;
             console.log('Currency changed to--->>  ',this.updatedcurrency);
        }
            
    }

    /*currencyChange(event) {
        this.selectedCurrency = event.target.value; // Capture the selected currency value
    }*/

    async cloneAction(){
        console.log('recordId--->>  ');
        console.log('recordId ', this.recordId);
        console.log('this.updatedOpportunityName',this.updatedOpportunityName);
        console.log('this.OppName',this.OppName);
        console.log('this.updatedcurrency',this.updatedcurrency);


       try {
           let OpportunityName = this.template.querySelector('.OpportunityName');
           
           if(!this.updatedOpportunityName ){
             this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Opportunity Clone Issue',
                    message: 'Please Enter Opportunity name to Clone',
                    variant: 'error'
                }),
            );
            }else{
        const integrationResult = await cloneOpportunityWithQuote({
            oppId: this.recordId,
            opportunityName: this.updatedOpportunityName,
            newCurrency : this.updatedcurrency
        });
        console.log('success!', integrationResult);

        await this.sleep(100);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Opportunity with Related have been created',
                variant: 'success'
            })
        );

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: integrationResult,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }
    } catch (error) {
         console.error('Error during cloning: ' + JSON.stringify(error));

    let errorMessage = 'An error occurred while cloning Opportunity with Related.';

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

    

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
}