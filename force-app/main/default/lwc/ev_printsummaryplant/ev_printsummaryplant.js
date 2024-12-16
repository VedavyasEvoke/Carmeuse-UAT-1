import { LightningElement,track,api, wire} from 'lwc';
import MY_LOGO from '@salesforce/resourceUrl/LOGO';
import getProductDetails from '@salesforce/apex/ev_printsummaryplantkilncontroller.getProductDetails';
import KilnsDetails from '@salesforce/apex/ev_printsummaryplantkilncontroller.KilnsDetails';
import { refreshApex } from '@salesforce/apex';
export default class Printsummarykilns extends LightningElement {
    //competitorData;
    @api selectedPlant;
    @api recordId;
     groupFilter = '';
     countryFilter = '';
     @track currentPage = 1;
     @track totalPages; // Set your total number of pages
    //  @track isFirstPage = true;
    //  @track isLastPage = false;
    //  @track isPreviousDisabled = true;
    //  @track isNextDisabled = false;
     @track fistPage = 1;
     @api selectedGroupName;
     @track displaykilns;
     @api selectedCompanyName;
     @api selectedCountry;
     @api childRecords;
     @api kilnsRecords;
     @track pageSize = 10;
     @track kilndata;
     @track isDisabled = false;
     
     logoUrl = MY_LOGO; // Updated logo URL

    // @wire(getProductDetails, {plandId :'$recordId'})
    // productInfo;

    @wire(getProductDetails,{plandId :'$recordId'}) productInfo(result) {
        this.productInfoResult = result;
        const { data, error } = result;
        if (data){
            this.displayplant = data;
            this.getDisplayDetailsFromPlant();
            // this.selectedGroupName= data.Group_Plants__c;
            // this.selectedCompanyName = data.Plant_Company_Name__c;
            // this.selectedCountry = data.Country__c;
        } else if (error) {
            console.error(error);
        }
    }

    @wire(KilnsDetails,{plandId: '$recordId'}) kilnInfo(result) {
        this.kilnInfoResult = result;    
        const { data, error } = result;
        if (data) {
            this.totalPages = Math.ceil(data.length/this.pageSize);
            this.displaykilns = data.slice(0, this.pageSize);
            console.log(data);
        } else if (error) {
            console.error(error);
        }
    }

    getDisplayDetailsFromPlant(){
        console.log('In getDisplayDetailsFromPlant');
        getProductDetails({plandId : this.recordId}).then(result=>{
          this.selectedGroupName= result[0].Group_Plants__c;
          console.log('this.selectedGroupName' + this.selectedGroupName);
          this.selectedCompanyName = result[0].Plant_Company_Name__c;
          console.log('this.selectedCompanyName' + this.selectedCompanyName);
          this.selectedCountry = result[0].Country__c;
          console.log('this.selectedCountry' + this.selectedCountry);
        }).catch(error=>{
            console.log(error);
        });
      }

    handleFirstPage() {
        console.log('handleFirstPage');
        this.currentPage = 1;
        this.isFirstPage = true;
        this.isLastPage = false;
        this.isPreviousDisabled = true;
        this.isNextDisabled = false;
        this.displaykilns = this.kilnInfoResult.data.slice(0, this.pageSize);
        }

    handleBackward() {
    console.log('handleBackward');
    if (this.currentPage > this.fistPage){
    this.currentPage = this.currentPage - 1;
    console.log(this.currentPage*this.pageSize);
    console.log(this.currentPage);
    console.log(this.pageSize);
    this.displaykilns = this.kilnInfoResult.data.slice((this.currentPage-1)*this.pageSize, this.pageSize*this.currentPage);
    console.log(this.kilnInfoResult.data);
    console.log(this.displaykilns);
    }
        // this.pageNumber = this.pageNumber - 1;
        // this.paginationHelper();
        //  if (this.currentPage > 1) {
        //      this.currentPage--;
        //  }
    }

    handleForward() {
        console.log('handleForward');
        console.log(this.currentPage*this.pageSize);
        console.log(this.currentPage);
        console.log(this.pageSize);
        if(this.currentPage <= this.totalPages){
            if(this.currentPage==this.totalPages){
                isDisabled=true;
            }
        this.displaykilns = this.kilnInfoResult.data.slice(this.currentPage*this.pageSize, this.pageSize*(this.currentPage+1));
        
        console.log(this.kilnInfoResult.data);
        console.log(this.displaykilns);
        this.currentPage = this.currentPage + 1;
            }    
        }

        // this.pageNumber = this.pageNumber + 1;
        // this.paginationHelper();
        //   if (this.currentPage < this.totalPages) {
        //      this.currentPage++;
        //  }

    handleLastPage() {
    this.currentPage = this.totalPages;
    this.isFirstPage = false;
    this.isLastPage = true;
    this.isPreviousDisabled = false;
    this.isNextDisabled = true;
    this.displaykilns = this.kilnInfoResult.data.slice((this.totalPages-1)*this.pageSize, this.pageSize*this.totalPages);
    // this.displayAccounts = this.accounts.slice(
    //   (this.currentPage - 1) * this.pageSize,
    //   this.currentPage * this.pageSize
    // );

        // console.log('handleLastPage');
        // this.pageNumber = this.pageNumber + 1;
        // this.paginationHelper();
        //   if (this.currentPage < this.totalPages) {
        //      this.currentPage++;
        //  }
    }

    handleRefresh() {
        console.log('In handle refresh');
        refreshApex(this.productInfo);
        refreshApex(this.kilnInfoResult);
    }

     handleResolutionChange() {
         // Implement resolution change logic here
     }

     handleMenuSelect(event)
    {
        this.selectedvalue=event.detail.value;
        if(this.selectedvalue == 'pdf')
        {
       debugger
      var selectedPnt = this.recordId;
      console.log(selectedPnt);
     // getGroupId({listCompetitors:this.companiesWithCompetitors}).then(result=>{console.log("data transerfered successfully")}).catch(error=>{console.log(error)});
        //const vfPageUrl = '/apex/printsummaryplant';
        const vfPageUrlWithParameters = '/apex/ev_printsummaryplant?selectedPlant='+ selectedPnt;
        // Navigate to the Visualforce page
        //window.location.href = vfPageUrl;
        window.open(vfPageUrlWithParameters, '_blank');
        }

        else if(this.selectedvalue == 'Excel')
        {
            debugger
      var selectedPnt = this.recordId;
      console.log(selectedPnt);
     // getGroupId({listCompetitors:this.companiesWithCompetitors}).then(result=>{console.log("data transerfered successfully")}).catch(error=>{console.log(error)});
        //const vfPageUrl = '/apex/printsummaryplant';
        const vfPageUrlWithParameters = '/apex/ev_printsummaryplantexcel?selectedPlant='+ selectedPnt;
        // Navigate to the Visualforce page
        window.location.href = vfPageUrlWithParameters;
        //window.open(vfPageUrlWithParameters, '_blank');
        }
    }
     
}