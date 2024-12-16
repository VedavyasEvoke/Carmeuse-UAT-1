import { LightningElement, track, api } from 'lwc';

export default class PowerBIContainer extends LightningElement {
    @track isModalOpen = false;
    @api powerBiUrl = 'https://app.powerbi.com/reportEmbed?reportId=28687202-7847-44d1-a3d5-b75a381a3760&autoAuth=true&ctid=02baf972-dbc1-4d23-ba9d-8cb2cac30c59';

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }
}