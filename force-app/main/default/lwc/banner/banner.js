import { LightningElement, api,track} from 'lwc';
import isCarrierUser  from '@salesforce/customPermission/Carrier_User_Only';
export default class Banner extends LightningElement {
    @api recordId;
    @track showBanner = false;
    connectedCallback(){
        this.showBanner = isCarrierUser;
    }
  
}