import { LightningElement,track } from 'lwc';
import getInvoicesWithDocuments from '@salesforce/apex/AccountUtils.getInvoicesWithDocuments';
import getAccountInvoices from '@salesforce/apex/AccountUtils.getAccountInvoices';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class InvoiceAttachmentReport extends LightningElement {
    invoiceIds = [];
    @track fileType = '';
    @track accountInvoices;
    @track files = false;
    @track withoutFiles = false;
    @track isLoading = false;
    connectedCallback(){
    }
    async handelDownload(event){
        const type = event.target.dataset.type;
        const isWithFiles = type === 'with';
        this.fileType = isWithFiles ? 'With Files' : 'Without Files';
        const method = this.fetchInvoicesWithFile;

        const fileToaster = new ShowToastEvent({
            title: 'Account Invoice Files',
            message : 'Wait File Is Getting Prepare For Download',
            variant: 'warning',
            mode: 'dismissible'
        });
        this.dispatchEvent(fileToaster);
        this.isLoading = true;
        await method.call(this);
    }

    async fetchInvoicesWithFile() {
        await getInvoicesWithDocuments()
            .then(result => {
                if (result) {
                    this.invoiceIds = result;

                    if (this.invoiceIds.length > 0 && this.fileType === 'With Files') {
                        this.files = true;
                        this.getAccountInvoices();
                    } else if(this.invoiceIds.length > 0 && this.fileType === 'Without Files') {
                        this.getAccountInvoices();
                    } else {
                        console.log('No Invoices to download');
                    }
                }
            })
            .catch(error => {
                console.log('Error to get Invocies With File -->' + JSON.stringify(error));
            })
    }



    async getAccountInvoices() {
        await getAccountInvoices({setIds : this.invoiceIds, fileType : this.fileType})
        .then(result => {
            if(this.fileType === 'Without Files') {
                result = result.filter(invoice => !this.invoiceIds.includes(invoice.Id));               
            }
            this.accountInvoices = this.convertToCSV(result);
            this.downloadCSV();
        })
        .catch(error => {
            console.log('Error to fetch Invoice field data -->' + JSON.stringify(error));
        })
    }

    convertToCSV(data) {
        const header = ['Id', 'Name', 'Invoice_Number', 'Invoice_Account', 'Invoice_External_Account', 'Invoice_Date'];
        const rows = data.map(record => [
            record.Id,
            record.Name,
            record.Invoice_Number__c,
            record.AccountInvoiceRelation__c,
            record.InvoiceExternalAccountNumber__c,
            record.InvoiceDate__c
        ]);
        return [header, ...rows].map(e => e.join(',')).join('\n');
    }

    downloadCSV(){
        var element = 'data:application/vnd.ms-excel,' + encodeURIComponent(this.accountInvoices);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        // use .csv as extension on below line if you want to export data as csv
        downloadElement.download = this.files ? 'Account Invoice With Files.csv' : 'Account Invoice Without Files.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
        this.files = false;
        this.withoutFiles = false; 
        this.isLoading = false;
    }
}