import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import cancelOrderDeliveryGroupByPortalUser from '@salesforce/apex/OrderController.cancelOrderDeliveryGroupByPortalUser';
import Order_Detail_Product_Code from '@salesforce/label/c.Order_Detail_Product_Code';
import Order_Detail_Access_Code from '@salesforce/label/c.Order_Detail_Access_Code';
import Order_Detail_BOL_Number from '@salesforce/label/c.Order_Detail_BOL_Number';
import Order_Detail_Status from '@salesforce/label/c.Order_Detail_Status';
import Order_Detail_Shipping_DateTime from '@salesforce/label/c.Order_Detail_Shipping_DateTime';
import Order_Detail_Shipping_Weight from '@salesforce/label/c.Order_Detail_Shipping_Weight';
import Cut_off_date from '@salesforce/label/c.Cut_off_date';
import isCarrierUser from '@salesforce/customPermission/Carrier_User_Only';
import getAccountDetails from '@salesforce/apex/AccountUtils.getAccountDetails';
import Business_Unit_for_the_MLS_account from '@salesforce/label/c.Business_Unit_for_the_MLS_account';
import updateOrderDeliveryDate from '@salesforce/apex/OrderDetailsUtility.updateOrderDeliveryDate';
import OrganizationDetail from '@salesforce/apex/OrderUtils.OrganizationDetail';
import Edit_Cart_Date_Updated_Success from '@salesforce/label/c.Edit_Cart_Date_Updated_Success';

export default class CarmeuseCancelOrderSummeryLineItem extends LightningElement {

    @api eachDeliveryDateWrapperClone;
    @api orderId;
    @api productCode;
    @api deliveryDate;
    @api shippingMode;
    @api isOwner;
    @api effectiveAccountId;
    @track eachDeliveryDateWrapper;
    @track payloadForCancelOrder = { orderId: null, lstOrderItemsToCancel: [] };
    @track orderItemsToCancel;
    @track index;
    @track showConfirmationModal = false;
    @track label = {
        Order_Detail_Product_Code,
        Order_Detail_BOL_Number,
        Order_Detail_Access_Code,
        Order_Detail_Status,
        Order_Detail_Shipping_DateTime,
        Order_Detail_Shipping_Weight
    };


    @track showEditDeliveryModel = false;
    @track isMLSAccount = false;
    @track newDeliveryDate;
    @track orgDetails;
    @track timeZone;
    @track locale;
    @track today;

    connectedCallback() {
        this.eachDeliveryDateWrapper = JSON.parse(JSON.stringify(this.eachDeliveryDateWrapperClone));
        this.getAccountDetails();
    }

    @wire(OrganizationDetail)
    getDateTime({ error, data }) {
        if (data) {
            this.orgDetails = data;
            this.timeZone = data.TimeZoneSidKey;
            this.locale = 'en-US';

            let dateTime = new Date().toLocaleString(this.locale, { timeZone: data.TimeZoneSidKey });
            let today = new Date(dateTime);
            this.today = today.getFullYear() + '-' + (today.getMonth() + 1).toString().padStart(2, '0') + '-' + today.getDate().toString().padStart(2, '0');
        } else if (error) {
            console.log('Error OrganizationDetail' + JSON.stringify(error));
        }
    }

    handleSelectNewDate(event) {
        this.newDeliveryDate = event.detail;
    }

    async getAccountDetails() {
        await getAccountDetails({ accountId: this.effectiveAccountId })
            .then((result) => {
                if (result[0].B2B_Business_Sub_Unit__c === Business_Unit_for_the_MLS_account) {
                    this.isMLSAccount = true;
                }
            }).catch(error => {
                console.log('Error getAccountDetails' + JSON.stringify(error));
            });
    }

    handleRequestForCancel(event) {
        let index = this.index;
        this.handleModalCancel();

        let deliveryDate = new Date((this.deliveryDate).split('/'));
        let cutOffDay = deliveryDate.setDate(deliveryDate.getDate() - 2);
        let cutOffDate = new Date(cutOffDay);
        cutOffDate.setHours(14, 0, 0, 0);
        let daterr = new Date(cutOffDate);
        let today = new Date();

        if (today > cutOffDate && !isCarrierUser) {
            this.showNotification(Cut_off_date, 'error', 'ERROR');
            before;
        }


        cancelOrderDeliveryGroupByPortalUser({
            orderDeliveryGroupId: this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList[index].originalOrderDeliveryGroupId,
            orderId: this.orderId
        })
            .then(result => {
                this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList[index].isOrderRequestedForCancellation = true;
                this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList[index].shipmentStatus = 'Cancellation Requested';
                this.index = null;
                this.showNotification('Cancelled Successfully!', 'success', 'SUCCESS');

            })
            .catch(error => {
                console.log('Error cancelOrderDeliveryGroupByPortalUser' + JSON.stringify(error));
                this.showNotification('Something went wrong!', 'error', 'ERROR');
                this.index = null;

            })

    }
    handleEditSingleDelivery(event) {
        let index = this.index;

        updateOrderDeliveryDate({ orderDeliveryGroupId: this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList[index].originalOrderDeliveryGroupId, orderId: this.orderId, selectedDate: this.newDeliveryDate })
            .then(result => {
                this.index = null;
                this.newDeliveryDate = '';
                this.showNotification(Edit_Cart_Date_Updated_Success, 'success', 'SUCCESS');
                location.reload();
                this.handleModalCancel();
            })
            .catch(error => {
                console.log('Error updateOrderDeliveryDate ' + JSON.stringify(error));
                this.showNotification('Something went wrong!', 'error', 'ERROR');
                this.index = null;
                this.newDeliveryDate = '';
                this.handleModalCancel();
            })
    }

    handleShowConfirmationModal(event) {
        this.index = parseInt(event.detail);
        this.showConfirmationModal = true;
        this.showEditModal = false;
        this.showEditDeliveryModel = false;
        this.showeditdatemodal = false;
    }

    handleShowEditDeliveryModal(event) {
        this.index = parseInt(event.detail);
        this.showConfirmationModal = false;
        this.showEditModal = false;
        this.showEditDeliveryModel = true;
        this.showeditdatemodal = false;
    }
    handleCancelling() {
        this.index = null;
        this.handleModalCancel();
    }

    handleModalCancel() {
        this.showConfirmationModal = false;
        this.showEditModal = false;
        this.showEditDeliveryModel = false;
        this.showeditdatemodal = false;
    }

    showNotification(message, variant, title) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleShowEditModal(event) {
        this.showEditModal = true;
        this.index = parseInt(event.detail);
        this.orderShow = this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList[this.index];
        this.showConfirmationModal = false;
    }

    handleShowEditDateModal(event) {
        this.showeditdatemodal = true;
        this.index = parseInt(event.detail);
        this.orderShow = this.eachDeliveryDateWrapper.orderDeliveryGroupSummaryWrapperList[this.index];
        this.showEditDeliveryModel = false;
        this.showEditModal = false;
        this.showConfirmationModal = false;
    }
}