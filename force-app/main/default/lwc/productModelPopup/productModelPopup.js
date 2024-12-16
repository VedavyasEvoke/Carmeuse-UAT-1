import { LightningElement,api,track,wire } from 'lwc';
import getMarketInfo from "@salesforce/apex/ev_marketingInfoController.getMarketingProds";
import updateMarketInfo from "@salesforce/apex/ev_marketingInfoController.updateMarketingProds";
import closeModal from "@salesforce/apex/ev_marketingInfoController.closeModal";



import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
const columns = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Business Unit', fieldName: 'Business_Unit__c'},
    { label: 'Market', fieldName: 'Market__c'},
    { label: 'Sub Market', fieldName: 'SubMarket__c'},
    { label: 'Region', fieldName: 'Region__c'}
    //{ label: 'Status', fieldName: 'Status__c'}
    //{ label: 'Final Delivered Price	', fieldName: 'Amount__c'}

    // { label: 'Competitor Product', fieldName: 'Competitor_Product__c'},
    // { label: 'Ship To', fieldName: 'Customerprospect__r.Name'}

];

export default class ProductModelPopup extends NavigationMixin(LightningElement){
 @api recordId;
     @track selectedRows = '';
    @track isShowModal = false;

 @track marketingData=[];
 columns = columns;
 connectedCallback() {
   console.log('recordId=='+this.recordId);
        getMarketInfo({qId:this.recordId})
        .then(result => {
         this.marketingData=result;
          debugger

// this.marketingData =  result.map(

//         record => Object.assign(

//             { "Customerprospect__r.Name": (record.Customerprospect__c != null && record.Customerprospect__c != '') 
//             ? record.Customerprospect__r.Name: '' }, record
//             )

//             );

            console.log('marketing=='+JSON.stringify(result));
        /*   for(var rec of result){
              rec.Customerprospect__c=rec.Customerprospect__r.Name
            this.marketingData.push(rec);
            
            }*/
             if (this.marketingData && this.marketingData.length > 0) { 
                           console.log('marketing=='+this.marketingData.length);

            this.isShowModal = true;
        } 
        })
    }
    handleShipSelection(event) {
             var selectedRows = event.detail.selectedRows;
        console.log('MarketingInfoRecords=='+JSON.stringify(selectedRows));
          this.selectedRows=selectedRows;
        // this.shippingStrr=JSON.stringify(selectedRows);
        // if (selectedRows.length > 0) {
        //    this.selectedRecId = selectedRows[0].Id;
        //      this.selRecords(event);
        // }
    }
    submitDetails(){


    }
   closeModal(){
       // this.isShowModal = false;
            closeModal({qtid:this.recordId})
            this.isShowModal = false;
        //disabledModal({oppId:this.recordId})
        //.then(result=>{
            
                // this[NavigationMixin.Navigate]({
                //     type: 'standard__recordPage',
                //     attributes: {
                //         recordId: this.recordId,
                //         actionName: 'edit',
                //     },
                // });
       // })
    }
     submitDetails(){
         console.log('selected records'+JSON.stringify(this.selectedRows));
         updateMarketInfo({records:JSON.stringify(this.selectedRows),qtid:this.recordId})
                 .then(result => {
            console.log('marketing=='+JSON.stringify(result));
          //  this.marketingData=result;
        })
               window.location.reload()

        //  alert('test alert');
     }
}