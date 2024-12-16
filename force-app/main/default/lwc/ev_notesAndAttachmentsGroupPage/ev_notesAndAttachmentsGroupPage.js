import { LightningElement, api, wire, track} from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import CONTENTVERSION_OBJECT from '@salesforce/schema/ContentVersion';
import DOCUMENTTYPE_FIELD from '@salesforce/schema/ContentVersion.Document_Type__c';
import getAllAttachments from '@salesforce/apex/ev_DocumentController.getAllAttachments'
import getAllAttachmentsOnLoad from '@salesforce/apex/ev_DocumentController.getAllAttachmentsOnLoad'
import deleteSelectedfile from "@salesforce/apex/ev_DocumentController.deleteSelectedfile";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateDocumentCustomField from '@salesforce/apex/ev_DocumentController.updateDocumentCustomField';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';


export default class ev_notesAndAttachmentsGroupPage extends NavigationMixin(LightningElement) {
@api selecteddocument;
@api alldocuments;
@api recordId;
@api error;
@api allAttachments;
@api selectedGroup;
@api recordIds;
@track showSpinner = false;
@track fileData;
@track fileName;
fileName;
fileInformation;
selectVal='';
acceptedFormats = '.pdf,.png,.jpg,.jpeg,.doc,.docx,.txt,.zip';
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

/*handleRename(event) {
    const documentId = event.target.dataset.id;
    this.allAttachments = this.allAttachments.map(doc => {
        if (doc.Id === documentId) {
            doc.isRenaming = true; // Enable renaming mode
        }
        return doc;
    });
}

handleRenameChange(event) {
    const documentId = event.target.dataset.id;
    const newTitle = event.target.value;
    this.allAttachments = this.allAttachments.map(doc => {
        if (doc.Id === documentId) {
            doc.Title = newTitle; // Update the title in the local state
        }
        return doc;
    });
}

handleSaveRename(event) {
    const documentId = event.target.dataset.id;
    const updatedDocument = this.allAttachments.find(doc => doc.Id === documentId);
    updateDocumentName({ documentId: documentId, newTitle: updatedDocument.Title })
        .then(() => {
            this.allAttachments = this.allAttachments.map(doc => {
                if (doc.Id === documentId) {
                    doc.isRenaming = false; // Exit renaming mode
                }
                return doc;
            });
            this.handleRefresh();
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error renaming document: ' + error.body.message,
                    variant: 'error',
                })
            );
        });
}*/

dTypeOptions = [
    { label: 'choose one', value: '' },
    { label: 'Annual Report', value: 'Annual Report' },
    {label: 'Sustainability Reports', value: 'Sustainability Reports'},
    { label: 'Brochure, Documentation', value: 'Brochure, Documentation' },
    { label: 'Business Plan', value: 'Business Plan' },
    { label: 'Financials', value: 'Financials' },
    { label: 'Presentation of the company', value: 'Presentation of the company' },
    { label: 'Press release', value: 'Press release' },
   // { label: 'Technical Data Sheet', value: 'Technical Data Sheet' },
    { label: 'Visit Report', value: 'Visit Report' },
    { label: 'Other', value: 'Other' },
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
    if (!this.selectedGroup) {
        this.selectedGroup = this.recordId;
    }
}

// Wire To Show All Records
@wire(getAllAttachmentsOnLoad, {recordId: '$selectedGroup'}) attachmentsInfo(result){
    this.attachmentsInfoResult = result;
    const { data, error } = result;
    
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
    console.log('selecteddocument doctype', this.selecteddocument); 
    if(event.detail.value == 'All'){
    getAllAttachmentsOnLoad({ recordId: this.selectedGroup})
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
    getAllAttachments({ recordId: this.selectedGroup, doctype: this.selecteddocument })
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
    deleteSelectedRecords(event) {
    this.recordIds = event.target.dataset.recordId;
    console.log('recordId=>', this.recordIds);
    
    deleteSelectedfile({ docIds: this.recordIds, attachments: this.allAttachments })
        .then(result => {
            console.log('Deleted selected file', result);
            
            // Fetch updated list after deleting
            getAllAttachmentsOnLoad({ recordId: this.selectedGroup })
                .then((updatedResult) => {
                    this.allAttachments = updatedResult;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Selected record is deleted!',
                            variant: 'success',
                        }),
                    );
                    this.handleRefresh();
                })
                .catch((error) => {
                    console.log("Error fetching updated attachments: ", error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error fetching updated records',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
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
    // Check if the document type is selected
    if (!this.selectVal) {
        this.showError('Please select a document type before uploading.');
        return; // Stop further execution
    }

    // Proceed with the file submission logic
    // Assuming you have a file upload function, you can call it here

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

showError(message) {
    const evt = new ShowToastEvent({
        title: 'Error',
        message: message,
        variant: 'error',
    });
    this.dispatchEvent(evt);
}*/
    /*handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        let exceedsLimit = false;
        for (let file of uploadedFiles) {
            if (file.size > 5 * 1024 * 1024) { // Check if file size exceeds 5MB
                exceedsLimit = true;
                this.errorMessage = `File ${file.name} exceeds the 5 MB size limit.`;
            } else {
                // Update the custom field for each uploaded document
                this.updateCustomField(file.documentId);
            }
        }

        if (!exceedsLimit) {
            this.errorMessage = ''; // Clear error message if all files are within limit
            // Optionally handle success message or further processing here
        }
    }

    handleUploadError(event) {
        this.errorMessage = 'An error occurred during file upload.';
    }

    updateCustomField(documentId) {
        updateDocumentCustomField({ documentId, customFieldValue: this. selectVal})
            .then(() => {
                // Handle success response
                this.successMessage = 'Custom field updated successfully.';
            })
            .catch(error => {
                this.errorMessage = 'Error updating custom field: ' + error.body.message;
            });
    }

    submitFile() {
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
}*/
    
    

//File Picklist Select
/* handlePicklistChange(event){
    this.selectVal = event.target.value;
    console.log('selected value of doc type  ', this.selectVal);

}*/

}