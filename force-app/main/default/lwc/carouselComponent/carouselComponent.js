import { LightningElement, wire, api, track } from 'lwc';
import getAllAttachments from '@salesforce/apex/CarouselController.getAllAttachments';
import { refreshApex } from '@salesforce/apex';

export default class CustomCarousel extends LightningElement {
    @api recordId; // Record ID to fetch attachments for
    @track attachments;
    @track error; // Track error state
    wiredAttachmentsResult;

    @wire(getAllAttachments, { recordId: '$recordId' })
    wiredAttachments(result) {
        this.wiredAttachmentsResult = result; // store result for refresh
        const { error, data } = result;
        
        if (!this.recordId) {
            console.warn('No recordId is set yet.');
            return;
        }

        if (data) {
            this.attachments = data.map(doc => ({
                ...doc,
                DynamicURL: doc.DynamicURL, 
                Title: doc.Title
            }));
            
            if (this.attachments.length === 0) { // Handle case when no images are found
                this.attachments = undefined;
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.attachments = undefined;
            console.error('Error fetching attachments:', error);
        }
    }

    // Handler for upload finished event
    handleUploadFinished() {
        refreshApex(this.wiredAttachmentsResult); // Refresh the Apex call to get updated attachments
    }
}