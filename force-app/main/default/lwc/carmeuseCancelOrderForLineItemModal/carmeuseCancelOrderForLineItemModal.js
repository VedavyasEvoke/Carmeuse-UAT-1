import {LightningElement, api} from 'lwc';

export default class ConfirmationDialog extends LightningElement {
    
    @api name; 
    @api message = 'Are you sure you want to cancel the order?'; 
    @api confirmLabel = 'Yes'; 
    @api cancelLabel = 'No'; 


    
    handleConfirmClick(event){
        
        this.dispatchEvent(new CustomEvent('handleconfirmation', {detail: true}));
    }

    handleCancelClick(event){
        
        this.dispatchEvent(new CustomEvent('handlecancel', {detail: false}));
    }
}