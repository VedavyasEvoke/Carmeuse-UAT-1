import { LightningElement, wire, track, api } from 'lwc';
import MY_LOGO from '@salesforce/resourceUrl/LOGO';
import getCompaniesWithCompetitors from '@salesforce/apex/ev_printsummarycontroller.getCompaniesWithCompetitors';
import getGroupDetails from '@salesforce/apex/ev_printsummarycontroller.getGroupDetails';
import { refreshApex } from '@salesforce/apex';
//import getGroupId from '@salesforce/apex/printsummarycontroller.getGroupId';
export default class ev_Printsummarygroup extends LightningElement {
    
    @track currentPage = 1;
    @track fistPage=1;
    @track pageSize=2;
	@api selectedGroup;
    @api selectedGroupName;
    @track selectedvalue;
    @api recordId;
    @track duplicateRecords;
    @track totalPages; // Set your total number of pages
    logoUrl = MY_LOGO; // Updated logo URL
    @track companiesWithCompetitors;
    @track EstimatedProductionty;
      FreeCapTy;
     TotalNoKilns;
     NominalCapacityTy;


   /*@wire(getCompaniesWithCompetitors,{selectedGroup: '$selectedGroup'})
    wiredCompaniesWithCompetitors({ error, data }) {
        if (data) {
            this.companiesWithCompetitors = data;
            console.log(data);
        } else if (error) {
            console.error(error);
        }
    }*/
    @wire(getCompaniesWithCompetitors,{selectedGroup: '$recordId'}) wiredCompaniesWithCompetitors(result) {
        this.wiredCompaniesWithCompetitorsResult = result;         
        const { data, error } = result;
        if (data) {
            this.getGroupName();
            this.totalPages = Math.ceil(data.length/this.pageSize);
            //this.companiesWithCompetitors = data;
            this.duplicateRecords = data;
            this.companiesWithCompetitors = data.slice(0, this.pageSize);
            console.log(data);
        } else if (error) {
            console.error(error);
        }
    }
    getGroupName(){

      getGroupDetails({groupId:this.recordId}).then(result=>{
          this.selectedGroupName=result.Name;
          this.EstimatedProductionty =result.Estimated_Production_t_y__c;
          this.FreeCapTy =result.Free_Capacity_t_y__c;
          this.NominalCapacityTy = result.Nominal_Capacity_t_y__c;
          this.TotalNoKilns = result.Total_No_Kilns__c;

        
      }).catch(error=>{
          console.log(error);
          });
    }
    handlePrint() {
        const vfPageUrl = '/apex/ev_printsummarygroup';

        // Navigate to the Visualforce page
        //window.location.href = vfPageUrl;
        window.open(vfPageUrl, '_blank');
    }

   handleFirst() {
        console.log('handleFirstPage');
        this.currentPage = this.fistPage;
        this.companiesWithCompetitors = this.duplicateRecords.slice(0, this.pageSize);
        }
    handleLast() {
    this.currentPage = this.totalPages;
    this.companiesWithCompetitors = this.duplicateRecords.slice((this.totalPages-1)*this.pageSize, this.pageSize*this.totalPages);
    
    }
     handleBackward() {
    console.log('handleBackward');
    if (this.currentPage > this.fistPage){
    this.currentPage = this.currentPage - 1;
    this.companiesWithCompetitors = this.duplicateRecords.slice((this.currentPage-1)*this.pageSize, this.pageSize*this.currentPage);
    }
       
    }

     handleForward() {
         console.log('handleForward');
        if(this.currentPage <= this.totalPages){
            if(this.currentPage==this.totalPages){
                isDisabled=true;
            }
        this.companiesWithCompetitors = this.duplicateRecords.slice(this.currentPage*this.pageSize, this.pageSize*(this.currentPage+1));
        this.currentPage = this.currentPage + 1;
            }    
        }

    handleRefresh() {
        console.log('In handle refresh');
        return refreshApex(this.wiredCompaniesWithCompetitorsResult);

    }

    handleBack() {
        // Implement back logic here
    }

    handleResolutionChange() {
        // Implement resolution change logic here
    }

//   handleSave() {
//       debugger
//       var selectedGrp = this.selectedGroup;
//       console.log(selectedGrp);
//       getGroupId({listCompetitors:this.companiesWithCompetitors}).then(result=>{console.log("data transerfered successfully")}).catch(error=>{console.log(error)});
//         //const vfPageUrl = '/apex/printsummarygroup';
//         const vfPageUrlWithParameters = '/apex/printsummarygroup?selectedgroup='+JSON.stringify(selectedGrp);
//         // Navigate to the Visualforce page
//         //window.location.href = vfPageUrl;
//         window.open(vfPageUrlWithParameters, '_blank');
//     }
    handleMenuSelect(event)
    {
        this.selectedvalue=event.detail.value;
        if(this.selectedvalue == 'pdf')
        {
       debugger
      var selectedGrp = this.recordId;
      console.log(selectedGrp);
     // getGroupId({listCompetitors:this.companiesWithCompetitors}).then(result=>{console.log("data transerfered successfully")}).catch(error=>{console.log(error)});
        //const vfPageUrl = '/apex/printsummarygroup';
        const vfPageUrlWithParameters = '/apex/ev_printsummarygroup?selectedgroup='+ selectedGrp;
        // Navigate to the Visualforce page
        //window.location.href = vfPageUrl;
        window.open(vfPageUrlWithParameters, '_blank');
        }

        else if(this.selectedvalue == 'Excel')
        {
            debugger
      var selectedGrp = this.recordId;
      console.log(selectedGrp);
     // getGroupId({listCompetitors:this.companiesWithCompetitors}).then(result=>{console.log("data transerfered successfully")}).catch(error=>{console.log(error)});
        //const vfPageUrl = '/apex/printsummarygroup';
        const vfPageUrlWithParameters = '/apex/ev_printsummarygroupexcel?selectedgroup='+ selectedGrp;
        // Navigate to the Visualforce page
        window.location.href = vfPageUrlWithParameters;
        //window.open(vfPageUrlWithParameters, '_blank');
        }
    }
}