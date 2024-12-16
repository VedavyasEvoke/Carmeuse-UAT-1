import { LightningElement, wire, track, api } from 'lwc';
import getCompetitorData from '@salesforce/apex/ev_competitorController.getCompetitorData';
import getCountryData from '@salesforce/apex/ev_competitorController.getCountryData';
import MY_LOGO from '@salesforce/resourceUrl/LOGO';
import { refreshApex } from '@salesforce/apex';

export default class EvPrintSummaryCompany extends LightningElement {
    @track competitorData;
    @track groupFilter = '';
    @track countryFilter = '';
    @track fistPage = 1;
    @track currentPage = 1;
    @api selectedGroupName;
    @api selectedCountry;
    @api childRecords;
    @api selectedCompany;
    @api recordId;
    @track pageSize = 5;
    @track totalPages;
    @track duplicateRecords;
    logoUrl = MY_LOGO;

    @wire(getCompetitorData, { cmpId: '$recordId' })
    wiredCompaniesWithplants(result) {
        this.wiredCompaniesWithplantsResult = result;
        const { data, error } = result;
        if (data) {
            this.duplicateRecords = data;
            this.totalPages = Math.ceil(data.length / this.pageSize);
            this.updateChildRecords(data.slice(0, this.pageSize));
            if (this.childRecords.length > 0) {
                this.selectedCountry = this.childRecords[0].Country__c;
                this.getCountry();
            }
        } else if (error) {
            console.error(error);
        }
    }

    updateChildRecords(records) {
        this.childRecords = records.map(record => ({
            ...record,
            formattedNominalCapacity: this.formatNumberWithCommas(record.Nominal_Capacity_t_y__c),
            formattedEstimatedProduction: this.formatNumberWithCommas(record.Estimated_Production_t_y__c)
        }));
    }

    formatNumberWithCommas(value) {
        if (value === null || value === undefined) {
            return '';
        }
        return Number(value).toLocaleString();
    }

    getCountry() {
        console.log('In getCountry');
        getCountryData({ cmpId: this.recordId })
            .then(result => {
                this.selectedCountry = result.Country__c;
                this.selectedGroupName = result.Name;
            })
            .catch(error => {
                console.error(error);
            });
    }

    handleMenuSelect(event) {
        this.selectedvalue = event.detail.value;
        const selectedCmp = this.recordId;
        console.log(selectedCmp);
        let vfPageUrlWithParameters;
        if (this.selectedvalue === 'pdf') {
            vfPageUrlWithParameters = `/apex/ev_printsummarycompany?selectedcompany=${selectedCmp}`;
            window.open(vfPageUrlWithParameters, '_blank');
        } else if (this.selectedvalue === 'Excel') {
            vfPageUrlWithParameters = `/apex/ev_printsummarycompanyexcel?selectedcompany=${selectedCmp}`;
            window.location.href = vfPageUrlWithParameters;
        }
    }

    handlePrint() {
        const vfPageUrl = '/apex/ev_printsummarycompany';
        window.open(vfPageUrl, '_blank');
    }

    handleFirst() {
        console.log('handleFirstPage');
        this.currentPage = this.fistPage;
        this.updateChildRecords(this.duplicateRecords.slice(0, this.pageSize));
    }

    handleLast() {
        this.currentPage = this.totalPages;
        this.updateChildRecords(this.duplicateRecords.slice((this.totalPages - 1) * this.pageSize, this.pageSize * this.totalPages));
    }

    handleBackward() {
        console.log('handleBackward');
        if (this.currentPage > this.fistPage) {
            this.currentPage--;
            this.updateChildRecords(this.duplicateRecords.slice((this.currentPage - 1) * this.pageSize, this.pageSize * this.currentPage));
        }
    }

    handleForward() {
        console.log('handleForward');
        if (this.currentPage < this.totalPages) {
            this.updateChildRecords(this.duplicateRecords.slice(this.currentPage * this.pageSize, this.pageSize * (this.currentPage + 1)));
            this.currentPage++;
        }
    }

    handleRefresh() {
        console.log('In handle refresh');
        refreshApex(this.wiredCompaniesWithplantsResult);
    }

    handleBack() {
        // Implement back logic here
    }

    handleResolutionChange() {
        // Implement resolution change logic here
    }
}