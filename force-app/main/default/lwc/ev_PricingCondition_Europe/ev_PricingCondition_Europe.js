import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from "lightning/uiRecordApi";
import Id from '@salesforce/user/Id';
import LOCALE from "@salesforce/i18n/locale";
import { categoryOptions, headerFields_Profiles, category_Profiles } from './ev_PricingCondition_Europe_Service';
import fetchQuotePricingConditionFieldset from '@salesforce/apex/ev_PricingConditionController.fetchQuotePricingConditionFieldset';
import fetchQliPricingConditionFieldset from '@salesforce/apex/ev_PricingConditionController.fetchQliPricingConditionFieldset';
import fetchQuote from '@salesforce/apex/ev_PricingConditionController.fetchQuote';
import fetchQLIsofQuote from '@salesforce/apex/ev_PricingConditionController.fetchQLIsofQuote';
import fetchPlantPicklistEntries from '@salesforce/apex/ev_PricingConditionController.fetchPlantPicklistEntries';
import fetchSalesOrgByPlant from '@salesforce/apex/ev_PricingConditionController.fetchSalesOrgByPlant';
import fetchPricingCategories from '@salesforce/apex/ev_PricingConditionController.fetchPricingCategories';
import fetchPCAs from '@salesforce/apex/ev_PricingConditionController.fetchPCAs';
import updateQuote from '@salesforce/apex/ev_PricingConditionController.updateQuote';
import updateQLIsWithPricingCategs from '@salesforce/apex/ev_PricingConditionController.updateQLIsWithPricingCategs';
import fetchPriceLists from '@salesforce/apex/ev_PricingConditionController.fetchPriceLists';

/**
* Class Name         : Ev_PricingCondition
* Developer          : D Sridhar           
* Created Date       : 13-03-2024
* @description       : This JS handles all the logic of this component
* Last Modified Date : 13-03-2024
*/
export default class Ev_PricingCondition_Europe extends NavigationMixin(LightningElement) {
    @api recordId;
    @api navigateToUrlFromVf;
    @track localee = LOCALE;
    @track qlis;
    @track spinner = true;
    @track dtSpinner = true;
    @track quote = { Name: 'Q-00000' };
    @track headerFields = [];
    @track qliHeaderFields = [];
    @track qliIds = [];
    @track accordion = {
        title: 'Collapse All Products',
        iconName: 'utility:collapse_all',
        isCollapsed: false,
        activeSections: []
    };
    @track showToastMessage = false;
    @track showQuoteInformation = false;
    @track showCategories = { Product: true, Discount: false, Commission: false };

    decimalPlaces = 2;
    qliColumns = [
        { label: 'Estimated Qty/ Delivery', fieldName: 'Estimated_Qty_Delivery__c', type: "Decimal", editable: false, columnLevelHelp: 'Only editable for Flat Category Options' },
        { label: 'Product Code', fieldName: 'SBQQ__ProductCode__c', type: "Text" },
        { label: 'Primary', fieldName: 'Primary__c', type: "Checkbox", editable: true },
        { label: 'Plant', fieldName: 'Plant__c', fieldData: 'PlantData', type: "Combobox", editable: true, required: true },
        { label: 'Quantity', fieldName: 'SBQQ__Quantity__c', type: "Decimal", minValue: '0.01', editable: true },
        { label: 'Currency', fieldName: 'CurrencyIsoCode', type: "Text" },
        { label: 'Sub Total', fieldName: 'Sub_Total__c', type: "Decimal" }];
    qliColumnsRefs = {
        List_Unit_Price__c: { label: 'Unit Price', fieldName: 'List_Unit_Price__c', type: "Decimal", minValue: '0.01' },
        Misc_Price__c: { label: 'Misc Price', fieldName: 'Misc_Price__c', type: "Decimal", editable: true },
        PC_Discount__c: { label: 'Discount', fieldName: 'PC_Discount__c', type: "Decimal", editable: true },
        Commission__c: { label: 'Commission', fieldName: 'Commission__c', type: "Decimal", editable: true },
        Freight_Price__c: { label: 'Freight Price', fieldName: 'Freight_Price__c', type: "Decimal" },
        Surcharge__c: { label: 'Surcharge', fieldName: 'Surcharge__c', type: "Decimal" },
        Fees_Price__c: { label: 'Fee', fieldName: 'Fees_Price__c', type: "Decimal" }
    };
    dtStyling = {
        th: 'background-color: rgb(243, 243, 243); text-transform: uppercase; overflow: hidden; text-overflow: ellipsis; font-weight: normal; color: #524f4e;'
    };
    qliIndexMap = {};
    categPriceFieldsMap = {
        'Product': 'List_Unit_Price__c',
        'Freight': 'Freight_Price__c',
        'Misc': 'Misc_Price__c',
        'Discount': 'PC_Discount__c',
        'Commission': 'Commission__c',
        'Surcharges': 'Surcharge__c',
        'Fees': 'Fees_Price__c'
    }
    priceFieldCategoryMap = {};
    plantPicklistEntries = {};
    pcaMap = {};
    pcaDataMap = {};
    priceLists = [];
    disabledPcs = ['ZF01__c'];
    /* Add fields which contain numbers including commas(,) for decimal places */
    priceFields = ['SBQQ__Quantity__c', 'Estimated_Qty_Delivery__c'];

    @wire(getRecord, { recordId: Id, fields: ['User.Id'], optionalFields: ['User.Profile.Name'] })
    userDetails({ error, data }) {
        if (error) {
            console.log('userDetails error => ', error);
        } else if (data) {
            if (data.fields.Profile.value) {
                let profileName = data.fields.Profile.value.fields.Name.value;
                this.showQuoteInformation = headerFields_Profiles.includes(profileName);
                for (let profile in category_Profiles) {
                    this.showCategories[profile] = category_Profiles[profile].includes(profileName);
                }
                this.showCategories = JSON.parse(JSON.stringify(this.showCategories));
            }
        }
    }

    connectedCallback() {
        this.preparePriceFields();
        this.preparePriceCategMap();
        this.getQuote();
    }

    preparePriceFields() {
        for (let key in categoryOptions) {
            this.priceFields.push(categoryOptions[key]?.fieldName);
        }
    }

    showToast(toast) {
        this.dispatchEvent(new ShowToastEvent(toast));
    }

    /* Prepare a map of Price field and its respective category */
    preparePriceCategMap() {
        for (let category in this.categPriceFieldsMap) {
            let priceField = this.categPriceFieldsMap[category];
            this.priceFields.push(priceField);
            this.priceFieldCategoryMap[priceField] = { category: category, selectedOptionVariable: ('selected' + category + 'Value') };
        }
    }

    getQuote() {
        let _parameters = JSON.stringify({ quoteId: this.recordId });
        fetchQuote({ parameters: _parameters }).then(result => {
            this.quote = JSON.parse(JSON.stringify(result))[0];
            this.getQuotePricingConditionFieldset();
        }).catch(error => {
            console.log(error);
        })
    }

    /* Fetches the PricingConditionFieldset which contains the fields to be displayed under Quote Information */
    getQuotePricingConditionFieldset() {
        fetchQuotePricingConditionFieldset({ fieldSetName: 'Pricing_Condition_Header_Fields_Europe' }).then(result => {
            if (result) {
                this.headerFields = JSON.parse(result);
            }
            this.getQliPricingConditionFieldset();
        }).catch(error => {

        });
    }

    /* Fetches the PricingConditionFieldset which contains the fields to be displayed under Quote Line */
    getQliPricingConditionFieldset() {
        fetchQliPricingConditionFieldset({ fieldSetName: 'Pricing_Condition_Header_Fields_Europe' }).then(result => {
            if (result) {
                this.qliHeaderFields = JSON.parse(result);
                this.qliHeaderFields.forEach(field => {
                    field['show'] = !(field.name === 'Surcharge_variable__c' && !this.quote?.Variable_Fuel_Surcharge__c);
                    field['show'] = !(field.name === 'Ship_To__c' && this.quote?.Ship_To_Quote__c);
                    field['class'] = (field.name === 'Customer_Region__c') ? 'hide' : 'slds-grid slds-p-vertical_x-small slds-p-horizontal_small';
                });
            }
            console.log('this.qliHeaderFields => ', this.qliHeaderFields);
            this.getQLIs();
        }).catch(error => {

        });
    }

    /* Fetches all QLIs of the current Quote(quote) */
    getQLIs() {
        let parameterMap = JSON.stringify({ quoteId: this.recordId });
        fetchQLIsofQuote({ parameters: parameterMap }).then(result => {
            if (result) {
                this.qlis = JSON.parse(JSON.stringify(result));
                //this.quote = this.qlis[0].SBQQ__Quote__r;
                fetchPlantPicklistEntries({}).then(result => {
                    if (result) {
                        this.plantPicklistEntries = JSON.parse(JSON.stringify(result));
                        fetchSalesOrgByPlant({}).then(result => {
                            if (result) {
                                this.salesOrgPlantMap = {};
                                result.forEach(row => {
                                    this.salesOrgPlantMap[row.PlantCode__c] = row.SalesOrgCode__c;
                                });
                                this.getPriceLists();
                            }
                        }).catch(error => {
                            this.dtSpinner = false;
                            this.spinner = false;
                            console.log('getQLIs Error => ', error);
                        });
                    }
                }).catch(error => {
                    this.dtSpinner = false;
                    this.spinner = false;
                    console.log('getQLIs Error => ', error);
                });
            }
        }).catch(error => {
            this.dtSpinner = false;
            this.spinner = false;
            console.log('getQLIs Error => ', error);
        });
    }

    /* Fetches PriceLists data */
    getPriceLists() {
        let parameterMap = JSON.stringify({ startDate: this.quote.Valid_From__c, endDate: this.quote.Valid_To__c });
        fetchPriceLists({ parameters: parameterMap }).then(result => {
            console.log('fetchPriceLists result => ', result);
            this.priceLists = JSON.parse(JSON.stringify(result));
            this.formatQlisData();
        }).catch(error => {
            console.log('getPriceLists Error => ', error);
        })
    }

    /* Builds the wrapper and collects Sales Organization values to query for Pricing categories */
    formatQlisData() {
        this.qlis.forEach(qli => {
            qli.attributes = {};
            this.qliIds.push(qli.Id);   //Storing QLI Ids to pass these Ids to Accordion and open all the Accordion Sections by default on UI 
            this.qliIndexMap[qli.Id] = Object.keys(this.qliIndexMap).length;

            /* Preparing Plant Options for Datatable */
            if (qli.SBQQ__Product__r.Plant__c && qli.SBQQ__Product__r.Plant__c.length > 0) {
                let plantOptions = [];
                let plants = qli.SBQQ__Product__r.Plant__c.split(';');
                plants.forEach(plant => {
                    plantOptions.push({ label: this.plantPicklistEntries[plant], value: plant });
                });
                qli.PlantData = { options: plantOptions, value: qli.Plant__c };
                if (qli.Plant__c) {
                    qli.Sales_Organization__c = this.salesOrgPlantMap[qli.Plant__c];
                }
            }

            qli.SObject = 'SBQQ__QuoteLine__c';
            qli.attributes.dtStyling = this.dtStyling;
            qli.attributes.record = [JSON.parse(JSON.stringify(qli))];   //Storing the qli JSON into 'record' key to pass it to datatable
            qli.attributes.columns = JSON.parse(JSON.stringify(this.qliColumns));
            console.log(qli.attributes.columns);
        });

        this.getPricingCategories();   //Fetching Pricing Categories
        this.accordion.activeSections = this.qliIds;
    }

    /* Fetches Pricing Categories related to Sales Organizations and prepares Product, Freight, Misc, Discount and Commission Options */
    getPricingCategories() {
        let parameterMap = JSON.stringify({});
        if (this.qlis && this.qlis.length > 0 && this.qlis[0].SBQQ__Quote__r.Customer_Region__c && this.qlis[0].SBQQ__Quote__r.Customer_Region__c.length > 0) {
            parameterMap = JSON.stringify({ plantRegion: this.qlis[0].SBQQ__Quote__r.Customer_Region__c });
        }
        console.log('parameterMap', parameterMap);
        fetchPricingCategories({ parameters: parameterMap }).then(result => {
            let pricingCategories = result;
            fetchPCAs({ parameters: parameterMap }).then(result => {
                this.preparePricingCategsForQLIs(pricingCategories, result);
                this.dtSpinner = false;
                this.spinner = false;
            });
        }).catch(error => {
            this.dtSpinner = false;
            this.spinner = false;
            console.log('getPricingCategories Error => ', error);
        });
    }

    /* Prepares the Product, Freight, Misc, Discount and Commission Options data */
    preparePricingCategsForQLIs(pricingCategs, pcas) {
        let pricingCategsMap = this.preparePricingCategsMap(pricingCategs);
        this.preparePCAMap(pcas);
        if (pricingCategsMap && this.qlis) {
            this.qlis.forEach(qli => {
                qli = this.assignCategOptionsToQli(pricingCategsMap, qli, 'Product', this.categPriceFieldsMap['Product'], false);
                if (qli.attributes.Product) {
                    let priceField = this.categPriceFieldsMap['Product'];
                    if (!qli.attributes.Product.value && qli.attributes.Product.options && qli.attributes.Product.options.length > 0) {
                        for (let i = 0; i < qli.attributes.Product.options.length; i++) {
                            if (qli.attributes.Product.options[i].value === 'ZCPR__c') {
                                qli[priceField] = isNaN(qli[priceField]) ? 0 : qli[priceField];
                                qli.attributes.Product['price'] = { value: qli[priceField], required: true };
                                qli.attributes.Product.value = qli.attributes.Product.options[i].value;
                                // qli.attributes.Product.option.options = (this.pcaMap[qli.attributes.Product.value] && this.pcaMap[qli.attributes.Product.value].options) ? this.pcaMap[qli.attributes.Product.value].options : [];
                                // if (this.pcaMap[qli.attributes.Product.value] && this.pcaMap[qli.attributes.Product.value].options) {
                                //     qli.attributes.Product.option.value = '2';
                                //     let optionField = (this.pcaMap[qli.attributes.Product.value] && this.pcaMap[qli.attributes.Product.value].pcaField)
                                //         ? this.pcaMap[qli.attributes.Product.value].pcaField : null;       //Framing the option variable name of the category

                                //     if (optionField) {
                                //         this.qlis[index].attributes[category].option.value = value;        //Storing the newly selected value
                                //         this.qlis[index][optionField] = value;                             //Updating the value in option related field
                                //     }
                                // }
                                // qli.attributes.Product.option.required = (qli.attributes.Product.option.options && qli.attributes.Product.option.options.length > 0);
                                qli = this.assignOptions(null, qli.attributes.Product.value, qli, 'Product', '');
                                break;
                            }
                        }
                    }
                    let defaultPrice = this.assignDefaultPrice(qli, qli.attributes.Product.value.replaceAll('__c', ''));
                    if (defaultPrice) {
                        qli[qli.attributes.Product.value] = qli[priceField] = qli.attributes.Product.price.value = Number(defaultPrice);
                        qli.attributes.Product.price.disabled = true;
                    } else {
                        qli[qli.attributes.Product.value] = qli[priceField];
                        qli.attributes.Product.price.disabled ??= false;
                    }

                }
                qli = this.assignCategOptionsToQli(pricingCategsMap, qli, 'Misc', this.categPriceFieldsMap['Misc'], false);
                qli = this.assignCategOptionsToQli(pricingCategsMap, qli, 'Discount', this.categPriceFieldsMap['Discount'], false);
                qli = this.assignCategOptionsToQli(pricingCategsMap, qli, 'Commission', this.categPriceFieldsMap['Commission'], false);

                qli = this.assignCategOptionsToQli(pricingCategsMap, qli, 'Freight', this.categPriceFieldsMap['Freight'], true);
                qli = this.assignCategOptionsToQli(pricingCategsMap, qli, 'Surcharges', this.categPriceFieldsMap['Surcharges'], true);
                qli = this.assignCategOptionsToQli(pricingCategsMap, qli, 'Fees', this.categPriceFieldsMap['Fees'], true);

                qli.attributes.dtStyling.th += ' width: ' + (100 / qli.attributes.columns.length) + '%;';   //Calculating the width for each column so that all column will have equal widths
                for (let i = 0; i < qli.attributes.columns.length; i++) {
                    switch (qli.attributes.columns[i].fieldName) {
                        case 'SBQQ__Quantity__c': qli.attributes.columns[i].style = {
                            th: this.dtStyling.th + ' width: calc(' + (100 / (qli.attributes.columns.length + 1)) + '% + 10px);'
                        }; break;
                        case 'Sub_Total__c': qli.attributes.columns[i].style = {
                            th: this.dtStyling.th + ' width: calc(' + (100 / (qli.attributes.columns.length + 1)) + '% + 10px);'
                        }; break;
                        case 'Fees_Price__c': qli.attributes.columns[i].style = {
                            th: this.dtStyling.th + ' width: calc(' + (100 / (qli.attributes.columns.length + 1)) + '% - 10px);'
                        }; break;
                        default: qli.attributes.columns[i].style = {
                            th: this.dtStyling.th + ' width: calc(' + (100 / (qli.attributes.columns.length - 1)) + '% - 10px);'
                        };
                    }
                }
                console.log(qli.attributes.columns);
            });
        }
        console.log(this.qlis);
    }

    /* Prepares the Product, Freight, Misc, Discount and Commission Options data */
    preparePricingCategsMap(pricingCategs) {
        this.pcaDataMap = {};
        let pricingCategsMap = {};
        if (pricingCategs) {
            pricingCategs.forEach(pricingCateg => {
                if (!pricingCategsMap[pricingCateg.Price_Category__c]) {
                    pricingCategsMap[pricingCateg.Price_Category__c] = [{ label: '--None--', value: null }];
                }
                if (categoryOptions[pricingCateg.Description__c]) {
                    pricingCategsMap[pricingCateg.Price_Category__c].push({
                        label: pricingCateg.Description__c,
                        value: categoryOptions[pricingCateg.Description__c].fieldName
                    });
                }

                this.pcaDataMap[pricingCateg.Category_Type__c] = { Description: pricingCateg.Description__c };
            });
        }
        console.log(this.pcaDataMap);
        console.log(pricingCategsMap);
        return pricingCategsMap;
    }

    /* Prepare a map of Pricing Category value/field and their list of Pricing Condition Access records */
    preparePCAMap(pcas) {
        this.pcaMap = {};
        if (pcas) {
            pcas.forEach(pca => {
                if (this.pcaDataMap[pca.Princing_Condition__c] &&
                    this.pcaDataMap[pca.Princing_Condition__c].Description &&
                    this.pcaDataMap[pca.Princing_Condition__c].Description.length > 0 &&
                    categoryOptions[this.pcaDataMap[pca.Princing_Condition__c].Description]) {

                    let category = categoryOptions[this.pcaDataMap[pca.Princing_Condition__c].Description].fieldName;
                    let options, optionsInfo;
                    if (!this.pcaMap[category]) {
                        options = [{ label: '--None--', value: null }];
                        optionsInfo = {};
                        this.pcaMap[category] = {};
                    } else {
                        options = this.pcaMap[category].options;
                        optionsInfo = this.pcaMap[category].optionsInfo;
                    }
                    optionsInfo[pca.Option__c] = (pca.Option_Name__c) ? pca.Option_Name__c : '';
                    options.push({ label: pca.Option_Label__c, value: pca.Option__c });
                    this.pcaMap[category]['options'] = options;
                    this.pcaMap[category]['optionsInfo'] = optionsInfo;
                    this.pcaMap[category]['pca'] = pca.Princing_Condition__c;
                    this.pcaMap[category]['pcaField'] = pca.Princing_Condition__c + '_Option__c';

                    if (pca.Princing_Condition__c && pca.Default_Option_for_Regions__c && pca.Default_Option_for_Regions__c.includes(this.qlis[0].SBQQ__Quote__r.Customer_Region__c)) {
                        this.pcaMap[category]['defaultOption'] = pca.Option__c;
                    }
                }
            });
        }
    }

    /* Assign Pricing Category Options to the qli */
    assignCategOptionsToQli(pricingCategsMap, qli, category, priceField, isMultiSelect) {
        qli.attributes[category] = { show: false };
        if (pricingCategsMap[category]) {
            qli.attributes[category].show = true;
            qli.attributes[category].options = pricingCategsMap[category];     //Assigning Options to Pricing Category
            qli.attributes[category].pcaOptionsInfo = '';

            if (qli.attributes[category].options) {
                let existingOptionInfos = [];
                qli.attributes[category].options.forEach(option => {
                    if (this.pcaMap[option.value] && this.pcaMap[option.value].optionsInfo) {
                        for (let optionKey in this.pcaMap[option.value].optionsInfo) {
                            if (!existingOptionInfos.includes(optionKey)) {
                                qli.attributes[category].pcaOptionsInfo = qli.attributes[category].pcaOptionsInfo +
                                    `${optionKey} - ${this.pcaMap[option.value].optionsInfo[optionKey]}\n`;
                                existingOptionInfos.push(optionKey);
                            }
                        }
                    }
                });
            }

            if (!isMultiSelect) {
                qli.attributes[category].option = {};
                qli.attributes[category].option.value = '';
                qli.attributes[category].option.options = [];
                qli.attributes[category].option.required = false;
                qli.attributes[category].price = { value: qli[priceField], required: !isNaN(qli[priceField]), disabled: false };
                qli = (!isNaN(qli[priceField])) ? this.determineOption(pricingCategsMap, qli, category) : qli;   //Searching for the selected Option in the category so as to display the selected option on the UI in the combobox
            } else {
                qli = this.determineMultiSelectOptions(pricingCategsMap, qli, category);   //Searching for the selected Options in the category so as to display the selected options on the UI
            }

            qli.attributes.columns.splice(qli.attributes.columns.length - 1, 0, this.qliColumnsRefs[priceField]);   //Adding the column to the list of datatable columns so that this column will show up only if there any category options
        }
        return qli;
    }

    /* Searches through all the fields related to that category and returns the field that has some value */
    determineOption(pricingCategsMap, qli, category) {
        pricingCategsMap[category].forEach(pricingCateg => {
            if (!isNaN(qli[pricingCateg.value])) {
                qli.attributes[category].value = pricingCateg.value;   //Storing the fieldName of selected option
                if (this.isCategoryReadOnly(qli, qli.attributes[category].value)) {
                    // qli = this.makeColumnReadOnly(qli, category, true);
                    qli.attributes[category].price.disabled = true;
                }
                if (this.pcaMap[pricingCateg.value] && this.pcaMap[pricingCateg.value].options) {
                    qli.attributes[category].option.options = this.pcaMap[pricingCateg.value].options;
                    qli.attributes[category].option.value = qli[this.pcaMap[pricingCateg.value].pcaField];
                    qli.attributes[category].option.required = (qli.attributes[category].option.options && qli.attributes[category].option.options.length > 0);
                }
            }
        });
        return qli;
    }

    makeColumnReadOnly(qli, category, isDisabled) {
        let categories = {
            Product: { qliFieldName: 'List_Unit_Price__c', isMultiSelect: false },
            Commission: { qliFieldName: 'Commission__c', isMultiSelect: false },
            Discount: { qliFieldName: 'PC_Discount__c', isMultiSelect: false },
            Freight: { qliFieldName: 'Freight_Price__c', isMultiSelect: true },
            Surcharges: { qliFieldName: 'Surcharge__c', isMultiSelect: true },
            Fees: { qliFieldName: 'Fees_Price__c', isMultiSelect: true }
        };
        qli.attributes.columns.forEach(column => {
            if (categories[category].qliFieldName === column.fieldName) {
                column.editable = !isDisabled;
            }
        });
        return qli;
    }

    /* Searches through all the fields related to that category and returns all the fields that has some value */
    determineMultiSelectOptions(pricingCategsMap, qli, category) {
        qli.attributes[category].remOptions = JSON.parse(JSON.stringify(qli.attributes[category].options));
        let data = [];
        let selectedValues = [];
        pricingCategsMap[category].forEach(pricingCateg => {
            if (!isNaN(qli[pricingCateg.value])) {
                let row = this.initializeNewRow(data.length, qli.attributes[category].remOptions);
                row.label = pricingCateg.label;
                row.value = pricingCateg.value;
                row.price = qli[pricingCateg.value];
                row.currentOption = JSON.parse(JSON.stringify(pricingCateg));
                data.push(row);

                selectedValues.push(pricingCateg.value);

                if (this.pcaMap[pricingCateg.value] && this.pcaMap[pricingCateg.value].options) {
                    row.option.options = this.pcaMap[pricingCateg.value].options;
                    row.option.value = qli[this.pcaMap[pricingCateg.value].pcaField];
                    row.option.required = (row.option.options && row.option.options.length > 0);
                }

                /*Disabling Price when the selected category is among the Price Lists
                    OR
                Disabling Options and Price when the selected category is Bagged Freight(i.e. ZF01) */
                row.priceInfo.disabled = (this.isCategoryReadOnly(qli, row.value)
                    || this.isRestrictedCategory(row.value));
                row.option.disabled = this.isRestrictedCategory(row.value);

                let isEstimatedQtyEditable = row.label.toLowerCase().includes('flat');
                this.makeEstimatedQtyEditable(qli, isEstimatedQtyEditable);
            }
        });

        if (selectedValues && selectedValues.length > 0) {
            qli.attributes[category].remOptions = qli.attributes[category].remOptions.filter(option => !selectedValues.includes(option.value));
            data.forEach(row => {
                row.options = [JSON.parse(JSON.stringify(row.currentOption)), ...JSON.parse(JSON.stringify(qli.attributes[category].remOptions))];
            });
        }

        if (data && data.length > 0) {
            qli.attributes[category].data = data;
        } else {
            let defaultOption = this.initializeNewRow(data.length, qli.attributes[category].remOptions)
            if (qli[this.categPriceFieldsMap[category]]) {
                defaultOption.price = qli[this.categPriceFieldsMap[category]];
                defaultOption.optionsRequired = true;
            }
            qli.attributes[category].data = [defaultOption];
        }
        return qli;
    }

    isCategoryReadOnly(qli, categoryValue) {
        let readOnlyField = 'Is_' + categoryValue.replace('__c', '') + '_Read_Only__c';
        return false;//(qli[readOnlyField] === true);
    }

    handleHeaderValue(event) {
        this.quote[event.target.name] = event.target.value;
        switch (event.target.name) {
            case 'Ord_Reason__c':
                if (event.target.value) {
                    this.qlis?.forEach(qli => {
                        qli.SBQQ__Quote__r.Ord_Reason__c = event.target.value;
                        if (qli?.attributes?.Product) {
                            qli = this.assignOptions(null, qli.attributes.Product.value, qli, 'Product', '');
                        }
                    });
                    this.qlis = JSON.parse(JSON.stringify(this.qlis));
                }
                break;
            case 'Variable_Fuel_Surcharge__c':
                this.qliHeaderFields.forEach(field => field.show = !(field.name === 'Surcharge_variable__c' && !event.target.value));
                this.qliHeaderFields = JSON.parse(JSON.stringify(this.qliHeaderFields));
                break;
        }
        // if (event.target.name === 'Ord_Reason__c' && event.target.value) {
        //     this.qlis?.forEach(qli => {
        //         qli.SBQQ__Quote__r.Ord_Reason__c = event.target.value;
        //         if (qli?.attributes?.Product) {
        //             qli = this.assignOptions(null, qli.attributes.Product.value, qli, 'Product', '');
        //         }
        //     });
        //     this.qlis = JSON.parse(JSON.stringify(this.qlis));
        // }
    }

    handleQliHeaderValue(event) {
        let qliId = event.currentTarget.dataset.id;                                  //QLI Id of the Category whose option was selected
        let index = this.qliIndexMap[qliId];
        this.qlis[index][event.target.name] = event.target.value;
        console.log('handleQliHeaderValue' + event.target.name);
        console.log('handleQliHeaderValue-index' + index);
        let exwShipList = ['94', '95', '96', '97', '98', '99'];
        if (event.target.name == 'SE_Shipping_Type__c') {
            if (exwShipList.includes(event.target.value)) {
                this.qlis[index]['Incoterms__c'] = 'EXW';
                this.template.querySelector(`[data-id="${qliId}"][data-fieldname="Incoterms__c"]`).value = 'EXW';
                this.template.querySelector(`[data-id="${qliId}"][data-fieldname="Shipping_Condition__c"]`).value = 'CP';
                this.qlis = JSON.parse(JSON.stringify(this.qlis));
            } else {
                this.qlis[index]['Incoterms__c'] = 'DDP';
                this.template.querySelector(`[data-id="${qliId}"][data-fieldname="Incoterms__c"]`).value = 'DDP';
                if (event.target.value == '88') {
                    this.template.querySelector(`[data-id="${qliId}"][data-fieldname="Shipping_Condition__c"]`).value = 'ZD';
                } else {
                    this.template.querySelector(`[data-id="${qliId}"][data-fieldname="Shipping_Condition__c"]`).value = 'CD';
                }
                this.qlis = JSON.parse(JSON.stringify(this.qlis));
            }
        }
    }

    calculateSubtotal(qli) {
        try {
            if (qli) {
                if (isNaN(qli.SBQQ__Quantity__c)) {
                    qli.SBQQ__Quantity__c = 1;
                }
                let subtotal = 0;
                for (let categ in this.categPriceFieldsMap) {
                    let priceField = this.categPriceFieldsMap[categ];
                    if (!isNaN(qli[priceField])) {
                        if (categ === 'Discount') {
                            subtotal -= Number(qli[priceField]);
                        } else {
                            subtotal += Number(qli[priceField]);
                        }
                    }
                }
                qli.Sub_Total__c = (qli.SBQQ__Quantity__c * subtotal).toFixed(2);

                let _qli = JSON.parse(JSON.stringify(qli));
                delete _qli.attributes;
                qli.attributes.record = [JSON.parse(JSON.stringify(_qli))];
                //this.qlis = JSON.parse(JSON.stringify(qlis));
            }
            console.log(qli);
        } catch (e) {
            console.log(e);
        }
        return qli;
    }

    /* Calculates the total price from all the options of a category and assigns to their respective price field */
    calculatePriceTotal(qli, category, priceField) {
        try {
            let total = 0;
            let pricesAvailable = false;
            qli.attributes[category]?.data.forEach(row => {
                if (row.currentOption?.value?.length > 0 && !isNaN(row.price)) {
                    pricesAvailable = true;
                    if (row.currentOption.label.toLowerCase().includes('flat') && !isNaN(qli.Estimated_Qty_Delivery__c) && Number((qli.Estimated_Qty_Delivery__c)) > 0) {
                        total += Number(row.price) / Number(qli.Estimated_Qty_Delivery__c);
                    } else {
                        total += Number(row.price);
                    }
                } else if (!row.currentOption?.value && !isNaN(row.price) && Number(row.price) === 0) {
                    pricesAvailable = true;
                }
            });
            if (pricesAvailable) {
                qli[priceField] = total.toFixed(this.decimalPlaces);
            }
            qli = this.calculateSubtotal(qli);
        } catch (e) {
            console.log(e);
        }
        return qli;
    }

    makeEstimatedQtyEditable(qli, isEditable) {
        if (qli?.attributes?.columns) {
            if (!isEditable) {
                for (let category in this.categPriceFieldsMap) {
                    for (let i = 0; i < qli.attributes[category]?.data?.length; i++) {
                        if (qli.attributes[category]?.data[i].currentOption?.label?.toLowerCase().includes('flat')) {
                            isEditable = true; break;
                        }
                    }
                }
            }

            for (let i = 0; i < qli.attributes.columns.length; i++) {
                if (qli.attributes.columns[i].fieldName === 'Estimated_Qty_Delivery__c') {
                    qli.attributes.columns[i].editable = isEditable; break;
                }
            }
        }
    }

    /* Adds a new row to multi select category options */
    initializeNewRow(rno, remOptions) {
        return {
            rno: rno,
            options: JSON.parse(JSON.stringify(remOptions)),
            optionRequired: false,
            value: '',
            option: {
                options: [],
                value: '',
                disabled: false
            },
            price: 0,
            priceInfo: {
                disabled: false
            },
            showAdd: (remOptions.length > 0),
            showDelete: (rno !== 0)
        };
    }

    /* Handles the value change */
    handleCategoryChange(event) {
        let category = event.currentTarget.dataset.name;                             //Category whose option was selected
        let qliId = event.currentTarget.dataset.id;                                  //QLI Id of the Category whose option was selected
        let index = this.qliIndexMap[qliId];                                         //Index of the QLI for easy access
        let priceField = this.categPriceFieldsMap[category];                         //Framing the price variable name of the category i.e. List_Unit_Price__c, Freight_Price__c, etc.
        let value = event.target.value;                                              //Newly selected option value
        let previousValue = this.qlis[index].attributes[category].value;             //Previous option value, if any
        let previousOptionField = (previousValue && this.pcaMap[previousValue]?.pcaField)
            ? this.pcaMap[previousValue].pcaField
            : null;

        this.qlis[index].attributes[category].value = value;                         //Storing the newly selected value
        // this.qlis[index].attributes[category].option.options = (this.pcaMap[value] && this.pcaMap[value].options)
        //     ? (this.pcaMap[value].options)
        //     : [];   //Fetching PCA options
        // this.qlis[index].attributes[category].option.value = '';
        // this.qlis[index].attributes[category].option.required = (this.qlis[index].attributes[category].option.options && this.qlis[index].attributes[category].option.options.length > 0);
        this.qlis[index] = this.assignOptions(previousValue, value, this.qlis[index], category, '');
        /*if (value) {
            this.qlis[index][priceField] = isNaN(this.qlis[index][priceField]) ? 0 : this.qlis[index][priceField];   //Updating the Price to 0 if there is no prior Price value
            this.qlis[index][value] = this.qlis[index][priceField];                      //Updating the Price in the selectedOption with the Price value
        }*/
        let defaultPrice;
        this.qlis[index].attributes[category].price.disabled = false;
        if (value) {
            defaultPrice = this.assignDefaultPrice(this.qlis[index], value);
            /* this.qlis[index][priceField] = (!isNaN(this.qlis[index][priceField]) && Number(this.qlis[index][priceField]) > 0)
                ? this.qlis[index][priceField]
                : (defaultPrice ?? 0); */
            if (defaultPrice && !isNaN(defaultPrice)) {
                this.qlis[index][priceField] = Number(defaultPrice);
                this.qlis[index].attributes[category].price.disabled = true;
            }
            this.qlis[index][value] = this.qlis[index][priceField];                      //Updating the Price in the selectedOption with the Price value
            this.qlis[index].attributes[category].price.value = this.qlis[index][priceField];
        }
        this.qlis[index] = this.makeColumnReadOnly(this.qlis[index], category, (defaultPrice !== null && typeof defaultPrice !== 'undefined'));
        if (previousValue) {
            this.qlis[index][previousValue] = null;                                  //Removing the price value from the option which was previously selected
            if (previousOptionField && this.qlis[index][previousOptionField]) {
                this.qlis[index][previousOptionField] = null;                        //Removing the value in option field
            }
        }
        this.qlis[index] = this.calculateSubtotal(this.qlis[index]);
        let _qli = JSON.parse(JSON.stringify(this.qlis[index]));
        delete _qli.attributes;
        this.qlis[index].attributes.record = [JSON.parse(JSON.stringify(_qli))];
        this.qlis = JSON.parse(JSON.stringify(this.qlis));
        console.log(this.qlis);
    }

    /* Handles the option change */
    handleOptionChange(event) {
        let category = event.currentTarget.dataset.name;                             //Category whose option was selected
        let qliId = event.currentTarget.dataset.id;                                  //QLI Id of the Category whose option was selected
        let index = this.qliIndexMap[qliId];                                         //Index of the QLI for easy access
        let value = event.target.value;                                              //Newly selected option value
        let categoryValue = this.qlis[index].attributes[category].value;
        let optionField = (categoryValue && this.pcaMap[categoryValue]?.pcaField)
            ? this.pcaMap[categoryValue].pcaField
            : null;                       //Framing the option variable name of the category

        this.qlis[index].attributes[category].option.value = value;                  //Storing the newly selected value
        if (optionField) {
            this.qlis[index][optionField] = value;                                       //Updating the value in option related field
        }
    }

    /* Handles the price change */
    handlePriceChange(event) {
        let category = event.currentTarget.dataset.name;                             //Category whose option was selected
        let qliId = event.currentTarget.dataset.id;                                  //QLI Id of the Category whose option was selected
        let index = this.qliIndexMap[qliId];                                         //Index of the QLI for easy access
        let value = event.target.value;                                              //Newly selected option value
        let categoryValue = this.qlis[index].attributes[category].value;
        let priceField = this.categPriceFieldsMap[category];                         //Framing the price variable name of the category i.e. List_Unit_Price__c, Freight_Price__c, etc.

        let qlis = this.qlis;
        qlis[index][priceField] = Number(value).toFixed(this.decimalPlaces);         //Storing the new value in qlis
        if (!categoryValue) {
            categoryValue = qlis[index].attributes[category].options[1].value;
            qlis[index].attributes[category].value = categoryValue;
            qlis[index] = this.assignOptions(null, categoryValue, qlis[index], category, '');
        }
        qlis[index][categoryValue] = Number(qlis[index][priceField]).toFixed(this.decimalPlaces);   //Updating selectedOption with the new Price
        qlis[index].attributes[category].price["value"] = qlis[index][categoryValue];

        let _qli = JSON.parse(JSON.stringify(qlis[index]));
        delete _qli.attributes;
        qlis[index].attributes.record = [JSON.parse(JSON.stringify(_qli))];
        qlis[index] = this.calculateSubtotal(qlis[index]);
        this.qlis = JSON.parse(JSON.stringify(qlis));
    }

    /* Handles the value change in multi-select category options */
    handleRowCategChange(event) {
        try {
            let qliId = event.currentTarget.dataset.id;
            let category = event.currentTarget.dataset.name;
            let index = this.qliIndexMap[qliId];
            let rno = event.currentTarget.dataset.rno;
            let value = event.target.value;
            let previousData = JSON.parse(JSON.stringify(this.qlis[index].attributes[category].data[rno]));
            let previousOptionField = (previousData.value && this.pcaMap[previousData.value]?.pcaField) ? this.pcaMap[previousData.value].pcaField : null;
            let priceField = this.categPriceFieldsMap[category];

            // let isEstimatedQtyEditable = value?.toLowerCase().includes('flat');

            // event.target.options.forEach(opt => {
            //     if (opt['value'] == event.target.value && opt['label'].toLowerCase().includes('flat')) {
            //         isEstimatedQtyEditable = true;
            //     }
            // });
            // this.makeEstimatedQtyEditable(this.qlis[index], isEstimatedQtyEditable);

            if (previousData.value && previousData.value.length > 0 && previousData.currentOption) {
                this.qlis[index].attributes[category].remOptions.push(previousData.currentOption);
                this.qlis[index][previousData.value] = null;
                if (previousOptionField && this.qlis[index][previousOptionField]) {
                    this.qlis[index][previousOptionField] = null;
                }
            }

            this.qlis[index].attributes[category].data[rno].value = value;
            this.qlis[index] = this.assignOptions(previousData.value, value, this.qlis[index], category, rno);
            // this.qlis[index].attributes[category].data[rno].option.options = (this.pcaMap[value] && this.pcaMap[value].options) ? (this.pcaMap[value].options) : [];   //Fetching PCA options
            /* Making Ship To option as default in every category */
            // for (let i = 0; i < this.qlis[index].attributes[category].data[rno].option.options.length; i++) {
            //     let option = this.qlis[index].attributes[category].data[rno].option.options[i];
            //     if (option.label && option.label.toLowerCase() === 'ship to') {
            //         this.qlis[index].attributes[category].data[rno].option.value = option.value;
            //         break;
            //     }
            // }

            let defaultPrice;
            if (value && !this.disabledPcs.includes(value)) {
                defaultPrice = this.assignDefaultPrice(this.qlis[index], value);
                // this.qlis[index][value] = !isNaN(previousData.price) && Number(previousData.price) != 0
                //     ? Number(previousData.price)
                //     : defaultPrice;
                this.qlis[index][value] = (defaultPrice != null)
                    ? defaultPrice
                    : Number(previousData.price);
                this.qlis[index].attributes[category].data[rno].price = this.qlis[index][value];
            } else if (value && this.disabledPcs.includes(value)) {
                /* If any of the disabled Categories, make Price to 0 and make options as optional. */
                this.qlis[index].attributes[category].data[rno].price = 0;
                this.qlis[index].attributes[category].data[rno].optionsRequired = false;
                this.qlis[index][value] = 0;
            } else {
                /* If "None" is selected, make Price to 0 and make options as optional. */
                this.qlis[index].attributes[category].data[rno].price = 0;
                this.qlis[index].attributes[category].data[rno].optionsRequired = false;
            }

            let remOptions = JSON.parse(JSON.stringify(this.qlis[index].attributes[category].remOptions));
            if (remOptions) {
                for (let i = 0; i < remOptions.length; i++) {
                    let remOption = remOptions[i];
                    if (remOption.value === value) {
                        this.qlis[index].attributes[category].data[rno].currentOption = remOption;
                        if (value) {
                            remOptions.splice(i, 1);
                        }
                        break;
                    }
                }
            }
            this.qlis[index].attributes[category].remOptions = JSON.parse(JSON.stringify(remOptions));

            /* Reassigning category options to each row */
            if (this.qlis[index].attributes[category].data) {
                this.qlis[index].attributes[category].data.forEach(row => {
                    row.options = JSON.parse(JSON.stringify(remOptions));   //Assigning category options without its selected option
                    if (row.value && row.currentOption) {
                        row.options.splice(1, 0, row.currentOption);        //Assigning selected option to the already list of cetgoyr options
                    }
                });
            }

            /* Disabling Price when the selected category is among the Price Lists
                    OR
            Disabling Options and Price when the selected category is Bagged Freight(i.e. ZF01) */
            this.qlis[index].attributes[category].data[rno].priceInfo.disabled = (defaultPrice != null && typeof defaultPrice !== 'undefined') || this.isRestrictedCategory(value);
            this.qlis[index].attributes[category].data[rno].option.disabled = this.isRestrictedCategory(value);

            this.qlis[index] = this.calculatePriceTotal(this.qlis[index], category, priceField);
            this.makeEstimatedQtyEditable(this.qlis[index], false);
        } catch (e) {
            console.log('handleRowCategChange error => ', e);
        }
    }

    updateCategoryReadOnlyField(qlis) {
        let readOnlyCategories = ['ZCO2', 'ZCPR'];
        qlis?.forEach(qli => {
            readOnlyCategories.forEach(category => {
                let categoryField = category + '__c';
                let categoryReadOnlyField = 'Is_' + category + '_Read_Only__c';
                qli[categoryReadOnlyField] = (qli[categoryField] !== null && typeof qli[categoryField] !== 'undefined');
            });
        });
        return qlis;
        // let readOnlyField = 'Is_' + categoryValue.replace('__c','') + '_Read_Only__c';
        // qli[readOnlyField] = (price !== null && typeof price !== 'undefined');
        // return qli;
    }

    isRestrictedCategory(categoryValue) {
        return this.disabledPcs.includes(categoryValue);
    }

    /* Assigns default option value based on category value */
    assignOptions(prevCategoryValue, categoryValue, qli, category, rno) {
        let prevOptionField = (prevCategoryValue && this.pcaMap[prevCategoryValue]?.pcaField) ? this.pcaMap[prevCategoryValue].pcaField : null;   //Framing the option variable name of the category
        let optionField = (categoryValue && this.pcaMap[categoryValue]?.pcaField) ? this.pcaMap[categoryValue].pcaField : null;   //Framing the option variable name of the category
        let intitalOption = {
            options: [],
            required: false,
            value: null
        };

        /* Making the value in previous option's field to null */
        if (prevOptionField && qli[prevOptionField]) {
            qli[prevOptionField] = null;
        }

        /* Intializing options */
        if (rno && rno.length > 0) {
            qli.attributes[category].data[rno].option = intitalOption;
        } else {
            qli.attributes[category].option = intitalOption;
        }

        /* Making the value in current option's field to chosen option value */
        if (optionField && this.pcaMap && this.pcaMap[categoryValue]) {
            if (rno && rno.length > 0) {
                qli.attributes[category].data[rno].option.options = this.pcaMap[categoryValue]?.options ? this.pcaMap[categoryValue].options : [];   //Fetching PCA options
                qli.attributes[category].data[rno].option.required = (qli.attributes[category].data[rno].option.options.length > 0);
                if (this.pcaMap[categoryValue]?.defaultOption) {
                    qli.attributes[category].data[rno].option.value = this.pcaMap[categoryValue]?.defaultOption;
                    qli[optionField] = this.pcaMap[categoryValue]?.defaultOption;
                }
            } else {
                let defaultOption;
                qli.attributes[category].option.options = this.pcaMap[categoryValue]?.options ? this.pcaMap[categoryValue].options : [];   //Fetching PCA options
                qli.attributes[category].option.required = (qli.attributes[category].option.options.length > 0);
                /* Checking if the category is Product and the qli's quote has Ord Reason value */
                if (category === 'Product' && qli?.SBQQ__Quote__r?.Ord_Reason__c) {
                    /* Hardcoding the value of "Ship to + Ord Reason" i.e. "1" as default Option if the Quote some Ord Reason value */
                    let filteredDefaultOptions = qli.attributes[category].option.options.filter(option => option.value === '1');
                    if (filteredDefaultOptions && filteredDefaultOptions.length > 0) {
                        defaultOption = filteredDefaultOptions[0].value;
                    }
                }
                /* Checking if the defaultOption is not populated and the category has some defaultOption configured in pcaMap */
                if (!defaultOption && this.pcaMap[categoryValue]?.defaultOption) {
                    defaultOption = this.pcaMap[categoryValue]?.defaultOption;
                }
                /* Checking if the defaultOption is valid so as to actually assign the defaultOption in the wrapper */
                if (defaultOption) {
                    qli.attributes[category].option.value = defaultOption;
                    qli[optionField] = defaultOption;
                }
            }
        }
        return qli;
    }

    /* Assigns default price based on some filters whenever a category value changes */
    assignDefaultPrice(qli, categoryValue) {
        if (categoryValue.endsWith('__c')) {
            categoryValue = categoryValue.replaceAll('__c', '');
        }
        let priceList = this.priceLists?.filter(priceList => {
            console.log(priceList.Material__c, priceList);
            return priceList.CnTy__c === categoryValue && priceList.Plnt__c === qli.Plant__c && priceList.Material__c === qli.SBQQ__ProductCode__c && priceList.PL__c === qli.SBQQ__Quote__r.Sold_to__r.Price_List__c;   //return priceList.CnTy__c === categoryValue;
        });
        if (priceList && priceList.length > 0 && priceList[0].Amount__c) {
            return priceList[0].Amount__c;
        }
        // return 0;
        return null;
    }

    /* Assigns default prices to all the categories based on some filters whenever the Plant value gets changed */
    assignDefaultPrices(qli) {
        try {
            let categories = [
                { name: 'Product', qliFieldName: 'List_Unit_Price__c', isMultiSelect: false },
                { name: 'Commission', qliFieldName: 'Commission__c', isMultiSelect: false },
                { name: 'Discount', qliFieldName: 'PC_Discount__c', isMultiSelect: false },
                { name: 'Freight', qliFieldName: 'Freight_Price__c', isMultiSelect: true },
                { name: 'Surcharges', qliFieldName: 'Surcharge__c', isMultiSelect: true },
                { name: 'Fees', qliFieldName: 'Fees_Price__c', isMultiSelect: true }
            ];
            categories.forEach(category => {
                if (category.isMultiSelect && qli?.attributes[category.name]?.data) {
                    qli?.attributes[category.name].data.forEach(row => {
                        if (row.value) {
                            // if (row.value && !(row.price && Number(row.price) !== 0)) {
                            let price = this.assignDefaultPrice(qli, row.value);
                            if (price) {
                                row.price = price;
                                row.priceInfo.disabled = true;
                                qli[row.value] = row.price;
                            } else {
                                row.priceInfo.disabled = false;
                            }
                        }
                    });
                    qli = this.calculatePriceTotal(qli, category.name, this.categPriceFieldsMap[category.name]);
                } else if (!category.isMultiSelect && qli.attributes[category.name]?.value && !(qli.attributes[category.name]?.price?.value && Number(qli.attributes[category.name].price.value) !== 0)) {
                    let price = this.assignDefaultPrice(qli, qli.attributes[category.name].value);
                    if (price) {
                        qli.attributes[category.name].price.value = qli[category.qliFieldName] = qli[qli.attributes[category.name].value] = Number(price);
                        qli.attributes[category.name].price.disabled = true;
                    } else {
                        qli.attributes[category.name].price.disabled = false;
                    }
                    qli = this.makeColumnReadOnly(qli, category.name, (price !== null && typeof price !== 'undefined'));
                }
            });
        } catch (e) {
            console.log(e);
        }
        return qli;
    }

    /* Handles the option change in multi-select category options */
    handleRowOptionChange(event) {
        let qliId = event.currentTarget.dataset.id;
        let category = event.currentTarget.dataset.name;
        let index = this.qliIndexMap[qliId];
        let rno = event.currentTarget.dataset.rno;
        let value = event.target.value;
        let categoryValue = this.qlis[index].attributes[category].data[rno].value;
        let optionField = (categoryValue && this.pcaMap[categoryValue]?.pcaField) ? this.pcaMap[categoryValue].pcaField : null;                       //Framing the option variable name of the category

        if (optionField) {
            this.qlis[index].attributes[category].data[rno].option.value = value;        //Storing the newly selected value
            if (optionField) {
                this.qlis[index][optionField] = value;                                       //Updating the value in option related field
            }
        }

    }

    /* Handles the price change in multi-select category options */
    handleRowPriceChange(event) {
        let qliId = event.currentTarget.dataset.id;
        let category = event.currentTarget.dataset.name;
        let index = this.qliIndexMap[qliId];
        let rno = event.currentTarget.dataset.rno;
        let value = isNaN(event.target.value) ? event.target.value : Number(event.target.value).toFixed(this.decimalPlaces);
        let option = this.qlis[index].attributes[category].data[rno];
        let priceField = this.categPriceFieldsMap[category];

        this.qlis[index].attributes[category].data[rno].price = value;
        this.qlis[index].attributes[category].data[rno].optionsRequired = (!isNaN(value) && Number(value) > 0);
        this.qlis = JSON.parse(JSON.stringify(this.qlis));

        if (option.value && option.value.length > 0) {
            this.qlis[index][option.value] = value;
            this.qlis[index] = this.calculatePriceTotal(this.qlis[index], category, priceField);
        }
    }

    /* Handles addition of a new row to the multi select options */
    handleNewRow(event) {
        let qliId = event.currentTarget.dataset.id;
        let category = event.currentTarget.dataset.name;
        let index = this.qliIndexMap[qliId];
        let rno = event.currentTarget.dataset.rno;
        let qli = JSON.parse(JSON.stringify(this.qlis[index]));
        let data = JSON.parse(JSON.stringify(this.qlis[index].attributes[category].data));

        if (this.qlis[index].attributes[category].data.length < this.qlis[index].attributes[category].options.length - 1) {
            this.qlis[index].attributes[category].data.push(this.initializeNewRow(data.length, qli.attributes[category].remOptions));
        }
    }

    /* Handles deletion of a row */
    handleDelRow(event) {
        let qliId = event.currentTarget.dataset.id;
        let category = event.currentTarget.dataset.name;
        let index = this.qliIndexMap[qliId];
        let rno = event.currentTarget.dataset.rno;
        let previousData = JSON.parse(JSON.stringify(this.qlis[index].attributes[category].data[rno]));
        let priceField = this.categPriceFieldsMap[category];
        let remOptions = JSON.parse(JSON.stringify(this.qlis[index].attributes[category].remOptions));

        if (previousData.currentOption?.value) {
            remOptions.push(previousData.currentOption);
            this.qlis[index].attributes[category].remOptions = JSON.parse(JSON.stringify(remOptions));

            if (this.qlis[index].attributes[category].data) {
                let i = 0;
                this.qlis[index].attributes[category].data.forEach(row => {
                    row.rno = (i > rno) ? i - 1 : row.rno;
                    row.options = JSON.parse(JSON.stringify(remOptions));
                    if (row.value && row.currentOption) {
                        row.options.splice(0, 0, row.currentOption);
                    }
                    i += 1;
                });
            }
        }

        if (previousData?.value) {
            this.qlis[index][previousData.value] = null;
        }
        this.qlis[index].attributes[category].data.splice(rno, 1);
        this.qlis[index] = this.calculatePriceTotal(this.qlis[index], category, priceField);
        this.makeEstimatedQtyEditable(this.qlis[index], false);
    }

    /* Handles the change in cell values of the table */
    handleCellChange(event) {
        let draftValues = event.detail.draftValues;
        if (draftValues) {
            let qlis = JSON.parse(JSON.stringify(this.qlis));
            draftValues.forEach(draftValue => {
                let index = this.qliIndexMap[draftValue.Id];            //Index of the QLI whose data has been changed in datatable

                /* Looping through fields in draft because we don't know the field which was modified */
                for (let field in draftValue) {
                    if (field !== 'Id') {
                        if (this.priceFieldCategoryMap[field]) {       //Checking if the modified field is a Price field so that its respective selectedOption should also be updated with the new Price
                            qlis[index][field] = Number(draftValue[field]).toFixed(this.decimalPlaces);   //Storing the new value in qlis
                            let category = this.priceFieldCategoryMap[field].category;
                            let value = qlis[index].attributes[category].value;
                            if (!value) {
                                value = qlis[index].attributes[category].options[1].value;
                                qlis[index].attributes[category].value = value;
                                qlis[index] = this.assignOptions(null, value, qlis[index], category, '');
                            }
                            qlis[index][value] = Number(qlis[index][field]).toFixed(this.decimalPlaces);   //Updating selectedOption with the new Price
                        } else {
                            qlis[index][field] = draftValue[field];                                        //Storing the new value in qlis
                            if (field === 'Estimated_Qty_Delivery__c') {
                                qlis = this.updateMultiOptionsTotals(qlis, index);
                            } else if (field === 'Plant__c') {
                                qlis[index]['Sales_Organization__c'] = this.salesOrgPlantMap[draftValue[field]];
                                qlis[index] = this.assignDefaultPrices(qlis[index]);
                            }
                        }
                    }
                }
                let _qli = JSON.parse(JSON.stringify(qlis[index]));
                delete _qli.attributes;
                qlis[index].attributes.record = [JSON.parse(JSON.stringify(_qli))];
                qlis[index] = this.calculateSubtotal(qlis[index]);
            });
            this.qlis = JSON.parse(JSON.stringify(qlis));
        }
        console.log(this.qlis);
    }

    /* Calculates and updates the Price Totals of the Multi Select Options */
    updateMultiOptionsTotals(qlis, index) {
        if (!isNaN(qlis[index][this.categPriceFieldsMap['Freight']])) {
            qlis[index] = this.calculatePriceTotal(qlis[index], 'Freight', this.categPriceFieldsMap['Freight']);
        }
        if (!isNaN(qlis[index][this.categPriceFieldsMap['Surcharges']])) {
            qlis[index] = this.calculatePriceTotal(qlis[index], 'Surcharges', this.categPriceFieldsMap['Surcharges']);
        }
        if (!isNaN(qlis[index][this.categPriceFieldsMap['Fees']])) {
            qlis[index] = this.calculatePriceTotal(qlis[index], 'Fees', this.categPriceFieldsMap['Fees']);
        }
        return qlis;
    }

    /* Handles Accordian's collapse and expand */
    handleAccordion() {
        if (this.accordion.isCollapsed) {
            this.accordion = {
                title: 'Collapse All Products',
                iconName: 'utility:collapse_all',
                activeSections: this.qliIds,
                isCollapsed: false
            };
        } else {
            this.accordion = {
                title: 'Expand All Products',
                iconName: 'utility:expand_all',
                activeSections: [],
                isCollapsed: true
            };
        }
    }

    /* Navigating to the previous screen i.e. Quote Line Editor */
    handleBack() {
        this.navigateToUrlFromVf('/apex/sbqq__sb?id=' + this.recordId);
    }
    /* Closes the Pricing Condition Screen and navigates to the Quote Record Page */
    handleClose() {
        window.location.href = '/' + this.recordId;
    }

    /* Saves the QLI */
    saveQLIs(closePage) {
        this.spinner = true;
        let isValid = this.isValid();
        if (isValid === true) {
            //this.handleQuoteSubmit();
            let isBaggedFreightSelected = false;
            let qlisData = JSON.parse(JSON.stringify(this.qlis));
            console.log('LOCALE==========' + this.localee);
            qlisData.forEach(qli => {
                isBaggedFreightSelected = (isBaggedFreightSelected ||
                    (typeof qli.ZF01__c !== 'undefined' && !isNaN(qli.ZF01__c)));
                if (!this.localee.includes('en-')) {
                    for (const key in qli) {
                        if (this.priceFields.includes(key) && qli[key] && !isNaN(qli[key]) && typeof qli[key] !== 'number') {
                            qli[key] = qli[key].replaceAll('.', ',');
                        }
                    }
                }
                delete qli.attributes;
                delete qli.PlantData;
            });
            this.quote.Is_Bagged_Freight_Selected__c = isBaggedFreightSelected;

            // qlisData = this.updateCategoryReadOnlyField(qlisData);

            updateQuote({ quote: this.quote }).then(result => {
                return updateQLIsWithPricingCategs({ qlis: qlisData });
            }).then(result => {
                if (result && closePage) {
                    this.handleClose();
                }
                this.spinner = false;
            }).catch(error => {
                this.spinner = false;
                console.log('saveQLIs Error => ', error);
            });
        } else {
            this.spinner = false;
        }
    }
    /* Updates the QLIs with new data containing Price values */
    handleSave() {
        this.saveQLIs(false);
    }
    /* Updates the QLIs with new data containing Price values */
    handleSaveClose() {
        this.saveQLIs(true);
    }
    /* Updates the Quote with new values */
    handleQuoteSubmit() {
        this.template.querySelectorAll('lightning-record-edit-form').forEach(form => form.submit());
    }

    /* Checking if all the entered data is valid or not including empty required fields, incorrect data formats, etc. */
    isValid() {
        let cfvo = this.checkForValidOptions();
        let cfvdid = this.checkForValidDataInDatatable();
        let cffs = this.checkForFuelSurcharges();
        let stvs = this.checkForValidIncoterms();
        let cfvmt = this.checkForValidMinTon();

        let status = cfvo && cfvdid && cffs && stvs && cfvmt;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            element.reportValidity();
            console.log(element);
        });
        return status;
    }

     checkForValidMinTon(){
        let status = true;
        for (let i = 0; i < this.qlis.length; i++) {
            let qli = this.qlis[i];
            if((qli.ZF7__c > 0  || qli.ZMF7__c > 0 || qli.ZF6__c > 0 || qli.ZSTF__c > 0|| qli.ZAD__c > 0 || qli.ZF9__c > 0 || qli.ZF11__c > 0)
                    && !qli.Estimated_Qty_Delivery__c > 0 ){
                    status = false;
            }
        }
        if (!status) {
            this.showToast({ variant: 'error', title: 'Estimated quantity validation.', message: 'Please provide Estimated quantity for flat fees.' });
        }
        return status;
    }

    checkForValidIncoterms() {
        let shipTypeMap = {};
        let status = true;
        for (let i = 0; i < this.qlis.length; i++) {
            let qli = this.qlis[i];
            if (typeof shipTypeMap[qli.SE_Shipping_Type__c] == 'undefined') {
                shipTypeMap[qli.SE_Shipping_Type__c] = qli.Incoterms__c;
            }
            if (typeof shipTypeMap[qli.SE_Shipping_Type__c] != 'undefined' && shipTypeMap[qli.SE_Shipping_Type__c] != qli.Incoterms__c) {
                status = false;
            }

        }
        if (!status) {
            this.showToast({ variant: 'error', title: 'Incoterms validation.', message: 'Please select same incoterms for same Shipping Type Values.' });
        }
        return status;
    }

    /* Checking if all the entered data among the categories and options is valid or not including empty required fields, incorrect data formats, etc. */
    checkForValidOptions() {
        let status = true;
        console.log(this.template.querySelectorAll('[data-required="true"]'));
        this.template.querySelectorAll('[data-required="true"]').forEach(element => {
            element.reportValidity();

            // if one element is invalid, set variable to false
            if (!element.validity.valid) {
                status = false;
            }
        });
        if (!status) {
            this.showToast({ variant: 'error', title: 'One or more required values are missing.', message: 'Kindly validate your data before submitting again.' });
        }
        return status;
    }

    /* Checking if all the entered data in the datatables is valid or not including empty required fields, incorrect data formats, etc. */
    checkForValidDataInDatatable() {
        let status = true;
        this.template.querySelectorAll('c-custom-datatable').forEach(datatableElement => {
            status = status && datatableElement.validateData();
        });
        if (!status) {
            this.showToast({ variant: 'error', title: 'One or more required values are missing.', message: 'Kindly validate your data before submitting again.' });
        }
        return status;
    }

    checkForFuelSurcharges() {
        let status = true;
        if (this.quote.Variable_Fuel_Surcharge__c) {
            for (let i = 0; i < this.qlis.length; i++) {
                let qli = this.qlis[i];
                if (qli?.attributes?.Surcharges?.data) {
                    for (let j = 0; j < qli.attributes.Surcharges.data.length; j++) {
                        let row = qli.attributes.Surcharges.data[j];
                        if (row.currentOption?.label?.toLowerCase().includes('fuel')) {
                            status = false;
                            break;
                        }
                    }
                    if (!status) { break; }
                }
            }
        }
        if (!status) {
            this.showToast({ variant: 'error', title: 'Unable to Save', message: 'Remove fuel related surcharges as surcharge variable is enabled.' });
        }
        return status;
    }
}