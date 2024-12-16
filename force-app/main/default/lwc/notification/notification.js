import { LightningElement, api,track } from 'lwc';
import IMAGES from '@salesforce/resourceUrl/notification';
import surveyInvitationLink from '@salesforce/apex/OrderUtils.getSurveyInvitationLink';
import getUserDetails from '@salesforce/apex/UserUtils.getUserDetails';
import closeModal from '@salesforce/apex/UserUtils.closeModal';
import UserId from '@salesforce/user/Id';
export default class Notification extends LightningElement {
    @api recordId;
    @track isModalOpen;
    @track update1=true;
    @track update2=false;
    @track update3=false;
    @track update4=false;
    @track update5=false;
    sessionStorageOptionId;
    localStorageOptionId;
    @track invitationLink; 
    Next_Day_Order = IMAGES+'/notification/MyCarmeuse-Pop-Up_Next-Day-Order.png';
    Excel_OR_CSV = IMAGES+'/notification/MyCarmeuse-Pop-Up_Excel-or-CSV.png';
    QuickSave = IMAGES+'/notification/MyCarmeuse-Pop-Up_QuickSave.png';
    AddUser = IMAGES+'/notification/MyCarmeuse-Pop-Up_Add-Users.png';
    New_Ideas = IMAGES+'/notification/MyCarmeuse-Pop-Up_New-Ideas.png'; 

    connectedCallback(){ 
        this.getUserDetails();       
        this.getSurveyInvitationLink();
        
    }

    closeModal(){
        sessionStorage.setItem("ShowUpdate","false")
       
        this.isModalOpen = false;
    }

    getSurveyInvitationLink(){
        surveyInvitationLink()
        .then(result => {
            if(result){
                this.invitationLink = result;
                console.log('invitationLink: ', this.invitationLink);
            }            
        })
        .catch(error => {
            console.log('Error: ', error);
        })        
    }

    onNext(){
        if(this.update1){
            this.update1=false;
            this.update2=true;
            this.update3=false;
            this.update4=false;
            this.update5=false;
        }else if(this.update2){
            this.update1=false;
            this.update2=false;
            this.update3=true;
            this.update4=false;
            this.update5=false;
        }else if(this.update3){
            this.update1=false;
            this.update2=false;
            this.update3=false;
            this.update4=true;
            this.update5=false;
        }else if(this.update4){
            this.update1=false;
            this.update2=false;
            this.update3=false;
            this.update4=false;
            this.update5=true;
        }else if(this.update5){
            this.update1=true;
            this.update2=false;
            this.update3=false;
            this.update4=false;
            this.update5=false;
        }
    }

    onPrevious(){
        if(this.update1){
            this.update1=false;
            this.update2=false;
            this.update3=false;
            this.update4=false;
            this.update5=true;
        }else if(this.update2){
            this.update1=true;
            this.update2=false;
            this.update3=false;
            this.update4=false;
            this.update5=false;
        }else if(this.update3){
            this.update1=false;
            this.update2=true;
            this.update3=false;
            this.update4=false;
            this.update5=false;
        }else if(this.update4){
            this.update1=false;
            this.update2=false;
            this.update3=true;
            this.update4=false;
            this.update5=false;
        }else if(this.update5){
            this.update1=false;
            this.update2=false;
            this.update3=false;
            this.update4=true;
            this.update5=false;
        }
    }

    getUserDetails(){ 
        getUserDetails({ userId: UserId})
        .then((result) => {
            if(result === true){
                this.isModalOpen = false;
            }else{
                this.isModalOpen = true;
            }
                      
        })
        .catch((error) => {
            this.error = error;
        });
    }

    closeModal(){
        this.isModalOpen = false;        
        closeModal({ userId: UserId})
        .then((result) => {
             
        })
        .catch((error) => {
            this.error = error;
        });
    }
}