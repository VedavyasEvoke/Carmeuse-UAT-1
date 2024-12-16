import { LightningElement, track, api, wire } from 'lwc';
import getOrderSummariesByAccountId from '@salesforce/apex/OrderDetailsUtility.getOrderSummariesByAccountId';
import getAccessCodeOrPOAllSummaries from '@salesforce/apex/OrderDetailsUtility.getAccessCodeOrPOAllSummaries';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OrderSummaryDetails extends LightningElement {

    @track orderSummaryRecords = '';
    @api effectiveAccountId;
    @track isNext = false;
    @track orderSummaryRecordsArray = [];
    @api recordId;
    @track searchPONumber;
    @track searchAccessCode;
    @track actualAccessCode;

    @wire(getOrderSummariesByAccountId, { AccountId: '$effectiveAccountId' })
    getAllOrderSummaries({ data, error }) {
        if (data) {
            this.orderSummaryRecords = data;
            data.forEach(order => {
                this.orderSummaryRecordsArray.push(order.Id);
            });
        } else {
            console.log('error' + JSON.stringify(error));
        }
    }
    scrollToTop() {
        window.scrollTo({
            top: 0,
            left: 0,
            behavior: 'smooth'
        });
    }
    keycheck(event) {
        if (event.code == 'Enter') {
            this.handleSearchKeyword();
        }
    }
    handleSearch(event) {
        let search = event.target.value;
        this.searchAccessCode = search.trim();
        this.searchPONumber = search.trim();
    }
    handleSearchKeyword() {
        if (this.searchAccessCode == null || this.searchAccessCode == '') {
            this.showNotification('Please enter the value for Access Code or PO', 'Warning', 'dismissable');
        }
        else {
            let newSearchValue = this.searchAccessCode.toString();
            let targeted_length = 10;
            let searchLength = newSearchValue.length;
            if (searchLength < targeted_length) {
                let padding = new Array(targeted_length - searchLength + 1).join('0');
                this.searchAccessCode = padding + newSearchValue;
            }
            this.getAccessCodeOrPOAllSummaries();
        }
    }
    getAccessCodeOrPOAllSummaries() {
        getAccessCodeOrPOAllSummaries({ accessCode: this.searchAccessCode, poNumber: this.searchPONumber, orderSummryId: this.orderSummaryRecordsArray })
            .then((result) => {
                if (result) {
                    this.isNext = true;
                    this.actualAccessCode = result[0].AccessCode__c;
                    this.findOnPage();
                }
                else { this.showNotification('No result found', 'Error', 'dismissable'); }
            })
            .catch((error) => {
                console.log('error' + JSON.stringify(error));
            });
    }
    findOnPage() {
        if (this.searchAccessCode === this.actualAccessCode) {
            window.find(this.searchAccessCode, false, false, true, true);
        } else {
            window.find(this.searchPONumber, false, false, true);
        }
    }
    previousFound() {
        if (this.searchAccessCode === this.actualAccessCode) {
            window.find(this.searchAccessCode, false, true, true, true);
        } else {
            window.find(this.searchPONumber, false, true, true);
        }
    }
    showNotification(message, variant, mode) {
        const evt = new ShowToastEvent({
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}