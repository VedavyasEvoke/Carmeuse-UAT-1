import { LightningElement, api, track, wire } from 'lwc';
import getCancelMessageOrderDeliveryGroupByCSR from '@salesforce/apex/OrderController.getCancelMessageOrderDeliveryGroupByCSR';
import getReleaseMessageOrderDeliveryGroupByCSR from '@salesforce/apex/OrderController.getReleaseMessageOrderDeliveryGroupByCSR';
import getPlantCode from '@salesforce/apex/OrderController.getPlantCode';

import Amend_Order_Access_Code from '@salesforce/label/c.Amend_Order_Access_Code';
import Amend_Order_BOL_Number from '@salesforce/label/c.Amend_Order_BOL_Number';
import Amend_Order_Canceled_By from '@salesforce/label/c.Amend_Order_Canceled_By';
import Amend_Order_Canceled_On from '@salesforce/label/c.Amend_Order_Canceled_On';
import Amend_Order_Cancellation_Request_By from '@salesforce/label/c.Amend_Order_Cancellation_Request_By';
import Amend_Order_Cancellation_Request_Cancel from '@salesforce/label/c.Amend_Order_Cancellation_Request_Cancel';
import Amend_Order_Cancellation_Request_On from '@salesforce/label/c.Amend_Order_Cancellation_Request_On';
import Amend_Order_Cancel_Button from '@salesforce/label/c.Amend_Order_Cancel_Button';

import Amend_Order_Cancel_Proceed_Confirmation_Message from '@salesforce/label/c.Amend_Order_Cancel_Proceed_Confirmation_Message';
import Amend_Order_Edit from '@salesforce/label/c.Amend_Order_Edit';
import Amend_Order_Edit_Button from '@salesforce/label/c.Amend_Order_Edit_Button';
import Amend_Order_Product_Code from '@salesforce/label/c.Amend_Order_Product_Code';

import Amend_Order_Quote_Number from '@salesforce/label/c.Amend_Order_Quote_Number';
import Amend_Order_Plant_Code from '@salesforce/label/c.Amend_Order_Plant_Code';
import Amend_Order_Release from '@salesforce/label/c.Amend_Order_Release';
import Amend_Order_Released_By from '@salesforce/label/c.Amend_Order_Released_By';
import Amend_Order_Released_On from '@salesforce/label/c.Amend_Order_Released_On';
import Amend_Order_Release_Button from '@salesforce/label/c.Amend_Order_Release_Button';

import Amend_Order_Release_Confirmation_Message from '@salesforce/label/c.Amend_Order_Release_Confirmation_Message';
import Amend_Order_Shipping_Date from '@salesforce/label/c.Amend_Order_Shipping_Date';
import Amend_Order_Shipping_Weight from '@salesforce/label/c.Amend_Order_Shipping_Weight';
import Amend_Order_Status from '@salesforce/label/c.Amend_Order_Status';

import cancelAllOrderDeliveryGroupByCSR from '@salesforce/apex/OrderController.cancelAllOrderDeliveryGroupByCSR';
import releaseAllOrderDeliveryGroupByCSR from '@salesforce/apex/OrderController.releaseAllOrderDeliveryGroupByCSR';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CarmeuseAmendOrderSummeryLineItem extends LightningElement {

    @api eachDeliveryDateWrapper;
    @api accountId;
    @api currentRecordId;
	@api errorMessage;
    @api productCode;
    @track plantCode;
    @track items = [];
    @track isDialogVisible = false;
    @track originalMessage;
    @track isReleaseDialogVisible = false;
    @track originalReleaseMessage;
    @track displayMessage = 'Click on the \'Open Confirmation\' button to test the dialog.';
    recordIds = [];
    releasedOrCancelledRecordIds = [];
    quoteNums = [];
    listOfQuoteNumbers = [];
    quoteNumber;
    editOrderDeliveryGroupId;
    cancelOrderDeliveryGroupId;
    releaseOrderDeliveryGroupId;
    //releasedIdHolder;

    label = {
        Amend_Order_Access_Code,
        Amend_Order_BOL_Number,
        Amend_Order_Canceled_By,
        Amend_Order_Canceled_On,
        Amend_Order_Cancellation_Request_By,
        Amend_Order_Cancellation_Request_Cancel,
        Amend_Order_Cancellation_Request_On,
        Amend_Order_Cancel_Button,
        Amend_Order_Cancel_Proceed_Confirmation_Message,
        Amend_Order_Edit,
        Amend_Order_Edit_Button,
        Amend_Order_Product_Code,
        Amend_Order_Plant_Code,
        Amend_Order_Quote_Number,
        Amend_Order_Release,
        Amend_Order_Released_By,
        Amend_Order_Released_On,
        Amend_Order_Release_Button,
        Amend_Order_Release_Confirmation_Message,
        Amend_Order_Shipping_Date,
        Amend_Order_Shipping_Weight,
        Amend_Order_Status
    }

    /*Cancel All and Release All Orders */
    @track isConfirm = false;
    @track isAllOrderCancel = false;
    @track isAllOrderRelease = false;
    @track orderToRelease = [];
    @track confirmHeader = ''
    @track orderToCancel = [];
    @track singleCancelOrders = [];
    @track singleReleaseOrders = [];
    @track showLoadingSpinner = false;

    connectedCallback() {
        this.getActions();
        getPlantCode({ accountId: this.accountId })
        .then(result => {
            this.listOfQuoteNumbers = result;
            this.listOfQuoteNumbers.forEach(element => {
                var fields = element.split('|');
                fields[0] = fields[0].trim();
                fields[1] = fields[1].trim();
                console.log('FILEDS 1---->'+fields[1])
                this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList.forEach(lineItem => {
                    let plantCodeelement = this.template.querySelector('[data-plantcode="' + lineItem.originalOrderDeliveryGroupId + '"]');
                    if(fields[0] == lineItem.quoteNumber){
                        plantCodeelement.innerHTML = fields[1];
                    }
                });
            });
        })
        .catch(error => {
            console.log(error);                        
        });
    } 

    handledChange(event){
        if(event.target.name==='quoteNumber'){
            //console.log('handle Change'+event.target.value);
            this.quoteNumber = event.target.value;
        }
    }

    handleProgressValueChange(event) {       
        
        let materialelement = this.template.querySelector('[data-materialid="' + event.detail.odgId + '"]');
        let plantCodeelement = this.template.querySelector('[data-plantcode="' + event.detail.odgId + '"]');
        let quoteelement = this.template.querySelector('[data-quote="' + event.detail.odgId + '"]');

        if(materialelement != null){            
            materialelement.innerHTML = event.detail.material;
        }
        if(plantCodeelement != null){
            plantCodeelement.innerHTML = event.detail.plantCode;
        }
        if(quoteelement != null){            
            quoteelement.innerHTML = event.detail.quote;
        }
    }

    handleCancel(event){
        
        if(event.target.name === 'confirmModal'){

            //when user clicks outside of the dialog area, the event is dispatched with detail value  as 1
            if(event.detail !== 1){
                if(event.detail.status === 'confirm') {                    
                    let element = this.template.querySelector('[data-id="' + this.cancelOrderDeliveryGroupId + '"]');
                    let statuselement = this.template.querySelector('[data-statusid="' + this.cancelOrderDeliveryGroupId + '"]');
                    let cancelButton = this.template.querySelector('[data-btn="' + this.cancelOrderDeliveryGroupId + '"]');
                    let editButton = this.template.querySelector('[data-editbtn="' + this.cancelOrderDeliveryGroupId + '"]');
                    let releaseButton = this.template.querySelector('[data-releasebtn="' + this.cancelOrderDeliveryGroupId + '"]');
                    cancelButton.classList.toggle('slds-hide'); 

                    element.innerHTML = 'Cancellation in progress';  
                    let orderToCancel = [this.cancelOrderDeliveryGroupId];                  
                    cancelAllOrderDeliveryGroupByCSR({ lstOrderDeliveryGroupId: orderToCancel})
                    .then(result => { 
                        getCancelMessageOrderDeliveryGroupByCSR({ orderDeliveryGroupId: this.cancelOrderDeliveryGroupId})
                        .then(result => {
                            
                            if(editButton != null){
                                editButton.classList.add('slds-hide');   
                            }
                            if(releaseButton != null){                                
                                releaseButton.classList.add('slds-hide');    
                            } 
                            element.innerHTML = result; 
                            statuselement.innerHTML = 'Cancelled';
                            this.singleCancelOrders.push(this.cancelOrderDeliveryGroupId);
                            this.checkAllCancel();
                        })
                        .catch(error => {
                                
                            cancelButton.classList.toggle('slds-hide');
                            element.innerHTML = '';                        
                        });

                        this.releasedOrCancelledRecordIds.push(this.cancelOrderDeliveryGroupId);

                    })
                    .catch(error => {
                          
                        cancelButton.classList.toggle('slds-hide');
                        element.innerHTML = '';                    
                    });
                } else if(event.detail.status === 'cancel'){
                    console.log('do nothing');
                }
            }

            //hides the component
            this.isDialogVisible = false;
        }
    }  

    handleConfirmation(event){
        this.originalMessage = '';
        this.cancelOrderDeliveryGroupId = event.target.name;
        //shows the component
        this.isDialogVisible = true;     
    }

    handleReleaseConfirmation(event){
        this.originaReleaselMessage = '';
        this.releaseOrderDeliveryGroupId = event.target.name;
       
        //shows the component
        this.template.querySelector('c-confirmation-dialog').setAttribute('message','Do you want to release an order?');
        this.template.querySelector('c-confirmation-dialog').setAttribute('title','Confirm Order Release');
        this.template.querySelector('c-confirmation-dialog').addEventListener('click',
        this.handleRelease);
        this.isReleaseDialogVisible = true;
    }

    handleRelease(event){
        if(event.target.name === 'confirmReleaseModal'){

            //when user clicks outside of the dialog area, the event is dispatched with detail value  as 1
            if(event.detail !== 1){
                if(event.detail.status === 'confirm') {
                    let releaseButton = this.template.querySelector('[data-releasebtn="' + this.releaseOrderDeliveryGroupId + '"]');
                    let relelement = this.template.querySelector('[data-relid="' + this.releaseOrderDeliveryGroupId + '"]');
                   // let cancelButton = this.template.querySelector('[data-btn="' + this.releaseOrderDeliveryGroupId + '"]');
                    let editButton = this.template.querySelector('[data-editbtn="' + this.releaseOrderDeliveryGroupId + '"]');
                    releaseButton.classList.toggle('slds-hide');
                    relelement.innerHTML = 'Release in progress';   
                    let orderToRelease = [this.releaseOrderDeliveryGroupId];               
                    releaseAllOrderDeliveryGroupByCSR({ lstOrderDeliveryGroupId : orderToRelease})
                    .then(result => {
                        
                        getReleaseMessageOrderDeliveryGroupByCSR({ orderDeliveryGroupId: this.releaseOrderDeliveryGroupId})
                        .then(result => {
                            console.log(result);
                            relelement.innerHTML = result;
                            // if(cancelButton != null){                                
                            //     cancelButton.classList.add('slds-hide');    
                            // } 
                            if(editButton != null){                                
                                editButton.classList.add('slds-hide');    
                            } 
                            this.singleReleaseOrders.push(this.releaseOrderDeliveryGroupId);
                            this.checkAllRelease();
                            //releasedOrCancelledRecordIds.push(this.releasedIdHolder);
                        })
                        .catch(error => {
                            console.log(error);
                            releaseButton.classList.toggle('slds-hide');
                            relelement.innerHTML = '';                        
                        });

                        //console.log("Released Id: ", this.releaseOrderDeliveryGroupId);
                        this.releasedOrCancelledRecordIds.push(this.releaseOrderDeliveryGroupId);

                    })
                    .catch(error => {
                        console.log(error);
                        releaseButton.classList.toggle('slds-hide');
                        relelement.innerHTML = '';                         
                    });
                } else if(event.detail.status === 'cancel'){
                    console.log('do nothing');
                }
            }
            //hides the component
            this.isReleaseDialogVisible = false;
        }
    }

    handleUpdate(event){
        this.editOrderDeliveryGroupId = event.target.name;
        this.template.querySelector('c-order-delivery-group-modal').setAttribute('record-id',event.target.name);
        this.template.querySelector('c-order-delivery-group-modal').handlePopup(event.target.name);
    } 

    handleEditAll(event){
        var releasedFlag = false;
        this.recordIds = [];
        this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList.forEach(element => {
            releasedFlag = false;
            this.releasedOrCancelledRecordIds.forEach(releasedId => {
                if(element.originalOrderDeliveryGroupId == releasedId) {
                    releasedFlag = true;
                }
            });
            if(element.isOrderCanceledByCSR == false && element.isOrderReleasedByCSR == false && releasedFlag == false) {
                this.recordIds.push(element.originalOrderDeliveryGroupId);
            }
        });

        if(this.recordIds.length != 0) {
            this.template.querySelector('c-order-delivery-group-modal-edit-all').handlePopup(this.recordIds);
        }
        else {
            var editAllButton = this.template.querySelector(".editAll")
        }
    }

    getActions(){
        this.showCancelAll = false;
        this.showReleaseAll = false;
        this.showEditAll = false;
        this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList.forEach(lineItem => {
            if(lineItem.shipmentStatus !== 'Cancelled' && lineItem.shipmentStatus !== 'Shipped' && lineItem.shipmentStatus !== 'Unfulfilled' && lineItem.shipmentStatus !== 'Pending' && lineItem.shipmentStatus !== 'Cancelled By Carmeuse'){
                this.showCancelAll = true;
                this.showEditAll = true;
            }
            if(lineItem.isHold === true && lineItem.shipmentStatus === 'Submitted'){
                this.showReleaseAll = true;
            }
            if(lineItem.shipmentStatus === 'Cancelled'){
                this.singleCancelOrders.push(lineItem.originalOrderDeliveryGroupId);
            }
            if(lineItem.isHold === false ){
                this.singleReleaseOrders.push(lineItem.originalOrderDeliveryGroupId);
            }
       });
    }

    handleCancelAll(event){
        this.eventCancelAllButton = event.target.name;
        this.isConfirm = true;
        this.isAllOrderCancel = true;
        this.isAllOrderRelease = false;
        this.orderToRelease = [];
        this.orderToCancel = [];
        this.confirmHeader = 'Confirm All Orders Cancellation';
        this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList.forEach(element => {
            if(element.shipmentStatus !== 'Shipped' && element.shipmentStatus !== 'Cancelled' && element.shipmentStatus !== 'Unfulfilled' && element.shipmentStatus !== 'Pending'){
                if(!this.singleCancelOrders.includes(element.originalOrderDeliveryGroupId)){
                    this.orderToCancel.push(element.originalOrderDeliveryGroupId)
                }
            }            
        });
    }

    handleReleaseAll(event){
        this.eventReleaseAllButton = event.target.name;
        this.isConfirm = true;
        this.isAllOrderCancel = false;
        this.isAllOrderRelease = true;
        this.orderToCancel = [];
        this.orderToRelease = [];
        this.confirmHeader = 'Confirm All Orders Release';
        this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList.forEach(element => {
            if(element.isHold === true){
                if(!this.singleReleaseOrders.includes(element.originalOrderDeliveryGroupId)){
                    this.orderToRelease.push(element.originalOrderDeliveryGroupId)
                }
            }            
        });
    }

    handleYesAction(){
        this.showLoadingSpinner = true;
        if(this.isAllOrderCancel === true){   
            if(this.orderToCancel.length > 0){
                this.orderToCancel.forEach(odgId => {
                    if(!this.singleCancelOrders.includes(odgId)){
                        let cancelButton = this.template.querySelector('[data-btn="' + odgId + '"]');
                        if(cancelButton !== null){
                            cancelButton.classList.add('slds-hide');  
                        }
                        let element = this.template.querySelector('[data-id="' + odgId + '"]');
                        if(element !== null){
                            element.innerHTML = 'Cancellation in progress';  
                        }
                        this.cancelOrderDeliveryGroupId  = odgId;
                     }
                })                
                cancelAllOrderDeliveryGroupByCSR({lstOrderDeliveryGroupId : this.orderToCancel})
                .then(result => {                                   
                    getCancelMessageOrderDeliveryGroupByCSR({ orderDeliveryGroupId: this.cancelOrderDeliveryGroupId})
                    .then(result => {
                        console.log(result);
                        this.orderToCancel.forEach(odgId => {
                            let element = this.template.querySelector('[data-id="' + odgId + '"]');
                            if(element !== null){
                                element.innerHTML = result;
                            }
                            let statuselement = this.template.querySelector('[data-statusid="' + odgId + '"]');
                            if(statuselement !== null){
                                statuselement.innerHTML = 'Cancelled';
                            }
                            let cancelButton = this.template.querySelector('[data-btn="' + odgId + '"]');
                            if(cancelButton !== null){
                                cancelButton.classList.add('slds-hide');  
                            }
                            let editButton = this.template.querySelector('[data-editbtn="' + odgId + '"]');
                            if(editButton !== null){
                                editButton.classList.add('slds-hide');  
                            }
                            let releaseButton = this.template.querySelector('[data-releasebtn="' + odgId + '"]');
                            if(releaseButton !== null){
                                releaseButton.classList.add('slds-hide'); 
                            }
                        })   
                        let cancelAllButton = this.template.querySelector('[data-cancelallbtn="' + this.eventCancelAllButton + '"]');
                        if(cancelAllButton !== null){
                            cancelAllButton.classList.add('slds-hide'); 
                        }
                        let releaseAllButton = this.template.querySelector('[data-releaseallbtn="' + this.eventCancelAllButton + '"]');
                        if(releaseAllButton !== null){
                            releaseAllButton.classList.add('slds-hide'); 
                        }
                        let editAllButton = this.template.querySelector('[data-editbtn="' + this.eventReleaseAllButton + '"]');
                        if(editAllButton !== null){
                            editAllButton.classList.add('slds-hide');                        
                        }
                        this.showLoadingSpinner = false; 
                        this.isConfirm = false;  
                        const showNotification = new ShowToastEvent({
                            message: 'Order Cancelled Successfully!',
                            variant: 'success',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(showNotification);                           
                    })                    
                    .catch(error => {
                        const showNotification = new ShowToastEvent({
                            message: 'Something went wrong!',
                            variant: 'error',
                            mode: 'pester'
                        });
                        this.dispatchEvent(showNotification);
                        this.showLoadingSpinner = false; 
                        this.isConfirm = false;
                    });                   
                                 
                })
                .catch(error => {
                    console.log(error);
                    const showNotification = new ShowToastEvent({
                        message: 'Something went wrong!',
                        variant: 'error',
                        mode: 'pester'
                    });
                    this.dispatchEvent(showNotification);
                    this.showLoadingSpinner = false; 
                    this.isConfirm = false;
                })
            }else{
                this.showLoadingSpinner = false; 
                this.isConfirm = false;
            }
        }
        if(this.isAllOrderRelease === true){  
            this.showLoadingSpinner = true; 
            if(this.orderToRelease.length > 0){
                this.orderToRelease.forEach(odgId => {
                    if(!this.singleReleaseOrders.includes(odgId)){
                        let releaseButton = this.template.querySelector('[data-releasebtn="' + odgId + '"]');
                        if(releaseButton !== null){
                            releaseButton.classList.add('slds-hide');                      
                        }
                        let element = this.template.querySelector('[data-relid="' + odgId + '"]');
                        if(element !== null){
                            element.innerHTML = 'Release in progress';  
                        }
                        this.releaseOrderDeliveryGroupId  = odgId;
                    }
                })  
                releaseAllOrderDeliveryGroupByCSR({lstOrderDeliveryGroupId : this.orderToRelease})
                .then(result => {                   
                    getReleaseMessageOrderDeliveryGroupByCSR({ orderDeliveryGroupId: this.releaseOrderDeliveryGroupId})
                    .then(result => {
                        console.log(result);
                        this.orderToRelease.forEach(odgId => {
                            let element = this.template.querySelector('[data-relid="' + odgId + '"]');
                            if(element !== null){
                                element.innerHTML = result;                              
                            }
                            let releaseButton = this.template.querySelector('[data-releasebtn="' + odgId + '"]');
                            if(releaseButton !== null){
                                releaseButton.classList.add('slds-hide'); 
                            }
                            let editButton = this.template.querySelector('[data-editbtn="' + odgId + '"]');
                            if(editButton !== null){
                                editButton.classList.add('slds-hide');  
                            }
                        })   
                        let releaseAllButton = this.template.querySelector('[data-releaseallbtn="' + this.eventReleaseAllButton + '"]');
                        if(releaseAllButton !== null){
                            releaseAllButton.classList.add('slds-hide');   
                        }
                        this.showLoadingSpinner = false; 
                        this.isConfirm = false;
                        const showNotification = new ShowToastEvent({
                            message: 'Order Released Successfully!',
                            variant: 'success',
                            mode: 'sticky'
                        });
                        this.dispatchEvent(showNotification);
                    })                    
                    .catch(error => {
                        const showNotification = new ShowToastEvent({
                            message: 'Something went wrong!',
                            variant: 'error',
                            mode: 'pester'
                        });
                        this.dispatchEvent(showNotification);
                        this.showLoadingSpinner = false; 
                        this.isConfirm = false;
                    });                   
                   
                })
                .catch(error => {
                    console.log(error);
                    const showNotification = new ShowToastEvent({
                        message: 'Something went wrong!',
                        variant: 'error',
                        mode: 'pester'
                    });
                    this.dispatchEvent(showNotification);
                    this.showLoadingSpinner = false; 
                    this.isConfirm = false;
                })
            }else{
                this.showLoadingSpinner = false; 
                this.isConfirm = false;
            }
        }
    }

    handleNoAction(){
        this.isConfirm = false;
        this.isAllOrderCancel = false;
        this.isAllOrderRelease = false; 
        this.orderToCancel = [];
        this.orderToRelease = [];
    }

    checkAllCancel(){
        let cancelAllButton = true;
        this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList.forEach(element => {
            if(!this.singleCancelOrders.includes(element.originalOrderDeliveryGroupId)){
                cancelAllButton = false;
            }            
        });
        if(cancelAllButton){
            let cancelAllButton = this.template.querySelector('[data-cancelallbtn="' + this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList + '"]');
            if(cancelAllButton !== null){
                cancelAllButton.classList.add('slds-hide'); 
            }
            let releaseAllButton = this.template.querySelector('[data-releaseallbtn="' + this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList + '"]');
            if(releaseAllButton !== null){
                releaseAllButton.classList.add('slds-hide');   
            }
        }
    }

    checkAllRelease(){
        let releaseAllButton = true;
        this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList.forEach(element => {
            if(!this.singleReleaseOrders.includes(element.originalOrderDeliveryGroupId)){
                releaseAllButton = false;
            }            
        });
        if(releaseAllButton){
            let releaseAllButton = this.template.querySelector('[data-releaseallbtn="' + this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList + '"]');
            if(releaseAllButton !== null){
                releaseAllButton.classList.add('slds-hide');   
            }
        }
    }
}