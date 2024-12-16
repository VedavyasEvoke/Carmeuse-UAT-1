import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import AccountNameField from '@salesforce/schema/Account.Name';

export default class AccountDatialsHomePage extends LightningElement {
  @track accountName;
  @api recordId;
  @track isCheckout = false;
  @track isHome = false;
  @track lstOfPermissionSet = null;
  currentPageReference = null;
  urlStateParameters = null;
  @api effectiveAccountId;
  @track accountId;

  connectedCallback() {
    this.accountId = this.effectiveAccountId;
  }

  @wire(getRecord, {recordId: '$accountId', fields: [ AccountNameField ] })
    currentAccountName({ error, data }) {
      if(data){
          this.accountName = data.fields.Name.value;
      } else if(error){
        console.log('ERROR',error);
      }
    }

  @wire(CurrentPageReference)
  getPageReferenceParameters(currentPageReference) {
    if (currentPageReference) {
      this.recordId = currentPageReference.attributes.recordId;
      let attributes = currentPageReference.attributes.name;
      if (attributes == 'Home') {
        this.isHome = true;
      }
      let states = currentPageReference.state;
      let type = currentPageReference.type;
      if (type == 'comm__checkoutPage') {
        this.isCheckout = true;
      }
    }
  }
}