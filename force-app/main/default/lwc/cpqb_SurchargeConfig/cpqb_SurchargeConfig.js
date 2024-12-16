import { LightningElement, api, track } from 'lwc';
import { categoryOptions } from './cpqb_SurchargeConfig_Service';
import fetchProduct from '@salesforce/apex/PricingConditionController.fetchProduct';
import getPricingCondition from '@salesforce/apex/PricingConditionController.getPricingCondition';

export default class Cpqb_SurchargeConfig extends LightningElement {
    @api recordId;
    @api productId;
    @api configAttrJSON;
    @api productJSON;
    @api quoteJSON;
    @api quoteCurrency;
    @api quotePricebook;
    @api configData;

    @track spinner = true;
    @track header = '';
    @track selectedOptionsColumns = [{ label: 'Quantity', fieldName: 'SBQQ__Quantity__c', type: "Number", editable: true },
    { label: 'Product Code', fieldName: 'SBQQ__ProductCode__c' },
    { label: 'Unit Price', fieldName: 'List_Unit_Price__c', type: "Number", editable: true }];
    @track categories = {
        "SBQQ__UnitPrice__c": { field: { label: 'Unit Price', fieldName: 'SBQQ__UnitPrice__c', type: "Number", editable: true }, price: 0 },
        "List_Unit_Price__c": { field: { label: 'Unit Price', fieldName: 'List_Unit_Price__c', type: "Number", editable: true }, price: 0 },
        "PC_Discount__c": { field: { label: 'Discount', fieldName: 'PC_Discount__c', type: "Number", editable: true }, price: 0 },
        "Fees_Price__c": { field: { label: 'Fees Price', fieldName: 'Fees_Price__c', type: "Number", editable: true }, price: 0 },
        "Freight_Price__c": { field: { label: 'Freight Price', fieldName: 'Freight_Price__c', type: "Number", editable: true }, price: 0 },
        "Misc_Price__c": { field: { label: 'Misc Price', fieldName: 'Misc_Price__c', type: "Number", editable: true }, price: 0 },
        "Surcharge__c": { field: { label: 'Surcharge', fieldName: 'Surcharge__c', type: "Number", editable: true }, price: 0 },
        "Comission__c": { field: { label: 'Commission', fieldName: 'Comission__c', type: "Number", editable: true }, price: 0 }
    };
    @track selectedOptions = [];
    @track lineItems = {};
    @track productOptions;
    @track freightOptions;
    @track miscOptions;
    @track discountOptions;
    @track commissionOptions;
    @track selectedProductValue;
    @track selectedFreightValue;
    @track selectedMiscValue;
    @track selectedDiscountValue;
    @track selectedCommissionValue;
    @track surchargeList = [];
    @track feeList = [];

    get showSurchargeList() {
        return (typeof this.surchargeOptions !== 'undefined' && this.surchargeOptions.length > 0);
    }
    get showFeeList() {
        return (typeof this.feeOptions !== 'undefined' && this.feeOptions.length > 0);
    }

    surchargeHeaders = ['Surcharges', 'Price'];
    feeHeaders = ['Fees', 'Price'];
    surchargeOptions;
    feeOptions;
    remSurchargeOptions = [];
    remFeeOptions = [];

    connectedCallback() {
        this.fetchOptionConfigurations();   //Stores all the Category wise Prices and Value wise Prices from configData
    }

    getProductName(productId) {
        fetchProduct({ id: productId }).then(result => {
            if (typeof result !== 'undefined' && result.length === 1) {
                this.header = result[0].Name;
            }
        }).catch(error => { });
    }

    /* Maps all the Categories and Category Options with their Prices */
    fetchOptionConfigurations() {
        if (typeof this.configData !== 'undefined') {
            let configWrapper = JSON.parse(this.configData);
            console.log(configWrapper);
            if (typeof configWrapper !== 'undefined') {
                if (typeof configWrapper.product.configuredProductId !== 'undefined' && configWrapper.product.configuredProductId !== null && configWrapper.product.configuredProductId.length > 0) {
                    this.getProductName(configWrapper.product.configuredProductId);
                }
                let productOptions = [];
                for (let i = 0; i < configWrapper.product.optionConfigurations["Other Options"].length; i++) {
                    if (configWrapper.product.optionConfigurations["Other Options"][i].selected === true) {
                        let option = {
                            'SBQQ__Quantity__c': configWrapper.product.optionConfigurations["Other Options"][i].Quantity,
                            'SBQQ__OptionalSKU__c': configWrapper.product.optionConfigurations["Other Options"][i].optionId,
                            'SBQQ__ProductCode__c': configWrapper.product.optionConfigurations["Other Options"][i].ProductCode
                        };
                        /* Initializing Prices of Categories */
                        for (let key in this.categories) {
                            option[key] = 0;
                        }
                        /* Mapping Category Options with their Prices */
                        for (let key in categoryOptions) {
                            this.lineItems[categoryOptions[key]['fieldName']] = {
                                label: key,
                                category: categoryOptions[key]['category'],
                                price: 0
                            };
                        }

                        if (typeof configWrapper.product.optionConfigurations["Other Options"][i].readOnly.line !== 'undefined') {
                            /* Mapping Categories with their Prices */
                            for (let key in this.categories) {
                                if (key === 'SBQQ__UnitPrice__c') {
                                    option[key] = configWrapper.product.optionConfigurations["Other Options"][i].readOnly.line['SBQQ__ListPrice__c'];
                                }
                                else {
                                    option[key] = configWrapper.product.optionConfigurations["Other Options"][i].readOnly.line[key];
                                }
                            }

                            /* Mapping Category Options with their Prices */
                            for (let key in categoryOptions) {
                                this.lineItems[categoryOptions[key]['fieldName']] = {
                                    label: key,
                                    category: categoryOptions[key]['category'],
                                    price: configWrapper.product.optionConfigurations["Other Options"][i].readOnly.line[categoryOptions[key]['fieldName']]
                                };
                                option[categoryOptions[key]['fieldName']] = configWrapper.product.optionConfigurations["Other Options"][i].readOnly.line[categoryOptions[key]['fieldName']];
                            }

                            let lineItem = configWrapper.product.optionConfigurations["Other Options"][i].readOnly.line;
                            for (let key in lineItem) {
                                if (typeof lineItem[key] !== 'undefined' && lineItem[key] !== null && typeof this.lineItems[key] !== 'undefined') {
                                    this.selectedProductValue = (this.lineItems[key].category === 'Product' && typeof lineItem[key] !== 'undefined' && Number(lineItem[key]) >= 0) ? key : this.selectedProductValue;
                                    this.selectedCommissionValue = (this.lineItems[key].category === 'Commission' && typeof lineItem[key] !== 'undefined' && Number(lineItem[key]) >= 0) ? key : this.selectedCommissionValue;
                                    this.selectedFreightValue = (this.lineItems[key].category === 'Freight' && typeof lineItem[key] !== 'undefined' && Number(lineItem[key]) >= 0) ? key : this.selectedFreightValue;
                                    this.selectedDiscountValue = (this.lineItems[key].category === 'Discount' && typeof lineItem[key] !== 'undefined' && Number(lineItem[key]) >= 0) ? key : this.selectedDiscountValue;
                                    this.selectedMiscValue = (this.lineItems[key].category === 'Misc' && typeof lineItem[key] !== 'undefined' && Number(lineItem[key]) >= 0) ? key : this.selectedMiscValue;
                                }
                            }
                        }
                        this.selectedOptions.push(option);

                        /* Using this list for passing it to Apex and getting all their Pricing Categories*/
                        productOptions.push({
                            Id: configWrapper.product.optionConfigurations["Other Options"][i].optionId,
                            sObjectType: 'SBQQ__ProductOption__c'
                        });
                    }
                }
                if (productOptions.length > 0) {
                    this.getPricingCondition(productOptions);
                }
            }
        }
    }
    getPricingCondition(productOptions) {
        getPricingCondition({ listPO: productOptions }).then(result => {
            if (typeof result !== 'undefined') {
                if (typeof result.Products !== 'undefined' && result.Products.length > 0) {
                    this.productOptions = [];
                    for (let key in result.Products) {
                        this.productOptions.push({ label: result.Products[key], value: categoryOptions[result.Products[key]]['fieldName'] });
                    }
                    this.updateOptions({ detail: { value: this.productOptions[0].value } }, 'selectedProductValue', 'List_Unit_Price__c');
                }
                if (typeof result.Freights !== 'undefined' && result.Freights.length > 0) {
                    this.freightOptions = [];
                    for (let key in result.Freights) {
                        this.freightOptions.push({ label: result.Freights[key], value: categoryOptions[result.Freights[key]]['fieldName'] });
                        if (categoryOptions[result.Freights[key]]['fieldName'] === 'Truck_Freight_Ton__c') {
                            this.updateOptions({ detail: { value: categoryOptions[result.Freights[key]]['fieldName'] } }, 'selectedFreightValue', 'Freight_Price__c');
                        }
                    }
                    this.selectedOptionsColumns.splice(3, 0, this.categories['Freight_Price__c'].field);
                }
                if (typeof result.Miscs !== 'undefined' && result.Miscs.length > 0) {
                    this.miscOptions = [];
                    for (let key in result.Miscs) {
                        this.miscOptions.push({ label: result.Miscs[key], value: categoryOptions[result.Miscs[key]]['fieldName'] });
                    }
                    this.selectedOptionsColumns.splice(3, 0, this.categories['Misc_Price__c'].field);
                }
                if (typeof result.Discounts !== 'undefined' && result.Discounts.length > 0) {
                    this.discountOptions = [];
                    for (let key in result.Discounts) {
                        this.discountOptions.push({ label: result.Discounts[key], value: categoryOptions[result.Discounts[key]]['fieldName'] });
                    }
                    this.selectedOptionsColumns.splice(3, 0, this.categories['PC_Discount__c'].field);
                }
                if (typeof result.Commissions !== 'undefined' && result.Commissions.length > 0) {
                    this.commissionOptions = [];
                    for (var key in result.Commissions) {
                        this.commissionOptions.push({ label: result.Commissions[key], value: categoryOptions[result.Commissions[key]]['fieldName'] });
                    }
                    this.selectedOptionsColumns.splice(3, 0, this.categories['Comission__c'].field);
                }
                if (typeof result.Surcharges !== 'undefined' && result.Surcharges.length > 0) {
                    this.surchargeOptions = [];
                    for (let key in result.Surcharges) {
                        this.surchargeOptions.push({ label: result.Surcharges[key], value: categoryOptions[result.Surcharges[key]]['fieldName'] });
                    }
                    this.selectedOptionsColumns.splice(3, 0, this.categories['Surcharge__c'].field);
                }
                if (typeof result.Fees !== 'undefined' && result.Fees.length > 0) {
                    this.feeOptions = [];
                    for (let key in result.Fees) {
                        this.feeOptions.push({ label: result.Fees[key], value: categoryOptions[result.Fees[key]]['fieldName'] });
                    }
                    this.selectedOptionsColumns.splice(3, 0, this.categories['Fees_Price__c'].field);
                }
            }

            for (let key in this.lineItems) {
                if (typeof this.lineItems[key] !== 'undefined' && this.lineItems[key] !== null) {
                    if (this.lineItems[key].category === 'Surcharges') {
                        this.remSurchargeOptions = ((typeof this.remSurchargeOptions === 'undefined' || this.remSurchargeOptions.length === 0) && typeof this.surchargeOptions !== 'undefined') ? JSON.parse(JSON.stringify(this.surchargeOptions)) : this.remSurchargeOptions;
                        let remSurchargeIndex = this.remSurchargeOptions.findIndex(option => (option.value === key));
                        if (remSurchargeIndex >= 0 && typeof this.lineItems[key].price !== 'undefined' && this.lineItems[key].price !== null && Number(this.lineItems[key].price) > 0) {
                            this.surchargeList.push(this.initializeSurchargeRow(this.surchargeList.length + 1));
                            this.surchargeList[this.surchargeList.length - 1].selectedSurchargeValue = key;
                            this.surchargeList[this.surchargeList.length - 1].surchargePrice = this.lineItems[key].price + '';
                            this.surchargeList[this.surchargeList.length - 1].selectedSurcharge = this.remSurchargeOptions[remSurchargeIndex];
                            this.remSurchargeOptions.splice(remSurchargeIndex, 1);
                        }
                    } else if (this.lineItems[key].category === 'Fees') {
                        this.remFeeOptions = ((typeof this.remFeeOptions === 'undefined' || this.remFeeOptions.length === 0) && typeof this.feeOptions !== 'undefined') ? JSON.parse(JSON.stringify(this.feeOptions)) : this.remFeeOptions;
                        let remFeeIndex = this.remFeeOptions.findIndex(option => (option.value === key));
                        if (remFeeIndex >= 0 && typeof this.lineItems[key].price !== 'undefined' && this.lineItems[key].price !== null && Number(this.lineItems[key].price) > 0) {
                            this.feeList.push(this.initializeFeeRow(this.feeList.length + 1));
                            this.feeList[this.feeList.length - 1].selectedFeeValue = key;
                            this.feeList[this.feeList.length - 1].feePrice = this.lineItems[key].price + '';
                            this.feeList[this.feeList.length - 1].selectedFee = this.remFeeOptions[remFeeIndex];
                            this.remFeeOptions.splice(remFeeIndex, 1);
                        }
                    }
                }
            }
            if (this.surchargeList.length > 0) {
                this.updatePreviousSurchargeOptions();
            }
            if (this.feeList.length > 0) {
                this.updatePreviousFeeOptions();
            }
            if (typeof this.surchargeOptions !== 'undefined' && this.surchargeOptions.length > 0 && this.surchargeList.length === 0) {
                this.surchargeList.push(this.initializeSurchargeRow(1));
            }
            if (typeof this.feeOptions !== 'undefined' && this.feeOptions.length > 0 && this.feeList.length === 0) {
                this.feeList.push(this.initializeFeeRow(1));
            }
            this.spinner = false;
            const dt = this.template.querySelector('lightning-datatable');
            dt.openInlineEdit();
        }).catch(error => {
            this.spinner = false;
        });
    }

    handleProductChange(event) {
        this.updateOptions(event, 'selectedProductValue', 'List_Unit_Price__c');
    }
    handleFreightChange(event) {
        this.updateOptions(event, 'selectedFreightValue', 'Freight_Price__c');
    }
    handleMiscChange(event) {
        this.updateOptions(event, 'selectedMiscValue', 'Misc_Price__c');
    }
    handleDiscountChange(event) {
        this.updateOptions(event, 'selectedDiscountValue', 'PC_Discount__c');
    }
    handleCommissionChange(event) {
        this.updateOptions(event, 'selectedCommissionValue', 'Comission__c');
    }
    updateOptions(event, variable, fieldName) {
        let previousValue = this[variable];
        this[variable] = event.detail.value;
        for (let i = 0; i < this.selectedOptions.length; i++) {
            this.selectedOptions[i][previousValue] = '';
            this.selectedOptions[i][this[variable]] = (typeof previousValue !== 'undefined' && previousValue !== '')
                ? this.selectedOptions[i][previousValue]
                : (isNaN(this.selectedOptions[i][fieldName]) ? 0 : Number(this.selectedOptions[i][fieldName]));
            this.selectedOptions[i][fieldName] = this.selectedOptions[i][this[variable]];
        }
    }

    handleSurchargeChange(event) {
        this.spinner = true;
        let selectedSurcharge = event.detail.value;
        let rno = Number(event.currentTarget.dataset.rno);
        if (typeof this.surchargeList[rno - 1].selectedSurcharge !== 'undefined') {
            this.remSurchargeOptions.push(this.surchargeList[rno - 1].selectedSurcharge);
        }
        let previousValue = this.surchargeList[rno - 1].selectedSurchargeValue;
        this.surchargeList[rno - 1].selectedSurchargeValue = selectedSurcharge;
        for (let i = 0; i < this.remSurchargeOptions.length; i++) {
            if (this.remSurchargeOptions[i].value === selectedSurcharge) {
                this.surchargeList[rno - 1].selectedSurcharge = this.remSurchargeOptions[i];
                this.remSurchargeOptions.splice(i, 1);
                break;
            }
        }
        this.updatePreviousSurchargeOptions();
        if (typeof this.surchargeList[rno - 1].selectedSurchargeValue !== 'undefined' && this.surchargeList[rno - 1].selectedSurchargeValue.trim().length > 0 && typeof this.surchargeList[rno - 1].surchargePrice !== 'undefined' && this.surchargeList[rno - 1].surchargePrice.trim().length > 0) {
            this.calculateSurchargeTotals(previousValue, this.surchargeList[rno - 1]);
        }
        this.spinner = false;
    }
    updatePreviousSurchargeOptions() {
        this.surchargeList.forEach(surcharge => {
            surcharge.surchargeOptions = JSON.parse(JSON.stringify(this.remSurchargeOptions));
            if (typeof surcharge.selectedSurcharge !== 'undefined') {
                surcharge.surchargeOptions.splice(0, 0, surcharge.selectedSurcharge);
            }
        });
    }
    handleSurchargePriceChange(event) {
        this.spinner = true;
        let rno = event.currentTarget.dataset.rno;
        this.surchargeList[Number(rno) - 1].surchargePrice = event.detail.value;
        if (typeof this.surchargeList[rno - 1].selectedSurchargeValue !== 'undefined' && this.surchargeList[rno - 1].selectedSurchargeValue.trim().length > 0 && typeof this.surchargeList[rno - 1].surchargePrice !== 'undefined') {
            this.calculateSurchargeTotals(undefined, this.surchargeList[rno - 1]);
        }
        this.spinner = false;
    }
    handleNewSurchargeRow(event) {
        if (this.surchargeList.length < this.surchargeOptions.length) {
            this.surchargeList.push(this.initializeSurchargeRow(this.surchargeList.length + 1));
        }
    }
    initializeSurchargeRow(rno) {
        this.remSurchargeOptions = (rno === 1) ? JSON.parse(JSON.stringify(this.surchargeOptions)) : this.remSurchargeOptions;
        return {
            rno: rno, surchargeOptions: JSON.parse(JSON.stringify(this.remSurchargeOptions)), selectedSurchargeValue: '', surchargePrice: '',
            showAdd: (this.remSurchargeOptions.length > 0), showDelete: (rno !== 1)
        };
    }
    handleDelSurchargeRow(event) {
        this.spinner = true;
        let rno = Number(event.currentTarget.dataset.rno);
        let _surchargeList = this.surchargeList;
        if (typeof this.surchargeList[rno - 1].selectedSurcharge !== 'undefined') {
            this.remSurchargeOptions.push(JSON.parse(JSON.stringify(this.surchargeList[rno - 1].selectedSurcharge)));
            for (let i = 0; i < _surchargeList.length; i++) {
                let surcharge = _surchargeList[i];
                surcharge.rno = ((i + 1) > rno) ? i : surcharge.rno;
                surcharge.surchargeOptions.push(this.surchargeList[rno - 1].selectedSurcharge);
            }
            this.surchargeList = JSON.parse(JSON.stringify(_surchargeList));
        }
        let removedSurcharge = this.surchargeList.splice(rno - 1, 1)[0];
        let previousValue = removedSurcharge.selectedSurchargeValue;
        if (typeof removedSurcharge.selectedSurchargeValue !== 'undefined' && removedSurcharge.selectedSurchargeValue.trim().length > 0 && typeof removedSurcharge.surchargePrice !== 'undefined' && removedSurcharge.surchargePrice.trim().length > 0) {
            this.calculateSurchargeTotals(previousValue, removedSurcharge);
        }
        this.spinner = false;
    }
    calculateSurchargeTotals(previousValue, newSurcharge) {
        if (typeof this.surchargeList !== 'undefined' && this.surchargeList.length > 0 && typeof this.selectedOptions !== 'undefined' && this.selectedOptions.length > 0) {
            let surchargeWithPriceMapping = new Map();
            let surchargePriceTotal = 0
            this.surchargeList.forEach(surcharge => {
                if (typeof surcharge.selectedSurchargeValue !== 'undefined' && surcharge.selectedSurchargeValue.trim().length > 0 && typeof surcharge.surchargePrice !== 'undefined') {
                    surchargeWithPriceMapping.set(surcharge.selectedSurchargeValue, surcharge.surchargePrice);
                    surchargePriceTotal += (surcharge.surchargePrice.trim().length > 0) ? Number(surcharge.surchargePrice) : 0;
                }
            });
            let _selectedOptions = this.selectedOptions;
            _selectedOptions.forEach(option => {
                option.Surcharge__c = surchargePriceTotal;
                option[previousValue] = (typeof previousValue !== 'undefined') ? '' : option[previousValue];

                /* Updating Prices of all Category Options belonging to Surcharge Category */
                for (let key in this.lineItems) {
                    if (this.lineItems[key].category === 'Surcharges') {
                        option[key] = surchargeWithPriceMapping.get(key);
                        this.lineItems[key].price = option[key];
                    }
                }
            });
            this.selectedOptions = JSON.parse(JSON.stringify(_selectedOptions));
        }
    }

    handleFeeChange(event) {
        this.spinner = true;
        let selectedFee = event.detail.value;
        let rno = Number(event.currentTarget.dataset.rno);
        if (typeof this.feeList[rno - 1].selectedFee !== 'undefined') {
            this.remFeeOptions.push(this.feeList[rno - 1].selectedFee);
        }
        let previousValue = this.feeList[rno - 1].selectedFeeValue;
        this.feeList[rno - 1].selectedFeeValue = selectedFee;
        for (let i = 0; i < this.remFeeOptions.length; i++) {
            if (this.remFeeOptions[i].value === selectedFee) {
                this.feeList[rno - 1].selectedFee = this.remFeeOptions[i];
                this.remFeeOptions.splice(i, 1);
                break;
            }
        }
        this.updatePreviousFeeOptions();
        if (typeof this.feeList[rno - 1].selectedFeeValue !== 'undefined' && this.feeList[rno - 1].selectedFeeValue.trim().length > 0 && typeof this.feeList[rno - 1].feePrice !== 'undefined' && this.feeList[rno - 1].feePrice.trim().length > 0) {
            this.calculateFeeTotals(previousValue);
        }
        this.spinner = false;
    }
    updatePreviousFeeOptions() {
        this.feeList.forEach(fee => {
            fee.feeOptions = JSON.parse(JSON.stringify(this.remFeeOptions));
            if (typeof fee.selectedFee !== 'undefined') {
                fee.feeOptions.splice(0, 0, fee.selectedFee);
            }
        });
    }
    handleFeePriceChange(event) {
        this.spinner = true;
        let rno = event.currentTarget.dataset.rno;
        this.feeList[Number(rno) - 1].feePrice = event.detail.value;
        if (typeof this.feeList[rno - 1].selectedFeeValue !== 'undefined' && this.feeList[rno - 1].selectedFeeValue.trim().length > 0 && typeof this.feeList[rno - 1].feePrice !== 'undefined') {
            this.calculateFeeTotals(undefined);
        }
        this.spinner = false;
    }
    handleNewFeeRow(event) {
        if (this.feeList.length < this.feeOptions.length) {
            this.feeList.push(this.initializeFeeRow(this.feeList.length + 1));
        }
    }
    initializeFeeRow(rno) {
        this.remFeeOptions = (rno === 1) ? JSON.parse(JSON.stringify(this.feeOptions)) : this.remFeeOptions;
        return {
            rno: rno, feeOptions: JSON.parse(JSON.stringify(this.remFeeOptions)), selectedFeeValue: '', feePrice: '',
            showAdd: (this.remFeeOptions.length > 0), showDelete: (rno !== 1)
        };
    }
    handleDelFeeRow(event) {
        this.spinner = true;
        let rno = Number(event.currentTarget.dataset.rno);
        let _feeList = this.feeList;
        if (typeof this.feeList[rno - 1].selectedFee !== 'undefined') {
            this.remFeeOptions.push(JSON.parse(JSON.stringify(this.feeList[rno - 1].selectedFee)));
            for (let i = 0; i < _feeList.length; i++) {
                let fee = _feeList[i];
                fee.rno = ((i + 1) > rno) ? i : fee.rno;
                fee.feeOptions.push(this.feeList[rno - 1].selectedFee);
            }
            this.feeList = JSON.parse(JSON.stringify(_feeList));
        }
        let removedFee = this.feeList.splice(rno - 1, 1)[0];
        let previousValue = removedFee.selectedFeeValue;
        if (typeof removedFee.selectedFeeValue !== 'undefined' && removedFee.selectedFeeValue.trim().length > 0 && typeof removedFee.feePrice !== 'undefined' && removedFee.feePrice.trim().length > 0) {
            this.calculateFeeTotals(previousValue);
        }
        this.spinner = false;
        this.spinner = false;
    }
    calculateFeeTotals(previousValue) {
        if (typeof this.feeList !== 'undefined' && this.feeList.length > 0 && typeof this.selectedOptions !== 'undefined' && this.selectedOptions.length > 0) {
            let feeWithPriceMapping = new Map();
            let feePriceTotal = 0
            this.feeList.forEach(fee => {
                if (typeof fee.selectedFeeValue !== 'undefined' && fee.selectedFeeValue.trim().length > 0 && typeof fee.feePrice !== 'undefined') {
                    feeWithPriceMapping.set(fee.selectedFeeValue, fee.feePrice);
                    feePriceTotal += (fee.feePrice.trim().length > 0) ? Number(fee.feePrice) : 0;
                }
            });
            let _selectedOptions = this.selectedOptions;
            _selectedOptions.forEach(option => {
                option.Fees_Price__c = feePriceTotal;
                option[previousValue] = (typeof previousValue !== 'undefined') ? '' : option[previousValue];

                /* Updating Prices of all Category Options belonging to Fee Category */
                for (let key in this.lineItems) {
                    if (this.lineItems[key].category === 'Fees') {
                        option[key] = feeWithPriceMapping.get(key);
                        this.lineItems[key].price = option[key];
                    }
                }
            });
            this.selectedOptions = JSON.parse(JSON.stringify(_selectedOptions));
        }
    }

    handleCellChange(event) {
        let draftValues = event.detail.draftValues[0];
        if (typeof draftValues !== 'undefined') {
            for (let i = 0; i < this.selectedOptions.length; i++) {
                if (this.selectedOptions[i].SBQQ__OptionalSKU__c === draftValues.SBQQ__OptionalSKU__c) {
                    for (let key in draftValues) {
                        if (key !== 'SBQQ__OptionalSKU__c') {
                            this.selectedOptions[i][key] = draftValues[key];
                            this.selectedOptions[i][this.selectedProductValue] = this.selectedOptions[i].List_Unit_Price__c;
                            this.selectedOptions[i][this.selectedFreightValue] = this.selectedOptions[i].Freight_Price__c;
                            this.selectedOptions[i][this.selectedDiscountValue] = this.selectedOptions[i].PC_Discount__c;
                            this.selectedOptions[i][this.selectedCommissionValue] = this.selectedOptions[i].Comission__c;
                            this.selectedOptions[i][this.selectedMiscValue] = this.selectedOptions[i].Misc_Price__c;
                        }
                    }
                    break;
                }
            }
        }
        //this.template.querySelector("lightning-datatable").draftValues = [];
    }

    handleSave(event) {
        if (typeof this.configData !== undefined) {
            let configWrapper = JSON.parse(this.configData);
            configWrapper.redirect.save = true;
            configWrapper.redirect.auto = true;
            let optionsVisited = 0;
            for (let j = 0; j < configWrapper.product.optionConfigurations["Other Options"].length; j++) {
                if (configWrapper.product.optionConfigurations["Other Options"][j].selected) {
                    for (let i = 0; i < this.selectedOptions.length; i++) {
                        if (configWrapper.product.optionConfigurations["Other Options"][j].optionId == this.selectedOptions[i].SBQQ__OptionalSKU__c) {
                            //configWrapper.product.optionConfigurations["Other Options"][j].Quantity = this.selectedOptions[i].SBQQ__Quantity__c;

                            for (let key in this.selectedOptions[i]) {
                                configWrapper.product.optionConfigurations["Other Options"][j].configurationData[key] = this.selectedOptions[i][key];
                            }
                            configWrapper.product.optionConfigurations["Other Options"][j].configurationData.SBQQ__UnitPrice__c = this.selectedOptions[i].SBQQ__UnitPrice__c;
                            configWrapper.product.optionConfigurations["Other Options"][j].configurationData.SBQQ__ListPrice__c = this.selectedOptions[i].SBQQ__UnitPrice__c;
                            configWrapper.product.optionConfigurations["Other Options"][j].configurationData.Net_Price__c = this.calculateTotal(this.selectedOptions[i]);
                            //configWrapper.product.optionConfigurations["Other Options"][j].configurationData.Total_Price__c = configWrapper.product.optionConfigurations["Other Options"][j].configurationData.Net_Price__c;
                            break;
                        }
                    }
                    optionsVisited += 1;
                }
                if (optionsVisited === this.selectedOptions.length) {
                    break;
                }
            }
            this.configData = JSON.stringify(configWrapper);
            console.log('Final Data');
            console.log(configWrapper);
        }
        this.dispatchEvent(new CustomEvent(
            'configevent',
            {
                detail: { configData: this.configData },
                bubbles: true,
                composed: true,
            }
        ));
    }
    calculateTotal(option) {
        let total = 0;
        let priceList = ['List_Unit_Price__c', 'Surcharge__c', 'Fees_Price__c', 'Freight_Price__c', 'Misc_Price__c', 'Misc_Price__c', 'PC_Discount__c'];
        if (isNaN(option.SBQQ__Quantity__c)) {
            return total;
        }
        priceList.forEach(price => {
            total = (isNaN(option[price])) ? total : ((price !== 'PC_Discount__c') ? total + Number(option[price]) : total - Number(option[price]));
        });
        return Number(option.SBQQ__Quantity__c) * total;
    }

}