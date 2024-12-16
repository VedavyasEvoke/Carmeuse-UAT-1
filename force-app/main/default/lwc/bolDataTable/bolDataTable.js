import { LightningElement, api, wire, track } from 'lwc';
import getUserBOLs from '@salesforce/apex/OrderController.getUserBOLs';
import { refreshApex } from '@salesforce/apex';

const columns = [{
    label: 'Ac. GI. Date',
    fieldName: 'Ac_GI_Date__c',
    type: 'date-local', 
    sortable: true
},
{
    label: 'Bill of Lading',
    fieldName: 'BOLUrl',
    type: 'url',
    typeAttributes: {label: { fieldName: 'BOL_Number__c' }, target: '_self'}
},
{
    label: 'Delivery Quantity',
    fieldName: 'Delivery_Quantity__c',
    type: 'text',
    sortable: true
},
{
    label: 'Material',
    fieldName: 'Material__c',
    type: 'text', 
    sortable: true
},
{
    label: 'Material Number',
    fieldName: 'Material_Number__c',
    type: 'text', 
    sortable: true
},
{
    label: 'Account Number of Vendor or Creditor',
    fieldName: 'Account_Number_of_Vendor_or_Creditor__c',
    type: 'text', 
    sortable: true
},
{
    label: 'Vendor',
    fieldName: 'Vendor__c',
    type: 'text', 
    sortable: true
}
];

export default class BolDataTable extends LightningElement {
    @api effectiveAccountId;

    @track error;
    @track numberOfRecords;
    @track columns;
    @api sortedDirection = 'desc';
    @api sortedBy = 'Ac_GI_Date__c';
    @api searchKey = '';

    @track accountBOLs;

    @track startDate = null;
    @track endDate = null;

    @track sortBy;
    @track sortDirection;
    @track page = 1; 
    @track items = []; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 15; 
    @track totalRecountCount = 0;
    @track totalPage = 0;

    @wire(getUserBOLs, 
        { accountId: '$effectiveAccountId', searchKey: '$searchKey', sortBy: '$sortedBy', sortDirection: '$sortedDirection', startDate: '$startDate', endDate: '$endDate' }) 
    wiredInvoices ({ error, data }) {
        if(data) {
            let tempOrderList = []; 
            
            data.forEach((record) => {
                let tempOrderRec = Object.assign({}, record);  
                tempOrderRec.BOLUrl = '/bill-of-lading/' + tempOrderRec.Id;
                tempOrderList.push(tempOrderRec);
                
            });
            this.items = tempOrderList;
            this.numberOfRecords = this.items.length;
            this.totalRecountCount = data.length; 
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
            
            this.accountBOLs = this.items.slice(0,this.pageSize); 
            this.endingRecord = this.pageSize;
            this.columns = columns;

            this.error = undefined;
        } else if (error) {
            this.error = error;
            console.log(this.error);
        }
    }

    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; 
            this.displayRecordPerPage(this.page);
        }
    }

    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; 
            this.displayRecordPerPage(this.page);            
        }             
    }

    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.accountBOLs = this.items.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    }    

    sortColumns( event ) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        return refreshApex(this.result);
        
    }
  
    handleKeyChange( event ) {
        this.searchKey = event.target.value;
        return refreshApex(this.result);
    }

    StartDateChange ( event ) {
        this.startDate = event.target.value;
        return refreshApex(this.result);
    }

    EndDateChange ( event ) {
        this.endDate = event.target.value;
        return refreshApex(this.result);
    }
}