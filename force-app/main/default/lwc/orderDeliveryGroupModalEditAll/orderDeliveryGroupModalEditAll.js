import { LightningElement, api, wire, track } from 'lwc';
import getOrderDeliveryGroupData from '@salesforce/apex/OrderController.getOrderDeliveryGroupData';
import getOrderDeliveryGroupsData from '@salesforce/apex/OrderController.getOrderDeliveryGroupsData';
import getExtendedEntitlement from '@salesforce/apex/OrderController.getExtendedEntitlement';
import updateOrderDeliveryGroupByCSR from '@salesforce/apex/OrderController.updateOrderDeliveryGroupByCSR';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import Order_Delivery_Group_Modal_Delivery_Close_Button from '@salesforce/label/c.Order_Delivery_Group_Modal_Delivery_Close_Button';
import Order_Delivery_Group_Modal_Delivery_Date from '@salesforce/label/c.Order_Delivery_Group_Modal_Delivery_Date';
import Order_Delivery_Group_Modal_Extended_Entitlement_Not_Present from '@salesforce/label/c.Order_Delivery_Group_Modal_Extended_Entitlement_Not_Present';
import Order_Delivery_Group_Modal_Header from '@salesforce/label/c.Order_Delivery_Group_Modal_Header';
import Order_Delivery_Group_Modal_Edit_All_Header from '@salesforce/label/c.Order_Delivery_Group_Modal_Edit_All_Header';
import Order_Delivery_Group_Modal_Quantity from '@salesforce/label/c.Order_Delivery_Group_Modal_Quantity';
import Order_Delivery_Group_Modal_Quote_Number from '@salesforce/label/c.Order_Delivery_Group_Modal_Quote_Number';
import Order_Delivery_Group_Modal_Update_Button from '@salesforce/label/c.Order_Delivery_Group_Modal_Update_Button';
import Order_Delivery_Group_Modal_Update_All_Button from '@salesforce/label/c.Order_Delivery_Group_Modal_Update_All_Button';
import Order_Delivery_Group_Modal_Quote_Number_Required from '@salesforce/label/c.Order_Delivery_Group_Modal_Quote_Number_Required';
import updateAllOrderDeliveryGroupBySPC from '@salesforce/apex/OrderController.updateAllOrderDeliveryGroupBySPC';

let i=0;

export default class OrderDeliveryGroupModalEditAll extends LightningElement {
    @api eachDeliveryDateWrapper;
    @api recordIds = [];
    @api recordId;
    @api accountId;
    @track materialNumber;
    @track quoteNumber;
    @track originalMaterialNumber;
    @track isExtendedEntitlementPresent = false;
    @track quantity;
    @track desiredDeliveryDate;
    @track items = []; //this will hold key, value pair
    @track value = ''; //initialize combo box value
    @track chosenValue = '';
    orderDeliveryGroups = [];
    displayExtendedEntitlementNotPresent = 'The account is not having an extended entitlement product.';

    label = {
        Order_Delivery_Group_Modal_Delivery_Close_Button,
        Order_Delivery_Group_Modal_Delivery_Date,
        Order_Delivery_Group_Modal_Extended_Entitlement_Not_Present,
        Order_Delivery_Group_Modal_Header,
        Order_Delivery_Group_Modal_Edit_All_Header,
        Order_Delivery_Group_Modal_Quantity,
        Order_Delivery_Group_Modal_Quote_Number,
        Order_Delivery_Group_Modal_Update_Button,
        Order_Delivery_Group_Modal_Update_All_Button,
        Order_Delivery_Group_Modal_Quote_Number_Required
    };

    @wire(getExtendedEntitlement, { accountId: '$accountId'})
    wiredExtendedEntitlement({ error, data }) {
        if (data) {
            for(i=0; i<data.length; i++)  {
                this.items = [...this.items ,{value: data[i] , label: data[i]} ];
                this.isExtendedEntitlementPresent = true;
                //console.log("Plant Code: ", data[i]);                                   
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
                this.orderDeliveryGroups.forEach(obj =>  {
                    obj.quoteNumber = fields[0];
                    obj.quoteNumber = obj.quoteNumber.trim();
                });
            }
            if(fields[1] != null){
                this.orderDeliveryGroups.forEach(obj =>  {
                    obj.plantCode = fields[1];
                    obj.plantCode = obj.plantCode.trim();
                });
            }
            if(fields[2] != null){
                this.orderDeliveryGroups.forEach(obj => {
                    obj.materialNumber = fields[2];
                    obj.materialNumber = obj.materialNumber.trim();
                });
            }               
        }
    }

    //this value will be shown as selected value of combobox item
    get selectedValue(){
        return this.chosenValue;
    }

    @api
    handlePopup(param1) {

        //console.log("handlePopup");
        //param1.forEach(element => console.log("Reveived: ", element));
        //console.log("Received: ", param1);

        var recordsString = param1.toString();
        //console.log("Received: ", recordsString);

        this.orderDeliveryGroups = [];

        getOrderDeliveryGroupsData({ orderDeliveryGroupsIds: recordsString})
        .then(result => {
            result.forEach(res => {
                let orderDeliveryGroupObject = {
                    recordId: null,
                    materialNumber: null,
                    plantCode: null,
                    quoteNumber: null,
                    originalMaterialNumber: null,
                    isExtendedEntitlementPresent: null,
                    quantity: null,
                    desiredDeliveryDate: null,
                }
                orderDeliveryGroupObject.recordId = res.Id;
                orderDeliveryGroupObject.quoteNumber = res.QuoteNumber__c;            
                if(res.DesiredDeliveryDate != null){
                    var fields = res.DesiredDeliveryDate.split('-');
                    if(fields.length == 3) {
                        orderDeliveryGroupObject.desiredDeliveryDate  = fields[1] + '/' + fields[2] + '/' + fields[0] ;
                    }       
                }
                orderDeliveryGroupObject.quantity = res.Quantity__c;
                orderDeliveryGroupObject.originalMaterialNumber = res.MaterialNumber__c;            
                this.template.querySelector("section").classList.remove("slds-hide");
                this.template
                .querySelector("div.modalBackdrops")
                .classList.remove("slds-hide"); 
                
                //console.log("Object: ", orderDeliveryGroupObject);
                this.orderDeliveryGroups.push(orderDeliveryGroupObject);
            });                  
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

    handleUpdateAll(){
        let quoteCmp = this.template.querySelector(".quoteCmp");
        let quotevalue = quoteCmp.value;
        if (!quotevalue) {
            quoteCmp.setCustomValidity("Quote number is required");

        } else {
            quoteCmp.setCustomValidity("");
                let orderDeliveryGroupIds = [];       
                this.orderDeliveryGroups.forEach(obj => {
                    orderDeliveryGroupIds.push(obj.recordId);
                });
                updateAllOrderDeliveryGroupBySPC({ lstOrderDeliveryGroupId : orderDeliveryGroupIds, quoteNumber: this.orderDeliveryGroups[0].quoteNumber,originalMaterialNumber : this.orderDeliveryGroups[0].originalMaterialNumber,materialNumber :this.orderDeliveryGroups[0].materialNumber})
                .then(result => {
                    if(result){
                        const eventSuccess = new ShowToastEvent({
                            title: 'Success!',
                            message: 'Record updated!',
                            variant: 'success'
                        });
                        this.orderDeliveryGroups.forEach(obj => {
                            const selectedEvent = new CustomEvent("progressvaluechange", {
                                detail: {
                                    odgId: obj.recordId,
                                    material: obj.materialNumber,
                                    plantCode: obj.plantCode,
                                    quote: obj.quoteNumber
                                }
                            });
                            this.template.querySelector(".quoteCmp").value = null;
                            this.dispatchEvent(selectedEvent);
                        });
                        this.dispatchEvent(eventSuccess);   
                        this.handleClose();             
                    }
                }).catch(error => {
                    console.log(error);
                    const evt = new ShowToastEvent({
                        title: 'Error!',
                        message: JSON.stringify(error),
                        variant: 'error',
                        mode:'dismissable'
                    });
                    this.template.querySelector(".quoteCmp").value = null;
                    this.dispatchEvent(evt);               
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