import { LightningElement, api,track} from 'lwc';
import Id from '@salesforce/user/Id';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class Ev_UpdatesQuoteInfo extends LightningElement {
		@api recordId;
		@track userId = Id;
	@track selectedDate = new Date().toISOString().slice(0,10);
    hide =true;

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
         //window.location.reload();
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