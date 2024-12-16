import { LightningElement, api,track} from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class RecordEditFormEditExampleLWC extends LightningElement {
    @api recordId;
		
handleDateChange(event) 
{        
 this.selectedDate = event.target.value;  
   }
    handleSubmit(event) {
				console.log('onsubmit event recordEditForm'+ event.detail.fields);
    }
    handleSuccess(event) {
				console.log('onsuccess event recordEditForm', event.detail.id);
         this.showMessage('Success', 'Updated Successfully!', 'success');
         window.location.reload();
    }
         showMessage(title, message, variant){
        this.dispatchEvent(
            new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            }),
        );
    }
}