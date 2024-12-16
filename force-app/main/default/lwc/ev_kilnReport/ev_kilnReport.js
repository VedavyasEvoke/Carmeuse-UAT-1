import { LightningElement, api, wire, track } from 'lwc';
import getCompaniesWithCompetitorsCaptive from '@salesforce/apex/ev_KilnsReportController.getCompaniesWithCompetitorsCaptive';
import getCompaniesWithCompetitorsMerchant from '@salesforce/apex/ev_KilnsReportController.getCompaniesWithCompetitorsMerchant';
import getGroupDetails from '@salesforce/apex/ev_KilnsReportController.getGroupDetails';
import { refreshApex } from '@salesforce/apex';
import MY_LOGO from '@salesforce/resourceUrl/LOGO';

export default class ev_kilnReport extends LightningElement {
    logoUrl = MY_LOGO;

    @api recordId;
    @track selectedGroupName;
    @track selectedGroup;
    @track currentPage = 1;
    @track pageSize = 10;
    @track totalPages;
    @track companiesWithMerchantCompetitors;
    @track companiesWithCaptiveCompetitors;
    @track duplicateRecords;
    @track isFirstPage = true;
    @track isLastPage = false;
     @track overallTotalEstimProdTpyMer = 0;
    @track overallTotalNomCapTpyMer = 0;
     @track overallTotalEstimProdTpyCap = 0;
    @track overallTotalNomCapTpyCap = 0;

    connectedCallback() {
      
        this.getMerchant();
    }

    getMerchant() {
        // Check if recordId is available before calling Apex
        if (this.recordId) {
            getCompaniesWithCompetitorsMerchant({ selectedGroup: this.recordId })
                .then(result => {
                    if (result) {
                        console.log('RecordId === ' + this.recordId);
                        console.log('Merchant Competitors:', result);
                        
                        // Log details for debugging
                        result.forEach(competitor => {
                            console.log('companyName: ' + competitor.companyName);
                            console.log('competitor: ' + competitor.competitor);
                            console.log('kilnReports: ' + competitor.competitor.Kiln_Report__r);
                       
                        });
                          let totalNomCapTpyMer = 0;
                          let totalEstimProdTpyMer =0;
                    // Calculate total values
                        result.forEach(competitor => {
                            const nomCapTpy = parseFloat(competitor.overallTotalNomCapTpy) || 0;
                            const estimProdTpy = parseFloat(competitor.overallTotalEstimProdTpy) || 0;
                            totalNomCapTpyMer += nomCapTpy;
                            totalEstimProdTpyMer += estimProdTpy;
                        });

                        // Remove decimals
                        this.overallTotalNomCapTpyMer = Math.floor(totalNomCapTpyMer);
                        this.overallTotalEstimProdTpyMer = Math.floor(totalEstimProdTpyMer);

                        // Assign records for pagination
                        this.duplicateRecords = result;
                        this.totalPages = Math.ceil(result.length / this.pageSize);
                        this.companiesWithMerchantCompetitors = result.slice(0, this.pageSize);

                        console.log('Overall Total Nom Cap Tpy (Merchant):', this.overallTotalNomCapTpyMer);
                        console.log('Overall Total Estim Prod Tpy (Merchant):', this.overallTotalEstimProdTpyMer);
                   
                        this.getGroupName();
                    }
                })
                .catch(error => {
                    console.error('Error in getMerchant:', error);
                });
        } else {
            console.warn('recordId is not available yet.');
        }
    }

    @wire(getCompaniesWithCompetitorsCaptive, { selectedGroup: '$recordId' })
    wiredcompaniesWithCompetitors({ data, error }) {
        if (data) {
            console.log('Captive Competitors Data:', data);
            data.forEach(competitor => {
                console.log('companyName: ' + competitor.companyName);
                console.log('competitor: ' + competitor.competitor);
                console.log('kilnReports: ' + competitor.competitor.Kiln_Report__r);
            });
            let totalNomCapTpyCap = 0;
                          let totalEstimProdTpyCap =0;
                    // Calculate total values
                        data.forEach(competitor => {
                            const nomCapTpy = parseFloat(competitor.overallTotalNomCapTpy) || 0;
                            const estimProdTpy = parseFloat(competitor.overallTotalEstimProdTpy) || 0;
                            totalNomCapTpyCap += nomCapTpy;
                            totalEstimProdTpyCap += estimProdTpy;
                        });

                        // Remove decimals
                        this.overallTotalNomCapTpyCap = Math.floor(totalNomCapTpyCap);
                        this.overallTotalEstimProdTpyCap = Math.floor(totalEstimProdTpyCap);

                       

                        console.log('Overall Total Nom Cap Tpy (Captive):', this.overallTotalNomCapTpyCap);
                        console.log('Overall Total Estim Prod Tpy (Captive):', this.overallTotalEstimProdTpyCap);

            this.duplicateRecords = data;
            this.totalPages = Math.ceil(data.length / this.pageSize);
            this.companiesWithCaptiveCompetitors = data.slice(0, this.pageSize);
            this.getGroupName();
        } else if (error) {
            console.error('Error in wiredcompaniesWithCompetitors:', error);
        }
    }

    getGroupName() {
        getGroupDetails({ groupId: this.recordId })
            .then(result => {
                this.selectedGroupName = result.Name;
            })
            .catch(error => {
                console.error('Error in getGroupName:', error);
            });
    }

    handleFirst() {
        this.currentPage = 1;
        this.isFirstPage = true;
        this.isLastPage = false;
        this.companiesWithMerchantCompetitors = this.duplicateRecords.slice(0, this.pageSize);
    }

    handleLast() {
        this.currentPage = this.totalPages;
        this.isFirstPage = false;
        this.isLastPage = true;
        this.companiesWithMerchantCompetitors = this.duplicateRecords.slice((this.totalPages - 1) * this.pageSize, this.pageSize * this.totalPages);
    }

    handleBackward() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.companiesWithMerchantCompetitors = this.duplicateRecords.slice((this.currentPage - 1) * this.pageSize, this.pageSize * this.currentPage);
        }
    }

    handleForward() {
        if (this.currentPage < this.totalPages) {
            this.companiesWithMerchantCompetitors = this.duplicateRecords.slice(this.currentPage * this.pageSize, this.pageSize * (this.currentPage + 1));
            this.currentPage += 1;
        }
    }

    handleMenuSelect(event) {
        this.selectedvalue = event.detail.value;
        const selectedGrp = this.recordId;
        let vfPageUrlWithParameters;

        if (this.selectedvalue === 'pdf') {
            vfPageUrlWithParameters = '/apex/ev_kilnReportpdf?selectedgroup=' + selectedGrp;
            window.open(vfPageUrlWithParameters, '_blank');
        } else if (this.selectedvalue === 'Excel') {
            vfPageUrlWithParameters = '/apex/ev_kilnReportExcel?selectedgroup=' + selectedGrp;
            window.location.href = vfPageUrlWithParameters;
        }
    }

    handleRefresh() {
        console.log('Refreshing data...');
        refreshApex(this.wiredcompaniesWithCompetitors);
        this.getMerchant();
    }
     // Getter function to calculate total
    get totalEstimProdTpy() {
        return this.overallTotalEstimProdTpyMer + this.overallTotalEstimProdTpyCap;
    }
     // Getter function to calculate total
    get totalNomProdTpy() {
        return this.overallTotalNomCapTpyCap + this.overallTotalNomCapTpyMer;
    }
}