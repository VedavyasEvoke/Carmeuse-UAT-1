import { LightningElement ,api, wire, track} from 'lwc';
import getUserOrders from '@salesforce/apex/OrderController.getUserOrders';
import { refreshApex } from '@salesforce/apex';

const columns = [{
        label: 'Order Number',
        fieldName: 'OrderUrl',
        type: 'url',
        typeAttributes: {label: { fieldName: 'OrderNumber' }, target: '_self'}
    },
    {
        label: 'Status',
        fieldName: 'Status',
        type: 'text'
    },
    {
        label: 'Ordered Date',
        fieldName: 'EffectiveDate',
        type: 'date-local', 
        sortable: true
    }
];

export default class OrderDataTable extends LightningElement {
    
    @api effectiveAccountId;

    @track error;
    @track accountOrders;
    @track numberOfRecords;
    @track value;
    @track columns;
    @api sortedDirection = 'desc';
    @api sortedBy = 'EffectiveDate';
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
 
    @wire(getUserOrders, 
        { accountId: '$effectiveAccountId', searchKey: '$searchKey', sortBy: '$sortedBy', sortDirection: '$sortedDirection', startDate: '$startDate', endDate: '$endDate' }) 
    wiredInvoices ({ error, data }) {
        if(data) {
            let tempOrderList = []; 
            
            data.forEach((record) => {
                let tempOrderRec = Object.assign({}, record);  
                tempOrderRec.OrderUrl = '/order/' + tempOrderRec.Id;
                tempOrderList.push(tempOrderRec);
                
            });
            this.items = tempOrderList;
            this.numberOfRecords = this.items.length;
            this.totalRecountCount = data.length; 
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
            
            this.accountOrders = this.items.slice(0,this.pageSize); 
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

        this.accountOrders = this.items.slice(this.startingRecord, this.endingRecord);

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