import { LightningElement,track } from 'lwc';
import IMAGES from '@salesforce/resourceUrl/carmeimages';
import Id from '@salesforce/user/Id';
import updateUserEmailPreferences from '@salesforce/apex/UserUtils.updateUserEmailPreferences';
import getUserEmailPreferences from '@salesforce/apex/UserUtils.getUserEmailPreferences';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SPC_Contact_Number from '@salesforce/label/c.SPC_Contact_Number';

export default class CarmeuseFooter extends LightningElement {

    carmeuseImageslogo = IMAGES+'/carmuseImages/logo-white.svg';
    instagramLogo = IMAGES+'/carmuseImages/instagram.svg';
    facebookLogo = IMAGES+'/carmuseImages/facebook.svg';
    youtubeLogo = IMAGES+'/carmuseImages/youtube.svg';
    linkedInLogo = IMAGES+'/carmuseImages/linkedin.svg';

    @track isModalOpen = false;
    @track isSubmit = false;
    @track isConfirmed = false;
    @track isCancelled = false;
    @track isNoEmail = false;
    @track isAllOrders = false;
    @track isAllSubmitOrders = false;
    @track isAllConfirmOrders = false;
    @track isAllCancelOrders =false;
    @track userId = Id;
    @track showAllOrder = false;
    @track currentYear;
    @track phone = '';

    connectedCallback(){
        this.phone = SPC_Contact_Number;
        this.showAllOrder = false;
        this.currentYear = new Date().getFullYear();
    }

    openModal(){
        this.isModalOpen = true;
        this.handleUserEmailPreferences();
    }

    closeModal(){
        this.isModalOpen = false;
    }

    handleNoEmailOnOther(){
       let noemail = this.template.querySelector('[data-id="noemail"]')
       this.isNoEmail = false;
       noemail.checked = false;
    }

    handleSubmit(event) {
       this.isSubmit = event.target.checked;          
       this.handleNoEmailOnOther();
    }

    handleConfirmed(event) {
        this.isConfirmed = event.target.checked; 
        this.handleNoEmailOnOther();
     }

     handleCancelled(event) {
      this.isCancelled = event.target.checked; 
      this.handleNoEmailOnOther();     
     }

     handleAllEmail(event){
        this.isAllOrders = event.target.checked; 
        if(this.isAllOrders){
            this.showAllOrder = true;
            this.handleNoEmailOnOther();  
        }else{
           this.showAllOrder = false;
        }
    }

    handleAllSubmit(event){
        this.isAllSubmitOrders = event.target.checked;         
        this.handleNoEmailOnOther();
    }

    handleAllConfirmed(event){
        this.isAllConfirmOrders = event.target.checked;         
        this.handleNoEmailOnOther();
    }

    handleAllCancelled(event){
        this.isAllCancelOrders = event.target.checked;         
        this.handleNoEmailOnOther();
    }
     
     handleNoEmail(event) {
      this.isNoEmail = event.target.checked;

      let submit = this.template.querySelector('[data-id="submit"]')
      this.isSubmit = false;
      submit.checked = false;

      let confirmed = this.template.querySelector('[data-id="confirmed"]')
      this.isConfirmed = false;
      confirmed.checked = false;

      let cancelled = this.template.querySelector('[data-id="cancelled"]')
      this.isCancelled = false;
      cancelled.checked = false;

      let allSubmitOrders = this.template.querySelector('[data-id="allSubmit"]')
      this.isAllSubmitOrders = false;
      allSubmitOrders.checked = false;

      let allConfirmOrders = this.template.querySelector('[data-id="allConfirmed"]')
      this.isAllConfirmOrders = false;
      allConfirmOrders.checked = false;

      let allCancelOrders = this.template.querySelector('[data-id="allCancelled"]')
      this.isAllCancelOrders = false;
      allCancelOrders.checked = false;

      let allOrders = this.template.querySelector('[data-id="allOrders"]')
      allOrders.checked = false;

      this.showAllOrder = false;
     }

     handleSubscribe(event){       
        updateUserEmailPreferences({userId: this.userId,isSubmit:this.isSubmit,isConfirmed:this.isConfirmed,isCancelled:this.isCancelled,isNoEmail:this.isNoEmail,isAllSubmit:this.isAllSubmitOrders,isAllConfirmed:this.isAllConfirmOrders,isAllCancelled:this.isAllCancelOrders})
         .then(result => {           
            const saved = new ShowToastEvent({
               title: 'Success!',
               message: "Successfully Saved",
               variant: 'success'
           });
           this.dispatchEvent(saved);
           this.isModalOpen = false;
         })
         .catch(error => {
            const saved = new ShowToastEvent({
               title: 'Error!',
               message: "Something went wrong",
               variant: 'error'
           });
           this.dispatchEvent(saved);
            console.log(error);
         })
     }  
     
     handleUserEmailPreferences(){    
         let arrayResult=[];   
        getUserEmailPreferences({userId: this.userId})
        .then(result => {
            console.log('result'+result)
            if(result == null){
                let submit = this.template.querySelector('[data-id="submit"]')
                this.isSubmit = true;
                submit.checked = true;
                let confirmed = this.template.querySelector('[data-id="confirmed"]')
                this.isConfirmed = true;
                confirmed.checked = true;
                let cancelled = this.template.querySelector('[data-id="cancelled"]')
                this.isCancelled = true;
                cancelled.checked = true; 
            }else{
                if(result.includes(";")){
                    arrayResult = result.split(";");
                }else{
                    arrayResult.push(result);
                }
                console.log('arrayResult'+arrayResult)
                if(arrayResult.includes('Order Submission')){
                    let submit = this.template.querySelector('[data-id="submit"]')
                    this.isSubmit = true;
                    submit.checked = true;
                }
                if(arrayResult.includes('Order Confirmation')){
                    let confirmed = this.template.querySelector('[data-id="confirmed"]')
                    this.isConfirmed = true;
                    confirmed.checked = true;
                }
                if(arrayResult.includes('Order Cancellation')){
                    let cancelled = this.template.querySelector('[data-id="cancelled"]')
                    this.isCancelled = true;
                    cancelled.checked = true; 
                }            
                if(arrayResult.includes('No Email')){               
                    let noemail = this.template.querySelector('[data-id="noemail"]')
                    this.isNoEmail = true;
                    noemail.checked = true;  
                }               
                if(arrayResult.includes('All Order Submission')){
                    let allSubmit = this.template.querySelector('[data-id="allSubmit"]')
                    console.log('allSubmit--->'+allSubmit)
                    this.isAllSubmitOrders = true;
                    allSubmit.checked = true;  

                }    
                if(arrayResult.includes('All Order Confirmation')){
                    let allConfirmed = this.template.querySelector('[data-id="allConfirmed"]')
                    this.isAllConfirmOrders = true;
                    allConfirmed.checked = true;  
                }   
                if(arrayResult.includes('All Order Cancellation')){
                    let allCancelled = this.template.querySelector('[data-id="allCancelled"]')
                    this.isAllCancelOrders = true;
                    allCancelled.checked = true; 
                }   
            }
        })
        .catch(error => {
           console.log(error);
        })
     }
}