import { LightningElement ,api, wire, track} from 'lwc';
import getUserInvoices from '@salesforce/apex/OrderController.getUserInvoices';
import { refreshApex } from '@salesforce/apex';

const columns = [{
        label: 'Account Invoice Name',
        fieldName: 'InvoiceUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Name' }, target: '_self'}
    },
    {
        label: 'Invoice Date',
        fieldName: 'InvoiceDate__c',
        type: 'date-local',
        sortable: true
    },
    {
        label: 'Invoice Number',
        fieldName: 'Invoice_Number__c',
        type: 'text'
    }
];

export default class InvoiceDataTable extends LightningElement {
    
    @api effectiveAccountId;

    @track error;
    @track accountInvoices;
    @track numberOfRecords;
    @track value;
    @track columns;
    @api sortedDirection = 'desc';
    @api sortedBy = 'InvoiceDate__c';
    @api searchKey = '';
    result;

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
 
    @wire(getUserInvoices, 
        { accountId: '$effectiveAccountId', searchKey: '$searchKey', sortBy: '$sortedBy', sortDirection: '$sortedDirection', startDate: '$startDate', endDate: '$endDate' }) 
    wiredInvoices ({ error, data }) {
        if(data) {
            let tempInvoiceList = []; 
            
            data.forEach((record) => {
                let tempInvoiceRec = Object.assign({}, record);  
                tempInvoiceRec.InvoiceUrl = '/accountinvoice/' + tempInvoiceRec.Id;
                tempInvoiceList.push(tempInvoiceRec);
                
            });
            this.items = tempInvoiceList;
            this.numberOfRecords = this.items.length;
            this.totalRecountCount = data.length; 
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
            
            this.accountInvoices = this.items.slice(0,this.pageSize); 
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

        this.accountInvoices = this.items.slice(this.startingRecord, this.endingRecord);

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