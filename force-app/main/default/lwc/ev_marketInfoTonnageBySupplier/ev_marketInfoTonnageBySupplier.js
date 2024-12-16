import { LightningElement, api, wire, track } from 'lwc';
import getMarketInfo from '@salesforce/apex/ev_MarketInfoController.getMarketInfo';

export default class ev_marketinfoTonnageBySupplier extends LightningElement {
    @api recordId;
    @track competitors = [];
    @track error;

    @wire(getMarketInfo, { recordId: '$recordId' })
    wiredMarketInfo({ error, data }) {
        if (data) {
            this.competitors = data.map(competitor => ({
                ...competitor,
                label: this.getCompetitorLabel(competitor)
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.competitors = [];
        }
    }

    get totalCrudeTonnage() {
        return this.competitors.reduce((total, competitor) => total + competitor.TotalCrudeTonnage, 0);
    }

    get totalBurntTonnage() {
        return this.competitors.reduce((total, competitor) => total + competitor.TotalBurntTonnage, 0);
    }

   // Round to the specified decimal places (default is 2)
    roundToDecimalPlaces(value, decimalPlaces = 0) {
        if (value === undefined || value === null || isNaN(value)) return 0;
        return parseFloat(value).toFixed(decimalPlaces);
    }

    // Format the number with commas
    formatNumber(value) {
        return value ? value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',') : '0';
    }

    // Combine rounding and formatting with commas
    get formattedTotalCrudeTonnage() {
        const roundedValue = this.roundToDecimalPlaces(this.totalCrudeTonnage);
        return this.formatNumber(roundedValue);
    }

    get formattedTotalBurntTonnage() {
        const roundedValue = this.roundToDecimalPlaces(this.totalBurntTonnage);
        return this.formatNumber(roundedValue);
    }

    getCompetitorLabel(competitor) {
        const totalTonnage = competitor.Plants.reduce((sum, plant) => {
            return sum + plant.CrudeTonnage + plant.BurntTonnage;
        }, 0);
        const roundedTotalTonnage = this.roundToDecimalPlaces(totalTonnage);
        return `${competitor.CompetitorName} - ${this.formatNumber(roundedTotalTonnage)}`;
    }
}