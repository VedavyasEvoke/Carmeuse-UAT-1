import { LightningElement, api, track, wire } from 'lwc';
import getSPCDetails from '@salesforce/apex/UserUtils.getSPCDetails';
import getAccountDetails from '@salesforce/apex/AccountUtils.getAccountDetails';
import SPC_Contact_Number from '@salesforce/label/c.SPC_Contact_Number';
import Business_Unit_for_the_MLS_account from '@salesforce/label/c.Business_Unit_for_the_MLS_account';
export default class DetailsSPC extends LightningElement {
    @api recordId;
    @track spcDetails;
    @track isDetails = false;
    @track firstName;
    @track lastName;
    @track phone;
    @track email;
    @track isName = false;
    @track isLastName = false;
    @track isEmail = false;
    @api effectiveAccountId;
    @track isMLSAccount = false;

    connectedCallback() {
        this.phone = SPC_Contact_Number;
    }

    @wire(getAccountDetails, { accountId: '$effectiveAccountId' })
    wiredAccount({ error, data }) {
        if (data) {
            if (data[0].B2B_Business_Sub_Unit__c === Business_Unit_for_the_MLS_account) {
                this.isMLSAccount = true;
            }
        } else if (error) {
            console.log('Error getAccountDetail--->' + JSON.stringify(error));
        }
    }

    @wire(getSPCDetails, { accountId: '$effectiveAccountId' })
    wiredUser({ error, data }) {
        if (data) {
            this.isDetails = true;
            if (data.FirstName) {
                this.firstName = data.FirstName;
                this.isName = true;
            }
            if (data.LastName) {
                this.lastName = data.LastName;
                this.isName = true;
            }
            if (this.spcDetails.Email) {
                this.email = data.Email;
                this.isEmail = true;
            }
        }    else if (error) {
            console.log('Error getSPCDetails -->' + JSON.stringify(error));
        }
    }
}