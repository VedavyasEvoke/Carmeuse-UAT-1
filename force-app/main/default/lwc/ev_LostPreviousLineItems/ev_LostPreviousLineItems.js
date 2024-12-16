import { LightningElement,api,wire,track } from 'lwc';
import getPreviousQuoteLineDetails from '@salesforce/apex/ev_PreviouslineItems.retrieveLostQuoteLines';
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = ['SBQQ__Quote__c.Customer_Region__c'];
export default class Ev_LostPreviousLineItems extends LightningElement {
 
    @api recordId;

    @track records = [];
    @track error;
    @track currencyCode ='$' ;
    @track region;
    @track columns = [];
    //get Current quote region 
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    rec({ error, data }) {
        if (data) {
            this.region = data.fields.Customer_Region__c ? data.fields.Customer_Region__c.value : '';
             console.log('Data',data);
            
            this.updateColumns();
        } else if (error) {
            this.error = error;
            console.error('Error fetching record:', error);
        }
    }
   //Get previous Line Items from Apex
    @wire(getPreviousQuoteLineDetails, { recordId: '$recordId' })
    handleData({ data, error }) {
        if (data) {
         
           this.records = this.prepareRecords(data);
            // Ensure columns are updated only after records are prepared
            console.log('records',this.records);
            this.updateColumns();
        } else if (error) {
            this.error = error;
            this.records = [];
            console.error('Error fetching quote line details:', error);
        }
    }

    updateColumns() {
        let columns = [
            { label: 'Supplier', fieldName: 'Supplier', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 60 },
            { label: 'Plant', fieldName: 'Plant__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 45 },
            { label: 'Product', fieldName: 'SBQQ__ProductName__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 100 },
            { label: 'Qty-UOM', fieldName: 'Qty_UOM__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 50 },
            { label: 'Product Price', fieldName: 'List_Unit_Price__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 55, type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' } },
            { label: 'Freight Price', fieldName: 'Freight_Price__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 55, type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' } }
        ];

        // Add  columns based on region Turkey
        if (this.region !== 'Turkey') {
            columns.push({
                label: 'Fuel Surch',
                fieldName: 'Surcharge__c',
                wrapText: true,
                cellAttributes: { style: 'word-break: break-all;' },
                hideDefaultActions: true,
                initialWidth: 55,
                type: 'currency',
                typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
            });
        }
          

        // Add remaining columns
        columns.push(
            { label: 'Total Price per TON/TO', fieldName: 'Total_Price_per_Ton__c', type: 'currency', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 65, typeAttributes: { currencyCode: this.currencyCode, step: '0.001' } },
            { label: 'Curr', fieldName: 'CurrencyIsoCode', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 40 },
            { label: 'Co2 Cost', fieldName: 'ZCO2__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 50, type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' } },
            { label: 'Dist', fieldName: 'Dist_UOM__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 50 },
            { label: 'Total Revenue', fieldName: 'Total_Price__c', type: 'currency', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, typeAttributes: { currencyCode: this.currencyCode, step: '0.001' } },
            { label: 'Start Date', fieldName: 'ParentValidFrom', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true}
           ,{ label: 'End Date', fieldName: 'ParentValidTo',  wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true}

        );

        this.columns = columns;
    }
      prepareRecords(data) {
      
        if (data.length > 0) {
           
            this.currencyCode = data[0].CurrencyIsoCode || '$';
        }

        return data.map(row => {
            const record = { ...row, Supplier: 'Carmeuse' };
            if (record.Qty_UOM__c) {
                record.Qty_UOM__c = this.formatQtyUOM(record.Qty_UOM__c);
            }
            // Add Parent fields SBQQ__Quote__r.Valid_from__c and SBQQ__Quote__r.Valid_to__c to the record
        if (record.SBQQ__Quote__r) {
            if (record.SBQQ__Quote__r.Valid_From__c) {
                record.ParentValidFrom = record.SBQQ__Quote__r.Valid_From__c;
            }
            if (record.SBQQ__Quote__r.Valid_To__c) {
                record.ParentValidTo = record.SBQQ__Quote__r.Valid_To__c;
            }
        }
            return record;
        });
    }

    formatQtyUOM(value) {
        if (!value) return value;
        let [quantity, uom] = value.split('/');
        quantity = quantity.replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        return `${quantity}/${uom}`;
    }
}