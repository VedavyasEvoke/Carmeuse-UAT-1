import { LightningElement, track, api } from 'lwc';
import getOrderDetailsById from '@salesforce/apex/OrderUtils.getOrderDetailsById';
import cancelAllButton from '@salesforce/apex/OrderUtils.cancelAllButton';
import getOrderDetail from '@salesforce/apex/OrderUtils.getOrderDeliveryGroupByOrderIdLWC';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import OrganizationDetail from '@salesforce/apex/OrderUtils.OrganizationDetail';
import cancelAllOrderDeliveryGroupByPortalUser from '@salesforce/apex/OrderController.cancelAllOrderDeliveryGroupByPortalUser';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UserId from '@salesforce/user/Id';
import isCarrierUser  from '@salesforce/customPermission/Carrier_User_Only';
import CancelAll_CutoffPendingShipped from '@salesforce/label/c.CancelAll_CutoffPendingShipped';
import CancelAll_Cutoff from '@salesforce/label/c.CancelAll_Cutoff';
import CancelAll_Pending from '@salesforce/label/c.CancelAll_Pending';
import CancelAll_PendingShipped from '@salesforce/label/c.CancelAll_PendingShipped';
export default class OrderDetails extends LightningElement {
    @api recordId;
    @track orderDeatils
    @track orderNumber;
    @track orderSummaryNumber;
    @track orderedDate;
    @track accountName;
    @track ownerName;
    @track status;
    @track showCancelAll = false;
    @track isConfirm = false;
  
    @track isOrderCutOff = false;
    @track isOrderShipped = false;
    @track isOrderPending = false;
    @track confirmationCutOffMsg = '';
    @track showMsg = false;
    @track orderToCancel = [];
    @track isOrderToDelete = false;
    @track showLoadingSpinner = false;

    connectedCallback(){
        this.getOrganizationDetails();   
    }

    getOrganizationDetails(){
        OrganizationDetail()
        .then(result => {
            this.orgDetails = result;
            this.timeZone = result.TimeZoneSidKey; 
            this.locale = 'en-US';           
            this.getOrderDetailsById();          
        })
        .catch(error => {
           console.log(error);
        })
    }

    getOrderDetailsById(){ 
        getOrderDetailsById({ orderId: this.recordId})
        .then((result) => {
            this.orderDeatils = result; 
            this.orderSummaryNumber = result[0].OrderNumber;  
            let dateTime= new Date(result[0].OrderedDate).toLocaleString(this.locale,{timeZone:TIME_ZONE});       
            this.orderedDate = dateTime;
            this.accountName = result[0].Account.Name;   
            this.ownerName = result[0].Owner.Name; 
            this.status = result[0].Status;             
          
            let orgDateTime= new Date().toLocaleString(this.locale,{timeZone:this.timeZone});       
            let orgToday = new Date(orgDateTime);
            let orderOrgDateTime= new Date(result[0].OrderedDate).toLocaleString(this.locale,{timeZone:this.timeZone});       
            let orderOrgToday = new Date(orderOrgDateTime);
            orderOrgToday.setHours( orderOrgToday.getHours() + 3 );
            if(UserId === result[0].Owner.Id){
                cancelAllButton({ orderId: this.recordId})
                .then((result) => {                   
                    if(result === true){
                        if(orgToday > orderOrgToday  ){
                            this.showCancelAll = false;
                        }else{
                            this.showCancelAll = true;
                        }
                    }else{
                        this.showCancelAll = false;
                    }
                })
                .catch((error) => {
                    this.error = error;
                });
            }else{
                this.showCancelAll = false;
            }
        })
        .catch((error) => {
            this.error = error;
        });
    }   

    showErrorMsg(){
        if(this.isOrderCutOff && (this.isOrderShipped || this.isOrderPending)){
            this.confirmationCutOffMsg = CancelAll_CutoffPendingShipped;
            this.showMsg = true;
        }
        if(this.isOrderCutOff  && !this.isOrderShipped && !this.isOrderPending){
            this.confirmationCutOffMsg = CancelAll_Cutoff;
            this.showMsg = true;
        }
        if(this.isOrderShipped && this.isOrderPending && !this.isOrderCutOff){
            this.confirmationCutOffMsg = CancelAll_PendingShipped;
            this.showMsg = true;
        }
        if(this.isOrderShipped && !this.isOrderPending && !this.isOrderCutOff){
            this.confirmationCutOffMsg = CancelAll_PendingShipped;
            this.showMsg = true;
        }
        if(this.isOrderPending  && !this.isOrderShipped && !this.isOrderCutOff){
            this.confirmationCutOffMsg = CancelAll_Pending;
            this.showMsg = true;
        }
    }

    cancelAllClick(){
        this.orderToCancel = [];
        getOrderDetail({orderId : this.recordId})
        .then(result =>{           
            result.forEach((record) => {
                let orgDateTime= new Date(new Date().toLocaleString(this.locale,{timeZone:this.timeZone}));       
                let deliveryDate = new Date(record.DesiredDeliveryDate);
                let cutOffDate = new Date(orgDateTime. getTime() + (1000 * 60 * 60 * 48));               
                if(record.ShipmentStatus__c !== 'Shipped' && record.ShipmentStatus__c !== 'Pending' && record.ShipmentStatus__c !== 'Cancelled' && record.ShipmentStatus__c !== 'Cancellation Requested'){
                    if((deliveryDate.setHours(0,0,0,0) < cutOffDate.setHours(0,0,0,0) || deliveryDate.setHours(0,0,0,0) === cutOffDate.setHours(0,0,0,0)) && isCarrierUser !== true) {
                        this.isOrderCutOff = true;
                    }else{
                        this.orderToCancel.push(record.Id);
                        this.isOrderToDelete = true;
                    }
                }else{
                    if(record.ShipmentStatus__c === 'Shipped'){
                        if((deliveryDate.setHours(0,0,0,0) < cutOffDate.setHours(0,0,0,0) || deliveryDate.setHours(0,0,0,0) === cutOffDate.setHours(0,0,0,0)) && isCarrierUser !== true) {
                            this.isOrderCutOff = true;
                        }
                        this.isOrderShipped = true;
                    }
                    if(record.ShipmentStatus__c === 'Pending'){
                        if((deliveryDate.setHours(0,0,0,0) < cutOffDate.setHours(0,0,0,0) || deliveryDate.setHours(0,0,0,0) === cutOffDate.setHours(0,0,0,0)) && isCarrierUser !== true) {
                            this.isOrderCutOff = true;
                        }
                        this.isOrderPending = true;
                    }
                }                
            });
            this.showErrorMsg();
            this.isConfirm = true;
        }).catch(error =>{
            this.err = error;
        });   
       
    }

    handleNoAction(){
        this.orderToCancel = [];
        this.isConfirm = false;
    }

    handleYesAction(){
        this.showLoadingSpinner = true;
        let dateTime= new Date(this.orderDeatils[0].OrderedDate).toLocaleString(this.locale,{timeZone:TIME_ZONE});       
        this.orderedDate = dateTime;  
        let orgDateTime= new Date().toLocaleString(this.locale,{timeZone:this.timeZone});       
        let orgToday = new Date(orgDateTime);
        let orderOrgDateTime= new Date(this.orderDeatils[0].OrderedDate).toLocaleString(this.locale,{timeZone:this.timeZone});       
        let orderOrgToday = new Date(orderOrgDateTime);
        orderOrgToday.setHours( orderOrgToday.getHours() + 3 );
        if(orgToday > orderOrgToday  ){
            const showNotification = new ShowToastEvent({
                message: 'Cancellation time-out.Please refresh the page.',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(showNotification);
            this.isConfirm = false;              
            before;
        }
        cancelAllOrderDeliveryGroupByPortalUser({lstOrderDeliveryGroupId : this.orderToCancel})
        .then(result => {
            this.showLoadingSpinner = false;
            this.isConfirm = false;
            const showNotification = new ShowToastEvent({
                message: 'Cancelled Successfully!',
                variant: 'success',
                mode: 'sticky'
            });
            this.dispatchEvent(showNotification);
            window.location.reload();
        })
        .catch(error => {
            console.log(error);
            const showNotification = new ShowToastEvent({
                message: 'Something went wrong!',
                variant: 'error',
                mode: 'pester'
            });
            this.dispatchEvent(showNotification);
            this.isConfirm = false;
        })

    }

    showNotification(message, variant, title) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode : mode
        });
        this.dispatchEvent(evt);
    }

    closeModal(){
        this.isConfirm = false;      
    }
    
}