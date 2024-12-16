import { LightningElement, track, api } from 'lwc';
import Id from '@salesforce/user/Id';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createVisitReportWithSiteVisits from '@salesforce/apex/Ev_VisitReportFormController.createVisitReportWithSiteVisits';
import fetchAttachments from '@salesforce/apex/Ev_VisitReportFormController.fetchAttachments';
import fetchSiteVisitAssignees from '@salesforce/apex/Ev_VisitReportFormController.fetchSiteVisitAssignees';

export default class VisitReportComponent extends LightningElement {

    @track currentUserId = Id;
    @track visitReport = { SObject: 'Visit_Report__c' };
    @track siteVisitAssignees = [];
    @track files = [];
    @track showSpinner = true;
    @track fields = {
        Account__c: { disabled: false },
        Opportunity__c: { disabled: false }
    };

    _recordId;
    _objectApiName;
    isRendered = false;
    deletedFiles = [];

    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        this.loadVisitReportRecord();
    }
    @api
    get objectApiName() {
        return this._objectApiName;
    }
    set objectApiName(value) {
        this._objectApiName = value;
        this.loadVisitReportRecord();
    }

    connectedCallback() {
        this.addFirstSiteVisitAssignee();
        this.showSpinner = false;
    }

    addFirstSiteVisitAssignee() {
        if (this.siteVisitAssignees.length === 0) {
            this.addSiteVisitAssignee(0);
            this.siteVisitAssignees[0].data.Assigned_To__c = this.currentUserId;
            console.log('this.currentUserId==>'+this.currentUserId);
        }
    }

    showToast(toast) {
        this.dispatchEvent(new ShowToastEvent(toast));
    }

    loadVisitReportRecord() {
        if (this.recordId) {
            switch (this.objectApiName) {
                case 'Visit_Report__c':
                    this.visitReport.Id = this.recordId;
                    this.fetchAttachments();
                    this.fetchSiteVisitAssignees();
                    break;
                case 'Account':
                    this.visitReport.Account__c = this.recordId;
                    this.fields['Account__c'] = { disabled: true };
                    break;
                case 'Opportunity':
                    this.visitReport.Opportunity__c = this.recordId;
                    this.fields['Opportunity__c'] = { disabled: true };
                    break;
            }
        }
    }

    fetchAttachments() {
        fetchAttachments({ linkedEntityId: this.visitReport.Id }).then(result => {
            if (result) {
                this.files = JSON.parse(JSON.stringify(result));
                this.files.forEach(file => {
                    file = this.addFileDetails(file);
                });
            }
        }).catch(error => { });
    }

    fetchSiteVisitAssignees() {
        fetchSiteVisitAssignees({ visitReportId: this.visitReport.Id }).then(result => {
            if (result) {
                let siteVisitAssignees = []
                result.forEach(svaRecord => {
                    let sva = this.newSiteVisitAssignee({ index: siteVisitAssignees.length });
                    sva.isExisting = true;
                    sva.data = svaRecord;
                    sva.data.Id = null;
                    siteVisitAssignees.push(sva);
                });
                if (siteVisitAssignees.length === 1) {
                    siteVisitAssignees[0].actions.deleteBtn.disabled = true;
                }
                this.siteVisitAssignees = siteVisitAssignees;
                this.addFirstSiteVisitAssignee();
            }
        }).catch(error => { });
    }

    handleVisitReportFieldChange(event) {
        this.visitReport[event.target.name] = event.target.value;
    }

    handleUploadFinished(event) {
        let files = JSON.parse(JSON.stringify(this.files));
        let uploadedFiles = event.detail.files;

        uploadedFiles.forEach(uploadedFile => {
            let i;
            for (i = 0; i < files.length; i++) {
                if (files[i].documentId === uploadedFile.documentId) {
                    break;
                }
            }
            if (i === files.length) {
                files.push(this.addFileDetails(uploadedFile));
            }
        });

        this.files = JSON.parse(JSON.stringify(files));
        this.template.querySelector('#AttachFiles')?.focus();
    }

    addFileDetails(file) {
        if (file.ContentDocumentId) {
            file.name = file.ContentDocument.Title + '.' + file.ContentDocument.FileExtension;
            file.documentId = file.ContentDocumentId;
            file.isExisting = true;
        }

        file.iconName = this.getFileIconName(file.name.substring(file.name.lastIndexOf('.') + 1));
        file.href = `/sfc/servlet.shepherd/document/download/${file.documentId}?operationContext=S1`;
        return file;
    }

    getFileIconName(fileType) {
        let fileIcons = { 'jpeg': 'image', 'jpg': 'image', 'png': 'image', 'xlsx': 'gsheet', 'xlx': 'gsheet' };
        return 'doctype:' + (fileIcons[fileType] ?? fileType);
    }

    handleDelFile(event) {
        let files = JSON.parse(JSON.stringify(this.files));
        let documentId = event.currentTarget.dataset.documentid;

        for (let i = 0; i < files.length; i++) {
            if (files[i].documentId === documentId) {
                files.splice(i, 1);
                break;
            }
        }
        this.deletedFiles.push(documentId);

        this.files = JSON.parse(JSON.stringify(files));
    }

    handleAddSiteVisitAssignee(event) {
        let index = Number(event.currentTarget.dataset.index);
        this.addSiteVisitAssignee(index + 1);
    }

    addSiteVisitAssignee(index) {
        let siteVisitAssignees = JSON.parse(JSON.stringify(this.siteVisitAssignees));

        siteVisitAssignees.splice(index, 0, this.newSiteVisitAssignee({ index: index }));
        for (let i = index + 1; i < siteVisitAssignees.length; i++) {
            siteVisitAssignees[i].index = i;
        }
        siteVisitAssignees[0].actions.deleteBtn.disabled = (siteVisitAssignees.length === 1);

        this.siteVisitAssignees = JSON.parse(JSON.stringify(siteVisitAssignees));
    }

    newSiteVisitAssignee(siteVisitAssignee) {
        return {
            index: siteVisitAssignee.index,
            isExisting: false,
            data: {
                SObject: 'Site_Visit_Assignee__c',
                Assigned_To__c: null
            },
            actions: { addBtn: { disabled: false }, deleteBtn: { disabled: false } }
        };
    }

    handleDelSiteVisitAssignee(event) {
        let index = Number(event.currentTarget.dataset.index);
        this.delSiteVisitAssignee(index);
    }

    delSiteVisitAssignee(index) {
        let siteVisitAssignees = JSON.parse(JSON.stringify(this.siteVisitAssignees));

        siteVisitAssignees.splice(index, 1);
        for (let i = index; i < siteVisitAssignees.length; i++) {
            siteVisitAssignees[i].index = i;
        }
        siteVisitAssignees[0].actions.deleteBtn.disabled = (siteVisitAssignees.length === 1);

        this.siteVisitAssignees = JSON.parse(JSON.stringify(siteVisitAssignees));
    }

    handleSvaFieldChange(event) {
        let index = event.currentTarget.dataset.index;
        let fieldName = event.target.name;
        let value = event.target.value;

        this.siteVisitAssignees[index].data[fieldName] = value;
    }

    handleSubmit() {
        this.showSpinner = true;
        let isDataValid = true;
        if (isDataValid) {
            this.visitReport["Name"] = this.visitReport["Meeting_Date__c"];
            let input = {
                visitReport: this.visitReport,
                siteVisitAssignees: this.siteVisitAssignees.filter(sva => (sva.data.Assigned_To__c !== null && typeof sva.data.Assigned_To__c !== 'undefined')).map(sva => sva.data),
                files: this.files.filter(file => !file.isExisting).map(file => file.documentId),
                deletedFiles: this.deletedFiles
            }
            createVisitReportWithSiteVisits({ wrapper: input }).then(result => {
                console.log('handleSubmit createVisitReportWithSiteVisits result => ', result);
                if (result) {
                    this.showToast({
                        title: 'Success',
                        message: 'Visit Report and Site Visit Assignees created successfully!',
                        variant: 'success'
                    });
                    this.dispatchEvent(new CloseActionScreenEvent());
                } else {
                    this.showToast({
                        title: 'Could not save the records',
                        message: 'Save unsuccessfull. Please contact your Administrator.',
                        variant: 'error'
                    });
                }
                this.showSpinner = false;
            }).catch(error => {
                console.error('handleSubmit createVisitReportWithSiteVisits error => ', error);
                this.showToast({
                    title: 'Could not save the records',
                    message: 'Save unsuccessfull. Please contact your Administrator.',
                    variant: 'error'
                });
                this.showSpinner = false;
            });
        }
    }

    /* Unused Methods */
    // handleInputChange(event) {
    //     const field = event.target.name;
    //     const value = event.target.value;

    //     console.log(`Updating field: ${field} with value: ${value}`);

    //     if (field in this.visitReportWrapper) {
    //         this.visitReportWrapper[field] = value;
    //     }
    // }

    // handleAssigneeChange(event) {
    //     const index = event.target.dataset.index;
    //     const value = event.target.value;

    //     console.log(`Updating Assignee at index: ${index} with value: ${value}`);

    //     this.siteVisitAssignees[index].assignedTo = value;
    // }
}