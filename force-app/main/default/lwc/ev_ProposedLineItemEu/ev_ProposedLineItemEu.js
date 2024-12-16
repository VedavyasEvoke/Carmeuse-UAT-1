import { LightningElement, api, track, wire } from 'lwc';
import getproposedlines from '@salesforce/apex/ev_QuoteInfo.getproposeddata';

export default class Ev_ProposedLineItemEu extends LightningElement {
    @api recordId;

    @track records = [];
    @track error;
    @track currencyCode = '$';
    @track region;
    @track columns = [];

    // Get previous Line Items from Apex
    @wire(getproposedlines, { quoteId: '$recordId' })
    handleData(response) {
        const { data, error } = response;
        if (data) {
            // Check if data.QuoteLines exists before accessing it
            if (data.QuoteLines) {
                this.records = this.prepareRecords(data.QuoteLines);
                this.region = data.CustomerRegion;
                this.updateColumns();
            }
        } else if (error) {
            this.error = error;
            this.records = [];
            console.error('Error fetching quote line details:', error);
        }
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
            return record;
        });
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

        if (this.region == 'Western Europe') {
            columns.push({
                label: 'Energy Surch',
                fieldName: 'ZSFT__c',
                wrapText: true,
                cellAttributes: { style: 'word-break: break-all;' },
                hideDefaultActions: true,
                initialWidth: 55,
                type: 'currency',
                typeAttributes: { currencyCode: this.currencyCode, step: '0.001' }
            });
        }
         if (this.region == 'Central Europe') {
            columns.push({
                label: 'Co2 Surch Agriculture',
                fieldName: 'ZCO3__c',
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
            { label: 'Co2 Surcharge', fieldName: 'ZCO2__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 50, type: 'currency', typeAttributes: { currencyCode: this.currencyCode, step: '0.001' } },
            { label: 'Total Price per TON/TO', fieldName: 'Total_Price_per_Ton__c', type: 'currency', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 65, typeAttributes: { currencyCode: this.currencyCode, step: '0.001' } },
            { label: 'Curr', fieldName: 'CurrencyIsoCode', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 40 },
            { label: 'Dist', fieldName: 'Dist_UOM__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 50 },
            { label: 'Payment Terms', fieldName: 'Payment_Terms__c', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, initialWidth: 50 },
            { label: 'Total Revenue', fieldName: 'Total_Price__c', type: 'currency', wrapText: true, cellAttributes: { style: 'word-break: break-all;' }, hideDefaultActions: true, typeAttributes: { currencyCode: this.currencyCode, step: '0.001' } }
        );

        this.columns = columns;
    }

    formatQtyUOM(value) {
        if (!value) return value;
        let [quantity, uom] = value.split('/');
        quantity = quantity.replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        return `${quantity}/${uom}`;
    }
}