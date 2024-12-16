import { LightningElement, api, wire, track } from 'lwc';
import getOrderDeliveryGroupData from '@salesforce/apex/OrderController.getOrderDeliveryGroupData';
import getExtendedEntitlement from '@salesforce/apex/OrderController.getExtendedEntitlement';
import updateOrderDeliveryGroupByCSR from '@salesforce/apex/OrderController.updateOrderDeliveryGroupByCSR';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import Order_Delivery_Group_Modal_Delivery_Close_Button from '@salesforce/label/c.Order_Delivery_Group_Modal_Delivery_Close_Button';
import Order_Delivery_Group_Modal_Delivery_Date from '@salesforce/label/c.Order_Delivery_Group_Modal_Delivery_Date';
import Order_Delivery_Group_Modal_Extended_Entitlement_Not_Present from '@salesforce/label/c.Order_Delivery_Group_Modal_Extended_Entitlement_Not_Present';
import Order_Delivery_Group_Modal_Header from '@salesforce/label/c.Order_Delivery_Group_Modal_Header';
import Order_Delivery_Group_Modal_Quantity from '@salesforce/label/c.Order_Delivery_Group_Modal_Quantity';
import Order_Delivery_Group_Modal_Quote_Number from '@salesforce/label/c.Order_Delivery_Group_Modal_Quote_Number';
import Order_Delivery_Group_Modal_Update_Button from '@salesforce/label/c.Order_Delivery_Group_Modal_Update_Button';
import Order_Delivery_Group_Modal_Quote_Number_Required from '@salesforce/label/c.Order_Delivery_Group_Modal_Quote_Number_Required';

let i=0;
export default class OrderDeliveryGroupModal extends LightningElement {
    @api recordId;
    @api accountId;
    @track materialNumber;
    @track quoteNumber;
    @track plantCode;
    @track originalMaterialNumber;
    @track isExtendedEntitlementPresent = false;
    @track quantity;
    @track desiredDeliveryDate;
    @track items = []; //this will hold key, value pair
    @track value = ''; //initialize combo box value
    @track chosenValue = '';
    displayExtendedEntitlementNotPresent = 'The account is not having an extended entitlement product.';

    label = {
        Order_Delivery_Group_Modal_Delivery_Close_Button,
        Order_Delivery_Group_Modal_Delivery_Date,
        Order_Delivery_Group_Modal_Extended_Entitlement_Not_Present,
        Order_Delivery_Group_Modal_Header,
        Order_Delivery_Group_Modal_Quantity,
        Order_Delivery_Group_Modal_Quote_Number,
        Order_Delivery_Group_Modal_Update_Button,
        Order_Delivery_Group_Modal_Quote_Number_Required
    };

    @wire(getExtendedEntitlement, { accountId: '$accountId'})
    wiredExtendedEntitlement({ error, data }) {
        if (data) {
            for(i=0; i<data.length; i++)  {
                this.items = [...this.items ,{value: data[i] , label: data[i]} ];
                this.isExtendedEntitlementPresent = true;                                   
            }
            this.error = undefined;
        } else if (error) {
            console.log(error);
            this.error = error;            
        }
    }

    //gettter to return items which is mapped with options attribute
    get extendedEntitlements() {
        return this.items;
    }

    handleChange(event) {
        // Get the string of the "value" attribute on the selected option
        const selectedOption = event.detail.value;
        this.chosenValue = selectedOption;
        var fields = this.chosenValue.split('|');
        if(fields != null){
            if(fields[0] != null){
                this.quoteNumber = fields[0];
                this.quoteNumber = this.quoteNumber.trim();
            }
            if(fields[1] != null){
                    this.plantCode = fields[1];
                    this.plantCode = this.plantCode.trim();
            }
            if(fields[2] != null){
                this.materialNumber = fields[2];
                this.materialNumber = this.materialNumber.trim();
            }               
        }
    }

    //this value will be shown as selected value of combobox item
    get selectedValue(){
        return this.chosenValue;
    }

    @api
    handlePopup(param1) {

        this.recordId = param1;

        getOrderDeliveryGroupData({ orderDeliveryGroupId: this.recordId})
        .then(result => {
 
            this.quoteNumber = result.QuoteNumber__c;            
            if(result.DesiredDeliveryDate != null){
                var fields = result.DesiredDeliveryDate.split('-');
                if(fields.length == 3) {
                    this.desiredDeliveryDate  = fields[1] + '/' + fields[2] + '/' + fields[0] ;
                }       
            }
            this.quantity = result.Quantity__c;
            this.originalMaterialNumber = result.MaterialNumber__c;            
            this.template.querySelector("section").classList.remove("slds-hide");
            this.template
               .querySelector("div.modalBackdrops")
               .classList.remove("slds-hide");                    
        })
        .catch(error => {
            console.log(error);                        
        });

    }

    handleFormInputChange(event){
        // In 1 line, assign the value to the property
        this[event.target.name] = event.target.value;
        //console.log(event.target.name + ' now is set to ' + event.target.value);
    }
    

    handleUpdate(event){
        let quoteCmp = this.template.querySelector(".quoteCmp");
        let quotevalue = quoteCmp.value;
        if (!quotevalue) {
            quoteCmp.setCustomValidity("Quote number is required");

        } else {

            quoteCmp.setCustomValidity(""); // clear previous value
            updateOrderDeliveryGroupByCSR({ orderDeliveryGroupId: this.recordId, quoteNumber: this.quoteNumber, originalMaterialNumber: this.originalMaterialNumber, materialNumber: this.materialNumber})
            .then(result => {
                //console.log(result);   
                
                getOrderDeliveryGroupData({ orderDeliveryGroupId: this.recordId})
                .then(result => {
                    //console.log(result); 
                    const even = new ShowToastEvent({
                        title: 'Success!',
                        message: 'Record updated!',
                        variant: 'success'
                    });
                    //console.log('call event on parent ****' + this.recordId );
                    // Creates the event with the data.
                    const selectedEvent = new CustomEvent("progressvaluechange", {
                        detail: {
                            odgId: this.recordId,
                            material: this.materialNumber,
                            plantCode: this.plantCode,
                            quote: this.quoteNumber
                        }
                    });
                
                    this.template.querySelector(".quoteCmp").value = null;
                    // Dispatches the event.
                    this.dispatchEvent(selectedEvent);
                    this.dispatchEvent(even);
                    this.handleClose();                           
                })
                .catch(error => {
                        console.log(error);
                        const evt = new ShowToastEvent({
                            title: 'Error!',
                            message: event.detail.detail,
                            variant: 'error',
                            mode:'dismissable'
                        });
                        this.dispatchEvent(evt);  
                        this.template.querySelector(".quoteCmp").value = null;                     
                });
    
            })
            .catch(error => {
                console.log(error);                        
            });
        }
        quoteCmp.reportValidity();
    }

    
    handleClose() {
        this.template.querySelector("section").classList.add("slds-hide");
        this.template
          .querySelector("div.modalBackdrops")
          .classList.add("slds-hide");
    }
}