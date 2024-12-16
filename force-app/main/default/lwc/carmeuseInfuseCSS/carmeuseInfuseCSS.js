import { LightningElement } from 'lwc';

export default class CarmeuseInfuseCSS extends LightningElement {

    renderedCallback(){
        const style = document.createElement('style');
        style.innerText = `
        .forceOutputLookupWithPreview a{
                pointer-events: none !important;
            }

            .actionsContainer{
                display: none !important;
            }
            .view-all-label {
                display: none !important;
            }`;

        this.template.querySelector('div').appendChild(style);

       
    }
}