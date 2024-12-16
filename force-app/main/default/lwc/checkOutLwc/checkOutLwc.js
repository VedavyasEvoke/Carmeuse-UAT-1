import { LightningElement, api, track } from 'lwc';
import communityId from '@salesforce/community/Id';
import getCartItems from '@salesforce/apex/B2BCartController.getCartItems';
import getPriceBookEntry from '@salesforce/apex/OrderUtils.getPriceBookEntry';
import getAccountAndProductData from '@salesforce/apex/OrderUtils.getAccountAndProductData';
import getDefaultId from '@salesforce/apex/OrderUtils.getDefaultId';
import splitShipments from '@salesforce/apex/B2BSplitShipment.splitShipments';
import splitShipmentsDefaults from '@salesforce/apex/B2BSplitShipment.getSplitShipmentDefaults';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import quickSaveSplitShipments from '@salesforce/apex/B2BSplitShipment.quickSaveSplitShipments';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Quick_Save_Success_Message from '@salesforce/label/c.Quick_Save_Success_Message';
import Weekend_Warning from '@salesforce/label/c.Weekend_Warning';
import OrganizationDetail from '@salesforce/apex/OrderUtils.OrganizationDetail';
import getProductsAssignToEP from '@salesforce/apex/OrderUtils.getProductsAssignToEP';
var productsAdded = 1;
var numProducts = 0;
var lineItemsGenerated = 0;

export default class CheckOutLwc extends LightningElement {

    @api recordId;
    @api mapOfProductIdVsAvailable = {};
    @track isDisabled = false;
    @track listOfProductItems = [];
    @track show = true;
    @track mapOfProductIdVsLabel = {};
    @track today;
    @track effectiveAccountId = null;
    @track pageParam = null;
    @track sortParam = null;
    @track currencyCode;
    @track cartId;
    @track cartItemOptions;
    @track cartItemAvailable;
    @track mapOfProductIdVsName = {};
    @track mapOfProductNameVsId = {};
    @track cartItems;
    @track mapOfIndexVsProductDetail = {};
    @track sortParamb2bCartLineItems;
    @track defaultData ;
    @track mapOfCartIdAndProductId = {};

    /*Quick Save Variables*/
    @track quickSaveData = [];
    @track showQuickSave = false;
    @track productInCart = [];
    @api cartSaveData

    @api isLoaded = false;
    @api isQuickSaveLoaded = false;
    isQuickSave = false;

    @track cartItemLineItem = [];
    @track cartDeliveryGroup = [];
    @track effectiveAccountData;
    @track defaultIds;
    @track productIdToNewDeliveryGroups = {};
    @track isRender = false;
    @track csvRowsCount=0;
    @track isCSVUpload=false;
    @track csvFileCount = {};

    @track addProductButton = true;
    @track showSubmitButton = true;
    @track timeZone;

    @track getProductInEntitlement;
    @track getPriceBookProductsValue;

    @track blueVariant;
    @track isMLSAccount;

    async connectedCallback() {
        await this.getOrganizationDetails();
        await this.getCartItems();
        await this.getDefaultId();
        await this.getPriceBookEntry();
        await this.getAccountAndProductData();
      await   splitShipmentsDefaults({cartId: this.recordId})
        .then(result => {
            this.defaultData = result;
            this.getQuickSaveCartItems();
        })
        .catch(error => {
           console.log(error);
        })
    }
    renderedCallback(){
        if(!this.isRender){ 
            this.getAccountAndProductData();  
            this.isRender = true;
        }   
        this.getOrganizationDetails();   
    }

    get defaultDataGenerated(){
        return this.defaultData != undefined;
    }

    getOrganizationDetails(){
        OrganizationDetail()
        .then(result => {
            this.orgDetails = result;
            this.timeZone = result.TimeZoneSidKey; 
            this.locale = 'en-US';
            
        })
        .catch(error => {
           console.log(error);
        })
    }

    splitShipmentsDefaults(){
        
    }
    addLineItems(event){
        productsAdded++;
        this.addProductButton = true;
        let indexToPush = this.listOfProductItems.length;
        this.listOfProductItems.push(indexToPush);
    }

    get showAddProductButtons(){

        return this.cartItemAvailable != null &&
                this.cartItemAvailable != undefined &&
                this.cartItemAvailable.length > 0 &&
                this.cartItemOptions != null &&
                this.cartItemOptions != undefined &&
                this.cartItemOptions.length > 1 ;
    }

    updateSubmitButton() {
        lineItemsGenerated = lineItemsGenerated + 1;

        if(lineItemsGenerated >= numProducts) {
            // let submitButton = this.template.querySelector(".submit");
            // submitButton.disabled = false;
            //this.showSubmitButton = false;
            this.blueVariant = 'brand';
        } else {
            console.log("Still need to generate all line items");
        }
    }

    updateAddProductsButton() {
        if(productsAdded < numProducts) {
            this.addProductButton = false;
        }
    }

    updatedeliverydata(event){
        this.productIdToNewDeliveryGroups =  Object.assign(this.productIdToNewDeliveryGroups,event.detail);
        // this.productIdToNewDeliveryGroups = event.detail;
    } 

    deleteandupdatedeliverydata(event){
        if(event.detail !== null || event.detail !== undefined){
            delete this.productIdToNewDeliveryGroups[event.detail];
        }
    }

    deletelineitems(event){
        let keys =  event.detail.product;
        let CartItemId =  event.detail.CartItemId;
        let cartDeliveryList =  JSON.parse(JSON.stringify(this.productIdToNewDeliveryGroups[keys]));
        var indexs = -1;
        let removeValFromIndex = []          
        for (let cdg of cartDeliveryList) {
            indexs++;
            if(cdg.CartItemId === CartItemId){
                removeValFromIndex.push(indexs)
            }
        }
        let updatedCartDeliveryList =[]
        for (var i = removeValFromIndex.length -1; i >= 0; i--){
            updatedCartDeliveryList.push(cartDeliveryList[removeValFromIndex[i]]);
            cartDeliveryList.splice(removeValFromIndex[i],1);               
        }
        this.productIdToNewDeliveryGroups[keys] = cartDeliveryList;
    }

    handleSubmit(){
        let submitButton = this.template.querySelector(".submit");        
        let elements = Array.from(this.template.querySelectorAll('c-split-shipment-product-details'));
        let isValid = true;
        let cdgCount = 0;
        let isNextDayOrder = false;
        let dateTime= new Date().toLocaleString(this.locale,{timeZone:this.timeZone});       
        let today = new Date(dateTime);
        let time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
        let [hours, minutes, seconds] = time.split(':');
        if(elements){
            for(let elementInstance of elements){
                isValid = isValid && elementInstance.combinedValidityCheck();
            }
        }
        if(isValid){
            if(!this.toCheckAllProductsSelected() || Object.keys(this.productIdToNewDeliveryGroups).length === 0 || Object.keys(this.mapOfProductIdVsName).length !== Object.keys(this.productIdToNewDeliveryGroups).length){
                elements[0].showNotification('Please generate line items for all products', 'error', 'ERROR');
            }else{
                submitButton.disabled = true;
                this.isLoaded = !this.isLoaded;
                let isDefault = true;
                this.beforeUpdatedMap = Object.assign({},this.productIdToNewDeliveryGroups);
                for (var key in this.productIdToNewDeliveryGroups) {
                    if (this.productIdToNewDeliveryGroups.hasOwnProperty(key)) {
                    var deliveryGroups = this.productIdToNewDeliveryGroups[key];
                    deliveryGroups = deliveryGroups.map(({CartItemId, ...rest}) => {
                        if(rest.Next_Day_Order__c && !isNextDayOrder){
                            isNextDayOrder = true;
                        }
                        return rest;
                    });                    
                    if(isNextDayOrder){
                        this.dispatchEvent(new ShowToastEvent({
                            message: 'Orders may get delayed as it contains next day deliveries. In case of any emergency please contact Customer Service at 1 (800) 445-3930.',
                            variant: 'warning',
                            mode: 'sticky'
                        }));
                    }
                    if(isDefault === true){ 
                        let cdg = deliveryGroups[0];
                        cdg.Id = this.defaultIds['CartDeliveryGroup'];
                        delete cdg['CartId'];
                        deliveryGroups[0] = cdg;
                        isDefault = false;
                    }
                    cdgCount += deliveryGroups.length;
                    this.productIdToNewDeliveryGroups[key] = deliveryGroups;
                    }            
                }
                if(cdgCount > 500){
                    elements[0].showNotification('We have reached the limit of no. of deliveries per order ('+ cdgCount + '). Please split your Order such that it contains a max of 500 deliveries. Eg: Total Cart items=Deliveries Required per Day * (No. of days)', 'warning', 'WARNING');
                    submitButton.disabled = false;
                    this.productIdToNewDeliveryGroups =  Object.assign({},this.beforeUpdatedMap);
                    this.isLoaded = !this.isLoaded;
                }else{
                    splitShipments({
                        productIdToNewDeliveryGroups: this.productIdToNewDeliveryGroups,
                        cartId: this.recordId
                    }).then(() => {
                        const navigateNextEvent = new FlowNavigationNextEvent();            
                        this.dispatchEvent(navigateNextEvent);
                        this.isLoaded = !this.isLoaded;
                    }).catch(error => {
                        this.isLoaded = !this.isLoaded;
                        elements[0].showNotification(error.body.message, 'error', 'ERROR');
                        console.error(error);
                    });
                }
            }
        }
    }

    toCheckAllProductsSelected(){
        if(Object.values(this.mapOfProductIdVsAvailable).includes(true)){
            return false;
        }else{
            return true;
        }
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

            this.cartItemAvailable = cartItems.map(({ cartItem }) => {
                var tempName = cartItem.name;
                tempName = tempName.replaceAll("&quot;", "\"");
                cartItem.name = tempName;
                cartItem.productDetails.name = tempName;
                this.mapOfProductIdVsAvailable[cartItem.cartItemId] = true;
                this.mapOfProductIdVsLabel[cartItem.cartItemId] = cartItem.name;
                return {
                    value: cartItem.cartItemId,
                    label: cartItem.name
                }
            })
            this.cartItemOptions = cartItems.map(({ cartItem }) => {
                var tempName = cartItem.name;
                tempName = tempName.replaceAll("&quot;", "\"");
                cartItem.name = tempName;
                cartItem.productDetails.name = tempName;
                this.mapOfProductIdVsName[cartItem.cartItemId] = cartItem.name;
                this.mapOfProductNameVsId[cartItem.name] = cartItem.productId;
                this.mapOfCartIdAndProductId[cartItem.cartItemId] = cartItem.productId;
                numProducts++;
                return {
                    value: cartItem.cartItemId,
                    label: cartItem.name
                }
            })
            this.listOfProductItems.push(0);
        })
        .catch((error) => {
            console.log('error : ' + error);
            this.cartItems = undefined;
        });  
        
    }  

    handleDeleteProduct(event){
        this.quickSaveData = {};
        this.show = false;
        const details = event.detail;
        let productIndexToDelete = details.index;
        let product = this.mapOfIndexVsProductDetail[productIndexToDelete].ProductDetail.Product;
        this.mapOfProductIdVsAvailable[product] = true;

        let key = this.mapOfCartIdAndProductId[product];
        delete this.productIdToNewDeliveryGroups[key];

        if(this.cartItemAvailable) {
            this.cartItemAvailable.push({
                                            value: product,
                                            label: this.mapOfProductIdVsLabel[product]
                                        })
        }
        delete this.mapOfIndexVsProductDetail[productIndexToDelete];



        if(this.listOfProductItems) {
            productsAdded--;
            this.listOfProductItems.splice(this.listOfProductItems.indexOf(productIndexToDelete), 1);
        }
       this.show = true;
       if(this.listOfProductItems.length == 0) {
            setTimeout(() => {
                this.listOfProductItems = [0];
            }, 500);
        }
        this.csvFileCount[product] = 0;
        this.updateAddProductsButton();
        this.blueVariant = 'Neutral';
    }

    handleUpdateSelectionMap(event) {
        const details = event.detail;
        this.mapOfProductIdVsAvailable = details.mapOfProductIdVsAvailableCopy;
    }

    handleProductDetailsAddition(event){
        const details = event.detail;
        this.mapOfIndexVsProductDetail[details.index] = details.Product;
        this.cartItemAvailable = this.cartItemAvailable.filter(cartData => cartData.value != details.Product.ProductDetail.Product);
    }

    handleQuickSave(){
        let elements = Array.from(this.template.querySelectorAll('c-split-shipment-product-details'));
        let isValid = true;
        if(elements){
            for(let elementInstance of elements){
                isValid = isValid && elementInstance.combinedValidityCheck();
            }
        }
        if(isValid){ 
            if(Object.keys(this.productIdToNewDeliveryGroups).length === 0 ){
                elements[0].showNotification('Please generate line items for all products', 'error', 'ERROR');
            }else{          
                let completeProductsData = {...this.mapOfIndexVsProductDetail};
                let mapAllProducts  = {};
                for(let i of Object.keys(completeProductsData)){
                    mapAllProducts[completeProductsData[i].ProductDetail.Product] = completeProductsData[i];
                }
                this.isQuickSaveLoaded = !this.isQuickSaveLoaded;
                let cdgCount = 0;
                for (var key in this.productIdToNewDeliveryGroups) {
                    if (this.productIdToNewDeliveryGroups.hasOwnProperty(key)) {
                    var deliveryGroups = this.productIdToNewDeliveryGroups[key];
                    cdgCount += deliveryGroups.length;
                    }            
                }
                if(cdgCount > 500){
                    elements[0].showNotification('We have reached the limit of no. of deliveries per order ('+ cdgCount + '). Please split your Order such that it contains a max of 500 deliveries. Eg: Total Cart items=Deliveries Required per Day * (No. of days)', 'warning', 'WARNING');
                    this.isQuickSaveLoaded = !this.isQuickSaveLoaded;
                }else{
                    //Todo send in payload
                    quickSaveSplitShipments({
                        cartId: this.cartId,
                        payload: JSON.stringify(mapAllProducts)
                    }).then(() => {
                        this.isQuickSaveLoaded = !this.isQuickSaveLoaded;
                        const quickSave = new ShowToastEvent({
                            title: 'Success!',
                            message: Quick_Save_Success_Message,
                            variant: 'success'
                        });
                        this.isQuickSave = true;
                        this.dispatchEvent(quickSave);
                    }).catch(error => {
                        this.isQuickSaveLoaded = !this.isQuickSaveLoaded;
                        const quickSave = new ShowToastEvent({
                            title: 'Error!',
                            message: 'Something went wrong!',
                            variant: 'error'
                        });
                        this.dispatchEvent(quickSave);
                    });
                }
            }
        }else{
            elements[0].showNotification('Please enter valid inputs', 'error', 'ERROR');
        } 
    }

    getQuickSaveCartItems(){
        this.productInCart = [];
        let cardItemsDetail = [];        
        let cartSaveData = JSON.parse(this.defaultData); 
        if(Array.isArray(cartSaveData)){   
            for(let data of cartSaveData){
                if(data.hasOwnProperty('listofLineItems')){
                    let productDetails = JSON.parse(data.listofLineItems).ProductDetail.Product
                    for(let cartValue of this.cartItemAvailable){
                        if(productDetails === cartValue.value){
                            this.productInCart.push(cartValue);
                        }                       
                    }                  
                    this.quickSaveData.push(data.listofLineItems);
                }            
            }
            cardItemsDetail = this.cartItemAvailable.filter(cartItems => !this.productInCart.some(products => cartItems.value === products.value));
            this.productInCart.push.apply(this.productInCart,cardItemsDetail);

       }        
    }

    addProductOnCard(event){
        let indexToPush = this.listOfProductItems.length;
        this.listOfProductItems.push(indexToPush);
    }

    updateQuickSaveButton() {
        let addButton = this.template.querySelector(".quicksave");
        addButton.disabled = false;
        let save = this.template.querySelector(".submit");
        save.disabled = false;
    }
    
    getPriceBookEntry(){ 
        getPriceBookEntry({
            cardId: this.recordId
        })
        .then((result) => {
           this.pricebookEntries = result;
        }).catch(error => {
            elements[0].showNotification(error.body.message, 'error', 'ERROR');
            console.error(error);
        });       
    }
    
    async getAccountAndProductData(){ 
        this.AccountAndProductData = await getAccountAndProductData({cardId: this.recordId}); 
        this.effectiveAccountData = this.AccountAndProductData['Account'];
        this.getExistingProductDetail = this.AccountAndProductData['Product'];
        
        if(this.effectiveAccountData !== undefined){
            let accountName = this.effectiveAccountData[0].Id;
            this.getPriceBookProductsValue = await getProductsAssignToEP({accountName:accountName});
        }       
    }

    async getPriceBookProducts(){
        let accountName = this.effectiveAccountData[0].Id;
        this.getPriceBookProductsValue = await getProductsAssignToEP({accountName:accountName});  
    }

    getDefaultId(){ 
        getDefaultId({ 
            cardId: this.recordId
        })
        .then((result) => {
            this.defaultIds = result;
         }).catch(error => {
             elements[0].showNotification(error.body.message, 'error', 'ERROR');
             console.error(error);
         });
    }

    handlecsvsize(event){
        this.csvFileCount = Object.assign(this.csvFileCount,event.detail);
        this.isCSVUpload = true;
    }

    isWeekEndOrders(){
        let dateTime= new Date().toLocaleString(this.locale,{timeZone:this.timeZone});       
        let today = new Date(dateTime);
        let time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
        let [hours, minutes, seconds] = time.split(':');
        let proceedToCheckoutDay = today.getDay();
        if(proceedToCheckoutDay == 0 || proceedToCheckoutDay == 6 || (proceedToCheckoutDay == 5 && Number(hours) >= 12)){
           /* const warning = new ShowToastEvent({
                message: Weekend_Warning,
                variant: 'warning',
                mode: 'sticky'
            });
            this.dispatchEvent(warning);*/
        }
    }

    getOrganizationDetails(){
        OrganizationDetail()
        .then(result => {
            this.orgDetails = result;
            this.timeZone = result.TimeZoneSidKey; 
            this.locale = 'en-US';
            this.isWeekEndOrders();
        })
        .catch(error => {
           console.log(error);
        })
    }
}