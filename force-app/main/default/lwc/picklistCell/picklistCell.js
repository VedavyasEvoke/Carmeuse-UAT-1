import { LightningElement, api } from 'lwc';

export default class PicklistCell extends LightningElement {
    @api options = []; // Picklist options
    @api value; // Selected value
    @api context; // Row context (ID)

    // Handle change in picklist selection
    handleChange(event) {
        const selectedEvent = new CustomEvent('picklistchange', {
            detail: {
                value: event.detail.value,
                context: this.context,
            },
        });
        this.dispatchEvent(selectedEvent); // Dispatch value change to parent
    }
}