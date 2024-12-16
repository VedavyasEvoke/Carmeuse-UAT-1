import { LightningElement, wire, api, track } from 'lwc';
import getproposedlines from '@salesforce/apex/ev_QuoteInfo.getproposeddata';

export default class GetRelatedListRecords extends LightningElement {
    @api recordId;

    @track records;
    @track error;
    @track currencyCode;
    @track variablefuelsurcharge;
    @track columns = [
        { label: 'Supplier', fieldName: 'Supplier', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 60 },
        { label: 'Plant', fieldName: 'Plant__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 45 },
        { label: 'Product', fieldName: 'SBQQ__ProductName__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 100 },
        // { label: 'Quantity', fieldName: 'SBQQ__Quantity__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 35, type: 'number' },
        // { label: 'UOM', fieldName: 'Default_UOM__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 35 },
        { label: 'Qty-UOM', fieldName: 'Qty_UOM__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 50 },
        {
            label: 'Product Price', fieldName: 'List_Unit_Price__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 55,
            type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
        },
        {
            label: 'Freight Price', fieldName: 'Freight_Price__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 55,
            type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
        },
        {
            label: 'Fuel Surch', fieldName: 'Surcharge__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 55,
            type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
        },
        
        {
            label: 'Misc', fieldName: 'Misc_Price__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 55,
            type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
        },
        {
            label: 'Fees', fieldName: 'Fees_Price__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 55,
            type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
        },
        {
            label: 'Total Price per TON/TO', fieldName: 'Total_Price_per_Ton__c', type: 'currency', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 65,
            type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
        },
        // { label: 'Distance', fieldName: 'Distance__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 45 },
        // { label: 'UoM Dist', fieldName: 'UOM_Distance__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 45 },
        { label: 'Curr', fieldName: 'CurrencyIsoCode', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 40 },
        {
            label: 'Co2 Cost', fieldName: 'ZCO2__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 50,
            type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
        },
        { label: 'Dist', fieldName: 'Dist_UOM__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 50 },
        {
            label: 'Total Revenue', fieldName: 'Total_Price__c', type: 'currency', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true,
            type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
        }
    ];
    
    @wire(getproposedlines, { quoteId: '$recordId' })
    wiredAccounts({ data, error }) {
        if (data) {
            this.records = this.prepareRecords(data.QuoteLines);
            this.currencyCode = this.records?.[0]?.CurrencyIsoCode ?? '$';
            this.columns = JSON.parse(JSON.stringify(this.columns));
            console.log(this.records);
        }
        else if (error) {
            this.error = error;
            this.records = undefined;
            this.currency = 'No Currency Chosen On The Quote'; // Fallback if there's a currency missing
        }
    }

   prepareRecords(result) {
        let records = [];
        result.forEach(row => {
            let record = { ...row, Supplier: 'Carmeuse' };
            
            this.columns.forEach(column => {
                if (column.fieldName === 'Surcharge__c') {
               
                 if (row.SBQQ__Quote__r?.Variable_Fuel_Surcharge__c) {
                    console.log('proposed In True', row.Surcharge_variable__c);
                    record[column.fieldName] = row.Surcharge_variable__c ?? 0;
                    console.log('After assignement proposed In True', record[column.fieldName]);
                } else {
                    console.log('proposed In False', row.Surcharge__c);
                    record[column.fieldName] = row.Surcharge__c ?? 0;  // Assign 0 if Surcharge__c is null
                }
            
                }
                if (column.fieldName === 'Qty_UOM__c') {
                    record[column.fieldName] = this.formatQtyUOM(row[column.fieldName]);
                } 
                 //else if(!record[column.fieldName]) {
                //     record[column.fieldName] = row[column.fieldName];
                //     console.log(record[column.fieldName] - row[column.fieldName]);
                // }
            
        });
            records.push(record);
        });
        return records;
    }

    formatQtyUOM(value) {
        if (!value) return value;
        let [quantity, uom] = value.split('/');
        quantity = quantity.replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        return `${quantity}/${uom}`;
    }
}