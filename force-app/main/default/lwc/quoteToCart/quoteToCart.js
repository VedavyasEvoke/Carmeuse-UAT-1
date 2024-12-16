import { LightningElement, api, wire } from 'lwc';
import getQuoteLines from '@salesforce/apex/AccountUtils.getAccountRelatedQuoteLines';

const columns = [
    { label: 'Product Name', fieldName: 'productName', type: 'text' },
    { label: 'Product Code', fieldName: 'productCode', type: 'text' },
    { label: 'Material Description', fieldName: 'materialDescription', type: 'text' },
    { label: 'Stock Keeping Unit', fieldName: 'stockKeepingUnit', type: 'text' }
];
export default class QuoteToCart extends LightningElement {
    @api recordId;
    @api effectiveAccountId;
    columns = columns;
    quoteLines = [];
    connectedCallback() {
        this.getQuoteLines();
    }

    getQuoteLines() {
        getQuoteLines({ accountId: this.effectiveAccountId })
            .then(result => {
                this.quoteLines = result.map(quoteLine => ({
                    id: quoteLine.Id,
                    productCode: quoteLine.ProductCode,
                    productName: quoteLine.SBQQ__Product__r.Name,
                    productCode: quoteLine.SBQQ__Product__r.ProductCode,
                    materialDescription: quoteLine.SBQQ__Product__r.MaterialDescription__c,
                    stockKeepingUnit: quoteLine.SBQQ__Product__r.StockKeepingUnit
                }));                
            })
            .catch(error => {
                console.log('ERROR IN getQuoteLines()-->'+error);
            });
    }
}