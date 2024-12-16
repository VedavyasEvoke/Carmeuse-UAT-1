import { LightningElement, track, api, wire } from 'lwc';
import getCompetitorQuoteLineDetails from '@salesforce/apex/ev_QuoteInfo.retriveCompetitorQuoteLine';
 
export default class ev_QuoteLineInfo extends LightningElement {
    @api recordId;
    @track records;
    @track currencyCode;
     @track region;
    @track columns =      [{
            label: 'Supplier', fieldName: 'RecordUrl', type: 'url', typeAttributes: { label: { fieldName: 'Supplier' } },
            wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 60
        },
        { label: 'Plant', fieldName: 'Plant', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 45 },
        { label: 'Product', fieldName: 'CarmeuseProduct', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 100 },
        { label: 'Qty-UOM', fieldName: 'Qty_UOM__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 50 },
        {
            label: 'Product Price', fieldName: 'FOB__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 55,
            type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
        },
        {
            label: 'Freight Price', fieldName: 'Freight_Unit_Price__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 55,
            type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
        },
        {
                label: 'Fuel Surch',
                fieldName: 'FuelSurcharge__c',
                wrapText: true,
                cellAttributes: { style: 'word-break: break-all;' },
                hideDefaultActions: true,
                initialWidth: 55,
                type: 'currency',
                typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
            } 
         
         ,{
            label: 'Misc', fieldName: 'OtherCosts__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 55,
            type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
        },
        {
            label: 'Fees', fieldName: 'FeesUnitPrice__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 55,
            type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
        },
         {
            label: 'Total Price per TON/TO', fieldName: 'Total_Price_per_TON__c', type: 'currency', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 65,
            type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
        },
         { label: 'Curr', fieldName: 'CurrencyIsoCode', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 40 },
        {
            label: 'Co2 Cost', fieldName: 'CO2Cost__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 50,
            type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
        },
        { label: 'Dist', fieldName: 'Dist_UOM__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 50 },
        {
            label: 'Total Revenue', fieldName: 'Total_Price__c', type: 'currency', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true,
            type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
        }];
         
           
     
   
         
   @wire(getCompetitorQuoteLineDetails, { recordIdAccount: '$recordId' })
    wiredAccounts({ data, error }) {
        if (data) {
            this.records = this.prepareRecords(data.QuoteLines);
            this.region = data.CustomerRegion;
            this.currencyCode = this.records?.[0]?.CurrencyIsoCode ?? '$';
            this.columns = JSON.parse(JSON.stringify(this.columns));
            console.log('Competitor data',data.QuoteLines);
        } else if (error) {
            this.error = error;
            this.records = undefined;
            this.currencyCode = 'No Currency Chosen On The Quote'; // Fallback if there's a currency missing
        }
    }
    

    prepareRecords(result) {
        let records = [];
        result.forEach(row => {
            let record = JSON.parse(JSON.stringify(row));
            record['RecordUrl'] = '/' + row.Id;
            record['Supplier'] = row.Competitor__r?.Name ?? row.Legacy_Competitor_Name__c;
            record['Plant'] = row.Plant__r?.Name ?? row.Legacy_Plant_Name__c;
            record['CarmeuseProduct'] = row.Product__r?.Name ?? row.Legacy_Product_Name__c;

            if (record['Qty_UOM__c']) {
                record['Qty_UOM__c'] = this.formatQtyUOM(record['Qty_UOM__c']);
            }

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