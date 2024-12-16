import { LightningElement, api, wire, track} from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import CONTENTVERSION_OBJECT from '@salesforce/schema/ContentVersion';
import DOCUMENTTYPE_FIELD from '@salesforce/schema/ContentVersion.Document_Type__c';
import getAllAttachmentsCompany from '@salesforce/apex/ev_DocumentController.getAllAttachmentsCompany'
import getAllAttachmentsCompanyOnLoad from '@salesforce/apex/ev_DocumentController.getAllAttachmentsCompanyOnLoad'
import deleteSelectedfile from "@salesforce/apex/ev_DocumentController.deleteSelectedfile";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateDocumentCustomField from '@salesforce/apex/ev_DocumentController.updateDocumentCustomField';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

export default class ev_notesAndAttachmentsCompanyPage extends NavigationMixin(LightningElement) {
    @api selecteddocument;
    @api recordId;
    @api error;
    @api allAttachments;
    @api fetchAttachments;
    @api selectedCompany;
    @api recordIds;
    @track showSpinner = false;
    @track fileData;
    @track fileName;
    fileName;
    fileInformation;
    selectVal='';
    disableUploadButton = true;

    @track allAttachments = [];  // Assuming this is populated with data
    @track sortDirection = 'asc';  // Initial sort direction
    @track sortedBy;  // Field currently sorted by

    get sortIcon() {
        return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown';
    }

    get isSortedByDocument() {
        return this.sortedBy === 'Title';
    }

    get isSortedByType() {
        return this.sortedBy === 'Document_Type__c';
    }

    get isSortedByDate() {
        return this.sortedBy === 'CreatedDateValue__c';
    }

    sortByDocument() {
        this.sortedBy = 'Title';
        this.sortData('Title');
    }

    sortByType() {
        this.sortedBy = 'Document_Type__c';
        this.sortData('Document_Type__c');
    }

    sortByDate() {
        this.sortedBy = 'CreatedDateValue__c';
        this.sortData('CreatedDateValue__c');
    }

    sortData(fieldName) {
        const isAsc = this.sortDirection === 'asc';
        this.allAttachments = [...this.allAttachments].sort((a, b) => {
            let val1 = a[fieldName] ? a[fieldName].toLowerCase() : '';
            let val2 = b[fieldName] ? b[fieldName].toLowerCase() : '';

            return isAsc ? (val1 > val2 ? 1 : -1) : (val1 > val2 ? -1 : 1);
        });

        this.sortDirection = isAsc ? 'desc' : 'asc';  // Toggle sort direction
    }

    dTypeOptions = [
            { label: 'choose one', value: '' },
            { label: 'Annual Report', value: 'Annual Report' },
            {label: 'Sustainability Reports', value: 'Sustainability Reports'},
            { label: 'Brochure, Documentation', value: 'Brochure, Documentation' },
            { label: 'Business Plan', value: 'Business Plan' },
            { label: 'Financials', value: 'Financials' },
            { label: 'Presentation of the company', value: 'Presentation of the company' },
            { label: 'Press release', value: 'Press release' },
            { label: 'Visit Report', value: 'Visit Report' },
            { label: 'Other', value: 'Other' },
           /* { label: 'Technical Data Sheet', value: 'Technical Data Sheet' },*/
            
        ];

    dTypeOptionsFilter = [
      { label: 'All', value: 'All' },
      { label: 'Annual Report', value: 'Annual Report' },
      {label: 'Sustainability Reports', value: 'Sustainability Reports'},
      { label: 'Brochure, Documentation', value: 'Brochure, Documentation' },
      { label: 'Business Plan', value: 'Business Plan' },
      { label: 'Financials', value: 'Financials' },
      { label: 'Presentation of the company', value: 'Presentation of the company' },
      { label: 'Press release', value: 'Press release' },
      //{ label: 'Technical Data Sheet', value: 'Technical Data Sheet' },
      { label: 'Visit Report', value: 'Visit Report' },
      { label: 'Other', value: 'Other' },
      ];

    @wire(getObjectInfo, { objectApiName: CONTENTVERSION_OBJECT})
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: DOCUMENTTYPE_FIELD })
    DocTypePicklistValues;

    connectedCallback() {
      if (!this.selectedCompany) {
          this.selectedCompany = this.recordId;
      }
    }

    // Wire To Show All Records
    @wire(getAllAttachmentsCompanyOnLoad, {recordId: '$selectedCompany'}) attachmentsInfo(result){
      this.attachmentsInfoResult = result;
      const { data, error } = result;
      console.log('selecteddocument doctype', this.selecteddocument);
      if(data){
        this.allAttachments = data;
        console.log('this.allAttachments=>' + this.allAttachments);
      }
      if(error){
          console.log(error)
      }
    }

    //Imperative Method to Change File Type To Show Selected Documents
    handleDocumentChange(event) {
        this.selecteddocument = event.detail.value;        
        if(event.detail.value == 'All'){
          getAllAttachmentsCompanyOnLoad({ recordId: this.selectedCompany})
          .then((result) => {
            this.allAttachments = result;
            this.error = undefined;
          })
          .catch((error) => {
            this.error = error;
            this.allAttachments = undefined;
          });
        }
        else{
        getAllAttachmentsCompany({ recordId: this.selectedCompany, doctype: this.selecteddocument })
        .then((result) => {
          this.allAttachments = result;
          this.error = undefined;
        })
        .catch((error) => {
          this.error = error;
          this.allAttachments = undefined;
        });
        }
      }

    //File Delete

    deleteSelectedRecords(event) {
      this.recordIds = event.target.dataset.recordId;
      console.log('recordId=>', this.recordIds);
      
      // Call the Apex method to delete the selected files
      deleteSelectedfile({ docIds: this.recordIds, attachments: this.allAttachments })
          .then(result => {
              console.log('Deleted selected file', result);
  
              // Update allAttachments to exclude deleted files
              this.allAttachments = this.allAttachments.filter(file => 
                  !this.recordIds.includes(file.Id) // Assuming Id is the unique identifier for your files
              );
  
              // Show success message
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Success',
                      message: 'Selected record is deleted!',
                      variant: 'success',
                  }),
              );
              this.handleRefresh();
          })
          .catch(error => {
              this.error = error;
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error deleting records',
                      message: error.body.pageError[0].message,
                      variant: 'error',
                  }),
              );
              console.log("error", JSON.stringify(this.error));
          });
  }
  
  
    /*deleteSelectedRecords(event){
        this.recordIds = event.target.dataset.recordId;
        console.log('recordId=>', this.recordIds);
        deleteSelectedfile({docIds:this.recordIds, attachments: this.allAttachments})
        .then(result => {
          console.log('Delected selected file', result);
          this.allAttachments =  result;
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Success',
              message: 'Selected record is deleted!',
              variant: 'success',
            }),
          );
        })
        .catch(error => {
          this.message = undefined;
          this.error = error;
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error deleting records',
              message: error.body.pageError[0].message,
              variant: 'error',
            
            }),
          );
          console.log("error", JSON.stringify(this.error));
        });
      }*/

    //File View
    previewFiles(event){
        this.recordIds = event.target.dataset.recordId;
        console.log('event=>' + event.target.dataset.recordId);
            this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                selectedRecordId: event.target.dataset.recordId
            }
        })
      }

    // Handle picklist change
    handlePicklistChange(event) {
      this.selectVal = event.target.value;
      console.log('Selected value of doc type:', this.selectVal);

      // Enable or disable the upload button based on document type selection
      if (this.selectVal) {
          this.disableUploadButton = false; // Enable upload if document type is selected
      } else {
          this.disableUploadButton = true; // Disable upload if no document type is selected
      }
  }

  // File upload handling
  handleUploadFinished(event) {
    if (!this.selectVal) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Please select a document type before uploading.',
                variant: 'error',
            })
        );
        return;
    }

    const uploadedFiles = event.detail.files;

    for (let file of uploadedFiles) {
        // Update the custom field for each uploaded document
        this.updateCustomField(file.documentId);
    }

    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Success',
            message: 'File Uploaded Successfully!',
            variant: 'success',
        })
    );
    this.selectVal = ''; // Reset document type after upload
    this.disableUploadButton = true; // Disable upload button again
    this.handleRefresh();
}

  // Update custom field on the document
  updateCustomField(documentId) {
      updateDocumentCustomField({ documentId, customFieldValue: this.selectVal })
          .then(() => {
              console.log('Custom field updated successfully.');
          })
          .catch((error) => {
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error',
                      message: 'Error updating custom field: ' + error.body.message,
                      variant: 'error',
                  })
              );
          });
  }

  // Handle page refresh
  handleRefresh() {
    refreshApex(this.attachmentsInfoResult); // Refresh the data from Apex
}

  /*submitFile() {
    // Handle the insert button logic

    // Show a toast success message
    const evt = new ShowToastEvent({
        title: 'Success',
        message: 'File Uploaded Successfully!!!',
        variant: 'success',
    });
  
    this.dispatchEvent(evt);
    this.handleRefresh();

    // Reload the component
    eval("$A.get('e.force:refreshView').fire();");
}

    //File Picklist Select
    handlePicklistChange(event){
        this.selectVal = event.target.value;
    }

    handleRefresh() {
      console.log('In handle refresh');
      //refreshApex(this.attachmentsInfo);
      window.location.reload();
    }*/

}