import { LightningElement, track, api, wire } from 'lwc';
import getCompetitorQuoteLineDetails from '@salesforce/apex/ev_QuoteInfo.retriveCompetitorQuoteLine';

export default class Ev_CompetitorLineItemEu extends LightningElement {
    @api recordId;

    @track records;
    @track currencyCode = '$'; // Default value for currency code
    @track columns = [];
    @track region;

    @wire(getCompetitorQuoteLineDetails, { recordIdAccount: '$recordId' })
    wiredAccounts({ data, error }) {
        if (data) {
            // Handle data
            this.records = this.prepareRecords(data.QuoteLines);
            this.region = data.CustomerRegion;
            this.currencyCode = this.records.length > 0 ? this.records[0].CurrencyIsoCode : '$';
            this.updateColumns();
            console.log('Data:', data);
        } else if (error) {
            // Handle error
            this.error = error;
            this.records = [];
            this.currencyCode = 'No Currency Chosen On The Quote'; // Fallback if there's a currency missing
            console.error('Error:', error);
        }
    }

    updateColumns() {
        let columns = [
            {
                label: 'Supplier', fieldName: 'RecordUrl', type: 'url', typeAttributes: { label: { fieldName: 'Supplier' } },
                wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 60
            },
            { label: 'Plant', fieldName: 'Plant', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 45 },
            { label: 'Product', fieldName: 'Product_2__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 100 },
            { label: 'Qty-UOM', fieldName: 'Qty_UOM__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 50 },
            {
                label: 'Product Price', fieldName: 'FOB__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 55,
                type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
            },
            {
                label: 'Freight Price', fieldName: 'Freight_Unit_Price__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 55,
                type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
            }
        ];

        // Add columns based on region Turkey
        if (this.region !== 'Turkey') {
            columns.push({
                label: 'Energy Surch',
                fieldName: 'FuelSurcharge__c',
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
            {
                label: 'Co2 Surcharge', fieldName: 'CO2Cost__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 50,
                type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
            },
            {
                label: 'Total Price per TON/TO', fieldName: 'Total_Price_per_TON__c', type: 'currency', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 65,
                type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
            },
            { label: 'Curr', fieldName: 'CurrencyIsoCode', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 40 },
            { label: 'Dist', fieldName: 'Dist_UOM__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 50 },
            {
                label: 'Total Revenue', fieldName: 'Total_Price__c', type: 'currency', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true,
                type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
            }
        );

        this.columns = columns;
    }

    prepareRecords(result) {
         if (result.length > 0) {
           
            this.currencyCode = result[0].CurrencyIsoCode || '$';
        }
        return result.map(row => {
            let record = { ...row };
            record['RecordUrl'] = '/' + row.Id;
            record['Supplier'] = row.Competitor__r?.Name ?? row.Legacy_Competitor_Name__c;
            record['Plant'] = row.Plant__r?.Name ?? row.Legacy_Plant_Name__c;
            record['Product_2__c'] = row.Product__r?.Name ?? row.Product_2__c;

            if (record['Qty_UOM__c']) {
                record['Qty_UOM__c'] = this.formatQtyUOM(record['Qty_UOM__c']);
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