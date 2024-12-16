import {LightningElement, api , track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader'; 
import jszip from '@salesforce/resourceUrl/ZIP';
import PARSER from '@salesforce/resourceUrl/papaparse';
import sheetjs from '@salesforce/resourceUrl/sheetjs';
import OrderXLS from '@salesforce/resourceUrl/OrderXLS';
import OrderXLSX from '@salesforce/resourceUrl/OrderXLSX'
import PO_Number_Validation from '@salesforce/label/c.PO_Number_Validation';
import Desired_Delivery_Date_Validation from '@salesforce/label/c.Desired_Delivery_Date_Validation';
import Desired_Delivery_Date_Validation_For_Today from '@salesforce/label/c.Desired_Delivery_Date_Validation_For_Today';
import Desired_Delivery_Date_Validation_For_Greater_Than from '@salesforce/label/c.Desired_Delivery_Date_Validation_For_Greater_Than';
import Max_500_Line_Item_Limit from '@salesforce/label/c.Max_500_Line_Item_Limit';
import CSV_File_Validation from '@salesforce/label/c.CSV_File_Validation';
import CSV_File_Size_Validation from '@salesforce/label/c.CSV_File_Size_Validation';
import Load_Volume_Validation from '@salesforce/label/c.Load_Volume_Validation';
import Desired_Delivery_Date_Validation_For_Weekend from '@salesforce/label/c.Desired_Delivery_Date_Validation_For_Weekend';
import Desired_Delivery_Date_Validation_For_Next_Day from '@salesforce/label/c.Desired_Delivery_Date_Validation_For_Next_Day';
import isCarrierUser  from '@salesforce/customPermission/Carrier_User_Only';
import Plant_Code_Business_Day_And_Weekend_Validation from '@salesforce/label/c.Plant_Code_Business_Day_And_Weekend_Validation';
import Plant_Code_Business_Day_Validation from '@salesforce/label/c.Plant_Code_Business_Day_Validation';
import Plant_Code_Validation_Customer_Service from '@salesforce/label/c.Plant_Code_Validation_Customer_Service';
import Plant_Code_Validation_Product_Available from '@salesforce/label/c.Plant_Code_Validation_Product_Available';
import Plant_Code_Weekend_Validation from '@salesforce/label/c.Plant_Code_Weekend_Validation';
import Invalid_Decimal_Number from '@salesforce/label/c.Invalid_Decimal_Number';
import Business_Unit_for_the_MLS_account from '@salesforce/label/c.Business_Unit_for_the_MLS_account';
import Business_Unit_MLS_Account_Validation from '@salesforce/label/c.Business_Unit_MLS_Account_Validation';

let XLS = {};
export default class CarmeuseUploadFileForLineItemModal extends LightningElement {
    cancelLabel = 'Cancel';
    fileName = '';
    showLoadingSpinner = false;
    errorString = '';
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    parserInitialized = false;
    parserInitializedExcel = false; 
    parserInitializedZipExcel = false;
    isError = false;
    columnHeader = ["Delivery Date","Deliveries Per Day","Load Volume","Delivery Text","PO Number"]
    MAX_FILE_SIZE = 1500000; 
    @api errorLst;
    productName;
    shipmentType;
    shippingCondition;
    poNumber;
    deliveryText;
    startDate = new Date().setHours(0,0,0,0);
    currentProductShippingMode;
    totalCount = 0;

    @api csvFileCount;
    @api productDetail;
    @api mapOfProductIdVsName;
    @api cartItemOptions;
    locale = 'en-US';
    @api timeZone;

    /*Gallon Limits */
    @api overrideGallonLimit;
    @track strShippmentCondition = 'tons';
  
     /*Plant code validation */
    @api plantCodeDate;
    @api getPriceBookProductsValue;
    @api effectiveAccountData;
    connectedCallback(){
        this.shipmentType = this.productDetail.shippingType;
        this.shippingCondition = this.productDetail.shippingCondition;
        this.productName = this.mapOfProductIdVsName[this.productDetail.Product];
        this.poNumber = this.productDetail.poNumber;
        this.deliveryText = this.productDetail.deliveryText;
        if(this.errorLst && this.errorLst.length > 0){
            this.isError = true;
        }
        if(this.overrideGallonLimit === true){
            this.strShippmentCondition = 'gallons';
        }
        
    }

    handleFilesChange(event) {
        if(event.target.files.length > 0) {
            this.isError = false;  
            this.errorLst = [];       
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.extension = this.fileName.substring(this.fileName.lastIndexOf(".")).toUpperCase();
        }
    }

    handleFilesClick(event) {
        this.isError = false;
        this.errorLst = [];     
    }
    handleSave() {
        if(this.filesUploaded.length > 0) {
            this.uploadHelper();
        }
        else {
            this.fileName = CSV_File_Validation;
            const invalidFileSize = new ShowToastEvent({
                message: CSV_File_Validation,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(invalidFileSize);
            this.showLoadingSpinner = false;
            return ;
        }
    }
    uploadHelper() {
        this.showLoadingSpinner = true;
        this.file = this.filesUploaded[0];
        let errorMsg;
        if(this.extension !== '.CSV' && this.extension !== '.XLS' && this.extension !== '.XLSX'){
            errorMsg = CSV_File_Validation;           
        }
        if (this.file.size > this.MAX_FILE_SIZE) {
            errorMsg = CSV_File_Size_Validation;
        }
        if(errorMsg){
            const invalidFileSize = new ShowToastEvent({
                message: errorMsg,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(invalidFileSize);
            this.showLoadingSpinner = false;
            return ;
        }
        if(this.extension == '.CSV'){    
            Papa.parse(this.file, {
            quoteChar: '"',
            header: 'true',
            complete: (results) => {
                let rowsCount = 0;
                this.totalCount = 0;
                this.csvrows  = results.data;
                if(Object.keys(this.csvFileCount).length !== 0){                   
                    for (let key in this.csvFileCount) {
                        if (this.csvFileCount.hasOwnProperty(key)) {
                            this.totalCount += this.csvFileCount[key];
                        }
                    }               
                }  
                if(this.csvrows.length > 0){
                    for (let j = 0; j < this.csvrows.length; j++) {
                        let element = this.csvrows[j];
                        if((element.hasOwnProperty('Delivery Date') && element['Delivery Date'] !== '' ) || (element.hasOwnProperty('Load Volume') && element['Load Volume'] !== '' ) || (element.hasOwnProperty('PO Number') && element['PO Number'] !== '' ) || (element.hasOwnProperty('Deliveries Per Day') && element['Deliveries Per Day'] !== '' )){
                            rowsCount ++;
                        }                   
                    }
                }
                if(this.totalCount + rowsCount > 500){
                    const invalidFileSize = new ShowToastEvent({
                        message: Max_500_Line_Item_Limit,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(invalidFileSize);
                    this.dispatchEvent(new CustomEvent('handlecancelonlimit', {detail: false}));
                    this.showLoadingSpinner = false;
                    return ;
                }           
                this.getProductDetails();
                this.validatecsvRows();
            },
            error: (error) => {
                this.showLoadingSpinner = false;
                console.error(error);
                return ;            
            }
            }) 
        }else if (this.extension == '.XLS' || this.extension == '.XLSX') {
            this.excelFileToJSON(this.filesUploaded[0]);
        }      
    }

    excelFileToJSON(file){
        var reader = new FileReader();        
        reader.onload = (event)=>{
            var data = event.target.result;
            if(data === undefined || data === ""){
                const uploadFail = new ShowToastEvent({
                    message: 'Upload failed - file is empty',
                    variant: 'error'
                });
                this.dispatchEvent(uploadFail);
                this.dispatchEvent(new CustomEvent('handlecancelonlimit', {detail: false}));
                this.showLoadingSpinner = false;
                return;
            }
            var workbook=XLS.read(data, {
                type: 'binary'
            });
            if(workbook.Sheets[Object.keys(workbook.Sheets)[0]] !== undefined){
                this.csvrows = XLS.utils.sheet_to_row_object_array(workbook.Sheets[Object.keys(workbook.Sheets)[0]]);
            }else{
                const illegalFile = new ShowToastEvent({
                    message: 'Illegal file format',
                    variant: 'error'
                });
                this.dispatchEvent(illegalFile);
                this.dispatchEvent(new CustomEvent('handlecancelonlimit', {detail: false}));
                this.showLoadingSpinner = false;
                return;
            }
            this.totalCount = 0;
            let rowsCount  = this.csvrows.length;
            if(Object.keys(this.csvFileCount).length !== 0){                   
                for (let key in this.csvFileCount) {
                    if (this.csvFileCount.hasOwnProperty(key)) {
                        this.totalCount += this.csvFileCount[key];
                    }
                }               
            }  
            if(this.totalCount + rowsCount > 500){
                const invalidFileSize = new ShowToastEvent({
                    message: Max_500_Line_Item_Limit,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(invalidFileSize);
                this.dispatchEvent(new CustomEvent('handlecancelonlimit', {detail: false}));
                this.showLoadingSpinner = false;
                return ;
            }  
            this.getProductDetails();
            this.validatecsvRows();
        }
        reader.onerror = function(ex) {
            this.error=ex;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while reading the file',
                    message: ex.message,
                    variant: 'error',
                }),
            );
        };
        reader.readAsBinaryString(file);
    }

    handleCancelClick(event){        
        this.dispatchEvent(new CustomEvent('handlecancel', {detail: false}));
    }

    importTemplate(){
        let doc = '';
        this.columnHeader.forEach(element => {            
            doc += element +','           
        });  
  
        let element = 'data:text/csv;charset=utf-8,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        downloadElement.download = 'Order.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    importTemplateXLS(){
        let downloadElement = document.createElement('a');
        downloadElement.href = OrderXLS;
        downloadElement.target = '_self';
        downloadElement.download = 'Order.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    importTemplateXLSX(){
        let downloadElement = document.createElement('a');
        downloadElement.href = OrderXLSX;
        downloadElement.target = '_self';
        downloadElement.download = 'Order.xlsx';
        document.body.appendChild(downloadElement);
        downloadElement.click();
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

    renderedCallback() {
        if(!this.parserInitialized){
            loadScript(this, PARSER)
                .then(() => {
                    this.parserInitialized = true;
                })
                .catch(error => 
                    console.error(error));
        }
        if(!this.parserInitializedZipExcel){            
            loadScript(this, jszip)
                .then(() => {
                    this.parserInitializedZipExcel = true;
                })
                .catch(error => 
                    console.error(error));            
        }
        if(!this.parserInitializedExcel){            
            loadScript(this, sheetjs)
                .then(() => {
                    this.parserInitializedExcel = true;
                    XLS = XLSX
                })
                .catch(error => 
                    console.error(error));
        }    
        if(this.shipmentType === null || this.shippingCondition === null ){
            this.shipmentType = this.productDetail.shippingType;
            this.shippingCondition = this.productDetail.shippingCondition;
        }       
    }

    validatecsvRows(){
        this.showLoadingSpinner = true;  
        let dateTime= new Date().toLocaleString(this.locale,{timeZone:this.timeZone});       
        let today = new Date(dateTime);
        let time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
        let [hours, minutes, seconds] = time.split(':');
        let proceedToCheckoutDay = today.getDay();
        let isNextDay = false;
        if(proceedToCheckoutDay === 0 && !isCarrierUser){
            today.setDate(today.getDate() + 2);
        }else if(proceedToCheckoutDay === 6 && !isCarrierUser){
            today.setDate(today.getDate() + 3);
        }else if(proceedToCheckoutDay === 5 && Number(hours) >= 12 && !isCarrierUser){
            today.setDate(today.getDate() + 4);
        }else if(Number(hours) >= 12 && !isCarrierUser){
            isNextDay = true;
            today.setDate(today.getDate() + 2);
        }else{
            if(!isCarrierUser){
                today.setDate(today.getDate() + 1);
            }else{
                today.setDate(today.getDate());
            }
        }

        if(this.plantCodeDate !== undefined){
            if(this.plantCodeDate.isPlantCode === true && this.plantCodeDate.plantDays > 0 && this.plantCodeDate.notWeekend === true && this.plantCodeDate.sameDayOrder !== true){
                let daysCount = 0;
                let dateTime= new Date().toLocaleString(this.locale,{timeZone:this.timeZone});       
                today = new Date(dateTime);
                today.setDate(today.getDate() + 1);
                while(daysCount < this.plantCodeDate.plantDays + 1 ){
                    if(today.getDay()  === 0 || today.getDay()  === 6){
                        today.setDate(today.getDate() + 1);
                    }else{
                        today.setDate(today.getDate() + 1);
                        daysCount ++;
                    }
                }
                today.setDate(today.getDate() - 1);
            } 
            if(this.plantCodeDate.isPlantCode === true && this.plantCodeDate.plantDays > 0 && this.plantCodeDate.notWeekend === false && this.plantCodeDate.sameDayOrder !== true){
                let daysCount = 0;
                let dateTime= new Date().toLocaleString(this.locale,{timeZone:this.timeZone});       
                today = new Date(dateTime);
                today.setDate(today.getDate() + 1);
                while(daysCount < this.plantCodeDate.plantDays + 1 ){             
                    today.setDate(today.getDate() + 1);
                    daysCount ++; 
                }
                today.setDate(today.getDate() - 1);
            }
            if(this.plantCodeDate.sameDayOrder){
                let dateTime= new Date().toLocaleString(this.locale,{timeZone:this.timeZone});       
                today = new Date(dateTime);
                today.setDate(today.getDate());
            }              
        }

        let maxDate = new Date();
        maxDate.setDate(today.getDate() + 90);
        let maxDateShow = (parseInt(maxDate.getMonth())+ parseInt(1))+'/'+maxDate.getDate()+'/'+maxDate.getFullYear();
        let todayDateShow = (parseInt(today.getMonth())+ parseInt(1))+'/'+today.getDate()+'/'+today.getFullYear();
        
        let nxtDay  = new Date();
        nxtDay.setDate(nxtDay.getDate() + 1);
        nxtDay.setHours(0,0,0,0);        

        let index = 1;
        this.errorIndex = -1;
        let startDates;
        let dpoNumber;
        let dloadVolume;
        let totalQuantityCount = 0
        let recordSize = 0;
        let removeIndex = [];
        if(this.csvrows.length > 0){
            if(this.extension === '.XLS' || this.extension === '.XLSX'){
                recordSize = this.csvrows.length;
            }else{
                this.csvrows.splice(this.csvrows.length - 1);
                for (let j = 0; j < this.csvrows.length ; j++) {
                    let element = this.csvrows[j];
                    if((element.hasOwnProperty('Delivery Date') && element['Delivery Date'] === '' ) && (element.hasOwnProperty('Load Volume') && element['Load Volume'] === '' ) && (element.hasOwnProperty('PO Number') && element['PO Number'] === '' ) && (element.hasOwnProperty('Deliveries Per Day') && element['Deliveries Per Day'] === '' )){
                        removeIndex.push(j);
                    }
                }
                for (let i = removeIndex.length -1; i >= 0; i--){
                    this.csvrows .splice(removeIndex[i],1);               
                }
                recordSize = this.csvrows.length;
            }
            let columnCount;
            let columnError = '';
            columnCount = this.csvrows.filter(t => Object.keys(t).includes("Delivery Date")).length;
            if(columnCount === 0){
                columnError = 'Delivery Date column is missing'
            }
            columnCount = this.csvrows.filter(t => Object.keys(t).includes("Load Volume")).length;
            if(columnCount === 0){
                columnError = 'Load Volume column is missing'
            }
            columnCount = this.csvrows.filter(t => Object.keys(t).includes("PO Number")).length;
            if(columnCount === 0){
                columnError = 'PO Number column is missing'
            }
            columnCount = this.csvrows.filter(t => Object.keys(t).includes("Deliveries Per Day")).length;
            if(columnCount === 0){
                columnError = 'Deliveries Per Day column is missing'
            }
            if(columnError !== ''){
                const missingCol = new ShowToastEvent({
                    message: columnError,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(missingCol);
                this.showLoadingSpinner = false;
                this.errorLst = [];
                this.isError = false;
                this.dispatchEvent(new CustomEvent('handlecancelonlimit', {detail: false}));
                return ;
            }
            this.showLoadingSpinner = true;
            for (let j = 0; j < recordSize ; j++) {
                index ++;
                let element = this.csvrows[j];
                    if((element.hasOwnProperty('Delivery Date') && element['Delivery Date'] !== '' ) || (element.hasOwnProperty('Load Volume') && element['Load Volume'] !== '' ) || (element.hasOwnProperty('PO Number') && element['PO Number'] !== '' ) || (element.hasOwnProperty('Deliveries Per Day') && element['Deliveries Per Day'] !== '' ) ){
                        for (let i = 0; i < this.columnHeader.length; i++) {
                            switch(this.columnHeader[i]) {  
                                case "Deliveries Per Day":
                                    let quantity = element[this.columnHeader[i]];
                                    if(!quantity){
                                        this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': Deliveries Per Day should range from 1 to 100.'});
                                    }else{            
                                        if(this.isValidAmount(quantity)){
                                            if(quantity > 100 || quantity < 1){
                                                this.errorLst.push({index:this.errorIndex++,error:' Row '+(index)+': Deliveries Per Day should range from 1 to 100.'});
                                            }else{
                                                totalQuantityCount += Number(quantity);
                                            }
                                        }else{
                                            this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': Deliveries Per Day should range from 1 to 100.'});
                                        }  
                                    } 
                                    break;        
                                case "Load Volume":
                                    let loadVolume = element[this.columnHeader[i]];
                                    if(!loadVolume){
                                        this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': Load Volume Missing'});
                                        break;
                                    }  
                                    this.validateLoadVolume(loadVolume,index);                                                     
                                    break;
                                case "PO Number":
                                    let poNumber = element[this.columnHeader[i]];
                                    if(!poNumber){
                                        this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': ' + PO_Number_Validation});
                                        break;
                                    }                      
                                    break;
                                case "Delivery Date":
                                    let date = element[this.columnHeader[i]];
                                    startDates = date;
                                    dpoNumber = element['PO Number'];
                                    dloadVolume = element['Load Volume'];  
                                    if(!date){
                                        this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': '+ Desired_Delivery_Date_Validation});  
                                        break;
                                    } 
                                    if(!this.isValidDate(date)){
                                        this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': '+ Desired_Delivery_Date_Validation});  
                                        break;
                                    }
                                    
                                    if((new Date(date).setHours(0,0,0,0) > new Date(this.productDetail.validTo).setHours(0,0,0,0))|| (new Date(date).setHours(0,0,0,0) < new Date(this.productDetail.validFrom).setHours(0,0,0,0))){
                                        let code = this.productDetail.productCode+this.productDetail.plantCode;
                                        if(this.getPriceBookProductsValue.hasOwnProperty(code)){
                                            if(this.getPriceBookProductsValue[code] > 20){
                                                this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': Product quote is valid from '+(parseInt(new Date(this.productDetail.validFrom).getMonth())+ parseInt(1))+'/'+new Date(this.productDetail.validFrom).getDate()+'/'+new Date(this.productDetail.validFrom).getFullYear()+' to '+(parseInt(new Date(this.productDetail.validTo).getMonth())+ parseInt(1))+'/'+new Date(this.productDetail.validTo).getDate()+'/'+new Date(this.productDetail.validTo).getFullYear()});
                                                break;
                                            } 
                                        }
                                    }
                                    if(this.plantCodeDate.isPlantCode === true && this.plantCodeDate.plantDays > 0 && this.plantCodeDate.notWeekend === true && this.plantCodeDate.sameDayOrder !==true){
                                        if( (new Date(date).setHours(0,0,0,0)  < new Date(today).setHours(0,0,0,0))){
                                            this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': '+Plant_Code_Validation_Product_Available+' '+this.plantCodeDate.plantDays+' '+Plant_Code_Business_Day_And_Weekend_Validation+' '+todayDateShow+' '+Plant_Code_Validation_Customer_Service});
                                            break;
                                        }
                                        if((new Date(date)).getDay() === 6 || (new Date(date)).getDay() === 0){
                                            this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': '+Plant_Code_Weekend_Validation});
                                            break;
                                        }
                                    } else if(this.plantCodeDate.isPlantCode === true && this.plantCodeDate.plantDays > 0 && this.plantCodeDate.notWeekend === false && this.plantCodeDate.sameDayOrder !==true){
                                        if( (new Date(date).setHours(0,0,0,0)  < new Date(today).setHours(0,0,0,0))){
                                            this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': '+Plant_Code_Validation_Product_Available+' '+this.plantCodeDate.plantDays+' '+Plant_Code_Business_Day_Validation+' '+todayDateShow+' '+Plant_Code_Validation_Customer_Service});
                                            break;
                                        }
                                    }else if(this.plantCodeDate.isPlantCode === true && this.plantCodeDate.plantDays === 0 && this.plantCodeDate.notWeekend === true){
                                        if((new Date(date)).getDay() === 6 || (new Date(date)).getDay() === 0){
                                            this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': '+Plant_Code_Weekend_Validation});
                                            break;
                                        }else{
                                            if( new Date(date).setHours(0,0,0,0) < new Date().setHours(0,0,0,0) || (new Date().setHours(0,0,0,0) === new Date(date).setHours(0,0,0,0) && !isCarrierUser)){
                                                this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': '+ Desired_Delivery_Date_Validation_For_Today});  
                                                break;
                                            }
                                            if( new Date(date).setHours(0,0,0,0)  === new Date(nxtDay).setHours(0,0,0,0) && isNextDay ){
                                                this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': '+Desired_Delivery_Date_Validation_For_Weekend+' '+todayDateShow+'. '+Desired_Delivery_Date_Validation_For_Next_Day});
                                                break;
                                            }
                                        }
                                    }else{
                                        if( new Date(date).setHours(0,0,0,0) < new Date().setHours(0,0,0,0) || (new Date().setHours(0,0,0,0) === new Date(date).setHours(0,0,0,0) && !isCarrierUser && this.plantCodeDate.sameDayOrder !== true)){
                                            this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': '+ Desired_Delivery_Date_Validation_For_Today});  
                                            break;
                                        }
                                        if( new Date(date).setHours(0,0,0,0) > new Date(maxDate).setHours(0,0,0,0) ){
                                            this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': '+Desired_Delivery_Date_Validation_For_Greater_Than+' '+maxDateShow+'.'});
                                            break;
                                        }
                                        if( new Date(date).setHours(0,0,0,0)  === new Date(nxtDay).setHours(0,0,0,0) && isNextDay ){
                                            this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': '+Desired_Delivery_Date_Validation_For_Weekend+' '+todayDateShow+'. '+Desired_Delivery_Date_Validation_For_Next_Day});
                                            break;
                                        }
                                        if( new Date(date).setHours(0,0,0,0)  < new Date(today).setHours(0,0,0,0)){
                                            this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': '+Desired_Delivery_Date_Validation_For_Weekend+' '+todayDateShow+'.'});
                                            break;
                                        } 
                                    }                                                                  
                                    break;                                
                            }               
                        } 
                    } 
                    if(element.hasOwnProperty('Delivery Text')){                  
                        let deliveryText = element['Delivery Text'];
                        if(deliveryText.length > 650){
                            this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': Too long delivery text you can add upto 550 characters only!'});
                        }
                    }
            }
        }else{
            const missingData = new ShowToastEvent({
                message: 'File should contain data',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(missingData);
            this.dispatchEvent(new CustomEvent('handlecancelonlimit', {detail: false}));
            this.showLoadingSpinner = false;
            return ;
        }
        if(totalQuantityCount > 0){
            if(this.totalCount + totalQuantityCount > 500){
                const invalidFileSize = new ShowToastEvent({
                    message: Max_500_Line_Item_Limit,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(invalidFileSize);
                this.dispatchEvent(new CustomEvent('handlecancelonlimit', {detail: false}));
                this.showLoadingSpinner = false;
                return ;
            }
        }else{
            const missingData = new ShowToastEvent({
                message: 'File should contain data',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(missingData);
            this.dispatchEvent(new CustomEvent('handlecancelonlimit', {detail: false}));
            this.showLoadingSpinner = false;
            return ;
        }
       
        if(this.errorLst.length > 0){
            this.showLoadingSpinner = false;  
            this.isError = true;
            this.dispatchEvent(new CustomEvent('handlecanceldataerror', {detail: this.errorLst}));
        }
        if(!this.isError){
            this.dispatchEvent(new CustomEvent('createlistdeliverylineitems', {detail: this.csvrows}));
            const successfullUpload = new ShowToastEvent({
                message: 'File uploaded successfully.',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(successfullUpload);
            let rowsCount = {};
            rowsCount[this.productDetail.Product]=totalQuantityCount;
            let customEvent = new CustomEvent('handlecsvsize',{detail:rowsCount});
            this.dispatchEvent(customEvent);
            this.showLoadingSpinner = false;
            if(startDates !== null && startDates !== undefined){
                startDates = new Date(startDates);
                let date = startDates.getFullYear()+'-' + (parseInt(startDates.getMonth())+ parseInt(1))+'-'+startDates.getDate();
                let productDetails = {'date':date,'poNumber':dpoNumber,'dloadVolume':dloadVolume}
                this.dispatchEvent(new CustomEvent('updateproductdetail', {detail: productDetails}));
            }
        }
    }
    isValidAmount(num){
        if(isNaN(num)){
            return false;
        }else{
            return Number(num) >= 0;
        }     
    }
    isValidDate(dateFormat){ //mm/dd/yy
        let dateparts = dateFormat.split('/');
        let isLengthCorrect = dateparts.length === 3 && (dateparts[0].length == 2 || dateparts[0].length == 1) && (dateparts[1].length == 2 || dateparts[1].length == 1)&& (dateparts[2].length == 2 || dateparts[2].length ==4);
        let isvalidmonth = !isNaN(Number(dateparts[0])) && Number(dateparts[0]) > 0 && Number(dateparts[0]) <= 12;
        let isvalidDay = !isNaN(Number(dateparts[1])) && Number(dateparts[1]) > 0 && Number(dateparts[1]) <= 31;
            return isLengthCorrect && isvalidmonth && isvalidDay;
        }
    getProductDetails(){
        if(this.productDetail != undefined){
            this.currentProductShippingMode = this.productDetail.shippingMode;
        }
    }

    validateLoadVolume(loadVolume,index){
        let loadVolError = '';       
        if (loadVolume.includes('.')) {
            if(Number(loadVolume.split('.')[1]) > 0 && loadVolume.split('.')[1].length > 3){
                this.errorLst.push({index:this.errorIndex++,error:'Row '+(index)+': '+Invalid_Decimal_Number});
            }
        } 
        if(this.effectiveAccountData[0].B2B_Business_Sub_Unit__c === Business_Unit_for_the_MLS_account && loadVolume != 22){
            loadVolError = ' Row '+(index)+': '+Business_Unit_MLS_Account_Validation+' '+this.strShippmentCondition;
        } else{    
            switch(this.currentProductShippingMode) {
                case '99':
                    if((loadVolume > 50 || loadVolume <= 0 || loadVolume === '' || !loadVolume) && !this.overrideGallonLimit) {
                          loadVolError = ' Row '+(index)+': '+Load_Volume_Validation+' 1 to 50 '+this.strShippmentCondition;               
                    }else if((loadVolume > 4500  || loadVolume <= 0) && this.overrideGallonLimit){
                        loadVolError = ' Row '+(index)+': '+Load_Volume_Validation+' 1 to 4500 '+this.strShippmentCondition;  
                    }else{
                        loadVolError = ''
                    }
                    break;
                case '88':
                     if((loadVolume > 4500  || loadVolume <= 0) && this.overrideGallonLimit){
                        loadVolError = ' Row '+(index)+': '+Load_Volume_Validation+' 1 to 4500 '+this.strShippmentCondition;  
                    }
                    break;
                case '25':
                    if(loadVolume > 25 || loadVolume <= 0 || loadVolume === '' || !loadVolume) {
                             loadVolError = ' Row '+(index)+': '+Load_Volume_Validation+' 1 to 25 '+this.strShippmentCondition;
                    }
                    break;                                   
                case '50':
                    if(loadVolume > 50 || loadVolume <= 0 || loadVolume === '' || !loadVolume) {
                            loadVolError = ' Row '+(index)+': '+Load_Volume_Validation+' 1 to 50 '+this.strShippmentCondition;
                    }
                    break;
                case '95':
                    if(loadVolume > 95 || loadVolume <= 0 || loadVolume === '' || !loadVolume) {
                            loadVolError = ' Row '+(index)+': '+Load_Volume_Validation+' 1 to 95 '+this.strShippmentCondition;
                    }
                    break;
                case '36':
                    if(loadVolume > 23 || loadVolume <= 0 || loadVolume === '' || !loadVolume) {
                            loadVolError = ' Row '+(index)+': '+Load_Volume_Validation+' 1 to 23 '+this.strShippmentCondition;
                    }
                    break;
                case '34':
                    if(loadVolume > 23 || loadVolume <= 17 || loadVolume === '' || !loadVolume) {
                            loadVolError = ' Row '+(index)+': '+Load_Volume_Validation+' 18 to 23 '+this.strShippmentCondition;
                    }
                    break;                                   
                case '33':
                    if(loadVolume > 45 || loadVolume <= 0 || loadVolume === '' || !loadVolume) {
                            loadVolError = ' Row '+(index)+': '+Load_Volume_Validation+' 1 to 45 '+this.strShippmentCondition;
                    }
                    break;                                   
                case '35':
                    if(loadVolume > 23 || loadVolume <= 0 || loadVolume === '' || !loadVolume) {
                        loadVolError = ' Row '+(index)+': '+Load_Volume_Validation+' 1 to 23 '+this.strShippmentCondition;
                    }
                    break;                                
                                            
                case '30':
                    if(loadVolume > 23 || loadVolume <= 0 || loadVolume === '' || !loadVolume) {
                        loadVolError = ' Row '+(index)+': '+Load_Volume_Validation+' 1 to 23 '+this.strShippmentCondition;
                    }
                    break;  
                case '37':                                 
                case '38':
                case '32':
                    if(loadVolume > 50 || loadVolume <= 0 || loadVolume === '' || !loadVolume) {
                        loadVolError = ' Row '+(index)+': '+Load_Volume_Validation+' 1 to 50 '+this.strShippmentCondition;
                    }
                    break; 
                case '55':
                case '98':
                case '51':
                    if(loadVolume > 100 || loadVolume <= 0 || loadVolume === '' || !loadVolume) {
                        loadVolError = ' Row '+(index)+': '+Load_Volume_Validation+' 1 to 100 '+this.strShippmentCondition;
                    }
                    break;   
                case '10':
                case '11':                                
                case '15':
                case '97':
                    if(loadVolume > 1600 || loadVolume <= 0 || loadVolume === '' || !loadVolume) {
                        loadVolError = ' Row '+(index)+': '+Load_Volume_Validation+' 1 to 1600 '+this.strShippmentCondition;
                    }
                    break;
            }  
        }
            if(loadVolError.length > 0){
                this.errorLst.push({index:this.errorIndex++,error:loadVolError});
            } 
        
    }
}