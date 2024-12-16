import { LightningElement, api, track } from 'lwc';
import Id from '@salesforce/user/Id';
import getPONumber from '@salesforce/apex/OrderController.getPONumber';
import getProduct from '@salesforce/apex/OrderUtils.getProductById';
import Split_Shipment_Deliveries_Required from '@salesforce/label/c.Split_Shipment_Deliveries_Required';
import Split_Shipment_Delivery_End_Date from '@salesforce/label/c.Split_Shipment_Delivery_End_Date';
import Split_Shipment_Delivery_Start_Date from '@salesforce/label/c.Split_Shipment_Delivery_Start_Date';
import Split_Shipment_Delivery_Text from '@salesforce/label/c.Split_Shipment_Delivery_Text';
import Split_Shipment_Line_Item_Delivery_Date from '@salesforce/label/c.Split_Shipment_Line_Item_Delivery_Date';
import Split_Shipment_Load_Volume from '@salesforce/label/c.Split_Shipment_Load_Volume';
import Split_Shipment_PO_Number from '@salesforce/label/c.Split_Shipment_PO_Number';
import Same_Day_Delivery_Warning from '@salesforce/label/c.Same_Day_Delivery_Warning';
import Split_Shipment_Select_Product from '@salesforce/label/c.Split_Shipment_Select_Product';
import Split_Shipment_Shipping_Mode from '@salesforce/label/c.Split_Shipment_Shipping_Mode';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Next_Day_Order_Delivery_Warning from '@salesforce/label/c.Next_Day_Order_Delivery_Warning';
import LightningConfirm from "lightning/confirm"
import isCarrierUser  from '@salesforce/customPermission/Carrier_User_Only';
import getShipToOverrideTonnageLimit from '@salesforce/apex/UserUtils.getShipToOverrideTonnageLimit';
import getPlantCodesForValidation from '@salesforce/apex/UserUtils.getPlantCodesForValidation';
import Plant_Code_Business_Day_And_Weekend_Validation from '@salesforce/label/c.Plant_Code_Business_Day_And_Weekend_Validation';
import Plant_Code_Business_Day_Validation from '@salesforce/label/c.Plant_Code_Business_Day_Validation';
import Plant_Code_Validation_Customer_Service from '@salesforce/label/c.Plant_Code_Validation_Customer_Service';
import Plant_Code_Validation_Product_Available from '@salesforce/label/c.Plant_Code_Validation_Product_Available';
import Plant_Code_Weekend_Validation from '@salesforce/label/c.Plant_Code_Weekend_Validation';
import getShipToOverrideGallonLimit from '@salesforce/apex/UserUtils.getShipToOverrideGallonLimit';
import getPermissionAssignedToUser from '@salesforce/apex/OrderUtils.getPermissionAssignedToUser';
import Business_Unit_for_the_MLS_account from '@salesforce/label/c.Business_Unit_for_the_MLS_account';
import Business_Unit_MLS_Account_Validation from '@salesforce/label/c.Business_Unit_MLS_Account_Validation';

export default class SplitShipmentProductDetails extends LightningElement {

    @api recordId;
    @api accountId;
    @api selectedProduct;
    @api mapOfProductIdVsName;
    @api mapOfProductNameVsId;
    @api mapOfIndexVsProductDetail;
    @api mapOfProductIdVsAvailable;
    @track lineItemsGenerated = false;
    @track selectedMeasure;
    @track selectedStartDate;
    @track selectedEndDate;
    @track selectedNumberOfRecurring;
    @track selectedShippingMode;
    @track shippingMode;
    @track loadVolumeLabel = "Load Volume";
    @track selectedQuantity;
    @track enteredPoNumber;
    @track today;
    @track maxDate;
    @track cartItems;
    @track enteredDeliveryText;
    @track maxEndDate;
    //@track listOfProductItems = [];
    @track mapIndexVsProduct = {};
    @track mapToDisplayData = {};
    @track ProductDetail = {  Product : null,
                        startDate : null ,
                        endDate : null,
                        loadVolume : null,
                        shippingMode : null,
                        shippingType : null,
                        shippingCondition : null,
                        quantity : null,
                        poNumber : null,
                        productId : null,
                        deliveryText : null,
                        isFile: null,
                        plantCode: null,
                        productCode: null,
                        validFrom: null,
                        validTo: null,
                        carrier: null,
                     };

    @track listOfLineItem = [];
    @track structureForTableRow = { Product : null, deliveryDate: null, deliveryDay: null, Quantity: null, Tonnage: null, DeliveryText: null, PoNumber: null};
    @track listDeliveryLineItems= [];    
    @track showLineItems = false;
    @track currentProduct;
    @track testTrue = false;

    @track effectiveAccountId = null;
    @track pageParam = null;
    @track sortParam = null;
    @track currencyCode;
    @track cartId;

    @api cartItemClone;
    @track cartItemOptions;
    @track cartItemAvailable;
    @api index;
    @api defaultData;
    @track lstOfDates = [];

    @api quickSaveData;
    @api listOfProductItems;
    @track isQuickSave = false;
    @track quickSaveProduct;
    @track currentCardItemProduct;
    @track quickSaveProductId;
    @api productInCart;
    @api mapOfCartIdAndProductId;
    
    @api cartItemLineItem = [];
    @api cartDeliveryGroup = [];
    @api effectiveAccountData;
    @track cartItemLineItemNew = [];
    @track cartDeliveryGroupNew = [];
    @track existingProductDetails;
    @api defaultIds;
    @api productIdToNewDeliveryGroups;
    @track productIdToNewDeliveryGroupsNew = {};
    @api pricebookEntries;
    @api getExistingProductDetail;
    mapToUpdate = {};
    errorLst = [];
    @track isNextDate = false;
  
    @track label = {
        Split_Shipment_Deliveries_Required,
        Split_Shipment_Delivery_End_Date,
        Split_Shipment_Delivery_Start_Date,
        Split_Shipment_Delivery_Text,
        Split_Shipment_Line_Item_Delivery_Date,
        Split_Shipment_Load_Volume,
        Split_Shipment_PO_Number,
        Split_Shipment_Select_Product,
        Split_Shipment_Shipping_Mode,
        Business_Unit_for_the_MLS_account,
        Business_Unit_MLS_Account_Validation
    };

    /*CSV file Variables*/
    @track isUploadCSV = false;
    @api csvFileCount;
    @track showLineItemsForFileUpload = false;
    @track isTonnage = true;
    @track errorString ='';
    @api timeZone;
    @track locale = 'en-US'; 

    /*Override Tonnage Limit*/
    @api lstOfShipTo;
    @api overrideTonnageLimit = false;

    /*Gallaon Limit */
    @api lstGallonUser;
    @track overrideGallonLimit = false;

    /*Plant Code Validation*/
    @track isPlantCode = false;
    @track plantDays;
    @track plantCodeDate = {isPlantCode:null,plantDays:null,notWeekend:null,sameDayOrder:null,}

    /*Carrier Input Field*/
    @track isCarrierField = false;

    /*Load Volume disable MLS User*/
    @track isloadVolumeDisable = false;
    @api getPriceBookProductsValue;
   
    get getTotalVolume() {
        let totalVolume = 0;
        if(this.listDeliveryLineItems) {
            for(let i of this.listDeliveryLineItems) {
                if(i.Quantity && i.Tonnage){
                    totalVolume+= parseFloat(parseInt(i.Quantity)*parseFloat(i.Tonnage));
                }
            }
        }
        return totalVolume.toFixed(3);
    }

    get getProducts() {
        return this.cartItemOptions;
    }

    get productname() {
        return this.mapOfProductIdVsName[this.ProductDetail.Product];
    }

    get isProduct(){
        return this.ProductDetail.Product;
    }

    get listlength(){
        return this.listDeliveryLineItems.length;
    }

    get getTonnage() {
        return [
            { label: 'Metric Ton', value: 'Metric Ton' },
            { label: 'Ton', value: 'Ton' }
        ];
    }

    get getShippingMode() {
        return [
            { label: 'Customer Pickup', value: '99' },
            { label: 'Truck', value: "25" },
            { label: 'Oversize Truck', value: "45"},
            { label: 'Rail', value: "95"}

        ];
    }


    get isMapBlank(){
        return Object.keys(this.mapToDisplayData).length == 0 ;
    }

    async getPermissionAssignedToUser(){ 
        await getPermissionAssignedToUser({ userId: Id})
        .then((result) => {
            if(result === true){
                this.isCarrierField = true;
            }else{
                console.log('Result is empty')
            }                  
        })
        .catch((error) => {
            this.error = error;
        });
    }

    getCartItems() {
        getCartItems({
            communityId: communityId,
            effectiveAccountId: this.effectiveAccountId,
            activeCartOrId: this.recordId,
            pageParam: this.pageParam,
            sortParam: this.sortParamb2bCartLineItems
        })
            .then(({ cartItems, cartSummary }) => {
                this.cartItems = cartItems;
                this.currencyCode = cartSummary.currencyIsoCode;
                this.cartId = cartSummary.cartId;

                this.cartItemOptions = cartItems.map(({ cartItem }) => {
                    return {
                        value: cartItem.cartItemId,
                        label: cartItem.name
                    }
                })

                this.cartItemAvailable = cartItems.map(({ cartItem }) => {
                    this.ProductDetail.productId = cartItem.productId;
                })
            })
            .catch((error) => {
                console.log('error : ' + error);
                this.cartItems = undefined;
            });
    }
    
    handleChange(event){
        let mapOfProductIdVsAvailableCopy = {...this.mapOfProductIdVsAvailable};

        if(this.currentProduct == null){
            this.ProductDetail.Product = event.target.value;
            this.currentProduct = event.target.value;
            mapOfProductIdVsAvailableCopy[event.target.value] = false;
                let customEvent = new CustomEvent('updateselectionmap',{detail : {mapOfProductIdVsAvailableCopy: mapOfProductIdVsAvailableCopy}});
                this.dispatchEvent(customEvent);
        }

        let name = event.target.name;
        let productDetail = this.ProductDetail;

        if(event.target.name == 'Product' && event.target.value != this.currentProduct){

            this.ProductDetail.Product = event.target.value;

            if(mapOfProductIdVsAvailableCopy[event.target.value]){
                getPONumber( { productId: this.mapOfCartIdAndProductId[this.ProductDetail.Product] })
                    .then((result) => {
                        this.ProductDetail.poNumber = result;
                    })
                    .catch((error) => {
                        this.error = error;
                    });
                    
                getProduct({ productId: this.mapOfCartIdAndProductId[this.ProductDetail.Product] })
                    .then((result) => {
                        this.ProductDetail.shippingType = result[0].Shipment_Size_Type_Label__c;
                        this.ProductDetail.shippingCondition = result[0].Shipping_Condition_Label__c;
                        this.ProductDetail.shippingMode = result[0].Ship__c;
                        this.ProductDetail.plantCode = result[0].Plant_code__c;
                        this.ProductDetail.productCode = result[0].ProductCode;
                        this.ProductDetail.validFrom = result[0].Valid_From__c;
                        this.ProductDetail.validTo = result[0].Valid_To__c;
                        this.ProductDetail.carrier = result[0].Carrier__c;
                        if(this.overrideGallonLimit === false){            
                        this.loadVolumeLabel = 'Load Volume per ' + this.ProductDetail.shippingType +' (Ton)';
                        }
                        else if(this.overrideGallonLimit === true){
                            this.loadVolumeLabel = 'Load Volume per ' + this.ProductDetail.shippingType +' (Gallon)';
                        }
                        this.existingProductDetails = result;
                        if(!isCarrierUser){
                            this.checkPlantCode();
                        }
                        if(this.effectiveAccountData[0].B2B_Business_Sub_Unit__c === Business_Unit_for_the_MLS_account){
                            this.isloadVolumeDisable = true;
                            this.ProductDetail.loadVolume = 22;
                        }
                    })
                    .catch((error) => {
                        this.error = error;
                    });
                    let activateButtonEvent = new CustomEvent('activatequicksavebutton');
                    this.dispatchEvent(activateButtonEvent);
            }else{

                event.target.value = this.currentProduct;
                this.showNotification('Product Already Selected!', 'error', 'ERROR');

            }
        }
        else if(event.target.name == 'Product') {
            this.ProductDetail.Product = event.target.value;
            getPONumber( { productId: this.mapOfCartIdAndProductId[this.ProductDetail.Product] })
                .then((result) => {
                    this.ProductDetail.poNumber = result;
                })
                .catch((error) => {
                    this.error = error;
                });
            getProduct({ productId: this.mapOfCartIdAndProductId[this.ProductDetail.Product] })
                .then((result) => {
                    this.ProductDetail.shippingType = result[0].Shipment_Size_Type_Label__c;
                    this.ProductDetail.shippingCondition = result[0].Shipping_Condition_Label__c;
                    this.ProductDetail.shippingMode = result[0].Ship__c;
                    this.ProductDetail.plantCode = result[0].Plant_code__c;
                    this.ProductDetail.productCode = result[0].ProductCode;
                    this.ProductDetail.validFrom = result[0].Valid_From__c;
                    this.ProductDetail.validTo = result[0].Valid_To__c;
                    this.ProductDetail.carrier = result[0].Carrier__c;

                    if(this.overrideGallonLimit === false){            
                        this.loadVolumeLabel = 'Load Volume per ' + this.ProductDetail.shippingType +' (Ton)';
                        }
                        else if(this.overrideGallonLimit === true){
                            this.loadVolumeLabel = 'Load Volume per ' + this.ProductDetail.shippingType +' (Gallon)';
                        }
                   // this.loadVolumeLabel = 'Load Volume per ' + this.ProductDetail.shippingType +' (Ton)';
                    this.existingProductDetails = result;
                    if(!isCarrierUser){
                        this.checkPlantCode();
                    }
                 
                    if(this.effectiveAccountData[0].B2B_Business_Sub_Unit__c === Business_Unit_for_the_MLS_account){
                        this.isloadVolumeDisable = true;
                        this.ProductDetail.loadVolume = 22;
                    }
                })
                .catch((error) => {
                    this.error = error;
                });
                let activateButtonEvent = new CustomEvent('activatequicksavebutton');
                this.dispatchEvent(activateButtonEvent);
        }

        if(event.target.name == 'shippingMode') {
            this.shippingMode = event.target.value;
            this.ProductDetail.shippingMode = event.target.value;

            if(this.ProductDetail.loadVolume) {
                let loadVolumeElement = this.template.querySelector(".loadVolume");
                this.ProductDetail.loadVolume = loadVolumeElement.value;

                this.handleLoadVolumeChange();    
            }
        }

        if(event.target.name == 'loadVolume') {
            let loadVolumeElement = this.template.querySelector(".loadVolume");
            this.ProductDetail.loadVolume = loadVolumeElement.value;

            this.handleLoadVolumeChange();
        }

        if(event.target.name == 'startDate'){
            let dateTime= new Date().toLocaleString(this.locale,{timeZone:this.timeZone});       
            let startDate = this.convertDate(event.target.value);
            startDate.setHours(0,0,0,0);
            //this.today = startDate.getFullYear()+'-' + (parseInt(startDate.getMonth())+ parseInt(1))+'-'+startDate.getDate();
            let today = new Date(dateTime);
            today.setHours(0,0,0,0);
            let nxtDay  = new Date(dateTime);
            nxtDay.setDate(nxtDay.getDate() + 1);
            nxtDay.setHours(0,0,0,0);

            let todayDate = new Date(this.today);
            todayDate.setHours(0,0,0,0);

            let quoteExpire = false;
            if((new Date(startDate).setHours(0,0,0,0) > new Date(this.ProductDetail.validTo).setHours(0,0,0,0))|| (new Date(startDate).setHours(0,0,0,0) < new Date(this.ProductDetail.validFrom).setHours(0,0,0,0))){
                let code = this.ProductDetail.productCode+this.ProductDetail.plantCode;
                if(this.getPriceBookProductsValue.hasOwnProperty(code)){
                    if(this.getPriceBookProductsValue[code] > 20){
                        quoteExpire = true;
                        let  message = 'Product quote is valid from '+(parseInt(new Date(this.ProductDetail.validFrom).getMonth())+ parseInt(1))+'/'+new Date(this.ProductDetail.validFrom).getDate()+'/'+new Date(this.ProductDetail.validFrom).getFullYear()+' to '+(parseInt(new Date(this.ProductDetail.validTo).getMonth())+ parseInt(1))+'/'+new Date(this.ProductDetail.validTo).getDate()+'/'+new Date(this.ProductDetail.validTo).getFullYear()+'. Please select valid quote for the order.'
                        this.template.querySelector('c-common-toast').showToast('warning', message,'',50000)
                        // const validQuotesWarning = new ShowToastEvent({
                        //     message:'Product quote is valid from '+(parseInt(new Date(this.ProductDetail.validFrom).getMonth())+ parseInt(1))+'/'+new Date(this.ProductDetail.validFrom).getDate()+'/'+new Date(this.ProductDetail.validFrom).getFullYear()+' to '+(parseInt(new Date(this.ProductDetail.validTo).getMonth())+ parseInt(1))+'/'+new Date(this.ProductDetail.validTo).getDate()+'/'+new Date(this.ProductDetail.validTo).getFullYear()+'. Please select valid quote for the order.',
                        //     variant: 'warning',
                        //     mode: 'sticky'
                        // });
                        // this.dispatchEvent(validQuotesWarning);
                        event.target.value = null;
                    }else{
                        this.template.querySelector('c-common-toast').closeModel();
                    }
                }
            }else{
                this.template.querySelector('c-common-toast').closeModel();
            }
            if(!quoteExpire){
                if(((startDate.getTime() < todayDate) || (startDate.getDay() === 6 || startDate.getDay() === 0)) && this.isPlantCode && (this.plantDays > 0) && this.notWeekend){
                    let message = Plant_Code_Validation_Product_Available+' '+Number(this.plantDays)+' '+Plant_Code_Business_Day_And_Weekend_Validation+' '+(parseInt(todayDate.getMonth())+ parseInt(1))+'/'+todayDate.getDate()+'/'+todayDate.getFullYear()+' '+Plant_Code_Validation_Customer_Service;
                    this.template.querySelector('c-common-toast').showToast('warning',message,'',50000);
                    // const businessDayValidation = new ShowToastEvent({
                    //     message:Plant_Code_Validation_Product_Available+' '+Number(this.plantDays)+' '+Plant_Code_Business_Day_And_Weekend_Validation+' '+(parseInt(todayDate.getMonth())+ parseInt(1))+'/'+todayDate.getDate()+'/'+todayDate.getFullYear()+' '+Plant_Code_Validation_Customer_Service,
                    //     variant: 'warning',
                    //     mode: 'sticky'
                    // });
                    // this.dispatchEvent(businessDayValidation);
                    event.target.value = null;
                }else{
                    this.template.querySelector('c-common-toast').closeModel();
                }
                
                if(this.isPlantCode && (this.plantDays === 0) && this.notWeekend){
                    let warningMsg = '';
                    if(startDate.getTime() == today.getTime()){
                        warningMsg = Same_Day_Delivery_Warning;
                        this.template.querySelector('c-common-toast').showToast('warning',warningMsg,'',50000)
                        event.target.value = null;
                    }
                    if((startDate.getDay() === 6 || startDate.getDay() === 0)){
                        warningMsg = Plant_Code_Weekend_Validation;
                        this.template.querySelector('c-common-toast').showToast('warning',warningMsg,'',50000)
                        event.target.value = null;
                    }
                }  

                if(this.isPlantCode && (this.plantDays > 0) && this.notWeekend === false){
                    if(startDate.getTime() < todayDate){
                        let message = Plant_Code_Validation_Product_Available+' '+Number(this.plantDays)+' '+Plant_Code_Business_Day_Validation+' '+(parseInt(todayDate.getMonth())+ parseInt(1))+'/'+todayDate.getDate()+'/'+todayDate.getFullYear()+' '+Plant_Code_Validation_Customer_Service;
                        this.template.querySelector('c-common-toast').showToast('warning', message,'',50000)
                        // const businessDayValidation = new ShowToastEvent({
                        //     message:Plant_Code_Validation_Product_Available+' '+Number(this.plantDays)+' '+Plant_Code_Business_Day_Validation+' '+(parseInt(todayDate.getMonth())+ parseInt(1))+'/'+todayDate.getDate()+'/'+todayDate.getFullYear()+' '+Plant_Code_Validation_Customer_Service,
                        //     variant: 'warning',
                        //     mode: 'sticky'
                        // });
                        // this.dispatchEvent(businessDayValidation);
                        event.target.value = null;
                    }
                }  

                if(startDate.getTime() == today.getTime() && !isCarrierUser && !this.isPlantCode) {
                    // const sameDayOrderWarning = new ShowToastEvent({
                    //     message: Same_Day_Delivery_Warning,
                    //     variant: 'warning',
                    //     mode: 'dismissable'
                    // });
                    // this.dispatchEvent(sameDayOrderWarning);
                    this.template.querySelector('c-common-toast').showToast('warning',Same_Day_Delivery_Warning,'',4000)
                    
                }
                else if(startDate.getTime() == nxtDay.getTime() && this.isNextDate && !this.isPlantCode) {
                    // const sameDayOrderWarning = new ShowToastEvent({
                    //     message: Next_Day_Order_Delivery_Warning,
                    //     variant: 'warning',
                    //     mode: 'sticky'
                    // });
                    // this.dispatchEvent(sameDayOrderWarning);
                    this.template.querySelector('c-common-toast').showToast('warning',Next_Day_Order_Delivery_Warning,'',4000)

                }
                else {   
                    let maxEndDate = this.addDays(event.target.value, 90);
                    this.maxEndDate = maxEndDate.getFullYear()+'-' + (parseInt(maxEndDate.getMonth())+ parseInt(1))+'-'+maxEndDate.getDate();
                }
            }
        }
        if(event.target.name == 'endDate'){
            let endDate = this.convertDate(event.target.value);
            endDate.setHours(0,0,0,0);
            if((new Date(endDate).setHours(0,0,0,0) > new Date(this.ProductDetail.validTo).setHours(0,0,0,0))|| (new Date(endDate).setHours(0,0,0,0) < new Date(this.ProductDetail.validFrom).setHours(0,0,0,0))){
                let code = this.ProductDetail.productCode+this.ProductDetail.plantCode;
                if(this.getPriceBookProductsValue.hasOwnProperty(code)){
                    if(this.getPriceBookProductsValue[code] > 20){
                        // const validQuotesWarning = new ShowToastEvent({
                        //     message:'Product quote is valid from '+(parseInt(new Date(this.ProductDetail.validFrom).getMonth())+ parseInt(1))+'/'+new Date(this.ProductDetail.validFrom).getDate()+'/'+new Date(this.ProductDetail.validFrom).getFullYear()+' to '+(parseInt(new Date(this.ProductDetail.validTo).getMonth())+ parseInt(1))+'/'+new Date(this.ProductDetail.validTo).getDate()+'/'+new Date(this.ProductDetail.validTo).getFullYear()+'. Please select valid quote for the order.',
                        //     variant: 'warning',
                        //     mode: 'sticky'
                        // });
                        // this.dispatchEvent(validQuotesWarning);
                        let message = 'Product quote is valid from '+(parseInt(new Date(this.ProductDetail.validFrom).getMonth())+ parseInt(1))+'/'+new Date(this.ProductDetail.validFrom).getDate()+'/'+new Date(this.ProductDetail.validFrom).getFullYear()+' to '+(parseInt(new Date(this.ProductDetail.validTo).getMonth())+ parseInt(1))+'/'+new Date(this.ProductDetail.validTo).getDate()+'/'+new Date(this.ProductDetail.validTo).getFullYear()+'. Please select valid quote for the order.';
                        this.template.querySelector('c-common-toast').showToast('warning', message,'',50000)
                        event.target.value = null;
                      
                    }
                }else{
                    this.template.querySelector('c-common-toast').closeModel();
                }
            }else{
                this.template.querySelector('c-common-toast').closeModel();
            }
        }
        productDetail[name] = event.target.value;
        this.ProductDetail = productDetail;
    }

    generateLoadVolumeLabel() {
        switch(this.ProductDetail.shippingMode) {
            case '99':
                this.loadVolumeLabel = "Load Volume per Customer Truck" +' (Ton)';
                break;
            case '25':
                this.loadVolumeLabel = "Load Volume per Truck (max 25)" +' (Ton)';
                break;
            case '45':
                this.loadVolumeLabel = "Load Volume per Oversize Truck (max 50)" +' (Ton)';
                break;
            case '95':
                this.loadVolumeLabel = "Load Volume per Rail Car (max 95)"+' (Ton)';
                break;
        }
    }

    handleLoadVolumeChange() {
        let loadVolumeElement = this.template.querySelector(".loadVolume");
        this.ProductDetail.loadVolume = loadVolumeElement.value;
        
        if(this.overrideTonnageLimit === false){
            switch(this.ProductDetail.shippingMode) {
                case '99':
                    if(loadVolumeElement.value > 50 && !this.overrideGallonLimit) {
                        loadVolumeElement.setCustomValidity("Customer PU - Truck Volume can't exceed 50");
                    } else if(loadVolumeElement.value <= 0 && !this.overrideGallonLimit) {
                        loadVolumeElement.setCustomValidity("Customer PU - Truck Volume must be greater than 0");
                    } else if(loadVolumeElement.value > 4500 && this.overrideGallonLimit){
                        loadVolumeElement.setCustomValidity("Customer PU - Truck Volume can't exceed 4500 gallons");
                    }else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '88':
                    if(loadVolumeElement.value > 4500 && this.overrideGallonLimit){
                        loadVolumeElement.setCustomValidity("Company owned truck Volume can't exceed 4500 gallons");
                    }else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '25':
                    if(loadVolumeElement.value > 25) {
                        loadVolumeElement.setCustomValidity("Truck Volume can't exceed 25");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Truck Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '50':
                    if(loadVolumeElement.value > 50) {
                        loadVolumeElement.setCustomValidity("Oversized Truck Volume can't exceed 50");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Oversized Truck Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '95':
                    if(loadVolumeElement.value > 95) {
                        loadVolumeElement.setCustomValidity("Rail Volume can't exceed 95");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Rail Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '36':
                    if(loadVolumeElement.value > 23) {
                        loadVolumeElement.setCustomValidity("Pneumatic Trailer Volume can't exceed 23");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Pneumatic Trailer Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '34':
                    if(loadVolumeElement.value > 23) {
                        loadVolumeElement.setCustomValidity("Van Trailer Volume can't exceed 23");
                    } else if(loadVolumeElement.value <= 17) {
                        loadVolumeElement.setCustomValidity("Van Trailer Volume must be greater than 18");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '33':
                    if(loadVolumeElement.value > 45) {
                        loadVolumeElement.setCustomValidity("Flat Bed Trailer Volume can't exceed 45");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Flat Bed Trailer Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '35':
                    if(loadVolumeElement.value > 23) {
                        loadVolumeElement.setCustomValidity("Pneu Trl/Hyd Lime Volume can't exceed 23");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Pneu Trl/Hyd Lime Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '37':
                    if(loadVolumeElement.value > 50) {
                        loadVolumeElement.setCustomValidity("Oversize TLR Dump Volume can't exceed 50");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Oversize TLR Dump Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '30':
                    if(loadVolumeElement.value > 23) {
                        loadVolumeElement.setCustomValidity("Dump Trailer Volume can't exceed 23");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Dump Trailer Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '38':
                    if(loadVolumeElement.value > 50) {
                        loadVolumeElement.setCustomValidity("Oversize TLR Pneu Volume can't exceed 50");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Oversize TLR Pneu Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '32':
                    if(loadVolumeElement.value > 50) {
                        loadVolumeElement.setCustomValidity("Multi TLR Pneu Volume can't exceed 50");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Multi TLR Pneu Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '55':
                    if(loadVolumeElement.value > 100) {
                        loadVolumeElement.setCustomValidity("Railcar Cvrd Hpr PVT Volume can't exceed 100");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Railcar Cvrd Hpr PVT Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '98':
                    if(loadVolumeElement.value > 100) {
                        loadVolumeElement.setCustomValidity("Customer PU - Rail Volume can't exceed 100");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Customer PU - Rail Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '51':
                    if(loadVolumeElement.value > 100) {
                        loadVolumeElement.setCustomValidity("Railcar Cvrd Hpr R/R Volume can't exceed 100");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Railcar Cvrd Hpr R/R Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '10':
                    if(loadVolumeElement.value > 1600) {
                        loadVolumeElement.setCustomValidity("Covered Rake Volume can't exceed 1600");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Covered Rake Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '11':
                    if(loadVolumeElement.value > 1600) {
                        loadVolumeElement.setCustomValidity("Covered Box Volume can't exceed 1600");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Covered Box Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '15':
                    if(loadVolumeElement.value > 1600) {
                        loadVolumeElement.setCustomValidity("Open Hopper Rake Volume can't exceed 1600");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Open Hopper Rake Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
                case '97':
                    if(loadVolumeElement.value > 1600) {
                        loadVolumeElement.setCustomValidity("Customer Barge Volume can't exceed 1600");
                    } else if(loadVolumeElement.value <= 0) {
                        loadVolumeElement.setCustomValidity("Customer Barge Volume must be greater than 0");
                    } else {
                        loadVolumeElement.setCustomValidity("");
                    }
                    loadVolumeElement.reportValidity();
                    break;
            }
        }
        return true;
    }

    handleProductChange(event) {
        this.ProductDetail.Product = event.target.value;
    }

    connectedCallback(){
        this.getShipToOverrideTonnageLimit();
        this.setMaxDate();
        this.getPermissionAssignedToUser();          
        let cardItemproduct = this.productInCart[this.index];
        if(Array.isArray(this.quickSaveData)){
            for(let item of this.quickSaveData){
                let product = JSON.parse(item).ProductDetail;
                if(cardItemproduct != undefined && cardItemproduct.value === product.Product){
                    this.quickSaveProduct = JSON.parse(item).ProductDetail;
                    this.isQuickSave = true;
                    this.currentCardItemProduct = JSON.parse(item);
                }
            }
            this.getProductDetails();
        }
        if(this.isQuickSave){
            this.handleGenerateLineItemsQuickSave();
            if(this.effectiveAccountData[0].B2B_Business_Sub_Unit__c === Business_Unit_for_the_MLS_account){
                this.isloadVolumeDisable = true;
                this.ProductDetail.loadVolume = 22;
            }
            let activateButtonEvent = new CustomEvent('activatequicksavebutton');
            this.dispatchEvent(activateButtonEvent);
        }else{
            let defaultObject = JSON.parse(this.defaultData);
            if(defaultObject.defaultShipmentType == "Truck"){
                this.ProductDetail.shippingMode = "25";
            }else if(defaultObject.defaultShipmentType == "Oversize Truck"){
                this.ProductDetail.shippingMode = "45";
            }else if(defaultObject.defaultShipmentType == "Rail"){
                this.ProductDetail.shippingMode = "95";
            }
            this.ProductDetail.loadVolume = defaultObject.defaultLoadVolume;
            this.ProductDetail.deliveryText = defaultObject.defaultDeliveryText;
            if(this.mapOfIndexVsProductDetail[this.index]) {
                //this.ProductDetail = {...this.mapOfIndexVsProductDetail[this.index].ProductDetail};
                this.listOfLineItem = {...this.mapOfIndexVsProductDetail[this.index].listOfLineItem}
            }
            this.cartItemOptions = JSON.parse(JSON.stringify(this.cartItemClone));
            this.ProductDetail.isFile = null;
        }
    }
    async getShipToOverrideTonnageLimit(){
        this.lstOfShipTo = await getShipToOverrideTonnageLimit();
        if(this.lstOfShipTo !== undefined){
            this.lstOfShipTo.forEach((shipTo) => {
                if(Number(shipTo.Ship_To__c) === Number(this.effectiveAccountData[0].AccountExternalNumber__c)){
                    this.overrideTonnageLimit = true; 
                }
            }) 
        }
        this.lstGallonUser = await getShipToOverrideGallonLimit();
        let lstOfShipTo = [];
        if(this.lstGallonUser !== undefined){
            this.lstGallonUser.forEach((shipTo) => {
                lstOfShipTo.push(Number(shipTo.ShipTo__c));  
            });   
        } 
         if(lstOfShipTo.length > 0 && lstOfShipTo.includes(Number(this.effectiveAccountData[0].AccountExternalNumber__c))){
            this.overrideGallonLimit = true; 
            this.loadVolumeLabel = 'Load Volume per ' + this.quickSaveProduct.shippingType +' (Gallon)';
         } else{
            this.loadVolumeLabel = 'Load Volume per ' + this.quickSaveProduct.shippingType +' (Ton)';
        }      

    }

    handleMeasureChange(event) {
        this.selectedMeasure = event.target.value;
    }

    handleselectedStartDateChange(event) {
        this.selectedStartDate = event.target.value;
        let maxEndDate = this.addDays(this.selectedStartDate, 90);
        this.maxEndDate = maxEndDate.getFullYear()+'-' + (parseInt(maxEndDate.getMonth())+ parseInt(1))+'-'+maxEndDate.getDate();
        this.fireEvent();
    }

    handleselectedEndDateChange(event){
        this.selectedEndDate = event.target.value;
        this.fireEvent();
    }

    handleNumberOfRecurrenceChange(event) {
        this.selectedNumberOfRecurring = event.target.value;
        this.fireEvent();
    }

    handleShippingModeChange(event) {
        this.selectedShippingMode = event.target.value;
        this.fireEvent();
    }

    handleQuantityChange(event) {
        this.selectedQuantity = event.target.value;
        this.fireEvent();
    }

    handlePoNumberChange(event) {
        this.enteredPoNumber = event.target.value;
        this.fireEvent();
    }

    handleDeliveryTextChange(event) {
        this.enteredDeliveryText = event.target.value;
        this.fireEvent();
    }

    handleDeliveryTextChangeOfLineItem(event){
        let index = event.target.name;
        let lineItemForThisIndex = {...this.listDeliveryLineItems[index]};
        lineItemForThisIndex.DeliveryText = event.target.value;
        this.listDeliveryLineItems[index] = lineItemForThisIndex;
            this.mapToUpdate = {...this.productIdToNewDeliveryGroups};
            let cartDeliveryList = [...this.mapToUpdate[this.mapOfCartIdAndProductId[lineItemForThisIndex.Product]]];
            let updateNewMap = {};
            var indexs = -1;
            var val = lineItemForThisIndex.CartItemId;
            for (let cdg of cartDeliveryList) {
                indexs++;
                if(cdg.CartItemId === val){
                    let cdg = {...cartDeliveryList[indexs]};
                    cdg.DeliveryText__c = lineItemForThisIndex.DeliveryText;
                    cdg.ShippingInstructions = lineItemForThisIndex.DeliveryText;
                    cartDeliveryList[indexs] = cdg;
                }
            }      
            updateNewMap[this.mapOfCartIdAndProductId[lineItemForThisIndex.Product]] = cartDeliveryList;
            this.dispatchEvent(new CustomEvent('updatedeliverydata',{detail:updateNewMap}));
    }

    handlePoNumberPerLineItemChange(event){
        let index = event.target.name;
        let lineItemForThisIndex = {...this.listDeliveryLineItems[index]};
        lineItemForThisIndex.PoNumber = event.target.value;
        this.listDeliveryLineItems[index] = lineItemForThisIndex;
        //this.fireEvent();
        if(lineItemForThisIndex.PoNumber !== undefined && lineItemForThisIndex.PoNumber !== '' && lineItemForThisIndex.PoNumber !== null){ 
            this.mapToUpdate = {...this.productIdToNewDeliveryGroups};
            let cartDeliveryList = [...this.mapToUpdate[this.mapOfCartIdAndProductId[lineItemForThisIndex.Product]]];
            let updateMap = {};
            var indexs = -1;
            var val = lineItemForThisIndex.CartItemId;
            for (let cdg of cartDeliveryList) {
                indexs++;
                if(cdg.CartItemId === val){
                    let cdg = {...cartDeliveryList[indexs]};
                    cdg.PONumber__c = lineItemForThisIndex.PoNumber;
                    cartDeliveryList[indexs] = cdg;
                }
            }
            updateMap[this.mapOfCartIdAndProductId[lineItemForThisIndex.Product]] = cartDeliveryList;
            let customEvent = new CustomEvent('updatedeliverydata',{detail:updateMap});
            this.dispatchEvent(customEvent);
        }   
    }   

    handleDeliveryDateChangeOfLineItem(event){
        let index = event.target.name;
        let lineItemForThisIndex = {...this.listDeliveryLineItems[index]};
        let previousDeliveryDate = lineItemForThisIndex.deliveryDate;
        let endDate = new Date((this.maxEndDate).split('-'));
        endDate.setHours(0,0,0,0);
        let startDate = new Date((event.target.value).split('-'));
        startDate.setHours(0,0,0,0);
        let today = new Date();
        today.setHours(0,0,0,0);
        let nxtDay  = new Date();
        nxtDay.setDate(nxtDay.getDate() + 1);
        nxtDay.setHours(0,0,0,0);
        let quoteExpire = false;
        if((new Date(startDate).setHours(0,0,0,0) > new Date(this.ProductDetail.validTo).setHours(0,0,0,0))|| (new Date(startDate).setHours(0,0,0,0) < new Date(this.ProductDetail.validFrom).setHours(0,0,0,0))){
            let code = this.ProductDetail.productCode+this.ProductDetail.plantCode;
            if(this.getPriceBookProductsValue.hasOwnProperty(code)){
                if(this.getPriceBookProductsValue[code] > 20){
                    quoteExpire = true;
                    // const validQuotesWarning = new ShowToastEvent({
                    //     message:'Product quote is valid from '+(parseInt(new Date(this.ProductDetail.validFrom).getMonth())+ parseInt(1))+'/'+new Date(this.ProductDetail.validFrom).getDate()+'/'+new Date(this.ProductDetail.validFrom).getFullYear()+' to '+(parseInt(new Date(this.ProductDetail.validTo).getMonth())+ parseInt(1))+'/'+new Date(this.ProductDetail.validTo).getDate()+'/'+new Date(this.ProductDetail.validTo).getFullYear()+'. Please select valid quote for the order.',
                    //     variant: 'warning',
                    //     mode: 'sticky'
                    // });
                    let message = 'Product quote is valid from '+(parseInt(new Date(this.ProductDetail.validFrom).getMonth())+ parseInt(1))+'/'+new Date(this.ProductDetail.validFrom).getDate()+'/'+new Date(this.ProductDetail.validFrom).getFullYear()+' to '+(parseInt(new Date(this.ProductDetail.validTo).getMonth())+ parseInt(1))+'/'+new Date(this.ProductDetail.validTo).getDate()+'/'+new Date(this.ProductDetail.validTo).getFullYear()+'. Please select valid quote for the order.';
                    this.template.querySelector('c-common-toast').showToast('warning', message,'',50000)
                    //this.dispatchEvent(validQuotesWarning);
                    event.target.value = null;
                }
            }
        }
        if(!quoteExpire){
            if(this.plantCodeDate.isPlantCode === true && this.plantCodeDate.plantDays > 0 && this.plantCodeDate.notWeekend === true){
                let today = new Date(this.today);
                if(startDate.getDay() === 6 || startDate.getDay() === 0){
                    // const weekEndDayValidation = new ShowToastEvent({
                    //     message : Plant_Code_Weekend_Validation,
                    //     variant: 'warning',
                    //     mode: 'sticky'
                    // });
                    // this.dispatchEvent(weekEndDayValidation);
                    this.template.querySelector('c-common-toast').showToast('warning',Plant_Code_Weekend_Validation,'',5000)
                    event.target.value = null;
                }else{          
                    this.template.querySelector('c-common-toast').closeModel();
                }
                if(startDate.setHours(0,0,0,0) < today.setHours(0,0,0,0)){
                    // const businessDayValidation = new ShowToastEvent({
                    //     message : Plant_Code_Validation_Product_Available+' '+this.plantCodeDate.plantDays+' '+Plant_Code_Business_Day_And_Weekend_Validation+' '+(parseInt(today.getMonth())+ parseInt(1))+'/'+today.getDate()+'/'+today.getFullYear()+' '+Plant_Code_Validation_Customer_Service,
                    //     variant: 'warning',
                    //     mode: 'sticky'
                    // });
                    let message = Plant_Code_Validation_Product_Available+' '+this.plantCodeDate.plantDays+' '+Plant_Code_Business_Day_And_Weekend_Validation+' '+(parseInt(today.getMonth())+ parseInt(1))+'/'+today.getDate()+'/'+today.getFullYear()+' '+Plant_Code_Validation_Customer_Service;
                    this.template.querySelector('c-common-toast').showToast('warning',message,'',50000)
                   // this.dispatchEvent(businessDayValidation);
                    event.target.value = null;
                }
            }else{
                this.template.querySelector('c-common-toast').closeModel();
            }
            if(this.plantCodeDate.isPlantCode === true && this.plantCodeDate.plantDays > 0 && this.plantCodeDate.notWeekend === false){
                let today = new Date(this.today);
                if(startDate.setHours(0,0,0,0) < today.setHours(0,0,0,0)){
                    // const businessDayValidation = new ShowToastEvent({
                    //     message : Plant_Code_Validation_Product_Available+' '+this.plantCodeDate.plantDays+' '+Plant_Code_Business_Day_Validation+' '+(parseInt(today.getMonth())+ parseInt(1))+'/'+today.getDate()+'/'+today.getFullYear()+' '+Plant_Code_Validation_Customer_Service,
                    //     variant: 'warning',
                    //     mode: 'sticky'
                    // });
                    // this.dispatchEvent(businessDayValidation);
                    let message = Plant_Code_Validation_Product_Available+' '+this.plantCodeDate.plantDays+' '+Plant_Code_Business_Day_Validation+' '+(parseInt(today.getMonth())+ parseInt(1))+'/'+today.getDate()+'/'+today.getFullYear()+' '+Plant_Code_Validation_Customer_Service;
                    this.template.querySelector('c-common-toast').showToast('warning',message,'',50000)
                    event.target.value = null;
                }
            }
            if(this.plantCodeDate.isPlantCode === true && this.plantCodeDate.plantDays === 0 && this.plantCodeDate.notWeekend === true){
                if(startDate.getDay() === 6 || startDate.getDay() === 0){
                    // const businessDayValidation = new ShowToastEvent({
                    //     message : Plant_Code_Weekend_Validation,
                    //     variant: 'warning',
                    //     mode: 'sticky'
                    // });
                    // this.dispatchEvent(businessDayValidation);
                    this.template.querySelector('c-common-toast').showToast('warning',Plant_Code_Weekend_Validation,'',50000)
                    event.target.value = null;
                }
            }        
            if(startDate.getTime() == today.getTime() && !isCarrierUser && !this.plantCodeDate.sameDayOrder) {
                // const sameDayOrderWarning = new ShowToastEvent({
                //     message: Same_Day_Delivery_Warning,
                //     variant: 'warning',
                //     mode: 'dismissable'
                // });
                // this.dispatchEvent(sameDayOrderWarning);
                this.template.querySelector('c-common-toast').showToast('warning',Same_Day_Delivery_Warning,'',50000)
                event.target.value = lineItemForThisIndex.deliveryDate;
            }      
            else if(startDate.getTime() > endDate.getTime() || startDate.getTime() < today.getTime()) {
                event.target.value = lineItemForThisIndex.deliveryDate;
            }else{
                if(previousDeliveryDate){
                    this.lstOfDates.splice(this.lstOfDates.indexOf(previousDeliveryDate));
                }
                lineItemForThisIndex.deliveryDate = event.target.value;
                let deliveryDate = this.addDays(event.target.value, 0);
                let deliveryDay = deliveryDate.getDay();
                switch(deliveryDay) {
                    case 0:
                        lineItemForThisIndex.deliveryDay = 'Sunday';
                        break;
                    case 1:
                        lineItemForThisIndex.deliveryDay = 'Monday';
                        break;
                    case 2:
                        lineItemForThisIndex.deliveryDay = 'Tuesday';
                        break;
                    case 3:
                        lineItemForThisIndex.deliveryDay = 'Wednesday';
                        break;
                    case 4:
                        lineItemForThisIndex.deliveryDay = 'Thursday';
                        break;
                    case 5:
                        lineItemForThisIndex.deliveryDay = 'Friday';
                        break;
                    case 6:
                        lineItemForThisIndex.deliveryDay = 'Saturday';
                        break;
                }
                this.lstOfDates.push(lineItemForThisIndex.deliveryDate);
                this.listDeliveryLineItems[index] = lineItemForThisIndex;
                let productIdToPricebookEntry = {};
                for (let i=0;i< this.pricebookEntries.length;i++) {
                    let pricebook = {...this.pricebookEntries[i]};
                    let validData = {};
                    if(pricebook.ValidTo__c != undefined && pricebook.ValidFrom__c != undefined){
                        validData.ValidTo = new Date(pricebook.ValidTo__c).getFullYear()+'-'+ ((new Date(pricebook.ValidTo__c).getMonth())+1)+'-'+new Date(pricebook.ValidTo__c).getDate();
                        validData.ValidFrom = new Date(pricebook.ValidFrom__c).getFullYear()+'-'+((new Date(pricebook.ValidFrom__c).getMonth())+1)+'-'+new Date(pricebook.ValidFrom__c).getDate();
                        validData.QuoteNumber = pricebook.Quote_Number__c;
                        if(productIdToPricebookEntry.hasOwnProperty(pricebook.Product2Id)){
                            let priceBookEntry = productIdToPricebookEntry[pricebook.Product2Id];
                            priceBookEntry.push(validData);
                            productIdToPricebookEntry[pricebook.Product2Id] = priceBookEntry;
                        }else{ 
                            let priceBookEntry =[];
                            priceBookEntry.push(validData);
                            productIdToPricebookEntry[pricebook.Product2Id] = priceBookEntry;
                        }
                    }                
                }
                this.mapToUpdate = {...this.productIdToNewDeliveryGroups};
                let cartDeliveryList = [...this.mapToUpdate[this.mapOfCartIdAndProductId[lineItemForThisIndex.Product]]];
                var indexs = -1;
                let updateMap = {};
                var val = lineItemForThisIndex.CartItemId;
                let dateTime= new Date().toLocaleString(this.locale,{timeZone:this.timeZone}); 
                let nxtDay  = new Date(dateTime);
                nxtDay.setDate(nxtDay.getDate() + 1);
                nxtDay.setHours(0,0,0,0);
                for (let cdg of cartDeliveryList) {
                    indexs++;
                    if(cdg.CartItemId === val){
                        let cdg = {...cartDeliveryList[indexs]};
                        cdg.DesiredDeliveryDate = lineItemForThisIndex.deliveryDate;
                            if(productIdToPricebookEntry.hasOwnProperty(this.mapOfCartIdAndProductId[this.ProductDetail.Product])){
                                let priceBookEntry = productIdToPricebookEntry[this.mapOfCartIdAndProductId[this.ProductDetail.Product]];
                                for (let i=0;i< priceBookEntry.length;i++) {
                                    let data = priceBookEntry[i];
                                    if(new Date(cdg.DesiredDeliveryDate) <= new Date(data.ValidTo) && new Date(cdg.DesiredDeliveryDate) >= new Date(data.ValidFrom)) {
                                        cdg.Quote_Number__c = data.QuoteNumber;
                                    }
                                    let dates = new Date(cdg.DesiredDeliveryDate);
                                    dates.setHours(0,0,0,0);
                                    if(dates.getTime() == nxtDay.getTime() && !isCarrierUser){
                                        cdg.Next_Day_Order__c = true;
                                    }else{
                                        cdg.Next_Day_Order__c = false;
                                    }                                
                                } 
                            }  
                            cartDeliveryList[indexs] = cdg;
                        }
                    }
                    updateMap[this.mapOfCartIdAndProductId[lineItemForThisIndex.Product]] = cartDeliveryList;
                    let customEvent = new CustomEvent('updatedeliverydata',{detail:updateMap});
                    this.dispatchEvent(customEvent);
            }
        }
    }

    handleGenerateLineItems(event) {
        try{
            let isValid = this.validityCheck();
            let enddate ;
            if(isValid) {
                this.showLineItems = false;
                this.listDeliveryLineItems = [];
                if(this.ProductDetail.endDate){
                    enddate = this.ProductDetail.endDate;
                }else{
                    enddate = this.ProductDetail.startDate;
                }              
                
                let date2 = this.convertDate(enddate);
                let date1 = this.convertDate(this.ProductDetail.startDate);
                var Difference_In_Time = date2.getTime() - date1.getTime();
                var Difference_In_Days = (parseInt(Difference_In_Time / (1000 * 3600 * 24)) + parseInt(1));
                let numberOfRecursion = parseInt(Difference_In_Days);
                for(let i=0; i<numberOfRecursion; i++) {
                    let structure = {...this.structureForTableRow};
                    structure.Product = this.ProductDetail.Product;
                    let deliveryDate = this.addDays(this.ProductDetail.startDate, i);
                    let deliveryDay = deliveryDate.getDay();
                    structure.deliveryDate = deliveryDate.getFullYear()+'-' + (parseInt(deliveryDate.getMonth())+ parseInt(1))+'-'+deliveryDate.getDate();
                    if(!this.notWeekend){
                        switch(deliveryDay) {
                            case 0:
                                structure.deliveryDay = 'Sunday';
                                break;
                            case 1:
                                structure.deliveryDay = 'Monday';
                                break;
                            case 2:
                                structure.deliveryDay = 'Tuesday';
                                break;
                            case 3:
                                structure.deliveryDay = 'Wednesday';
                                break;
                            case 4:
                                structure.deliveryDay = 'Thursday';
                                break;
                            case 5:
                                structure.deliveryDay = 'Friday';
                                break;
                            case 6:
                                structure.deliveryDay = 'Saturday';
                                break;
                        }
                    }else if(this.notWeekend){
                        if(deliveryDay !== 0 && deliveryDay !== 6){
                            switch(deliveryDay) {
                                case 0:
                                    structure.deliveryDay = 'Sunday';
                                    break;
                                case 1:
                                    structure.deliveryDay = 'Monday';
                                    break;
                                case 2:
                                    structure.deliveryDay = 'Tuesday';
                                    break;
                                case 3:
                                    structure.deliveryDay = 'Wednesday';
                                    break;
                                case 4:
                                    structure.deliveryDay = 'Thursday';
                                    break;
                                case 5:
                                    structure.deliveryDay = 'Friday';
                                    break;
                                case 6:
                                    structure.deliveryDay = 'Saturday';
                                    break;
                            }
                        }                     
                    }
                    structure.Quantity = this.ProductDetail.quantity;
                    structure.Tonnage = this.ProductDetail.loadVolume;
                    structure.DeliveryText = this.ProductDetail.deliveryText;
                    structure.PoNumber = this.ProductDetail.poNumber;
                    structure.index = i;
                    let structureToCompare = Object.assign({}, structure);
                    structureToCompare.deliveryDate = deliveryDate.getFullYear()+'-' + this.addZeroInMonthDays(parseInt(deliveryDate.getMonth()) + parseInt(1))+'-'+this.addZeroInMonthDays(deliveryDate.getDate());
                    structure.deliveryDate = structureToCompare.deliveryDate;                                    
                    structure.CartItemId = String(Math.random()).substring(2);
                    if(this.notWeekend && deliveryDay !== 0 && deliveryDay !== 6){
                        this.lstOfDates.push(structureToCompare.deliveryDate);
                        this.listDeliveryLineItems.push(structure);
                        this.cartItemLineItemNew.push(structure);
                    }
                    if(!this.notWeekend){
                        this.lstOfDates.push(structureToCompare.deliveryDate);
                        this.listDeliveryLineItems.push(structure);
                        this.cartItemLineItemNew.push(structure);
                    }            
                }
                let mapProductIsGeneated = {...this.productIdToNewDeliveryGroups};
                if(mapProductIsGeneated.hasOwnProperty(this.mapOfCartIdAndProductId[this.ProductDetail.Product])){
                    this.cartDeliveryGroupNew = [];
                    let customEvent = new CustomEvent('deleteandupdatedeliverydata',{detail:this.mapOfCartIdAndProductId[this.ProductDetail.Product]});
                    this.dispatchEvent(customEvent);
                }
                this.generateCartDeliveryGrpToSave();
                this.showLineItems = true;
                this.fireEvent();
                if(this.lineItemsGenerated != true) {
                    this.lineItemsGenerated = true;
                    let customEvent = new CustomEvent('updatesubmitbutton');
                    this.dispatchEvent(customEvent);

                    // Activate add products button
                    let activateButtonEvent = new CustomEvent('activateaddproductsbutton');
                    this.dispatchEvent(activateButtonEvent);
                }
            }
        }catch(err){
            console.log('eror', err);
        }
    }

    addZeroInMonthDays(dataToChange){

        if(dataToChange && dataToChange.toString().length == 1){
            dataToChange = '0' + dataToChange ;
        }
        return dataToChange;
    }

    handleDeleteProduct() {
        let customEvent = new CustomEvent('deleteproduct',{detail : {index : this.index}});
        this.dispatchEvent(customEvent);
        this.ProductDetail.isFile = null;
    }

    fireEvent(){
        let customEvent = new CustomEvent('updateproductdetails',{detail : {Product:{ProductDetail: this.ProductDetail,
                                                                                    listOfLineItem : this.listDeliveryLineItems},
                                                                            index : this.index}});
            this.dispatchEvent(customEvent);
    }

    addLineItems(){
        this.cdgAddLineItem = [];
        this.cdgItemLineItem = [];
        
        this.showLineItems = false;
        let structure = {...this.structureForTableRow};
        structure.Product = this.ProductDetail.Product;
        structure.Quantity = 1;
        if(!this.showLineItemsForFileUpload){
            structure.Tonnage = this.ProductDetail.loadVolume;
        }else{
            structure.Tonnage = '';
        }
        structure.DeliveryText = this.enteredDeliveryText;
        structure.PoNumber = this.enteredPoNumber;
        structure.index = this.listDeliveryLineItems.length;
        structure.CartItemId = String(Math.random()).substring(2);

        this.listDeliveryLineItems.push(structure);
        if(!this.showLineItemsForFileUpload){
            this.showLineItems = true;
        }else{
            this.isTonnage = false;
        }
        this.cdgItemLineItem.push(structure);        
        let cdg = {
            sobjectType : 'CartDeliveryGroup',
            CartId : this.recordId,
            CartItemId : structure.CartItemId,
            Quantity__c : 1,
            DeliveryText__c : '',
            ShippingInstructions : '',
            ShipmentTonnage__c : parseFloat(structure.Tonnage),
            PONumber__c : '',
            Shipment_Size__c : parseFloat(structure.Tonnage),
            DesiredDeliveryDate : '',
            AccountExternalNumber__c : this.effectiveAccountData[0].AccountExternalNumber__c,
            IsHold__c : this.effectiveAccountData[0].IsHold__c,
            MaterialNumber__c : this.existingProductDetails[0].MaterialNumber__c,
            Material_Number_SF__c : this.existingProductDetails[0].MaterialNumber__c,
            Shipping_Condition__c : this.existingProductDetails[0].Shipping_Condition__c,
            Name : 'Delivery for '+this.existingProductDetails[0].Name,
            ShipmentSizeType__c : this.ProductDetail.shippingMode,
            ShippingAddress__c : this.defaultIds['Shipping'],
            BillingAddress__c : this.defaultIds['Billing'],
            DeliveryMethodId : this.defaultIds['OrderDeliveryMethod']
        }
        let updatedCDG = [];
        this.cdgAddLineItem.push(cdg);
        let updateMap = {};
        this.mapProductIdcdg = {...this.productIdToNewDeliveryGroups}
        updatedCDG = this.mapProductIdcdg[this.mapOfCartIdAndProductId[this.ProductDetail.Product]];
        updatedCDG = updatedCDG.concat(this.cdgAddLineItem);
        updateMap[this.mapOfCartIdAndProductId[this.ProductDetail.Product]] = updatedCDG;
        updateMap[this.mapOfCartIdAndProductId[this.ProductDetail.Product]] = updatedCDG;
        let customEvent = new CustomEvent('updatedeliverydata',{detail:updateMap}); 
         this.dispatchEvent(customEvent);       
    }

    validityCheck(){
        let validity;
            let elements = Array.from(this.template.querySelectorAll('[data-id =checkValidity]'));
                if(elements!= undefined && elements!=null) {
                    validity =  elements.reduce((validSoFar,inputcmp) => {
                        inputcmp.reportValidity();
                        return validSoFar && inputcmp.checkValidity();
                    },true );
                }
        return validity;
    }

    validityLineItemCheck(){
        let validity;
        let validityDeliveryLineItem;
        // let validitytonnage;
            let elements = Array.from(this.template.querySelectorAll('[data-id =checkLineItemValidity]'));
                if(elements!= undefined &&
                    elements!=null) {
                    validity =  elements.reduce((validSoFar,inputcmp) => {
                        inputcmp.reportValidity();
                        return validSoFar && inputcmp.checkValidity();
                    },true );
                }
            let deliveryDateelements = Array.from(this.template.querySelectorAll('[data-validity =checkDeliveryDateValidity]'));
            if(deliveryDateelements!= undefined &&
                deliveryDateelements!=null) {
                    validityDeliveryLineItem =  deliveryDateelements.reduce((validSoFar,inputcmp) => {
                    if(!inputcmp.value){
                        return validSoFar && false;
                    }else{
                        return validSoFar && true
                    }
                },true );
            }            
        return validity && validityDeliveryLineItem;
    }


    @api
    combinedValidityCheck(){
        return this.validityCheck() && this.validityLineItemCheck();
    }

    convertDate(dateString) {
        let dateSplit = dateString.split('-');

        let dateObject = {
            year: parseInt(dateSplit[0]),
            month: parseInt(dateSplit[1]) - 1,
            day: parseInt(dateSplit[2])
        };

        return new Date(dateObject.year, dateObject.month, dateObject.day);
    }

    addDays(date, days) {
        var result = this.convertDate(date);
        result.setDate(result.getDate() + days);
        return result;
    }


    handleLineItemQuantityChange(event) {
        this.showLineItems = false;
        let selectedQuantity = event.target.value;
        let index = event.target.name;
        let lineItemForThisIndex = {...this.listDeliveryLineItems[index]};
        lineItemForThisIndex.Tonnage = this.ProductDetail.loadVolume ;
        lineItemForThisIndex.Quantity = selectedQuantity;
        this.listDeliveryLineItems[index] = lineItemForThisIndex; 
        this.showLineItems = true;
        //this.fireEvent();
        if(selectedQuantity !== 0 && selectedQuantity !== '0' && selectedQuantity !== undefined && selectedQuantity !== '' && selectedQuantity !== null){ 
            let mapToUpdate = {...this.productIdToNewDeliveryGroups};
            let cartDeliveryList =  JSON.parse(JSON.stringify([...mapToUpdate[this.mapOfCartIdAndProductId[lineItemForThisIndex.Product]]]));
            var indexs = -1;
            let updateMap = {};
            var val = lineItemForThisIndex.CartItemId;
            let removeValFromIndex = []          
            for (let cdg of cartDeliveryList) {
                indexs++;
                if(cdg.CartItemId === val){
                    removeValFromIndex.push(indexs)
                }
            }
            let updatedCartDeliveryList =[]
            for (var i = removeValFromIndex.length -1; i >= 0; i--){
                updatedCartDeliveryList.push(cartDeliveryList[removeValFromIndex[i]]);
                cartDeliveryList.splice(removeValFromIndex[i],1);               
            }
            if(updatedCartDeliveryList.length !== selectedQuantity){ 
                let cdg = updatedCartDeliveryList[0];
                for(var i = 0 ;i< selectedQuantity; i++){ 
                    cartDeliveryList.push(cdg);
                }
            }
            let key = this.mapOfCartIdAndProductId[lineItemForThisIndex.Product];
            updateMap[key] = cartDeliveryList;
            let customEvent = new CustomEvent('updatedeliverydata',{detail:updateMap});  
            this.dispatchEvent(customEvent);
        }            
    }

    deleteLineItem(event){
        this.showLineItems = false;
        let index = event.target.name;
        let noDateData = false;
        let structureToCompare = {...this.listDeliveryLineItems[index]};

        let dataToDelete = structureToCompare.deliveryDate;
        if(dataToDelete){
            let splitData = dataToDelete.split('-');
            structureToCompare.deliveryDate = splitData[0]+'-' + this.addZeroInMonthDays(splitData[1]) +'-'+ this.addZeroInMonthDays(splitData[2]);
            if(this.lstOfDates.includes(structureToCompare.deliveryDate)){
                this.lstOfDates.splice(this.lstOfDates.indexOf(structureToCompare.deliveryDate),1);
            }
        }else{
           if(!structureToCompare.deliveryDate){
                noDateData = true;
           } 
        }
        this.listDeliveryLineItems.splice(index, 1);
        if(!this.showLineItemsForFileUpload){
            this.showLineItems = true;
        }
        if(dataToDelete || noDateData){  
            let keys = this.mapOfCartIdAndProductId[structureToCompare.Product];
            let CartItemId =  structureToCompare.CartItemId;
            let data = {'product':keys,'CartItemId':CartItemId};
            this.dispatchEvent(new CustomEvent('deletelineitems',{detail:data}));
            let rowsCount = {...this.csvFileCount}
            let countRows =  rowsCount[structureToCompare.Product];
            rowsCount[structureToCompare.Product]=countRows-structureToCompare.Quantity;
            let uploadFileSize = new CustomEvent('csvsize',{detail:rowsCount});
            this.dispatchEvent(uploadFileSize);
        }    
    }

    @api
    showNotification(message, variant, title) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleGenerateLineItemsQuickSave(){
        try{           
            let mapOfProductIdVsAvailableCopy = {...this.mapOfProductIdVsAvailable};
            let defaultObject = this.quickSaveProduct;
            this.ProductDetail.loadVolume = defaultObject.loadVolume;
            this.ProductDetail.poNumber = defaultObject.poNumber;
            this.enteredPoNumber =defaultObject.poNumber;
            this.ProductDetail.deliveryText = defaultObject.DeliveryText;
            this.enteredDeliveryText = defaultObject.DeliveryText;
            this.ProductDetail.endDate = defaultObject.endDate;
            this.ProductDetail.quantity = defaultObject.quantity;
            this.ProductDetail.shippingMode = defaultObject.shippingMode.toString();
            this.ProductDetail.shippingType = defaultObject.shippingType,
            this.ProductDetail.shippingCondition = defaultObject.shippingCondition,
            this.ProductDetail.startDate = defaultObject.startDate;
            this.ProductDetail.isFile = defaultObject.isFile;
            this.ProductDetail.plantCode = defaultObject.plantCode;
            this.ProductDetail.validFrom = defaultObject.validFrom;
            this.ProductDetail.validTo = defaultObject.validTo;
            this.ProductDetail.productCode = defaultObject.productCode;
            if(this.ProductDetail.isFile !== null && this.ProductDetail.isFile === true){
                this.isTonnage = false;
            }          
            this.cartItemOptions = JSON.parse(JSON.stringify(this.cartItemClone));
            let cartItems = JSON.parse(JSON.stringify(this.cartItemClone));
            for(let cartItem of cartItems) {
                if(cartItem.value === defaultObject.Product){
                    this.ProductDetail.Product = cartItem.value;
                    this.quickSaveProductId = cartItem.value;
                    this.currentProduct = cartItem.value;
                    mapOfProductIdVsAvailableCopy[cartItem.value] = false;
                    let customEvent = new CustomEvent('updateselectionmap',{detail : {mapOfProductIdVsAvailableCopy: mapOfProductIdVsAvailableCopy}});
                    this.dispatchEvent(customEvent);
                }
            }
            let maxEndDate = this.addDays(this.ProductDetail.startDate, 90);
            this.maxEndDate = maxEndDate.getFullYear() + "-" + (parseInt(maxEndDate.getMonth()) + parseInt(1)) + "-" + maxEndDate.getDate();
            let isValid = this.validityCheck();
            if(isValid) {
                let listOfLineItem = this.currentCardItemProduct.listOfLineItem;
                this.listDeliveryLineItems = listOfLineItem;
                this.generateCartDeliveryGrpToSave();
                for(let structureToCompare of this.listDeliveryLineItems) {
                    this.lstOfDates.push(structureToCompare.deliveryDate);
                }    
                let maxEndDate = this.addDays(this.ProductDetail.startDate, 90);
                this.maxEndDate = maxEndDate.getFullYear() + "-" + (parseInt(maxEndDate.getMonth()) + parseInt(1)) + "-" + maxEndDate.getDate();
                this.showLineItems = true;
                this.fireEvent();
                this.lineItemsGenerated = false;             
                if(this.lineItemsGenerated != true) {
                    this.lineItemsGenerated = true;
                    let customEvent = new CustomEvent('updatesubmitbutton');
                    this.dispatchEvent(customEvent);
                    //Add Product 
                    if( this.productInCart.length !== 1 && this.cartItemOptions.length !== 1){
                        let addProductOnCardEvt = new CustomEvent('addproductoncard');
                        this.dispatchEvent(addProductOnCardEvt);
                    }                    
               }
            }
            if(!isCarrierUser){
                this.checkPlantCode();
            }
        }
        catch(err){
            console.log(err);
        }
    }

    getProductDetails(){ 
        getProduct({ productId: this.mapOfCartIdAndProductId[this.quickSaveData.Product] })
        .then((result) => {
            this.ProductDetail.shippingType = result[0].Shipment_Size_Type_Label__c;
            this.ProductDetail.shippingCondition = result[0].Shipping_Condition_Label__c;
            this.ProductDetail.shippingMode = result[0].Ship__c;
            this.loadVolumeLabel = 'Load Volume per ' + this.ProductDetail.shippingType +' (Ton)';
            this.existingProductDetails = result;
        })
        .catch((error) => {
            this.error = error;
        });
    }

    generateCartDeliveryGrpToSave(){ 
        let productIdToPricebookEntry = {};  
        this.cartDeliveryGroupNew = [];    
        for (let i=0;i< this.pricebookEntries.length;i++) {
            let pricebook = {...this.pricebookEntries[i]};
            let validData = {};
            if(pricebook.ValidTo__c != undefined && pricebook.ValidFrom__c != undefined){
                validData.ValidTo = new Date(pricebook.ValidTo__c).getFullYear()+'-'+ ((new Date(pricebook.ValidTo__c).getMonth())+1)+'-'+new Date(pricebook.ValidTo__c).getDate();
                validData.ValidFrom = new Date(pricebook.ValidFrom__c).getFullYear()+'-'+((new Date(pricebook.ValidFrom__c).getMonth())+1)+'-'+new Date(pricebook.ValidFrom__c).getDate();
                validData.QuoteNumber = pricebook.Quote_Number__c;
                if(productIdToPricebookEntry.hasOwnProperty(pricebook.Product2Id)){
                    let priceBookEntry = productIdToPricebookEntry[pricebook.Product2Id];
                    priceBookEntry.push(validData);
                    productIdToPricebookEntry[pricebook.Product2Id] = priceBookEntry;
                }else{ 
                    let priceBookEntry =[];
                    priceBookEntry.push(validData);
                    productIdToPricebookEntry[pricebook.Product2Id] = priceBookEntry;
                }
            }                
        }
        this.existingProductDetails = [];
        for(var data of this.getExistingProductDetail){  
            if(this.isQuickSave === true){ 
                if(data.Id === this.mapOfCartIdAndProductId[this.quickSaveProductId]){ 
                    this.existingProductDetails.push(data);
                }
            }else{
                if(data.Id === this.mapOfCartIdAndProductId[this.currentProduct]){ 
                    this.existingProductDetails.push(data);
                }
            } 
        }
        let dateTime= new Date().toLocaleString(this.locale,{timeZone:this.timeZone});
        let nxtDay  = new Date(dateTime);
        nxtDay.setDate(nxtDay.getDate() + 1);
        nxtDay.setHours(0,0,0,0);
        if(this.listDeliveryLineItems.length > 0){
            for(let cartItem of this.listDeliveryLineItems) {
                for(let i = 0 ;i < cartItem.Quantity ; i++){
                    let cdg = {};
                    cdg.sobjectType = 'CartDeliveryGroup';
                    cdg.CartId = this.recordId;
                    cdg.CartItemId = cartItem.CartItemId;
                    cdg.Quantity__c = 1;
                    cdg.DeliveryText__c = cartItem.DeliveryText;
                    cdg.ShippingInstructions = cartItem.DeliveryText;
                    cdg.ShipmentTonnage__c = parseFloat(cartItem.Tonnage);
                    cdg.PONumber__c = cartItem.PoNumber;
                    cdg.Shipment_Size__c =  parseFloat(cartItem.Tonnage);
                    cdg.DesiredDeliveryDate = cartItem.deliveryDate;
                    let dates = new Date(cartItem.deliveryDate);
                    dates.setHours(0,0,0,0);
                    if(dates.getTime() == nxtDay.getTime() && !isCarrierUser && !this.sameDayOrder){
                        cdg.Next_Day_Order__c = true;
                    }
                    cdg.AccountExternalNumber__c = this.effectiveAccountData[0].AccountExternalNumber__c;
                    cdg.IsHold__c = this.effectiveAccountData[0].IsHold__c;
                    cdg.MaterialNumber__c = this.existingProductDetails[0].MaterialNumber__c;
                    cdg.Material_Number_SF__c = this.existingProductDetails[0].MaterialNumber__c;
                    cdg.Shipping_Condition__c = this.existingProductDetails[0].Shipping_Condition__c;
                    cdg.Name = 'Delivery for '+this.existingProductDetails[0].Name;
                    cdg.ShipmentSizeType__c = this.ProductDetail.shippingMode;
                    cdg.ShippingAddress__c = this.defaultIds['Shipping'];
                    cdg.BillingAddress__c = this.defaultIds['Billing'];
                    cdg.DeliveryMethodId = this.defaultIds['OrderDeliveryMethod'];
                    if(productIdToPricebookEntry.hasOwnProperty(this.mapOfCartIdAndProductId[this.ProductDetail.Product])){
                        let priceBookEntry = productIdToPricebookEntry[this.mapOfCartIdAndProductId[this.ProductDetail.Product]];
                        for (let i=0;i< priceBookEntry.length;i++) {
                            let data = priceBookEntry[i];
                            if(new Date(cartItem.deliveryDate) <= new Date(data.ValidTo) && new Date(cartItem.deliveryDate) >= new Date(data.ValidFrom)) {
                                cdg.Quote_Number__c = data.QuoteNumber;
                            }
                        } 
                    }           
                    this.cartDeliveryGroupNew.push(cdg);
                }
            }
        }
        let mapToUpdate = {...this.productIdToNewDeliveryGroups};
        mapToUpdate[this.mapOfCartIdAndProductId[this.ProductDetail.Product]] = this.cartDeliveryGroupNew;
        let customEvent = new CustomEvent('updatedeliverydata',{detail:mapToUpdate});
        this.dispatchEvent(customEvent);
        if(this.isQuickSave){
            let csvRowCount = {};
            csvRowCount[this.ProductDetail.Product] = this.cartDeliveryGroupNew.length;
            let uploadFileSize = new CustomEvent('csvsize',{detail:csvRowCount});
            this.dispatchEvent(uploadFileSize);
        }
    }

    async handleUploadCSVFile(){
        this.errorLst = [];
        let mapProductIsGeneated = {...this.productIdToNewDeliveryGroups};
        if(this.currentProduct !== undefined){
            if(this.showLineItems){
                let overloadLineItems  = await LightningConfirm.open({
                    message: "Uploading a new File will overwrite any existing line items. Do you want to continue?",
                    theme:"warning",
                    label:"Warning"
                });
                if (overloadLineItems == true) {
                    if(mapProductIsGeneated.hasOwnProperty(this.mapOfCartIdAndProductId[this.ProductDetail.Product])){
                        let customEvent = new CustomEvent('deleteandupdatedeliverydata',{detail:this.mapOfCartIdAndProductId[this.ProductDetail.Product]});
                        this.dispatchEvent(customEvent); 
                        
                        this.showLineItemsForFileUpload = false;
                        let rowsCount = {};
                        rowsCount[this.ProductDetail.Product]=0;
                        let uploadFileSize = new CustomEvent('csvsize',{detail:rowsCount});
                        this.dispatchEvent(uploadFileSize);
                    }
                    this.showLineItems = false;
                    this.isUploadCSV=true;
                }
            }else{
                if(!this.showLineItems && mapProductIsGeneated.hasOwnProperty(this.mapOfCartIdAndProductId[this.ProductDetail.Product])){
                    let overloadLineItems  = await LightningConfirm.open({
                        message: "Uploading a new File will overwrite any existing line items. Do you want to continue?",
                        theme:"warning",
                        label:"Warning "
                    });
                    if (overloadLineItems == true) {
                        if(mapProductIsGeneated.hasOwnProperty(this.mapOfCartIdAndProductId[this.ProductDetail.Product])){
                            let customEvent = new CustomEvent('deleteandupdatedeliverydata',{detail:this.mapOfCartIdAndProductId[this.ProductDetail.Product]});
                            this.dispatchEvent(customEvent);
                            this.showLineItemsForFileUpload = false;
                            let rowsCount = {};
                            rowsCount[this.ProductDetail.Product]=0;
                            let uploadFileSize = new CustomEvent('csvsize',{detail:rowsCount});
                            this.dispatchEvent(uploadFileSize);
                        }
                        this.showLineItems = false;
                        this.isUploadCSV=true;
                    }
                }else{
                    this.isUploadCSV=true;
                }
            } 
        }else{
            this.dispatchEvent(new ShowToastEvent({
                message:'Please select product',
                variant: 'error',
                mode: 'dismissable'
            }));            
            return;
        }      
    }

    handleModalCancel(){
        this.isUploadCSV = false;
    }

    handleCancelOnLimit(){
        this.errorLst = [];
        this.isUploadCSV = false;
        setTimeout(() => {
            this.showLineItems = false;
            this.isUploadCSV=true;
        },0.0001);        
    }

    handleCancelDataError(event){
        this.errorLst =  JSON.parse(JSON.stringify(event.detail));
        this.isUploadCSV = false;
        setTimeout(() => {
            this.showLineItems = false;
            this.isUploadCSV=true;
        },0.0001);
    }

    handleCSVLineItemSize(event){
        let csvRows =  event.detail;
        let customEvent = new CustomEvent('csvsize',{detail:csvRows});
        this.dispatchEvent(customEvent);
    }

    handlelistDeliveryLineItems(event){
        let today = new Date();
        if(!isCarrierUser){
            today.setDate(today.getDate() + 1);
        }else{
            today.setDate(today.getDate());
        }
        this.today = today.getFullYear()+'-' + (parseInt(today.getMonth())+ parseInt(1))+'-'+today.getDate();
        let maxDate = new Date();
        maxDate.setDate(today.getDate() + 90);
        this.maxEndDate = maxDate.getFullYear()+'-' + (parseInt(maxDate.getMonth())+ parseInt(1))+'-'+maxDate.getDate();
        
        if(this.isPlantCode === true && this.plantDays > 0 && this.notWeekend === true && this.sameDayOrder !==true){
            this.setBusinnessAndWeekendDatesValidation();
        } 
        if(this.isPlantCode === true && this.plantDays > 0 && this.notWeekend === false && this.sameDayOrder !== true){
            this.setBusinnessDaysValidationOnly();
        }   
        if(this.sameDayOrder === true){
            this.setSameDayValidation();
        }      

        this.isTonnage = true;
        this.listDeliveryLineItems = [];
        this.csvrows = event.detail;
        for (let j = 0; j < this.csvrows.length; j++) {
            let element = this.csvrows[j];
            let structure = {...this.structureForTableRow};
            structure.Product = this.ProductDetail.Product;
            let deliveryDate = new Date(element['Delivery Date']);
            let deliveryDay = deliveryDate.getDay();
            structure.deliveryDate = deliveryDate.getFullYear()+'-' + (parseInt(deliveryDate.getMonth())+ parseInt(1))+'-'+deliveryDate.getDate();
            let day = '';
            switch(deliveryDay) {
                case 0:
                    structure.deliveryDay = 'Sunday';
                    break;
                case 1:
                    structure.deliveryDay = 'Monday';
                    break;
                case 2:
                    structure.deliveryDay = 'Tuesday';
                    break;
                case 3:
                    structure.deliveryDay = 'Wednesday';
                    break;
                case 4:
                    structure.deliveryDay = 'Thursday';
                    break;
                case 5:
                    structure.deliveryDay = 'Friday';
                    break;
                case 6:
                    structure.deliveryDay = 'Saturday';
                    break;
            }
            structure.Quantity = element['Deliveries Per Day'];
            structure.Tonnage = element['Load Volume'];
            structure.DeliveryText = element['Delivery Text'];
            structure.PoNumber = element['PO Number'];
            structure.index = j;

            let structureToCompare = Object.assign({}, structure);
            structureToCompare.deliveryDate = deliveryDate.getFullYear()+'-' + this.addZeroInMonthDays(parseInt(deliveryDate.getMonth()) + parseInt(1))+'-'+this.addZeroInMonthDays(deliveryDate.getDate());
            structure.deliveryDate = structureToCompare.deliveryDate;
            structure.CartItemId = String(Math.random()).substring(2);
            this.lstOfDates.push(structureToCompare.deliveryDate);
            this.listDeliveryLineItems.push(structure);            
        }
        this.generateCartDeliveryGrpToSave();
        this.fireEvent();
        if(this.lineItemsGenerated != true) {
            this.lineItemsGenerated = true;
            let customEvent = new CustomEvent('updatesubmitbutton');
            this.dispatchEvent(customEvent);

            // Activate add products button
            let activateButtonEvent = new CustomEvent('activateaddproductsbutton');
            this.dispatchEvent(activateButtonEvent);
        }
        this.showLineItemsForFileUpload = true;
        this.handleModalCancel();
    }

    handleLoadVolume(event){
        let index = event.target.name;
        let lineItemForThisIndex = {...this.listDeliveryLineItems[index]};
        lineItemForThisIndex.Tonnage = event.target.value;
        this.listDeliveryLineItems[index] = lineItemForThisIndex;
        let loadVolume = event.target.value;
        this.errorString = '';
        this.loadVolMin = 1;
        if(this.effectiveAccountData[0].B2B_Business_Sub_Unit__c === Business_Unit_for_the_MLS_account ){
            this.loadVolMin = 22;
           this.ProductDetail.shippingMode = '90';
        }  
        if(this.overrideTonnageLimit === false){
            switch(this.ProductDetail.shippingMode) {
                case '90':
                    this.loadVolMax = 22;
                    if((loadVolume > 22 || loadVolume < 22) ) {
                        this.errorString = Business_Unit_MLS_Account_Validation;
                    }
                    break;  
                case '99':
                
                    if((loadVolume > 50 || loadVolume <= 0) && !this.overrideGallonLimit) {
                        this.loadVolMax = 50;
                        this.errorString = 'Load volume ranges from 1 to 50';
                    }
                    else if((loadVolume > 4500 || loadVolume <= 0) && this.overrideGallonLimit){
                        this.loadVolMax = 4500;
                        this.errorString = 'Load volume ranges from 1 to 4500';
                    }
                    break;
                case '88':
                    this.loadVolMax = 4500;
                    if((loadVolume > 4500 || loadVolume <= 0) && this.overrideGallonLimit) {
                        this.errorString = 'Load volume ranges from 1 to 4500';
                    }
                    break;  
                case '25':
                    this.loadVolMax = 25;
                    if(loadVolume > 25 || loadVolume <= 0) {
                        this.errorString = 'Load volume ranges from 1 to 25';
                    }
                    break;                                   
                case '50':
                    this.loadVolMax = 50;
                    if(loadVolume > 50 || loadVolume <= 0) {
                        this.errorString = 'Load volume ranges from 1 to 50';
                    }
                    break;
                case '95':
                    this.loadVolMax = 95;
                    if(loadVolume > 95 || loadVolume <= 0) {
                        this.errorString = 'Load volume ranges from 1 to 95';
                    }
                    break;
                case '36':
                    this.loadVolMax = 23;
                    if(loadVolume > 23 || loadVolume <= 0) {
                        this.errorString = 'Load volume ranges from 1 to 23';
                    }
                    break;
                case '34':
                    this.loadVolMax = 23;
                    if(loadVolume > 23 || loadVolume <= 17) {
                        this.errorString = 'Load volume ranges from 18 to 23';
                    }
                    break;                                   
                case '33':
                    this.loadVolMax = 45;
                    if(loadVolume > 45 || loadVolume <= 0) {
                        this.errorString = 'Load volume ranges from 1 to 45';
                    }
                    break;                                   
                case '35':
                    this.loadVolMax = 23;
                    if(loadVolume > 23 || loadVolume <= 0) {
                        this.errorString = 'Load volume ranges from 1 to 23';
                    }
                    break;                                
                case '30':
                    this.loadVolMax = 23;
                    if(loadVolume > 23 || loadVolume <= 0) {
                        this.errorString = 'Load volume ranges from 1 to 23';
                    }
                    break;                                   
                case '37':                                 
                case '38':
                case '32':
                    this.loadVolMax = 50;
                    if(loadVolume > 50 || loadVolume <= 0) {
                        this.errorString = 'Load volume ranges from 1 to 50';
                    }
                    break;             
                case '55':
                case '98':
                case '51':
                    this.loadVolMax = 100;
                    if(loadVolume > 100 || loadVolume <= 0) {
                        this.errorString = 'Load volume ranges from 1 to 100';
                    }
                    break;   
                case '10':
                case '11':
                case '15':
                case '97':
                    this.loadVolMax = 1600;
                    if(loadVolume > 1600 || loadVolume <= 0) {
                        this.errorString = 'Load volume ranges from 1 to 1600';
                    }
                    break;               
            //}       
                
            }
        }              
        if(this.errorString.length > 0){
            event.target.value = null;
        }else{
            this.mapToUpdate = {...this.productIdToNewDeliveryGroups};
            let cartDeliveryList = [...this.mapToUpdate[this.mapOfCartIdAndProductId[lineItemForThisIndex.Product]]];
            var indexs = -1;
            var val = lineItemForThisIndex.CartItemId;
            for (let cdg of cartDeliveryList) {
                indexs++;
                if(cdg.CartItemId === val){
                    let cdg = {...cartDeliveryList[indexs]};
                    cdg.Tonnage = lineItemForThisIndex.Tonnage;
                    cdg.ShipmentTonnage__c = parseFloat(lineItemForThisIndex.Tonnage);
                    cdg.Shipment_Size__c = parseFloat(lineItemForThisIndex.Tonnage);
                    cartDeliveryList[indexs] = cdg;
                }
            }
            let updateMap = {};
            updateMap[this.mapOfCartIdAndProductId[lineItemForThisIndex.Product]] = cartDeliveryList;
            let customEvent = new CustomEvent('updatedeliverydata',{detail:updateMap});  
            this.dispatchEvent(customEvent);
        }               
        
    }

    handleLineItemQuantityCSVChange(event){
        let index = event.target.name;
        let lineItemForThisIndex = {...this.listDeliveryLineItems[index]};
        lineItemForThisIndex.Quantity = event.target.value;
        this.listDeliveryLineItems[index] = lineItemForThisIndex;
        let selectedQuantity = event.target.value;
        if(selectedQuantity <= 100 && selectedQuantity > 0 && selectedQuantity !== 0 && selectedQuantity !== '0' && selectedQuantity !== undefined && selectedQuantity !== '' && selectedQuantity !== null){ 
            let mapToUpdate = {...this.productIdToNewDeliveryGroups};
            let cartDeliveryList =  JSON.parse(JSON.stringify([...mapToUpdate[this.mapOfCartIdAndProductId[lineItemForThisIndex.Product]]]));
            var indexs = -1;
            let updateMap = {};
            var val = lineItemForThisIndex.CartItemId;
            let removeValFromIndex = []          
            for (let cdg of cartDeliveryList) {
                indexs++;
                if(cdg.CartItemId === val){
                    removeValFromIndex.push(indexs)
                }
            }
            let updatedCartDeliveryList =[]
            for (var i = removeValFromIndex.length -1; i >= 0; i--){
                updatedCartDeliveryList.push(cartDeliveryList[removeValFromIndex[i]]);
                cartDeliveryList.splice(removeValFromIndex[i],1);               
            }
            if(updatedCartDeliveryList.length !== selectedQuantity){ 
                let cdg = updatedCartDeliveryList[0];
                for(var i = 0 ;i< selectedQuantity; i++){ 
                    cartDeliveryList.push(cdg);
                }
            }
            let key = this.mapOfCartIdAndProductId[lineItemForThisIndex.Product];
            updateMap[key] = cartDeliveryList;
            let customEvent = new CustomEvent('updatedeliverydata',{detail:updateMap});  
            this.dispatchEvent(customEvent);
        }  
        
    }

    handleupdateproductdetail(event){
        this.ProductDetail.startDate =  event.detail.date;
        this.ProductDetail.loadVolume =  event.detail.dloadVolume;
        this.ProductDetail.quantity =  1;
        this.ProductDetail.poNumber =  event.detail.poNumber;
        this.ProductDetail.isFile = true;
        this.ProductDetail.endDate = null;
        this.isTonnage=false;
    }

    setMaxDate(){
            let dateTime= new Date().toLocaleString(this.locale,{timeZone:this.timeZone});       
            let today = new Date(dateTime);
            let time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
            let [hours, minutes, seconds] = time.split(':');
            let proceedToCheckoutDay = today.getDay();
            if(proceedToCheckoutDay === 0 && !isCarrierUser && !this.isPlantCode){
                today.setDate(today.getDate() + 2);
            }else if(proceedToCheckoutDay === 6  && !isCarrierUser && !this.isPlantCode){
                today.setDate(today.getDate() + 3);
            } else if(proceedToCheckoutDay === 5 && Number(hours) >= 12 && !isCarrierUser && !this.isPlantCode){
                today.setDate(today.getDate() + 4);
            } else if(Number(hours) >= 12 && !isCarrierUser && !this.isPlantCode){
                this.isNextDate = true;
                today = new Date(dateTime);
                today.setDate(today.getDate() + 2);
            }
            else{
                if(!isCarrierUser){
                    today = new Date(dateTime);
                    today.setDate(today.getDate() + 1);
                }else{
                    today = new Date(dateTime);
                    today.setDate(today.getDate());
                }               
            }
            this.today = today.getFullYear()+'-' + (parseInt(today.getMonth())+ parseInt(1))+'-'+today.getDate();
            let maxDate = new Date(dateTime);
            maxDate.setDate(today.getDate() + 90);
            this.maxDate = maxDate.getFullYear()+'-' + (parseInt(maxDate.getMonth())+ parseInt(1))+'-'+maxDate.getDate();
            this.todayError='Date must be '+ new Date(this.today).toDateString()+' or later.';
            this.maxDateError='Date must be '+ new Date(this.maxDate).toDateString()+' or earlier.';
    }
    
    async checkPlantCode(){
        this.isPlantCode = false;
        this.getPlantCodeValidation = await getPlantCodesForValidation({plantCode:this.ProductDetail.plantCode,productCode:this.ProductDetail.productCode});
        if(this.getPlantCodeValidation !== undefined && this.getPlantCodeValidation.length > 0){
            this.getPlantCodeValidation.forEach((plant) => {
                    this.isPlantCode = true;
                    this.plantDays = plant.Ordering_Rule_Days__c;
                    this.notWeekend = plant.No_Weekend_Order__c;
                    this.sameDayOrder = plant.Same_Day_Order__c;
            });
            this.plantCodeDate.isPlantCode = this.isPlantCode;
            this.plantCodeDate.plantDays = this.plantDays;
            this.plantCodeDate.notWeekend = this.notWeekend;
            this.plantCodeDate.sameDayOrder = this.sameDayOrder;
            if(this.isPlantCode === true && this.plantDays > 0 && this.notWeekend === true && this.sameDayOrder !== true){
                this.setBusinnessAndWeekendDatesValidation();
            } 
            if(this.isPlantCode === true && this.plantDays > 0 && this.notWeekend === false && this.sameDayOrder !== true){
                this.setBusinnessDaysValidationOnly();
            }
            if(this.sameDayOrder === true){
                this.setSameDayValidation();
            }                       
        }
    }

    setBusinnessAndWeekendDatesValidation(){
        let daysCount = 0;
        let dateTime= new Date().toLocaleString(this.locale,{timeZone:this.timeZone});       
        let today = new Date(dateTime);
        today.setDate(today.getDate() + 1);
        while(daysCount < this.plantDays + 1 ){
            if(today.getDay() === 0 || today.getDay() === 6){
                today.setDate(today.getDate() + 1);
            }else{
                today.setDate(today.getDate() + 1);
                daysCount ++;
            }
        }
        today.setDate(today.getDate() - 1);
        this.today = today.getFullYear()+'-' + (parseInt(today.getMonth())+ parseInt(1))+'-'+today.getDate();
        let maxDate = new Date(dateTime);
        maxDate.setDate(today.getDate() + 90);
        this.maxDate = maxDate.getFullYear()+'-' + (parseInt(maxDate.getMonth())+ parseInt(1))+'-'+maxDate.getDate();
        this.todayError='Date must be '+ new Date(this.today).toDateString()+' or later.';
        this.maxDateError='Date must be '+ new Date(this.maxDate).toDateString()+' or earlier.';
    }  
    
    setBusinnessDaysValidationOnly(){
        let daysCount = 0;
        let dateTime= new Date().toLocaleString(this.locale,{timeZone:this.timeZone});       
        let today = new Date(dateTime);
        today.setDate(today.getDate() + 1);
        while(daysCount < this.plantDays + 1 ){
            today.setDate(today.getDate() + 1);
            daysCount ++;            
        }
        today.setDate(today.getDate() - 1);
        this.today = today.getFullYear()+'-' + (parseInt(today.getMonth())+ parseInt(1))+'-'+today.getDate();
        let maxDate = new Date(dateTime);
        maxDate.setDate(today.getDate() + 90);
        this.maxDate = maxDate.getFullYear()+'-' + (parseInt(maxDate.getMonth())+ parseInt(1))+'-'+maxDate.getDate();
        this.todayError='Date must be '+ new Date(this.today).toDateString()+' or later.';
        this.maxDateError='Date must be '+ new Date(this.maxDate).toDateString()+' or earlier.';
    }  

    setSameDayValidation(){
        let dateTime= new Date().toLocaleString(this.locale,{timeZone:this.timeZone});       
        let today = new Date(dateTime);
        today.setDate(today.getDate());
        this.today = today.getFullYear()+'-' + (parseInt(today.getMonth())+ parseInt(1))+'-'+today.getDate();
        let maxDate = new Date(dateTime);
        maxDate.setDate(today.getDate() + 90);
        this.maxDate = maxDate.getFullYear()+'-' + (parseInt(maxDate.getMonth())+ parseInt(1))+'-'+maxDate.getDate();
        this.todayError='Date must be '+ new Date(this.today).toDateString()+' or later.';
        this.maxDateError='Date must be '+ new Date(this.maxDate).toDateString()+' or earlier.';
    }
}