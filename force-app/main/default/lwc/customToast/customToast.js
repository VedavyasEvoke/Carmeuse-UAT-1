import { LightningElement, api, track } from 'lwc';
export default class CustomToast extends LightningElement {
    @track toast;
    @track show;

    handleClose() {
        this.show = false;
    }

    @api
    showToast(toast, autoCloseTime) {
        let variantMap = {
            'success': {
                theme: 'slds-notify slds-notify_toast slds-theme_success',
                iconName: 'utility:success'
            },
            'warning': {
                theme: 'slds-notify slds-notify_toast slds-theme_warning',
                iconName: 'utility:warning'
            },
            'error': {
                theme: 'slds-notify slds-notify_toast slds-theme_error',
                iconName: 'utility:error'
            }
        }

        this.toast = Object.assign(toast, variantMap[toast.variant]);
        this.show = true;
        setTimeout(() => {
            this.handleClose();
        }, autoCloseTime);
    }
}