import { LightningElement, track, api, wire } from 'lwc';
import getOrderDetail from '@salesforce/apex/OrderController.getOrderDetail';
import UserId from '@salesforce/user/Id';
import getAccessCodeOrPOAllSummaries from '@salesforce/apex/OrderDetailsUtility.getAccessCodeOrPOAllSummaries';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import Search_Access_Code_OR_Po_Warning from '@salesforce/label/c.Search_Access_Code_OR_Po_Warning';
import No_Result_Found from '@salesforce/label/c.No_Result_Found';

export default class CarmeuseCancelOrderSummary extends LightningElement {

   @track wrapper;
   @track err;
   @track isResponse = false;
   @api recordId;
   @track roughData = '{"orderSummaryDetails":{"totalAmount":9446.99,"status":"Created","poNumber":null,"originalOrderId":"8013O00000256WpQAI","orderNumber":"00000160","orderedDate":"2021-04-05T15:08:01.000Z","Id":"1Os3O0000004Dk0SAE","description":null,"billingStreet":"3001 DICKEY RD","billingState":"IN","billingPostalCode":"46312","billingCountry":"US","billingCity":"EAST CHICAGO","accountName":"966 - ARCELORMITTAL BURNS HARBOR - STEEL","accountId":"0013O00000amRwaQAE"},"orderNumber":null,"orderItemSummaryWrapperList":[{"stockKeepingUnit":"10325","quantity":5,"productName":"Dolo QL","productCode":"10325","product2Id":"01t3O0000042dH6QAI","orderSummaryId":"1Os3O0000004Dk0SAE","orderDeliveryGroupSummaryWrapperHeaderList":[{"quantity":5,"orderDeliveryGroupSummaryWrapperList":[{"shipmentWeight":"75","shipmentTonnage":"200","shipmentStatus":"Shipped","shipmentSizeType":null,"shipmentSize":null,"shipmentDateTime":"4\/11\/2021","quantity":1,"poNumber":null,"orderSummaryId":"1Os3O0000004Dk0SAE","orderDeliveryMethodId":"2Dm3O0000004CDeSAM","materialNumber":"000000000000010325","Id":"0ag3O0000004DkCQAU","desiredDeliveryDate":"2021-04-06T00:00:00.000Z","description":null,"deliveryInstructions":null,"deliverToStreet":"250 WEST US HIGHWAY 12","deliverToState":"IN","deliverToPostalCode":"46304","deliverToName":"966 - ARCELORMITTAL BURNS HARBOR - STEEL- Shipping","deliverToCountry":"US","deliverToCity":"BURNS HARBOR","bolNumber":"12345","accountExternalNumber":null,"accessCode":"11"},{"shipmentWeight":"75","shipmentTonnage":"200","shipmentStatus":"Shipped","shipmentSizeType":null,"shipmentSize":null,"shipmentDateTime":"4\/11\/2021","quantity":1,"poNumber":null,"orderSummaryId":"1Os3O0000004Dk0SAE","orderDeliveryMethodId":"2Dm3O0000004CDeSAM","materialNumber":"000000000000010325","Id":"0ag3O0000004DkDQAU","desiredDeliveryDate":"2021-04-06T00:00:00.000Z","description":null,"deliveryInstructions":null,"deliverToStreet":"250 WEST US HIGHWAY 12","deliverToState":"IN","deliverToPostalCode":"46304","deliverToName":"966 - ARCELORMITTAL BURNS HARBOR - STEEL- Shipping","deliverToCountry":"US","deliverToCity":"BURNS HARBOR","bolNumber":"12345","accountExternalNumber":null,"accessCode":"12"},{"shipmentWeight":"75","shipmentTonnage":"200","shipmentStatus":"Shipped","shipmentSizeType":null,"shipmentSize":null,"shipmentDateTime":"4\/11\/2021","quantity":1,"poNumber":null,"orderSummaryId":"1Os3O0000004Dk0SAE","orderDeliveryMethodId":"2Dm3O0000004CDeSAM","materialNumber":"000000000000010325","Id":"0ag3O0000004DkEQAU","desiredDeliveryDate":"2021-04-06T00:00:00.000Z","description":null,"deliveryInstructions":null,"deliverToStreet":"250 WEST US HIGHWAY 12","deliverToState":"IN","deliverToPostalCode":"46304","deliverToName":"966 - ARCELORMITTAL BURNS HARBOR - STEEL- Shipping","deliverToCountry":"US","deliverToCity":"BURNS HARBOR","bolNumber":"12345","accountExternalNumber":null,"accessCode":"21"},{"shipmentWeight":"75","shipmentTonnage":"200","shipmentStatus":"Shipped","shipmentSizeType":null,"shipmentSize":null,"shipmentDateTime":"4\/11\/2021","quantity":1,"poNumber":null,"orderSummaryId":"1Os3O0000004Dk0SAE","orderDeliveryMethodId":"2Dm3O0000004CDeSAM","materialNumber":"000000000000010325","Id":"0ag3O0000004DkFQAU","desiredDeliveryDate":"2021-04-06T00:00:00.000Z","description":null,"deliveryInstructions":null,"deliverToStreet":"250 WEST US HIGHWAY 12","deliverToState":"IN","deliverToPostalCode":"46304","deliverToName":"966 - ARCELORMITTAL BURNS HARBOR - STEEL- Shipping","deliverToCountry":"US","deliverToCity":"BURNS HARBOR","bolNumber":"12345","accountExternalNumber":null,"accessCode":"40"},{"shipmentWeight":"75","shipmentTonnage":"200","shipmentStatus":"Shipped","shipmentSizeType":null,"shipmentSize":null,"shipmentDateTime":"4\/11\/2021","quantity":1,"poNumber":null,"orderSummaryId":"1Os3O0000004Dk0SAE","orderDeliveryMethodId":"2Dm3O0000004CDeSAM","materialNumber":"000000000000010325","Id":"0ag3O0000004DkHQAU","desiredDeliveryDate":"2021-04-06T00:00:00.000Z","description":null,"deliveryInstructions":null,"deliverToStreet":"250 WEST US HIGHWAY 12","deliverToState":"IN","deliverToPostalCode":"46304","deliverToName":"966 - ARCELORMITTAL BURNS HARBOR - STEEL- Shipping","deliverToCountry":"US","deliverToCity":"BURNS HARBOR","bolNumber":"12345","accountExternalNumber":null,"accessCode":"51"}],"materialNumber":"000000000000010325","desiredDeliveryDateStr":"4\/5\/2021","desiredDeliveryDate":null,"deliverToStreet":"250 WEST US HIGHWAY 12","deliverToState":"IN","deliverToPostalCode":"46304","deliverToName":"966 - ARCELORMITTAL BURNS HARBOR - STEEL- Shipping","deliverToCountry":"US","deliverToCity":"BURNS HARBOR"}],"orderDeliveryGroupSummaryId":"0ag3O0000004DkAQAU","materialNumber":"000000000000010325"},{"stockKeepingUnit":"10320","quantity":5,"productName":"HiCal QL SteelGr ","productCode":"10320","product2Id":"01t3O0000042dH3QAI","orderSummaryId":"1Os3O0000004Dk0SAE","orderDeliveryGroupSummaryWrapperHeaderList":[{"quantity":5,"orderDeliveryGroupSummaryWrapperList":[{"shipmentWeight":"75","shipmentTonnage":"200","shipmentStatus":"Shipped","shipmentSizeType":null,"shipmentSize":null,"shipmentDateTime":"5\/11\/2021","quantity":1,"poNumber":null,"orderSummaryId":"1Os3O0000004Dk0SAE","orderDeliveryMethodId":"2Dm3O0000004CDeSAM","materialNumber":"000000000000010320","Id":"0ag3O0000004Dk8QAE","desiredDeliveryDate":"2021-04-11T00:00:00.000Z","description":null,"deliveryInstructions":null,"deliverToStreet":"250 WEST US HIGHWAY 12","deliverToState":"IN","deliverToPostalCode":"46304","deliverToName":"966 - ARCELORMITTAL BURNS HARBOR - STEEL- Shipping","deliverToCountry":"US","deliverToCity":"BURNS HARBOR","bolNumber":"12345","accountExternalNumber":null,"accessCode":"21"},{"shipmentWeight":"75","shipmentTonnage":"200","shipmentStatus":"Shipped","shipmentSizeType":null,"shipmentSize":null,"shipmentDateTime":"5\/11\/2021","quantity":1,"poNumber":null,"orderSummaryId":"1Os3O0000004Dk0SAE","orderDeliveryMethodId":"2Dm3O0000004CDeSAM","materialNumber":"000000000000010320","Id":"0ag3O0000004DkGQAU","desiredDeliveryDate":"2021-04-11T00:00:00.000Z","description":null,"deliveryInstructions":null,"deliverToStreet":"250 WEST US HIGHWAY 12","deliverToState":"IN","deliverToPostalCode":"46304","deliverToName":"966 - ARCELORMITTAL BURNS HARBOR - STEEL- Shipping","deliverToCountry":"US","deliverToCity":"BURNS HARBOR","bolNumber":"12345","accountExternalNumber":null,"accessCode":"31"},{"shipmentWeight":"75","shipmentTonnage":"200","shipmentStatus":"Shipped","shipmentSizeType":null,"shipmentSize":null,"shipmentDateTime":"5\/11\/2021","quantity":1,"poNumber":null,"orderSummaryId":"1Os3O0000004Dk0SAE","orderDeliveryMethodId":"2Dm3O0000004CDeSAM","materialNumber":"000000000000010320","Id":"0ag3O0000004Dk9QAE","desiredDeliveryDate":"2021-04-11T00:00:00.000Z","description":null,"deliveryInstructions":null,"deliverToStreet":"250 WEST US HIGHWAY 12","deliverToState":"IN","deliverToPostalCode":"46304","deliverToName":"966 - ARCELORMITTAL BURNS HARBOR - STEEL- Shipping","deliverToCountry":"US","deliverToCity":"BURNS HARBOR","bolNumber":"12345","accountExternalNumber":null,"accessCode":"14"},{"shipmentWeight":"75","shipmentTonnage":"200","shipmentStatus":"Shipped","shipmentSizeType":null,"shipmentSize":null,"shipmentDateTime":"5\/11\/2021","quantity":1,"poNumber":null,"orderSummaryId":"1Os3O0000004Dk0SAE","orderDeliveryMethodId":"2Dm3O0000004CDeSAM","materialNumber":"000000000000010320","Id":"0ag3O0000004DkAQAU","desiredDeliveryDate":"2021-04-11T00:00:00.000Z","description":null,"deliveryInstructions":null,"deliverToStreet":"250 WEST US HIGHWAY 12","deliverToState":"IN","deliverToPostalCode":"46304","deliverToName":"966 - ARCELORMITTAL BURNS HARBOR - STEEL- Shipping","deliverToCountry":"US","deliverToCity":"BURNS HARBOR","bolNumber":"12345","accountExternalNumber":null,"accessCode":"91"},{"shipmentWeight":"75","shipmentTonnage":"200","shipmentStatus":"Shipped","shipmentSizeType":null,"shipmentSize":null,"shipmentDateTime":"5\/11\/2021","quantity":1,"poNumber":null,"orderSummaryId":"1Os3O0000004Dk0SAE","orderDeliveryMethodId":"2Dm3O0000004CDeSAM","materialNumber":"000000000000010320","Id":"0ag3O0000004DkBQAU","desiredDeliveryDate":"2021-04-11T00:00:00.000Z","description":null,"deliveryInstructions":null,"deliverToStreet":"250 WEST US HIGHWAY 12","deliverToState":"IN","deliverToPostalCode":"46304","deliverToName":"966 - ARCELORMITTAL BURNS HARBOR - STEEL- Shipping","deliverToCountry":"US","deliverToCity":"BURNS HARBOR","bolNumber":"12345","accountExternalNumber":null,"accessCode":"99"}],"materialNumber":"000000000000010320","desiredDeliveryDateStr":"4\/10\/2021","desiredDeliveryDate":null,"deliverToStreet":"250 WEST US HIGHWAY 12","deliverToState":"IN","deliverToPostalCode":"46304","deliverToName":"966 - ARCELORMITTAL BURNS HARBOR - STEEL- Shipping","deliverToCountry":"US","deliverToCity":"BURNS HARBOR"}],"orderDeliveryGroupSummaryId":"0ag3O0000004DkEQAU","materialNumber":"000000000000010320"}],"Id":null}';
   @track isOwner = true;
   @track accountExternalNumber;
   @track searchValue;
   @track isNext = false;
   @api effectiveAccountId;
   @track viewSearchBar = true;
   @track orderSummaryRecordsArray = [];
   @track orderSummaryRecords;

   connectedCallback() {
      this.getOrderDetail();
   }
   async getOrderDetail() {
      await getOrderDetail({ orderId: this.recordId })
         .then(result => {
            this.wrapper = result;
            this.isResponse = true;
            this.OriginalOrderId = result.orderSummaryDetails.orderSummaryRecord.OriginalOrderId;
            if (result && result.orderSummaryDetails) {
               if (UserId === result.orderSummaryDetails.ownerid) {
                  this.isOwner = true
               } else {
                  this.isOwner = false;
               }
               if (result.orderSummaryDetails.accountExternalNumber !== undefined) {
                  this.accountExternalNumber = result.orderSummaryDetails.accountExternalNumber;
               }
            }
         }).catch(error => {
            this.err = error;
         });
      this.orderSummaryRecordsArray.push(this.recordId);
   }

   @wire(CurrentPageReference)
   getPageReferenceParameters(currentPageReference) {
      if (currentPageReference) {
         let attributes = currentPageReference.attributes.actionName;
         if (attributes == 'list') {
            this.viewSearchBar = false;
         }
      }
   }
   scrollToTop() {
      window.scrollTo({
         top: 0,
         left: 0,
         behavior: 'smooth'
      });
   }
   keycheck(event) {
      if (event.code == 'Enter') {
         this.handleSearchKeyword();
      }
   }
   handleSearch(event) {
      let search = event.target.value;
      this.searchValue = search.trim();
   }
   previousFound() {
      window.find(this.searchValue, false, true, true, true);
   }
   handleSearchKeyword() {
      if (this.searchValue == null || this.searchValue == '') {
         this.showNotification(Search_Access_Code_OR_Po_Warning, 'Warning', 'dismissable');
      }
      else {
         this.getAccessCodeOrPOAllSummaries();
      }
   }
   findOnPage() {
      window.find(this.searchValue, false, false, true, true);
   }

   async getAccessCodeOrPOAllSummaries() {
      await getAccessCodeOrPOAllSummaries({ accessCode: this.searchValue, poNumber: this.searchValue, orderSummryId: this.orderSummaryRecordsArray })
         .then((result) => {
            if (result) {
               this.isNext = true;
               this.findOnPage();
            }
            else { this.showNotification(No_Result_Found, 'Error', 'dismissable'); }
         })
         .catch((error) => {
            console.log('error getAccessCodeOrPOAllSummaries' + JSON.stringify(error));
         });
   }
   showNotification(message, variant, mode) {
      const evt = new ShowToastEvent({
         message: message,
         variant: variant,
         mode: mode
      });
      this.dispatchEvent(evt);
   }
}